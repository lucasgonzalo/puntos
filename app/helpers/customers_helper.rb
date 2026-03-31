module CustomersHelper
  def get_badges_customer(customer)
    badges = " "
    badges += " <span class=\"badge text-bg-success\">Activo</span> " if customer.status_active?
    badges += " <span class=\"badge text-bg-info\">Pendiente</span> " if customer.status_pending?
    badges += " <span class=\"badge text-bg-danger\">Inactivo</span> " if customer.status_inactive?
    badges += " <span class=\"badge text-bg-secondary\">Dormido</span> " if customer.status_asleep?

    badges.html_safe
  end
end
