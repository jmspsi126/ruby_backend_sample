class LogfileRequest < ActiveRecord::Base
  belongs_to :account
  acts_as_tenant :account

  attr_accessible :liis_locomotive_id, :liis_system_id, :liis_file_request_id,
    :send_file_flag_enum_value, :status, :date, :label

  scope(:pending, ->{ where(status: :pending) })

  def to_logfile
    Logfile.new({
      path: nil,
      customer_id: self.account.id,
      date: self.date,
      locomotive_id: self.liis_locomotive_id,
      system_id: self.liis_system_id,
      label: self.label,
      url: nil
    })
  end
end

