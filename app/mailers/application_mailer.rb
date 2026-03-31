class ApplicationMailer < ActionMailer::Base
  after_action :log_email_delivery
  # default from: ENV.fetch("SMTP_DEFAULT_FROM")
  default from: Rails.application.config.action_mailer.default_url_options[:from]
  # default from: "notificaciones@puntosaltoque.com" # this inherits to the other mailers, but can be overwritten in each mailer if needed
  layout "mailer"

  def self.default_from_address
    #return "notificaciones@puntosaltoque.com"
    # return ENV.fetch("SMTP_DEFAULT_FROM")
    return Rails.application.config.action_mailer.default_url_options[:from]
  end

  def log_email_delivery
    email_type = action_name
    user_info = @user ? "User ID: #{@user.id}" : "No user"
    attachment_info = message.attachments.any? ? "with attachment(s): #{message.attachments.map(&:filename).join(", ")}" : "no attachments"
    
    Rails.logger.info "*** #### *** Email sent (#{email_type}): #{user_info}, Subject='#{message.subject}', To='#{message.to.join(", ")}', From='#{message.from.join(", ")}', Message-ID='#{message.message_id}', #{attachment_info}, at #{Time.current}"
  end
end
