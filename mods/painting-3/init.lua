-- painting - in-game painting for minetest

-- picture is drawn using a nodebox to draw the canvas
-- and an entity which has the painting as its texture.
-- this texture is created by minetests internal image
-- compositing engine (see tile.cpp).

minetest.log("action", "Painting mod loading...")

painting = {
	translator = minetest.get_translator("painting")
}

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/functions.lua")
dofile(modpath.."/definitions.lua")

dofile(modpath.."/painting.lua")
dofile(modpath.."/water_color.lua")
dofile(modpath.."/oil_color.lua")
dofile(modpath.."/crafting.lua")

dofile(modpath.."/files.lua")
dofile(modpath.."/commands.lua")
if minetest.get_modpath("tga_encoder") then
  dofile(modpath.."/export_tga.lua")
end

minetest.log("action", "Painting mod loaded.")

