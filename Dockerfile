FROM articulate/articulate-ruby:2.3

RUN apt-get update && apt-get install -y libsodium-dev

RUN mkdir /app
WORKDIR /app

COPY Gemfile* /app/
RUN bundle install

COPY . /app

EXPOSE 9393
CMD puma -C config/puma.rb
