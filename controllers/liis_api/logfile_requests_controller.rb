  module LiisApi
  class LogfileRequestsController < LiisController
    include ApipieDescriptions::LogFileRequests
    respond_to :json

    apipie_log_file_requests_index
    def index
      respond_with LogfileRequest.pending
    end
    
    apipie_log_file_requests_update
    def update
      ActsAsTenant.with_tenant(nil) do
        logfile_request = LogfileRequest.find_by_liis_file_request_id(params[:id])
        logfile_request.status = :received
        logfile_request.save

        render json: true
      end
    end
  end
end
