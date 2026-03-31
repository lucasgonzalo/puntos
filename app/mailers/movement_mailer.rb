class MovementMailer < ApplicationMailer
  include ActionView::Helpers::NumberHelper

  after_action :log_email_delivery, only: :send_mail_movement

  def send_mail_movement(movement)
    Rails.logger.debug "### Enviando email de movimiento para Movement ID: #{movement.id}"
    @movement = movement
    @company = @movement.branch.company
    @branch = @movement.branch
    @main_email = @movement.customer.person.person_emails.find_by(main: true)

    # Me fijo si el cliente tiene mail principal y el comercio tiene mail
    puts "---------------- Estos son los datos del email ----------------"
    puts @branch.email
    puts @main_email.email
    puts "---------------- Estos son los datos del email ----------------"

    # raise StandardError, "No se envió el email porque falta la configuracion del email de la sucursal."if @branch.email.blank?

    if @main_email.email.blank?
      Rails.logger.debug "### No se envió el email porque falta el email principal del cliente."
      raise StandardError, "No se envió el email porque falta el email principal del cliente."
    end

    if @main_email.validated_at.nil?
      Rails.logger.debug "### No se envió el email porque el email del cliente no está validado."
      raise StandardError, "No se envió el email porque el email del cliente no está validado, email: #{@main_email.email}."
    end

    puts "--------------Estos son los datos de configuración-------------- "
    Rails.logger.info "### Configuracion de SMTP: #{MailerSettingsService.smtp_settings.inspect}"

    # Configurar imagen para mostrar visualmente en el email
    if @branch.email_image_branch.attached?
      begin
        default_url_options = Rails.application.config.action_mailer.default_url_options
        @url_email_image_top = Rails.application.routes.url_helpers.rails_blob_url(
          @branch.email_image_branch, 
          host: default_url_options[:host], 
          protocol: default_url_options[:protocol] || 'http'
        )
        Rails.logger.info "### URL de imagen configurada: #{@url_email_image_top}, Pero ten en cuenta que se descarga internamente y se agrega inline con ApplicationMailer y nombre logo.png"
        # attachment hereda de application_mailer, es una forma de adjuntar la imagen en el email
        attachments.inline['logo.png'] = @branch.email_image_branch.download
      rescue => e
        Rails.logger.error "### Error al generar la URL de la imagen: #{e.message}"
        @url_email_image_top = nil
      end
    else
      Rails.logger.debug "### No hay imagen de email configurada para la sucursal #{@branch.name}"
      @url_email_image_top = nil
    end

    @email = @main_email.email
    @discount_value = @movement.amount*(@movement.discount/100)
    @monthly_saving = @movement.customer.get_monthly_saving(@company)
    @points_available = @movement.customer.points_balance_amount(@company)

    @msg = ''

    case @movement.movement_type

      #--------------------VENTA-------------------
      when 'sale'
        @msg = @movement.mail_description(@movement.points, @points_available)
        @msg += " <br>Tu descuento fue de <b> #{number_to_currency(@discount_value)} </b>.".html_safe if @discount_value != 0
        @msg += "<br>Llevas ahorrando <b>#{number_to_currency(@monthly_saving)}</b> el último mes.".html_safe if @monthly_saving > 0

      #--------------------CANJE PRODUCTO-------------------
      when 'product_exchange'
        @msg = "Has realizado un CANJE de <b>#{number_with_delimiter(@movement.points.to_i, delimiter: '.')}</b> en #{@company.name}.
                Te quedan <b>#{number_with_delimiter(@points_available.to_i, delimiter: '.')}</b> puntos disponibles para canjearlos cuando quieras."
                
      #--------------------CANJE-------------------
      when 'exchange'
        @msg = "Has realizado un CANJE de <b>#{number_with_delimiter(@movement.points.to_i, delimiter: '.')}</b> en #{@company.name}.
                Te quedan <b>#{number_with_delimiter(@points_available.to_i, delimiter: '.')}</b> puntos disponibles para canjearlos cuando quieras."

      #--------------------ANULACIÓN DE VENTA-------------------
      when 'sale_annulment'
        @msg = "Has realizado una ANULACIÓN DE VENTA  en #{@company.name}.
              Tenés <b>#{number_with_delimiter(@points_available.to_i, delimiter: '.')}</b> puntos disponibles para canjearlos cuando quieras."

      #--------------------ANULACIÓN DE CANJE-------------------
      else
        @msg =  "Has realizado una ANULACIÓN DE CANJE en #{@company.name}.
                Tenés <b>#{number_with_delimiter(@points_available.to_i, delimiter: '.')}</b> puntos disponibles."
        @msg += "Llevas ahorrando <b>#{number_to_currency(@monthly_saving)}</b> el último mes." if @monthly_saving > 0
    end

    # Example in the mailer or controller
    # base_url = ENV.fetch("MAIL_DEFAULT_URL")
    base_url = "https://app.puntosaltoque.com"
    options = Rails.application.config.action_mailer.default_url_options
    Rails.logger.debug "### options: #{options}"
    # base_url = "#{options[:protocol]}://#{options[:host]}"
    Rails.logger.debug "### base_url: #{base_url}"
    path = Rails.application.routes.url_helpers.current_account_exteneral_path(@movement.customer)
    @url = URI.join(base_url, path).to_s
    Rails.logger.debug "### URL generada para el email: #{@url}"

    if @branch.admits_product_exchange && @branch.get_related_catalog
      catalog_path = Rails.application.routes.url_helpers.showcase_catalogs_path(id: @branch.get_related_catalog.id)
      options = Rails.application.config.action_mailer.default_url_options
      # base_url_catalog = "#{options[:protocol]}://#{options[:host]}"
      @catalog_url = URI.join(base_url, catalog_path).to_s
    end

    from_name = "#{@branch.company.name} -#{@branch.name} "
    # from_email = 'notificaciones@puntosaltoque.com' ## Hardcoded email para evitar problemas de SPF/DKIM de envialosimple, por ahora
    from_email = ApplicationMailer.default_from_address

    mail(to: @email,
          from: %("#{from_name}" <#{from_email}>),
          reply_to: @branch.email.to_s,
          subject: 'Tu movimiento fue generado con éxito!',
          #  content_type: "text/html"
        ) 
    
  end

  private

   def log_email_delivery
    email_type = action_name
    user_info = params[:user] ? "User ID: #{params[:user][:id]}" : "No user"
    attachment_info = message.attachments.any? ? "with attachment(s): #{message.attachments.map(&:filename).join(", ")}" : "no attachments"
    
    Rails.logger.info "*** #### *** Email sent (#{email_type}): #{user_info}, Subject='#{message.subject}', To='#{message.to.join(", ")}', From='#{message.from.join(", ")}', Message-ID='#{message.message_id}', #{attachment_info}, at #{Time.current}"
  end

end
