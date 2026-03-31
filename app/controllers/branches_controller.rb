class BranchesController < ApplicationController
  layout 'clean', only: [:qr_companies]
  skip_before_action :authenticate_user!, only: [:qr_companies]

  before_action :set_branch, only: %i[
    show edit update destroy
    edit_days_sleep show_days_sleep
    edit_admits_exchange show_admits_exchange
    edit_admits_product_exchange show_admits_product_exchange
    edit_alert_quantity show_alert_quantity
    edit_email show_email
    upload_image delete_image
    change_background_color
    change_text_color
  ]
  before_action :set_combos, only: %i[ new create edit update ]

  # GET /branches or /branches.json
  def index
    @branches = Branch.all
  end

  # GET /branches/1 or /branches/1.json
  def show; end

  # GET /branches/new
  def new
    @company = Company.find(params[:company])
    @branch = Branch.new
    @main_value = @company.branches.where(main: true).count.zero?
  end

  # GET /branches/1/edit
  def edit
    @company = @branch.company
    @main_value = @branch.main
  end

  # POST /branches or /branches.json
  def create
    error = false

    @branch = Branch.new(branch_params)
    error = true unless @branch.save

    @company = @branch.company
    unless error
      Array(1..7).each do |day|
        # params[:company][:conversion] = 1 if params[:company][:conversion].blank?
        branch_setting = @branch.branch_settings.new(
          day: day,
          conversion: !params[:branch][:conversion].blank? ? params[:branch][:conversion] : 0,
          discount: !params[:branch][:discount].blank? ? params[:branch][:discount] : 0
        )
        unless branch_setting.save
          @branch.errors[:base] << branch_setting.errors
          error = true
        end
      end
    end

    respond_to do |format|
      if !error
        format.html { redirect_to @company, notice: 'Sucursal creada correctamente.' }
        format.json { render :show, status: :created, location: @branch }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @branch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /branches/1 or /branches/1.json
  def update

    @company = @branch.company

    route_back =
    if !params[:branch][:days_sleep].blank?
      branch_show_days_sleep_path(branch_id: @branch.id)
    elsif !params[:branch][:alert_days].blank? || !params[:branch][:alert_qty_movements].blank? ||
        !params[:branch][:alert_amount].blank?
      branch_settings_path
    elsif !params[:branch][:email].blank?
      branch_show_email_path(branch_id: @branch.id)
    elsif !params[:branch][:admits_exchange].blank?
      branch_show_admits_exchange_path(branch_id: @branch.id)
    elsif !params[:branch][:admits_product_exchange].blank?
      branch_show_admits_product_exchange_path(branch_id: @branch.id)
    else
      @company
    end


    respond_to do |format|
      if @branch.update(branch_params)
        format.html { redirect_to route_back, notice: 'Sucursal actualizada correctamente.'}
        format.json { render :show, status: :ok, location: @branch }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @branch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /branches/1 or /branches/1.json
  def destroy
    company = @branch.company
    @branch.destroy

    respond_to do |format|
      format.html { redirect_to company, notice: 'Sucursal eliminada correctamente.'}
      format.json { head :no_content }
    end
  end

  def edit_days_sleep; end
  def show_days_sleep; end

  def edit_admits_exchange; end
  def show_admits_exchange; end

  def edit_admits_product_exchange; end
  def show_admits_product_exchange; end

  def edit_alert_quantity; end
  def show_alert_quantity; end
  def update_alert_quantity; end

  def edit_email; end
  def show_email; end



  def upload_image
    @current_branch.image_branch.attach(params[:image_branch])
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, notice: 'Imagen subida correctamente') }
      format.json { head :no_content }
    end
  end

  def delete_image
    @current_branch.image_branch.purge
    respond_to do |format|
      format.html { redirect_to branch_settings_path, notice: 'Imagen eliminada correctamente.' }
      format.json { head :no_content }
    end
  end

  def qr_companies
    @branch = Branch.find(params[:id])
    @url_qr_branch = "#{request.protocol}#{request.host_with_port}" + new_customer_external_path(token: @branch.token).to_s
    @qrcode = RQRCode::QRCode.new(@url_qr_company)
    @svg = @qrcode.as_svg(
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true,
      use_path: true
    )
  end

  def email_upload_image
    @current_branch.email_image_branch.attach(params[:email_image_branch])
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, notice: 'Imagen de email subida correctamente.') }
      format.json { head :no_content }
    end
  end

  def email_delete_image
    @current_branch.email_image_branch.purge
    respond_to do |format|
      format.html { redirect_to branch_settings_path, notice: 'Imagen de email eliminada correctamente.' }
      format.json { head :no_content }
    end
  end

  def change_background_color

    @branch.update(email_background_color: params[:background_color])

    respond_to do |format|
      if @branch.save
        format.html { redirect_to branch_settings_path, notice: 'El fondo del correo electrónico fue actualizado'}
      else
        format.html { redirect_to branch_settings_path, alert: 'EL fondo de correo electrónico no fue actualizado'}
      end
    end
  end

   def change_text_color
    @branch.update(email_text_color: params[:text_color])

    respond_to do |format|
      if @branch.save
        format.html { redirect_to branch_settings_path, notice: 'El color del texto del correo electrónico fue actualizado'}
      else
        format.html { redirect_to branch_settings_path, alert: 'EL color del texto del correo electrónico no fue actualizado'}
      end
    end
  end

  def today_settings
    branch = Branch.find(params[:id])
    render json: {
      discount: branch.today_discount,
      conversion: branch.today_conversion
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_branch
      @branch = Branch.find(params[:id] || params[:branch_id])
    end

    # Only allow a list of trusted parameters through.
    def branch_params
      params.require(:branch).permit(
        :company_id, :name, :address, :city_id, :geolocation_link, :main, :active,
        :days_sleep, :alert_days, :alert_qty_movements, :alert_amount, :email, :admits_exchange, :admits_product_exchange
      )
    end

    def set_combos
      @companies = Company.all.order(:name)
      @cities = City.all.order(:name)
    end


end
