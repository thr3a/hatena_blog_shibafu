FROM ruby:2.6-alpine

ENV BUNDLE_PATH /bundle

RUN mkdir /app
WORKDIR /app
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

RUN apk add --update --no-cache imagemagick curl-dev font-noto \
  && apk add --update --no-cache --virtual=build-dependencies alpine-sdk \
  && bundle install \
  && apk del build-dependencies