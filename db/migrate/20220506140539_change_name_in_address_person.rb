class ChangeNameInAddressPerson < ActiveRecord::Migration[7.1]
  def change
    rename_column :address_people, :geo_location_link, :geolocation_link
  end
end
