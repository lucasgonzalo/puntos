namespace :email_settings_task do
  task ejecute_method: :environment do
    redis = Redis.new(host: ENV.fetch("REDIS_HOST", "redis"), db: Integer(ENV.fetch("REDIS_DB", 0)))
    redis.set('mailer_delivery_method', 'smtp')
    redis.set('smtp_address', 'c2611577.ferozo.com')
    redis.set('smtp_port', '465')
    redis.set('smtp_user_name', 'info@puntosaltoke.online')
    redis.set('smtp_password', 'Tok3Punt@s24')
    redis.set('smtp_authentication', 'login')
    redis.set('smtp_enable_starttls_auto', 'true')
    redis.set('smtp_ssl', 'true')
  end
end
