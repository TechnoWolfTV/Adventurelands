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
* `overcast` — Overcast sky with no precipitation
* `clear` — Cloudless blue sky
* `snow` — Light snowfall
* `snowstorm` — Blizzard conditions
* `thunder` — Lightning and thunder (works together with heavy_rain)
* `light_fog` — Light atmospheric fog (100 node view distance, subtle sky tint)
* `moderate_fog` — Moderate fog (50 node view distance, greyer sky)
* `dense_fog` — Dense fog (20 node view distance, dim flat sky)
* `severe_thunderstorm` — Multi-phase severe thunderstorm. Bad weather, but
  not utterly terrifying: moderate sky darkening, building rain, and
  reduced-frequency lightning during onslaught. No green sky, no rumble.
  Wind builds as the storm approaches, peaks during onslaught, and eases off
  as it passes.
* `pds_severe_thunderstorm` — "Particularly Dangerous Situation" tier.
  The rare, full-intensity severe thunderstorm with an ominous green sky,
  full darkness, a low rumble during onslaught, and frequent close lightning.
  Wind follows the same rise-peak-fall envelope as severe_thunderstorm but
  hits harder at the climax.

Spawn Frequencies
-----------------------
All chances are approximate. Each weather rolls independently on its own
check interval; a roll only succeeds if that weather's conditions are met
(right biome, no conflicting weather active, etc.).

| Weather                    | Chance  | Check Interval |
|----------------------------|---------|----------------|
| thunder                    | 0.8     | 100s           |
| snow                       | 0.05    | 200s           |
| light_rain                 | 0.0375  | 200s           |
| rain                       | 0.025   | 300s           |
| overcast                   | 0.025   | 300s           |
| clear                      | 0.025   | 300s           |
| light_fog                  | 0.025   | 300s           |
| heavy_rain                 | 0.015   | 200s           |
| moderate_fog               | 0.015   | 200s           |
| severe_thunderstorm        | 0.015   | 400s           |
| snowstorm                  | 0.0125  | 300s           |
| pds_severe_thunderstorm    | 0.0075  | 400s           |
| dense_fog                  | 0.0075  | 400s           |

Commands
-----------------------
Requires `weather_manager` privilege.

  * `start_weather <weather_code>` — Start a weather type (blocked if disabled)
  * `stop_weather <weather_code|all>` — Stop a weather type, or stop all active weathers
  * `disable_weather <weather_code|all>` — Disable a weather type so it cannot start naturally or manually; persists between restarts
  * `enable_weather <weather_code|all>` — Re-enable a previously disabled weather type; persists between restarts
  * `weather_status` — Display active (with elapsed time), enabled, and disabled weather, one category per line, comma-separated

Available weather codes:
`light_rain`, `rain`, `heavy_rain`, `overcast`, `clear`, `thunder`, `snow`, `snowstorm`,
`light_fog`, `moderate_fog`, `dense_fog`, `severe_thunderstorm`, `pds_severe_thunderstorm`

Be aware that weather may not be visible for a player until they are
in the right biome. Fog does not appear in dry biomes. Snowstorm only
appears in frozen biomes.

`heavy_rain` builds in gradually -- sky, sound, and rain all fade in
together over about 10 seconds, reaching full intensity right as rain
starts falling -- and fades back out the same way before ending (also
~10 seconds), rather than starting or stopping instantly. When it ends
naturally there's a chance it hands off directly to `rain` rather than
clearing to nothing. Severe storms still take over from heavy_rain
immediately rather than waiting for this fade, to avoid two skies
fighting for the same few seconds. Admin `stop_weather` / `disable_weather`
always take effect instantly for every weather type, including
heavy_rain, with no lingering effects.

`/weather_status` shows how long each active weather has been running,
e.g. `heavy_rain (2m 14s)`.

Shelter System
-----------------------
Weather sounds are attenuated based on the player's shelter level.
Rain and wind sounds fade as players move indoors or underground.
Thunder remains partially audible even deep indoors, fading gradually
in caves.

Rain and snow particles only spawn at positions with open sky directly
above them -- not based on the player's own shelter level -- so standing
indoors near a window still shows weather happening just outside, while
the room itself stays dry. This applies to light_rain, rain, heavy_rain,
and both severe storm tiers.

Fog uses engine-level atmospheric depth (not particles). It is suppressed
entirely when a player is indoors (shelter detected via overhead check),
so fog does not appear inside buildings. Sky/cloud tints from heavy_rain
and both severe storm tiers remain visible through windows while indoors.

Fire Extinguishing
-----------------------
Exposed flames (`fire:basic_flame` and `lightning:dying_flame`) in outdoor
positions are extinguished based on rain intensity. `heavy_rain`,
`severe_thunderstorm`, and `pds_severe_thunderstorm` extinguish fire quickly
(~5 seconds average). `rain` extinguishes more slowly (~10 seconds average).
`light_rain` and snow do not extinguish fire.

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

Musheran (https://opengameart.org/content/low-rumbling):

  * `sounds/severe-storm-rumble.ogg` - CC BY (http://creativecommons.org/publicdomain/zero/1.0/)
    Original: "Low Rumbling | low-rumbling-176033.mp3"
