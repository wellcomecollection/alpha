Sidekiq.configure_server do |config|

  database_url = ENV['DATABASE_URL']
  if database_url
    ENV['DATABASE_URL'] = "#{database_url}?pool=#{ ENV['SIDEKIQ_CONCURRENCY'] || 25 }"
    ActiveRecord::Base.establish_connection
  end
end