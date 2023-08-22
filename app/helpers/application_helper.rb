# frozen_string_literal: true

module ApplicationHelper
  def player_count
    Player.where(deactivated: false).count + 1
  end

  def external_link_to(name = nil, options = nil, html_options = nil, &block)
    opts = { target: '_blank', rel: 'nofollow noopener' }
    if block_given?
      options ||= {}
      options = options.merge(opts)
    else
      html_options ||= {}
      html_options = html_options.merge(opts)
    end
    link_to(name, options, html_options, &block)
  end

  def wom
    Rails.application.credentials.dig(:wom, :verificationCode)
  end

  def api_key
    Rails.application.credentials.dig(:wom, :apiKey)
  end
end
