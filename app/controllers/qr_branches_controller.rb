class QrBranchesController < ApplicationController
 # layout 'clean', only: [:qr_companies]
  # skip_before_action :authenticate_user!, only: [:qr_companies]
  skip_before_action :authenticate_user!, only: %i[
    new_customer_external search_person_customer query_customer
  ]

  layout 'clean', only: %i[
    new_customer_external query_customer
  ]

  before_action :set_branch, only: %i[
    all_qr_branch search_person_customer
  ]

  before_action :set_variables, only: %i[
    new_customer_external query_customer
  ]

  ######################### Este método es para QR de sucursales ######################

  def all_qr_branch
    @branch = Branch.find(params[:branch_id])
    @company = @branch.company

    #---------------------QR Catalogo ----------------
    @catalog = @branch.get_related_catalog
    if @catalog
      @url_qr_catalog = "#{request.base_url}" + showcase_catalogs_path(id: @catalog.id)
      @qr_code_catalog = RQRCode::QRCode.new(@url_qr_catalog)
      @qrcode_png_catalog = @qr_code_catalog.as_png(
        module_size: 6,
        standalone: true,
        use_path: true
      )
    end


    #-----------------------------------QR PARA REGISTRAR CLIENTES AL COMERCIO----------------------------------------
    @url_qr_branch = "#{request.base_url}" + new_customer_external_qr_branches_path(token: @branch.token).to_s
    @qrcode = RQRCode::QRCode.new(@url_qr_branch)
    @qrcode_png = @qrcode.as_png(
      module_size: 6,
      standalone: true,
      use_path: true
    )

    #-----------------------------------QR PARA CONSULTAR SALDOS----------------------------------------
    @url_query_customer = "#{request.protocol}#{request.host_with_port}" + query_customer_qr_branches_path(token: @branch.token).to_s
    @qrcode_query_customer = RQRCode::QRCode.new(@url_query_customer)
    @qrcode_png_query_customer = @qrcode_query_customer.as_png(
      module_size: 6,
      standalone: true,
      use_path: true
    )

    #-----------------------------------QR PARA CARGAR MOVIMIENTOS----------------------------------------
    @url_new_movement = "#{request.protocol}#{request.host_with_port}" + new_movement_external_path.to_s
    @qrcode_new_movement = RQRCode::QRCode.new(@url_new_movement)
    @qrcode_png_new_movement = @qrcode_new_movement.as_png(
      module_size: 6,
      standalone: true,
      use_path: true
    )
  end

  ######################### Entramos a link de registrar cliente o Asociar en un Comercio ######################

  def new_customer_external
    render 'qr_branches/new_customer_external'
  end

  #-------------------------Buscador de Person con tipo DNI por defecto ---------------------------------
  def search_person_customer

    document_number = params[:document_number].strip
    @company = @branch.company
    @person = Person.where(document_number: document_number, document_type: params[:document_type]).last
    @customer = Customer.find_by(person: @person, company: @company) if @person

    # @customer = Customer.find_by(person: @person, company: @current_company) if @person
    session[:result_person] = @person
    session[:document_number] = document_number
    @new_customer_next_enabled = true unless @customer

    @conversion = @company.today_conversion
    @discount = @company.today_discount

    respond_to do |format|
      format.turbo_stream
    end
  end

  def query_customer
    @company = @branch.company
    render 'qr_branches/query_customer'
  end

  def new_movement_external
    render 'movements/new'
  end

  private
    def set_branch
      @branch = Branch.find(params[:id] || params[:branch_id])
    end

    def set_variables
      @token = params[:token]
      @branch = Branch.find_by(token: params[:token])
      @company = @branch.company
    end
end
