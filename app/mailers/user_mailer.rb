class UserMailer < ApplicationMailer
  after_action :log_email_delivery

   def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

    private

  def log_email_delivery
    email_type = action_name
    user_info = @user ? "User ID: #{@user.id}" : "No user"
    attachment_info = message.attachments.any? ? "with attachment(s): #{message.attachments.map(&:filename).join(", ")}" : "no attachments"
    
    Rails.logger.info "## ** ## Email sent (#{email_type}): #{user_info}, Subject='#{message.subject}', To='#{message.to.join(", ")}', From='#{message.from.join(", ")}', Message-ID='#{message.message_id}', #{attachment_info}, at #{Time.current}"
  end

end