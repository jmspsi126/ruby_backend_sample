require './lib/uri_extensions'

class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from LIIS::Error, with: :liis_error
  rescue_from Faraday::Error::ClientError, with: :liis_error

  set_current_tenant_through_filter
  before_filter :get_current_tenant

  def get_current_tenant
    acct = Account.find_by_subdomain(current_uri.subdomain)
    set_current_tenant(acct)
  end

  def authorize_admin!
    authenticate_user!

    unless current_user.admin?
      flash[:alert] = "You are not authorized to view that page"
      redirect_to root_url(host: request.host)
    end
  end

  def force_subdomain!
    return unless user_signed_in?

    if current_user.admin? && using_root_url?

      # admin accessing root url
      show_accounts_list

    elsif current_user.admin? && current_tenant.nil?

      # admin accessing a non existent subdomain
      not_found

    elsif current_user.admin? && current_tenant.present?

      # admin accessing an existing subdomain
      return

    elsif current_user.mpi_user? or current_user.mpi_account_admin?
      return

    elsif !subdomain_matches_user_account?

      # signed in user (non-admin) accessing a subdomain that is different from
      # the one that is associated to their account
      redirect_to_correct_subdomain

    end

  end

  def using_root_url?
    current_uri.host == default_url_options[:host]
  end

  def show_accounts_list
    redirect_to accounts_path
  end

  def subdomain_matches_user_account?
    current_uri.subdomain.downcase == current_user.subdomain.downcase
  end

  def redirect_to_correct_subdomain
    current_uri.subdomain = current_user.subdomain
    redirect_to current_uri.to_s
  end

  def current_uri
    @current_uri ||= URI(request.url)
  end

  def authenticate_and_scope!
    authenticate_user!
    force_subdomain!
  end

  def authorize_account_admin!
    return if current_user.has_any_role? :admin, :account_admin, :mpi_user, :mpi_account_admin

    flash[:alert] = "You are not authorized to view that page"
    redirect_to root_path
  end

  def liis_error
    render json: { error: $!.message }, status: 500
  end

  def deny_access
    render(text:'', status: 401)
  end

  def not_found
    render file: Rails.root.join("public/404.html"), layout: false, status: 404
  end
end
