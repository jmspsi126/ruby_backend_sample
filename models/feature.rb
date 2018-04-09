class Feature < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :accounts, :join_table => :accounts_features
  belongs_to :resource, :polymorphic => true

  scopify

  def self.ensure(feature_name)
    unless find_by_name(feature_name)
      create!(name: feature_name)
    end
  end
end
