#   Copyright 2021 Stephen Connolly
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

FROM ubuntu:20.04

LABEL \
  org.opencontainers.image.title="Docker Image of Some toolchains useful for scientific data analysis and reporting" \
  org.opencontainers.image.authors="Stephen Connolly <stephenc@apache.org>" \
  org.opencontainers.image.source="https://github.com/stephenc/docker-science-data-reporting" \
  org.opencontainers.image.licenses="ASLv2"

ENV SDKMAN_DIR=/usr/local/sdkman
ENV PATH=$SDKMAN_DIR/bin;$PATH

RUN set -ex ; \
  export DEBIAN_FRONTEND=noninteractive ; \
  apt-get update -y ; \
  apt-get install -y -q \
    dirmngr \
    gnupg \
    apt-transport-https \
    ca-certificates \
    software-properties-common ;\
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 ; \
  add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' ; \
  apt-get update -y ; \
  apt-get install -y -q \
    bash \
    bison \
    build-essential \
    cmake \
    curl \
    flex \
    fonts-lyx \
    git \
    graphviz \
    language-pack-en \
    latexmk \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    libgdk-pixbuf2.0-dev \
    libpango1.0-dev \
    libssl-dev \
    libxml2-dev \
    r-base \
    ruby-dev \
    sed \
    texlive-bibtex-extra \
    texlive-font-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-base \
    texlive-latex-extra \
    wget \
    unzip \
    zip ; \
  apt-get clean

RUN set -ex ; \
  curl -s "https://get.sdkman.io?rcupdate=false" | bash ; \
  bash -c 'set -ex ; \
    source "$SDKMAN_DIR/bin/sdkman-init.sh" ; \
    sdk install java 17.0.3-tem ; \
    sdk install maven 3.8.5 ; \
    sdk install jbang 0.94.0 ; \
    rm -rf "$SDKMAN_DIR/archives/*.zip" ;   \
    '
RUN set -ex ; \
  MATHEMATICAL_SKIP_STRDUP=1 gem install mathematical ; \
  gem install \
    asciidoctor \
    asciidoctor-bibtex \
    asciidoctor-kroki \
    asciidoctor-mathematical \
    asciidoctor-pdf 

ENV PATH=$SDKMAN_DIR/candidates/java/current/bin:$SDKMAN_DIR/candidates/jbang/current/bin:$SDKMAN_DIR/candidates/maven/current/bin:$PATH
ENV JAVA_HOME=$SDKMAN_DIR/candidates/java/current

# R tidyverse packages need TZ environment variable defined.
ENV TZ=UTC
# R needs a UTF-8 locale to load CSV files with non-ascii characters
ENV LANG=C.UTF-8
ENV RENV_PATHS_CACHE=/usr/local/share/renv
COPY seed-environments/r /tmp/seed-environments/r
RUN set -ex ; \
  cd /tmp/seed-environments/r ; \
  Rscript init.R ; \
  cd / ; \
  rm -rf /tmp/seed-environments ; \
  chmod -R a+rw "${RENV_PATHS_CACHE}" "/usr/local/lib/R/site-library"

# GitHub actions compatibility is better if we use user 1001
RUN set -ex ; \
  useradd -u 1001 user ; \
  mkdir /home/user ; \
  chown user:user /home/user

USER 1001
WORKDIR /home/user
ENTRYPOINT ["/bin/bash"]

