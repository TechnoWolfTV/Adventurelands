local S = minetest.get_translator("backroomtest_nodes")

-- Nodes

minetest.register_node("backroomtest_nodes:carpet", {
	description = S("Backrooms Carpet"),
	tiles = {"br_carpet_0.png"},
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3,
				flammable = 3, wool = 1},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("backroomtest_nodes:ceiling", {
	description = S("Backrooms Ceiling Tiles"),
	tiles = {"br_ceiling_tiles_0.png"},
	is_ground_content = false,
	groups = {cracky = 2},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("backroomtest_nodes:wallpaper", {
	description = S("Backrooms Wallpaper"),
	tiles = {"br_wallpaper_0.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	sounds = default.node_sound_wood_defaults(),
})