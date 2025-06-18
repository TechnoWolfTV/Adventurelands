asrs = {}
asrs.clicker = {}

dofile(core.get_modpath('asrs')..'/formspecs.lua')
dofile(core.get_modpath('asrs')..'/functions.lua')
dofile(core.get_modpath('asrs')..'/nodes.lua')
dofile(core.get_modpath('asrs')..'/remote.lua')

if core.get_modpath('default') and core.get_modpath('dye') then
   dofile(core.get_modpath('asrs')..'/craft_recipies_mtg.lua')
end

if core.get_modpath('mcl_core') and core.get_modpath('mcl_dye') and core.get_modpath('mcl_chests') and core.get_modpath('mesecons') and core.get_modpath('mesecons_torch') then
   dofile(core.get_modpath('asrs')..'/craft_recipies_mcl.lua')
end

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
