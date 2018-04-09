module Api
  class SystemStatusesController < ApplicationController

    before_filter :authenticate_user!
    respond_to :json
    
    def index
      loco = Locomotive.find(params[:locomotive_id])
      @systems = LIIS::Locomotive.find(loco.id_assigned, current_tenant).systems
      respond_with @systems
    end
  end
end

