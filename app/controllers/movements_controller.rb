class MovementsController < ApplicationController
  before_action :check_company, except: %i[index filter_movements]
  before_action :set_movement, only: %i[show edit update destroy annulment ]

  # GET /movements or /movements.json
  def index
    # logged_admin solo funciona si se ingresa como administrador en la pagina de seleccion de comercio
    # no tiene en cuenta el attr admin_role 
    @movements = @logged_admin ? fetch_admin_movements : fetch_company_movements

    # filtro por fechas(1 mes de rango) para no sobrecargar el datatable
    @date_start = (Time.now.in_time_zone('America/Argentina/Buenos_Aires') - 1.month).beginning_of_day
    @date_end = Time.now.in_time_zone('America/Argentina/Buenos_Aires').end_of_day
    @movements = @movements.where(created_at: @date_start..@date_end)
    
    @cache_key = "movements_#{Movement.maximum(:updated_at)&.to_i}_#{@movements.count}"

  end

  # GET /movements/1 or /movements/1.json
  def show
    @accumulate_points = 0
    @exchange_points = 0
    @related_movement = nil
    @annulment_movement = nil

    #--------------------------------Venta----------------------------------
    if @movement.movement_type_sale?
      @accumulate_points = @movement.points
      previous_movement = Movement.find_by(id: (@movement.id - 1))
      if !previous_movement.blank? && @movement.total_import==previous_movement.total_import && previous_movement.movement_type_exchange?
        @related_movement = previous_movement
        @exchange_points = previous_movement.points
      end
    #--------------------------------Canje----------------------------------
    elsif @movement.movement_type_exchange?
      @exchange_points = @movement.points
      next_movement = Movement.find_by(id: (@movement.id + 1))
      if !next_movement.blank? && @movement.total_import==next_movement.total_import && next_movement.movement_type_sale?
        @related_movement = next_movement
        @accumulate_points = next_movement.points
      end

    elsif @movement.movement_type_product_exchange?
      @exchange_points = @movement.points
      
    elsif @movement.movement_type_group_load?
      @exchange_points = @movement.points

    #--------------------------------Anulación de Venta o Canje----------------------------------
    else
      @annulment_movement = Movement.find_by(id: @movement.movement_related_id)

      if @annulment_movement.movement_type_sale?
        @accumulate_points = @movement.points
        previous_movement = Movement.find_by(id: (@annulment_movement.id - 1))
        if !previous_movement.blank? && @annulment_movement.total_import==previous_movement.total_import && previous_movement.movement_type_exchange?
          @related_movement = previous_movement
          @exchange_points = previous_movement.points
        end
      else
        @exchange_points = @movement.points
        next_movement = Movement.find_by(id: (@annulment_movement.id + 1))
        if !next_movement.blank? && @annulment_movement.total_import==next_movement.total_import && next_movement.movement_type_sale?
          @related_movement = next_movement
          @accumulate_points = next_movement.points
        end
      end
    end
  end

  # GET /movements/new
  def new
    @movement = Movement.new
    @company = @current_company
    @branch = @current_branch
  end

  # GET /movements/1/edit
  def edit; end

  # POST /movements or /movements.json
  def create
    begin
      # Extraer y validar datos de los parametros
      movement_data = extract_common_data
      validate_common_data(movement_data)

      result = case movement_data[:movement_type]
                when 'sale'
                  process_sale_movement(movement_data)
                when 'exchange'
                  process_sale_exchange_movement(movement_data)
                when 'product_exchange'
                  process_product_exchange_movement(movement_data)
                else
                  raise StandardError, "Tipo de movimiento no válido: #{movement_data[:movement_type]}"
                end

      activate_customer_if_inactive(movement_data[:customer])

      respond_to_create_success(result[:email_error])

    rescue => e
      error_message = handle_error(e)
      respond_to_create_error(error_message)
    end
  end

  # PATCH/PUT /movements/1 or /movements/1.json
  def update
    result = {type: :success, message: 'Movimiento anulado exitosamente.'}
    begin
      raise StandardError, "No se puede anular un movimiento ya anulado." if @movement.annulled?

      if @movement.credit_points_movement?
        # Si se anula algo que me acreditaba puntos entonces chequea que tenga puntos para devolverlo.
         # recuerde que @movement es el movimiento original a anular, por lo  que si quiero anular un movimiento que me debita puntos(ej: exchange o canje) no necesito chequear si tengo puntos para devolver
        # pero si el movimiento original es de credito de puntos (ej: sale) debo chequear que el cliente tenga puntos suficientes para devolverlos
        raise StandardError, "No se puede anular el movimiento porque el cliente no tiene puntos suficientes, es posible que ya haya usado sus puntos para un canje." if @movement.points > @movement.customer.points_balance_amount(@movement.branch.company)
      end
      error = false

      @new_movement = @movement.movement_related.new(
        movement_type: params[:movement][:movement_type].to_sym,
        amount: @movement.amount,
        amount_discounted: @movement.amount_discounted,
        points: @movement.points,
        conversion: @movement.conversion,
        discount: @movement.discount,
        total_import: @movement.total_import,
        user: current_user
      )
      @new_movement.customer = Customer.find(params[:movement][:customer_id])
      @new_movement.branch = Branch.find(params[:movement][:branch_id])
      @new_movement.save!

      #----------- Cambiar el estado del movimiento a anulado---------------
      @movement.annulled = true
      @movement.save!
     
    rescue StandardError => e
      result =  { type: :error, message: 'Ha ocurrido un error: ' + e.message }
    end

    #----------- Envia mail de anulación---------------
     if result[:type] == :success
      begin
        MovementMailer.send_mail_movement(@new_movement).deliver
        @new_movement.update!(mail_delivered_at: Time.current)
      rescue StandardError => e
        Rails.logger.error "Error al enviar email de anulación: #{e.message}"
        result[:message] += 'Sin embargo  ' + e.message
      end
    end

    respond_to do |format|
      if result[:type] == :error
        format.html { redirect_to movements_path(), alert: result[:message] }
      else
        format.html { redirect_to movements_path(), notice: result[:message] }
      end
    end
  end


  # DELETE /movements/1 or /movements/1.json
  def destroy
    @movement.destroy

    respond_to do |format|
      format.html { redirect_to movements_url, notice: 'Movimiento eliminado exitosamente.'}
      format.json { head :no_content }
    end
  end

  # Para anulacion de canjes y de ventas
  def annulment
    case @movement.movement_type
    when 'sale'
      @type = :sale_annulment
    when 'exchange'
      @type = :exchange_annulment
    when 'product_exchange'
      @type = :product_exchange_annulment
    else
      flash[:alert] = 'Tipo de movimiento no válido para anulación.'
      redirect_to movements_path
      return 
      # raise StandardError, "Tipo de movimiento no válido para anulación."
    end
    @customer = @movement.customer
    @conversion = @movement.conversion
    @discount = @movement.discount
  end

  def filter_movements
    movements = @logged_admin ? fetch_admin_movements : fetch_company_movements
    #movements = @current_branch ? Movement.where(branch: @current_branch) : Movement.where(branch: @current_company.branches)

    unless movements.blank?
      # FILTRO DE TIPO DE MOVIMIENTO
      movements = movements.where(movement_type: params[:movement_type]) unless params[:movement_type].blank?

      # FILTRO DE PUNTOS
      movements = movements.where(points: params[:points]) unless params[:points].blank?

      # FILTRO DE CLIENTE
      unless params[:customer].blank?
        value = "%#{params[:customer].upcase}%"
        movements = movements.joins(customer: :person).where(
          'upper(people.first_name) LIKE ? OR upper(people.last_name) LIKE ?',
          value, value)
      end

      # FILTRO DE NUMERO DE DOCUMENTO
      unless params[:document_number].blank?
        movements = movements.joins(customer: :person).where(
          'people.document_number LIKE ?', "%#{params[:document_number]}%")
      end

      # FILTRO DESDE
      if !params[:date_start].blank? 
        date_start = Date.parse(params[:date_start]).in_time_zone('America/Argentina/Buenos_Aires').beginning_of_day
        movements = movements.where('movements.created_at >= ? ', date_start)
      end
      # FILTRO Hasta
      if !params[:date_end].blank?
        date_end = Date.parse(params[:date_end]).in_time_zone('America/Argentina/Buenos_Aires').end_of_day
        movements = movements.where(' movements.created_at <= ?', date_end)
      end
    end
    # @new_movements = @movements
    @movements = movements

    respond_to do |format|
      format.js
    end
  end

  def excel_movements
    movements_ids = params[:movements].to_s.split(',').map(&:to_i)
    @movements = Movement.where(id: movements_ids).includes(:user, customer: :person, branch: :company) unless params[:movements].blank?

    respond_to do |format|
      format.html
      format.xlsx { render xlsx: 'excel_movements', filename: "Excel_Movimientos_#{Time.now.in_time_zone('America/Argentina/Buenos_Aires').strftime('%d-%m-%Y_%H-%M')}.xlsx" }
    end
  end

  def new_movement_external
    render 'movements/new'
  end

  def catalog_content
    @catalog = Catalog.find(params[:catalog_id])
    @products = @catalog.products.where(active: true) # Adjust query as needed
    render partial: "movements/catalog_content", locals: {catalog: @catalog, products: @products }
  end

  def product_exchange_form
    @customer = Customer.find(params[:customer_id])
    @branch = Branch.find(params[:branch_id])
    # @branch = current_branch || @customer.company.branches.first
    @company = @customer.company
    # @current_group = @customer.group
    render partial: 'product_exchange_form', locals: { customer: @customer, branch: @branch }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_movement
    @movement = Movement.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  # Updated to include selected_products_array for multi-product exchange functionality
  def movement_params
    params.require(:movement).permit(:customer_id, :branch_id, :movement_type, :amount, :points,:amount_discounted, :selected_products_array).except(:id, :amount_with_discount)
  end

  def check_company
    redirect_to select_company_url unless @current_company
  end

  #------------------------------verificamos tema puntos------------------------------
  def validate_points_and_settings(exchange_points, total_points, conversion, discount)
    Rails.logger.debug "### Validating points: exchange_points=#{exchange_points}, total_points=#{total_points}"
    if exchange_points > total_points
      raise StandardError, "La cantidad de puntos a canjear (#{exchange_points}) supera la cantidad de puntos disponibles (#{total_points})"
    elsif conversion.blank? || discount.blank?
      raise StandardError, 'No se cuenta con conversion y descuento configurados para realizar el movimiento, por favor verifique la configuración de la sucursal.'
    end
  end

  #------------------------------CREAMOS SEGUN TIPO DE MOVIMIENTO------------------------------
  def create_movement_type(movement_type, customer, conversion, discount)
    case movement_type
    when :product_exchange
      # Updated to handle multi-product selection array with quantities
      # Array structure: [{product_id: 45, quantity: 2}, {product_id: 47, quantity: 1}]
      selected_products = JSON.parse(params[:movement][:selected_products_array] ||'[]')
      raise StandardError, "No se encontraron productos seleccionados, intente nuevamente." if selected_products.empty?

      description_result = generate_product_exchange_description(selected_products)
      description = description_result[:description]
      points = description_result[:total_points]
    when :sale
      description = ''
      points = params[:movement][:points].presence || 0
    when :exchange
      description = ''
      points = params[:movement][:exchange_points]
    else
      raise StandardError, "No se ingresó el tipo de movimiento correctamente, intente nuevamente."
    end
    movement = Movement.new(
      user: current_user,
      movement_type: movement_type,
      amount: params[:movement][:amount],
      amount_discounted: params[:movement][:amount_discounted],
      points: points,
      conversion: conversion,
      discount: discount,
      total_import: params[:movement][:total_import],
      description: description
    )
    movement.customer = customer
    movement.branch = Branch.find(params[:movement][:branch_id])

    if movement.save
      return movement
    else
      return nil
      logger.debug "### Error al crear el movimiento: #{movement.errors.full_messages.join(', ')}"
      # raise StandardError, "El movimiento de #{movement_type} no se creó correctamente"
    end
  end

  #------------------------------ENVIAR MAIL DESPUES DE CREAR------------------------------
  def send_mail_after_creating(movement, conversion, discount)
    begin
      MovementMailer.with(user: @current_user).send_mail_movement(movement).deliver_now
      movement.update!(mail_delivered_at: Time.current)
      false # No hubo error al enviar el correo
    rescue StandardError => e
      Rails.logger.error "Error al enviar el correo para el movimiento #{movement.id}: #{e.message}"
      true # Indica que hubo un error al enviar el correo
    end
  end

  #------------------------------activamos cliente------------------------------
  def activate_customer_if_inactive(customer)
    if customer.status != :active
      customer.update!(status: :active)
    end
  end

  def fetch_admin_movements
    # puts "### Admin Movements ###"
    scope = @current_group ? Movement.where(group: @current_group) : Movement.all
    @current_group&.account_type_group? ? scope : scope.where.not(movement_type: :group_load)
    scope.includes(:customer, :group, {branch: :company }, :person, :user).order(created_at: :desc)
  end

  def fetch_company_movements
    #  puts "### fetch_company_movements ### "
    # El or se utiliza para movimientos que no pertencen a una sucursal en particular, son del otro tipo de movimientos relacionados a la compañia en general
    if @current_branch
      if current_user.role_on_branch?(:basic_role, @current_branch)
         # MODIFICACIÓN: Filtrar por día actual, usuario actual, branch actual, clientes activos
        scope = Movement.where(
          branch: @current_branch,
          user: current_user,
          customer: { status: :active },
          created_at: Time.zone.now.in_time_zone('America/Argentina/Buenos_Aires').beginning_of_day..Time.zone.now.in_time_zone('America/Argentina/Buenos_Aires').end_of_day
        )
      else
        scope = Movement.where(branch: @current_branch)
              .or(Movement.where(group: @current_company.active_group, branch: nil))
      end
    else
      scope = Movement.where(branch: @current_company.branches)
              .or(Movement.where(group: @current_company.active_group, branch: nil))
    end
    scope.includes(:customer, :group, {branch: :company }, :person, :user).order(created_at: :desc)
  end

  def extract_common_data
    raise StandardError, "Debe tener seleccionada una sucursal para realizar este movimiento." if params[:movement][:branch_id].blank?
    raise StandardError, "Ocurrio un error al recuperar el cliente, intente nuevamente." if params[:movement][:customer_id].blank?
    {
      movement_type: params[:movement][:movement_type],
      customer: Customer.find(params[:movement][:customer_id]),
      branch: Branch.find(params[:movement][:branch_id]),
      add_points: params[:movement][:points].to_i,
      exchange_points: params[:movement][:exchange_points].to_i,
      total_import: params[:movement][:total_import].to_f
    }
  end

  # Validar datos comunes
  def validate_common_data(data)
    branch_setting = BranchSetting.find_by(branch: data[:branch], day: Time.now.strftime('%u'))
    data[:conversion] = data[:customer].category_is_agente? ? branch_setting.conversion_agent : branch_setting.conversion
    data[:discount] = branch_setting.discount

    available_points = data[:customer].points_balance_amount(data[:customer].company).to_i
    total_points = data[:add_points] + available_points

    validate_points_and_settings(data[:exchange_points], total_points, data[:conversion], data[:discount])
  end

  # Procesar movimiento de venta simple
  def process_sale_movement(data)
    movement = create_movement_type(:sale, data[:customer], data[:conversion], data[:discount])
    email_error = send_mail_after_creating(movement, data[:conversion], data[:discount]) if movement

    { email_error: email_error, movements: [movement].compact }
  end

  # Procesar movimiento de venta con canje
  def process_sale_exchange_movement(data)
    movements = []
    email_error = false

    # Crear movimiento de canje si hay puntos a canjear
    if data[:exchange_points].positive?
      exchange_movement = create_movement_type(:exchange, data[:customer], data[:conversion], data[:discount])
      movements << exchange_movement
      email_error = send_mail_after_creating(exchange_movement, data[:conversion], data[:discount]) if exchange_movement
    end

    # Crear movimiento de venta
    sale_movement = create_movement_type(:sale, data[:customer], data[:conversion], data[:discount])
    movements << sale_movement
    email_error ||= send_mail_after_creating(sale_movement, data[:conversion], data[:discount]) if sale_movement

    { email_error: email_error, movements: movements.compact }
  end

  # Procesar movimiento de canje de producto
  def process_product_exchange_movement(data)
    selected_products = JSON.parse(params[:movement][:selected_products_array] || '[]')
    multi_product_points = 0
    selected_products.each do |item|
        product = Product.find_by(id: item['product_id'])
        raise StandardError, "No se encontró el producto seleccionado, intente nuevamente." unless product
        multi_product_points += product.points * (item['quantity'] || 1)
      end

    available_points = data[:customer].points_balance_amount(data[:customer].company).to_i
    total_points = data[:add_points] + available_points
    validate_points_and_settings(multi_product_points, total_points, data[:conversion], data[:discount])

    movement = create_movement_type(:product_exchange, data[:customer], data[:conversion], data[:discount])
    email_error = send_mail_after_creating(movement, data[:conversion], data[:discount]) if movement

    { email_error: email_error, movements: [movement].compact }
  end

  # Responder con éxito
  def respond_to_create_success(email_error)
    respond_to do |format|
      notice_message = "Movimiento creado exitosamente."
      notice_message += " Sin embargo, no se pudo enviar el correo al cliente." if email_error
      format.html { redirect_to new_movement_path, notice: notice_message }
    end
  end

  # Responder con error
  def respond_to_create_error(error_message)
    respond_to do |format|
      format.html { redirect_to new_movement_path, alert: error_message }
    end
  end

  # Manejar errores - devuelve mensaje de error
  def handle_error(error)
    error_message = case error
                    when ActiveRecord::RecordNotFound
                      'Registro no encontrado: ' + error.message
                    else
                      'Ha ocurrido un error: ' + error.message
                    end
    puts "Error: #{error}"
    error_message
  end

  def generate_product_exchange_description(selected_products)
    product_details = []
    total_points = 0

    selected_products.each do |item|
      product = Product.find_by(id: item['product_id'])
      if product
        quantity = item['quantity'] || 1
        subtotal = product.points * quantity
        total_points += subtotal
        product_details << "{producto: #{product.name}, puntos: #{product.points}, cantidad: #{quantity}, precio: #{product.price || 0 }}"
      end
    end

    raise StandardError, "No se encontraron productos válidos, intente nuevamente." if product_details.empty?

    # description = "#{product_details.join(', ')}, Total Puntos: #{total_points}"
    description = product_details.join(', ')
    { description: description, total_points: total_points }
  end

end
