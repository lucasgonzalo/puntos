class AddConversionAgentToBranchSettings < ActiveRecord::Migration[7.2]
  def up
    add_column :branch_settings, :conversion_agent, :float, default: 0, null: false
    BranchSetting.reset_column_information
    BranchSetting.find_each do |bs|
      bs.update_column(:conversion_agent, bs.conversion)
    end
  end
  def down
    remove_column :branch_settings, :conversion_agent
  end
end
