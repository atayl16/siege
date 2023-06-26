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
    # show the winner name if it exists and show it on the next line
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

  def event_time
    if self.future_event
      "Starts " + local_time(starts) 
    elsif self.past_event
      "Ended " + local_time(ends)
    else
      "Ends " + local_time(ends)
    end
  end
end
