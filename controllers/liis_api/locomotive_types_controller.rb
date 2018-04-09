module LiisApi
  class LocomotiveTypesController < LiisController 
    include ApipieDescriptions::LiisLocomotiveTypes
    respond_to :json

    apipie_liis_locomotive_types_index
    def index
      respond_with LocomotiveType.all
    end
  end
end