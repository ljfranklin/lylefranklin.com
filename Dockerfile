FROM ruby:2.2.2

WORKDIR /tmp
RUN apt-get update -qq && apt-get install -y \
  nodejs \
  npm \
  wget

# Install JS tools
RUN npm install -g bower
RUN wget -O phantomjs.tar.bz2 --no-check-certificate https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2
RUN mkdir -p phantomjs
RUN tar xjf phantomjs.tar.bz2 -C phantomjs/ --strip-components=1
RUN cp phantomjs/bin/phantomjs /usr/local/bin/

# Install Ruby tools
RUN gem install middleman rspec

# Expose Middleman port
EXPOSE 4567

# Cache Bundled gems
COPY Gemfile /tmp/
COPY Gemfile.lock /tmp/
RUN bundle install

WORKDIR /workdir
COPY . /workdir
