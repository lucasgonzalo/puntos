# frozen_string_literal: true
module SidebarHelper
  
  # ==================== VERIFICACIONES DE CONTEXTO ====================
  
  def logged_admin?
    @logged_admin == true
  end
  
  def admin_without_group?
    @logged_admin && @current_group.nil?
  end
  
  def company_owner?
    current_user.company_owner_role?
  end
  
  def group_owner?
    current_user.group_owner_role?
  end
  
  def branch_selected?
    @current_branch.present?
  end
  
  def company_context?
    @current_company.present?
  end
  
  def group_context?
    @current_group.present?
  end
  
  # ==================== VERIFICACIONES DE ROL EN SUCURSAL ====================
  
  def branch_user(branch = @current_branch)
    return nil unless branch
    
    current_user.branch_users.find_by(branch_id: branch.id)
  end
  
  def current_basic_role?
    return false unless branch_selected?
    
    branch_user&.basic_role?
  end
  
  def current_intermediate_role?
    return false unless branch_selected?
    
    branch_user&.intermediate_role?
  end
  
  def current_manager_role?
    return false unless branch_selected?
    
    branch_user&.manager_role?
  end
  
  def current_not_basic_role?
    branch_selected? && !current_basic_role?
  end
  
  # ==================== VERIFICACIONES COMBINADAS ====================
  
  def logged_admin_or_no_group_or_company_owner?
    logged_admin? || @current_group.nil? || company_owner?
  end
  
  def admin_or_company_owner?
    admin_without_group? || company_owner?
  end
  
  # ==================== SECCIONES ====================
  
  def show_indicators?
    (admin_without_group? || company_owner?) ||
      (branch_selected? && current_not_basic_role?)
  end
  
  def show_entities?
    logged_admin? && can?(:access, Group)
  end
  
  def show_companies?
    logged_admin? && can?(:access, Company)
  end
  
  def show_customers?
    can?(:access, Customer)
  end
  
  def show_people?
    logged_admin? && can?(:access, Person)
  end
  
  def show_movements?
    can?(:access, Movement)
  end
  
  def show_qr?
    (@current_company || @current_branch) && can?(:access, :my_qr)
  end
  
  def show_qr_branch?
    branch_selected? && can?(:access, :my_qr)
  end
  
  def show_qr_entity?
    group_owner? && can?(:access, :my_qr)
  end
  
  def show_employees?
    can?(:access, BranchUser)
  end
  
  def show_users?
    can?(:access, User)
  end
  
  def show_branch_settings?
    branch_selected? && can?(:access, :branch_setting)
  end
  
  def show_locations?
    can?(:access, Country) || can?(:access, State) || can?(:access, City)
  end
  
  def show_relationships?
    logged_admin? && can?(:access, :relationship)
  end
  
  def show_catalogs?
    true
  end
  
  # ==================== INDICADORES SUB-ITEMS ====================
  
  def show_indicators_general_data?
    admin_or_company_owner? && !branch_selected?
  end
  
  def show_indicators_periodic_data?
    admin_or_company_owner? && !branch_selected?
  end
  
  def show_indicators_charts?
    true 
  end
  
  def indicators_general_label
    company_context? ? 'Datos Generales' : 'Estadísticas Generales'
  end
  
  # ==================== CLIENTES VARIANTES ====================
  
  def show_customers_admin_version?
    show_customers? && (logged_admin? || @current_group.nil? || company_owner?) && !@current_branch
  end
  
  def show_customers_branch_standard_version?
    show_customers? && current_intermediate_role?
  end
  
  def show_customers_branch_basic_version?
    show_customers? && branch_selected? && (current_basic_role? || current_manager_role?)
  end
  
  def new_client_qr_url
    return '' unless branch_selected?
    
    "#{request.base_url}#{new_customer_external_qr_branches_path(token: @current_branch.token)}"
  end

  def new_client_qr_url
  # Use branch QR if branch is selected
  if branch_selected?
    "#{request.base_url}#{new_customer_external_qr_branches_path(token: @current_branch.token)}"
    # Use company QR for company_owner at company level (or other users with company but no branch)
  elsif @current_company.present? && current_user.company_owner_role? 
    "#{request.base_url}#{new_customer_external_path(token: @current_company.token)}"
  else
    ''
  end
end
  
  # ==================== MOVIMIENTOS SUB-ITEMS ====================
  
  def show_movements_new?
    can?(:create, Movement.new) && !group_owner?
  end
  
  # ==================== QR ENTIDAD ====================
  
  def first_entity_branch
    return nil unless @current_group
    
    @current_group.companies&.first&.branches&.first
  end
  
  def show_qr_entity_first_branch?
    show_qr_entity? && first_entity_branch.present?
  end
  
  # ==================== ALERTAS ====================
  
  def company_alerts_count
    return 0 unless @current_company
    
    @current_company.count_alerts_not_read
  end
  
  def show_company_alerts_badge?
    company_context? && company_alerts_count.positive?
  end
  
  def branch_alerts_count
    return 0 unless branch_selected?
    
    @current_branch.count_branch_alerts_not_read
  end
  
  def show_branch_alerts_badge?
    branch_selected? && branch_alerts_count.positive?
  end

  # ==================== ALTA DE AGENTE ====================

  def show_agent_requests?
    can?(:index, AgentRequest) && (@current_company.present? || @logged_admin)
  end
  
  def agent_requests_pending_count
    return 0 unless @current_company
    AgentRequest.where(branch_id: @current_company.branches.select(:id), status: :pending).count
  end
  
  # ==================== LOCALIZACIONES ====================
  
  def show_countries?
    can?(:access, Country)
  end
  
  def show_states?
    can?(:access, State)
  end
  
  def show_cities?
    can?(:access, City)
  end
end