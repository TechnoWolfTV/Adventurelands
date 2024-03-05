asrs = {}
asrs.clicker = {}

dofile(minetest.get_modpath('asrs')..'/formspecs.lua')
dofile(minetest.get_modpath('asrs')..'/functions.lua')
dofile(minetest.get_modpath('asrs')..'/nodes.lua')

if minetest.get_modpath('default') and minetest.get_modpath('dye') then
   dofile(minetest.get_modpath('asrs')..'/craft_recipies_mtg.lua')
end

if minetest.get_modpath('mcl_core') and minetest.get_modpath('mcl_dye') and minetest.get_modpath('mcl_chests') and minetest.get_modpath('mesecons') and minetest.get_modpath('mesecons_torch') then
   dofile(minetest.get_modpath('asrs')..'/craft_recipies_mcl.lua')
end

if minetest.get_modpath('tubelib') then
   dofile(minetest.get_modpath('asrs')..'/tubelib.lua')
end

if minetest.get_modpath('techage') then
   dofile(minetest.get_modpath('asrs')..'/techage.lua')
end

if minetest.get_modpath('pipeworks') then
   dofile(minetest.get_modpath('asrs')..'/pipeworks.lua')
end

asrs.load()
minetest.register_on_shutdown(asrs.save)
