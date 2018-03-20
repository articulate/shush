FROM ruby:2.4-alpine3.7

ENV SERVICE_USER service
ENV SERVICE_ROOT /service

RUN addgroup $SERVICE_USER && adduser -h $SERVICE_ROOT -G $SERVICE_USER -s /bin/bash $SERVICE_USER -D
WORKDIR $SERVICE_ROOT

RUN apk update && apk upgrade && apk add libsodium-dev git curl-dev ruby-dev build-base

COPY Gemfile* $SERVICE_ROOT/
RUN bundle install

COPY . $SERVICE_ROOT

RUN chown -R $SERVICE_USER:$SERVICE_USER $SERVICE_ROOT
USER $SERVICE_USER

EXPOSE 3000
CMD puma -C config/puma.rb
