namespace :fix_data do
  task ejecute_method: :environment do
    puts 'Data Migration'
    require 'faker'
    Company.all.each do |company|
      # company.company_settings.destroy_all
      if !company.company_settings.blank?
        (1..7).each do |i|
          days = company.company_settings.where(day: i)
          first_day = days.first
          days.where.not(id: first_day.id).destroy_all
        end
      else
        conversion_random = Faker::Number.between(from: 0.0, to: 1.0).round(2)
        discount_random = Faker::Number.between(from: 0.0, to: 1.0).round(2)
        (1..7).each do |i|
          company_setting = CompanySetting.new
          company_setting.day = i
          company_setting.company_id = company.id
          company_setting.conversion = conversion_random
          company_setting.discount = discount_random
          company_setting.save!
        end
      end

      company.days_sleep = Random.rand(1..30)
      company.alert_days = Random.rand(1..15)
      company.alert_qty_movements = Random.rand(1..10)
      company.alert_amount = Random.rand(5000)

      company.save!
    end
  end
end
