module PersonAddressesHelper
  def get_badges_person_address(person_address)
    badges = ""
    badges += " <span class=\"badge text-bg-success\">Activa</span> " if person_address.active
    badges += " <span class=\"badge text-bg-danger\">Inactiva</span> " if !person_address.active
    badges += " <span class=\"badge text-bg-secondary\">Principal</span> " if person_address.main
    badges.html_safe
  end
end
