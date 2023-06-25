# PostEvent

## Credits

Tat @ Ares Central

## Overview
This plugin posts new events to a configurable forum.

It can also post event updates to the forum as replies, as long as the event name does not change. If there is more than one forum post in the category with the same name, it will reply to the most recent one.

**NOTE:** This is not a fully standalone plugin - it requires some very minimal insertion of code into the core events plugin. This could cause conflicts during upgrades that you would need to sort out - but they should be minimal and easy to identify.

## Web Portal

This plugin has no web portal code.  

## Installation

In the game, run `plugin/install https://github.com/spiritlake/ares-postevent-plugin`.

This also requires inserting two lines of code into the core Events code.

In **plugins\events\helpers.rb**, in `def self.create_event`, add

> PostEvent.create_forum_post(event)

directly before

> return event

AND in `def self.update_event` , add

> if Global.read_config("postevent", "reply_on_edit") then PostEvent.reply_to_forum_post(event) end

 directly before

 > end

## Configuration

Configuration options can be set in `post_event.yml`.

`event_forum:` The name of the forum you'd like new events to be posted to.

`reply_on_edit?:` True/false. Whether you'd like event edits to be posted as replies to the forum post. Will not work if the name of the event changes (but it won't cause any problems).

## Uninstalling

Removing the plugin requires some code fiddling.  See [Uninstalling Plugins](https://www.aresmush.com/tutorials/code/extras.html#uninstalling-plugins).

## License

Same as [AresMUSH](https://aresmush.com/license).
