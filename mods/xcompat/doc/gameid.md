# GameId API

## minetest versions >= 5.7 

simply returns `core.get_game_info().id`  

## minetest versions < 5.7

approximates the gameid value via a hardcoded table of gameid =\> modname,
and then checks via `core.get_modpath()`. If it fails, it falls 
back to using `xcompat_unknown_gameid` as the id. See the chart in the
readme for which games are supported
