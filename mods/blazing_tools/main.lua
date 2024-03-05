local S = minetest.get_translator("blazing_tools")

-- Nodes

minetest.register_node("blazing_tools:blazing_block", {
	description = S("Blazing Block"),
	tiles = {"blazing_block.png"},
	light_source = 13,
	is_ground_content = true,
	groups = {cracky=2},

	sounds = default.node_sound_stone_defaults(),
})

-- Tools

minetest.register_tool("blazing_tools:pick_blazing", {
	description = S("Blazing Pickaxe"),
	inventory_image = "blazing_pick.png",
	light_source = 13,
	tool_capabilities = {
		full_punch_interval = 0.45,
		max_drop_level=3,
		groupcaps={
			cracky={times={[1]=0.10, [2]=0.10, [3]=0.10}, uses=1000, maxlevel=2}
		},
		damage_groups = {fleshy=6},
	},
	groups = {pickaxe = 1, enchantability=22}
})

minetest.register_tool("blazing_tools:shovel_blazing", {
	description = S("Blazing Shovel"),
	inventory_image = "blazing_shovel.png",
	light_source = 13,
	tool_capabilities = {
		full_punch_interval = 0.45,
		max_drop_level=3,
		groupcaps={
			crumbly={times={[1]=0.05, [2]=0.05, [3]=0.05}, uses=1000, maxlevel=2}
		},
		damage_groups = {fleshy=5},
	},
	groups = {shovel = 1, enchantability=22}
})

minetest.register_tool("blazing_tools:axe_blazing", {
	description = S("Blazing Axe"),
	inventory_image = "blazing_axe.png",
	light_source = 13,
	tool_capabilities = {
		full_punch_interval = 0.45,
		max_drop_level=3,
		groupcaps={
			choppy={times={[1]=0.15, [2]=0.15, [3]=0.15}, uses=1000, maxlevel=2},
			fleshy={times={[1]=0.15, [2]=0.15, [3]=0.15}, uses=1000, maxlevel=2}
		},
		damage_groups = {fleshy=8},
	},
	groups = {axe = 1, enchantability=22}
})

minetest.register_tool("blazing_tools:sword_blazing", {
	description = S("Blazing Sword"),
	inventory_image = "blazing_sword.png",
	light_source = 13,
	tool_capabilities = {
		full_punch_interval = 0.45,
		max_drop_level=3,
		groupcaps={
			fleshy={times={[1]=0.20, [2]=0.20, [3]=0.20}, uses=1000, maxlevel=2},
			snappy={times={[1]=0.20, [2]=0.20, [3]=0.20}, uses=1000, maxlevel=2}
		},
		damage_groups = {fleshy=10},
	},
	groups = {sword = 1, enchantability=22}
})
