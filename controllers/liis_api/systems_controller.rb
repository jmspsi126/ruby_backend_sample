module LiisApi
  class SystemsController < LiisController 
    include ApipieDescriptions::LiisSystems
    respond_to :json

    apipie_liis_systems_index
    def index
      respond_with System.all
    end
  end
end