# Email proper configuration for production.rb:


```
  config.action_mailer.default_url_options = { host: ENV["MAIL_DEFAULT_URL"]}
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
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
```