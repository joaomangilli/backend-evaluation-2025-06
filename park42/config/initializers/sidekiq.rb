redis_host = ENV.fetch("REDIS_HOST", "127.0.0.1")
redis_port = ENV.fetch("REDIS_PORT", "6379")
redis_url  = ENV.fetch("REDIS_URL", "redis://#{redis_host}:#{redis_port}/0")

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
