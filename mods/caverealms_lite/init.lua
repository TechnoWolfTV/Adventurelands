caverealms = {} --create a container for functions and constants

--grab a shorthand for the filepath of the mod
local modpath = core.get_modpath(core.get_current_modname())

local config = dofile(modpath .. "/config.lua") --configuration file; holds various constants

--load companion lua files
dofile(modpath .. "/crafting.lua") --crafting recipes
dofile(modpath .. "/nodes.lua") --node definitions
dofile(modpath .. "/stairs.lua") --stairs (mod auto-detected)
dofile(modpath .. "/plants.lua")

if core.get_modpath("mobs_monster") and config.dm_spawn == true then
	dofile(modpath .. "/dungeon_master.lua") --special DMs for DM's Lair biome
end

-- register mapgen script
if core.register_mapgen_script then
	core.register_mapgen_script(modpath .. "/mapgen.lua")
else
	dofile(modpath .. "/mapgen.lua")
end

print("[MOD] Caverealms Lite loaded")
