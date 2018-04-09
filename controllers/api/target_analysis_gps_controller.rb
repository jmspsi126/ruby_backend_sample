class Api::TargetAnalysisGpsController < ApplicationController
  include ApipieDescriptions::TargetAnalysisGps

  respond_to :json
  before_filter :authenticate_and_scope!
  before_filter :deny_access_if_not_enabled

  apipie_target_analysis_gps_show
  def show
    @ta_req = Api::TargetAnalysisGpsRequest.new(params)

    if @ta_req.valid?
      loco = Locomotive.find(params[:locomotive_id])
      @ta = @ta_req.send_request(loco.id_assigned, current_tenant.id)

      respond_with @ta
    else
      respond_with({ errors: @ta_req.error_messages }, status: 400)
    end
  end

  def deny_access_if_not_enabled
    deny_access unless current_tenant.has_feature_enabled?(:target_analysis)
  end
end
