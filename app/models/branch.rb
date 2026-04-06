class Branch < ApplicationRecord

  # ------------------------------Relaciones---------------------------------------------
  has_one_attached :image_branch do |attachable|
    attachable.variant :thumb, resize_to_limit: [377, 134]
  end

  has_one_attached :email_image_branch do |attachable|
    attachable.variant :thumb, resize_to_limit: [377, 134]
  end

  belongs_to :company
  belongs_to :city
  has_many :movements, dependent: :destroy
  has_many :branch_users
  has_many :users, through: :branch_users

  has_many :branch_settings, dependent: :destroy
  has_many :branch_alerts, dependent: :destroy
  has_many :agent_requests, dependent: :destroy

  validates :name, presence: true, length: { minimum: 3 }
  validates :name, uniqueness: { scope: :company, case_sensitive: false }
  validates :address, presence: true, length: { minimum: 3 }
  scope :main_ordered, -> { order(main: :desc).order(:name) }

  before_save :check_main

  after_commit :generate_token_to_branch, on: [:create]

  # ------------------------------Metodos---------------------------------------------
  def check_main
    return unless main?

    company.branches.where(main: true).each do |branch|
      if branch != self
        branch.main = false
        branch.save!
      end
    end
  end

  # Este metodo calcula los movimientos // REFACTORIZACION
  def calculate_movements(movements_list)
    pesos = 0
    unless movements_list.blank?
      movements_list.each do |movement|
        multiplier = 1 if movement.credit_points_movement? #movement_type_sale? || movement.movement_type_exchange_annulment?
        multiplier = -1 if movement.debit_points_movement? #movement_type_exchange? || movement.movement_type_sale_annulment? || movement.movement_type_product_exchange?
        pesos += multiplier * movement.amount
      end
    end
    pesos
  end

  def get_history_pesos_balance_amount
    pesos = 0
    pesos += calculate_movements(movements) unless movements.blank?
    pesos
  end

  def get_monthly_pesos_balance_amount
    pesos = 0
    unless movements.blank?
      movements_list = movements.where(created_at: 1.months.ago..0.month.ago)
      pesos += calculate_movements(movements_list)
    end
    pesos
  end

  def generate_token_to_branch
    code = SecureRandom.base64(6)
    while Company.exists?(token: code)
      code = SecureRandom.base64(6)
    end
    self.token = code
    self.save
  end

  # ------------------------------Aqui saco descuento y conversion del dia de HOY ---------------------------------------------
  def today_discount
    branch_setting = branch_settings.find_by(day: Time.now.strftime('%u'))
    branch_setting ? branch_setting.discount : 0
  end

  def today_conversion
    branch_setting = branch_settings.find_by(day: Time.now.strftime('%u'))
    branch_setting ? branch_setting.conversion : 0
  end

   def today_conversion_agent
    branch_setting = branch_settings.find_by(day: Time.now.strftime('%u'))
    branch_setting ? branch_setting.conversion_agent : 0
  end


  def count_branch_alerts
    BranchAlert.where(branch: self).count
  end

  def count_branch_alerts_read
    BranchAlert.where(branch: self, status: :read).count
  end

  def count_branch_alerts_not_read
    BranchAlert.where(branch: self, status: :not_read).count
  end

  def get_related_catalog
    group = self.company.active_group
    if group.account_type_group?
      catalog = Catalog.where(group: group).last
    else
      catalog = Catalog.where(group: group, company: company).last
    end
    catalog
  end


end
