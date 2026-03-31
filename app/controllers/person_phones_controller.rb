class PersonPhonesController < ApplicationController
  before_action :set_person_phone, only: %i[show edit update destroy]
  before_action :set_customer, only: %i[ new edit show create update]

  def new
    @person = Person.find(params[:person])
    @person_phone = PersonPhone.new
  end

  def edit
    @person = @person_phone.person
  end

  def show
  end

  def create
    @person_phone = PersonPhone.new(
      person_id: params[:person_phone][:person_id],
      country_code: params[:person_phone][:country_code],
      area_code: params[:person_phone][:area_code],
      phone_number: params[:person_phone][:phone_number],
      phone_type: params[:person_phone][:phone_type],
      main: params[:person_phone][:main],
      active: params[:person_phone][:active]
    )
    @person = @person_phone.person

    respond_to do |format|
      if @person_phone.save
        format.html { redirect_to !@customer.blank? ? @customer : @person_phone.person, notice: 'Teléfono creado correctamente.'}
      else
        format.html { redirect_to !@customer.blank? ? @customer : @person_phone.person, alert: 'Teléfono no creada correctamente.' }
      end
    end
  end

  def update
    @person_phone.update(
      person_id: params[:person_phone][:person_id],
      country_code: params[:person_phone][:country_code],
      area_code: params[:person_phone][:area_code],
      phone_number: params[:person_phone][:phone_number],
      phone_type: params[:person_phone][:phone_type],
      main: params[:person_phone][:main],
      active: params[:person_phone][:active]
    )

    respond_to do |format|
      if @person_phone.save
        format.html { redirect_to !@customer.blank? ? @customer : @person_phone.person, notice: 'Teléfono actualizada correctamente.' }
      else
        format.html { redirect_to !@customer.blank? ? @customer : @person_phone.person, alert: 'Teléfono no actualizada correctamente.' }
      end
    end
  end

  def destroy
    person = @person_phone.person
    @person_phone.destroy

    respond_to do |format|
      format.html { redirect_to person, notice: 'Teléfono eliminada exitosamente.'}
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_person_phone
    @person_phone = PersonPhone.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def person_phone_params
    params.require(:person_phone).permit(
      :person_id,
      :customer_id,
      :country_code,
      :area_code,
      :phone_number,
      :phone_type,
      :main,
      :active
    )
  end

  def set_customer
    if params[:person_phone].present? && params[:person_phone][:customer_id].present?
      @customer = Customer.find(params[:person_phone][:customer_id])
    elsif params[:customer].present?
      @customer = Customer.find(params[:customer])
    else
      @customer = nil
    end
  end

end
