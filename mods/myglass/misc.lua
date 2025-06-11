-- Glass Mesh
minetest.register_node("myglass:myglass_mesh", {
	description = "Glass Mesh",
	drawtype = "glasslike",
	tiles = {"myglass_glass2.png"},
	paramtype = "light",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})
-- Glass Cross
minetest.register_node("myglass:myglass_cross", {
	description = "Glass Cross",
	drawtype = "glasslike",
	tiles = {"myglass_cross.png"},
	paramtype = "light",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})
-- Glass Hole
minetest.register_node("myglass:myglass_hole", {
	description = "Glass Hole",
	drawtype = "glasslike",
	tiles = {"myglass_hole.png"},
	paramtype = "light",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})
-- Glass Bars
minetest.register_node("myglass:myglass_bars", {
	description = "Glass Bars",
	drawtype = "glasslike",
	tiles = {"myglass_bars.png"},
	paramtype = "light",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})
-- Glass Grid
minetest.register_node("myglass:myglass_grid", {
	description = "Glass Grid",
	drawtype = "glasslike",
	tiles = {"myglass_grid.png"},
	paramtype = "light",
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})

--Crafts
-----------------------------------------------------------

--Glass Mesh

minetest.register_craft({
	output = "myglass:myglass_mesh 5",
	recipe = {
		{"default:glass","","default:glass"},
		{"","default:glass",""},
		{"default:glass","","default:glass"},
	}
})

--Glass Lime

minetest.register_craft({
	output = "myglass:myglass_cross 4",
	recipe = {
		{"","default:glass",""},
		{"default:glass","","default:glass"},
		{"","default:glass",""},
	}
})

--Glass Lime

minetest.register_craft({
	output = "myglass:myglass_hole 8",
	recipe = {
		{"default:glass","default:glass","default:glass"},
		{"default:glass","","default:glass"},
		{"default:glass","default:glass","default:glass"},
	}
})

--Glass Lime

minetest.register_craft({
	output = "myglass:myglass_bars 6",
	recipe = {
		{"default:glass","","default:glass"},
		{"default:glass","","default:glass"},
		{"default:glass","","default:glass"},
	}
})

--Glass Lime

minetest.register_craft({
	output = "myglass:myglass_grid 6",
	recipe = {
		{"default:glass","default:glass","default:glass"},
		{"","",""},
		{"default:glass","default:glass","default:glass"},
	}
})
