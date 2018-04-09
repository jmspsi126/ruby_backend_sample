class ChangePassword
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Serialization
  include ActiveModel::Conversion

  attr_accessor :password, :password_confirmation, :current_password

  validates_presence_of :password, :password_confirmation

  validate :passwords_match, :current_password_match

  def initialize(user=nil)
    @user = user
  end

  def persisted?
    return false
  end

  def passwords_match
    unless password == password_confirmation
      self.errors.add(:password, "doesn't match confirmation.")
    end
  end

  def current_password_match
    unless @user.valid_password?(current_password)
      self.errors.add(:current_password, "doesn't match current password.")
    end
  end

end
