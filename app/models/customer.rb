class Customer < ApplicationRecord
  include ApplicationMethods

  # ------------------------------Relaciones---------------------------------------------
  belongs_to :person
  belongs_to :company
  has_many :movements, dependent: :destroy
  has_many :agent_requests, dependent: :destroy

  enum status: { active: 'Activo', inactive: 'Inactivo', pending: 'Pendiente', asleep: 'Dormido' }, _prefix: true
  # enum :status, {:active=>"Activo", :inactive=>"Inactivo", :pending=>"Pendiente", :asleep=>"Dormido"}
  enum category: { cliente: 'CLIENTE', agente: 'AGENTE' }, _prefix: :category_is

  # ------------------------------Métodos---------------------------------------------
  def full_name
    person.full_name
  end

  def agente?
    category_agente?
  end

  def html_card
    %{
      <div class="card my-4">
        <div class="card-body">
          <div class="text-start">
            <p class="text-muted my-1 font-16">
              <strong>Cliente de #{company.name}:</strong>
              <span class="ms-2">#{active ? 'ACTIVO' : 'INACTIVO'}</span>
            </p>
          </div>
        </div>
      </div>
    }.html_safe
  end

  # RETORNA CANTIDAD DE CANJES
  def get_count_exchange(company)
    if company.active_group.account_type_group?
      self.person.get_count_exchange(company.active_group)
    else
      branches_ids = company.branches.pluck(:id)
      count_exchange = movements.where(branch_id: branches_ids, movement_type: [:exchange, :product_exchange]).count
      count_exchange_annulment = movements.where(branch_id: branches_ids, movement_type: [:exchange_annulment, :product_exchange_annulment]).count
      count_exchange.to_i-count_exchange_annulment.to_i
    end
  end

  def get_details_movement(company_element)
    if company_element.active_group.account_type_group?
      self.person.get_details_movement(company_element.active_group)
    else
      arr = []
      balance = 0
      person_saving = 0
      branches_ids = company_element.branches.pluck(:id)
      mvts = movements.where(branch_id: branches_ids).or(person.movements.where(branch_id: nil, group: company.active_group))
      unless mvts.blank?
        mvts.order(created_at: :asc).each do |movement|
          #----------------------Para cta. cte. de PUNTOS----------------------------
          multiplier = 1 if movement.credit_points_movement? #.movement_type_sale? || movement.movement_type_exchange_annulment? || movement.movement_type_group_load?
          multiplier = -1 if movement.debit_points_movement? #.movement_type_exchange? || movement.movement_type_sale_annulment? || movement.movement_type_product_exchange?
          balance += movement.points * multiplier

          #----------------------Para cta. cte. de AHORRO----------------------------
          add_value = movement.amount_discounted if movement.movement_type_sale? || movement.movement_type_sale_annulment?
          add_value = 0 if movement.movement_type_exchange? || movement.movement_type_exchange_annulment? || movement.movement_type_group_load? || movement.movement_type_product_exchange? || movement.movement_type_product_exchange_annulment?
          add_value = 0 unless add_value.present?
          person_saving += add_value * multiplier

          #-------------------------------Array----------------------------
          arr << {
            id: movement.id,
            annulled: movement.annulled,
            date_created: datetime_in_time_zone(movement.created_at),
            group_name: movement.group ? movement.group.name : '-',
            company_name: movement.branch ? movement.branch.company.name : '-',
            movement_type: movement.movement_type,
            amount: movement.amount,
            points: movement.points,
            balance: balance,
            discount: movement.discount,
            amount_discounted: movement.amount_discounted,
            person_saving: person_saving,
            total_import: movement.total_import,
            description: movement.description
          }
        end
      end
      arr.reverse
    end
  end

  def points_balance_amount(company)
    if company.active_group.account_type_group?
      self.person.points_balance_amount(company.active_group)
    else
      balance = 0
      (movements.or(person.movements.where(branch_id: nil, group: company.active_group))).each do |movement|
        multiplier = 1 if movement.credit_points_movement? #movement_type_sale? || movement.movement_type_exchange_annulment? || movement.movement_type_group_load?
        multiplier = -1 if movement.debit_points_movement? #movement_type_exchange? || movement.movement_type_sale_annulment? || movement.movement_type_product_exchange?
        balance += multiplier * movement.points
      end
      balance
    end
  end

  # Ahorro del Ultimo Mes
  def get_monthly_saving(company_element)
    if company_element.active_group.account_type_group?
      self.person.get_monthly_saving(company_element.active_group)
    else
      branches_ids = company_element.branches.pluck(:id)
      movements.where(
        created_at: 1.months.ago..0.month.ago,
        annulled: false,
        movement_type: :sale,
        branch_id: branches_ids
      ).sum(:amount_discounted)
    end
  end

  def points_monthly_balance_amount(company_element)
    points_total = 0
    if !company_element.blank?
      branches_ids = company_element.branches.pluck(:id)
      movements.where(branch_id: branches_ids, created_at: 1.months.ago..0.month.ago).each do |movement|
        multiplier = 1 if movement.credit_points_movement? #movement_type_sale? || movement.movement_type_exchange_annulment?
        multiplier = -1 if movement.debit_points_movement? #movement_type_exchange? || movement.movement_type_sale_annulment?
        points_total += multiplier * movement.points
      end
    else
      Company.all.each do |company|
        company.movements.where(created_at: 1.months.ago..0.month.ago).each do |movement|
          multiplier = 1 if movement.credit_points_movement? #movement_type_sale? || movement.movement_type_exchange_annulment?
          multiplier = -1 if movement.debit_points_movement? #movement_type_exchange? || movement.movement_type_sale_annulment?
          points_total += multiplier * movement.points
        end
      end
    end
    points_total
  end

  def points_four_last_mounth_balance_amount(company_element)
    points_total = 0
    if !company_element.blank?
      branches_ids = company_element.branches.pluck(:id)
      movements.where(branch_id: branches_ids, created_at: 3.months.ago..0.month.ago).each do |movement|
        multiplier = 1 if movement.credit_points_movement? #movement_type_sale? || movement.movement_type_exchange_annulment?
        multiplier = -1 if movement.debit_points_movement? #movement_type_exchange? || movement.movement_type_sale_annulment?
        points_total += multiplier * movement.points
      end
    else
      Company.all.each do |company|
        company.movements.where(created_at: 3.months.ago..0.month.ago).each do |movement|
          multiplier = 1 if movement.credit_points_movement? #movement_type_sale? || movement.movement_type_exchange_annulment?
          multiplier = -1 if movement.debit_points_movement? #movement_type_exchange? || movement.movement_type_sale_annulment?
          points_total += multiplier * movement.points
        end
      end
    end
    points_total
  end

  def points_day_balance_amount(company_element)
    points_total = 0
    if !company_element.blank?
      branches_ids = company_element.branches.pluck(:id)
      movements.where(branch_id: branches_ids, created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).each do |movement|
        multiplier = 1 if movement.credit_points_movement? #movement_type_sale? || movement.movement_type_exchange_annulment?
        multiplier = -1 if movement.debit_points_movement? #movement_type_exchange? || movement.movement_type_sale_annulment?
        points_total += multiplier * movement.points
      end
    else
      Company.all.each do |company|
        company.movements.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).each do |movement|
          multiplier = 1 if movement.credit_points_movement? #movement_type_sale? || movement.movement_type_exchange_annulment?
          multiplier = -1 if movement.debit_points_movement? #movement_type_exchange? || movement.movement_type_sale_annulment?
          points_total += multiplier * movement.points
        end
      end
    end
    points_total
  end


  #Este metodo calcula los movimientos // REFACTORIZACION
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

  def get_history_pesos_balance_amount(company_element)
    pesos = 0
    if !company_element.blank?
      company_branches = company.branches
      unless company_branches.blank?
        movements_list = movements.where(branch: company_branches)
        pesos += calculate_movements(movements_list)
      end
    else
      Company.all.each do |company|
        company_branches = company.branches
        unless company_branches.blank?
          movements_list = movements.where(branch: company_branches)
          pesos += calculate_movements(movements_list)
        end
      end
    end
    pesos
  end

  def get_monthly_pesos_balance_amount(company_element)
    pesos = 0
    if !company_element.blank?
      company_branches = company.branches
      unless company_branches.blank?
        month_movements = movements.where(branch: company_branches, created_at: 1.months.ago..0.month.ago)
        pesos += calculate_movements(month_movements)
      end
    else
      Company.all.each do |company|
        company_branches = company.branches
        unless company_branches.blank?
          month_movements = movements.where(branch: company_branches, created_at: 1.months.ago..0.month.ago)
          pesos += calculate_movements(month_movements)
        end
      end
    end
    pesos
  end

  def self.monthly_balances(customer_ids, company = nil)
    range = 1.month.ago..Time.current
    query = Movement.where(customer_id: customer_ids, created_at: range, annulled: false)
    if company
      branch_ids = company.branches.pluck(:id) # Preload IDs to avoid extra queries
      query = query.where(branch_id: branch_ids)
    end
    # Use string values from enum in CASE, matching movement_type column
    query.group(:customer_id).select(
      "customer_id, SUM(CASE
        WHEN movement_type IN ('Venta', 'Anulación de Canje') THEN amount
        WHEN movement_type IN ('Canje Producto', 'Canje', 'Anulación de Venta') THEN -amount
        ELSE 0  -- #group_load or any other type
      END) AS balance"
    ).map { |record| [record.customer_id, record.balance || 0] }.to_h
  end

 # New method for historical balances (no date filter)
  def self.historical_balances(customer_ids, company = nil)
    query = Movement.where(customer_id: customer_ids, annulled: false)
    if company
      branch_ids = company.branches.pluck(:id) # Preload IDs to avoid extra queries
      query = query.where(branch_id: branch_ids)
    end
    # Same CASE logic as monthly, but no created_at filter
    query.group(:customer_id).select(
      "customer_id, SUM(CASE
        WHEN movement_type IN ('Venta', 'Anulación de Canje') THEN amount
        WHEN movement_type IN ('Canje Producto', 'Canje', 'Anulación de Venta') THEN -amount
        ELSE 0
      END) AS balance"
    ).map { |record| [record.customer_id, record.balance || 0] }.to_h
  end

end
