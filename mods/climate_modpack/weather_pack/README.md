weather-pack
=======================
Weather mod for Luanti / Minetest (http://minetest.net/)

Originally authored by xeranas (Artūras Norkus).
Extended and maintained for Adventurelands by TechnoWolfTV.

Feedback and Improvements
-----------------------
* Original source: https://gitlab.com/zombiebot/weather_pack
* Register bugs at https://gitlab.com/zombiebot/weather_pack/issues
* Questions / Discussion at https://forum.minetest.net/viewtopic.php?p=215869

Weathers included
-----------------------
* `light_rain` — Light drizzle
* `rain` — Moderate rain
* `heavy_rain` — Heavy rain
* `snow` — Light snowfall
* `snowstorm` — Blizzard conditions
* `thunder` — Lightning and thunder (works together with heavy_rain)
* `light_fog` — Thin atmospheric fog
* `moderate_fog` — Moderate fog
* `heavy_fog` — Dense fog
* `severe_thunderstorm` — Multi-phase severe thunderstorm. Bad weather, but
  not utterly terrifying: moderate sky darkening, building rain, and
  reduced-frequency lightning during onslaught. No green sky, no rumble.
* `pds_severe_thunderstorm` — "Particularly Dangerous Situation" tier.
  The rare, full-intensity severe thunderstorm with an ominous green sky,
  full darkness, a low rumble during onslaught, and frequent close lightning.

Commands
-----------------------
Requires `weather_manager` privilege.

  * `start_weather <weather_code>` — Start a weather type (blocked if disabled)
  * `stop_weather <weather_code|all>` — Stop a weather type, or stop all active weathers
  * `disable_weather <weather_code|all>` — Disable a weather type so it cannot start naturally or manually; persists between restarts
  * `enable_weather <weather_code|all>` — Re-enable a previously disabled weather type; persists between restarts
  * `weather_status` — Display active, enabled, and disabled weather, one category per line, comma-separated

Available weather codes:
`light_rain`, `rain`, `heavy_rain`, `thunder`, `snow`, `snowstorm`,
`light_fog`, `moderate_fog`, `heavy_fog`, `severe_thunderstorm`, `pds_severe_thunderstorm`

Be aware that weather may not be visible for a player until they are
in the right biome. Fog does not appear in dry biomes. Snowstorm only
appears in frozen biomes.

Shelter System
-----------------------
Weather sounds are attenuated based on the player's shelter level.
Rain and wind sounds fade as players move indoors or underground.
Thunder remains partially audible even deep indoors, fading gradually
in caves. Fog particles do not appear indoors but the sky overlay
remains visible through windows.

Dependencies
-----------------------
Thunder, severe_thunderstorm, and pds_severe_thunderstorm weather require the
[lightning](https://github.com/minetest-mods/lightning) mod.
All three are loaded conditionally and will be skipped if lightning is absent.

Wind-driven particles require the
[breasy](https://content.luanti.org/packages/Bas080/breasy/) mod (optional).
If absent, particles fall back to default behaviour with no wind effect.

Minimum Luanti version: 5.9+

License of source code:
-----------------------
MIT — see LICENSE file for full details including modification history.

Authors of media files:
-----------------------

xeranas:

  * `happy_weather_heavy_rain_drops.png` - CC-0
  * `happy_weather_light_rain_raindrop_*.png` - CC-0
  * `happy_weather_light_snow_snowflake_*.png` - CC-0

inchadney (http://freesound.org/people/inchadney/):

  * `rain_drop.ogg` - CC-BY-SA 3.0 (cut from http://freesound.org/people/inchadney/sounds/58835/)

rcproductions54 (http://freesound.org/people/rcproductions54/):

  * `light_rain_drop.ogg` - CC-0 (http://freesound.org/people/rcproductions54/sounds/265045/)

uberhuberman:

  * `heavy_rain_drop.ogg` - CC BY 3.0 (https://www.freesound.org/people/uberhuberman/sounds/21189/)

TechnoWolfTV:

  * `weather_pack_fog.png` - MIT

Musheran (https://opengameart.org/content/low-rumbling):

  * `sounds/severe-storm-rumble.ogg` - CC BY (http://creativecommons.org/publicdomain/zero/1.0/)
    Original: "Low Rumbling | low-rumbling-176033.mp3"
