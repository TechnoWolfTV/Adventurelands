-- Minislots game engine

minislots = {}

minislots.modpath = core.get_modpath(core.get_current_modname())
-- local machinelist = core.get_dir_list(minislots.modpath.."/machines", true)

dofile(minislots.modpath.."/engine.lua")
