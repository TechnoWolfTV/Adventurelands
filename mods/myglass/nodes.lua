
mypaint_windows = {}

mypaint_windows.colors = {
	{"black",      "Black",      "#000000"},
	{"blue",       "Blue",       "#2000c9"},
	{"brown",      "Brown",      "#954c05"},
	{"cyan",       "Cyan",       "#01ffd8"},
	{"darkgreen", "Dark Green",  "#005b07"},
	{"darkgrey",  "Dark Grey",   "#303030"},
	{"green",      "Green",      "#61ff01"},
	{"grey",       "Grey",       "#5b5b5b"},
	{"magenta",    "Magenta",    "#ff05bb"},
	{"orange",     "Orange",     "#ff8401"},
	{"pink",       "Pink",       "#ff65b5"},
	{"red",        "Red",        "#ff0000"},
	{"violet",     "Violet",     "#ab23b0"},
	{"white",      "White",      "#ffffff"},
	{"yellow",     "Yellow",     "#e3ff00"},
}

if core.get_modpath("mydye") then
	mypaint_windows.colors = {
	{"black",      	"Black",      		"#000000"},
	{"blue",       	"Blue",       		"#2000c9"},
	{"brown",     	"Brown",      		"#954c05"},
	{"cyan",      	"Cyan",       		"#01ffd8"},
	{"darkgreen", 	"Dark Green",  		"#005b07"},
	{"darkgrey",  	"Dark Grey",   		"#303030"},
	{"green",     	"Green",      		"#61ff01"},
	{"grey",       	"Grey",       		"#5b5b5b"},
	{"magenta",    	"Magenta",    		"#ff05bb"},
	{"orange",     	"Orange",     		"#ff8401"},
	{"pink",      	"Pink",       		"#ff65b5"},
	{"red",        	"Red",        		"#ff0000"},
	{"violet",     	"Violet",     		"#ab23b0"},
	{"white",      	"White",      		"#ffffff"},
	{"yellow",     	"Yellow",     		"#e3ff00"},
	{"peachpuff",	"Peachpuff", 		"#FFDAB9"},
	{"navy",		"Navy", 			"#000080"},
	{"coral",		"Coral", 			"#FF7F50"},
	{"khaki",		"Khaki", 			"#F0E68C"},
	{"lime",		"Lime", 			"#00FF00"},
	{"light_pink",	"Light Pink", 		"#FFB6C1"},
	{"light_grey",	"Light Grey", 		"#D3D3D3"},
	{"purple",		"Purple", 			"#800080"},
	{"maroon",		"Maroon", 			"#800000"},
	{"aquamarine",	"Aqua Marine", 		"#7FFFD4"},
	{"chocolate",	"Chocolate", 		"#D2691E"},
	{"crimson",		"Crimson", 			"#DC143C"},
	{"olive",		"Olive", 			"#808000"},
	{"white_smoke",	"White Smoke", 		"#F5F5F5"},
	{"mistyrose",	"Misty Rose", 		"#FFE4E1"},
	{"orchid",		"Orchid", 			"#DA70D6"},
	}
end

--Window Frame
core.register_node("myglass:window_frame", {
	description = "Wood Window Frame",
	tiles = {"default_pine_wood.png"},
	drawtype = "mesh",
	mesh = "myglass_window2.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			}
		},
	on_place = core.rotate_node
})

--Window Horizontal
core.register_node("myglass:window_horizontal", {
	description = "Wood Window Horizontal",
	tiles = {"default_pine_wood.png"},
	drawtype = "mesh",
	mesh = "myglass_window3.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.0625, -0.0625, 0.5, 0.0625, 0.0625},
			}
		},
	on_place = core.rotate_node
})

--Window Vertical
core.register_node("myglass:window_vertical", {
	description = "Wood Window Vertical",
	tiles = {"default_pine_wood.png"},
	drawtype = "mesh",
	mesh = "myglass_window5.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
			}
		},
	on_place = core.rotate_node
})

--Window Plus
core.register_node("myglass:window_plus", {
	description = "Wood Window Plus",
	tiles = {"default_pine_wood.png"},
	drawtype = "mesh",
	mesh = "myglass_window4.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
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
	on_place = core.rotate_node
})

--Window Frame White
core.register_node("myglass:window_frame_white", {
	description = "Window Frame White",
	tiles = {"myglass_white.png"},
	drawtype = "mesh",
	mesh = "myglass_window2.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			}
		},
	on_place = core.rotate_node
})

--Window Horizontal White
core.register_node("myglass:window_horizontal_white", {
	description = "Window Horizontal White",
	tiles = {"myglass_white.png"},
	drawtype = "mesh",
	mesh = "myglass_window3.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.0625, -0.0625, 0.5, 0.0625, 0.0625},
			}
		},
	on_place = core.rotate_node
})

--Window Vertical White
core.register_node("myglass:window_vertical_white", {
	description = "Window Vertical White",
	tiles = {"myglass_white.png"},
	drawtype = "mesh",
	mesh = "myglass_window5.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.0625, 0.5, 0.5, 0.0625},
			{-0.5, -0.5, -0.0625, 0.5, -0.375, 0.0625},
			{-0.5, -0.5, -0.0625, -0.375, 0.5, 0.0625},
			{0.375, -0.5, -0.0625, 0.5, 0.5, 0.0625},
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
			}
		},
	on_place = core.rotate_node
})

