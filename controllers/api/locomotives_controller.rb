module Api
  class LocomotivesController < ApplicationController
    include ApipieDescriptions::Locomotives

    before_filter :authenticate_and_scope!

    respond_to :json, :csv

    attr_writer :local_locos, :remote_locos, :loco_adapter

    def local_locos
      @local_locos ||= Locomotive
    end

    def remote_locos
      @remote_locos ||= LIIS::Locomotive
    end

    def loco_adapter
      @loco_adapter ||= LocomotiveAdapter
    end

    # feed for monitoring pages, populates locomotive list
    def locomotives_all
      @locomotives = Locomotive.all
      respond_with(@locomotives)
    end

    def index
      files = loco_adapter.adapt_all(local_locos.all, remote_locos.all(current_tenant))
      
      respond_to do |format|
        format.json {render json: files.to_json}
        format.csv do
          send_data files.to_csv, type: 'text/csv', disposition: 'attachment'
        end
      end
    end

    # feed for locomotive status
    # LIIS: /locomotives/:id
    # rails: /api/locomotives/:id
    # not in use: /locomotives/:id/loco_status
    def show
      loco = local_locos.find(params[:id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      @loco = loco_adapter.new(loco, liis_loco)
      respond_with @loco
    end

    # feed for system statuses on the locomotive data page
    # LIIS: /locomotives/:id/system_statuses
    # rails: /api/locomotives/:id/system_statuses
    apipie_locomotives_system_statuses
    def system_statuses
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      ap liis_loco.system_statuses(params)
      respond_with liis_loco.system_statuses(params)
    end

    # feed for featured parameters on the locomotive data page - Locomotive Data
    # LIIS: /locomotives/:id/locomotive_data
    # rails: /api/locomotives/:id/locomotive_data
    apipie_locomotives_locomotive_data
    def locomotive_data
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)

      locomotive_data_set = liis_loco.locomotive_data
      locomotive_data_set.merge_with(MonitoringParam)

      respond_with locomotive_data_set
    end

    # feed for featured parameters on the locomotive data page - Engine Data
    # LIIS: /locomotives/:id/engine_data
    # rails: /api/locomotives/:id/engine_data
    apipie_locomotives_engine_data
    def engine_data
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)

      engine_data_sets = liis_loco.engine_data

      engine_data_sets.each do |engine_data_set|
        engine_data_set.merge_with(MonitoringParam)
      end

      respond_with engine_data_sets
    end

    # feed for software versions on maintenance monitoring
    # LIIS: /locomotives/:id/software
    # rails: /api/locomotives/:id/software
    apipie_locomotives_locomotive_software
    def locomotive_software
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      respond_with liis_loco.locomotive_software(params)
    end

    # feed for fuel consumption on maintenance monitoring
    # LIIS: /locomotives/:id/fuel_consumption
    # rails: /api/locomotives/:id/fuel_consumption
    apipie_locomotives_fuel_consumption
    def fuel_consumption
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      respond_with liis_loco.fuel_consumption(params).each {|entry| entry['lfu'] = loco.pref_measurement_fuel}
    end

    # feed for fuel history on maintenance monitoring
    # LIIS: /locomotives/:id/fuel_history
    # rails: /api/locomotives/:id/fuel_history
    apipie_locomotives_fuel_history
    def fuel_history
      loco = local_locos.find(params[:locomotive_id])
      liis_loco = remote_locos.find(loco.id_assigned, current_tenant)
      respond_with liis_loco.fuel_history(params).entries.each {|entry| entry.lfu = loco.pref_measurement_fuel}
    end

    def update
      @locomotive = Locomotive.find(params[:id])

      if @locomotive.update_attributes(locomotive_params)
        render json: @locomotive.as_json(only: locomotive_params.keys)
      end
    end

    def locomotive_params
      allowed_params = ['out_of_service']
      params.select { |param, _| allowed_params.include?(param) }
    end

  end
end
