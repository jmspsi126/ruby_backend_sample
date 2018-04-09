class PasswordsController < ApplicationController
  def edit
    @current_user = current_user
    @change_password = ChangePassword.new
  end

  def update
    @current_user = current_user
    @user = User.find(params[:user_id])
    @change_password = ChangePassword.new(@user)
    user_params = params[:change_password]
    @change_password.password = user_params[:password]
    @change_password.password_confirmation = user_params[:password_confirmation]
    @change_password.current_password = user_params[:current_password]

    if @change_password.valid?
      @user.password = @change_password.password
      @user.save
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to user_details_path, notice: 'Password was successfully updated.'
    else
      render "edit"
    end
  end

end