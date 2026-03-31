class BranchUser < ApplicationRecord

  # ------------------------------Relaciones---------------------------------------------
  belongs_to :branch
  belongs_to :user

  validates :user_id, uniqueness: { scope: :branch_id}

  scope :sorted_by_name, -> { joins(:user).order(:first_name, :last_name).includes(:user) }

  def role_name
    case
    when self.manager_role?
      "Gerente"
    when self.intermediate_role?
      "Intermedio"
    when self.basic_role?
      "Basico"
    else
      "SIN ROL"
    end
  end
end
