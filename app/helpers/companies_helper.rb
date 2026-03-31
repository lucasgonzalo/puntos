module CompaniesHelper
  def get_badges_company(company)
    badges = ""
    badges += " <span class=\"badge text-bg-success\">Activo</span> " if company.active
    badges += " <span class=\"badge text-bg-danger\">Inactivo</span> " if !company.active
    badges.html_safe
  end
end
