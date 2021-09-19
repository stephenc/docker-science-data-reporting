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
    bash \
    build-essential \
    curl \
    git \
    latexmk \
    r-base \
    ruby-dev \
    texlive-latex-extra \
    wget \
    unzip \
    zip ; \
  apt-get clean ; \
  curl -s "https://get.sdkman.io?rcupdate=false" | bash ; \
  bash -c 'set -ex ; \
    source "$SDKMAN_DIR/bin/sdkman-init.sh" ; \
    sdk install java 11.0.11.hs-adpt ; \
    sdk install maven 3.8.2 ; \
    sdk install jbang 0.78.0 ; \
    rm -rf "$SDKMAN_DIR/archives/*.zip" ;   \
    ' ; \
  gem install asciidoctor asciidoctor-bibtex asciidoctor-kroki

ENV PATH=$SDKMAN_DIR/candidates/java/current/bin:$SDKMAN_DIR/candidates/jbang/current/bin:$SDKMAN_DIR/candidates/maven/current/bin:$PATH
ENV JAVA_HOME=$SDKMAN_DIR/candidates/java/current


