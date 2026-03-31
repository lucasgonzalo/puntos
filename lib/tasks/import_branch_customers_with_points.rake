namespace :excel_import do
  desc 'Analyze branch customers with points comparison (logging only)'
  task import_branch_customers_with_points: :environment do
    2.times{puts}
    puts "### Import Branch Customers with Points Analysis. Task started. ###"
    
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
        excel_greater_current: 0,
        excel_less_current: 0,
        migration_points_found: 0,
        migration_points_not_found: 0,
        not_exist_details: [],
        one_movement_details: [],
        point_differences: [],
        migration_details: []
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
            since_migration_diff = current_points - migration_points
            
            # Check if the single movement is the migration movement
            is_migration_single = (movement_count == 1 && migration_movement.present?)
            
            if migration_movement
              stats[:migration_points_found] += 1
            else
              stats[:migration_points_not_found] += 1
            end
            
            # Check if customer has only 1 movement
            if movement_count == 1
              stats[:clients_one_movement] += 1
              stats[:one_movement_details] << {
                document: document_number,
                name: name,
                customer_id: customer.id,
                movement_count: movement_count,
                excel_points: excel_points,
                current_points: current_points,
                migration_points: migration_points,
                since_migration_diff: since_migration_diff,
                has_migration: is_migration_single
              }
            end
            
            # Compare excel points with current points
            point_diff = excel_points - current_points
            if point_diff > 0
              stats[:excel_greater_current] += 1
            elsif point_diff < 0
              stats[:excel_less_current] += 1
            end
            
            # Store point differences for detailed analysis
            if point_diff != 0
              stats[:point_differences] << {
                document: document_number,
                name: name,
                customer_id: customer.id,
                excel_points: excel_points,
                current_points: current_points,
                migration_points: migration_points,
                since_migration_diff: since_migration_diff,
                difference: point_diff,
                movement_count: movement_count
              }
            end
            
            # Store migration details for analysis
            stats[:migration_details] << {
              document: document_number,
              name: name,
              customer_id: customer.id,
              excel_points: excel_points,
              migration_points: migration_points,
              current_points: current_points,
              since_migration_diff: since_migration_diff,
              movement_count: movement_count,
              has_migration: migration_movement.present?
            }
          end
          
        rescue StandardError => e
          puts "Error processing row #{idx}, document: #{item_data['Documento']}, error: #{e.message}"
        end
      end
      
      # Output detailed results
      puts "\n\n### Results Summary ###"
      puts "Total clients processed: #{stats[:total_processed]}"
      puts "Clients not found in database: #{stats[:clients_not_exist]}"
      puts "Clients with only 1 movement: #{stats[:clients_one_movement]}"
      puts "Clients with migration movement found: #{stats[:migration_points_found]}"
      puts "Clients without migration movement: #{stats[:migration_points_not_found]}"
      puts "Clients with excel_points > current_points: #{stats[:excel_greater_current]}"
      puts "Clients with excel_points < current_points: #{stats[:excel_less_current]}"
      
      # Detailed breakdowns
      if stats[:not_exist_details].any?
        puts "\n### Clients Not Found in Database ###"
        stats[:not_exist_details].each do |detail|
          reason = detail[:reason] || "Person not found"
          puts "  - Doc: #{detail[:document]} | Name: #{detail[:name]} | Excel Points: #{detail[:excel_points]} | Reason: #{reason}"
        end
      end
      
       if stats[:one_movement_details].any?
         puts "\n### Clients with Only 1 Movement ###"
         stats[:one_movement_details].each do |detail|
           migration_info = detail[:has_migration] ? "Migration: #{detail[:migration_points]}" : "No Migration"
           since_migration = detail[:has_migration] ? "Since Migration: #{detail[:since_migration_diff]}" : "N/A"
           puts "  - Doc: #{detail[:document]} | Name: #{detail[:name]} | Customer ID: #{detail[:customer_id]} | Movements: #{detail[:movement_count]} | Excel: #{detail[:excel_points]} | Current: #{detail[:current_points]} | #{migration_info} | #{since_migration}"
         end
       end
      
      if stats[:point_differences].any?
        puts "\n### Point Differences Analysis ###"
        
        greater_than = stats[:point_differences].select { |d| d[:difference] > 0 }
        less_than = stats[:point_differences].select { |d| d[:difference] < 0 }
        
         if greater_than.any?
           puts "\nClients with Excel Points > Current Points (#{greater_than.size}):"
           greater_than.each do |detail|
             migration_info = detail[:migration_points] > 0 ? "Migration: #{detail[:migration_points]}" : "No Migration"
             since_migration = detail[:migration_points] > 0 ? "Since Migration: #{detail[:since_migration_diff]}" : "N/A"
             puts "  - Doc: #{detail[:document]} | Excel: #{detail[:excel_points]} | Current: #{detail[:current_points]} | Diff: +#{detail[:difference]} | #{migration_info} | #{since_migration} | Movements: #{detail[:movement_count]}"
           end
         end
        
         if less_than.any?
           puts "\nClients with Excel Points < Current Points (#{less_than.size}):"
           less_than.each do |detail|
             migration_info = detail[:migration_points] > 0 ? "Migration: #{detail[:migration_points]}" : "No Migration"
             since_migration = detail[:migration_points] > 0 ? "Since Migration: #{detail[:since_migration_diff]}" : "N/A"
             puts "  - Doc: #{detail[:document]} | Excel: #{detail[:excel_points]} | Current: #{detail[:current_points]} | Diff: #{detail[:difference]} | #{migration_info} | #{since_migration} | Movements: #{detail[:movement_count]}"
           end
         end
       end
       
       # Migration Analysis
       if stats[:migration_details].any?
         puts "\n### Migration Points Analysis ###"
         
         with_migration = stats[:migration_details].select { |d| d[:has_migration] }
         without_migration = stats[:migration_details].select { |d| !d[:has_migration] }
         
         puts "\nClients with Migration Movement (#{with_migration.size}):"
         with_migration.each do |detail|
           excel_vs_migration = detail[:excel_points] - detail[:migration_points]
           excel_migration_diff = excel_vs_migration != 0 ? "Excel vs Migration: #{excel_vs_migration > 0 ? '+' : ''}#{excel_vs_migration}" : "Excel = Migration"
           puts "  - Doc: #{detail[:document]} | Excel: #{detail[:excel_points]} | Migration: #{detail[:migration_points]} | Current: #{detail[:current_points]} | Since Migration: #{detail[:since_migration_diff]} | #{excel_migration_diff} | Movements: #{detail[:movement_count]}"
         end
         
         if without_migration.any?
           puts "\nClients without Migration Movement (#{without_migration.size}):"
           without_migration.each do |detail|
             puts "  - Doc: #{detail[:document]} | Excel: #{detail[:excel_points]} | Current: #{detail[:current_points]} | No Migration Movement Found | Movements: #{detail[:movement_count]}"
           end
         end
       end
       
       puts "\n### Analysis completed successfully ###"
      
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