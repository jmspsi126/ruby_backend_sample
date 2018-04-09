class PagesController < ApplicationController
  # root path
  def index
    if user_signed_in?
      redirect_to fleetmanager_path
    end
    @body_id = "homepage"
  end

  def fleet_manager
    authenticate_and_scope!
    @body_id = "fleetmanager"
  end

  def privacy_policy
    @body_id = "privacy-policy"
  end

  def terms
    @body_id = "terms"
  end

end
