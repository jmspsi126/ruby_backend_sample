module LiisApi
  class MonitoringParamsController < LiisController
    include ApipieDescriptions::LiisMonitoringParams
    respond_to :json

    apipie_liis_monitoring_params_index
    def index
      respond_with MonitoringParam.all
    end
  end
end
