module PagesHelper

  #------------------------------------DATOS Y ESTADISTICAS GENERALES------------------------------------------------
  # CANTIDAD DE CLIENTES FEMENINAS
  def get_count_femenines_customers(customers)
    customers.joins(:person).where(person: {gender: :feminine}, status: :active).count
  end

  # CANTIDAD DE CLIENTES MASCULINAS
  def get_count_masculines_customers(customers)
    customers.joins(:person).where(person: {gender: :masculine}, status: :active).count
  end

  # CANTIDAD SIN ESPECIFICAR
  def get_count_customers(customers)
    customers.where(status: :active).count
  end

  # CANTIDAD DE CLIENTES ACTIVOS DE LOS ULTIMOS 4 MESES
  def get_count_active_customers_four_months(customers)
    customers.where(status: :active).where(created_at: 3.months.ago..0.month.ago).count
  end

  # CANTIDAD DE CLIENTES INACTIVOS DE LOS ULTIMOS 4 MESES
  def get_count_inactive_customers_four_months(customers)
    customers.where.not(status: :active).where(created_at: 3.months.ago..0.month.ago).count
  end

  # CANTIDAD DE CLIENTES DORMIDOS EN LOS ULTIMOS N DIAS
  def get_count_sleep_customers(customers)
    customers.where(status: :asleep).count
  end

   # CANTIDAD DE MAIL ACTIVOS
  def get_count_active_mails(customers)
    customers.joins(person: :person_emails).where(person_emails: {active: true}).count
  end

  # CANTIDAD DE TELEFONOS ACTIVOS
  def get_count_active_phones(customers)
    customers.joins(person: :person_phones).where(person_phones: {active: true}).count
  end

  # CANTIDAD DE COMERCIOS ACTIVOS
  def get_count_active_company(company)
    # company ? company.where(active: true).count : Company.where(active: true).count
    Company.where(active: true).count
  end

  # TRANSACCION ACUMULADA DEL DIA - PUNTOS
  def get_day_points(movements)
    sale_points = movements.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, annulled: false, movement_type: :sale).sum(:points)
    exchange_points = movements.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day, annulled: false, movement_type: :exchange).sum(:points)
    sale_points - exchange_points
  end

  #----------------------------------------DATOS PERIODICOS------------------------------------------------
  # CANTIDAD DE PUNTOS OTORGADOS EN ESTE ULTIMO MES
  def get_awarded_points(movements)
    total_movement = movements.where(created_at: 1.months.ago..0.month.ago, annulled: false, movement_type: :sale).sum(:points)
    total_annulment = movements.where(created_at: 1.months.ago..0.month.ago, annulled: false, movement_type: :exchange).sum(:points)
    total_movement - total_annulment
  end

  # PROMEDIO DE TICKET MENSUAL
  def get_average_monthly_ticket(movements)
    val_points = get_awarded_points(movements)
    count = movements.where(created_at: 1.months.ago..0.month.ago).where.not(annulled: true).count
    count!=0 ? (val_points/count) : 0
  end

  # TOTAL DE FACTURACION MENSUAL
  def get_total_monthly_billing(movements)
    total_movement = movements.where(created_at: 1.months.ago..0.month.ago, annulled: false, movement_type: :sale).sum(:amount)
    total_exchange = movements.where(created_at: 1.months.ago..0.month.ago, annulled: false, movement_type: :exchange).sum(:amount)
    total_movement - total_exchange
  end

  # TOTAL DE AHORRO MENSUAL
  def get_total_monthly_savings(movements)
    total_movement = movements.where(created_at: 1.months.ago..0.month.ago, annulled: false).where(movement_type: :sale).sum(:amount_discounted)
    total_annulment = movements.where(created_at: 1.months.ago..0.month.ago, annulled: true).sum(:amount_discounted)
    total_exchange = movements.where(created_at: 1.months.ago..0.month.ago, annulled: false).where(movement_type: :exchange).sum(:amount_discounted)
    (total_movement - total_exchange)- total_annulment
  end

  # PROMEDIO DE AHORRO MENSUAL
  def get_average_monthly_savings(movements)
    total_sale = movements.where(created_at: 1.months.ago..0.month.ago, annulled: false).where(movement_type: :sale).sum(:amount_discounted)
    total_exchange = movements.where(created_at: 1.months.ago..0.month.ago, annulled: false).where(movement_type: :exchange).sum(:amount_discounted)
    count_movement = movements.where(created_at: 1.months.ago..0.month.ago, annulled: false).where(movement_type: [:sale, :exchange]).count
    total = (total_sale - total_exchange)
    count_movement!=0 ? (total/count_movement) : 0
  end

  # PROMEDIO CARGA PUNTOS MENSUAL
  def get_average_mounth_points(movements)
    count = movements.where(created_at: 1.months.ago..0.month.ago).count - movements.where(created_at: 1.months.ago..0.month.ago, annulled: true).count
    sum = movements.where(created_at: 1.months.ago..0.month.ago).sum(:points) - movements.where(created_at: 1.months.ago..0.month.ago, annulled: true).sum(:points)
    count!=0 ? (sum/count) : 0
  end

  # PROMEDIO CANJE PUNTOS MENSUAL
  def get_average_mounth_excheange_points(movements)
    sum = 0
    count = movements.where(movement_type: [:exchange_annulment, :exchange], created_at: 1.months.ago..0.month.ago).count
    movement_list = movements.where(movement_type: [:exchange_annulment, :exchange], created_at: 1.months.ago..0.month.ago)
    movement_list.each do |movement|
      multiplier = -1 if movement.movement_type_exchange_annulment?
      multiplier = 1 if movement.movement_type_exchange?
      sum += multiplier * movement.points
    end
    count!=0 ? (sum/count) : 0
  end

  # FACTURACIÓN TOTAL COMERCIOS
  def get_total_trade_billing(movements)
    total_movement = movements.where(annulled: false, movement_type: :sale).sum(:amount)
    total_exchange = movements.where(annulled: false, movement_type: :exchange).sum(:amount)
    total_movement - total_exchange
  end

  # TASA DE USO
  def get_usage_rate(customers)
    active_customers = customers.where(status: :active).count
    active_customers_four_months = customers.where(status: :active).where(created_at: 3.months.ago..0.month.ago).count
    active_customers_four_months!=0 ? active_customers/active_customers_four_months : 0
  end

  #-------------------------------------------GRAFICOS----------------------------------------------------------
  # CANTIDAD DE TRANSACCIONES EN LOS ULTIMOS 4 MESES
  def get_transaction_count(movements)
    movements.group_by_month(:created_at, format: '%b %Y', last: 4).count
  end

  # CANTIDAD DE PUNTOS OTORGADOS EN LOS ULTIMOS 4 MESES
  def get_four_mounth_awarded_points(movements)
    total_movement = movements.where(created_at: 3.months.ago..0.month.ago, annulled: false).where.not(movement_type: :exchange).sum(:points)
    total_annulment = movements.where(created_at: 3.months.ago..0.month.ago, annulled: true).sum(:points)
    total_movement - total_annulment
  end

  # CANTIDAD DE PUNTOS CANJEADOS EN LOS ULTIMOS 4 MESES
  def get_four_mounth_excheange_points(movements)
    total_exchange = movements.where(movement_type: :exchange, created_at: 3.months.ago..0.month.ago).sum(:points)
    total_annulment_exchange = movements.where(movement_type: :exchange_annulment, created_at: 3.months.ago..0.month.ago).sum(:points)
    total_exchange - total_annulment_exchange
  end

  # CANTIDAD DE TYPO DE CLIENTE
  def get_count_type_customers(customers, gender, type_customer)
    customer_of_gender = customers.where(status: :active).joins(:person).where(person: { gender: gender })

    count = 0
    customer_of_gender.each do |customer|
      age = customer.person.get_years_person
      next unless age 
      case type_customer
      when 'ninio' # rango de 0 a 13 años
        if age < 13
          count += 1
        end
      when 'adolescente' # rango de 13 a 16 años
        if age >= 13 && age < 16
          count += 1
        end
      when 'jovenes' # rango de 16 a 18 años
        if age >= 16 && age < 18
          count += 1
        end
      when 'adultos' # rango de mas de 18 años
        if age > 18
          count += 1
        end
      end
    end
    count
  end

  def get_count_type_customers(customers, gender, type_customer)
    # Build age condition based on type_customer parameter
  age_condition = case type_customer
  when 'ninio'
    "EXTRACT(YEAR FROM AGE(person.birth_date)) < 13"
  when 'adolescente'
    "EXTRACT(YEAR FROM AGE(person.birth_date)) >= 13 AND EXTRACT(YEAR FROM AGE(person.birth_date)) < 16"
  when 'jovenes'
    "EXTRACT(YEAR FROM AGE(person.birth_date)) >= 16 AND EXTRACT(YEAR FROM AGE(person.birth_date)) < 18"
  when 'adultos'
    "EXTRACT(YEAR FROM AGE(person.birth_date)) > 18"
  else
    "FALSE"
  end
  
  count = customers.where(status: :active)
    .joins(:person)
    .where(person: { gender: gender })
    .where('person.birth_date IS NOT NULL')
    .where(age_condition)
    .count

