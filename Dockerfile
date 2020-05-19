FROM ruby:alpine
LABEL maintainer="Chef Software, Inc. <docker@chef.io>"

ARG EXPEDITOR_VERSION
ARG VERSION=4.18.114
ARG GEM_SOURCE=https://rubygems.org

# Allow VERSION below to be controlled by either VERSION or EXPEDITOR_VERSION build arguments
ENV VERSION ${EXPEDITOR_VERSION:-${VERSION}}

RUN mkdir -p /share
RUN apk add --update build-base libxml2-dev libffi-dev git openssh-client
RUN gem install --no-document --source ${GEM_SOURCE} --version ${VERSION} inspec
RUN gem install --no-document --source ${GEM_SOURCE} --version ${VERSION} inspec-bin
RUN apk del build-base

COPY lib/ lib/
COPY Rakefile .
COPY CHANGELOG.md .
COPY LICENSE.md .
COPY README.md .
COPY exe/inspec_tools exe/inspec_tools
COPY inspec_tools.gemspec .

RUN gem build inspec_tools.gemspec

ENTRYPOINT ["inspec"]
CMD ["help"]
VOLUME ["/share"]
WORKDIR /share
