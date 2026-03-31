class CountriesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[states select_country]
  before_action :set_country, only: %i[show edit update destroy]

  # GET /countries or /countries.json
  def index
    @countries = Country.all
  end

  # GET /countries/1 or /countries/1.json
  def show; end

  # GET /countries/new
  def new
    @country = Country.new
  end

  # GET /countries/1/edit
  def edit; end

  # POST /countries or /countries.json
  def create
    @country = Country.new(country_params)

    respond_to do |format|
      if @country.save
        format.html { redirect_to country_url(@country), notice: 'País creado correctamente.' }
        format.json { render :show, status: :created, location: @country }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /countries/1 or /countries/1.json
  def update
    respond_to do |format|
      if @country.update(country_params)
        format.html { redirect_to country_url(@country), notice: 'País actualizado correctamente.' }
        format.json { render :show, status: :ok, location: @country }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @country.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /countries/1 or /countries/1.json
  def destroy
    @country.destroy

    respond_to do |format|
      format.html { redirect_to countries_url, notice: 'País eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  def states
    @target_states = params[:target_states]
    @target_cities = params[:target_cities]

    country = Country.find_by_id(params[:country])
    @states = [['Seleccione Provincia', nil]]
    country.states.each do |state|
      @states << [state.name, state.id]
    end

    respond_to do |format|
      format.turbo_stream
    end
  end


  def select_country
    states = State.where(country_id: params[:country_id])
    # @states = State.where(country_id: params[:country_id])
    # respond_to do |format|
    #   format.js { render 'state_selects', locals: { states: @states } }
    # end
    response = states.to_json
    respond_to do |format|
      format.json { render json: response }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_country
    @country = Country.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def country_params
    params.require(:country).permit(:name)
  end
end
