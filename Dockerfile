FROM ruby:alpine AS builder

RUN mkdir -p /share
RUN apk add --update build-base git

COPY . /build
RUN cd /build && \
    bundle install && \
    gem build inspec_tools.gemspec -o inspec_tools.gem


FROM ruby:alpine

RUN apk add --update build-base

COPY --from=builder /build /build
RUN cd build && \
    gem install inspec_tools.gem 
    
RUN apk del build-base

ENTRYPOINT ["inspec_tools"]
VOLUME ["/share"]
WORKDIR /share
