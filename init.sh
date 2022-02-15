pwd
rm -f ./tmp/pids/server.pid
if [[ "${REMOVE_GEMFILE_LOCK}" == "true" ]]; then
  rm -rf ./Gemfile.lock
fi
bundle install
