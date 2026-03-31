class StatesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[cities select_state]
  before_action :set_state, only: %i[show edit update destroy]
  before_action :set_combos, only: %i[new create edit update]

  # GET /states or /states.json
  def index
    @states = State.all
  end

  # GET /states/1 or /states/1.json
  def show; end

  # GET /states/new
  def new
    @state = State.new
  end

  # GET /states/1/edit
  def edit; end

  # POST /states or /states.json
  def create
    @state = State.new(state_params)

    respond_to do |format|
      if @state.save
        format.html { redirect_to state_url(@state), notice: 'Provincia creada correctamente.'}
        format.json { render :show, status: :created, location: @state }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /states/1 or /states/1.json
  def update
    respond_to do |format|
      if @state.update(state_params)
        format.html { redirect_to state_url(@state), notice: 'Provincia actualizada correctamente.'}
        format.json { render :show, status: :ok, location: @state }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /states/1 or /states/1.json
  def destroy
    @state.destroy

    respond_to do |format|
      format.html { redirect_to states_url, notice: 'Provincia eliminada correctamente.' }
      format.json { head :no_content }
    end
  end

  def cities
    @target_states = params[:target_states]
    @target_cities = params[:target_cities]

    state = State.find_by_id(params[:state])
    @cities = [['Seleccione Ciudad', nil]]
    state.cities.each do |city|
      @cities << [city.name, city.id]
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  def select_state
    cities = City.where(state_id: params[:state_id])
    # respond_to do |format|
    #   format.js { render 'city_selects', locals: { cities: @cities } }
    # end
    response = cities.to_json
    respond_to do |format|
      format.json { render json: response }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_state
    @state = State.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def state_params
    params.require(:state).permit(:country_id, :name)
  end

  def set_combos
    @countries = Country.all.order(:name)
  end
end
