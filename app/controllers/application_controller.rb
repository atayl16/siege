# frozen_string_literal: true

class ApplicationController < ActionController::Base
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
