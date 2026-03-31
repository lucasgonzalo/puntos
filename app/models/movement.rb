class Movement < ApplicationRecord
  include ApplicationMethods
  include ActionView::Helpers::NumberHelper

  enum movement_type: {
    sale: 'Venta', # Incrementa puntos
    exchange: 'Canje', # Decrementa puntos (Se usa en la venta con canje que genera movimiento de venta y movimiento de canje) - Solo se genera en venta con canje
    product_exchange: 'Canje Producto', # Decrementa puntos
    group_load: 'Carga desde Entidad', # Incrementa puntos
    sale_annulment: 'Anulación de Venta', # Decrementa puntos
    exchange_annulment: 'Anulación de Canje', # Incrementa puntos
    product_exchange_annulment: 'Anulación de Canje Producto' # Incrementa puntos
  }, _prefix: true

  belongs_to :customer, optional: true
  belongs_to :person, optional: true
  belongs_to :branch, optional: true
  belongs_to :group, optional: true
  belongs_to :user, optional: true
  has_one :company, through: :branch
  has_many :movement_related, class_name: 'Movement', foreign_key: 'movement_related_id', dependent: :destroy

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  

  # after_save :change_points_discount

  # def change_points_discount
  #   return unless movement_type_exchange?

  #   self.amount = 0
  #   self.amount_discounted = 0
  # end

  before_create :save_person
  def save_person
    # Set person_id if it's not already set and the customer exists
    self.person_id ||= customer.person_id if customer
  end

  before_create :save_group
  def save_group
    self.group_id ||= customer.company.active_group.id if customer
  end

  after_commit :trigger_alerts, on: [:create]

  def trigger_alerts
    # check configuration
    qty_movements = self.branch.alert_qty_movements
    qty_days = self.branch.alert_days
    limit_amount = self.branch.alert_amount

    category = :sales if movement_type_sale?
    category = :exchanges if movement_type_exchange?

    # ---------- Estas son alertas en base a movimientos------------
    if (!qty_movements.blank? && !qty_days.blank?)
      to_date = Time.now
      from_date = to_date - qty_days.days
      if category.in?([:sales, :exchanges])
        movements = Movement.where(customer: self.customer, branch: self.branch, created_at: from_date..to_date)
        if movements.count > qty_movements
          BranchAlert.create!(
            branch: self.branch,
            category: category,
            status: :not_read,
            content: "Cantidad de movimientos sospechosos: #{movements.count} - Monto: #{self.amount} - Fecha/Hora: #{datetime_in_time_zone(self.created_at)} - Cliente #{self.customer.full_name}",
            link: "/movements/#{self.id}"
          )
        end
      end
    end

    # ---------- Estas son alertas en base a montos------------
    if (!limit_amount.blank?)
      if category.in?([:sales, :exchanges])
        if(self.amount > limit_amount)
          BranchAlert.create!(
            branch: self.branch,
            category: category,
            status: :not_read,
            content: "Movimiento mayor a #{limit_amount} > Monto: #{self.amount} - Fecha/Hora: #{datetime_in_time_zone(self.created_at)} - Cliente #{self.customer.full_name}",
            link: "/movements/#{id}"
          )
        end
      end
    end
  end

  def formatted_date_created
    created_at&.strftime('%d/%m/%Y - %H:%M')
  end

  def first_non_annulled_of_customer?
    bool = false
    first_mov = customer.movements.order(created_at: :desc).where(annulled: false, movement_related_id: nil).first
    bool = true if first_mov == self
    bool
  end

  def can_be_annulled?
    # Por ejemplo, podrías verificar si ha pasado más de 24 horas desde la creación. cambiar uno, por 24
    more_hours_movement = self.created_at + 24.hours
    current_time = Time.now
    current_time < more_hours_movement
  end

  def credit_points_movement?
    %i[sale group_load exchange_annulment product_exchange_annulment ].include?(self.movement_type.to_sym)
  end

  def debit_points_movement?
    %i[exchange product_exchange sale_annulment].include?(self.movement_type.to_sym)
  end

  def annulment_movement?
    %i[sale_annulment exchange_annulment product_exchange_annulment].include?(self.movement_type.to_sym)
  end

  def self.movement_type_label_for(key)
    labels = {
      sale: 'Venta',
      exchange: 'Canje',
      product_exchange: 'Canje Catalogo',  # Custom display
      group_load: 'Carga desde Entidad',
      sale_annulment: 'Anulación de Venta',
      exchange_annulment: 'Anulación de Canje',
      product_exchange_annulment: 'Anulación de Canje Catalogo'  # Custom display
    }
    labels[key.to_sym] || key.to_s.humanize  # Fallback if key missing
  end

  def mail_description(points, points_available)
    msg = ''
    msg = "Has sumado <b>#{number_with_delimiter(points.to_i, delimiter: '.')}</b> puntos a tu cuenta." if points > 0
    msg += "<br>Tenés <b> #{ number_with_delimiter(points_available.to_i, delimiter: '.')}</b> puntos disponibles para canjear." if points_available > 0
    msg.html_safe
  end


end
