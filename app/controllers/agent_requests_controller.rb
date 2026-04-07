class AgentRequestsController < ApplicationController

  before_action :set_agent_request, only: [:cancel, :approve]

  def index
    @agent_requests = fetch_agent_requests
  end

  def create
    customer = Customer.find(params[:customer_id])
    
    if customer.category_is_agente?
      redirect_to request.referer || root_path, alert: 'El beneficiario ya es AGENTE.'
      return
    end

    if AgentRequest.pending_for_customer?(customer.id)
      redirect_to request.referer || root_path, alert: 'Ya existe una solicitud pendiente para este beneficiario.'
      return
    end

    @agent_request = AgentRequest.new(
      customer: customer,
      branch: @current_branch,
      user: current_user,
      status: :pending
    )

    if @agent_request.save
      redirect_to request.referer || root_path, notice: 'Se creó la solicitud de AGENTE correctamente.'
    else
      redirect_to request.referer || root_path, alert: "Error al crear la solicitud: #{@agent_request.errors.full_messages.join(', ')}"
    end
  end

  def cancel
    if @agent_request.status_pending?
      @agent_request.update!(status: :cancelled)
      redirect_to request.referer || agent_requests_path, notice: 'Solicitud cancelada correctamente.'
    else
      redirect_to request.referer || agent_requests_path, alert: 'No se puede cancelar una solicitud que no está pendiente.'
    end
  end

  def approve
    if @agent_request.status_pending?
      ActiveRecord::Base.transaction do
        @agent_request.customer.update!(category: :agente)
        @agent_request.update!(status: :approved)
      end
      redirect_to agent_requests_path, notice: 'Beneficiario convertido a AGENTE correctamente.'
    else
      redirect_to agent_requests_path, alert: 'No se puede aprobar una solicitud que no está pendiente.'
    end
  end

  def filter
    @agent_requests = fetch_agent_requests
    respond_to do |format|
      format.js
    end
  end

  private

  def set_agent_request
    @agent_request = AgentRequest.find(params[:id])
  end

  def fetch_agent_requests
    scope = if @logged_admin
              AgentRequest.all
            elsif @current_company
              AgentRequest.where(branch: @current_company.branches)
            elsif @current_branch
              AgentRequest.where(branch: @current_branch)
            else
              AgentRequest.none
            end
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where(branch_id: params[:branch_id]) if params[:branch_id].present?
    scope = scope.where('created_at >= ?', Date.parse(params[:date_start]).beginning_of_day) if params[:date_start].present?
    scope = scope.where('created_at <= ?', Date.parse(params[:date_end]).end_of_day) if params[:date_end].present?
    scope.pending_first.includes(:customer, :branch, :user, customer: :person)
  end
  
end