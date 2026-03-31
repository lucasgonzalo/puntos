class Group < ApplicationRecord
  enum account_type: { group: "grupo", store: "comercio" }, _prefix: true

  has_many :company_groups, dependent: :destroy
  has_many :companies, through: :company_groups
  has_many :movements, dependent: :nullify
  has_many :group_users
  has_many :users, through: :group_users
  has_many :catalogs

  has_one_attached :image

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  default_scope { order(name: :asc) }

  attr_accessor :remove_image

  def users_names
    users.pluck(:email).join(', ')
  end

  def branch_users_from_group
    User.joins(branch_users: { branch: { company: :company_groups } })
      .where(company_groups: { group_id: self.id })
      .where(branch_users: { active: true })
      .distinct
  end

  before_save :purge_image_if_needed

  private

  def purge_image_if_needed
    image.purge if remove_image == "1"
  end
end