--Window Plus White
core.register_node("myglass:window_plus_white", {
	description = "Window Plus White",
	tiles = {"myglass_white.png"},
	drawtype = "mesh",
	mesh = "myglass_window4.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
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
	on_place = core.rotate_node
})
local colors = {"red", "cyan", "green", "violet", "purple", "white"}
for _,col in pairs(colors) do
--Blinds
core.register_node("myglass:blinds_"..col, {
	description = "Blinds - "..col,
	tiles = {"myglass_blinds_"..col..".png"},
	drawtype = "mesh",
	mesh = "myglass_blinds.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.45},
			}
		},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.45},
			}
		},
	on_punch = function(pos, node, puncher, pointed_thing)
		core.set_node(pos, {name = "myglass:blinds_up_"..col, param2 = node.param2})
	end
})
core.register_node("myglass:blinds_up_"..col, {
	description = "Blinds Up - "..col,
	tiles = {"myglass_blinds_"..col..".png"},
	drawtype = "mesh",
	mesh = "myglass_blinds_up.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.45},
			}
		},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.45},
			}
		},
	on_punch = function(pos, node, puncher, pointed_thing)
		core.set_node(pos, {name = "myglass:blinds_"..col, param2 = node.param2})
	end
})
end

--Crafts
--------------------------------------------------------------------

--Window Frame

core.register_craft({
	output = "myglass:window_frame 4",
	recipe = {
		{"group:wood", "default:glass",""},
		{"default:glass", "group:wood",""},
		{"", "",""}
	}
})

--Window Horizontal

core.register_craft({
	output = "myglass:window_horizontal 3",
	recipe = {
		{"", "",""},
		{"group:wood", "default:glass","group:wood"},
		{"", "",""}
	}
})

--Window Vertical

core.register_craft({
	output = "myglass:window_vertical 3",
	recipe = {
		{"", "group:wood",""},
		{"", "default:glass",""},
		{"", "group:wood",""}
	}
})

--Window Plus

core.register_craft({
	output = "myglass:window_plus 5",
	recipe = {
		{"", "group:wood",""},
		{"group:wood", "default:glass","group:wood"},
		{"", "group:wood",""}
	}
})

--Window Frame White

core.register_craft({
	type = "shapeless",
	output = "myglass:window_frame_white 1",
	recipe = {
		"myglass:window_frame", "dye:white"
	}
})

--Window Horizontal White

core.register_craft({
	type = "shapeless",
	output = "myglass:window_horizontal_white 1",
	recipe = {
		"myglass:window_horizontal", "dye:white"
	}
})

--Window Vertical White

core.register_craft({
	type = "shapeless",
	output = "myglass:window_vertical_white 1",
	recipe = {
		"myglass:window_vertical", "dye:white"
	}
})

--Window Plus White

core.register_craft({
	type = "shapeless",
	output = "myglass:window_plus_white 1",
	recipe = {
		"myglass:window_plus", "dye:white"
	}
})
--Blinds
core.register_craft({
	output = "myglass:blinds_white 1",
	recipe = {
		{"default:stick", "dye:white",""},
		{"default:stick", "",""},
		{"default:stick", "",""}
	}
})
core.register_craft({
	type = "shapeless",
	output = "myglass:blinds_red 1",
	recipe = {
		"myglass:blinds_white", "dye:red"
	}
})
core.register_craft({
	type = "shapeless",
	output = "myglass:blinds_cyan 1",
	recipe = {
		"myglass:blinds_white", "dye:cyan"
	}
})
core.register_craft({
	type = "shapeless",
	output = "myglass:blinds_green 1",
	recipe = {
		"myglass:blinds_white", "dye:green"
	}
})
core.register_craft({
	type = "shapeless",
	output = "myglass:blinds_violet 1",
	recipe = {
		"myglass:blinds_white", "dye:violet"
	}
})
core.register_craft({
	type = "shapeless",
	output = "myglass:blinds_purple 1",
	recipe = {
		"myglass:blinds_white", "mydye:purple"
	}
})
-----------------------------------------------------
local paintables = {
	"myglass:window_frame", "myglass:window_horizontal", "myglass:window_vertical", "myglass:window_plus"
}

for _, entry in ipairs(mypaint_windows.colors) do
	local color = entry[1]
	local desc = entry[2]
	local paint = entry[3]

	local windows = {{"window_frame", "Window Frame", "default_pine_wood", "window2"},
				 	{"window_horizontal", "Horizontal Window", "default_pine_wood", "window3"},
				 	{"window_vertical", "Vertical Window", "default_pine_wood", "window5"},
				 	{"window_plus", "Plus Window", "default_pine_wood", "window4"},
				 	}
	
	for i in ipairs(windows) do
		local mat = windows[i][1]
		local des = windows[i][2]
		local img = windows[i][3]
		local msh = windows[i][4]
	
		core.register_node("myglass:"..mat.."_"..color, {
			description = desc.." "..des,
			tiles = {img..".png^[colorize:"..paint..":250"},
			drawtype = "mesh",
			mesh = "myglass_"..msh..".obj",
			paramtype = "light",
			paramtype2 = "facedir",
			groups = {cracky = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1},
			selection_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.0625, 0.5, 0.5, 0.0625},
					}
				},
			on_place = core.rotate_node
		})
	end
end
minetest.override_item("myglass:window_frame_white",{groups = {cracky = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory=0},})
minetest.override_item("myglass:window_horizontal_white",{groups = {cracky = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory=0},})
minetest.override_item("myglass:window_vertical_white",{groups = {cracky = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory=0},})
minetest.override_item("myglass:window_plus_white",{groups = {cracky = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory=0},})

if core.get_modpath("mypaint") then
local colors = {}
for _, entry in ipairs(mypaint_windows.colors) do
	table.insert(colors, entry[1])
end
	mypaint.register(paintables, colors)
end
