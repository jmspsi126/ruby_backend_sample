require 'liis'

class System < ActiveRecord::Base
  attr_accessor :send_file_flags

  acts_as_tenant :account

  attr_accessible :name, :id_assigned, :account_id, :locomotive_type_id

  validates :name, :presence => true

  has_many :faults
  belongs_to :account
  belongs_to :locomotive_type
  
  def self.for_account(account)
    account_id = account ? account.id : nil
    self.where(account_id: account_id)
  end
  
  def self.for_locotype(locomotive_type)
    self.where(locomotive_type_id:locomotive_type)
  end

  def as_json(options={})
    options[:methods] = :send_file_flags
    super(options)
  end

  def include_file_flags_for(loco)
    find = FindSendFileFlags.new(
      LogfileRequest,
      loco.send_file_flags_for_system(self)
    )

    self.send_file_flags = find.flags_for(loco, self)
    self
  end
end

