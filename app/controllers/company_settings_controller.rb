class CompanySettingsController < ApplicationController
  before_action :set_company_setting, only: %i[ show edit update destroy ]

  # GET /company_settings or /company_settings.json
  def index
    @company = @current_company
    @url_query_customer = "#{request.protocol}#{request.host_with_port}" + query_customer_path(token: @company.token).to_s
  end

  # GET /company_settings/1 or /company_settings/1.json
  def show; end

  # GET /company_settings/new
  def new
    @company_setting = CompanySetting.new
  end

  # GET /company_settings/1/edit
  def edit; end

  # POST /company_settings or /company_settings.json
  def create
    @company_setting = CompanySetting.new(company_setting_params)

    respond_to do |format|
      if @company_setting.save
        format.html { redirect_to @company_setting, notice: 'Configuración creada correctamente.' }
        format.json { render :show, status: :created, location: @company_setting }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /company_settings/1 or /company_settings/1.json
  def update
    respond_to do |format|
      if @company_setting.update(company_setting_params)
        format.html { redirect_to @company_setting, notice: 'Configuración actualizada correctamente.' }
        format.json { render :show, status: :ok, location: @company_setting }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_company_days_sleep
    @company = Company.find(params[:id])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company_setting
    @company_setting = CompanySetting.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def company_setting_params
    params.require(:company_setting).permit(:day, :company_id, :conversion, :discount)
  end
end
