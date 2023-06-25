# Weather

## Status

**Supported**  Although not part of the main Ares code release, this is a supported plugin.  [Report](https://aresmush.com/feedback) any problems you encounter.

Designed for AresMUSH 1.0.

## Overview

Allows you to include weather in your room descs. The weather uses a simplistic model that you can customize. If you're looking for more realistic weather, you may prefer the [Openweather](https://github.com/Mudpuppy12/ares-openweather-plugin) plugin.

## How Weather Works

Ares has a fairly simplistic weather system.  You can define **climates** with different weather patterns available by **season**.  Each weather pattern consists of a **temperature** and a **condition**.

The temperature and condition combine to a weather report like:  "It is a hot spring morning.  The skies are clear."

Here's what a sample climate might look like.

    temperate:
        summer:
            temperature: hot hot hot hot hot warm warm warm cool cool
            condition:  clear clear clear fair fair fair drizzling drizzling overcast raining
            stability: 70
        spring:
            temperature: cool cool cool cool cool warm warm warm warm warm
            condition:  clear clear clear fair fair fair drizzling drizzling overcast raining
            stability: 70

Every time the weather cron job runs, there's a chance the weather will change.  That chance is determined by the **stability** of the weather.  If the stability is 70, that means there's a 30% chance of the weather changing.  In other words, the weather will shift roughly once every 8 hours.

When the weather does change, the system will select a random temperature and condition from the seasonal list.  By default, there are 10 entries in the list, meaning each entry has a 10% chance of occurring.  You can make some entries more likely than others by repeating them multiple times.  In the spring example above, there's a 30% chance of clear skies, 30% chance of fair weather, 20% chance of drizzling, 10% overcast, 10% raining.

> Note: You are not limited to ten entries.  That's just convenient for understanding that each entry represents a 10% chance.  You could have 20 entries (5% chance each) or even 100 entries (1% chance each) to fine-tune the weather as much as you want.

Seasons follow the RL northern hemisphere dates based on the IC time.  In other words, January would be winter and July summer.  If you want to make this more sophisticated (like accounting for different seasons on different planets, or months like November which are half winter and half fall), you'll have to change the code.

## Web Portal

The weather shows up in room descs on the portal.

## Installation

In the game, run `plugin/install <github url>`.

## Configuration

This plugin has several configuration options.

> **Note!** After changing the weather config, you should do `weather/reset` in-game to refresh the weather in all locations.

### climate_for_area and default_climate

The weather system lets you configure a climate for each room **area**.  You can use 'none' to disable the weather system for an area.  

If the climate for an area is not specified, the weather system will look at the area's parent, and it's parent's parent, and so on until it finds a climate.  If all else fails, it will use the `default_climate`.  

For example, the following config will use the polar climate for the North area and disable weather in the offstage area.  Any other areas will use the temperate climate.

    climate_for_area:
        Offstage: none
        North: polar
        
    default_climate: temperate

To disable weather completely, you can just make the default_climate 'none'.

### temperatures and conditions

The 'temperatures' and 'conditions' lists control what temperatures and weather conditions are available for your use in weather patterns.  

If you add new ones, you may want to add them to the weather descriptions config, described below.

### descriptions

The `descriptions` configuration can override the default (lame) weather descriptions.

The condition description is simply the current condition:

    clear: The skies are clear.
    misty: There's a mist in the air.

The temperature description is a combination of the actual temperature, the season, and the time of day (morning, day, evening, night): 

    hot_spring_morning: It is a hot spring morning.
    warm_summer_day: It is a warm summer day.

### weather_cron

The game will periodically change the weather.  There is a cron job to control when this happens.  By default it does this every hour.  See the [Cron Job Tutorial](http://www.aresmush.com/tutorials/code/cron.html) for help if you want to change this or turn it off.

## Uninstalling

Removing the plugin requires some code fiddling.  See [Uninstalling Plugins](https://aresmush.com/tutorials/code/contribs.html#uninstalling-plugins).

## License

Same as	[AresMUSH](https://aresmush.com/license).