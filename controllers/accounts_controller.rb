class AccountsController < ApplicationController
  before_filter :authorize_account_admin!

  def index
  end

  def show
    @accounts = Account.all
  end


  # get /accounts/:id/edit
  def edit
    @account = Account.find(params[:id])
    @account.script_time = Time.now
  end

  # put /accounts/:id/
  def update
   @account = Account.find(params[:id])

   respond_to do |format|
    minutes = params[:time]['script_time(4i)'].to_i * 60 + params[:time]['script_time(5i)'].to_i
    params[:account][:script_time] = minutes
    if @account.update_attributes(params[:account])
     format.html { redirect_to company_path, notice: 'The account was successfully updated.' }
    else
     format.html { render action: "edit", notice: 'Unable to save account.' }
    end
   end
  end

end
