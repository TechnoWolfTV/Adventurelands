--Glass Black
core.register_node("myglass:myglass_black", {
	description = "Glass Black",
	drawtype = "glasslike",
	tiles = {"myglass_black_framed.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

--Glass Yellow
core.register_node("myglass:myglass_yellow", {
	description = "Glass Yellow",
	drawtype = "glasslike",
	tiles = {"myglass_yellow_framed.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

--Glass White
core.register_node("myglass:myglass_white", {
	description = "Glass White",
	drawtype = "glasslike",
	tiles = {"myglass_white_framed.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

--Glass Blue
core.register_node("myglass:myglass_blue", {
	description = "Glass Blue",
	drawtype = "glasslike",
	tiles = {"myglass_blue_framed.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

--Glass Red
core.register_node("myglass:myglass_red", {
	description = "Glass Red",
	drawtype = "glasslike",
	tiles = {"myglass_red_framed.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

--Glass Lime
core.register_node("myglass:myglass_lime", {
	description = "Glass Lime",
	drawtype = "glasslike",
	tiles = {"myglass_lime_framed.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

--Crafts
--------------------------------------------------------------

--Glass Black

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_black",
	recipe = {
		"default:glass", "dye:black"
	}
})
--Glass White

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_white",
	recipe = {
		"default:glass", "dye:white"
	}
})
--Glass Yellow

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_yellow",
	recipe = {
		"default:glass", "dye:black"
	}
})
--Glass Blue

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_blue",
	recipe = {
		"default:glass", "dye:blue"
	}
})
--Glass Red

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_red",
	recipe = {
		"default:glass", "dye:red"
	}
})
--Glass Lime

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_lime",
	recipe = {
		"default:glass", "dye:lime"
	}
})

