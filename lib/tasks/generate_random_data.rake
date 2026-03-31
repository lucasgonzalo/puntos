
namespace :generate_random_data do
  task ejecute_method: :environment do
    puts 'Data Migration'
    require 'faker'

    # ESTO ES PARA CREAR PAISES
    (1..30).each do |i|
      puts i.to_s
      date_created = rand(10.years.ago..1.day.ago)
      country = Country.new
      country.name = Faker::Address.country
      country.created_at = date_created
      country.updated_at = date_created
      country.save
    end

    # ESTO SON PARA PROVINCIAS
    (1..30).each do |i|
      puts i.to_s
      date_created = rand(10.years.ago..1.day.ago)
      state = State.new
      state.name = Faker::Address.city
      state.country_id = Random.rand(1..Country.all.length)
      state.created_at = date_created
      state.updated_at = date_created
      state.save
    end

    # ESTO SON PARA CIUDADES
    (1..30).each do |i|
      puts i.to_s
      date_created = rand(10.years.ago..1.day.ago)
      city = City.new
      city.name = Faker::Address.state
      city.state_id = Random.rand(1..State.all.length)
      city.created_at = date_created
      city.updated_at = date_created
      city.save
    end

    # ESTO ES PARA CREAR PERSONA
    puts "CARGANDO PERSONAS----------------------------"

    (1..30).each do |i|
      puts i.to_s
      types = ['dni','cuil', 'identity_card', 'passport'].to_a
      doc_type = types[Random.rand(types.length-1)]
      date_random = rand(Date.new(1970)..Time.now.to_date)
      date_created = rand(10.years.ago..1.day.ago)

      person = Person.new
      person.first_name = Faker::Name.first_name
      person.last_name = Faker::Name.last_name
      person.document_type = doc_type
      person.document_number = Random.rand(40000000..48900234)
      person.birth_date = date_random
      person.gender = Random.rand(2) == 1 ? 'masculine' : 'feminine'
      person.created_at = date_created
      person.updated_at = date_created
      person.save
    end

    # ESTO ES PARA CREAR COMERCIOS
    puts "CARGANDO COMERCIOS----------------------------"
    (1..4).each do |i|
      puts i.to_s
      date_created = rand(10.years.ago..1.day.ago)

      company = Company.new
      company.name = Faker::Company.name
      company.user_id = 1
      company.active = Random.rand(2) == 1 ? true : false
      company.created_at = date_created
      company.updated_at = date_created
      company.save
    end

    # ESTO ES PARA CREAR CONFIGURACION
    puts "CARGANDO CONFIGURACION COMERCIOS----------------------------"
    (1..30).each do |i|
      puts i.to_s
      date_created = rand(10.years.ago..1.day.ago)
      company_random = Random.rand(1..Company.all.length)
      conversion_random = Faker::Number.between(from: 0.0, to: 1.0).round(2)
      discount_random = Faker::Number.between(from: 0.0, to: 1.0).round(2)


      (1..7).each do |i|
        company_setting = CompanySetting.new
        company_setting.day = i
        company_setting.company_id = company_random
        company_setting.conversion = conversion_random
        company_setting.discount = discount_random
        company_setting.save
      end

    end

    # ESTO ES PARA CREAR COMERCIOS
    puts "CARGANDO SUCURSAL----------------------------"
    (1..50).each do |i|
      puts i.to_s
      date_created = rand(10.years.ago..1.day.ago)
      company_random = Random.rand(1..Company.all.length)

      branch = Branch.new
      branch.company_id = company_random
      branch.name = Faker::Company.name
      branch.address = Faker::Address.street_address
      branch.city_id = Random.rand(1..City.all.length)
      branch.main = Random.rand(2) == 1 ? true : false
      branch.active = Random.rand(2) == 1 ? true : false
      branch.created_at = date_created
      branch.updated_at = date_created
      branch.save
    end


    # ESTO ES PARA CLIENTES
    puts "CARGANDO CLIENTES----------------------------"

    (1..40).each do |i|
      puts i.to_s
      person_random = Random.rand(1..Person.all.length)
      company_random = Random.rand(1..Company.all.length)
      date_random = DateTime.now - (rand * 90)
      status = ['active','inactive', 'pending'].to_a
      status_rand = status[Random.rand(status.length-1)]

      customer = Customer.new
      customer.person_id = person_random
      customer.company_id = company_random
      customer.created_at = date_random
      customer.updated_at = date_random
      customer.status = status_rand
      # customer.active = status_rand == 'active' ? true : false
      customer.save
    end


    # ESTO ES PARA CREAR MOVIMIENTOS
    puts "CARGANDO MOVIMIENTOS----------------------------"

    (1..200).each do |i|
      #puts i.to_s
      company_al = Random.rand(1..Company.all.length)
      puts "comercio" + company_al.to_s
      customer_al = Random.rand(Company.find(company_al).customers.length) if company_al!=0
      puts "cliente" + customer_al.to_json

      company_branches = Company.find(company_al).branches
      branch_al = Random.rand(company_branches.length) if company_al!=0 && !company_branches.blank?
      puts "sucursal" + branch_al.to_json
      # types = ['sale','exchange','sale_annulment','exchange_annulment'].to_a
      types_random = ['sale','exchange'].to_a
      mov_type = types_random[Random.rand(types_random.length)]
      puts mov_type.to_json
      # boolean_ann = Random.rand(2) == 1 ? true : false
      date_random = DateTime.now - (rand * 1095) # 365 por 3 = 1095 es decir 3 años atras
      puts date_random.to_json
      conversion = CompanySetting.where(company: Company.find(company_al), day: date_random.strftime('%u')).first.conversion if company_al!=0
      puts conversion.to_json
      discount = CompanySetting.where(company: Company.find(company_al), day: date_random.strftime('%u')).first.discount if company_al!=0
      puts discount.to_json
      import = Random.rand(5000)
      puts import.to_json
      # movement_rel = Random.rand(Company.find(company_al).movements.length) if company_al!=0
      if company_al!=0 && !company_branches.blank?
        movement = Movement.new
        movement.customer_id = customer_al
        movement.branch_id = branch_al
        movement.movement_type = mov_type
        movement.amount = import
        movement.created_at = date_random
        movement.updated_at = date_random
        movement.conversion = conversion
        movement.discount = discount
        movement.amount_discounted = import * (discount/100)
        movement.points = import * conversion
        movement.annulled = false
        # if boolean_ann==true
        #   movement.movement_related_id = movement_rel
        # end
        movement.save
      end

    end
  end
end
