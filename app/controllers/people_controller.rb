class PeopleController < ApplicationController
  before_action :set_person, only: %i[show edit update destroy addresses emails balance]
  skip_before_action :authenticate_user!, only: %i[create_customer_external confirmation_principal_person finish_upload validate_email email_validated email_validation_error]
  layout 'clean', only: %i[confirmation_principal_person finish_upload validate_email email_validated email_validation_error]

  # GET /people or /people.json
  def index
    @people = Person.all
  end

  # GET /people/1 or /people/1.json
  def show
    @person_addresses = @person.person_addresses
    @person_emails = @person.person_emails
    @person_phones = @person.person_phones
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit; end

  # POST /people or /people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to person_url(@person), notice: 'Persona creada correctamente'}
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1 or /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to person_url(@person), notice: 'Persona actualizada correctamente'}
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1 or /people/1.json
  def destroy
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url, notice: 'Persona eliminada correctamente' }
      format.json { head :no_content }
    end
  end

  def addresses
    respond_to do |format|
      format.html { render partial: 'people/addresses', locals: { person_addresses: @person.person_addresses, person: @person } }
    end
  end

  def emails
    respond_to do |format|
      format.html
    end
  end

  def search_by_document
    document_number = params[:document_number].split
    person = @current_company.people.where(document_number: document_number).first
    html_tag = person ? person.html_card : '<h4>NO EXISTE PERSONA</h4>'.html_safe

    response = { person: person, html_tag: html_tag }
    respond_to do |format|
      format.json { render json: response }
    end
  end

  def balance

  end

  def create_customer_external

    error = false
    @token_company = params[:token_company]
    @token_branch = params[:token_branch] if !params[:token_branch].blank?

    if params[:document_number].blank? ||params[:document_type].blank?
      error = true
      msg = "No se pudo guardar. Tipo y Nro de Documento son obligatorios"
    end

    person_exist = Person.where(document_number: params[:document_number], document_type: params[:document_type])
    
    #------------------------Creación de Person----------------------
    if !person_exist.blank? #----ya hay una persona
      error = true
      msg = "No se pudo guardar ya hay una persona con este DNI"
    else
      @person =  Person.new(
        first_name: params[:first_name],
        last_name: params[:last_name],
        document_type: params[:document_type],
        document_number: params[:document_number],
        birth_date:params[:birth_date],
        gender: params[:gender]
      )
      if !error
        error = true unless @person.save!
      end
      #---------------------Email y Telefono de Persona----------------------
      unless error
        unless params[:email].blank?
          person_email = @person.person_emails.new(
            email: params[:email],
            main: true,
            active: true
          )
          error = true unless person_email.save!
          msg = "No se pudo guardar - " + person_email.errors.full_messages.to_s if error == true
        end

        unless params[:phone_number].blank?
          person_phone = @person.person_phones.new(
            phone_type: params[:phone_type],
            country_code: params[:country_code],
            area_code: params[:area_code],
            phone_number: params[:phone_number],
            main: true,
            active: true
          )
          error = true unless person_phone.save!
          msg = "No se pudo guardar - " + person_phone.errors.full_messages.to_s if error == true
        end
      end
    end

    # ------------------Buscamos el comercio que ya existe-----------------------
    company = Company.find_by(token: @token_company)


    # found_person = Person.where(document_number: params[:document_number]).last

    #----------- Verificamos si la persona es cliente del comercio, sino la creamos-------------------
    customer = Customer.where(company: company, person: @person).first

    if customer.blank? && !error
      customer = Customer.new(company: company, person: @person, status: :pending)
      customer.save!
    else
    end

    unless params[:first_person].blank?
      #---------------En este caso es last porque es el ultimo de la BD, es decir el mas viejo.-----------
      @first_person = Person.find(params[:first_person])
      relationship = Relationship.find(params[:relationship])
      person_relationship = PersonRelationship.new(
        person: @person,
        relationship: relationship,
        person_relation: @first_person
      )
      error = true unless person_relationship.save!
    end

    respond_to do |format|
      if !error

        ## Here should send the registration email to the customer
        RegistrationMailer.validate_email_registration(@person.person_emails.first, company).deliver_now if @person.person_emails.any?

        first_person_id =  @first_person.blank? ? @person.id : @first_person.id
        return_success = !@token_branch.blank? ? confirmation_principal_person_path(token_company: @token_company, token_branch: @token_branch, first_person: first_person_id) : confirmation_principal_person_path(token_company: @token_company, first_person: first_person_id)
        format.html {
          redirect_to return_success,
          notice: 'Persona creada correctamente'
        }
      else
        return_alert = !@token_branch.blank? ? form_new_person_path(token_company: @token_company, token_branch: @token_branch) : form_new_person_path(token_company: @token_company)
        format.html {
          redirect_to return_alert,
          alert: msg

        }
        format.json { render json: person.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirmation_principal_person
    @first_person = params[:first_person]
    @person = Person.find_by_id(@first_person)

    if !params[:token_branch].blank?
      @token_company = params[:token_company]
      @token_branch = params[:token_branch]
      render 'qr_branches/confirmation_principal_person'
    else
      @token_company = params[:token_company]
      render 'qr_code/confirmation_principal_person'
    end
  end

  def finish_upload
    @asociated_customer = params[:asociated].present? && params[:asociated] == 'true' # Variable para mostrar mensaje de asociación exitosa si viene de una asociación, sino mostramos mensaje de registro exitoso
    @company = Company.find_by(token: params[:token_company])
    @branch = Branch.find_by(token: params[:token_branch]) if !params[:token_branch].blank?
    @return_page = !@branch.blank? ? new_customer_external_qr_branches_path(token: @branch.token) : new_customer_external_path(token: @company.token)
  end

  def validate_email #Procesa el token, valida el email, incrementa contadores, o redirige a error
    @person_email = PersonEmail.find_by_token_for(:email_validation, params[:token])
    if @person_email
      if @person_email.validated_at.present?
        redirect_to email_validation_error_path(error: 'already_validated')
        return
      end
      @person_email.update!(
        validated_at: Time.current,
        email_validation_times_sended: (@person_email.email_validation_times_sended || 0) + 1,
        emails_sended: @person_email.emails_sended + 1
      )
      @person = @person_email.person
      render 'email_validated'
    else
      redirect_to email_validation_error_path(error: 'invalid_token')
    end
  end

  def email_validated # Muestra la página de éxito
    @person_email = PersonEmail.find_by_token_for(:email_validation, params[:token]) if params[:token].present?
  end

  def email_validation_error # Muestra la página de error (token inválido, ya validado, etc.)
    @error_type = params[:error] || 'invalid_token'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_person
    @person = Person.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def person_params
    params.require(:person).permit(:first_name, :last_name, :document_type, :document_number, :birth_date, :gender)
  end


  def person_address_params
    params.require(:person).permit(:address, :geolocation_link, :postal_code, :city_id)
  end

  def person_email_params
    params.require(:person).permit(:email)
  end

  def person_phone_params
    params.require(:person).permit(:country_code, :area_code, :phone_number, :phone_type)
  end

  def token_params
    params.require(:person).permit(:token)
  end
end
