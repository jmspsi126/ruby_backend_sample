class ConfirmationsController < Devise::ConfirmationsController
  def show
    token = params[:confirmation_token]
    self.resource = resource_class.find_by_confirmation_token token
    super if resource.nil? || resource.confirmed?
  end

  def confirm
    token = resource_params[:confirmation_token]
    passwords = resource_params.except :confirmation_token
    self.resource = resource_class.find_by_confirmation_token token

    if resource.update_and_confirm(passwords)
      set_flash_message :notice, :confirmed
      sign_in_and_redirect resource_name, resource
    else
      render :action => "show"
    end
  end
end

