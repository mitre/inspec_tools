FROM ruby:alpine AS builder

RUN mkdir -p /share
RUN apk add --no-cache build-base git-lfs

COPY . /build
RUN cd /build && \
    bundle install && \
    rake build_release

FROM ruby:alpine

ENV CHEF_LICENSE=accept-silent
RUN apk add --no-cache build-base

COPY --from=builder /build/inspec_tools.gem /build/
RUN gem install build/inspec_tools.gem

RUN apk del build-base

ENTRYPOINT ["inspec_tools"]
VOLUME ["/share"]
WORKDIR /share
