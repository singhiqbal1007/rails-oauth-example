FROM ruby:2.7.4
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev npm nodejs
RUN mkdir /rails_oauth_practice
WORKDIR /rails_oauth_practice
ADD Gemfile /rails_oauth_practice/Gemfile
ADD Gemfile.lock /rails_oauth_practice/Gemfile.lock
RUN bundle install
RUN npm install --global yarn
ADD . /rails_oauth_practice
RUN bundle exec rake assets:precompile
