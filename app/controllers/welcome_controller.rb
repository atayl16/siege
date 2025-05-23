# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:redirect_notice]
  skip_before_action :authenticate_user!, only: [:redirect_notice]
  def redirect_notice
    @new_site_url = "https://www.siege-clan.com"
  end
end
