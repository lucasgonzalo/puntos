module MovementsHelper
  def get_badges_movement_type(movement)
    badges = ""
    badges += " <span class=\"badge text-bg-success\">Venta</span> " if movement.movement_type_sale?
    badges += " <span class=\"badge text-bg-danger\">Canje</span> " if movement.movement_type_exchange?
    badges += " <span class=\"badge text-bg-danger\">Canje Catalogo</span> " if movement.movement_type_product_exchange?
    badges += " <span class=\"badge text-bg-info\">Anulación de Venta </span> " if movement.movement_type_sale_annulment?
    badges += " <span class=\"badge text-bg-info\">Anulación de Canje </span> " if movement.movement_type_exchange_annulment?
    badges += " <span class=\"badge text-bg-info\">Anulación de Canje Catalogo </span> " if movement.movement_type_product_exchange_annulment?
    badges += " <span class=\"badge text-bg-success\">Carga de Entidad </span> " if movement.movement_type_group_load?

    badges.html_safe
  end

  def get_badges_movement_type_hash(movement)
    badges = ""
    badges += " <span class=\"badge text-bg-success\">Venta</span> " if movement[:movement_type]=="sale"
    badges += " <span class=\"badge text-bg-danger\">Canje</span> " if movement[:movement_type]=="exchange"
    badges += " <span class=\"badge text-bg-danger\">Canje Catalogo</span> " if movement[:movement_type]=="product_exchange"
    badges += " <span class=\"badge text-bg-info\">Anulación de Venta </span> " if movement[:movement_type]=="sale_annulment"
    badges += " <span class=\"badge text-bg-info\">Anulación de Canje </span> " if movement[:movement_type]=="exchange_annulment"
    badges += " <span class=\"badge text-bg-info\">Anulación de Canje Catalogo</span> " if movement[:movement_type]=="product_exchange_annulment"
    badges += " <span class=\"badge text-bg-success\">Carga desde Entidad </span> " if movement[:movement_type]=="group_load"

    badges.html_safe
  end

  def get_card_header(title)
    text = ''
    text += '<td>'
    text += '<p class="m-0 d-inline-block align-middle">'
    text += '<a href="apps-ecommerce-products-details.html" class="text-body fw-semibold">'+ title + '</a>'
    text += '<br>'
    text += '</p>'
    text += '</td>'
    text.html_safe
  end

  # def branch_field_form(form, company, branch)
  #   if !branch.blank?
  #     content_tag(:div, class: 'col-sm-8') do
  #       form.hidden_field(:branch_id, value: branch.id, data: { branch_settings_target: "branchValue", action: "keyup->branch_settings#validation_method" }) +
  #       form.text_field(:branch_id, class: 'form-control', value: branch.name, disabled: true)
  #     end
  #   else
  #     content_tag(:div, class: 'col-sm-8') do
  #       form.collection_select(:branch_id, company.branches, :id, :name, { prompt: "Seleccione una Sucursal" }, {
  #         class: "form-select", data: { branch_settings_target: "branchValue", action: "keyup->branch_settings#validation_method" }
  #       })
  #     end
  #   end
  # end

end
