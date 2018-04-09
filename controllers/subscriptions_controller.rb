class SubscriptionsController < ApplicationController
  before_filter :authenticate_and_scope!, :authorize_account_admin!

  def update
    @fault = Fault.find(params[:fault_id])
    @fault.toggle(:needs_notification).save
    update_liis_notification_settings

    respond_to do |f|
      f.html do
        flash[:notice] = "Successfully updated subscription"
        redirect_to controller: :faults, action: :index
      end
      f.js do
        #render javascript
      end
      f.json do
        render :json => { subscribe_button_text: @fault.subscribe_button_text }
      end
    end
  end

  private
  def update_liis_notification_settings
   # return true #delete this line when LIIS endpoint is up
    LIIS.update_notification_settings(
      current_tenant.id,
      @fault.to_notification_settings
    )
  end
end

