class Account < ActiveRecord::Base
  rolify :role_cname => 'Feature'

  accepts_nested_attributes_for :roles

  attr_accessible :name, :subdomain, :liis_id, :header_image,
                  :company_address_1, :company_address_2, :company_city,
                  :company_state, :company_country, :company_zip, :company_phone,
                  :company_fax, :company_email, :company_url,
                  :pref_measurement_system, :pref_measurement_system, :role_ids, :script_time

  validates_presence_of :name, :subdomain
  validates_uniqueness_of :name, :subdomain
  has_and_belongs_to_many :features
  has_many :locomotives
  has_many :users
  has_many :systems

  has_and_belongs_to_many :features

  has_attached_file(
    :header_image,
    styles: { thumb: '100x100>' },
    default_url: '/assets/generic-customer.png'
  )

  after_initialize :init

  MEASUREMENT_SYSTEMS_OPTIONS = ['Imperial', 'Metric']

  def self.measurement_system_options
    MEASUREMENT_SYSTEMS_OPTIONS
  end

  MEASUREMENT_FUEL_OPTIONS = ['IGAL', 'GAL', 'L']

  def self.measurement_fuel_options
    MEASUREMENT_FUEL_OPTIONS
  end

  def init
    self.pref_measurement_system ||= 'Imperial'
    self.pref_measurement_system ||= 'IGAL'
  end

  def add_user(user)
    user.account = self
    user
  end

  def add_user!(user)
    add_user(user)
    user.save
    user
  end

  def has_feature_enabled?(feature_name)
    has_role?(feature_name)
  end

  def feature_names
    roles.map(&:name)
  end
end

