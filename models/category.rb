class Category < ActiveRecord::Base
  attr_accessible :group_id, :name, :position
  has_many :resources
end
