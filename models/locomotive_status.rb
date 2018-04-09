class LocomotiveStatus
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'locomotives'

  def self.for_account(account_id)
    where(customer_id: account_id)
  end

  def self.active
    result = []
    where({updated_at: ((Time.now - 1.minute)..Time.now)}).each do |loco|
      result << {'customer_id' => loco[:customer_id],'locomotive_id'=>loco[:locomotive_id]}
    end
    return result
  end
end