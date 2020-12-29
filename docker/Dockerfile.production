FROM ruby:2.6-alpine

ENV BUNDLE_PATH /bundle
ENV RACK_ENV production

RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN apk add --update --no-cache imagemagick curl-dev font-noto \
  && apk add --update --no-cache --virtual=build-dependencies alpine-sdk \
  && bundle install \
  && apk del build-dependencies

COPY . /app

CMD ["bundle", "exec", "puma"]
