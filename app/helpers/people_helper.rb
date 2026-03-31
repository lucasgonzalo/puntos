module PeopleHelper
  def get_badges_person(person)
    badges = ""
    # badges += " <span class=\"badge badge-success-lighten\">Activo</span> " if person.active
    # badges += " <span class=\"badge badge-danger-lighten\">Inactivo</span> " if !person.active
    badges.html_safe
  end

  def get_badges_status_person(person)
    badges = ""
    # badges += " <span class=\"badge badge-success-lighten\">Correcto</span> " if person.status == 'correct'
    # badges += " <span class=\"badge badge-info-lighten\">Duplicado </span> " if person.status == 'duplicated'
    # badges += " <span class=\"badge badge-danger-lighten\">Triplicado</span> " if person.status == 'triplicated'
    badges.html_safe
  end
end
