minetest.register_node("myglass:window_shutter", {
	description = "Window Shutter",
	tiles = {
		"myglass_window_shutter.png",
		"myglass_window_shutter.png",
		"myglass_window_shutter.png",
		"myglass_window_shutter.png",
		"myglass_window_shutter.png",
		"myglass_window_shutter_front.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0.5, -0.4375, 0.5},
			{0.375, -0.5, 0, 0.5, -0.375, 0.5},
			{-0.5, -0.5, 0, -0.375, -0.375, 0.5},
			{-0.5, -0.5, 0, 0.5, -0.375, 0.125},
			{-0.5, -0.5, 0.375, 0.5, -0.375, 0.5},
		}
	},
	on_place = minetest.rotate_node,
})
minetest.register_node("myglass:window_shutter2", {
	description = "Window Shutter 2",
	tiles = {
		"myglass_window_shutter_front.png",
		"myglass_window_shutter.png",
		"myglass_window_shutter.png",
		"myglass_window_shutter.png",
		"myglass_window_shutter.png",
		"myglass_window_shutter.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4375, 0.5, -0.4375, 0.5},
			{0.375, -0.5, -0.5, 0.5, -0.375, 0.5},
			{-0.5, -0.5, -0.5, -0.375, -0.375, 0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.375, -0.375},
			{-0.5, -0.5, 0.375, 0.5, -0.375, 0.5},
		}
	},
	on_place = minetest.rotate_node,
})

--Crafts

minetest.register_craft({
	output = "myglass:window_shutter 1",
	recipe = {
		{"default:wood", "",""},
		{"default:pine_wood", "",""},
		{"default:wood", "",""},
	}
})

minetest.register_craft({
	output = "myglass:window_shutter2 1",
	recipe = {
		{"default:wood", "default:wood",""},
		{"default:pine_wood", "default:pine_wood",""},
		{"default:wood", "default:wood",""},
	}
})
