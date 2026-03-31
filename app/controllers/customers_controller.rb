class CustomersController < ApplicationController

  skip_before_action :authenticate_user!, only: %i[
    new_customer_external query_customer search_person_customer form_new_person current_account_exteneral associate_company
  ]
  before_action :set_customer, only: %i[
    show edit update destroy current_account activate_customer current_account_exteneral
  ]
  before_action :check_company, except: %i[
    index new edit new_customer_external query_customer search_person_customer form_new_person current_account_exteneral associate_company
  ]
  before_action :set_combos, only: %i[
    new create edit update
  ]
  layout 'clean', only: %i[
    new_customer_external query_customer form_new_person current_account_exteneral
  ]


  # GET /customers or /customers.json
  def index
    companies = if @logged_admin
                  if @current_group
                    Company.joins(:groups).where(groups: { id: @current_group.id })
                  else
                    Company.all
                  end
                else
                  @current_company
                end

    # companies = @logged_admin ? Company.joins(:groups).where(groups: { id: @current_group.id }) : @current_company
    @customers = Customer.where(company: companies).includes(:person, :company).order(created_at: :desc)

    # Este cod es para ejecutar el job que pone en estado dormido a los clientes
    if current_user.company_owner_role? && !@logged_admin
      companies = current_user.active_companies
      companies.each do |company|
        MyTaskStatusJob.perform_later(company)
      end
    end
  end

  # GET /customers/1 or /customers/1.json
  def show; end

  # GET /customers/new
  def new; end

  # GET /customers/1/edit
  def edit; end

  # POST /customers or /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to customer_url(@customer), notice: 'Cliente creado correctamente.' }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to customer_url(@customer), notice: 'Cliente actualizado correctamente.' }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Cliente eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  #-------------------------Buscador de Person con tipo DNI por defecto ---------------------------------
  def search_person_customer_backup
    document_number = params[:document_number].strip
    @company = params[:company].blank? ? @current_company : Company.find(params[:company])

    @person = Person.where(document_number: document_number, document_type: params[:document_type]).last
    @customer = Customer.find_by(person: @person, company: @company) if @person

    # @customer = Customer.find_by(person: @person, company: @current_company) if @person
    session[:result_person] = @person
    session[:document_number] = document_number
    @new_customer_next_enabled = true unless @customer

    @conversion = @company.today_conversion
    @discount = @company.today_discount

    respond_to do |format|
      format.turbo_stream { render "search_person/return_person_movement" }
    end
  end


  def search_person_customer
    action_name = params[:action_name_param]
    controller_name = params[:controller_name_param]

    #---------------------Buscamos solo personas de comercios-----------------
    @company, @branch, @document_number, @person, @customer = search_person_in_company(
      params[:document_number],
      params[:document_type],
      params[:company_id].to_i,
      params[:branch_id].to_i
    )

    respond_to do |format|
      format.turbo_stream do
        return if @person.blank?

        if (action_name=='new' && controller_name=='movements')
          render "search_person/return_person_movement"

        elsif (action_name=='new_customer_wizard' && controller_name=='customers')
          session[:result_person] = @person
          session[:document_number] = @document_number
          @new_customer_next_enabled = @customer ? false : true
          render "search_person/return_person_wizard"

        elsif (action_name=='new_customer_external' && controller_name=='qr_branches')
          render "search_person/return_person_new_customer_external"

        elsif (action_name=='query_customer' && controller_name=='qr_branches')
          render "search_person/return_person_query_customer"

        else
          # Also Goes this way if @person.blank?
          render "customers/search_person_customer"

        end
      end
    end
  end

  def new_customer_wizard
    puts "entro aqui para abrir el wizard en determinado paso"
    logger.info "Entrando a new_customer_wizard con paso #{params[:step]}"

    @company = @logged_admin ? nil : @current_company
    @branch = @logged_admin ? nil : @current_branch

    @new_customer_next_enabled = false
    @new_customer_previous_enabled = false
    @new_customer_finish_enabled = false

    @step = params[:step].to_i
    session[:new_customer_step] = @step

    case @step
    when 1
      @customer = Customer.new
    when 2
      @new_customer_previous_enabled = true
      @customer = session[:result_customer]
      @person = Person.find_by(id: session[:result_person]["id"]) if session[:result_person]
      @person ||= Person.new
      @person.document_number = session[:document_number]
    when 3
      @person = Person.find_by(id: session[:person_id])
      @customer = Customer.find_by(company: @current_company, person: @person)
      @customer ||= Customer.new(company: @current_company, person: @person)
      @customer.status = :pending
      @customer.save!
      @new_customer_finish_enabled = true
    end

    # render :new_customer_wizard
  end

  def wizard_previous_step
    @step = session[:new_customer_step] - 1
    session[:new_customer_step] = @step
    redirect_to new_customer_wizard_path(step: @step)
  end

  def wizard_next_step
    @step = session[:new_customer_step] + 1
    session[:new_customer_step] = @step
    redirect_to new_customer_wizard_path(step: @step)
  end

  def current_account; end
  def current_account_exteneral; end

  def validate_person
    @new_customer_previous_enabled = true
    @person_find = Person.find_by(document_number: params[:person][:document_number])
    @person = !@person_find.blank? ? @person_find : Person.new(document_number: params[:person][:document_number])
    @person.document_type = params[:person][:document_type]
    @person.first_name = params[:person][:first_name]
    @person.last_name = params[:person][:last_name]
    @person.birth_date = params[:person][:birth_date]
    @person.gender = params[:person][:gender]

    if @person.valid?
      @person.save!
      session[:person_id] = @person.id
      @new_customer_next_enabled = true
    else
      @new_customer_next_enabled = false
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  def new_customer_external
    @token = params[:token]
    @company = Company.find_by(token: @token)
    render 'qr_code/new_customer_external'
  end

  def form_new_person
    @person = Person.new
    @first_person = nil

    if params[:token_branch].blank?
      @company = Company.find_by(token: params[:token_company])
      @token_company = @company.token
      render 'qr_code/form_load_person'
    else
      @branch = Branch.find_by(token: params[:token_branch])
      @company = @branch.company
      @token_company = @company.token
      @token_branch = @branch.token
      render 'qr_branches/form_load_person'
    end
  end

  def query_customer
    @token = params[:token]
    @company = Company.find_by(token: @token)
  end

  def filter_customers
    @customers = @logged_admin ? Customer.all : Customer.where(company: @current_company)

    if params[:customer_status].present?
      @customers = @customers.where(status: params[:customer_status].to_sym).includes(:person, :company)
    end

    if params[:date_end].present? || params[:date_start].present?
    zone = 'America/Argentina/Buenos_Aires'

    date_start = params[:date_start].present? ?
      Date.parse(params[:date_start]).in_time_zone(zone).beginning_of_day :
      Date.new(2000, 1, 1).in_time_zone(zone).beginning_of_day

    date_end = params[:date_end].present? ?
      Date.parse(params[:date_end]).in_time_zone(zone).end_of_day :
      Time.current.in_time_zone(zone).end_of_day

  

    @customers = @customers.where(created_at: date_start..date_end).includes(:person, :company)
  end

    respond_to do |format|
      format.js
    end
  end

  def excel_customers
    customer_ids = params[:customers].to_s.split(',').map(&:to_i)
    @customers = Customer.where(id: customer_ids).includes(person: [:person_emails, :person_addresses, :person_phones]) unless params[:customers].blank?
    respond_to do |format|
      format.html
      format.xlsx { render xlsx: 'excel_customers', filename: "Excel_Clientes_#{Time.now.in_time_zone('America/Argentina/Buenos_Aires').strftime('%d-%m-%Y_%H-%M')}.xlsx" }
    end
  end

  def activate_customer
    value_status = params[:activate]=="true" ? :active : :inactive
    msg = params[:activate]=="true" ? 'Cliente activado correctamente.' : 'Cliente desactivado correctamente.'

    respond_to do |format|
      if @customer.update(status: value_status)
        format.html { redirect_to customer_url(@customer), notice:  msg}
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end


  def search_customer_person
  end


  def associate_company
    person = Person.find_by(id: params[:person_id].to_i)
    company = Company.find_by(id: params[:company_id].to_i)
    branch = Branch.find_by(id: params[:branch_id].to_i) if !params[:branch_id].blank?
    customer = Customer.new(company: company, person: person, status: :pending)

    return_url = branch ? finish_upload_path(token_company: company.token, token_branch: branch.token, asociated: true) : finish_upload_path(token_company: company.token, asociated: true)

    respond_to do |format|
      if customer.save
        format.html { redirect_to return_url, notice: "Se asoció correctamente" }
      end
    end
  end




  def query_customer_branch
    @branch = Branch.where(token: params[:token]).first
    @company = @branch.company
  end



  private

  # Use callbacks to share common setup or constraints between actions.
  def set_customer
    @customer = Customer.find_by(id: params[:id]) || Customer.new
  end

  # Only allow a list of trusted parameters through.
  def customer_params
    params.require(:customer).permit(:person_id, :company_id)
  end

  def set_combos
    @companies = Company.all.order(:name)
  end

  def check_company
    redirect_to select_company_url unless @current_company
  end

  def search_person_in_company(document_number, document_type, company_id, branch_id)
    document_number = params[:document_number].strip
    company = company_id.blank? ? @current_company : Company.find_by_id(company_id)
    branch = branch_id.blank? ? @current_branch : Branch.find_by_id(branch_id)

    person = Person.where(document_number: document_number, document_type: document_type).last
    if company
      customer = Customer.find_by(person: person, company: company) if person
    else 
      customer = Customer.where(person: person).last if person
    end
    return company, branch, document_number, person, customer
  end
end
