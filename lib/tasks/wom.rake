# frozen_string_literal: true

namespace :wom do
  desc 'Update players current info from external API'
  task update_all: :environment do
    require 'net/http'
    require 'uri'
    require 'json'

    wom = Rails.application.credentials.dig(:wom, :verificationCode)
    uri = URI.parse('https://api.wiseoldman.net/v2/groups/2928/update-all')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request.body = JSON.dump({
                               'verificationCode' => wom
                             })

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    puts response.code
    puts response.body
  end
end
