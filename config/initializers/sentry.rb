# frozen_string_literal: true

Sentry.init do |config|
  next if ENV['IS_LOCALHOST'] == 'true'
  config.dsn = 'https://ca530bab9b2035696851f615ad44fb2e@o4509357096501248.ingest.us.sentry.io/4509372552904704'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 1.0
end

# Sentry.init do |config|
#   config.dsn = 'https://ca530bab9b2035696851f615ad44fb2e@o4509357096501248.ingest.us.sentry.io/4509372552904704'
#   config.breadcrumbs_logger = [:active_support_logger, :http_logger]

#   # Add data like request headers and IP for users,
#   # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
#   config.send_default_pii = true

#    # Enable sending logs to Sentry
#   config.enable_logs = true
#   # Patch Ruby logger to forward logs
#   config.enabled_patches = [:logger]
# end
