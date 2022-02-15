rm -f /rails_oauth_practice/tmp/pids/server.pid
if [[ "${REMOVE_GEMFILE_LOCK}" == "true" ]]; then
  rm -f /rails_oauth_practice/Gemfile.lock
fi
bundle install
