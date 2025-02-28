# frozen_string_literal: true

class Player < ApplicationRecord
  NULL_ATTRS = %w[title].freeze
  before_save :nil_if_blank
  validates :name, presence: true, uniqueness: { message: 'already exists' }
  require 'csv'

  ADMIN_RANKS = %w[Owner Deputy\ Owner General Captain PvM\ Organizer].freeze

  SKILLER_RANKS = {
    'opal' => 0..2_999_999,
    'sapphire' => 3_000_000..7_999_999,
    'emerald' => 8_000_000..14_999_999,
    'ruby' => 15_000_000..39_999_999,
    'diamond' => 40_000_000..89_999_999,
    'dragonstone' => 90_000_000..149_999_999,
    'onyx' => 150_000_000..499_999_999,
    'zenyte' => 500_000_000..Float::INFINITY
  }.freeze
  
  FIGHTER_RANKS = {
    'mentor' => 0..199,
    'prefect' => 100..299,
    'leader' => 300..499,
    'supervisor' => 500..699,
    'superior' => 700..899,
    'executive' => 900..1099,
    'senator' => 1100..1299,
    'monarch' => 1300..1499,
    'tzkal' => 1500..Float::INFINITY
  }.freeze

  def skiller?
    SKILLER_RANKS.key?(womrole&.downcase)
  end

  def fighter?
    FIGHTER_RANKS.key?(womrole&.downcase)
  end

  def admin?
    title
  end

  def rank_icon
    if skiller?
      "<i class='bi-gem' style='font-size: 1rem; color: #{rank_color}'></i>".html_safe
    elsif fighter?
      image_file = fighter_image_file(womrole)
      ActionController::Base.helpers.image_tag(image_file, alt: 'Fighter Icon', style: 'width: 1rem; height: 1rem;')
    else
      "<i class='bi-question-circle' style='font-size: 1rem; color: grey;'></i>".html_safe
    end
  end

  def needs_update
    if skiller?
      current_xp = clan_xp
      rank_threshold = SKILLER_RANKS[womrole&.downcase]
    elsif fighter?
      current_xp = clan_ehb
      rank_threshold = FIGHTER_RANKS[womrole&.downcase]
    else
      return false
    end
  
    if rank_threshold && !rank_threshold.include?(current_xp)
      self.womrole = next_rank.downcase
      '❗'
    else
      nil
    end
  end

  def switch_role
    if skiller?
      new_role = FIGHTER_RANKS.keys.find { |rank| FIGHTER_RANKS[rank].include?(clan_ehb) }
      self.womrole = new_role.capitalize if new_role
    elsif fighter?
      new_role = SKILLER_RANKS.keys.find { |rank| SKILLER_RANKS[rank].include?(clan_xp) }
      self.womrole = new_role.capitalize if new_role
    else
      return false
    end
  
    save
  end

  def opposing_role
    if skiller?
      FIGHTER_RANKS.keys.find { |rank| FIGHTER_RANKS[rank].include?(clan_ehb) }&.titleize
    elsif fighter?
      SKILLER_RANKS.keys.find { |rank| SKILLER_RANKS[rank].include?(clan_xp) }&.titleize
    else
      ''
    end
  end

  def achievements_exist?
    achievements.present? && achievements.count.positive? && achievements[0].present? && achievements[0]['createdAt'].present? && achievements[0]['name'].present?
  end

  def achievements_ordered_by_date
    if achievements.count > 1
      achievements.sort_by { |a| a['createdAt'] }.reverse
    else
      achievements
    end
  end

  def has_3_achievements?
    achievements[3].present?
  end

  def achievement_date_checked(achievement)
    if achievement['createdAt'].present? && achievement['createdAt'].to_date > 5.years.ago
      "on #{achievement['createdAt'].to_date.strftime('%b %d, %Y')}"
    else
      ''
    end
  end

  def has_old_names?
    old_names.present? && old_names.count.positive? && old_names[0].present? && old_names[0]['name'].present?
  end

  def name_history
    if has_old_names?
      names = old_names.map { |a| a['oldName'] }
      names.join(', ')
    else
      ''
    end
  end

  def type
    build ? build.titleize : 'Not yet updated'
  end

  def place
    case siege_winner_place
    when 1
      3
    when 2
      2
    when 3
      1
    end
  end

  def siege_winner_place_icon
    case siege_winner_place
    when 1
      '🥇'
    when 2
      '🥈'
    when 3
      '🥉'
    else
      ''
    end
  end

  def self.to_csv
    players = Player.all

    CSV.generate do |csv|
      csv << %w[name lvl xp title rank current_lvl current_xp first_xp first_lvl gained_xp wom_id wom_name score
                inactive deactivated deactivated_xp deactivated_lvl deactivated_date reactivated_xp reactivated_lvl reactivated_date]
      players.each do |player|
        csv << [player.name, player.lvl, player.xp, player.title, player.rank, player.current_lvl, player.current_xp,
                player.first_xp, player.first_lvl, player.gained_xp, player.wom_id, player.wom_name,
                player.score, player.inactive, player.deactivated, player.deactivated_xp, player.deactivated_lvl,
                player.deactivated_date, player.reactivated_xp, player.reactivated_lvl, player.reactivated_date]
      end
    end
  end

  def officer
    admin_icon == '👑' || admin_icon == '🔑' || admin_icon == '🌟' || admin_icon == '🛠' || admin_icon == '🐉'
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

  def clan_ehb
    if ehb.to_i.positive?
      ehb.to_i
    else
      0
    end
  end

  def next_level
    if skiller?
      SKILLER_RANKS.each do |_, range|
        return range.end - clan_xp if range.include?(clan_xp)
      end
    elsif fighter?
      FIGHTER_RANKS.each do |_, range|
        return range.end - clan_ehb if range.include?(clan_ehb)
      end
    else
      0
    end
  end

  def clan_rank
    if skiller?
      SKILLER_RANKS.each do |rank, range|
        return rank.capitalize if range.include?(clan_xp)
      end
    elsif fighter?
      FIGHTER_RANKS.each do |rank, range|
        return rank.capitalize if range.include?(clan_ehb)
      end
    elsif admin?
      title.titleize
    else
      'Unknown'
    end
  end

  def current_wom_rank
    womrole&.titleize
  end

  # Set clan title icon
  def admin_icon
    case title
    when 'Owner'
      '👑'
    when 'Deputy Owner'
      '🔑'
    when 'General'
      '🌟'
    when 'Captain'
      '🛠'
    when 'PvM Organizer'
      '🐉'
    else
      ''
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

  def next_rank
    if skiller?
      SKILLER_RANKS.each do |rank, range|
        return rank.capitalize if range.include?(clan_xp)
      end
      'Zenyte'
    elsif fighter?
      FIGHTER_RANKS.each do |rank, range|
        return rank.capitalize if range.include?(clan_ehb)
      end
      'TzKal'
    else
      'Unknown'
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
    return unless current_wom_rank != clan_rank

    '❗'
  end

  def join_date
    joined_date || created_at
  end

  def joined
    join_date.strftime('%b %d, %Y')
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

  # Set blanks to nil
  def nil_if_blank
    NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
  end

  private

  def fighter_image_file(womrole)
    "Clan_icon_-_#{womrole.titleize.gsub(' ', '_')}.png"
  end
end
