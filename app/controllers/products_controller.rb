class ProductsController < ApplicationController
  before_action :set_catalog
  before_action :set_product, only: %i[show edit update destroy]


  def show
  end

  def new
    @product = @catalog.products.new
  end

  def create
     @product = Product.new(product_params)
    if @product.save
      CatalogProduct.create!(catalog: @catalog, product: @product)
      redirect_to catalog_path(@catalog), notice: 'Producto agregado correctamente.'
    else
       flash.now[:alert] = 'Por favor, corrige los errores de validación:'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to catalog_path(@catalog), notice: 'Producto actualizado correctamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to catalog_path(@catalog), notice: 'Producto eliminado correctamente.'
  end

  def toggle_active
    @product = Product.find(params[:id])
    @catalog = Catalog.find_by(id: params[:catalog_id])
    new_active_state = params[:active] == 'true'
    if @product.update(active: new_active_state)
      render partial: 'active_cell', locals: { product: @product }
    else
      render status: :unprocessable_entity, html: "Error updating product: #{@product.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_catalog
    @catalog = Catalog.find(params[:catalog_id])
  end

  def set_product
    @product = @catalog.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :image, :product_type, :points)
  end
end