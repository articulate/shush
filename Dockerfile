FROM ruby:2.2

RUN mkdir /app
WORKDIR /app

COPY Gemfile* /app/
RUN bundle install

COPY . /app

CMD puma -C config/puma.rb
