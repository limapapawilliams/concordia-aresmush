module AresMUSH
  module Cookies
    def self.give_cookie(recipient, giver)
      
      if (recipient == giver)
        return t('cookies.cant_cookie_yourself')
      end
      
      cookies_from_giver = recipient.cookies_received.select { |c| c.giver == giver }
      if (!cookies_from_giver.empty?)
        return t('cookies.cookie_already_given', :name => recipient.name)
      end
      
      CookieAward.create(giver: giver, recipient: recipient)
      
      Login.emit_ooc_if_logged_in(recipient,  t('cookies.cookie_received', :name => giver.name))
      
      Global.logger.info "#{giver.name} gave #{recipient.name} a cookie."

      return nil
    end
    
    def self.get_web_sheet(char, viewer)
      {
        total_cookies_received: char.total_cookies,
        total_cookies_given: char.total_cookies_given,
        weekly_cookies: char.cookies_given.map { |a| a.recipient.name }
      }
    end
    
    def self.uninstall_plugin
      CookieAward.all.each { |c| c.delete }
      Character.all.each do |c|
        c.update(total_cookies: nil)
        c.update(total_cookies_given: nil)
      end
    end
  end
end