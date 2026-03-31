class MailerSettingsService
  # Se utilizó para poder recuperar variables de redis
  # Se modifica para utilizar varaiables de entorno

  def self.delivery_method
    redis = Redis.new(host: ENV.fetch("REDIS_HOST", "redis"), db: Integer(ENV.fetch("REDIS_DB", 0)))
    redis.get('mailer_delivery_method')&.to_sym || :smtp
  end

  def self.default_url_options
    redis = Redis.new(host: ENV.fetch("REDIS_HOST", "redis"), db: Integer(ENV.fetch("REDIS_DB", 0)))
    enable_with_redis = redis.get('enable_mail_by_redis').blank? ? false : (redis.get('enable_mail_by_redis') == 'true')
    if enable_with_redis
      { host: redis.get('mail_default_url') || "app.puntosaltoque.com",
       from: redis.get('mail_default_from') || "notificaciones@puntosaltoque.com",
       protocol: 'https' }
    else
      { host: ENV["MAIL_DEFAULT_URL"] || "app.puntosaltoque.com",
       from: ENV["SMTP_DEFAULT_FROM"] || "notificaciones@puntosaltoque.com",
       protocol: 'https' }
    end
  end

  def self.smtp_settings
    redis = Redis.new(host: ENV.fetch("REDIS_HOST", "redis"), db: Integer(ENV.fetch("REDIS_DB", 0)))
    enable_with_redis = redis.get('enable_mail_by_redis').blank? ? false : (redis.get('enable_mail_by_redis') == 'true')
    if enable_with_redis
      {
        domain: redis.get('smtp_domain'),
        address: redis.get('smtp_address'),
        user_name: redis.get('smtp_user_name'),
        password: redis.get('smtp_password'),
        port: redis.get('smtp_port').to_i,
        authentication: redis.get('smtp_authentication')&.to_sym,
        enable_starttls_auto: redis.get('smtp_enable_starttls_auto')=='true',
        ssl: redis.get('smtp_ssl')=='true',
        tls: redis.get('smtp_tls')=='true',
        openssl_verify_mode:  redis.get('smtp_openssl_verify_mode'),
        open_timeout: 15,
        read_timeout: 30
      }
    else
      {
        address:              ENV["SMTP_ADDRESS"],
        user_name:            ENV["SMTP_USER_NAME"],
        password:             ENV["SMTP_PASSWORD"],
        port:                 ENV.fetch("SMTP_PORT", "465").to_i,
        authentication:       ENV.fetch("SMTP_AUTH", "login").to_sym,
        enable_starttls_auto: ENV.fetch("SMTP_STARTTLS","false") == "true",
        ssl:                  ENV.fetch("SMTP_SSL", "true") == "true",
        tls:                  ENV.fetch("SMTP_TLS", "true") == "true",
        openssl_verify_mode:  ENV.fetch("SMTP_OPENSSL_VERIFY_MODE", "none"),
        open_timeout:    15,
        read_timeout:    15
      }
    end
  end

end

