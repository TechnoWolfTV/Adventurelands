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

minetest.register_node("backroomtest_nodes:wallpaper_baseboard", {
	description = S("Backrooms Wallpaper Baseboard"),
	tiles = {"br_wallpaper_baseboard.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("backroomtest_nodes:ceiling_light", {
    description = S("Backrooms Ceiling Light"),
    tiles = {"br_ceiling_light_1.png"},
    paramtype = "light",
    light_source = minetest.LIGHT_MAX,
    groups = {cracky = 2, oddly_breakable_by_hand = 3, handy = 1},
    _mcl_hardness = 0.3,
	sounds = default.node_sound_glass_defaults(),
})

-- Doors

doors.register("backroomtest_nodes:br_door_grey", {
	tiles = { { name = "br_door_grey.png", backface_culling = true } },
	description = "Backrooms Grey Door",
	inventory_image = "br_door_item_grey.png",
	groups = {choppy=2,cracky=2,door=1},
	protected = false,
	sounds = default.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot", "dye:dark_grey"},
		{"default:steel_ingot", "default:steel_ingot", ""},
	}
})

doors.register("backroomtest_nodes:br_door_purple", {
	tiles = { { name = "br_door_purple.png", backface_culling = true } },
	description = "Backrooms Purple Door",
	inventory_image = "br_door_item_purple.png",
	groups = {choppy=2,cracky=2,door=1},
	protected = false,
	sounds = default.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot", "dye:violet"},
		{"default:steel_ingot", "default:steel_ingot", ""},
	}
})

doors.register("backroomtest_nodes:br_door_red", {
	tiles = { { name = "br_door_red.png", backface_culling = true } },
	description = "Backrooms Red Door",
	inventory_image = "br_door_item_red.png",
	groups = {choppy=2,cracky=2,door=1},
	protected = false,
	sounds = default.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot", "dye:red"},
		{"default:steel_ingot", "default:steel_ingot", ""},
	}
})

doors.register("backroomtest_nodes:br_door_teal", {
	tiles = { { name = "br_door_teal.png", backface_culling = true } },
	description = "Backrooms Teal Door",
	inventory_image = "br_door_item_teal.png",
	groups = {choppy=2,cracky=2,door=1},
	protected = false,
	sounds = default.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot", "dye:green"},
		{"default:steel_ingot", "default:steel_ingot", ""},
	}
})

doors.register("backroomtest_nodes:br_door_rusty", {
	tiles = { { name = "br_door_rusty.png", backface_culling = true } },
	description = "Backrooms Rusty Door",
	inventory_image = "br_door_item_rusty.png",
	groups = {choppy=2,cracky=2,door=1},
	protected = false,
	sounds = default.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot", "dye:orange"},
		{"default:steel_ingot", "default:steel_ingot", "dye:brown"},
	}
})