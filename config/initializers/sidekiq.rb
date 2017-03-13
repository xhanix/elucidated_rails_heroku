Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDISTOGO_URL"], namespace: :resque }
  
  database_url = ENV['DATABASE_URL']
  if database_url
    ENV['DATABASE_URL'] = "#{database_url}?pool=250"
    ActiveRecord::Base.establish_connection
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDISTOGO_URL"], namespace: :resque }
end