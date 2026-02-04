core.register_node("myglass:window_shutter", {
	description = "Window Shutter",
	tiles = {
		"myglass_window_shutter.png"
	},
	drawtype = "mesh",
	mesh = "myglass_window_shutter_sm.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0.5, -0.4375, 0.5},
			{0.375, -0.5, 0, 0.5, -0.375, 0.5},
			{-0.5, -0.5, 0, -0.375, -0.375, 0.5},
			{-0.5, -0.5, 0, 0.5, -0.375, 0.125},
			{-0.5, -0.5, 0.375, 0.5, -0.375, 0.5},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0, 0.5, -0.4375, 0.5},
			{0.375, -0.5, 0, 0.5, -0.375, 0.5},
			{-0.5, -0.5, 0, -0.375, -0.375, 0.5},
			{-0.5, -0.5, 0, 0.5, -0.375, 0.125},
			{-0.5, -0.5, 0.375, 0.5, -0.375, 0.5},
		}
	},
	on_place = core.rotate_node,
})
core.register_node("myglass:window_shutter2", {
	description = "Window Shutter 2",
	tiles = {
		"myglass_window_shutter_front.png"
	},
	drawtype = "mesh",
	mesh = "myglass_window_shutter.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4375, 0.5, -0.4375, 0.5},
			{0.375, -0.5, -0.5, 0.5, -0.375, 0.5},
			{-0.5, -0.5, -0.5, -0.375, -0.375, 0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.375, -0.375},
			{-0.5, -0.5, 0.375, 0.5, -0.375, 0.5},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4375, 0.5, -0.4375, 0.5},
			{0.375, -0.5, -0.5, 0.5, -0.375, 0.5},
			{-0.5, -0.5, -0.5, -0.375, -0.375, 0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.375, -0.375},
			{-0.5, -0.5, 0.375, 0.5, -0.375, 0.5},
		}
	},
	on_place = core.rotate_node,
})

--Crafts

core.register_craft({
	output = "myglass:window_shutter 1",
	recipe = {
		{"default:wood", "",""},
		{"default:pine_wood", "",""},
		{"default:wood", "",""},
	}
})

core.register_craft({
	output = "myglass:window_shutter2 1",
	recipe = {
		{"default:wood", "default:wood",""},
		{"default:pine_wood", "default:pine_wood",""},
		{"default:wood", "default:wood",""},
	}
})
