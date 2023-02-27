class Player < ApplicationRecord
  NULL_ATTRS = %w( title )
  before_save :nil_if_blank

  def self.lower_name
    name.downcase
  end

  def clan_xp
    if self.current_xp.to_i > 0
      self.current_xp.to_i - self.xp.to_i
    else
      0
    end
  end

  def clan_lvl
    if self.current_lvl.to_i > 0
      self.current_lvl.to_i - self.lvl.to_i
    else
      "Player not found or OSRS API is down"
    end
  end

  def inactive
    case self.gained_xp
    when 0..1000000
      "red"
    else
      "white"
    end
  end

  def needs_update
    if self.clan_rank != self.rank
      "❗"
    end
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
    when "Staff"
      "🛠"
    when "PvM Organizer"
      "🐉"
    else
      ""
    end
  end

  # Set clan rank based on clan XP using a case statement
  def clan_rank
    case clan_xp
    when 0..3000000
      "Opal"
    when 3000000..7999999
      "Sapphire"
    when 8000000..14999999
      "Emerald"
    when 15000000..39999999
      "Ruby"
    when 40000000..89999999
      "Diamond"
    when 90000000..149999999
      "Dragonstone"
    when 150000000..499999999
      "Onyx"
    else
      "Zenyte"
    end
  end

  def rank_color
    case clan_xp
    when 0..3000000
      "moccasin"
    when 3000000..7999999
      "blue"
    when 8000000..14999999
      "lime"
    when 15000000..39999999
      "red"
    when 40000000..89999999
      "white"
    when 90000000..149999999
      "magenta"
    when 150000000..499999999
      "grey"
    else
      "orange"
    end
  end

  # Set blanks to nil
  def nil_if_blank
    NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
  end
end
