-- Crafting Recipes

if minetest.get_modpath("blazing_tools") then

	minetest.register_craft({
		output = "blazing_tools:blazing_block",
		recipe = {
			{"", "", ""},
			{"", "bucket:bucket_lava", "default:gold_ingot"},
			{"", "default:coal_lump", "group:stick"},
		},
		replacements = {{'bucket:bucket_lava', 'bucket:bucket_empty'},},
	})

	minetest.register_craft({
		output = "blazing_tools:pick_blazing",
		recipe = {
			{"blazing_tools:blazing_block", "blazing_tools:blazing_block", "blazing_tools:blazing_block"},
			{"", "group:stick", ""},
			{"", "group:stick", ""},
		}
	})

	minetest.register_craft({
		output = "blazing_tools:axe_blazing",
		recipe = {
			{"blazing_tools:blazing_block", "blazing_tools:blazing_block"},
			{"blazing_tools:blazing_block", "group:stick"},
			{"", "group:stick"},
		}
	})

	minetest.register_craft({
		output = "blazing_tools:shovel_blazing",
		recipe = {
			{"blazing_tools:blazing_block"},
			{"group:stick"},
			{"group:stick"},
		}
	})

	minetest.register_craft({
		output = "blazing_tools:sword_blazing",
		recipe = {
			{"blazing_tools:blazing_block"},
			{"blazing_tools:blazing_block"},
			{"group:stick"},
		}
	})
end
