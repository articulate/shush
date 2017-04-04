FROM ruby:2.4

ENV SERVICE_USER service
ENV SERVICE_ROOT /service

RUN groupadd $SERVICE_USER && useradd --create-home --home $SERVICE_ROOT --gid $SERVICE_USER --shell /bin/bash $SERVICE_USER
WORKDIR $SERVICE_ROOT

RUN apt-get update && apt-get install -y libsodium-dev

COPY Gemfile* $SERVICE_ROOT/
RUN bundle install

COPY . $SERVICE_ROOT

RUN chown -R $SERVICE_USER:$SERVICE_USER $SERVICE_ROOT
USER $SERVICE_USER

EXPOSE 3000
CMD puma -C config/puma.rb