end



  # CANTIDAD DE CLIENTES DE UN COMERCIO POR ESTADOS
  def get_count_status_customers(current_company, status)

    if !current_company.blank?
      sum = current_company.customers.where(status: status).count
    else
      sum = 0
      Company.all.each do |company|
        sum += company.customers.where(status: status).count
      end
    end
    sum
  end

  # In customer.rb (or a concern/module if shared), add this class method for DB-optimized balance calculation.
# This avoids N+1 queries and Ruby-side looping for performance.
# Assumes Movement has 'movement_type' as string column; adjust if it's an enum (use integer values in CASE).
# If movement_type_*? methods are more complex, translate their logic to SQL conditions.



# TOP 10 de MEJORES CLIENTES DEL MES - REFACTORED
def get_monthly_top_ten_customers(customers, company)
  customer_ids = customers.pluck(:id) # Use pluck for efficiency if customers is a relation; or map(&:id) if array
  balances = Customer.monthly_balances(customer_ids, company)
  # Assign balances (default 0 if no movements)
  customers.each do |customer|
    customer.define_singleton_method(:monthly_balance) { balances[customer.id] || 0 }
  end
  # Sort in Ruby (fine for reasonable customer counts; if huge, consider DB sort with LEFT JOIN)
  customers.sort_by { |c| -c.monthly_balance }.first(10)
