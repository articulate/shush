FROM articulate/articulate-ruby:2.4-stretch-slim

RUN apt-get update -qq \
    && apt-get install -y locales libsodium-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN ln -fs /usr/share/zoneinfo/GMT /etc/localtime

ENV SERVICE_USER service
ENV SERVICE_ROOT /service

COPY Gemfile* $SERVICE_ROOT/
RUN bundle install

COPY . $SERVICE_ROOT

RUN chown -R $SERVICE_USER:$SERVICE_USER $SERVICE_ROOT
USER $SERVICE_USER

EXPOSE 3000
CMD puma -C config/puma.rb
