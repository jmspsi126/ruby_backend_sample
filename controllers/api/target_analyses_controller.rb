class Api::TargetAnalysesController < ApplicationController
  include ApipieDescriptions::TargetAnalyses

  before_filter :authenticate_and_scope!
  before_filter :deny_access_if_not_enabled

  apipie_target_analyses_show
  def show
    @ta_req = Api::TargetAnalysisRequest.new(params)

    if @ta_req.valid?
      loco = Locomotive.find(params[:locomotive_id])

      @target_analysis = @ta_req.send_request(
        loco.id_assigned,
        current_tenant.id
      )
    else
      render(json: { errors: @ta_req.error_messages }, status: 400)
    end
  end

  def deny_access_if_not_enabled
    deny_access unless current_tenant.has_feature_enabled?(:target_analysis)
  end
end
