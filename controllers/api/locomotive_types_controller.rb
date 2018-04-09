module Api
  class LocomotiveTypesController < ApplicationController
    include ApipieDescriptions::LocomotiveTypes

    before_filter :authenticate_and_scope!

    respond_to :json

    apipie_locomotive_types_index
    def index
      @types = LocomotiveType.all
      respond_with @types
    end

  end
end
