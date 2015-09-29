FROM ruby:2.2

RUN apt-get update && apt-get install -y libsodium-dev

RUN mkdir /app
WORKDIR /app

COPY Gemfile* /app/
RUN bundle install

COPY . /app

CMD puma -C config/puma.rb
