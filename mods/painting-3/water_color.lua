
-- water-color

local S = painting.translator

local color_vessel = "vessels:drinking_glass"
local water_bottle = "bucket:bucket_water"
local empty_bottle = "bucket:bucket_empty"
local feather = nil
local feather_img = nil

if minetest.registered_items["farming:glass_water"] then
  water_bottle = "farming:glass_water"
  empty_bottle = "vessels:drinking_glass"
end

if minetest.get_modpath("hades_bucket") then
  water_bottle = "hades_bucket:bucket_water"
  empty_bottle = "hades_bucket:bucket_empty"
end
if minetest.get_modpath("hades_extrafarming") then
  water_bottle = "hades_extrafarming:glass_water"
  empty_bottle = "vessels:drinking_glass"
end

--[[
-- water color with feather only in MineClone
if minetest.get_modpath("mobs_animal") or minetest.get_modpath("hades_animals") then
	feather = "mobs:chicken_feather"
	feather_img = "mobs_chicken_feather.png"
end
--]]
if minetest.get_modpath("mcl_core") then
	color_vessel = "mcl_potions:glass_bottle"
	water_bottle = "mcl_potions:river_water"
	empty_bottle = "mcl_potions:glass_bottle"
	feather = "mcl_mobitems:feather"
	feather_img = "mcl_mobitems_feather.png"
end

for color,hexcol in pairs(painting.hexcolors) do
	des_col = color:gsub("^%l", string.upper)
	
	minetest.register_craftitem("painting:water_color_"..color, {
			description = S("Glass with "..des_col.." Water Color"),
			inventory_image = "painting_glass_water_color.png^[colorize:#"..hexcol.."^painting_glass.png",
		})	
	minetest.register_tool("painting:brush_water_color_"..color, {
			description = S("Brush with "..des_col.." Water Color"),
			inventory_image = "painting_glass_oil_color.png^[colorize:#"..hexcol.."^painting_glass.png",
			inventory_overlay = "painting_brush_stem.png^painting_brush_head.png",
			_painting_brush = {
				points = {
					{x=0,y=0,a=0.7},
					{x=-1,y=0,a=0.5},
					{x=0,y=-1,a=0.5},
					{x=1,y=0,a=0.5},
					{x=0,y=1,a=0.5},
				},
				color = hexcol,
				wear = 1150,
				break_stack = color_vessel,
			},
		})
	if feather then
		minetest.register_tool("painting:feather_water_color_"..color, {
				description = S("Feather with "..des_col.." Water Color"),
				inventory_image = "painting_glass_water_color.png^[colorize:#"..hexcol.."^painting_glass.png",
				inventory_overlay = feather_img,
				_painting_brush = {
					points = {
						{x=0,y=0,a=0.6},
					},
					color = hexcol,
					wear = 256,
					break_stack = color_vessel,
				},
			})
	end
	
	if minetest.get_modpath("mcl_dye") then
		minetest.register_craft{
			output = "painting:water_color_"..color,
			recipe = {
				{"mcl_dye:"..color},
				{water_bottle},
				{color_vessel},
			},
			replacements = {{water_bottle,empty_bottle}},
		}
	else
		minetest.register_craft{
			output = "painting:water_color_"..color,
			recipe = {
				{"dye:"..color},
				{water_bottle},
				{color_vessel},
			},
			replacements = {{water_bottle,empty_bottle}},
		}
	end
	minetest.register_craft{
		output = "painting:brush_water_color_"..color,
		recipe = {
			{"painting:brush"},
			{"painting:water_color_"..color},
		},
	}
	if feather then
		minetest.register_craft{
			output = "painting:feather_water_color_"..color,
			recipe = {
				{feather},
				{"painting:water_color_"..color},
			},
		}
	end
end
