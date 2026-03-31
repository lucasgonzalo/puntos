class BranchAlertsController < ApplicationController
  before_action :set_alert, only: %i[ show  ]
  def index
    @branch = @current_branch
    if @branch
      @alerts = BranchAlert.where(branch: @branch)
    else
      @alerts = BranchAlert.none
    end
  end

  def filter_alerts
    branch = @current_branch
    if params[:alert_status].blank?
      @alerts = BranchAlert.where(branch: branch)
    else
      @alerts = BranchAlert.where(branch: branch).where(status: params[:alert_status])
    end
    respond_to do |format|
      format.js { render 'filter_alerts', locals: { alerts: @alerts } }
    end
  end

  def show
    branch_alert = BranchAlert.find_by_id(params[:id])
    if  branch_alert.status_not_read?
      branch_alert.status = :read
      if branch_alert.save!
        flash[:notice] = "Alerta marcada como leída"
      else
        flas[:alert] = "La alerta no fue marcada leída debido a : #{branch_alert.errors.full_messages}"
      end
    end
  end


  def mark_as_read
    branch_alert = BranchAlert.find_by_id(params[:id])
    branch_alert.status = :read

    respond_to do |format|
      if branch_alert.save
        format.html { redirect_to branch_alerts_path, notice: 'La alerta fue Leída' }
        format.json { head :no_content }
      else
        format.html { redirect_to branch_alerts_path, alert: 'La alerta no fue marcada leida con éxito' }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_alert
    @alert = BranchAlert.find(params[:id])
  end

end
