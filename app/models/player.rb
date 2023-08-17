# frozen_string_literal: true

class Player < ApplicationRecord
  NULL_ATTRS = %w[title].freeze
  before_save :nil_if_blank
  validates :name, presence: true, uniqueness: { message: 'already exists' }
  require 'csv'

  def self.lower_name
    name.downcase
  end

  def self.to_csv
    players = Player.all

    CSV.generate do |csv|
      csv << %w[name lvl xp title rank current_lvl current_xp first_xp first_lvl gained_xp wom_id wom_name score inactive deactivated deactivated_xp deactivated_lvl deactivated_date reactivated_xp reactivated_lvl reactivated_date]
      players.each do |player|
        csv << [player.name, player.lvl, player.xp, player.title, player.rank, player.current_lvl, player.current_xp,
                player.first_xp, player.first_lvl, player.gained_xp, player.wom_id, player.wom_name,
                player.score, player.inactive, player.deactivated, player.deactivated_xp, player.deactivated_lvl,
                player.deactivated_date, player.reactivated_xp, player.reactivated_lvl, player.reactivated_date]
      end
    end
  end

  def officer
    clan_title.present?
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

  def next_lvl
    case clan_xp
    when 0..3_000_000
      3_000_000 - clan_xp
    when 3_000_000..7_999_999
      8_000_000 - clan_xp
    when 8_000_000..14_999_999
      15_000_000 - clan_xp
    when 15_000_000..39_999_999
      40_000_000 - clan_xp
    when 40_000_000..89_999_999
      90_000_000 - clan_xp
    when 90_000_000..149_999_999
      150_000_000 - clan_xp
    when 150_000_000..499_999_999
      500_000_000 - clan_xp
    else
      0
    end
  end

  def next_rank_color
    case clan_xp
    when 0..3_000_000
      'blue'
    when 3_000_000..7_999_999
      'lime'
    when 8_000_000..14_999_999
      'red'
    when 15_000_000..39_999_999
      'white'
    when 40_000_000..89_999_999
      'magenta'
    when 90_000_000..149_999_999
      'grey'
    else
      'orange'
    end
  end

  def kickable
    if inactive == true
      'yellow'
    elsif gained_xp.to_i < 2_000_000
      'red'
    else
      'white'
    end
  end

  def two_month_gains
    if inactive == true
      'Inactive'
    else
      gained_xp.to_i
    end
  end

  def needs_update
    return unless clan_rank != rank

    '❗'
  end


  def join_date
    joined_date ? joined_date : created_at    
  end

  def joined
    join_date.strftime('%b %d, %Y')
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
    when 'Siege Winner'
      '🏆'
    else
      ''
    end
  end

  def new_check
    if created_at > 2.months.ago
      '🚸 New'
    else
      ''
    end
  end

  def created
    if og == true
      'OG*'
    else
      created_at.strftime('%b %d, %Y')
    end
  end

  def og
    created_at < '2023-02-26'.to_date
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
