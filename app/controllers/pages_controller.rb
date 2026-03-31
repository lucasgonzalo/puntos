class PagesController < ApplicationController
  layout 'clean', only: %i[home error404 not_allowed select_company select_branch]
  skip_before_action :authenticate_user!, only: %i[home about error404]

  def dashboard_crm; end

  def home
    redirect_to dashboard_path if current_user
  end

  # ESTOS SON LOS GRAFICOS
  def dashboard
    @customers = @current_company ? @current_company.customers : Customer.all

    @company ||= @current_company

    if @current_branch
      @movements = @current_branch.movements
    else
      @movements = @current_company ? @current_company.movements : (@current_group ? Movement.where(group: @current_group) : Movement.all)
    end

    @exchange_count = @current_company ?
    @current_company.movements.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, movement_type: [:exchange, :product_exchange]).count :
    Movement.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, movement_type: [:exchange, :product_exchange]).count
    if @current_company
      today_movements = @current_company.movements.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, movement_type: [:sale])
    else
      today_movements = Movement.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
    end
    @today_movements = today_movements.count
    @today_movements_amount = today_movements.map(&:amount).sum

    # Redirecciona a nuevo movimiento si: hay sucursal actual y el usuario tiene rol basico en esa sucursal
    basic_role_with_branch = @current_branch && current_user.branch_users.find_by(branch_id: @current_branch.id)&.basic_role?
    # Redirecciona a nuevo movimiento si: hay grupo actual de tipo GRUPO y el usuario no es admin o grupo owner
    admin_or_group_owner_with_group = @current_group && @current_group.account_type_group? && !(current_user.admin_role? || current_user.group_owner_role?)
    if basic_role_with_branch || admin_or_group_owner_with_group
      redirect_to new_movement_path
    end
  end

  def update_stream_content
    # This is stored as example of dynamic content update via Turbo Streams
    @customers = @current_company ? @current_company.customers : Customer.all
    @company ||= @current_company
    #This uses TURBO STREAM to update a part of the page
    @new_text = "Updated text at #{Time.current}"  # Example dynamic content

    respond_to do |format|
      format.turbo_stream  # Only handle Turbo Stream responses
    end
  end

  def update_frame_content
    # This is stored as example of dynamic content update via partial rendering
    @customers = @current_company ? @current_company.customers : Customer.all
    @company ||= @current_company
    
    @content = "Updated text at #{Time.current}"  # Dynamic server-side content
    # No explicit respond_to needed; Rails renders update_frame_content.html.erb by default
  end

  def load_customers_graphs
    @customers = @current_company ? @current_company.customers : Customer.all
    @company ||= @current_company
    # No explicit respond_to needed; Rails renders load_customers_graphs.html.erb by default
  end


  # ESTOS SON DATOS GENERALES Y ESTADISTICAS GENERALES
  def general_data
    @customers = @current_company ? @current_company.customers : Customer.all
    @company = @current_company ? @current_company : nil
    total_movement = @company ? @company.movements.where(created_at: 1.months.ago..0.month.ago, annulled: false).count : Movement.where(created_at: 1.months.ago..0.month.ago, annulled: false).count
    total_annulment = @company ? @company.movements.where(created_at: 1.months.ago..0.month.ago, annulled: true).count : Movement.where(created_at: 1.months.ago..0.month.ago, annulled: true).count
    @monthly_transactions = total_movement - total_annulment
    @active_mails = @customers.joins(person: :person_emails).where(person_emails: { active: true }).count
    @active_phones = @customers.joins(person: :person_phones).where(person_phones: { active: true }).count

    @exchange_count = @current_company ?
    @current_company.movements.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, movement_type: [:exchange, :product_exchange]).count :
    Movement.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, movement_type: [:exchange, :product_exchange]).count
    @movements = @current_company ? @current_company.movements : (@current_group ? Movement.where(group: @current_group) : Movement.all)
  end

  # ESTOS SON DATOS PERIODICOS
  def periodic_data
    @customers = @current_company ? @current_company.customers : Customer.all
    @movements = @current_company ? @current_company.movements : (@current_group ? Movement.where(group: @current_group) : Movement.all)
    total_movement = @movements.where(created_at: 1.months.ago..0.month.ago, annulled: false, movement_type: :sale).sum(:points)
    total_annulment = @movements.where(created_at: 1.months.ago..0.month.ago, annulled: false, movement_type: :exchange).sum(:points)
    @awarded_points = total_movement - total_annulment

    total_movement = @movements.where(created_at: 1.months.ago..0.month.ago, annulled: false, movement_type: :sale).sum(:amount)
    total_exchange = @movements.where(created_at: 1.months.ago..0.month.ago, annulled: false, movement_type: :exchange).sum(:amount)
    @monthly_billing = total_movement - total_exchange
  end

  def select_company
    @redirect_url = params[:redirect_url] if !params[:redirect_url].blank?
    @companies = current_user.active_companies
    @groups = current_user.active_groups
  end

  def select_branch
    @redirect_url = params[:redirect_url] if !params[:redirect_url].blank?
    @branches = current_user.my_branches(@current_company) unless current_user.blank?
  end

  def error404; end

  def not_allowed; end
end
