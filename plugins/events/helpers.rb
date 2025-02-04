module AresMUSH
  module Events
    def self.can_manage_events?(actor)
      actor && actor.has_permission?("manage_events")
    end

    def self.ical_path
      File.join(AresMUSH.game_path, 'calendar.ics')
    end
        
    def self.parse_date_time_desc(str)
      begin
        separator = OOCTime.date_element_separator
        if (separator == '-')
          split = str.split('/')
          date = split[0]
          desc = split[1]
        elsif (separator == '/')
          split = str.split('/')
          date = split[0..2].join('/')
          desc = split[3..-1].join('/')
        elsif (separator == ' ')
          split = str.split('/')
          date = split[0]
          desc = split[1]
        else
          raise "Unrecognized date time separator.  Check your 'short' date format in datetime.yml."
        end

        
        
        date_time = OOCTime.parse_datetime(date.strip.downcase)
        if (date_time < DateTime.now)
          return nil, nil, t('events.no_past_events')
        end
        
        return date_time, desc, nil
      rescue Exception => e
        error = t('events.invalid_event_date', 
        :format_str => Global.read_config("datetime", "date_and_time_entry_format_help"))        
        return nil, nil, error
      end
    end
    
    
    def self.with_an_event(num, client, enactor, &block)
      events = Event.sorted_events
      if (num < 0 || num > events.count)
        client.emit_failure t('events.invalid_event')
        return
      end
      
      yield events.to_a[num - 1]
    end    
    
    def self.can_manage_event?(enactor, event)
      return Events.can_manage_events?(enactor) || enactor == event.character
    end
    
    def self.signup_for_event(event, char, comment)
      signup = event.signups.select { |s| s.character == char }.first
      
      if (signup)
        signup.update(comment: comment)
      else
        EventSignup.create(event: event, character: char, comment: comment)
      end
    end
    
    def self.create_event(enactor, title, datetime, desc, warning, tags)
      event = Event.create(title: title, 
      starts: datetime, 
      description: desc,
      character: enactor,
      content_warning: warning)
      
      Website.update_tags(event, tags)  
      Channels.announce_notification(t('events.event_created_notification', :title => title))
      Events.events_updated
      Achievements.award_achievement(enactor, "event_created")
	  PostEvent.create_forum_post(event)
      return event
    end
   
    def self.delete_event(event, enactor)
      title = event.title
      message = t('events.event_deleted_notification', :title => title)
      event.signups.each do |s|
        Login.notify(s.character, :event, message, event.id)
      end
      Channels.announce_notification(message)

      event.delete
      Events.events_updated
    end
   
    def self.update_event(event, enactor, title, datetime, desc, warning, tags)
      event.update(title: title)
      event.update(starts: datetime)
      event.update(description: desc)
      event.update(content_warning: warning)

      Website.update_tags(event, tags)     
      Events.events_updated
      message = t('events.event_updated_notification', :title => title)
      event.signups.each do |s|
        Login.notify(s.character, :event, message, event.id)
      end
      Channels.announce_notification(message)
	  if Global.read_config("postevent", "reply_on_edit") then PostEvent.reply_to_forum_post(event) end
    end
   
    def self.format_timestamp(time)
      time.utc.iso8601.gsub(":", "").gsub("-", "")
    end
    
    def self.events_updated
      File.open(Events.ical_path, 'w') do |f|
        f.puts "BEGIN:VCALENDAR\r\n"
        f.puts "VERSION:2.0\r\n"
        f.puts "PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n"
                  
        Event.all.each do |event|
          f.puts "BEGIN:VEVENT\r\n"
          f.puts "UID:#{event.ical_uid}\r\n"
          f.puts "DTSTART:#{Events.format_timestamp(event.starts)}\r\n"
          f.puts "DTSTAMP:#{Events.format_timestamp(event.updated_at)}\r\n"
          f.puts "SUMMARY:#{event.title}\r\n"
          f.puts "DESCRIPTION:#{event.description.gsub("%r", "\r\n  ")}\r\n"
          f.puts "END:VEVENT\r\n"
        end
        
        f.puts "END:VCALENDAR\r\n"
      end
    end
    
    def self.cancel_signup(event, char, enactor)
      if (!Events.can_manage_signup?(event, char, enactor))
        return t('dispatcher.not_allowed')
      end
      
      signup = event.signups.select { |s| s.character == char }.first
      if (!signup)
        return t('events.not_signed_up', :name => char.name)
      end
      signup.delete
      
      return nil
    end
    
    def self.is_signed_up?(event, char)
      return nil if !char
      
      alts = AresCentral.alts(char)
      
      alts.each do |alt|
        return true if event.character == alt
        return true if alt.event_signups.any? { |e| e.event == event }
      end
      return false
    end
    
    def self.can_manage_signup?(event, char, enactor)
      return false if !enactor
      return true if Events.can_manage_event?(enactor, event)
      AresCentral.is_alt?(enactor, char)
    end
  end
end