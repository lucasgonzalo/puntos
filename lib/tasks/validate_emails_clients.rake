namespace :validate_emails do
  desc 'Validate people emails from xlsx file'
  task validate: :environment do
    2.times{puts}
    puts "### validate emails customers from excel, task started.###"

    file_name = "lib/tasks/files/solo_mails_entregados.xlsx"

    total_emails = 0
    emails_found = 0
    emails_updated = 0
    emails_not_found = 0
    emails_not_found_list = []
    duplicated_emails = []
    errors = 0
    error_rows = []

    begin
      xlsx = Roo::Spreadsheet.open(file_name)
      headers = xlsx.row(1)

      destinatario_col_index = headers.index("Destinatario")

      if destinatario_col_index.nil?
        puts "ERROR: Column 'Destinatario' not found in Excel file"
        puts "Available columns: #{headers.join(', ')}"
        return
      end

      total_rows = xlsx.last_row - 1
      puts "Total data rows (excluding header): #{total_rows}"

      xlsx.each_with_index.drop(1).each do |row, idx|
        begin
          print "Procesando fila #{idx + 1} de #{total_rows}  \r"
          $stdout.flush

          email = row[destinatario_col_index].to_s.strip

          next if email.blank?

          total_emails += 1

          person_emails = PersonEmail.where("LOWER(email) = ?", email.downcase)

          if person_emails.any?
            emails_found += person_emails.count

            if person_emails.count > 1
              duplicated_emails << { email: email, count: person_emails.count }
              next
            end

            person_emails.each do |person_email|
              if person_email.validated_at.nil?
                person_email.update!(validated_at: Time.current)
                emails_updated += 1
              end
            end
          else
            emails_not_found += 1
            emails_not_found_list << email
          end

        rescue StandardError => e
          errors += 1
          error_rows << { row: idx + 1, email: row[destinatario_col_index], error: e.message }
          puts "Error en fila #{idx + 1}: #{e.message}"
        end
      end

    rescue StandardError => e
      puts "Error processing Excel file: #{e.message}"
      puts "Try re-saving the file in Excel or LibreOffice to fix ZIP entry issues."
    ensure
      GC.start
      puts "### Garbage collector: File resources released at #{Time.now} ###"
    end

    2.times{puts}
    puts "### Validation Summary ###"
    puts "Total emails processed: #{total_emails}"
    puts "Emails found in database: #{emails_found}"
    puts "Emails validated (updated): #{emails_updated}"
    puts "Emails not found: #{emails_not_found}"
    puts "Errors encountered: #{errors}"

    if emails_not_found_list.any?
      puts "\n### Emails Not Found (#{emails_not_found_list.size}) ###"
      emails_not_found_list.each { |email| puts "  - #{email}" }
    end

    if duplicated_emails.any?
      puts "\n### Duplicated Emails Found (#{duplicated_emails.size}) ###"
      duplicated_emails.each { |dup| puts "  - #{dup[:email]} (appears #{dup[:count]} times)" }
    end

    if error_rows.any?
      puts "\n### Error Details ###"
      error_rows.each do |err|
        puts "Row #{err[:row]} - Email: #{err[:email]} - Error: #{err[:error]}"
      end
    end

    puts "### validate emails customers from excel, task finished.###"
    2.times{puts}
  end
end