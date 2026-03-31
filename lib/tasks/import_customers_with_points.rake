namespace :excel_import do
  desc 'Import customers from an Excel file with their points'
  #This task will recive a file(inside this repo and will update all the customers with their points)
  # Las personas seran creadas si no existen, debe existir una empresa a la que sera realcionado, y una branch a la que le seran asignados los puntos

  task import_customers: :environment do
    2.times{puts}
    puts "### Importing customers from excel, task started.###"
    branch_id = 36 # Branch where points will be assigned(SUC 20 migracion)
    branch = Branch.find(branch_id)
    company = branch.company
    puts "Branch: #{branch.name} of Company: #{company.name}"
    puts "Using branch_id=#{branch_id} and company_id=#{company.id}"

    file_name = "lib/tasks/files/clientes(fidely-1-nov-2025)-faltantes-aguaray.xlsx"

    begin
      xlsx = Roo::Spreadsheet.open(file_name)
      # puts xlsx.info
      missing_rows = [] # {index: , id: , reason: "", puntos: }  # Rows that were not migrated by missing data
      customers_created = 0
      persons_created = 0
      movements_created = 0
      # Calculate total data rows (excluding header)
      total_rows = xlsx.last_row - 1
      puts "Total data rows (excluding header): #{total_rows}"
      headers = xlsx.row(1) # get header row (column names)

      # Load all data rows (excluding header) into an array of hashes
      data_rows = []
      xlsx.each_with_index.drop(1).each do |row, idx|
        item_data = Hash[[headers, row].transpose]
        data_rows << item_data
      end

      # Sort data by ID (converting to integer for numerical sorting)
      sorted_rows = data_rows.sort_by { |row| row["ID"]&.to_i || 0 }
      current_row = 1 # To track progress

      # Procesamiento de cada fila
      sorted_rows.each_with_index do |item_data, idx|
        begin
          print "Procesando fila #{current_row}  de  #{total_rows}  \r"
          $stdout.flush
          current_row += 1
          error_msg = ""
          error_row = false

          # Response item_data example:{"ID":53165,"Nombre":" josé darío","Apellido":"García","Documento":"33668865","Fecha Nacimiento":"","Genero":"H","Email":"silvyaquinto@gmail.com","Telefono":"543873683068","Tipo Cliente":"Member","Puntos":13940.74,"Puntos Pesos":13940.74,"Nro. Tarjeta":"","Fecha Alta":"2023-02-27 13:35:07","Más Datos":null}

          # Validate required fields
          error_msg += "Falta Nombre" if item_data["Nombre"].blank?
          error_msg += ",Falta Apellido" if item_data["Apellido"].blank?
          error_msg += ",Falta Documento" if item_data["Documento"].blank?
          error_msg += "Falta Genero" if item_data["Genero"].blank?
          error_msg += ",Falta Email" if item_data["Email"].blank? # Hay 106 registros sin email
          if Person.find_by(document_number: item_data["Documento"].to_s&.strip).present?
            error_msg += ",Ya existe persona con este documento"
            puts "Ya existe persona con este documento: #{item_data['Documento']}, id: #{item_data['ID']}"
          end
          # error_msg += "Falta ID. " if item_data["ID"].blank?
          # error_msg += ",Falta Telefono. " if item_data["Telefono"].blank?
          # error_msg += ",Falta Puntos. " if item_data["Puntos"].blank?
          # error_msg += ",Falta Fecha Alta. " if item_data["Fecha Alta"].blank? 
          # error_msg += ",Falta Fecha Nacimiento. " if item_data["Fecha Nacimiento"].blank? # La fecha de nac se colocara con un valor muy alto, ej 1900-01-01
          
          if error_msg.present?
            error_row = true
            missing_rows << {index: idx, id: item_data["ID"], reason: error_msg, puntos: item_data["Puntos"] }
          end

          unless error_row
            ActiveRecord::Base.transaction do

              # Parse birth_date (YYYY-MM-DD to Date)
              birth_date = parse_date(item_data["Fecha Nacimiento"]) || Date.new(1900, 1, 1)
              # Parse old_created_at (YYYY-MM-DD HH:MM:SS to DateTime)
              old_created_at = parse_datetime(item_data["Fecha Alta"])

              email = item_data["Email"].to_s.strip # se presupone que no es nulo

              phone_number = item_data["Telefono"].to_s.strip
              phone_number = nil if phone_number.blank?

              gender = item_data["Genero"].to_s.strip # se presupone que no es nulo
              case gender.upcase
              when 'H'
                gender = :masculine
              when 'M'
                gender = :masculine
              when 'F'
                gender = :feminine
              end

              card_number = item_data["Nro. Tarjeta"].to_s.strip
              card_number = nil if card_number.blank?

              # Process Puntos: truncate to integer, nil if 0 or invalid
              puntos = item_data["Puntos"].to_s.strip
              puntos = puntos.to_i if puntos&.match?(/\A-?\d+(\.\d+)?\z/)
              puntos = nil if puntos.nil? || puntos.zero?

              # Inserts:
              person =  Person.new(
                first_name:  item_data["Nombre"],
                last_name: item_data["Apellido"],
                document_type: :dni,
                document_number: item_data["Documento"],
                birth_date: birth_date,
                gender: gender,
                old_id: item_data["ID"].to_i,
                card_number: card_number,
                old_created_at: old_created_at
              )
              person.save!
              persons_created += 1
              # puts "-------------------CREADA----------------------" if person.save!
              # puts person.to_json

              if email.present?
                person_email = PersonEmail.new(
                  person: person,
                  email: email,
                  main: true,
                  active: true
                )
                person_email.save!
                # puts "-------------------EMAIL CREADO----------------------" if person_email.save!
              end

              if phone_number.present?
                person_phone = PersonPhone.new(
                  person: person,
                  phone_number: phone_number,
                  main: true,
                  active: true
                )
                person_phone.save!
                # puts "-------------------TELEFONO CREADO----------------------" if person_phone.save!
              end

              #----------- Verificamos si la persona es cliente del comercio, sino la creamos-------------------
              customer = Customer.where(company: company, person: person).first

              if customer.blank?
                customer = Customer.new(company: company, person: person, status: :pending)
                customer.save!
                customers_created += 1
              else
                puts "###### !!!! ##### Ya existe customer para esta persona y empresa: person_id=#{person.id}, company_id=#{company.id}"
                raise StandardError, "Ya existe customer para esta persona y empresa: person_id=#{person.id}, company_id=#{company.id}"
              end
              
              # Movimiento si puntos > 0 
              if puntos.present? && puntos > 0
                movement = Movement.new(
                  movement_type: :sale, # de este tipo no afecta en nada
                  amount: 0,
                  amount_discounted: 0,
                  points: puntos,
                  conversion: 1,
                  discount: 0,
                  total_import: 0,
                  description: "Movimiento generado por migración de datos."
                )
                movement.customer = customer
                movement.branch = branch
                movement.person = person
                movement.group = company.active_group
                # Movement.skip_callback(:commit, :after, :trigger_alerts) # Desactivamos las alertas para este movimiento
                if movement.save!
                  customer.update!(status: :active)
                  movements_created += 1
                  # puts "-------------------MOVIMIENTO CREADO----------------------"
                  # puts movement.to_json
                else
                  puts "###### !!!! ##### Error al guardar movimiento para person_id=#{person.id}, company_id=#{company.id}, errores: #{movement.errors.full_messages.to_s}"
                end
              end # if puntos.present?
            end # end Transaction
          end # Unless error_row

        rescue StandardError => e
          puts "Error en fila #{idx}, id: #{item_data['ID']}, error: #{e.message}"
        end # begin block
      end # end xlsx each row
    # rescue StandardError => e # rescue file
    #   puts "Error processing Excel file: #{e.message}"
    #   puts "Try re-saving the file in Excel or LibreOffice to fix ZIP entry issues."
    ensure
      GC.start
      puts "### Garbage colector: File resources released at #{Time.now} ###"
    end

    puts "Rows with missing data that were not imported: #{missing_rows.count}"
    puts missing_rows.to_json
    puts "Customers created: #{customers_created}"
    puts "Persons created: #{persons_created}"
    puts "Movements created: #{movements_created}"
    puts "### Importing customers from excel, task finished.###"
    2.times{puts}
  end

  private

  # Helper to parse date strings (YYYY-MM-DD)
  def parse_date(date_string)
    return nil unless date_string&.strip&.match?(/\A\d{4}-\d{2}-\d{2}\z/)
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end

  # Helper to parse datetime strings (YYYY-MM-DD HH:MM:SS)
  def parse_datetime(datetime_string)
    return nil unless datetime_string&.strip&.match?(/\A\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\z/)
    DateTime.parse(datetime_string)
  rescue ArgumentError
    nil
  end

end