module Api
  class FaultsController < ApplicationController
    include ApipieDescriptions::Faults

    before_filter :authenticate_and_scope!
    respond_to :json, :csv

    def local_locos
      @local_locos ||= Locomotive
    end

    def remote_locos
      @remote_locos ||= LIIS::Locomotive
    end

    def local_faults
      @local_faults ||= Fault
    end

    def fault_adapter
      @fault_adapter ||= FaultAdapter
    end

    def show
      loco = local_locos.find(params[:id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      respond_with liis_loco.current_faults
    end

    # /api/faults.json - for rails - kb
    def index
      @faults = Fault.all
      respond_to do |format|
        format.json {
          render :json => @faults.to_json(methods: :system_name)
        }
      end
    end

    # /api/faults.json - for BOS
    apipie_faults_faults_all
    def faults_all
      @faults = Fault.for_display
      respond_to do |format|
        format.json {
          render :json => @faults,
          :only =>  [ :code_display, :account_id, :severity, :title,
                      :data_dictionary, :system_id, :id, :needs_notification]
        }
      end
    end

    # /api/faults/43.json
    apipie_faults_show_one
    def show_one
      # @fault = Fault.where( code_display: params[:fault_id] )
      @fault = Fault.where(:qes_variable => params[:fault_id].split(','))
      @fault = @fault.first if @fault.length == 1
      respond_to do |format|
        format.json {
          render :json => @fault.to_json(methods: :system_name)
        }
      end
    end

    def summary
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      liis_faults = liis_loco.fault_summary(params)
      render json: fault_adapter.adapt_all(local_faults.for_display, liis_faults, loco).to_json
    end

    def summary_warning_critical
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      liis_faults = liis_loco.fault_summary_warning_critical(params)

      render json: fault_adapter.adapt_all(local_faults.for_display, liis_faults, loco).to_json
    end

    def summary_critical
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      liis_faults = liis_loco.fault_summary_critical(params)
      render json: fault_adapter.adapt_all(local_faults.for_display, liis_faults, loco).to_json
    end

    def summary_minute
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      liis_faults = liis_loco.fault_summary_minute(params)
      render json: fault_adapter.adapt_all(local_faults.for_display, liis_faults, loco).to_json
    end

    def archive
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      liis_faults = liis_loco.fault_archive(params)
      render json: fault_adapter.adapt_all(local_faults.for_display, liis_faults, loco).to_json
    end

    def archive_warning_critical
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      liis_faults = liis_loco.fault_archive_warning_critical(params)
      render json: fault_adapter.adapt_all(local_faults.for_display, liis_faults, loco).to_json
    end

    def archive_critical
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      liis_faults = liis_loco.fault_archive_critical(params)
      render json: fault_adapter.adapt_all(local_faults.for_display, liis_faults, loco).to_json
    end

    def archive_minute
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      liis_faults = liis_loco.fault_archive_minute(params)
      render json: fault_adapter.adapt_all(local_faults.for_display, liis_faults, loco).to_json
    end

    private

  end
end

