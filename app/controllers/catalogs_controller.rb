class CatalogsController < ApplicationController
  layout 'clean', only: [:showcase]
  skip_before_action :authenticate_user!, only: [:showcase]
  before_action :set_catalog, only: %i[ show edit update destroy showcase]


  def showcase
    @force_theme = 'light'
  end

  # GET /catalogs or /catalogs.json
  def index
    if @logged_admin
      @catalogs = Catalog.all
    else
      if @current_group.account_type_group?
        @catalogs = Catalog.where(group_id: @current_group.id)
      else
        if @current_company
          @catalogs = Catalog.where(group: @current_group, company: @current_company)
        else
          @catalogs = nil
        end
      end
    end
  end

  # GET /catalogs/1 or /catalogs/1.json
  def show
  end

  # GET /catalogs/new
  def new
    unless @current_group
      redirect_back fallback_location: root_path, alert: "Seleccione una entidad con la cual trabajar"
      return
    end
    
    @catalog = Catalog.new
    @groups = Group.all
    @companies = Company.where(active: true)
  end

  # GET /catalogs/1/edit
  def edit
    @groups = Group.all
    @companies = Company.where(active: true)
  end

  # POST /catalogs or /catalogs.json
  def create
    @catalog = Catalog.new(catalog_params)

    respond_to do |format|
      if @catalog.save
        format.html { redirect_to @catalog, notice: "El Catálogo se creó exitosamente" }
        format.json { render :show, status: :created, location: @catalog }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @catalog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /catalogs/1 or /catalogs/1.json
  def update
    respond_to do |format|
      if @catalog.update(catalog_params)
        format.html { redirect_to @catalog, notice: "El Catálogo se actualizó exitosamente" }
        format.json { render :show, status: :ok, location: @catalog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @catalog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /catalogs/1 or /catalogs/1.json
  def destroy
    @catalog.destroy!

    respond_to do |format|
      format.html { redirect_to catalogs_path, status: :see_other, notice: "El Catálogo se eliminó exitosamente" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_catalog
      @catalog = Catalog.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def catalog_params
      params.require(:catalog).permit(:name, :group_id, :company_id, :description, :image_catalog, :remove_image_catalog, 
                                       :text_color, :background_color, :background_image, :remove_background_image, :font_family)
    end
end
