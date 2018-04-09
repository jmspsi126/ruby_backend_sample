class Locomotive < ActiveRecord::Base
  acts_as_tenant :account

  attr_accessible :commission_date, :description, :id_assigned, :title,
                  :locomotive_type, :latitude, :longitude, :current_time,
                  :account_id, :config_file, :send_config, :send_map,
                  :pref_measurement_system, :pref_measurement_fuel, :out_of_service, :locomotive_type_id

  belongs_to :account
  belongs_to :locomotive_type

  validates_presence_of :account
  validates_presence_of :locomotive_type

  after_create :set_measurement_from_account

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end

  private
    # inherit it from account pref
    def set_measurement_from_account
      self.pref_measurement_system = self.account.pref_measurement_system
      self.save
    end

end

