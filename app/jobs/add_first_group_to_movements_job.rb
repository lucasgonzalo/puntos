class AddFirstGroupToMovementsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Find the first group in the database
    first_group = Group.first

    # If no group exists, you may want to create one or skip the job
    unless first_group
      Rails.logger.error "No Group found. Please create at least one Group before running this job."
      return
    end

    # Iterate through all movements without a group and assign the first group
    Movement.all.find_each do |movement|
      if movement.branch
        new_group = movement.branch.company.active_group
      else
        new_group = first_group
      end
      
      new_person = movement.customer.person if movement.customer
      new_person = movement.person if movement.person
      movement.update(group: new_group, person: new_person)
    end
  end
end
