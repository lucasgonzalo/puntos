class TestMailer < ApplicationMailer
  layout "mailer"
  def send_mail(test_email)
    smtp_config = Rails.application.config.action_mailer.smtp_settings
    delivery_method = Rails.application.config.action_mailer.delivery_method
    
    # Mask password for security in the display
    masked_config = smtp_config.dup
    masked_config[:password] = "***MASKED***" if masked_config[:password]
    
    mail(
      from: "Puntos al Toque <#{ApplicationMailer.default_from_address}>",
      to: test_email,
      subject: 'Test de Puntos!',
      body: <<~BODY
        Hola Tester
        
        Configuracion de SMTP utilizado:
        Delivery Method: #{delivery_method}
        #{masked_config.inspect}
      BODY
    )
  end
end
