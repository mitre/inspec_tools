FROM ruby:2-alpine
COPY *.gem /tmp
ENV CHEF_LICENSE=accept-silent
RUN apk add --no-cache build-base
RUN gem install /tmp/*.gem
RUN apk del build-base
ENTRYPOINT ["inspec_tools"]
VOLUME ["/share"]
WORKDIR /share
