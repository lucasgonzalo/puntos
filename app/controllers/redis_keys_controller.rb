require 'net/smtp'

class RedisKeysController < ApplicationController
  load_and_authorize_resource
  
  def index
    # @redis.flushall
  end

  def new
  end

  def new_task
  end


  def create_task
    errors = []
    key_redis_text = params[:key_redis_text].strip
    value_redis_text = params[:value_redis_text].strip
    value_redis_number = params[:value_redis_number].strip
    value_redis_date = params[:value_redis_date].strip

    begin
      if key_redis_text.include?("/") || key_redis_text.include?("\\")
        raise StandardError, "StandardError - Key contains invalid characters \/ or \\"
      end
      if value_redis_text.blank? && value_redis_number.blank? && value_redis_date.blank?
        raise StandardError, "StandardError - All values are empty"
      end
      if !value_redis_text.blank?
        @redis.set(key_redis_text, value_redis_text)
      end
      if !value_redis_number.blank?
        @redis.set(key_redis_text, value_redis_number)
      end
      if !value_redis_date.blank?
        @redis.set(key_redis_text, value_redis_date)
      end
    rescue Redis::BaseError => e
      # Handle the error here
      errors << e.message
    rescue StandardError => e
      # Handle the custom error here
      errors << e.message
    end

    respond_to do |format|
      if errors.any?
        format.html { redirect_to redis_keys_path, alert: "Key #{key_redis_text} error: #{errors.first}" }
      else
        format.html { redirect_to redis_keys_path, notice: "Key #{key_redis_text} updated successfully." }
      end
    end
  end

  def edit_task
    @key_redis_value = params[:key]
  end

  def update_task
    errors = []
    redis_key = params[:key].strip
    value_redis_text = params[:value_redis_text].strip
    value_redis_number = params[:value_redis_number].strip
    value_redis_date = params[:value_redis_date].strip
    
    begin
      if redis_key.include?("/") || redis_key.include?("\\")
        raise StandardError, "StandardError - Key contains invalid characters \/ or \\"
      end
      # Check if all values are blank
      if value_redis_text.blank? && value_redis_number.blank? && value_redis_date.blank?
        raise StandardError, "StandardError - All values are empty"
      end
      if !value_redis_text.blank?
        @redis.set(redis_key, value_redis_text)
      end
      if !value_redis_number.blank?
        @redis.set(redis_key, value_redis_number)
      end
      if !value_redis_date.blank?
        @redis.set(redis_key, value_redis_date)
      end
    rescue Redis::BaseError => e
      # Handle redis set error
      errors << e.message
    rescue StandardError => e
      # Handle custom error
      errors << e.message
    end

    respond_to do |format|
      if errors.any?
        format.html { redirect_to redis_keys_path, alert: "Key #{redis_key} error: #{errors.first}" }
      else
        format.html { redirect_to redis_keys_path, notice: "Key #{redis_key}, updated successfully." }
      end
    end
  end

  def destroy_task
    key_redis_text = params[:key]
    
    @redis.del(key_redis_text)
    respond_to do |format|
      if @redis.get(key_redis_text)
        format.html { redirect_to redis_keys_path, alert: "Redis #{key_redis_text} wasn't deleted." }
      else
        format.html { redirect_to redis_keys_path, notice: "Redis key deleted successfully." }
      end
    end
  end


  def test_email
    @test_email = params[:test_email].strip
    errors = []

    begin
      puts "----------------------Estos son los datos del mails que se manda"
      Rails.logger.info "Configuracion de SMTP: #{MailerSettingsService.smtp_settings.inspect}"
      TestMailer.send_mail(@test_email).deliver_now

      puts "Connected successfully"

    rescue Net::SMTPAuthenticationError => e
      errors << "Fallo de Autenticacion: #{e.message}"
    rescue Net::SMTPServerBusy => e
      errors << "Server esta ocupado: #{e.message}"
    rescue Net::SMTPSyntaxError => e
      errors << "Syntax error: #{e.message}"
    rescue Net::SMTPFatalError => e
      errors << "Fatal error: #{e.message}"
    rescue Net::SMTPUnknownError => e
      errors << "No se reconoce error: #{e.message}"
    rescue IOError => e
      errors << "IO error: #{e.message}"
    rescue Timeout::Error => e  # Cambio aquí
      errors << "Timeout error: #{e.message}"
    rescue StandardError => e
      errors << "General error: #{e.message}"
    end
    puts "-----------------Estos son los errores"
    puts errors.to_json

    respond_to do |format|
      if errors.any?
        format.html { redirect_to redis_keys_path, alert: "Surguieron errores al enviar el correo: #{errors.first}" }
      else
        format.html { redirect_to redis_keys_path, notice: "Se envió correctamente el correo." }
      end
    end

  end

  def re_send_movement_mail
    errors = []
    movement = Movement.find_by(id: params[:movement_id])
    customer = movement.customer if movement
    main_email = movement.customer.person.person_emails.find_by(main: true) if movement && customer
    begin
      raise StandardError, "No se encontró movimiento con id #{params[:movement_id]}" unless movement
      raise StandardError, "No se econtro cliente asociado al movimiento #{movement.id}" unless customer
      raise StandardError, "No se econtro email principal asociado al cliente #{customer.id}" unless main_email

      puts "###---------Prueba de Envio de mail a usuario con mail: #{main_email.email} ---------###"
      MovementMailer.with(user: @current_user).send_mail_movement(movement).deliver_now
      movement.update!(mail_delivered_at: Time.current)

    rescue Net::SMTPAuthenticationError => e
      errors << "Fallo de Autenticacion: #{e.message}"
    rescue Net::SMTPServerBusy => e
      errors << "Server esta ocupado: #{e.message}"
    rescue Net::SMTPSyntaxError => e
      errors << "Syntax error: #{e.message}"
    rescue Net::SMTPFatalError => e
      errors << "Fatal error: #{e.message}"
    rescue Net::SMTPUnknownError => e
      errors << "No se reconoce error: #{e.message}"
    rescue IOError => e
      errors << "IO error: #{e.message}"
    rescue Timeout::Error => e  # Cambio aquí
      errors << "Timeout error: #{e.message}"
    rescue StandardError => e
      errors << "General error: #{e.message}"
    end

    logger.debug "###--------Estos son los errores: #{errors.to_json}"

    respond_to do |format|
      if errors.any?
        format.html { redirect_to redis_keys_path, alert: "Surguieron errores al enviar el correo: #{errors.first}" }
      else
        format.html { redirect_to redis_keys_path, notice: "Se envió correctamente el correo al mail #{main_email.email}" }
      end
    end
  end

  def import_keys
    respond_to do |format|
      if params[:file].present?
        result = process_file_import(params[:file])
        if result[:type] == :error
          format.html { redirect_to redis_keys_path, alert: result[:message] }
        else
          format.html { redirect_to redis_keys_path, notice: result[:message] }
        end
      else
        format.html { redirect_to redis_keys_path, alert: "Por favor seleccione un archivo para importar." }
      end
    end
  end


  def clear_tmp_pdfs
    folder = Rails.root.join('tmp', 'pdfs')
    Dir.glob(folder.join('*.pdf')).each { |file| File.delete(file) if File.exist?(file) }
    Rails.logger.info "Manually cleared all PDFs from tmp/pdfs"
    redirect_to redis_keys_path, notice: "All temporary PDFs have been deleted."
  end

  private

  def process_file_import(file)
    begin
      xlsx = Roo::Spreadsheet.open(file.path, extension: :xlsx)
      sheet = xlsx.sheet(0) # Primera hoja

      headers = sheet.row(1).map { |cell| cell&.to_s&.downcase }
      unless headers[0] == 'clave' && headers[1] == 'valor'
        return { message: "Las primeras dos columnas deben ser 'clave' y 'valor' (insensible a mayúsculas).", type: :error }
      end

      redis = @redis
      overwritten_count = 0
      processed_count = 0

      # Procesar cada fila (saltar encabezado)
      sheet.each_row_streaming(offset: 1) do |row|
        clave = row[0]&.value&.to_s # Primera columna (clave)
        valor = row[1]&.value&.to_s # Segunda columna (valor)
        next if clave.blank?

        if redis.exists?(clave)
          overwritten_count += 1
        end
        processed_count += 1
        redis.set(clave, valor)
      end

      message = "Archivo importado exitosamente. #{processed_count} pares clave-valor añadidos a Redis."
      message += " #{overwritten_count} variables se sobreescribieron." if overwritten_count > 0

      { message: message, type: :success }
    rescue Roo::Error => e
      { message: "Formato de archivo inválido: #{e.message}", type: :error }
    rescue StandardError => e
      { message: "Error al importar el archivo: #{e.message}", type: :error }
    end
  end

end
