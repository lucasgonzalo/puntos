class ApplicationController < ActionController::Base
  include ApplicationMethods
  #  protect_from_forgery with: :exception
  
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_group
  before_action :set_current_company
  before_action :set_current_branch
  before_action :check_variables, except: %i[ showcase
    home enter_as_admin select_company set_company new_customer_external
    query_customer search_person_customer set_group
    select_country select_state
    create_customer_external confirmation_principal_person finish_upload
    form_new_person current_account_exteneral associate_company
    validate_email email_validated email_validation_error
  ], if_not: :devise_controller?
  before_action :redis_connection
  before_action :check_maintenance_mode

  before_action do
    if (current_user && current_user.admin_role?) || (Rails.env.development? && request.host == 'localhost')
      Rack::MiniProfiler.authorize_request
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to not_found_path, notice: exception.message }
      format.json { render nothing: true, status: :not_found }
      format.js   { render nothing: true, status: :not_found }
    end
  end

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
  Rails.logger.warn "CSRF token invalid for #{request.remote_ip} at
#{request.path}"

  respond_to do |format|
    format.html do
      reset_session
      flash[:alert] = 'Tu sesión ha expirado por seguridad. Por favor,
inicia sesión nuevamente.'
      redirect_to new_user_session_path
    end
    format.json { render json: { error: 'Sesión expirada' }, status:
:unauthorized }
    format.turbo_stream do
      # For turbo stream, show alert message and let user manually navigate
      render turbo_stream: turbo_stream.prepend("flash",
        partial: 'layouts/messages',
        locals: { alert: "Tu sesión ha expirado. Por favor, inicia sesión nuevamente." }
      )
    end
  end
end

  def after_sign_in_path_for(resource_or_scope)
    @current_company = nil
    session[:current_company_id] = nil
    @logged_admin = nil
    session[:logged_admin] = nil

    # Almacena la URL original antes de redirigir al usuario a la página de inicio de sesión
    redirect_url = stored_location_for(resource_or_scope) || super

    #----------------------------Nos fijamos comercios activos, si el usuario esta en mas de un comercio-----------------------------------------
    active_companies = current_user.active_companies
    if active_companies.count > 1 || current_user.admin_role?
      select_company_path(redirect_url: redirect_url)
    elsif active_companies.count == 1
      #----------------------------El usuario tiene un solo comercio-----------------------------------------
      @current_company = active_companies.first
      session[:current_company_id] = @current_company.id
      user_branches = current_user.my_branches(@current_company)

      #----------------------------El usuario tiene una sucursal-----------------------------------------
      if user_branches.count == 1
        @current_branch = user_branches.first
        session[:current_branch_id] = @current_branch.id || nil
        # dashboard_path
        redirect_url
      else
        #----------------------------Nos fijamos sucursales activas, si el usuario esta en mas de un sucursal-----------------------------------------
        select_branch_path(redirect_url: redirect_url)
      end
    else
      #--------------------------Almacena la URL original antes de redirigir al usuario a la página de inicio de sesión---------------------------------
      redirect_url
    end
  end

  def enter_as_admin
    @logged_admin = true
    session[:logged_admin] = true

    session[:current_group_id] = nil
    redirect_to dashboard_path
  end

  def set_group
    @logged_admin = true
    session[:logged_admin] = true
    # Tenemos el id del grupo
    group_id = params[:group_id].to_i
    redirect_url = params[:redirect_url]

    # El grupo seleccionado, sino nil
    @current_group = group_id.positive? ? Group.find(group_id) : nil

    # Si hay comercio anterior seleccionado, sino el seleccionado
    session[:current_company_id] = nil

    # Si hay grupo anterior seleccionado, sino el seleccionado
    session[:current_group_id] = @current_group ? @current_group.id : nil
    #session[:current_company_id] = nil

    redirect_to redirect_url.presence || dashboard_path
  end

  def set_company
    @logged_admin = false
    session[:logged_admin] = false
    # Tenemos el id del comercio
    company_id = params[:company_id].to_i
    redirect_url = params[:redirect_url]

    # El comercio seleccionado, sino nil
    @current_company = company_id.positive? ? Company.find(company_id) : nil

    # Si hay comercio anterior seleccionado, sino el seleccionado
    session[:current_company_id] = company_id.positive? ? @current_company.id : nil

    if company_id.positive?
      # Si la sesion del comercio es distinta a la anterior es nil
      session[:current_branch_id] = nil if @current_company.id != session[:current_company_id]

      # Buscamos las sucursales de usuario
      user_branches = current_user.my_branches(@current_company)
      redirect_to select_branch_path(redirect_url: redirect_url)
    else
      #redirect_to dashboard_path
      redirect_to redirect_url.presence || dashboard_path
    end
  end

  def set_branch
    branch_id = params[:branch_id].to_i
    @current_branch = branch_id.positive? ? Branch.find(branch_id) : nil
    session[:current_branch_id] = branch_id.positive? ? @current_branch.id : nil
    #redirect_to dashboard_path
    redirect_to params[:redirect_url].presence || dashboard_path
  end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation
      )
    end

    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :current_password
      )
    end
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def set_current_group
    @current_group = Group.find_by(id: session[:current_group_id]) if session[:current_group_id]
    @logged_admin = session[:logged_admin] if session[:logged_admin]
  end

  def set_current_company
    @current_company = Company.find_by(id: session[:current_company_id]) if session[:current_company_id]
    @current_group = @current_company.active_group if @current_company
    @logged_admin = session[:logged_admin] if session[:logged_admin]
  end

  def set_current_branch
    @current_branch = Branch.find_by(id: session[:current_branch_id]) if session[:current_branch_id]
    @logged_admin = session[:logged_admin] if session[:logged_admin]
  end

  def check_variables
    return unless !devise_controller? && (!@current_company && !@logged_admin)
    if user_signed_in?
      redirect_to select_company_path
    else
      redirect_to root_path
    end
  end

  def redis_connection
    @redis = Redis.new(host: ENV.fetch("REDIS_HOST", "redis"), db: Integer(ENV.fetch("REDIS_DB", 0))) if !@redis
  end

  def check_maintenance_mode
    return if skip_maintenance_check?
    
    redis_connection
    maintenance_active = @redis.get('maintenance_mode') == 'true'
    
    if maintenance_active
      render 'errors/service_unavailable', status: 503
    end
  end

  def skip_maintenance_check?
    # Skip for health checks
    return true if request.path == '/up' || request.path == '/rails/health/show'
    
    # Skip for admin users
    return true if current_user&.admin_role?
    
    # Skip for error pages to avoid redirect loops
    return true if request.path.start_with?('/404', '/500', '/503')
    
    # Skip for devise controllers
    return true if devise_controller?
    
    # Skip for errors controller
    return true if controller_name == 'errors'
    
    false
  end



end
