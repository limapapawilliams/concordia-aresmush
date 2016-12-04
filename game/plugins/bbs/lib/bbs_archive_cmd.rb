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

          posts = board.bbs_posts
          posts.each_with_index do |post, seconds|
            Global.dispatcher.queue_timer(seconds, "Board archive #{board.name}", client) do
              Global.logger.debug "Logging post #{post.id} from #{board.name}."
              template = ArchiveTemplate.new([post], enactor)
              client.emit template.render
            end
          end
          Global.dispatcher.queue_timer(posts.count + 2, "Board archive", client) do
            client.emit_success t('global.done')
          end
        end
      end      
    end
  end
end