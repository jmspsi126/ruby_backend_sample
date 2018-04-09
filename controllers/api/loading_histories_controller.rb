class Api::LoadingHistoriesController < ApplicationController
  include ApipieDescriptions::LoadingHistories

  before_filter :authenticate_and_scope!
  before_filter :deny_access_if_not_enabled

  apipie_loading_histories_show
  def show
    loco = Locomotive.find(params[:locomotive_id])

    @history = LIIS::MonitoringParamHistory.fetch(
      locomotive_id: loco.id_assigned,
      at: timestamp,
      account_id: current_tenant.id,
      mode: "loading_history"
    )

    @history.build_history
    @history.merge_with(MonitoringParam)

    render json: @history.to_json
  end

  def deny_access_if_not_enabled
    deny_access unless current_tenant.has_feature_enabled?(:target_analysis)
  end

  def timestamp
    @timestamp ||= parse_date(params[:id]).to_i
  end

  def parse_date(date)
    DateTime.strptime(date, "%Y-%m-%dT%H:%M:%S%:z")
  end
end