end

  # TOP 10 de MEJORES CLIENTES DEL MES
  # def get_monthly_top_ten_customers(customers, company)
  #   new_customers = customers.sort_by{|customer| -customer.get_monthly_pesos_balance_amount(company)}
  #   new_customers.slice!(0, 9)
  # end

   # TOP 10 DE MEJORES CLIENTES A NIVEL HISTORICO - REfACTORED
  def get_history_top_ten_customers(customers, company)
    customer_ids = customers.pluck(:id) # Efficient ID extraction
    balances = Customer.historical_balances(customer_ids, company)
    customers.each do |customer|
      customer.define_singleton_method(:historical_balance) { balances[customer.id] || 0 }
    end
    customers.sort_by { |c| -c.historical_balance }.first(10)
  end

  # TOP 10 DE MEJORES CLIENTES A NIVEL HISTORICO
  # def get_history_top_ten_customers(customers, company)
  #   new_customers = customers.sort_by{|customer| -customer.get_history_pesos_balance_amount(company)}
  #   new_customers.slice!(0,9)
  # end

  # TOP 1O MEJORES SUCURSALES DEL MES
  def get_monthly_top_ten_branches(company)
    new_companies = company.branches.sort_by{|branch| -branch.get_monthly_pesos_balance_amount }
    new_companies.slice!(0, 9)
  end

  # TOP 1O MEJORES SUCURSALES A NIVEL HISTORICO
  def get_history_top_ten_branches(company)
    new_companies = company.branches.sort_by{|branch| -branch.get_history_pesos_balance_amount }
    new_companies.slice!(0,9)
  end

  # TOP 10 MEJORES COMERCIOS DEL MES
  def get_monthly_top_ten_companies
    new_companies = Company.all.sort_by{ |company| -company.get_monthly_company }
    new_companies.slice!(0,9)
  end

  # TOP 10  MEJORES COMERCIOS A NIVEL HISTORICO
  def get_history_top_ten_companies
    new_companies = Company.all.sort_by{|company| -company.get_history_company}
    new_companies.slice!(0,9)
  end

  #-------------------------------------------OTROS----------------------------------------------------------
  def get_count_transaction(movements, month)
    movements.where(created_at: month.month.ago, movement_type: [:sale]).count
  end

  # CANTIDAD DE PUNTOS CANJEADOS EN ESTE ULTIMO MES
  def get_excheange_points(movements)
    sum = 0
    movement_list = movements.where(movement_type: [:exchange_annulment, :exchange], created_at: 1.months.ago..0.month.ago)
    movement_list.each do |movement|
      multiplier = -1 if movement.movement_type_exchange_annulment?
      multiplier = 1 if movement.movement_type_exchange?
      sum += multiplier * movement.points
    end
    sum
  end
end
