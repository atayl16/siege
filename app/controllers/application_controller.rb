class ApplicationController < ActionController::Base
  # Skip authentication and other database-dependent filters
  skip_before_action :verify_authenticity_token, raise: false
  
  def staying
    redirect_to "https://www.siege-clan.com", allow_other_host: true
  end
end
