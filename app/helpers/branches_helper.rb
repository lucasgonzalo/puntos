module BranchesHelper
  def get_badges_branch(branch)
    badges = ""
    badges += " <span class=\"badge text-bg-success\">Activa</span> " if branch.active
    badges += " <span class=\"badge text-bg-danger\">Inactiva</span> " if !branch.active
    badges += " <span class=\"badge text-bg-secondary\">Principal</span> " if branch.main
    badges.html_safe
  end
end
