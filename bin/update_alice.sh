#!/bin/sh
. /home/alice/.my_set
tar czvf alice.`date +%Y%m%d`.tgz alice/
rm -rf alice
git clone https://github.com/pachiara/alice.git
cd alice/
bundle install
EDITOR="mate --wait" bin/rails credentials:edit
bundle exec rake db:migrate RAILS_ENV=production
bundle exec rake tmp:clear
bundle exec rake log:clear
bundle exec rake assets:clean
bundle exec rake assets:precompile RAILS_RELATIVE_URL_ROOT=/alice
