namespace :excel_analysis do
  desc "Analyze para_anular_completo.xlsx for customers from company 16"
  # This task will read the para_anular_completo.xlsx file and analyze customers belonging to company_id = 16
  # For each found customer, it will show how many movements they have and then will generate an exchange movement
  # to deduct points according to the Excel data (Importe * 0.02)

  task analyze_annulment_file: :environment do
    # Setup task lock to prevent multiple executions
    lock_file = create_task_lock("analyze_annulment_file", {
      file_processed: "para_anular_completo.xlsx",
      company_id: 16
    })

    begin
    2.times { puts }
    puts "### Analyzing annulment file for company 16 customers. Task started.###"
    company_id = 16
    company = Company.find(company_id)
    puts "Company: #{company.name} (ID: #{company_id})"

    file_name = "lib/tasks/files/para_anular_completo.xlsx"

    begin
      xlsx = Roo::Spreadsheet.open(file_name)
      puts "File info: #{xlsx.info}"

      # Statistics tracking
      total_rows = 0
      customers_found = 0
      customers_with_movements = 0
      customers_with_one_movement = 0
      customers_with_multiple_movements = 0
      customers_with_exchanges = 0
      customers_with_negative_difference = 0
      total_movements = 0
      total_current_points = 0
      total_excel_points = 0
      total_difference_points = 0
      movements_created = 0
      total_points_deducted = 0
      customers_with_partial_deduction = 0
      not_found_customers = []
      customer_details = []

      # Calculate total data rows (excluding header)
      total_rows = xlsx.last_row - 1
      puts "Total data rows (excluding header): #{total_rows}"
      headers = xlsx.row(1) # get header row (column names)
      puts "Headers: #{headers.inspect}"

      # Load all data rows (excluding header) into an array of hashes
      data_rows = []
      xlsx.each_with_index.drop(1).each do |row, idx|
        item_data = Hash[[ headers, row ].transpose]
        data_rows << item_data
      end

      # Group data by DNI to handle duplicate customers
      grouped_data = data_rows.group_by { |row| row["DNI"] }
      
      puts "Found #{grouped_data.keys.count} unique customers from #{data_rows.count} total rows"
      
      current_row = 1 # To track progress

      # Procesamiento de cada cliente único
      grouped_data.each do |dni, customer_rows|
        begin
          print "Processing customer #{current_row} of #{grouped_data.keys.count} (DNI: #{dni})  \r"
          $stdout.flush
          current_row += 1

          # Get first row data for customer info
          first_row = customer_rows.first
          full_name = first_row["Nombre y Apellido"]&.to_s&.strip
          
          # Skip if DNI is blank
          if dni.blank?
            puts "\nSkipping customer - DNI is blank"
            next
          end

          # Find person by DNI
          person = Person.find_by(document_number: dni)

          if person.blank?
            not_found_customers << {
              dni: dni,
              name: full_name,
              rows_count: customer_rows.count,
              trans_ids: customer_rows.map { |r| r["Trans"] }
            }
            next
          end

          # Find customer for this person and company
          customer = Customer.joins(:person)
                           .where(people: { id: person.id }, company_id: company_id)
                           .first

          if customer.present?
            customers_found += 1

            # Count movements for this customer
            movement_count = customer.movements.count
            total_movements += movement_count

            # Check if customer has exchange movements (Canje)
            exchange_count = customer.movements.where(movement_type: [ :exchange, :product_exchange ]).count
            has_exchanges = exchange_count > 0

            # Calculate points
            current_points = customer.points_balance_amount(company)
            
            # Sum Excel points for all rows of this customer
            total_excel_points_for_customer = customer_rows.sum do |row|
              importe = row["Importe"]
              importe.present? ? (importe.to_f * 0.02).round : 0
            end
            
            difference_points = current_points - total_excel_points_for_customer

            # Count customers with negative difference
            if difference_points < 0
              customers_with_negative_difference += 1
            end

            # Create exchange movement to deduct Excel points
            if total_excel_points_for_customer > 0
              ActiveRecord::Base.transaction do
                # Determine how many points to deduct
                if difference_points >= 0
                  # Customer has enough points - deduct full Excel amount
                  exchange_points = total_excel_points_for_customer
                  deduction_type = "full"
                else
                  # Customer has insufficient points - only deduct what's available
                  exchange_points = current_points
                  deduction_type = "partial"
                  customers_with_partial_deduction += 1
                end

                # Only create movement if there are points to deduct
                if exchange_points > 0
                  movement = Movement.new(
                    movement_type: :exchange,
                    amount: 0,
                    amount_discounted: 0,
                    points: exchange_points,
                    conversion: 1,
                    discount: 0,
                    total_import: 0,
                    description: "Movimiento de correccion de puntos generado por migracion de anulaciones. Transaccion/es: #{customer_rows.map { |r| r["Trans"] }.join(', ')}",
                    customer: customer,
                    branch: company.branches.first, # Use first branch of company
                    person: person,
                    group: company.active_group
                  )

                  if movement.save!
                    movements_created += 1
                    total_points_deducted += exchange_points
                    puts "\n✓ Created exchange movement for #{full_name} (DNI: #{dni}): -#{exchange_points} points (#{deduction_type} deduction) from #{customer_rows.count} Excel rows"
                  else
                    puts "\n✗ Failed to create movement for #{full_name} (DNI: #{dni}): #{movement.errors.full_messages.join(', ')}"
                  end
                else
                  puts "\n⚠ No points to deduct for #{full_name} (DNI: #{dni}) - current points: #{current_points}"
                end
              end # transaction
            end

            # Update totals
            total_current_points += current_points
            total_excel_points += total_excel_points_for_customer
            total_difference_points += difference_points

            customers_with_movements += 1 if movement_count > 0
            customers_with_one_movement += 1 if movement_count == 1
            customers_with_multiple_movements += 1 if movement_count > 1
            customers_with_exchanges += 1 if has_exchanges && movement_count > 1

            customer_details << {
              customer_id: customer.id,
              person_id: person.id,
              dni: dni,
              name: full_name,
              movement_count: movement_count,
              exchange_count: exchange_count,
              current_points: current_points,
              excel_points: total_excel_points_for_customer,
              difference_points: difference_points,
              excel_rows_count: customer_rows.count,
              trans_ids: customer_rows.map { |r| r["Trans"] },
              importe: customer_rows.map { |r| r["Importe"] },
              fecha: customer_rows.map { |r| r["Fecha"] }
            }

            exchange_info = has_exchanges ? " | Exchanges: #{exchange_count}" : ""
            puts "\n✓ Found customer: #{full_name} (DNI: #{dni}) - Movements: #{movement_count}#{exchange_info} | Current Points: #{current_points} | Excel Points: #{total_excel_points_for_customer} | Difference: #{difference_points} | Excel Rows: #{customer_rows.count}"
          else
            not_found_customers << {
              dni: dni,
              name: full_name,
              rows_count: customer_rows.count,
              trans_ids: customer_rows.map { |r| r["Trans"] }
            }
          end

        rescue StandardError => e
          puts "\nError processing customer #{dni}, error: #{e.message}"
        end
      end # end grouped_data each

    rescue StandardError => e
      puts "Error processing Excel file: #{e.message}"
      puts "Try re-saving the file in Excel or LibreOffice to fix ZIP entry issues."
    ensure
      GC.start
      puts "\n### Garbage collector: File resources released at #{Time.now} ###"
    end

    # Display summary statistics
    puts "\n" + "="*80
    puts "SUMMARY REPORT"
    puts "="*80
    puts "Company: #{company.name} (ID: #{company_id})"
    puts "Total rows processed: #{total_rows}"
    puts "Customers found in company 16: #{customers_found}"
    puts "Customers with movements: #{customers_with_movements}"
    puts "Customers with exactly 1 movement: #{customers_with_one_movement}"
    puts "Customers with multiple movements: #{customers_with_multiple_movements}"
    puts "Customers with multiple movements AND exchanges: #{customers_with_exchanges}"
    puts "Total movements across all found customers: #{total_movements}"
    puts "Customers not found: #{not_found_customers.count}"
    puts "\nPOINTS SUMMARY:"
    puts "Total current points across all customers: #{total_current_points}"
    puts "Total points according to Excel (Importe * 0.02): #{total_excel_points}"
    puts "Total difference after discount: #{total_difference_points}"
    puts "Customers with negative difference: #{customers_with_negative_difference}"
    if customers_found > 0
      percentage_negative = (customers_with_negative_difference.to_f / customers_found * 100).round(2)
      puts "Percentage with negative difference: #{percentage_negative}%"
    end

    puts "\nEXCHANGE MOVEMENTS CREATED:"
    puts "Total movements created: #{movements_created}"
    puts "Total points deducted: #{total_points_deducted}"
    puts "Customers with partial deduction (insufficient points): #{customers_with_partial_deduction}"
    if customers_with_negative_difference > 0
      puts "Note: #{customers_with_negative_difference} customers had insufficient points for full deduction"
    end

    # Show customers not found (limited to first 10)
    if not_found_customers.any?
      puts "\nFirst 10 customers not found:"
      not_found_customers.first(10).each do |customer|
        reason = customer[:reason] || "Person not found"
        puts "  Row #{customer[:row]}: #{customer[:name]} (DNI: #{customer[:dni]}) - #{reason}"
      end
      if not_found_customers.count > 10
        puts "  ... and #{not_found_customers.count - 10} more"
      end
    end

    # Show detailed customer information (all customers)
    if customer_details.any?
      puts "\nDetailed customer information:"
      customer_details.each do |detail|
        exchange_info = detail[:exchange_count] > 0 ? " | Exchanges: #{detail[:exchange_count]}" : ""
        puts "  Customer ID: #{detail[:customer_id]} | Person ID: #{detail[:person_id]}"
        puts "  Name: #{detail[:name]} | DNI: #{detail[:dni]}"
        puts "  Movements: #{detail[:movement_count]}#{exchange_info} | Excel Rows: #{detail[:excel_rows_count]}"
        puts "  Points - Current: #{detail[:current_points]} | Excel: #{detail[:excel_points]} | Difference: #{detail[:difference_points]}"
        puts "  Excel Details: Trans IDs: #{detail[:trans_ids].join(', ')}"
        puts "  Excel Details: Importes: #{detail[:importe].join(', ')}"
        puts "  " + "-"*60
      end
    end

    # Movement statistics
    if customer_details.any?
      movement_counts = customer_details.map { |c| c[:movement_count] }
      avg_movements = movement_counts.sum.to_f / movement_counts.count
      max_movements = movement_counts.max
      min_movements = movement_counts.min

      puts "\nMovement Statistics:"
      puts "  Average movements per customer: #{avg_movements.round(2)}"
      puts "  Maximum movements for a customer: #{max_movements}"
      puts "  Minimum movements for a customer: #{min_movements}"

      # Points statistics
      current_points_array = customer_details.map { |c| c[:current_points] }
      excel_points_array = customer_details.map { |c| c[:excel_points] }
      difference_points_array = customer_details.map { |c| c[:difference_points] }

      avg_current_points = current_points_array.sum.to_f / current_points_array.count
      avg_excel_points = excel_points_array.sum.to_f / excel_points_array.count
      avg_difference_points = difference_points_array.sum.to_f / difference_points_array.count

      puts "\nPoints Statistics:"
      puts "  Average current points per customer: #{avg_current_points.round(2)}"
      puts "  Average Excel points per customer: #{avg_excel_points.round(2)}"
      puts "  Average difference per customer: #{avg_difference_points.round(2)}"
      puts "  Maximum current points: #{current_points_array.max}"
      puts "  Minimum current points: #{current_points_array.min}"
      puts "  Maximum Excel points: #{excel_points_array.max}"
      puts "  Minimum Excel points: #{excel_points_array.min}"
      puts "  Maximum difference: #{difference_points_array.max}"
      puts "  Minimum difference: #{difference_points_array.min}"
    end

    puts "\n### Analyzing annulment file for company 16 customers. Task finished.###"
    2.times { puts }
  ensure
    # Keep lock file as evidence of execution
    keep_task_lock(lock_file)
  end
  end

  # ============================================================================
  # TASK LOCK HELPER METHODS - REUSABLE FOR OTHER TASKS
  # ============================================================================

  # Creates a lock file to prevent multiple executions of the same task
  # Usage: lock_file = create_task_lock('task_name', { metadata: 'value' })
  def create_task_lock(task_name, metadata = {})
    lock_file = "tmp/#{task_name}_#{Rails.env}.lock"

    # Check if lock file already exists
    if File.exist?(lock_file)
      begin
        lock_data = YAML.load_file(lock_file)
        executed_at_str = lock_data[:executed_at]

        if executed_at_str.present?
          executed_at = Time.parse(executed_at_str)
        else
          executed_at = Time.current
        end

        puts "⚠️  TASK ALREADY EXECUTED"
        puts "⚠️  Task: #{lock_data[:task_name] || task_name}"
        puts "⚠️  Executed: #{executed_at.strftime('%Y-%m-%d %H:%M:%S UTC')}"
        puts "⚠️  Environment: #{lock_data[:rails_env] || 'unknown'}"
        if lock_data[:file_processed]
          puts "⚠️  File processed: #{lock_data[:file_processed]}"
        end
        if lock_data[:company_id]
          puts "⚠️  Company ID: #{lock_data[:company_id]}"
        end
        puts "⚠️  To run again, remove lock file: #{lock_file}"
        puts "⚠️  Command: rm #{lock_file}"
        exit 1
      rescue => e
        puts "⚠️  Lock file exists but is corrupted: #{e.message}"
        puts "⚠️  Remove manually to continue: #{lock_file}"
        exit 1
      end
    end

    # Create lock file with execution metadata
    lock_data = {
      task_name: task_name,
      executed_at: Time.current.to_s,
      rails_env: Rails.env.to_s,
      ruby_version: RUBY_VERSION,
      hostname: Socket.gethostname,
      pid: Process.pid
    }.merge(metadata)

    begin
      File.write(lock_file, lock_data.to_yaml)
      puts "🔒 Lock file created: #{lock_file}"
      lock_file
    rescue => e
      puts "❌ Failed to create lock file: #{e.message}"
      puts "❌ Task cannot continue without lock protection"
      exit 1
    end
  end

  # Keeps the lock file as evidence of successful execution
  # Usage: keep_task_lock(lock_file)
  def keep_task_lock(lock_file)
    if File.exist?(lock_file)
      puts "✅ Execution completed. Lock file preserved as evidence: #{lock_file}"
      puts "✅ To run again, remove: #{lock_file}"
    else
      puts "⚠️  Lock file not found at completion: #{lock_file}"
    end
  end

  # Removes the lock file (useful for cleanup or manual override)
  # Usage: remove_task_lock('task_name')
  def remove_task_lock(task_name)
    lock_file = "tmp/#{task_name}_#{Rails.env}.lock"
    if File.exist?(lock_file)
      File.delete(lock_file)
      puts "🗑️  Lock file removed: #{lock_file}"
      true
    else
      puts "ℹ️  No lock file found: #{lock_file}"
      false
    end
  end

  # Checks if a task lock exists without creating one
  # Usage: task_locked?('task_name') => true/false
  def task_locked?(task_name)
    lock_file = "tmp/#{task_name}_#{Rails.env}.lock"
    File.exist?(lock_file)
  end
end
