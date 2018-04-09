module LiisApi
  class FaultsController < LiisController
    include ApipieDescriptions::LiisFaults
    respond_to :json

    apipie_liis_faults_index
    def index
      @faults = Fault.all

      respond_with @faults.as_json(
        only: [ :code_display, :account_id, :severity, :title,
                :data_dictionary, :system_id, :needs_notification, :id, :hidden]
      )
    end
  end
end
