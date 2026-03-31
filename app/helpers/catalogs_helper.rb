module CatalogsHelper
  # Return a CSS font-family stack for a simple font key.
  # Keys are human-friendly (e.g. 'Inter', 'Montserrat').
  def font_family_stack(key)
    stacks = {
      'Inter' => "Inter, system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif",
      'Montserrat' => "Montserrat, system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif",
      'Lora' => "Lora, Georgia, 'Times New Roman', Times, serif",
      'Roboto' => "Roboto, system-ui, -apple-system, 'Segoe UI', Arial, sans-serif",
      'Open Sans' => "'Open Sans', system-ui, -apple-system, 'Segoe UI', Arial, sans-serif",
      'Poppins' => "Poppins, system-ui, -apple-system, 'Segoe UI', Arial, sans-serif",
      'Merriweather' => "Merriweather, Georgia, serif",
      'Playfair Display' => "'Playfair Display', Georgia, serif",
      'Raleway' => "Raleway, system-ui, -apple-system, 'Segoe UI', Arial, sans-serif",
      'Source Sans Pro' => "'Source Sans Pro', system-ui, -apple-system, 'Segoe UI', Arial, sans-serif",
      'Nunito' => "Nunito, system-ui, -apple-system, 'Segoe UI', Arial, sans-serif",
      'Oswald' => "Oswald, system-ui, -apple-system, 'Segoe UI', Arial, sans-serif",
      'Abril Fatface' => "'Abril Fatface', Georgia, serif",
      'Asimovian' => "Asimovian, Montserrat, system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif",
      'Comic Relief' => "Comic Relief, Montserrat, system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif"
    }

    stacks[key.to_s]
  end
end
