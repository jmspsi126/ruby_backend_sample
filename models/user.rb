class User < ActiveRecord::Base
  rolify

  belongs_to :account

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :recoverable, :rememberable,
          :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :account_id, :approved_by_admin, :approved_by_account_admin,
                  :role_ids, :pref_header_image, :first_name, :last_name, :city,
                  :state, :country, :job_title, :pref_fault_severity_filter,
                  :pref_default_health_param, :pref_default_status_param,
                  :pref_timezone, :pref_daylight_savings, :pref_time_display,
                  :pref_email_notifications


  accepts_nested_attributes_for :roles
  after_initialize :init

  TIME_DISPLAY_OPTIONS = ["UTC", "Preference", "Locomotive"]

  def init
    self.pref_header_image = true if self.pref_header_image.nil?
    self.pref_fault_severity_filter ||= "Show All"
    self.pref_time_display ||= "Preference"
    self.pref_timezone ||= "(GMT-05:00) Eastern Time (US & Canada)"
    self.pref_daylight_savings = true if self.pref_daylight_savings.nil?
    self.pref_email_notifications ||= false
  end

  def self.time_options
    TIME_DISPLAY_OPTIONS
  end

  def first_name_or_email
    first_name ? first_name : email
  end

  # don't require a password when sending an invite
  def password_required?
    super if confirmed?
  end

  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  def update_and_confirm(passwords)
    if !fully_approved?
      self.errors[:account] << "is not yet approved."
      false
    else
      update_attributes(passwords) && password_match? && confirm!
    end
  end

  def active_for_authentication?
    fully_approved? && super
  end

  def fully_approved?
    approved_by_admin? && approved_by_account_admin?
  end

  def send_on_create_confirmation_instructions
    # wait for user to become fully approved
  end

  def approval_status
    fully_approved? ? "Fully Approved" : "Awaiting Approval"
  end

  def approve
    self.approved_by_admin = true
    self.approved_by_account_admin = true
  end

  def approve!
    approve; save
  end

  def invite_if_approval_changed previous_approval_status
    if previous_approval_status == false
      invite_if_approved
    end
  end

  def invite_if_approved
    invite if fully_approved?
  end

  def invite
    send_confirmation_instructions
  end

  def admin?
    has_role? :admin
  end

  def account_admin?
    has_role? :account_admin
  end

  def mpi_user?
    has_role? :mpi_user
  end

  def mpi_account_admin?
    has_role? :mpi_account_admin
  end

  def subdomain
    account.subdomain
  end

  def safe_attributes
    self.attributes.except(
      'encrypted_password',
      'reset_password_sent_at',
      'remember_created_at',
      'reset_password_token',
      'current_sign_in_ip',
      'last_sign_in_ip',
      'confirmation_token',
      'account_id'
    )
  end

  def notify_account_admins
    return if account.nil?
    account.users.with_role(:account_admin).each do |account_admin|
      next if account_admin.email == self.email
      NewUserMailer.notify_account_admin(self, account_admin).deliver
    end
  end

  def notify_admins
    if !approved_by_admin?
      ActsAsTenant.with_tenant(nil) do
        User.with_role(:admin).each do |admin|
          NewUserMailer.notify_admin(self, admin).deliver
        end
      end
    end
  end

  def wants_email_notification?
    pref_email_notifications?
  end

  def features
    account && account.roles.map { |r| r.name }
  end

  def role_names
    roles.map { |r| r.name }
  end
end
