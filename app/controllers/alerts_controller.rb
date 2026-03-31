class AlertsController < ApplicationController
  before_action :set_alert, only: %i[ show edit update destroy ]

  # GET /alerts or /alerts.json
  def index
    if @current_company
      # @alerts = current_user.alerts(@current_company)
      # @alerts = current_user.alerts(@current_company).where(status: :not_read)
      @alerts = Alert.where(company: @current_company)
    else
      @alerts = Alert.none
    end
  end

  # GET /alerts/1 or /alerts/1.json
  def show
  end

  # GET /alerts/new
  def new
    @alert = Alert.new
  end

  # GET /alerts/1/edit
  def edit
  end

  # POST /alerts or /alerts.json
  def create
    @alert = Alert.new(alert_params)

    respond_to do |format|
      if @alert.save
        format.html { redirect_to @alert, notice: 'Alerta creada correctamente.' }
        format.json { render :show, status: :created, location: @alert }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /alerts/1 or /alerts/1.json
  def update
    respond_to do |format|
      if @alert.update(alert_params)
        format.html { redirect_to @alert, notice: 'Alerta actualizada correctamente.' }
        format.json { render :show, status: :ok, location: @alert }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alerts/1 or /alerts/1.json
  def destroy
    @alert.destroy
    respond_to do |format|
      format.html { redirect_to alerts_url, notice: 'Alerta eliminada correctamente.' }
      format.json { head :no_content }
    end
  end

  def mark_as_read
    alert = Alert.find_by_id(params[:id])
    alert.status = :read
    alert.save!

    respond_to do |format|
      format.html { redirect_to alerts_path(), notice: 'La alerta fue Leída' }
      format.json { head :no_content }
    end
  end


  def filter_alerts

    if params[:alert_status].blank?
      @alerts = current_user.alerts(@current_company)
    else
      @alerts = current_user.alerts(@current_company).where(status: params[:alert_status])
    end

    respond_to do |format|
      format.js {
        render 'filter_alerts', locals: { alerts: @alerts }
      }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_alert
    @alert = Alert.find(params[:id])
    respond_to do |format|
      format.html { redirect_to alerts_url }
      format.json { head :no_content }
    end
  end

  # Only allow a list of trusted parameters through.
  def alert_params
    params.require(:alert).permit(:company_id, :category, :status, :content, :link)
  end
end
