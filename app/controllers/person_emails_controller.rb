class PersonEmailsController < ApplicationController
  before_action :set_person_email, only: %i[show edit update destroy]
  before_action :set_customer, only: %i[ new edit show create update]


  def new
    @person = Person.find(params[:person])
    @person_email = PersonEmail.new
  end

  def edit
    @person = @person_email.person
  end

  def show
  end

  def create
    @person_email = PersonEmail.new(
      person_id: params[:person_email][:person_id],
      email: params[:person_email][:email],
      main: params[:person_email][:main],
      active: params[:person_email][:active]
    )

    respond_to do |format|
      if @person_email.save
        format.html { redirect_to !@customer.blank? ? @customer : @person_email.person, notice: 'Email creado correctamente.'}
      else
        format.html { redirect_to !@customer.blank? ? @customer : @person_email.person, alert: 'Email no creada correctamente.' }
      end
    end
  end

  def update
    @person_email.update(
      person_id: params[:person_email][:person_id],
      email: params[:person_email][:email],
      main: params[:person_email][:main],
      active: params[:person_email][:active]
    )

    respond_to do |format|
      if @person_email.save
        format.html { redirect_to !@customer.blank? ? @customer : @person_email.person, notice: 'Email actualizada correctamente.' }
      else
        format.html { redirect_to !@customer.blank? ? @customer : @person_email.person, alert: 'Email no actualizada correctamente.' }
      end
    end
  end

  def destroy
    person = @person_email.person
    @person_email.destroy

    respond_to do |format|
      format.html { redirect_to person, notice: 'Email eliminada exitosamente.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_person_email
    @person_email = PersonEmail.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def person_email_params
    params.require(:person_email).permit(
      :person_id,
      :customer_id,
      :email,
      :main,
      :active
    )
  end

  def set_customer
    if params[:person_email].present? && params[:person_email][:customer_id].present?
      @customer = Customer.find(params[:person_email][:customer_id])
    elsif params[:customer].present?
      @customer = Customer.find(params[:customer])
    else
      @customer = nil
    end
  end
end
