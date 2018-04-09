class LocomotivesController < ApplicationController
  before_filter :authenticate_and_scope!
  before_filter :authorize_account_admin!, except: [:show]
  respond_to :json, :csv, :html

  def index

  end

  def show
  end

  # get /locomotives/:id/edit
  def edit
    @locomotive = Locomotive.find(params[:id])
  end

  # put /locomotives/:id/
  def update
   @locomotive = Locomotive.find(params[:id])

   respond_to do |format|
    if @locomotive.update_attributes(params[:locomotive])
     format.html { redirect_to company_path, notice: 'Locomotive was successfully updated.' }
    else
     format.html { render action: "edit", alert: 'Unable to save locomotive.' }
    end
   end
  end

end
