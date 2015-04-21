FROM ruby:2.2.1

RUN apt-get update -qq

# Install JS tools
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN npm install -g bower

# Install Ruby tools
RUN gem install middleman

# Expose Middleman port
EXPOSE 4567

# Cache Bundled gems
WORKDIR /tmp
COPY Gemfile /tmp/
COPY Gemfile.lock /tmp/
RUN bundle install

WORKDIR /workdir
COPY . /workdir
