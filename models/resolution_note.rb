class ResolutionNote < ActiveRecord::Base
  attr_accessible :user_id, :fault_id, :note

  belongs_to :fault
  belongs_to :user

end
