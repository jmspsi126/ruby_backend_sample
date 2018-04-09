class UsersController < ApplicationController
  before_filter :authenticate_and_scope!
  before_filter :authorize_account_admin!, except: [:current, :details, :update_current]
  load_and_authorize_resource except: [:current, :details, :update_current]

  attr_writer :local_locos, :remote_locos, :loco_adapter

  def local_locos
    @local_locos ||= Locomotive
  end

  def remote_locos
    @remote_locos ||= LIIS::Locomotive
  end

  def loco_adapter
    @loco_adapter ||= LocomotiveAdapter
  end

  def set_users_for_admin
    if current_tenant && current_user.admin?
      @users = @users.where(account_id: current_tenant.id)
    end
  end

  # GET /users
  # GET /users.json
  def index
    set_users_for_admin

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    # respond_to do |format|
    #   format.html {
    #     flash[:success] = "Saved user details."
    #     redirect_to user_details_path(@current_user)
    #   }

    #   format.json { render json: @user }
    # end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user.account = current_tenant
    selectable

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    selectable
  end

  # POST /users
  # POST /users.json
  def create
    if !current_tenant
      flash[:error] = "Please select an account before creating a user"
      render action: :new
      return
    end

    @user.account = current_tenant

    respond_to do |format|
      if @user.save
        @user.notify_admins
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    update_user(users_path)
  end

  # PUT /users/current
  def update_current
    @user = current_user
    update_user
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def invite
    if @user.fully_approved?
      @user.invite
      flash[:success] = "Successfully sent invitation to #{@user.email}"
    else
      flash[:error] = "Unable to send invite until user has been approved by the administrator."
    end
    redirect_to @user
  end

  def current
    @user_attrs = current_user.as_json

    if current_user.admin?
      @user_attrs["features"] = current_tenant.feature_names
    else
      @user_attrs["features"] = current_user.account.feature_names
    end

    render json: @user_attrs
  end

  def details
    @health_params = MonitoringParam.where(  :param_type => "health",
                                              :display_monitoring => true)
                                      .order("order_monitoring ASC")
    @status_params = MonitoringParam.where(  :param_type => "status",
                                              :display_monitoring => true)
                                      .order("order_monitoring ASC")
  end

  def company
    @account = current_tenant
    @locomotives = loco_adapter.adapt_all(local_locos.all, remote_locos.all(current_tenant))
    # @locomotives = Locomotive.where(account_id: current_tenant.id)
  end

  private
  def update_user(destination=user_details_path(@user))

    previous_approval_status = @user.fully_approved?

    respond_to do |format|
      if @user.update_attributes(params[:user])
        @user.notify_admins
        @user.invite_if_approval_changed(previous_approval_status)
        format.html { redirect_to destination, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def selectable
    @unselectable = {}
    @roles        = []
    case current_user
    when lambda(&:admin?)
      @unselectable = {account: false, mpi: false}
      @roles        = ["admin","account_admin","mpi_user","user"]
    when lambda(&:mpi_account_admin?)
      @unselectable = {account: true, mpi: false}
      @roles        = ["account_admin","mpi_user","user"]
    when lambda(&:account_admin?)
      @unselectable = {account: false, mpi: true}
      @roles        = ["account_admin","user"]
    else
      @unselectable = {account: true, mpi: true}
    end
    @collection = Role.where('name IN (?)', @roles)
  end
end
