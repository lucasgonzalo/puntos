module BranchUsersHelper
  def get_badges_branch_user(branch_user)
    badges = ""
    badges += " <span class='badge text-bg-success'>Activo</span> " if branch_user.active
    badges += " <span class='badge text-bg-danger'>Inactivo</span> " unless branch_user.active
    badges += " <span class='badge text-bg-warning'>Gerente</span> " if branch_user.manager_role?
    badges += " <span class='badge text-bg-info'>Supervisor</span> " if branch_user.intermediate_role?
    badges += " <span class='badge text-bg-secondary'>Basico</span> " if branch_user.basic_role?
    badges.html_safe
  end

  def get_role_branch_user(branch_user)
    badges = ""
    badges += " <span class='badge text-bg-warning'>Gerente Sucursal</span> " if branch_user.manager_role?
    badges += " <span class='badge text-bg-info'>Supervisor</span> " if branch_user.intermediate_role?
    badges += " <span class='badge text-bg-secondary'>Basico</span> " if branch_user.basic_role?
    badges.html_safe
  end

  def get_active_branch_user(branch_user)
    badges = ""
    badges += " <span class='badge text-bg-success'>Activo</span> " if branch_user.active
    badges += " <span class='badge text-bg-danger'>Inactivo</span> " unless branch_user.active
    badges.html_safe
  end


  def get_cond_branches(company, condition_branch)
    company_branches = company.branches
    if !condition_branch.blank?
      company_branches = company_branches.where(id: condition_branch.to_i)
    end
    company_branches
  end

  def get_cond_branch_user(branch, condition_active, condition_role)
    branch_users = branch.branch_users
    #-------------------------Condicion de usuarios activos-----------------------------
    if !condition_active.blank?
      val_condition_active = condition_active == "active" ? true : false
      branch_users = branch.branch_users.where(active: val_condition_active)
    end

    #-------------------------Condicion de roles de usuarios-----------------------------
    if !condition_role.blank?
      branch_users = case condition_role
      when "manager_role"
          branch_users.where(manager_role: true)
      when "intermediate_role"
          branch_users.where(intermediate_role: true)
      when "basic_role"
          branch_users.where(basic_role: true)
      else
          branch_users
      end
    end
    #-------------------------Retornamos usuarios-----------------------------
    branch_users
  end
end
