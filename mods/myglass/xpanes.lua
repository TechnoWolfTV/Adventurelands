--xpane Black
xpanes.register_pane("myglass:glass_pane_black", {
	description = ("Black Glass Pane"),
	textures = {"myglass_black_framed.png", "", "myglass_black.png"},
	inventory_image = "myglass_black_framed.png",
	wield_image = "myglass_black_framed.png",
	sounds = default.node_sound_glass_defaults(),
	groups = {snappy=2, cracky=3},
	recipe = {
		{"default:glass", "dye:black", "default:glass"},
		{"", "default:glass", ""},
		{"","",""}
	},
})

--xpane White
xpanes.register_pane("myglass:glass_pane_white", {
	description = ("White Glass Pane"),
	textures = {"myglass_white_framed.png", "", "myglass_white.png"},
	inventory_image = "myglass_white_framed.png",
	wield_image = "myglass_white_framed.png",
	sounds = default.node_sound_glass_defaults(),
	groups = {snappy=2, cracky=3},
	recipe = {
		{"default:glass", "dye:white", "default:glass"},
		{"", "default:glass", ""},
		{"","",""}
	}
})

--xpane Yellow
xpanes.register_pane("myglass:glass_pane_yellow", {
	description = ("Yellow Glass Pane"),
	textures = {"myglass_yellow_framed.png", "", "myglass_yellow.png"},
	inventory_image = "myglass_yellow_framed.png",
	wield_image = "myglass_yellow_framed.png",
	sounds = default.node_sound_glass_defaults(),
	groups = {snappy=2, cracky=3},
	recipe = {
		{"default:glass", "dye:yellow", "default:glass"},
		{"", "default:glass", ""},
		{"","",""}
	}
})

--xpane Blue
xpanes.register_pane("myglass:glass_pane_blue", {
	description = ("Blue Glass Pane"),
	textures = {"myglass_blue_framed.png", "", "myglass_blue.png"},
	inventory_image = "myglass_blue_framed.png",
	wield_image = "myglass_blue_framed.png",
	sounds = default.node_sound_glass_defaults(),
	groups = {snappy=2, cracky=3},
	recipe = {
		{"default:glass", "dye:blue", "default:glass"},
		{"", "default:glass", ""},
		{"","",""}
	}
})

--xpane Red
xpanes.register_pane("myglass:glass_pane_red", {
	description = ("Red Glass Pane"),
	textures = {"myglass_red_framed.png", "", "myglass_red.png"},
	inventory_image = "myglass_red_framed.png",
	wield_image = "myglass_red_framed.png",
	sounds = default.node_sound_glass_defaults(),
	groups = {snappy=2, cracky=3},
	recipe = {
		{"default:glass", "dye:red", "default:glass"},
		{"", "default:glass", ""},
		{"","",""}
	}
})

--xpane Lime
xpanes.register_pane("myglass:glass_pane_lime", {
	description = ("Lime Glass Pane"),
	textures = {"myglass_lime_framed.png", "", "myglass_lime.png"},
	inventory_image = "myglass_lime_framed.png",
	wield_image = "myglass_lime_framed.png",
	sounds = default.node_sound_glass_defaults(),
	groups = {snappy=2, cracky=3},
	recipe = {
		{"default:glass", "dye:green", "default:glass"},
		{"", "default:glass", ""},
		{"","",""}
	}
})
