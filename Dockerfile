FROM stackbrew/ubuntu:12.04
RUN apt-get update -qq && apt-get install -y build-essential git python-software-properties
RUN add-apt-repository -y ppa:brightbox/ruby-ng-experimental
RUN apt-get update -qq && apt-get install -y ruby2.0 ruby2.0-dev libxslt-dev libxml2-dev libmysqlclient-dev nodejs zip imagemagick xpdf file
RUN gem install -v 1.3.5 bundler
ADD Gemfile /code/
ADD Gemfile.lock /code/
WORKDIR /code/
RUN bundle install
ADD . /code/
EXPOSE 3020
CMD bundle exec rails server -p 3020
