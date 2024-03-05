
-- oil-color

local S = painting.translator

local color_vessel = "vessels:drinking_glass"
local oil_bottle = "farming:hemp_oil"
local empty_bottle = "vessels:glass_bottle"
local feather = nil
local feather_img = nil

if minetest.get_modpath("petz") then
	feather = "petz:dcuky_feather"
	feather_img = "petz_ducky_feather.png"
end
if minetest.get_modpath("hades_petz") then
	feather = "hades_petz:ducky_feather"
	feather_img = "petz_ducky_feather.png"
end
if minetest.get_modpath("animalia") then
	feather = "animalia:feather"
	feather_img = "animalia_feather.png"
end
if minetest.get_modpath("hades_animalia") then
	feather = "hades_animalia:feather"
	feather_img = "animalia_feather.png"
end
if minetest.get_modpath("mobs_animal") or minetest.get_modpath("hades_animals") then
	feather = "mobs:chicken_feather"
	feather_img = "mobs_chicken_feather.png"
end
if minetest.get_modpath("hades_extrafarming") then
	color_vessel = "vessels:drinking_glass"
	oil_bottle = "hades_extrafarming:hemp_oil"
	empty_bottle = "vessels:glass_bottle"
end
if minetest.get_modpath("mcl_core") then
	color_vessel = "--unknown--"
	oil_bottle = "--unknown--"
	feather = "mcl_mobitems:feather"
	feather_img = "mcl_mobitems_feather.png"
end

local sculpture_tool = nil

if minetest.get_modpath("sculpture") then
	if sculpture.tool_paint_point then
		sculpture_tool = {
			category_name = {metal = 10},
			wear = 16,
			on_use = sculpture.tool_paint_point,
		}
	end
end

for color,hexcol in pairs(painting.hexcolors) do
	des_col = color:gsub("^%l", string.upper)
	
	minetest.register_craftitem("painting:oil_color_"..color, {
			description = S("Glass with "..des_col.." Oil Color"),
			inventory_image = "painting_glass_oil_color.png^[colorize:#"..hexcol.."^painting_glass.png",
		})
	local sculpture_tool_color = nil
  if sculpture_tool then
    sculpture_tool_color = table.copy(sculpture_tool)
	  sculpture_tool_color.brush_color = hexcol
  end
	minetest.register_tool("painting:brush_oil_color_"..color, {
			description = S("Brush with "..des_col.." Oil Color"),
			inventory_image = "painting_glass_oil_color.png^[colorize:#"..hexcol.."^painting_glass.png",
			inventory_overlay = "painting_brush_stem.png^painting_brush_head.png",
			_painting_brush = {
				points = {
					{x=0,y=0,a=1.0},
					{x=-1,y=0,a=0.9},
					{x=0,y=-1,a=0.9},
					{x=1,y=0,a=0.9},
					{x=0,y=1,a=0.9},
				},
				color = hexcol,
				wear = 1177,
				break_stack = color_vessel,
			},
			_sculpture_tool = sculpture_tool_color,
		})
	if feather then
		minetest.register_tool("painting:feather_oil_color_"..color, {
				description = S("Feather with "..des_col.." Oil Color"),
				inventory_image = "painting_glass_oil_color.png^[colorize:#"..hexcol.."^painting_glass.png",
				inventory_overlay = feather_img,
				_painting_brush = {
					points = {
						{x=0,y=0,a=1},
					},
					color = hexcol,
					wear = 256,
					break_stack = color_vessel,
				},
			})
	end
	
	if minetest.get_modpath("mcl_dye") then
		minetest.register_craft{
			output = "painting:oil_color_"..color,
			recipe = {
				{"mcl_dye:"..color},
				{oil_bottle},
				{color_vessel},
			},
			replacements = {{oil_bottle,empty_bottle}},
		}
	else
		minetest.register_craft{
			output = "painting:oil_color_"..color,
			recipe = {
				{"dye:"..color},
				{oil_bottle},
				{color_vessel},
			},
			replacements = {{oil_bottle,empty_bottle}},
		}
	end
	minetest.register_craft{
		output = "painting:brush_oil_color_"..color,
		recipe = {
			{"painting:brush"},
			{"painting:oil_color_"..color},
		},
	}
	if feather then
		minetest.register_craft{
			output = "painting:feather_oil_color_"..color,
			recipe = {
				{feather},
				{"painting:oil_color_"..color},
			},
		}
	end
end
