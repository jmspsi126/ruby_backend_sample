class CdsAccountResource < ActiveRecord::Base
  acts_as_tenant :account

  attr_accessible :file, :title, :category_id, :position, :link_url,
                  :account_id

  has_attached_file :file
  belongs_to :category
  belongs_to :account

  validates_presence_of :account

  def category_name
    return category.name rescue ""
  end

  def file_url
    return file.url rescue ""
  end

  def self.resources
    find(:all, :joins => :category, :order => 'categories.name ASC, position DESC')
  end
end
