module ApplicationHelper
  include ApplicationMethods
  
  def set_page_title(title = nil)
    return unless title

    content_for :page_title, "Puntos al Toque - #{title}"
    content_for :content_title, title
  end

  def default_checkbox(form)
    form.object.persisted? ? form.object.active : true
  end

  def google_fonts_url
    # ToDo Review catalogs_helper to unify everything
    fonts = [
      { name: 'Inter', weights: [400, 600, 700] },
      { name: 'Montserrat', weights: [400, 600, 700] },
      { name: 'Lora', weights: [400, 700] },
      { name: 'Roboto', weights: [400, 700] },
      { name: 'Open Sans', weights: [400, 700] },
      { name: 'Poppins', weights: [400, 700] },
      { name: 'Merriweather', weights: [400, 700] },
      { name: 'Playfair Display', weights: [400, 700] },
      { name: 'Raleway', weights: [400, 700] },
      { name: 'Source Sans 3', weights: [400, 700] },
      { name: 'Nunito', weights: [400, 700] },
      { name: 'Oswald', weights: [400, 700] },
      { name: 'Abril Fatface', weights: [400] },
      { name: 'Asimovian', weights: [400,600,700] },
      { name: 'Comic Relief', weights: [400] },
      
    ]

    # Build the Google Fonts URL
    font_params = fonts.map do |font|
      weights = font[:weights].join(';')
      font_name = font[:name].gsub(' ', '+')
      "#{font_name}:wght@#{weights}"
    end.join('&family=')

    "https://fonts.googleapis.com/css2?family=#{font_params}&display=swap"
  end

  def tmp_pdfs_size
    folder = Rails.root.join('tmp', 'pdfs')
    return 0 unless Dir.exist?(folder)
    Dir.glob(folder.join('*.pdf')).sum { |file| File.size(file) } / (1024.0 * 1024.0) # Size in MB
  end
end
