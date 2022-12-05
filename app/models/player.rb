class Player < ApplicationRecord
  NULL_ATTRS = %w( title )
  before_save :nil_if_blank

  # Use external API with HTTParty to get player's current XP
  def current_xp
    require 'httparty'
    @url = HTTParty.get(
      "https://secure.runescape.com/m=hiscore_oldschool/index_lite.ws?player=#{self.name}",
      :headers =>{'Content-Type' => 'application/json'}
    )
    @url.split("\n")[0].split(",").map(&:to_i).last
  end

  # Use external API with HTTParty to get player's current lvl
  def current_lvl
    require 'httparty'
    @url = HTTParty.get(
      "https://secure.runescape.com/m=hiscore_oldschool/index_lite.ws?player=#{self.name}",
      :headers =>{'Content-Type' => 'application/json'}
    )
    @url.split("\n")[0].split(",").map(&:to_i).second
  end

  def clan_xp
    current_xp - self.xp
  end

  def clan_lvl
    current_lvl - self.lvl
  end

  # Set clan title icon
  def clan_title
    case title
    when "Owner"
      "👑"
    when "Deputy Owner"
      "🔑"
    when "Admin"
      "🌟"
    else
      ""
    end
  end

  # Set clan rank based on clan XP using a case statement
  def clan_rank
    case clan_xp
    when 0..3000000
      # "Opal"
      "yellow"
    when 3000000..7999999
      # "Sapphire"
      "blue"
    when 8000000..14999999
      # "Emerald"
      "green"
    when 15000000..39999999
      # "Ruby"
      "red"
    when 40000000..89999999
      # "Diamond"
      "white"
    when 90000000..149999999
      # "Dragonstone"
      "purple"
    when 150000000..499999999
      # "Onyx"
      "grey"
    else
      # "Zenyte"
      "orange"
    end
  end

  # Set blanks to nil
  def nil_if_blank
    NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
  end
end
