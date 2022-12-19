class Player < ApplicationRecord
  NULL_ATTRS = %w( title )
  before_save :nil_if_blank

  def clan_xp
    if self.current_xp.to_i > 0
      self.current_xp.to_i - self.xp.to_i
    else
      0
    end
  end

  def clan_lvl
    if self.current_lvl.to_i > 0
      self.current_lvl.to_i ? self.current_lvl.to_i - self.lvl.to_i : "OSRS API is down"
    else
      0
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
    else
      ""
    end
  end

  # Set clan rank based on clan XP using a case statement
  def clan_rank
    case clan_xp
    when 0..3000000
      # "Opal"
      "moccasin"
    when 3000000..7999999
      # "Sapphire"
      "blue"
    when 8000000..14999999
      # "Emerald"
      "lime"
    when 15000000..39999999
      # "Ruby"
      "red"
    when 40000000..89999999
      # "Diamond"
      "white"
    when 90000000..149999999
      # "Dragonstone"
      "magenta"
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
