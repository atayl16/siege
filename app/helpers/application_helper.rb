# frozen_string_literal: true

module ApplicationHelper

  def clan_icon(rank_name)
    # Special case for TzKal with its unique capitalization
    if rank_name.downcase == "tzkal"
      image_path = "Clan_icon_-_TzKal.png"
    else
      # For other ranks: standard capitalization
      image_path = "Clan_icon_-_#{rank_name.capitalize}.png"
    end
    
    begin
      # Check if we can render this image
      image_tag(image_path, alt: "#{rank_name.titleize} Icon", style: 'width: 1rem; height: 1rem;')
    rescue => e
      # Fall back to a Bootstrap icon if the image can't be found
      "<i class='bi bi-trophy-fill' style='font-size: 1rem; color: gold;'></i>".html_safe
    end
  end
  
  def player_count
    Player.where(deactivated: false).count + (Var.where(name: 'hidden_players').first.value.to_i || 0)
  end

  def logo
    if Var.where(name: 'logo').first.value && File.exist?("app/assets/images/#{Var.where(name: 'logo').first.value}")
      Var.where(name: 'logo').first.value
    else
      'siege_logo.png'
    end
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
