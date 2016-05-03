FROM ruby:2.2.4

RUN apt-get update && apt-get install -y libsodium-dev

RUN mkdir /app
WORKDIR /app

COPY Gemfile* /app/
RUN bundle install

COPY . /app

EXPOSE 9393
CMD puma -C config/puma.rb
