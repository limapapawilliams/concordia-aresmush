module AresMUSH
  module Cookies    
    class CronEventHandler
      def on_event(event)
        config = Global.read_config("cookies", "cookie_award_cron")
        return if !Cron.is_cron_match?(config, event.time)
        
        Global.logger.debug "Issuing cookies."
                
        awards = ""
        counts = {}
        given_counts = {}
        chars = {}
        
        CookieAward.all.each do |c|
          recipient = c.recipient
          giver = c.giver
          
          name = recipient.name
          if (counts.has_key?(name))
            counts[name] = counts[name] + 1
          else
            counts[name] = 1 
          end
          chars[name] = c.recipient
          
          name = giver.name
          if (given_counts.has_key?(name))
            given_counts[name] = given_counts[name] + 1
          else
            given_counts[name] = 1 
          end
          chars[name] = c.giver
          
          c.delete
        end
        
        default_levels = [1, 10, 25, 50, 100, 200, 500, 1000]
        
        counts.sort_by { |name, count| count }.reverse.each_with_index do |(name, count), i|
          char = chars[name]
          index = i+1
          if (i <= 10)
            num = "#{index.to_s}."
            awards << "#{num.ljust(3)} #{char.name.ljust(20)}#{count}\n"
          end
          
          char.update(total_cookies: char.total_cookies + count)
          

          Achievements.achievement_levels("cookie_received", default_levels).reverse.each do |count|
            if (char.total_cookies >= count)
              Achievements.award_achievement(char, "cookie_received", count)
              break
            end
          end
        end
        
        given_counts.sort_by { |name, count| count }.each do |name, count|
          char = chars[name]
          char.update(total_cookies_given: char.total_cookies_given + count)
          
          Achievements.achievement_levels("cookie_given", default_levels).reverse.each do |count|
            if (char.total_cookies_given >= count)
              Achievements.award_achievement(char, "cookie_given", count)
              break
            end
          end
        end
        
        
        return if awards.blank?
        
        Forum.system_post(
          Global.read_config("cookies", "cookie_category"),
          t('cookies.weekly_award_title'), 
          awards.chomp)
      end
    end    
  end
end