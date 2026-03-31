namespace :generate_settings_branch do

  task ejecute_method: :environment do
    puts 'Vamos a crear los tokens a las sucursales'
    Branch.all.each do |branch|
      code = SecureRandom.base64(6)
      while Company.exists?(token: code)
        code = SecureRandom.base64(6)
      end
      branch.token = code
      branch.save
    end
  end

  task branch_ejecute_method: :environment do
    puts 'Vamos a mover todo lo de company a sus braches'
    Company.all.each do |company|
      company.branches.each do |branch|
        branch.days_sleep = company.days_sleep
        branch.alert_days = company.alert_days
        branch.alert_qty_movements = company.alert_qty_movements
        branch.alert_amount = company.alert_amount
        branch.email = company.email
        branch.save
      end
    end
  end

  task branch_setting_ejecute_method: :environment do
    puts 'Vamos a mover todo lo de company_setting a sus brach_settings'
    Company.all.each do |company|
      company.branches.each do |branch|
        company.company_settings.each do |company_setting|
          branch_setting = BranchSetting.new
          branch_setting.day = company_setting.day
          branch_setting.branch_id = branch.id
          branch_setting.conversion = company_setting.conversion
          branch_setting.discount = company_setting.discount
          branch_setting.save
        end
      end
    end
  end

  task branch_setting_ejecute_method: :environment do
    puts 'Vamos a mover todo lo de company_setting a sus brach_settings'
    Company.all.each do |company|
      company.branches.each do |branch|
        company.company_settings.each do |company_setting|
          branch_setting = BranchSetting.new
          branch_setting.day = company_setting.day
          branch_setting.branch_id = branch.id
          branch_setting.conversion = company_setting.conversion
          branch_setting.discount = company_setting.discount
          branch_setting.save
        end
      end
    end
  end

  task branch_alert_ejecute_method: :environment do
    puts 'Vamos a mover todo lo de alert a sus branch_alerts'
    Company.all.each do |company|
      company.branches.each do |branch|
        company.alerts.each do |alert|
          branch_alert = BranchAlert.new
          branch_alert.branch_id = branch.id
          branch_alert.category = alert.category
          branch_alert.status = alert.status
          branch_alert.content = alert.content
          branch_alert.link = alert.link
          branch_alert.save

        end
      end
    end
  end

end
