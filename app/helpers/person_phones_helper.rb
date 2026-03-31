module PersonPhonesHelper
  def get_badges_person_phone(person_phone)
    badges = ""
    badges += " <span class=\"badge text-bg-success\">Activa</span> " if person_phone.active
    badges += " <span class=\"badge text-bg-danger\">Inactiva</span> " if !person_phone.active
    badges += " <span class=\"badge text-bg-secondary\">Principal</span> " if person_phone.main
    badges.html_safe
  end
end
