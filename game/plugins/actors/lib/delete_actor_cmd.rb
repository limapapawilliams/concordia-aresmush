module AresMUSH
  module Actors
    class DeleteActorCmd
      include CommandHandler
      include CommandRequiresLogin
      include CommandRequiresArgs
      
      attr_accessor :name
      
      def crack!
        self.name = trim_input(cmd.args)
      end
      
      def required_args
        {
          args: [ self.name ],
          help: 'actors'
        }
      end
      
      def check_is_allowed
        return t('dispatcher.not_allowed') if !Actors.can_set_actor?(enactor)
        return nil
      end
      
      def handle
        actor = ActorRegistry.all.select { |a| a.charname.upcase == self.name.upcase }
        
        if (actor.empty?)
          client.emit_failure t('actors.actor_not_found')
        else
          actor[0].destroy
          client.emit_success t('actors.actor_deleted')
        end
      end
    end
  end
end
