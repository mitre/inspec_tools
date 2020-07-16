FROM ruby:alpine
COPY *.gem /tmp
ENV CHEF_LICENSE=accept-silent
RUN apk add --no-cache build-base && gem install /tmp/*.gem && apk del build-base
ENTRYPOINT ["inspec_tools"]
VOLUME ["/share"]
WORKDIR /share
