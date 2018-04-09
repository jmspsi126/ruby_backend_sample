class Role < ActiveRecord::Base
  attr_accessible :name, :resource_type

  has_and_belongs_to_many :users, join_table: "users_roles"
  belongs_to :resource, polymorphic: true

  scopify

  scope(:user_roles, -> { where(name: [:admin, :mpi_account_admin, :account_admin, :mpi_user, :user ]) })
end

