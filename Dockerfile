FROM ruby:3.3.3
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && apt-get install -y \
    build-essential \
    nodejs \
    yarn \
    imagemagick && \
    mkdir /recipe_app

WORKDIR /recipe_app
COPY Gemfile /recipe_app/Gemfile
COPY Gemfile.lock /recipe_app/Gemfile.lock
RUN bundle install
COPY . /recipe_app

RUN rm -f tmp/pids/server.pid

CMD ["rails", "server", "-b", "0.0.0.0"]
