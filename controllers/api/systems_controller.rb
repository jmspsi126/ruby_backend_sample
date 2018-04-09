module Api
  class SystemsController < ApplicationController
    include ApipieDescriptions::Systems

    before_filter :authenticate_and_scope!

    apipie_systems_show
    def show
      @system = System.find(params[:id])
      @system.include_file_flags_for(loco)

      render json: @system.to_json
    end

    apipie_systems_index
    def index
      @systems = System.all
      @systems.each do |system|
        system.include_file_flags_for(loco)
      end

      render json: @systems.to_json
    end

    private
    def loco
      @loco ||= find_loco
    end

    def find_loco
      _loco = Locomotive.find(params[:locomotive_id])
      LIIS::Locomotive.find(_loco.id_assigned, current_tenant)
    end
  end
end

