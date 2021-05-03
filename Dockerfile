FROM ruby:2.6-alpine

USER root

ENV APP_ROOT /app
ENV PORT 9292
ENV RACK_ENV production
ENV BUNDLE_PATH /bundle

RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

ADD ./Gemfile $APP_ROOT
ADD ./Gemfile.lock $APP_ROOT

RUN apk add --update --no-cache imagemagick curl-dev font-noto \
  && apk add --update --no-cache --virtual=build-dependencies alpine-sdk \
  && bundle install -j$(nproc) --without development test \
  && apk del build-dependencies

ADD . $APP_ROOT

EXPOSE $PORT
CMD ["bundle", "exec", "puma"]
