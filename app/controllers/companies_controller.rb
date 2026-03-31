class CompaniesController < ApplicationController
  layout 'clean', only: [:qr_companies]
  skip_before_action :authenticate_user!, only: [:qr_companies]

  before_action :set_company, only: %i[
    show edit update destroy
    edit_days_sleep show_days_sleep
    edit_alert_quantity show_alert_quantity
    edit_email show_email
    all_qr_company
  ]
  before_action :set_combos, only: %i[new create edit update]

  require 'prawn/qrcode'
  require 'prawn/measurement_extensions'



  # GET /companies or /companies.json
  def index
    @companies = @current_group ? Company.from_group(@current_group) : Company.all
  end

  # GET /companies/1 or /companies/1.json
  def show
    @branches = @company.branches.main_ordered
    @customers = @company.customers.includes(:person, :movements)
    @movements = @company.movements.includes(customer: :person, branch: :company)
  end

  # GET /companies/new
  def new
    @company = Company.new
    @users = User.all
    @groups = Group.all
  end

  # GET /companies/1/edit
  def edit
    @groups = Group.all
  end

  # POST /companies or /com
  def create
    error = false
    @company = Company.new(company_params)
    error = true unless @company.save

    @user = User.find(params[:company][:user_id])
    @user.company_owner_role = true
    error = true unless @user.save


    unless error
      Array(1..7).each do |day|
        # params[:company][:conversion] = 1 if params[:company][:conversion].blank?
        company_setting = @company.company_settings.new(
          day: day,
          conversion: !params[:company][:conversion].blank? ? params[:company][:conversion] : 0,
          discount: !params[:company][:discount].blank? ? params[:company][:discount] : 0
        )
        unless company_setting.save
          @company.errors[:base] << company_setting.errors
          error = true
        end
      end

    end

    if !params[:company][:group_id].blank?
      group = Group.find(params[:company][:group_id])
      @company.company_groups.build(group: group)
      error = true unless @company.save!
    end

    respond_to do |format|
      if !error
        format.html { redirect_to company_url(@company), notice: 'Comercio creado correctamente' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    days_sleep = params[:company][:days_sleep]
    alert_days = params[:company][:alert_days]
    alert_qty_movements = params[:company][:alert_qty_movements]
    alert_amount = params[:company][:alert_amount]

    email = params[:company][:email]

    route_back =
    if !days_sleep.blank?
      show_days_sleep_path
    elsif !alert_days.blank? || !alert_qty_movements.blank? || !alert_amount.blank?
      company_settings_url
    elsif !email.blank?
      show_email_path
    else
      @company
    end

    # Hablado con Ema: se manejara con estructura muchos/muchos en BD pero en la logica es a 1
    if !params[:company][:group_id].blank?
      group = Group.find(params[:company][:group_id])

      @company.company_groups.destroy_all

      @company.company_groups.build(group: group)
      error = true unless @company.save!
    end

    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to route_back, notice: 'Comercio Actualizado correctamente' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy

    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Comercio eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  def qr_companies
    @company = Company.find(params[:id])
    @url_qr_company = "#{request.protocol}#{request.host_with_port}" + new_customer_external_path(token: @company.token).to_s
    @qrcode = RQRCode::QRCode.new(@url_qr_company)
    @svg = @qrcode.as_svg(
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true,
      use_path: true
    )
    # Esto es para descargar la imagen
    # send_data @qrcode.as_png(size: 500), type: 'image/png', disposition: 'attachment'
  end

  def upload_image_company
    @current_company.image_company.attach(params[:image_company])
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, notice: 'Imagen subida correctamente') }
      format.json { head :no_content }
    end
  end

  def delete_image_company
    @current_company.image_company.purge
    respond_to do |format|
      format.html { redirect_to company_settings_url, notice: 'Imagen eliminada correctamente.' }
      format.json { head :no_content }
    end
  end

  def edit_days_sleep; end
  def show_days_sleep; end

  def edit_alert_quantity; end
  def show_alert_quantity; end
  def update_alert_quantity; end

  def edit_email; end
  def show_email; end


  def all_qr_company

    @company = Company.find(params[:id])

    #-----------------------------------QR PARA REGISTRAR CLIENTES AL COMERCIO----------------------------------------
    @url_qr_company = "#{request.base_url}" + new_customer_external_path(token: @company.token).to_s
    @qrcode = RQRCode::QRCode.new(@url_qr_company)
    @qrcode_png = @qrcode.as_png(
      module_size: 6,
      standalone: true,
      use_path: true
    )

    #-----------------------------------QR PARA CONSULTAR SALDOS----------------------------------------
    @url_query_customer = "#{request.protocol}#{request.host_with_port}" + query_customer_path(token: @company.token).to_s
    @qrcode_query_customer = RQRCode::QRCode.new(@url_query_customer)
    @qrcode_png_query_customer = @qrcode_query_customer.as_png(
      module_size: 6,
      standalone: true,
      use_path: true
    )


    #-----------------------------------QR PARA CARGAR MOVIMIENTOS----------------------------------------
    @url_new_movement = "#{request.protocol}#{request.host_with_port}" + new_movement_external_qr_branches_path.to_s
    @qrcode_new_movement = RQRCode::QRCode.new(@url_new_movement)
    @qrcode_png_new_movement = @qrcode_new_movement.as_png(
      module_size: 6,
      standalone: true,
      use_path: true
    )

  end


  def generate_qr_pdf
    @company = Company.find(params[:company_id])
    @url_qr_company = params[:url]

    # @qr_code = RQRCode::QRCode.new(@url_qr_company) # URL para el código QR
    @qr_code = RQRCode::QRCode.new(@url_qr_company)
    @qr_png = @qr_code.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 500,
    )
    # Prawn::Document::new do
    #   # Renders a QR Code at he cursor position using a dot (module) size of 2.8/72 in (roughly 1 mm).
    #   render_qr_code(@qr_code, dot: 1.2, align: :left)
    #   render_file("qr3.pdf")
    # end


    name = params[:name] +".pdf"



    respond_to do |format|
      format.html
      format.pdf do
        pdf = GenerateQrPdf.new(@url_qr_company, @company, @qr_png)
        send_data pdf.render,
          filename: name,
          type: 'aplication/pdf',
          disposition: "attachment"
      end
    end

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def company_params
    params.require(:company).permit(:group_id, :name, :user_id, :active, :observation, :days_sleep, :alert_days, :alert_qty_movements, :alert_amount, :email, :image_company)
  end

  def set_combos
    @users = User.where(company_owner_role: true).order(:last_name)
  end


end
