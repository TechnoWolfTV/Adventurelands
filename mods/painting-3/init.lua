-- painting - in-game painting for minetest

-- picture is drawn using a nodebox to draw the canvas
-- and an entity which has the painting as its texture.
-- this texture is created by core. internal image
-- compositing engine (see tile.cpp).

core.log("action", "Painting mod loading...")

painting = {
	translator = core.get_translator("painting")
}

local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath.."/functions.lua")
dofile(modpath.."/definitions.lua")

dofile(modpath.."/painting.lua")
dofile(modpath.."/water_color.lua")
dofile(modpath.."/oil_color.lua")
dofile(modpath.."/crafting.lua")

dofile(modpath.."/files.lua")
dofile(modpath.."/commands.lua")
if core.get_modpath("tga_encoder") then
  dofile(modpath.."/export_tga.lua")
end

core.log("action", "Painting mod loaded.")

