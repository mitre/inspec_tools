FROM ruby:alpine

RUN mkdir -p /share
RUN apk add --update build-base

COPY ./ ./
RUN gem build inspec_tools.gemspec
RUN gem install inspec_tools --pre --no-document
RUN apk del build-base

ENTRYPOINT ["inspec_tools"]
VOLUME ["/share"]
WORKDIR /share
