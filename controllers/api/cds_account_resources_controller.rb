module Api
  class CdsAccountResourcesController < ApplicationController
    include ApipieDescriptions::CdsAccountResources

    before_filter :authenticate_and_scope!

    respond_to :json

    apipie_cds_account_resources_index
    def index
      resources = CdsAccountResource.resources
      respond_to do |format|
        format.json {
          render :json => resources.to_json(methods: [:category_name, :file_url])
        }
      end
    end
  end
end
