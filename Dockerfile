FROM ruby:2.5

RUN apt-get update
RUN apt-get install libmagickwand-dev -y
RUN apt-get install ghostscript -y
RUN gem install rmagick

WORKDIR /
ADD animeface-2009 /animeface-2009
WORKDIR /animeface-2009
RUN ./build.sh

RUN gem install sinatra
RUN gem install sinatra-contrib
WORKDIR /
ADD src /app
WORKDIR /app
RUN cp /animeface-2009/animeface-ruby/AnimeFace.so /app

EXPOSE $PORT
CMD ruby /app/app.rb -p $PORT