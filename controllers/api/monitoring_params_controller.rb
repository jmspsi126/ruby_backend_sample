require 'zip/zip'
Mime::Type.register "application/zip", :zip

module Api
  class MonitoringParamsController < ApplicationController
    include ApipieDescriptions::MonitoringParams

    before_filter :authenticate_and_scope!
    respond_to :json, :csv

    def local_locos
      @local_locos ||= Locomotive
    end

    def remote_locos
      @remote_locos ||= LIIS::Locomotive
    end

    # feed for monitoring charts
    # LIIS: /locomotives/1/healthparams/ai20?from=2013-06-29&to=2013-07-30
    # rails: /api/locomotives/1/healthparams/ai20/?from=2013-07-01&to=2013-07-02
    apipie_monitoring_params_search_health
    def search_health
      param_title = MonitoringParam.find_by_qes_variable(params['qes_variable']).title.downcase
      respond_to do |format|
        format.json do 
          loco = local_locos.find(params[:locomotive_id])
          liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
          group =  LIIS::GroupIdentifier.new(params)
          render json: liis_loco.health_params(group, params)
        end
        format.zip do
          loco_ids = params[:loco_ids].split(",")
          csv_zip = Zip::ZipOutputStream.write_buffer do |zipfile|
            data = []
            loco_ids.each do |loco_id|
              loco = local_locos.find(loco_id)
              liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
              group =  LIIS::GroupIdentifier.new(params)
              params.delete(:to) if params[:to].blank?
              data = data + liis_loco.health_params(group, params.merge(format: :json))
            end
            csv_data = CSV.generate do |csv|
              csv << ["active_alarms", "gps", "time and date", param_title, "loco"]
              data.each do |record|
                active_value = record.active_alarms
                gps_value = record.gps
                date_time_value = record.time_utc
                loco_name_value = record.locomotive_name
                loco_value = record.value
                csv << [active_value, gps_value, date_time_value, loco_value, loco_name_value]
              end
            end
            @file_name = param_title.gsub(" ","-") + '_' + params[:from]
            @file_name += "_#{params[:to]}" unless params[:to].nil?
            zipfile.put_next_entry("#{@file_name}.csv")
            zipfile.write(csv_data)
          end
          csv_zip.rewind
          send_data(csv_zip.read, :filename => "#{@file_name}.zip", :type => 'application/zip')
        end
      end
    end

    # feed for monitoring charts
    # LIIS: /locomotives/1/statusparams/di17?from=2013-06-29&to=2013-07-30
    # rails: /api/locomotives/1/statusparams/di17/?from=2013-07-01&to=2013-07-02
    apipie_monitoring_params_search_status
    def search_status
      param_title = MonitoringParam.find_by_qes_variable(params['qes_variable']).title.downcase
      respond_to do |format|
        format.json do
          loco = local_locos.find(params[:locomotive_id])
          liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
          group =  LIIS::GroupIdentifier.new(params)
          render json: liis_loco.status_params(group, params)
        end
        format.zip do
          loco_ids = params[:loco_ids].split(",")
          csv_zip = Zip::ZipOutputStream.write_buffer do |zipfile|
            data = []
            loco_ids.each do |loco_id|
              loco = local_locos.find(loco_id)
              liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
              group =  LIIS::GroupIdentifier.new(params)
              params.delete(:to) if params[:to].blank?
              data = data + liis_loco.status_params(group, params.merge(format: :json))
            end
            csv_data = CSV.generate do |csv|
              csv << ["active_alarms", "gps", "time and date", param_title, "loco"]
              data.each do |record|
                active_value = record.active_alarms
                gps_value = record.gps
                date_time_value = record.time_utc
                loco_name_value = record.locomotive_name
                loco_value = record.value
                csv << [active_value, gps_value, date_time_value, loco_value, loco_name_value]
              end
            end
            @file_name = param_title.gsub(" ","-") + '_' + params[:from]
            @file_name += "_#{params[:to]}" unless params[:to].nil?
            zipfile.put_next_entry("#{@file_name}.csv")
            zipfile.write(csv_data)
          end
          csv_zip.rewind
          send_data(csv_zip.read, :filename => "#{@file_name}.zip", :type => 'application/zip')
        end
      end
    end

    def index
      @params_csv = MonitoringParam.to_csv
      @params = MonitoringParam.all
      respond_to do |format|
        format.json { respond_with(@params) }
        format.csv { send_data @params_csv }
      end
    end

    # all params - for BOS
    def monitoring
      @params = MonitoringParam.all
      respond_with(@params)
    end
    # just health for graph parameter list /api/healthmonitoring.json
    def health_monitoring
      @params = MonitoringParam.health.for_display
      respond_with(@params)
    end
    # just status for graph parameter list /api/statusmonitoring.json
    def status_monitoring
      @params = MonitoringParam.status.for_display
      respond_with(@params)
    end

    # LIIS:   /locomotives/1/latest_health
    # rails:  /api/locomotives/1/healthparams/latest
    apipie_monitoring_params_latest_health
    def latest_health
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      liis_params = liis_loco.latest_health_params(params)
      cms_params = MonitoringParam.health.all

      respond_with MonitoringParamAdapter.adapt_all(cms_params, liis_params)
    end

    apipie_monitoring_params_latest_status
    def latest_status
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      liis_params = liis_loco.latest_status_params(params)
      cms_params = MonitoringParam.status.all

      respond_with MonitoringParamAdapter.adapt_all(cms_params, liis_params)
    end

    def import
      # binding.pry
      MonitoringParam.import(params[:file])
      redirect_to users_url, notice: "Monitoring Params imported."
    end

    def import_master
      MonitoringParam.import_from_master(params[:param_csv], params[:ta_map_csv], params[:category_map_csv])
      redirect_to users_url, notice: "Monitoring Params imported."
    end

    def locomotive_type
      @loco_types = LocomotiveType.all
    end

    private
    def latest_health_source
      @latest_health_source ||= LIIS::HealthParams
    end

    def latest_status_source
      @latest_status_source ||= LIIS::StatusParams
    end
  end
end
