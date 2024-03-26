-- Crafting Recipes

if minetest.get_modpath("backrooms_nodes") then

	minetest.register_craft({
		output = "backrooms_nodes:carpet 9",
		recipe = {
			{"wool:white", "wool:white", "wool:white"},
			{"wool:white", "dye:brown", "wool:white"},
			{"wool:white", "wool:white", "wool:white"},
		},
	})

	minetest.register_craft({
		output = "backrooms_nodes:ceiling 9",
		recipe = {
			{"default:sandstone", "default:sandstone", "default:sandstone"},
			{"default:sandstone", "dye:white", "default:sandstone"},
			{"default:sandstone", "default:sandstone", "default:sandstone"},
		},
	})
	
	minetest.register_craft({
		output = "backrooms_nodes:ceiling_light 3",
		recipe = {
			{"default:glass", "default:glass", "default:glass"},
			{"default:torch", "default:torch", "default:torch"},
			{"default:glass", "default:glass", "default:glass"},
		},
	})

	minetest.register_craft({
		output = "backrooms_nodes:wallpaper 9",
		recipe = {
			{"default:paper", "default:paper", "default:paper"},
			{"default:wood", "dye:yellow", "default:wood"},
			{"default:paper", "default:paper", "default:paper"},
		},
	})
	
	minetest.register_craft({
		output = "backrooms_nodes:wallpaper_baseboard 9",
		recipe = {
			{"default:paper", "default:paper", "default:paper"},
			{"default:wood", "dye:yellow", "default:wood"},
			{"default:silver_sandstone", "default:silver_sandstone", "default:silver_sandstone"},
		},
	})
end
