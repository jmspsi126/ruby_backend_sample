class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    user.account ||= Account.new

    if user.admin?
      can :manage, :all
    elsif user.mpi_user?
      can :manage, :all
    elsif user.mpi_account_admin?
      can :manage, :all
    else
      if user.account_admin?
        can :manage, User, account_id: user.account.id
      end
    end

  end
end
