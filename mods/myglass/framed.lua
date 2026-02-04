
--Black Framed

core.register_node("myglass:myglass_framed_black", {
	description = "Glass Framed Black",
	drawtype = "glasslike_framed",
	tiles = {"myglass_black.png","myglass_blank.png"},
	paramtype = "light",
	groups = {cracky = 2,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})

--Glass Yellow Framed

core.register_node("myglass:myglass_framed_yellow", {
	description = "Glass Framed Yellow",
	drawtype = "glasslike_framed",
	tiles = {"myglass_yellow.png","myglass_blank.png"},
	paramtype = "light",
	groups = {cracky = 2,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})

--Glass White Framed

core.register_node("myglass:myglass_framed_white", {
	description = "Glass Framed White",
	drawtype = "glasslike_framed",
	tiles = {"myglass_white.png","myglass_blank.png"},
	paramtype = "light",
	groups = {cracky = 2,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})

--Glass Blue Framed

core.register_node("myglass:myglass_framed_blue", {
	description = "Glass Framed Blue",
	drawtype = "glasslike_framed",
	tiles = {"myglass_blue.png","myglass_blank.png"},
	paramtype = "light",
	groups = {cracky = 2,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})

--Glass Red Framed

core.register_node("myglass:myglass_framed_red", {
	description = "Glass Framed Red",
	drawtype = "glasslike_framed",
	tiles = {"myglass_red.png","myglass_blank.png"},
	paramtype = "light",
	groups = {cracky = 2,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})

--Glass Lime Framed

core.register_node("myglass:myglass_framed_lime", {
	description = "Glass Framed Lime",
	drawtype = "glasslike_framed",
	tiles = {"myglass_lime.png","myglass_blank.png"},
	paramtype = "light",
	groups = {cracky = 2,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

})



--Crafts
--Glass Framed Black

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_framed_black 2",
	recipe = {
		"myglass:myglass_black","myglass:myglass_black"
	}
})
--Glass Framed White

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_framed_white 2",
	recipe = {
		"myglass:myglass_white", "myglass:myglass_white"
	}
})
--Glass Framed Yellow

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_framed_yellow 2",
	recipe = {
		"myglass:myglass_yellow", "myglass:myglass_yellow"
	}
})
--Glass Framed Yellow

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_framed_blue 2",
	recipe = {
		"myglass:myglass_blue", "myglass:myglass_blue"
	}
})
--Glass Framed Yellow

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_framed_red 2",
	recipe = {
		"myglass:myglass_red", "myglass:myglass_red"
	}
})
--Glass Framed Yellow

core.register_craft({
	type = "shapeless",
	output = "myglass:myglass_framed_lime 2",
	recipe = {
		"myglass:myglass_lime", "myglass:myglass_lime"
	}
})
