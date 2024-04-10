# Dockerfile

FROM ruby:3.2.2

RUN mkdir /app
WORKDIR /app

COPY . /app

RUN bundle install

EXPOSE 9292

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0"]