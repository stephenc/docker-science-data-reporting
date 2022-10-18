#   Copyright 2022 Stephen Connolly
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

FROM eclipse-temurin:18.0.2.1_1-jdk as java

ARG MAVEN_VERSION=3.8.5
ARG JBANG_VERSION=0.98.0

ENV SDKMAN_DIR=/usr/local/sdkman
ENV PATH=$SDKMAN_DIR/bin;$PATH
RUN set -ex ; \
  export DEBIAN_FRONTEND=noninteractive ; \
  apt-get update -y ; \
  apt-get install -y -q \
    curl zip ; \
  curl -s "https://get.sdkman.io?rcupdate=false" | bash ; \
  bash -c 'set -ex ; \
    source "$SDKMAN_DIR/bin/sdkman-init.sh" ; \
    sdk install maven ${MAVEN_VERSION} ; \
    sdk install jbang ${JBANG_VERSION} ; \
    rm -rf "$SDKMAN_DIR/archives/*.zip" ; \
    ' ; \
  apt-get clean

FROM r-base:4.2.1

ENV SDKMAN_DIR=/usr/local/sdkman
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=java $JAVA_HOME $JAVA_HOME
COPY --from=java $SDKMAN_DIR $SDKMAN_DIR
ENV PATH="${JAVA_HOME}/bin:${SDKMAN_DIR}/candidates/jbang/current/bin:${SDKMAN_DIR}/candidates/maven/current/bin:/usr/local/share/bin:${PATH}"

RUN set -ex ; \
  export DEBIAN_FRONTEND=noninteractive ; \
  apt-get update -y ; \
  apt-get install -y -q \
    cmake \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libzstd-dev \
    libfontconfig1-dev \
    pandoc \
    pandoc-citeproc \
    gpg \
    ; \
  apt-get clean ; \
  #
  # Switch the docker user to UID 1001 for compatibility with GitHub Actions
  #
  usermod -u 1001 docker ; \
  groupmod -g 1001 docker ; \
  chown docker:docker /home/docker 

ENV RENV_PATHS_ROOT=/usr/local/share/renv

ARG RENV_PRELOAD="methods tidyverse nlme ggthemes gridExtra Matrix MatrixModels ggpubr zoo dplyr lubridate xtable expint deSolve qrcode ggplotify gtools rmarkdown rio rticles bookdown kableExtra"

RUN set -ex ; \
  #
  # Preload renv and then the latest versions of the preload packages
  #
  mkdir preload ; \
  cd preload ; \
  Rscript -e ' \
  install.packages("renv", lib="/usr/local/lib/R/site-library") ; \
  renv::init() ; \
  preload <- strsplit(Sys.getenv("RENV_PRELOAD"), " ") ; \
  preload <- preload[nzchar(preload) && !is.na(preload)] ; \
  for (package in preload) { \
    renv::install(package) ; \
  } ; \
  tinytex::install_tinytex(dir="/usr/local/share/TinyTeX", add_path=FALSE, extra_packages=c("fancyhdr","units","microtype")) \
  ' ; \
  cd .. ; \
  #
  # Now we can throw away the preload project
  #
  rm -rvf preload ; \
  #
  # Wire up TinyTeX on the path for both root and docker using a shared install
  #
  /usr/local/share/TinyTeX/bin/*/tlmgr option sys_bin /usr/local/share/bin ; \
  mkdir /usr/local/share/bin ; \
  chmod -R g+w /usr/local/share/bin ; \
  chgrp -R staff /usr/local/share/bin ; \
  ln -s /usr/local/share/TinyTeX /home/docker/.TinyTeX ; \
  /usr/local/share/TinyTeX/bin/*/tlmgr path add ; \
  chgrp -R staff /usr/local/lib/R /usr/local/share/TinyTeX "${RENV_PATHS_ROOT}" ; \
  chmod -R g+w /usr/local/lib/R /usr/local/share/TinyTeX "${RENV_PATHS_ROOT}"

ENV R_LIBS=/usr/local/lib/R/site-library:/usr/lib/R/site-library:/usr/lib/R/library

ENTRYPOINT ["/bin/bash"]
