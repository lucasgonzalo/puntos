module PersonEmailsHelper
  def get_badges_person_email(person_email)
    badges = ""
    badges += " <span class=\"badge text-bg-success\">Activa</span> " if person_email.active
    badges += " <span class=\"badge text-bg-danger\">Inactiva</span> " if !person_email.active
    badges += " <span class=\"badge text-bg-secondary\">Principal</span> " if person_email.main
    badges += " <span class=\"badge text-bg-warning\">Validado</span> " if person_email.validated_at
    badges += " <span class=\"badge text-bg-light\">No Validado</span> " unless person_email.validated_at
    badges.html_safe
  end
end
