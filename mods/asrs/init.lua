asrs = {}
asrs.clicker = {}

dofile(core.get_modpath('asrs')..'/formspecs.lua')
dofile(core.get_modpath('asrs')..'/functions.lua')
dofile(core.get_modpath('asrs')..'/nodes.lua')
dofile(core.get_modpath('asrs')..'/remote.lua')
dofile(core.get_modpath('asrs')..'/craft_recipes.lua')

if core.get_modpath('tubelib') then
   dofile(core.get_modpath('asrs')..'/tubelib.lua')
end

if core.get_modpath('techage') then
   dofile(core.get_modpath('asrs')..'/techage.lua')
end

if core.get_modpath('pipeworks') then
   dofile(core.get_modpath('asrs')..'/pipeworks.lua')
end

asrs.load()
core.register_on_shutdown(asrs.save)
