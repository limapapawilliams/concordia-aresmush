module AresMUSH
  module Bbs
    class BbsArchive
      include CommandHandler
      include CommandRequiresLogin
      include CommandRequiresArgs
      include TemplateFormatters
      
      attr_accessor :board_name
      
      def crack!
        self.board_name = titleize_input(cmd.args)
      end
      
      def required_args
        {
          args: [ self.board_name ],
          help: 'bbs'
        }
      end
      
      def handle
        client.emit_ooc t('bbs.starting_archive')
        Bbs.with_a_board(self.board_name, client, enactor) do |board|  
          if board.bbs_posts.count > 30
            client.emit_failure t('bbs.too_much_for_archive')
            return
          end
          
          board.bbs_posts.each_with_index do |post, i|
            Global.dispatcher.queue_timer(i, "BBS Archive", client) do
              Global.logger.debug "Logging bbpost #{post.id} from #{board.name}."

              template = ArchiveTemplate.new(post, enactor)
              client.emit template.render
            end
          end
        end
      end      
    end
  end
end