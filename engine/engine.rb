require_relative '../lib/aresmush.rb'

module AresMUSH
  def self.logs_path
    File.join(AresMUSH.game_path, "logs", "engine")
  end
end

require 'aresmush/bootstrapper'
require 'aresmush/client/client_monitor'
require 'aresmush/client/client.rb'
require 'aresmush/client/client_factory.rb'
require 'aresmush/client/client_greeter.rb'
require 'aresmush/commands/arg_parser.rb'
require 'aresmush/commands/command'
require 'aresmush/commands/command_alias_parser'
require 'aresmush/commands/command_cracker.rb'
require 'aresmush/commands/dispatcher.rb'
require 'aresmush/commands/global_events.rb'
require 'aresmush/connection.rb'
require 'aresmush/cron.rb'
require 'aresmush/global.rb'
require 'aresmush/plugin/plugin_manager.rb'
require 'aresmush/plugin/command_handler.rb'
require 'aresmush/plugin_helpers/find_result.rb'
require 'aresmush/plugin_helpers/single_result_selector.rb'
require 'aresmush/plugin_helpers/class_target_finder.rb'
require 'aresmush/plugin_helpers/any_target_finder.rb'
require 'aresmush/plugin_helpers/visible_target_finder.rb'
require 'aresmush/plugin_helpers/online_char_finder.rb'
require 'aresmush/plugin_helpers/on_off_option.rb'
require 'aresmush/rest_connector.rb'
require 'aresmush/templates/template_formatters.rb'
require 'aresmush/templates/template_renderer.rb'
require 'aresmush/server.rb'
require 'aresmush/telnet_negotiation.rb'
require 'aresmush/web/web_connection.rb'