#!/usr/bin/env bash
set -e

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv install 3.4.7
rbenv global 3.4.7
gem install rails
