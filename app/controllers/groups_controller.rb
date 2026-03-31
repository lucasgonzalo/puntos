class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy ]

  def show; end

  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit; end

  # POST /groups or /groups.json

  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to group_url(@group), notice: 'Entidad creada correctamente.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to group_url(@group), notice: 'Entidad actualizada correctamente.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Entidad eliminada correctamente.' }
      format.json { head :no_content }
    end
  end

  def index
    @groups = Group.all
  end



  # GET /movements/new
  def new_movement
    @movement = Movement.new
    @group = @current_group
    @person = Person.find(params[:person])
  end

  # POST /movements or /movements.json
  def create_movement

    @error = false
    @message = nil

    begin
      person = Person.find(params[:movement][:person_id].to_i)
      movement_type = params[:movement][:movement_type]

      # Puntos a acumular
      add_points = params[:movement][:points].to_i

      # Puntos disponible de la Persona
      available_points = person.points_balance_amount(@current_group)

      # TODO: Envio de mail de carga de puntos
      email_error = false

      # ----------------------CREAMOS UN MOVIMIENTO PARA LA CARGA--------------------
      movement = Movement.new(

        movement_type: movement_type,
        amount: 0,
        amount_discounted: 0,
        points: params[:movement][:points].presence || 0,
        conversion: 1,
        discount: 0,
        total_import: 0
      )
      movement.customer = nil
      movement.branch = nil
      movement.person = person
      movement.group = @current_group
      Movement.skip_callback(:commit, :after, :trigger_alerts)
      if !movement.save
        @error = true
        @message = 'Error al guardar: ' + movement.errors.to_json
      end
      Movement.set_callback(:commit, :after, :trigger_alerts)
    rescue ActiveRecord::RecordNotFound => e
      @error = true
      @message = 'Registro no encontrado: ' + e.message
    rescue StandardError => e
      @error = true
      @message = 'Ha ocurrido un error: ' + e.message
    ensure

      respond_to do |format|
        if @error
          format.html { redirect_to new_group_movement_path(person: person.id), alert: @message }
        else
          notice_message = 'Movimiento creado exitosamente.'
          notice_message += ' Sin embargo, no se pudo enviar el correo de confirmación.' if email_error
          format.html { redirect_to person_balance_path(id: person), notice: notice_message }
        end
      end
    end
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:name, :description, :image, :remove_image, :account_type)
  end
end
