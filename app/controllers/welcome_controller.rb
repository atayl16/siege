# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index; end

  def redirect_notice
    @new_site_url = "https://www.siege-clan.com"
  end
end
