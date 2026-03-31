class MyTaskStatusJob < ApplicationJob
  queue_as :default

  def perform(company)
    # shoud check if last update was made today
    if company.last_update_customers_job.present? && company.last_update_customers_job.to_date == Date.today
      Rails.logger.debug "########## Skipping customer status update for Company #{company.id} as it was updated recently.########"
      return
    end
    # TODO !: Using a specific branch to get days_sleep setting makes no sense as this updates customers for the whole company.
    # Use find_in_batches for large datasets to avoid memory issues in Rails jobs.
    # branch = company.branches.where(active: true).first # Selecting a random branch
    company.customers.where(status: :active).includes(:movements).find_in_batches do |batch|
      batch.each do |customer|
        next unless customer.movements.any?  # Skip if no movements

        last_movement_date = customer.movements.maximum(:created_at) # Fetch last movement efficiently

        # next unless branch.days_sleep.present? && branch.days_sleep.to_i > 0
        # days_sleep = branch.days_sleep.to_i
        days_sleep = company.days_sleep || 30
        today_date = Date.today
        last_movement_date = last_movement_date.to_date  # Convert to Date.
        sleep_threshold_date = last_movement_date + days_sleep.days

        if today_date >= sleep_threshold_date
          Rails.logger.debug "---------Customer #{customer.id}------------"
          Rails.logger.debug "Hoy: #{today_date}"
          Rails.logger.debug "Ultimo movimiento: #{last_movement_date}"
          Rails.logger.debug "Dias para dormir: #{days_sleep}"
          Rails.logger.debug "Fecha para dormir: #{sleep_threshold_date}"
          Rails.logger.debug "---------------------"
          customer.update(status: :asleep)  # Use update for efficiency; assumes enum or valid status.
        else
          Rails.logger.debug "Customer #{customer.id} is still active. Last movement on #{last_movement_date}, needs to sleep after #{sleep_threshold_date}."
        end
      end
    end
    Rails.logger.debug "########## Finished customer status update for Company #{company.id}. ########"
    company.update(last_update_customers_job: DateTime.now)
  end

end
