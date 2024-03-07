-- Crafting Recipes

if minetest.get_modpath("backroomtest_nodes") then

	minetest.register_craft({
		output = "backroomtest_nodes:carpet 9",
		recipe = {
			{"wool:white", "wool:white", "wool:white"},
			{"wool:white", "dye:brown", "wool:white"},
			{"wool:white", "wool:white", "wool:white"},
		},
	})

	minetest.register_craft({
		output = "backroomtest_nodes:ceiling 9",
		recipe = {
			{"default:sandstone", "default:sandstone", "default:sandstone"},
			{"default:sandstone", "dye:white", "default:sandstone"},
			{"default:sandstone", "default:sandstone", "default:sandstone"},
		},
	})

	minetest.register_craft({
		output = "backroomtest_nodes:wallpaper 9",
		recipe = {
			{"default:paper", "default:paper", "default:paper"},
			{"default:wood", "dye:yellow", "default:wood"},
			{"default:paper", "default:paper", "default:paper"},
		},
	})
end
