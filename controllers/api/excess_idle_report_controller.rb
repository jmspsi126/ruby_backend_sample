module Api
  class ExcessIdleReportController < ApplicationController
    # include ApipieDescriptions::ExcessIdle

    def index
      param_data = ParamData.new(:customer_id, :locmotive_id)
      @health_data = param_data.search_for(Health, params)
      @status_data = param_data.search_for(Status, params)
      # format.json render :partial => "excess_idle_report/index"
      render :action => 'index.html'
    end
  end
end
