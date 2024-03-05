-- painting - in-game painting for minetest

local items =
{
	wood = "default:wood",
	stick = "default:stick",
	brush_head = "farming:cotton",
	canvas_source = "default:paper",
}

if minetest.get_modpath("mcl_core") then
	items.wood = "mcl_core:wood"
	items.stick = "mcl_core:stick"
	items.brush_head = "mcl_mobitems:string"
	items.canvas_source = "mcl_core:paper"
elseif minetest.get_modpath("hades_core") then
	items.wood = "group:wood"
	items.stick = "hades_core:stick"
	items.brush_head = "hades_farming:cotton"
	items.canvas_source = "hades_core:paper"
	
	if minetest.get_modpath("hades_extrafarming") then
		items.brush_head = "hades_extrafarming:cotton"
	end
	if minetest.get_modpath("hades_clothing") then
		items.canvas_source = "hades_clothing:fabric_white"
	end
	if minetest.get_modpath("hades_animals") then
		local hairball = minetest.settings:get("mobs_hairball")
    if hairball then
		  items.brush_head = "mobs:hairball"
    end
	end
else
	if minetest.get_modpath("clothing") then
		items.canvas_source = "clothing:fabric_white"
	end
	if minetest.get_modpath("mobs_animal") then
		local hairball = minetest.settings:get("mobs_hairball")
    if hairball then
		  items.brush_head = "mobs:hairball"
    end
	end
end

minetest.register_craft({
	output = 'painting:easel 1',
	recipe = {
		{ '', items.wood, '' },
		{ '', items.wood, '' },
		{ items.stick,'', items.stick },
	}})

minetest.register_craft({
	output = 'painting:brush 1',
	recipe = {
		{ items.brush_head },
		{ items.stick },
		{ items.stick },
	}})

minetest.register_craft({
	output = 'painting:canvas_16 1',
	recipe = {
		{ '', '', '' },
		{ '', '', '' },
		{ items.canvas_source, '', '' },
	}})

minetest.register_craft({
	output = 'painting:canvas_32 1',
	recipe = {
		{ '', '', '' },
		{ items.canvas_source, items.canvas_source, '' },
		{ items.canvas_source, items.canvas_source, '' },
	}})

minetest.register_craft({
	output = 'painting:canvas_64 1',
	recipe = {
		{ items.canvas_source, items.canvas_source, items.canvas_source },
		{ items.canvas_source, items.canvas_source, items.canvas_source },
		{ items.canvas_source, items.canvas_source, items.canvas_source },
	}})

