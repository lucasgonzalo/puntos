class BranchUsersController < ApplicationController
  before_action :set_branch_user, only: %i[ show edit update destroy activate_employee edit_employee]
  before_action :set_combos, only: %i[ new create edit update ]

  # GET /branch_users or /branch_users.json
  def index
    if @logged_admin
      @companies = Company.where(active: true).to_a
    else
      @companies = [@current_company]
    end

    if @current_branch # Filtra la primera carga del index si tiene branch seleccionada
      @condition_branch = @current_branch.id.to_s
    end
  end

  # GET /branch_users/1 or /branch_users/1.json
  def show
    @return_page = params[:return_page]
  end

  # GET /branch_users/new
  def new
    @user = User.new
  end

  # GET /branch_users/1/edit
  def edit
    @return_page = params[:return_page]
  end

  # POST /branch_users or /branch_users.json
  def create
    @branch = Branch.find(params[:branch_user][:branch_id])
    user_email = params[:branch_user][:user_email].strip
    user = User.find_by(email: user_email)

    @branch_user = BranchUser.new(branch_user_params)

    @branch_user.errors.add(:base, 'Usuario no registrado') unless user

    respond_to do |format|
      @branch_user.user = user
      if user && @branch_user.save
        format.html { redirect_to branch_users_url(branch_id: @branch.id), notice: 'Usuario vinculado correctamente.'}
        format.json { render :show, status: :created, location: @branch_user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @branch_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /branch_users/1 or /branch_users/1.json
  def update
    respond_to do |format|
      if @branch_user.update(branch_user_params)
        format.html {redirect_to branch_users_url(branch_id: @branch_user.branch.id), notice: 'Usuario actualizado correctamente.'}
        format.json { render :show, status: :ok, location: @branch_user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @branch_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_active
    @branch_user = BranchUser.find(params[:id])
    new_active_state = params[:active] == 'true'
    if @branch_user.update(active: new_active_state)
      render partial: 'active_cell', locals: { branch_user: @branch_user }
    else
      render status: :unprocessable_entity, html: "Error updating user: #{@branch_user.errors.full_messages.join(', ')}"
    end
  end

  # DELETE /branch_users/1 or /branch_users/1.json
  def destroy
    @branch_user.destroy

    respond_to do |format|
      format.html { redirect_to branch_users_url, notice: 'Usuario eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  def create_employee
    @branch = Branch.find(params[:branch_id])
    error = false

    if User.exists?(email: params[:email])
      error = true
      msg = "No se pudo guardar - " + person_phone.errors.full_messages.to_s
    else
      @user = User.new(
        first_name: params[:first_name],
        last_name: params[:last_name],
        email: params[:email],
        password: params[:password]
      )
      @user.branch_users.build(
        branch_id: @branch.id,
        active: params[:active],
        manager_role: params[:manager_role],
        intermediate_role: params[:intermediate_role],
        basic_role: params[:basic_role]
      )
      error = true unless @user.save!
    end
    respond_to do |format|
      if @user.save && error==true
        format.html { redirect_to branch_users_path, notice: 'Empleado creado correctamente'}
      else
        format.html { redirect_to branch_users_path, alert: msg }
      end
    end
  end

  def form_employee
    @entity_current_branch = Branch.find_by(id: params[:branch_id])
    @entity_current_company = @entity_current_branch.company
    # @group_related_users 
  end

  def add_or_create_employee
    branch_id = params[:branch_id].to_i
    
    ActiveRecord::Base.transaction do
      validate_branch_id!(branch_id)
      user = find_or_create_user
      create_or_update_branch_user_association(user, branch_id)
    end

    respond_to do |format|
      format.html { 
        redirect_to show_branch_users_path(branch_id: branch_id), 
                    notice: "Empleado agregado correctamente" 
      }
    end
  rescue => e
    Rails.logger.error "Error al agregar empleado: #{e.message}"
    
    respond_to do |format|
      format.html { 
        redirect_to form_employee_path(branch_id: branch_id), 
                    alert: e.message 
      }
    end
  end

  def filter_employees
    if @logged_admin
      @companies = Company.where(active: true)
    else
      @companies = [@current_company]
    end

    if !params[:user_status].blank?
      @condition_active = params[:user_status]
    end

    if !params[:user_roles].blank?
      @condition_role = params[:user_roles]
    end

    if !params[:branch].blank?
      @condition_branch = params[:branch]
    end

    respond_to do |format|
      format.js
    end
  end

  def activate_employee
    value_status = params[:activate]=="true" ? :true : :false
    msg = params[:activate]=="true" ? 'Empleado activado correctamente.' : 'Empleado desactivado correctamente.'

    respond_to do |format|
      if @branch_user.update(active: value_status)
        format.html { redirect_to branch_user_path(@branch_user, return_page: params[:return_page]), notice:  msg}
      else
        format.html { redirect_to branch_user_path(@branch_user, return_page: params[:return_page]), alert:  'Hubo un error'}
      end
    end
  end

  def edit_employee
    begin
      ActiveRecord::Base.transaction do
        @branch_user.update!(
          active: params[:active],
          manager_role: params[:manager_role],
          intermediate_role: params[:intermediate_role],
          basic_role: params[:basic_role]
        )
      end

      respond_to do |format|
        format.html { redirect_to branch_users_path, notice: 'Empleado editado correctamente' }
      end
    rescue => e
      Rails.logger.error "Error al editar el empleado: #{e.message}"
      respond_to do |format|
        format.html { redirect_to branch_users_path, alert: 'Empleado no editado correctamente' }
      end
    end
  end

  def show_branch_users
    @branch = Branch.find(params[:branch_id])
  end

  private
  # Use callbacks to share common setup or constraints between actions.

  def set_branch_user
    @branch_user = BranchUser.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def branch_user_params
    params.require(:branch_user).permit(:branch_id, :user_id, :active, :manager_role, :intermediate_role, :basic_role)
  end

  def set_combos
    @users = User.order(:last_name)
  end

  def validate_branch_id!(branch_id)
    return if branch_id.positive?
    
    raise StandardError, "Hubo un problema y no se obtuvo el comercio actual, actualice e intente nuevamente"
  end

  def find_or_create_user
    case params[:create_user]
    when "create_new"
      create_new_user
    when "modify_existing"
      find_existing_user
    else
      raise StandardError, "Acción no válida para el usuario"
    end
  end

  def create_new_user
    validate_unique_email!
    
    User.create!(
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      password: params[:password]
    )
  end

  def validate_unique_email!
    return unless User.exists?(email: params[:email])
    
    raise StandardError, "Ya existe un usuario con este email"
  end

  def find_existing_user
    user = User.find_by(id: params[:user_id])
    raise StandardError, "Usuario no encontrado" unless user
    
    user
  end

  def create_or_update_branch_user_association(user, branch_id)
    branch_user = user.branch_users.find_by(branch_id: branch_id)
    
    if branch_user
      # Update existing association with new roles
      branch_user.update!(
        active: true,
        **role_permissions
      )
    else
      # Create new association
      user.branch_users.create!(
        branch_id: branch_id,
        active: true,
        **role_permissions
      )
    end
  end

  def role_permissions
    case params[:role]
    when "manager"
      { manager_role: true, intermediate_role: false, basic_role: false }
    when "intermediate"
      { manager_role: false, intermediate_role: true, basic_role: false }
    when "basic"
      { manager_role: false, intermediate_role: false, basic_role: true }
    else
      raise StandardError, "Rol no válido"
    end
  end
end
