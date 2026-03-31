require 'rqrcode'
require 'prawn'
require 'stringio'


class GenerateQrPdf < Prawn::Document
  def initialize(url_qr_company, company, qr_png)
    super(top_margin: 35, left_margin: 20)
    @url_qr_company = url_qr_company
    @company = company
    @qr_png = qr_png
    generate_pdf_content
  end

  def generate_pdf_content
    image_height = 50 # Altura deseada de la imagen
    image_width = 50 # Ancho deseado de la imagen
    image_data = @company.image_company.download
    x_position = (bounds.width - image_width) / 2

    image StringIO.new(image_data), alt: "",   width: image_width, height: image_height, at: [x_position, cursor]  if !image_data.blank?

    move_down 90

    text @company.name, align: :center, size: 50

    move_down 20
    # Obtener las dimensiones de la imagen
    image_width = 500
    image_height = 500

    # Calcular las coordenadas X e Y para centrar la imagen
    x_position = (bounds.width - image_width) / 2

    # Insertar la imagen centrada
    image StringIO.new(@qr_png.to_s), width: image_width, height: image_height, at: [x_position, cursor]
  end

end
