class PersonAddressesController < ApplicationController
  before_action :set_person_address, only: %i[ show edit update destroy ]
  before_action :set_customer, only: %i[new edit show create update]


  def new
    @person = Person.find(params[:person])
    @person_address = PersonAddress.new
  end

  def edit
    @person = @person_address.person
  end

  def show
  end

  def create
    @person_address = PersonAddress.new(
      person_id: params[:person_address][:person_id],
      address: params[:person_address][:address],
      geolocation_link: params[:person_address][:geolocation_link],
      latitude: params[:person_address][:latitude],
      longitude: params[:person_address][:longitude],
      postal_code: params[:person_address][:postal_code],
      city_id: params[:person_address][:city_id],
      main: params[:person_address][:main],
      active: params[:person_address][:active]
    )

    respond_to do |format|
      if @person_address.save
        format.html { redirect_to !@customer.blank? ? @customer : @person_address.person, notice: 'Dirección creada correctamente.'}
      else
        format.html { redirect_to !@customer.blank? ? @customer : @person_address.person, alert: 'Dirección no creada correctamente.' }
      end
    end
  end

  def update
    @person_address.update(
      person_id: params[:person_address][:person_id],
      address: params[:person_address][:address],
      geolocation_link: params[:person_address][:geolocation_link],
      latitude: params[:person_address][:latitude],
      longitude: params[:person_address][:longitude],
      postal_code: params[:person_address][:postal_code],
      city_id: params[:person_address][:city_id],
      main: params[:person_address][:main],
      active: params[:person_address][:active]
    )

    respond_to do |format|
      if @person_address.save
        format.html { redirect_to !@customer.blank? ? @customer : @person_address.person, notice: 'Dirección actualizada correctamente.' }
      else
        format.html { redirect_to !@customer.blank? ? @customer : @person_address.person, alert: 'Dirección no actualizada correctamente.' }
      end
    end
  end

  def destroy
    person = @person_address.person
    @person_address.destroy

    respond_to do |format|
      format.html { redirect_to person, notice: 'Dirección eliminada exitosamente.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_person_address
    @person_address = PersonAddress.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def person_address_params
    params.require(:person_address).permit(
      :person_id,
      :customer_id,
      :address,
      :geolocation_link,
      :latitude,
      :longitude,
      :postal_code,
      :city_id,
      :main,
      :active)
  end
  def set_customer
    if params[:person_address].present? && params[:person_address][:customer_id].present?
      @customer = Customer.find(params[:person_address][:customer_id])
    elsif params[:customer].present?
      @customer = Customer.find(params[:customer])
    else
      @customer = nil
    end
    # @customer = params[:person_address][:customer_id].present? && params[:person_address][:customer_id]!='' ? Customer.find(params[:person_address][:customer_id]) : nil
    # @customer = params[:customer].present? && !params[:customer].blank? ? Customer.find(params[:customer]) : nil
  end
end
