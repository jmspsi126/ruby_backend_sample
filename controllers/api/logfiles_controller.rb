module Api
  class LogfilesController < ApplicationController
    include ApipieDescriptions::Logfiles

    before_filter :authenticate_and_scope!

    apipie_logfiles_index
    def index
      local_loco = Locomotive.find(params[:locomotive_id])
      system = System.find(params[:system_id])

      @requests = LogfileRequest.where(
        status: :pending,
        liis_locomotive_id: local_loco.id_assigned,
        liis_system_id: system.id_assigned
      ).map { |r| r.to_logfile }

      @logfiles = Logfile.all(root_path, {
        customer_id: current_tenant.id,
        locomotive_id: local_loco.id_assigned,
        system_id: system.id_assigned
      }).include(@requests).arrange_by_date

      render json: @logfiles.to_json
    end

    def show
      filename = "#{params[:filename]}"

      @logfile = Logfile.find(root_path, {
        customer_id: current_tenant.id,
        year: params[:year],
        month: params[:month],
        day: params[:day],
        locomotive_id: params[:locomotive_id],
        system_id: params[:system_id],
        filename: filename
      })

      if @logfile
        send_file File.join(root_path, @logfile.path)
      else
        render text: "", status: :not_found
      end
    end

    private
    def root_path
      ENV['LOGFILE_PATH']
    end
  end
end

