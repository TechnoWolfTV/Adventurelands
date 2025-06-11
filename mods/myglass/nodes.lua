--Window Frame
minetest.register_node("myglass:window_frame", {
	description = "Wood Window Frame",
	tiles = {"default_pine_wood.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			}
		},
	on_place = minetest.rotate_node
})

--Window Horizontal
minetest.register_node("myglass:window_horizontal", {
	description = "Wood Window Horizontal",
	tiles = {"default_pine_wood.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.0625, -0.0625, 0.5, 0.0625, 0.0625},
			}
		},
	on_place = minetest.rotate_node
})

--Window Vertical
minetest.register_node("myglass:window_vertical", {
	description = "Wood Window Vertical",
	tiles = {"default_pine_wood.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
			}
		},
	on_place = minetest.rotate_node
})

--Window Plus
minetest.register_node("myglass:window_plus", {
	description = "Wood Window Plus",
	tiles = {"default_pine_wood.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
			{-0.5, -0.0625, -0.0625, 0.5, 0.0625, 0.0625},
			}
		},
	on_place = minetest.rotate_node
})

--Window Frame White
minetest.register_node("myglass:window_frame_white", {
	description = "Window Frame White",
	tiles = {"myglass_white.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			}
		},
	on_place = minetest.rotate_node
})

--Window Horizontal White
minetest.register_node("myglass:window_horizontal_white", {
	description = "Window Horizontal White",
	tiles = {"myglass_white.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.0625, -0.0625, 0.5, 0.0625, 0.0625},
			}
		},
	on_place = minetest.rotate_node
})

--Window Vertical White
minetest.register_node("myglass:window_vertical_white", {
	description = "Window Vertical White",
	tiles = {"myglass_white.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
			}
		},
	on_place = minetest.rotate_node
})

--Window Plus White
minetest.register_node("myglass:window_plus_white", {
	description = "Window Plus White",
	tiles = {"myglass_white.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
			{-0.5, -0.0625, -0.0625, 0.5, 0.0625, 0.0625},
			}
		},
	on_place = minetest.rotate_node
})

--Crafts
--------------------------------------------------------------------

--Window Frame

minetest.register_craft({
	output = "myglass:window_frame 4",
	recipe = {
		{"group:wood", "default:glass",""},
		{"default:glass", "group:wood",""},
		{"", "",""}
	}
})

--Window Horizontal

minetest.register_craft({
	output = "myglass:window_horizontal 3",
	recipe = {
		{"", "",""},
		{"group:wood", "default:glass","group:wood"},
		{"", "",""}
	}
})

--Window Vertical

minetest.register_craft({
	output = "myglass:window_vertical 3",
	recipe = {
		{"", "group:wood",""},
		{"", "default:glass",""},
		{"", "group:wood",""}
	}
})

--Window Plus

minetest.register_craft({
	output = "myglass:window_plus 5",
	recipe = {
		{"", "group:wood",""},
		{"group:wood", "default:glass","group:wood"},
		{"", "group:wood",""}
	}
})

--Window Frame White

minetest.register_craft({
	type = "shapeless",
	output = "myglass:window_frame_white 1",
	recipe = {
		"myglass:window_frame", "dye:white"
	}
})

--Window Horizontal White

minetest.register_craft({
	type = "shapeless",
	output = "myglass:window_horizontal_white 1",
	recipe = {
		"myglass:window_horizontal", "dye:white"
	}
})

--Window Vertical White

minetest.register_craft({
	type = "shapeless",
	output = "myglass:window_vertical_white 1",
	recipe = {
		"myglass:window_vertical", "dye:white"
	}
})

--Window Plus White

minetest.register_craft({
	type = "shapeless",
	output = "myglass:window_plus_white 1",
	recipe = {
		"myglass:window_plus", "dye:white"
	}
})
