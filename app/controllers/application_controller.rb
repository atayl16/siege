# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :check_for_redirection

  def check_for_redirection
    @new_site_url = "https://www.siege-clan.com"
    # Skip for API requests or if the user has chosen to stay
    return if request.format.json? || session[:stay_on_old_site] || request.path == "/staying"
    
    # Redirect to a transition page
    redirect_to redirect_notice_path unless controller_name == 'welcome' && action_name == 'redirect_notice'
  end
  
  # New action to allow users to continue using old site temporarily
  def staying
    session[:stay_on_old_site] = true
    redirect_to root_path, notice: "You'll remain on this site for this session. Please update your bookmarks soon."
  end

  def store_location
    if request.path != '/users/sign_in' &&
       request.path != '/users/sign_up' &&
       request.path != '/users/password/new' &&
       request.path != '/users/password/edit' &&
       request.path != '/users/confirmation' &&
       request.path != '/users/sign_out' &&
       !request.xhr? && !current_user # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(_resource)
    previous_path = session[:previous_url]
    session[:previous_url] = nil
    previous_path || root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    request.referrer
  end
end
