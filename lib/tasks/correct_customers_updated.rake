namespace :excel_import do
  desc 'Correct customer points based on Excel data with detailed analysis'
  task correct_customers_updated: :environment do
    2.times{puts}
    puts "### Correct Customers Updated Task Started ###"
    
    company_id = 16
    company = Company.find(company_id)
    puts "Using company_id=#{company_id} (#{company.name})"
    
    file_name = "lib/tasks/files/filtered_clients_updated.xlsx"
    
    begin
      xlsx = Roo::Spreadsheet.open(file_name)
      total_rows = xlsx.last_row - 1
      puts "Total data rows (excluding header): #{total_rows}"
      headers = xlsx.row(1)
      
      # Statistics tracking
      stats = {
        total_processed: 0,
        clients_not_exist: 0,
        clients_one_movement: 0,
        corrected_clients: 0,
        clients_not_corrected: 0,
        multi_movement_already_correct: 0,
        movements_updated: 0,
        not_exist_details: [],
        one_movement_details: [],
        multi_movement_details: [],
        updated_movements_details: []
      }
      
      current_row = 1
      
      xlsx.each_with_index.drop(1).each do |row, idx|
        begin
          print "Processing row #{current_row} of #{total_rows}\r"
          $stdout.flush
          current_row += 1
          
          item_data = Hash[[headers, row].transpose]
          document_number = item_data["Documento"]&.to_s&.strip
          excel_points = item_data["Puntos"]&.to_f&.to_i || 0
          name = "#{item_data['Nombre']&.to_s&.strip} #{item_data['Apellido']&.to_s&.strip}".strip
          
          next if document_number.blank?
          
          stats[:total_processed] += 1
          
          # Find person by document number
          person = Person.find_by(document_number: document_number)
          
          if person.nil?
            stats[:clients_not_exist] += 1
            stats[:not_exist_details] << {
              document: document_number,
              name: name,
              excel_points: excel_points
            }
            next
          end
          
          # Find customer records for this person in the specified company
          customers = Customer.joins(:person)
                           .where(people: { id: person.id }, company_id: company_id)
          
          if customers.empty?
            stats[:clients_not_exist] += 1
            stats[:not_exist_details] << {
              document: document_number,
              name: name,
              excel_points: excel_points,
              reason: "Person exists but no customer for company #{company.name}"
            }
            next
          end
          
          # Process each customer (usually should be 1 per person per company)
          customers.each do |customer|
            movement_count = customer.movements.count
            current_points = customer.points_balance_amount(company)
            
            # Find migration movement (first movement with specific description)
            migration_movement = customer.movements
                                   .where(description: 'Movimiento generado por migración de datos.')
                                   .order(created_at: :asc)
                                   .first
            
            migration_points = migration_movement&.points || 0
            
            # Check if customer has only 1 movement
            if movement_count == 1
              stats[:clients_one_movement] += 1
              
              # Check if excel points equals migration points (corrected_client)
              if excel_points == migration_points
                stats[:corrected_clients] += 1
              else
                # Update the single movement with excel points
                single_movement = customer.movements.first
                if single_movement
                  old_points = single_movement.points
                  single_movement.update!(
                    points: excel_points,
                    updated_at: Time.new(2025, 11, 6, 3, 0, 0)
                  )
                  stats[:movements_updated] += 1
                  stats[:updated_movements_details] << {
                    document: document_number,
                    name: name,
                    customer_id: customer.id,
                    movement_id: single_movement.id,
                    old_points: old_points,
                    new_points: excel_points,
                    migration_points: migration_points
                  }
                end
              end
              
              stats[:one_movement_details] << {
                document: document_number,
                name: name,
                customer_id: customer.id,
                movement_count: movement_count,
                excel_points: excel_points,
                current_points: current_points,
                migration_points: migration_points,
                is_corrected: excel_points == migration_points
              }
            else
              # Multi-movement clients
              if excel_points == migration_points
                # Points already match - no correction needed
                stats[:corrected_clients] += 1
                stats[:multi_movement_already_correct] += 1
                stats[:multi_movement_details] << {
                  document: document_number,
                  name: name,
                  customer_id: customer.id,
                  movement_count: movement_count,
                  excel_points: excel_points,
                  migration_points: migration_points,
                  current_points: current_points,
                  status: "ALREADY_CORRECT"
                }
              else
                # Points don't match - requires manual correction
                stats[:clients_not_corrected] += 1
                stats[:multi_movement_details] << {
                  document: document_number,
                  name: name,
                  customer_id: customer.id,
                  movement_count: movement_count,
                  excel_points: excel_points,
                  migration_points: migration_points,
                  current_points: current_points,
                  status: "NEEDS_MANUAL_CORRECTION"
                }
              end
            end
          end
          
        rescue StandardError => e
          puts "Error processing row #{idx}, document: #{item_data['Documento']}, error: #{e.message}"
        end
      end
      
      # Output detailed results
      puts "\n\n### Results Summary ###"
      puts "Total clients processed: #{stats[:total_processed]}"
      puts "Clients not found in database: #{stats[:clients_not_exist]}"
      puts "Clients with only one movement: #{stats[:clients_one_movement]}"
      puts "Clients with only one movement and excel points equals migration points (corrected_client): #{stats[:corrected_clients]}"
        puts "Multi-movement clients already correct: #{stats[:multi_movement_already_correct]}"
        puts "Multi-movement clients needing manual correction: #{stats[:clients_not_corrected]}"
      puts "Movements updated: #{stats[:movements_updated]}"
      
      # Detailed breakdowns
      if stats[:not_exist_details].any?
        puts "\n### Clients Not Found in Database ###"
        stats[:not_exist_details].each do |detail|
          reason = detail[:reason] || "Person not found"
          puts "  - Doc: #{detail[:document]} | Name: #{detail[:name]} | Excel Points: #{detail[:excel_points]} | Reason: #{reason}"
        end
      end
      
      if stats[:one_movement_details].any?
        puts "\n### Clients with Only One Movement ###"
        stats[:one_movement_details].each do |detail|
          status = detail[:is_corrected] ? "CORRECTED" : "UPDATED"
          puts "  - Doc: #{detail[:document]} | Name: #{detail[:name]} | Movements: #{detail[:movement_count]} | Excel: #{detail[:excel_points]} | Migration: #{detail[:migration_points]} | Current: #{detail[:current_points]} | Status: #{status}"
        end
      end
      
      if stats[:multi_movement_details].any?
        puts "\n### Clients with More Than One Movement ###"
        stats[:multi_movement_details].each do |detail|
          status = detail[:status] == "ALREADY_CORRECT" ? "ALREADY CORRECT" : "NEEDS MANUAL CORRECTION"
          puts "  - Document: #{detail[:document]} | Status: #{status}"
          puts "    Full Name: #{detail[:name]}"
          puts "    Movement Count: #{detail[:movement_count]}"
          puts "    Excel Points: #{detail[:excel_points]}"
          puts "    Migration Points: #{detail[:migration_points]}"
          puts "    Current Points: #{detail[:current_points]}"
          puts "    ---"
        end
      end
      
      if stats[:updated_movements_details].any?
        puts "\n### Updated Movements Details ###"
        stats[:updated_movements_details].each do |detail|
          puts "  - Doc: #{detail[:document]} | Name: #{detail[:name]}"
          puts "    Movement ID: #{detail[:movement_id]} | Customer ID: #{detail[:customer_id]}"
          puts "    Points: #{detail[:old_points]} → #{detail[:new_points]} | Migration Points: #{detail[:migration_points]}"
          puts "    Updated at: 2025-11-06 03:00:00"
          puts "    ---"
        end
      end
      
      puts "\n### Correction completed successfully ###"
      
    rescue StandardError => e
      puts "Error processing Excel file: #{e.message}"
      puts e.backtrace.first(5).join("\n")
    ensure
      GC.start
      puts "### Garbage collector: File resources released at #{Time.now} ###"
    end
    
    2.times{puts}
  end
end