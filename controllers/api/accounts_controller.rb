module Api
  class AccountsController < ApplicationController
    include ApipieDescriptions::Accounts

    before_filter :authenticate_and_scope!

    respond_to :json
    apipie_accounts_show

    api :GET, "/users/:id", "Show user profile"
    
    def show
      resources = Account.find(params[:id])
      respond_to do |format|
        format.json {
          render :json => resources.to_json()
        }
      end
    end

  end
end
