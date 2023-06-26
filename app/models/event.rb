class Event < ApplicationRecord
  def future_events
    Event.where('ends >= ?', Time.now)
  end

  def completed_events
    Event.where('ends < ?', Time.now)
  end

  def events_for_table
    future_events.order('ends ASC').all + completed_events.order('ends DESC').limit(1).all
  end

  def future_event 
    starts > Time.now
  end

  def past_event
    ends < Time.now
  end

  def current_event
    starts < Time.now && ends > Time.now
  end

  def status
    if Time.now > starts && Time.now < ends
      '🔥 Active'
    elsif Time.now < starts
      'Upcoming'
    else
      winner.nil? ? 'Ended' : '🥇' + winner
    end
  end

  def local_time(time)
    if time > Time.now
      time.localtime.strftime('%b %d %I:%M %P')
    else 
      time.localtime.strftime('%b %d')
    end
  end

  def utc_time(time)
    if time > Time.now
      time.strftime('%b %d %I:%M %P')
    else 
      time.strftime('%b %d %Y')
    end
  end

  def local_start_time
    local_time(starts)
  end

  def local_end_time
    local_time(ends)
  end

  def utc_start_time
    utc_time(starts)
  end

  def utc_end_time
    utc_time(ends)
  end

  def event_time
    if self.future_event
      "Starts " + local_time(starts) 
    elsif self.past_event
      "Ended " + local_time(ends)
    else
      "Ends " + local_time(ends)
    end
  end

  def wom_link
    if wom_id?
      "https://wiseoldman.net/competitions/#{wom_id}"
    else
      nil
    end
  end
end
