web: bundle exec puma -p $PORT -e $RACK_ENV
worker: bundle exec sidekiq -e production -C config/sidekiq.yml