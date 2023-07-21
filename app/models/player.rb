# frozen_string_literal: true

class Player < ApplicationRecord
  NULL_ATTRS = %w[title].freeze
  before_save :nil_if_blank
  validates :name, presence: true, uniqueness: { message: 'already exists' } 

  def self.lower_name
    name.downcase
  end

  def clan_xp
    if current_xp.to_i.positive?
      current_xp.to_i - xp.to_i
    else
      0
    end
  end

  def clan_lvl
    if current_lvl.to_i.positive?
      current_lvl.to_i - lvl.to_i
    else
      'Player not found or OSRS API is down'
    end
  end

  def kickable
    if self.inactive == true
      'yellow'
    elsif self.gained_xp.to_i < 1000000
      'red'
    else
      'white'
    end
  end

  def two_month_gains
    if self.inactive == true
      "Inactive"
    else
      self.gained_xp.to_i
    end
  end

  def needs_update
    return unless clan_rank != rank

    '❗'
  end

  # Set clan title icon
  def clan_title
    case title
    when 'Owner'
      '👑'
    when 'Deputy Owner'
      '🔑'
    when 'Admin'
      '🌟'
    when 'Staff'
      '🛠'
    when 'PvM Organizer'
      '🐉'
    else
      ''
    end
  end


  def created
    if self.created_at > 2.months.ago
      self.created_at.strftime('%b %d, %Y') + ' (New)'
    elsif self.created_at < '2023-02-26'.to_date
      'OG'
    else
      self.created_at.strftime('%b %d, %Y')
    end
  end

  # Set clan rank based on clan XP using a case statement
  def clan_rank
    case clan_xp
    when 0..3_000_000
      'Opal'
    when 3_000_000..7_999_999
      'Sapphire'
    when 8_000_000..14_999_999
      'Emerald'
    when 15_000_000..39_999_999
      'Ruby'
    when 40_000_000..89_999_999
      'Diamond'
    when 90_000_000..149_999_999
      'Dragonstone'
    when 150_000_000..499_999_999
      'Onyx'
    else
      'Zenyte'
    end
  end

  def rank_color
    case clan_xp
    when 0..3_000_000
      'moccasin'
    when 3_000_000..7_999_999
      'blue'
    when 8_000_000..14_999_999
      'lime'
    when 15_000_000..39_999_999
      'red'
    when 40_000_000..89_999_999
      'white'
    when 90_000_000..149_999_999
      'magenta'
    when 150_000_000..499_999_999
      'grey'
    else
      'orange'
    end
  end

  # Set blanks to nil
  def nil_if_blank
    NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
  end
end
