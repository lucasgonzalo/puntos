class Company < ApplicationRecord
  attr_accessor :group_id

  # ------------------------------Relaciones---------------------------------------------
  has_one_attached :image_company do |attachable|
    attachable.variant :thumb, resize_to_limit: [377, 134]
  end

  belongs_to :user

  has_many :branches, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :people, through: :customers
  has_many :movements, through: :branches
  has_many :company_settings, dependent: :destroy
  has_many :alerts, dependent: :destroy
  has_many :agent_requests, dependent: :destroy
  has_many :company_groups, dependent: :destroy
  has_many :groups, through: :company_groups


  validates :name, presence: true, length: {minimum: 3}

  default_scope { order(:name) }

  after_commit :generate_token_to_company, on: [:create]

  # ------------------------------Métodos---------------------------------------------
  def full_name
    if Company.where(name: name).count > 1
      "#{name} - #{active_group.name}"
    else
      "#{name}"
    end
  end

  def self.from_group(group)
    # Ensure the parameter is a Group object or group_id
    group_id = group.is_a?(Group) ? group.id : group

    # Query the join table and return unique companies
    joins(:company_groups).where(company_groups: { group_id: group_id }).distinct
  end

  def active_group
    # Cambiar en caso de permitir el muchos a muchos
    self.company_groups.any? ? self.company_groups.first.group : nil
  end

  def generate_token_to_company
    code = SecureRandom.base64(6)
    while Company.exists?(token: code)
      code = SecureRandom.base64(6)
    end
    self.token = code
    self.save
  end

  def generate_qr_code(checkin_url)
    qrcode = RQRCode::QRCode.new(checkin_url)
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 120
    )
  end

  # ESTE ES PARA VER LOS PUNTOS GANADOS DE UN COMERCIO
  def get_balance_movements
    sum = 0
    unless branches.blank?
      branches.each do |branch|
        unless branch.movements.blank?
          branch.movements.each do |movement|
            multiplier = 1 if movement.movement_type_sale? || movement.movement_type_exchange_annulment?
            multiplier = -1 if movement.movement_type_exchange? || movement.movement_type_sale_annulment?
            sum += multiplier * movement.amount
          end
        end
      end
    end
    sum
  end

  #  Este metodo calcula los movimientos // REFACTORIZACION
  def calculate_movements(movements_list)
    pesos = 0
    unless movements_list.blank?
      movements_list.each do |movement|
        multiplier = 1 if movement.credit_points_movement? # movement.movement_type_sale? || movement.movement_type_exchange_annulment?
        multiplier = -1 if movement.debit_points_movement? # movement.movement_type_exchange? || movement.movement_type_sale_annulment? || movement.movement_type_product_exchange?
        pesos += multiplier * movement.amount
      end
    end
    pesos
  end

  def get_history_company
    pesos = 0
    pesos += calculate_movements(movements) unless movements.blank?
    pesos
  end

  def get_monthly_company
    pesos = 0
    unless movements.blank?
      movements_list = movements.where(created_at: 1.months.ago..0.month.ago)
      pesos += calculate_movements(movements_list)
    end
    pesos
  end

  def today_discount
    company_setting = company_settings.find_by(day: Time.now.strftime('%u'))
    company_setting ? company_setting.discount : 0
  end

  def today_conversion
    company_setting = company_settings.find_by(day: Time.now.strftime('%u'))
    company_setting ? company_setting.conversion : 0
  end


  def execute_daily_task
    #------------------Cambiamos de estado activo a dormido a los clientes de los comercios---------------------
    days_sleep = self.days_sleep.to_i
    self.customers.each do |customer|
      last_movement_date = customer.movements.last.created_at.to_date
      today_date = Date.today
      mov_more_day = last_movement_date + days_sleep
      if(mov_more_day >= today_date)
        customer.status = :asleep
        customer.save!
      end
    end
  end

  def branch_names
    self.branches.pluck(:name).join(', ')
  end


  def count_alerts
    Alert.where(company: self).count
  end

  def count_alerts_read
    Alert.where(company: self, status: :read).count
  end

  def count_alerts_not_read
    Alert.where(company: self, status: :not_read).count
  end


end
