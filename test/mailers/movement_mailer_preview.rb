class MovementMailerPreview < ActionMailer::Preview
  def movement_notification(movement)
    # Preview emails at http://localhost:3000/rails/mailers/movement_mailer/movement_notification
    @movement = movement
    mail(to: @movement.user.email, subject: 'New Movement Notification')
  end

  def send_mail_movement(movement, conversion,discount)
    # Preview emails at http://localhost:3000/rails/mailers/movement_mailer/send_mail_movement
    @movement = movement
    mail(to: @movement.user.email, subject: 'Movement Details')
  end
end