module Api
  class SendFileFlagsController < ApplicationController
    include ApipieDescriptions::SendFileFlags

    attr_writer :liis_locos, :logfile_requests, :date
    before_filter :authenticate_and_scope!

    apipie_send_file_flags_index
    def index
      all_flags = find.flags_for(loco, system)

      enabled_flags = all_flags.select do |flag|
        !current_tenant.has_role?("disable_flag_#{flag.name}")
      end

      render json: enabled_flags
    end

    apipie_send_file_flags_show
    def show
      render json: find.flag_for(loco, system, flag).to_json
    end

    apipie_send_file_flags_update
    def update
      find.flag_for(loco, system, flag)
      set_send_file_flag unless flag.pending?

      render json: flag.to_json
    end

    private
    def set_send_file_flag
      Rails.logger.info("Sending request to LIIS")
      result = loco.set_send_file_flag(flag)
      Rails.logger.info("Finished sending request")
      Rails.logger.info(result.to_yaml)

      logfile_requests.create!({
        liis_locomotive_id: loco.id,
        liis_system_id: system.id_assigned,
        liis_file_request_id: result.id,
        send_file_flag_enum_value: flag.enum_value,
        status: :pending,
        label: flag.description,
        date: date.today
      })

      flag.pending = true
    end

    def find
      @find ||= FindSendFileFlags.new(
        logfile_requests,
        loco.send_file_flags_for_system(system)
      )
    end

    def liis_locos
      @liis_locos ||= LIIS::Locomotive
    end

    def logfile_requests
      @logfile_requests ||= LogfileRequest
    end

    def loco
      @loco ||= begin
                  Rails.logger.info params.to_yaml
                  local_loco = Locomotive.find params[:locomotive_id]
                  Rails.logger.info "Found loco with id_assigned #{local_loco.id_assigned}"
                  remote = liis_locos.find(local_loco.id_assigned, current_tenant)
                  Rails.logger.info "Fetched remote loco w/ id #{remote.id}"
                  remote
                end
    end

    def system
      @system ||= System.find(params[:system_id])
    end

    def flag
      @flag ||= LIIS::SendFileFlag.for(params[:id].to_i)
    end

    def date
      @date ||= Date
    end
  end
end

