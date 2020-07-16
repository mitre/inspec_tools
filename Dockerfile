FROM ruby:alpine
COPY *.gem /tmp
ENV CHEF_LICENSE=accept-silent
RUN gem install /tmp/*.gem
ENTRYPOINT ["inspec_tools"]
VOLUME ["/share"]
WORKDIR /share
