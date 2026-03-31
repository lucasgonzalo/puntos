class BranchSettingsController < ApplicationController
  before_action :set_branch_setting, only: %i[show edit update destroy ]

  def index
    @branch = @current_branch
    @url_query_customer = "#{request.protocol}#{request.host_with_port}" + query_customer_qr_branches_path(token: @branch.token).to_s
  end

  def show; end

  def new
    @branch_setting = BranchSetting.new
  end

  def edit; end

  def create
    @branch_setting = BranchSetting.new(branch_setting_params)

    respond_to do |format|
      if @branch_setting.save
        format.html { redirect_to @branch_setting, notice: 'Configuración creada correctamente.' }
        format.json { render :show, status: :created, location: @branch_setting }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @branch_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @branch_setting.update(branch_setting_params)
        format.html { redirect_to @branch_setting, notice: 'Configuración actualizada correctamente.' }
        format.json { render :show, status: :ok, location: @branch_setting }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @branch_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_branch_days_sleep
    @branch = Branch.find(params[:id])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_branch_setting
    @branch_setting = BranchSetting.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def branch_setting_params
    params.require(:branch_setting).permit(:day, :branch_id, :conversion, :discount, :admits_exchange)
  end
end
