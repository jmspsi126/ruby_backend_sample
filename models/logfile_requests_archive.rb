class LogfileRequestsArchive < ActiveRecord::Base
  belongs_to :account
  acts_as_tenant :account

  attr_accessible :liis_locomotive_id, :liis_system_id, :liis_file_request_id,
    :send_file_flag_enum_value, :status, :date, :label, :created_at, :updated_at, :account_id

end

