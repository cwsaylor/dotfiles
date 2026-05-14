#!/usr/bin/env bash
set -e

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv install 4.0.4
rbenv global 4.0.4
gem install rails
