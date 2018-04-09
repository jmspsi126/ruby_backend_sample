class FaultsController < ApplicationController
  before_filter :authenticate_and_scope!, :authorize_account_admin!
  respond_to :json, :csv, :html

  def index
    @faults = Fault.order("title ASC")
    @faults_csv = Fault.to_csv
    respond_to do |format|
      format.html { @faults }
      format.json { respond_with(@faults) }
      format.csv { send_data @faults_csv }
    end
  end

  def visibilities
    @faults = Fault.order("title ASC")
  end

  def visibility
    @fault = Fault.find(params[:fault_id])
    @fault.toggle(:hidden).save
    Fault.new.visibility_sync(@fault)
  end

  def import
    Fault.import(params[:file])
    redirect_to users_url, notice: "Faults imported."
  end

  def import_from_master
    Fault.import_from_master(params[:file])
    redirect_to users_url, notice: "Faults imported."
  end

  def manage_assets
    @loco_types = LocomotiveType.all
  end

  def associate_params
    Fault.associate_params(params[:file])
    redirect_to users_url, notice: "Faults imported."
  end

  def resolution_notes
    @resolution_notes = ResolutionNote
      .where(:fault_id => params[:fault_id])
      .order("created_at ASC")
    respond_to do |format|
      format.json { render json: @resolution_notes.to_json(include: :user) }
    end
  end

end
