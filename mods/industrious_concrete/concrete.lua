-- -- Concrete --
-- --- SOUNDS
local concrete_sound = default.node_sound_stone_defaults({
	footstep = {name = "industrious_concrete_footstep", gain = 0.15, pitch = 0.9},
	dig = {name = "industrious_concrete_footstep", gain = 0.4, pitch = 1.1},
	dug = {name = "industrious_concrete_dug", gain = 0.37},
})

-- --- CONCRETE

-- Concrete
minetest.register_node("industrious_concrete:concrete", {
	description = "Concrete",
	tiles = {"industrious_concrete.png"},
	groups = {cracky = 2},
	sounds = concrete_sound,
	drop = "industrious_concrete:concrete_powder",
})

minetest.register_craft({
	output = "industrious_concrete:concrete 8",
	recipe = {
		{"industrious_concrete:concrete_powder", "industrious_concrete:concrete_powder", "industrious_concrete:concrete_powder"},
		{"industrious_concrete:concrete_powder", "bucket:bucket_water", "industrious_concrete:concrete_powder"},
		{"industrious_concrete:concrete_powder", "industrious_concrete:concrete_powder", "industrious_concrete:concrete_powder"},
	},
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}}
})

-- Concrete Powder
minetest.register_node("industrious_concrete:concrete_powder", {
	description = "Concrete Powder",
	tiles = {"industrious_concrete_powder.png"},
	groups = {oddly_breakable_by_hand = 1, falling_node = 1},
	sounds = default.node_sound_sand_defaults(),
})

minetest.register_craft({
	output = "industrious_concrete:concrete_powder 4",
	recipe = {
		{"group:sand", "default:gravel"},
		{"default:gravel", "group:sand"},
	}
})

-- Concrete with Caution Tape
minetest.register_node("industrious_concrete:concrete_caution", {
	description = "Concrete with Caution Tape",
	tiles = {
		"industrious_concrete_painted_top.png",
		"industrious_concrete_slab.png",
		"industrious_concrete_painted_side.png",
		"industrious_concrete_painted_side.png",
		"industrious_concrete_painted_side.png",
		"industrious_concrete_painted_side.png",
	},
	groups = {cracky = 2},
	sounds = concrete_sound,
	drop = "industrious_concrete:concrete_powder",
})

minetest.register_craft({
	output = "industrious_concrete:concrete_caution 4",
	recipe = {
		{"industrious_concrete:concrete", "industrious_concrete:concrete", "dye:black"},
		{"industrious_concrete:concrete", "industrious_concrete:concrete", "dye:yellow"},
	}
})

-- Concrete Slab
minetest.register_node("industrious_concrete:concrete_slab", {
	description = "Concrete Slab",
	drawtype = "nodebox",
	tiles = {"industrious_concrete_slab.png"},
	paramtype = "light",
	groups = {cracky = 2},
	sounds = concrete_sound,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5000, -0.5000, -0.5000, 0.5000, 0.0000, 0.5000},
		},
	},
})

minetest.register_craft({
	output = "industrious_concrete:concrete_slab 6",
	recipe = {
		{"industrious_concrete:concrete", "industrious_concrete:concrete", "industrious_concrete:concrete"},
	}
})

-- Concrete Block
minetest.register_node("industrious_concrete:concrete_block", {
	description = "Concrete Block",
	drawtype = "nodebox",
	inventory_image = "industrious_concrete_block.png",
	tiles = {
		"industrious_concrete_block_top.png",
		"industrious_concrete_block_top.png",
		"industrious_concrete.png",
		"industrious_concrete.png",
		"industrious_concrete.png",
		"industrious_concrete.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, falling_node = 1},
	sounds = concrete_sound,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.2500, -0.5000, -0.5000, 0.2500, 0.0000, 0.5000},
		},
	},
})

minetest.register_craft({
	output = "industrious_concrete:concrete_block 16",
	recipe = {
		{"industrious_concrete:concrete", "industrious_concrete:concrete"},
		{"industrious_concrete:concrete", "industrious_concrete:concrete"},
	}
})

-- Concrete Block Wall
minetest.register_node("industrious_concrete:concrete_block_wall", {
	description = "Concrete Block Wall",
	tiles = {
		"industrious_concrete_block_wall_top.png",
		"industrious_concrete_block_wall_top.png",
		"industrious_concrete_block_wall_side.png",
		"industrious_concrete_block_wall_side.png",
		"industrious_concrete_block_wall_side.png",
		"industrious_concrete_block_wall_side.png",
	},
	groups = {cracky = 2},
	sounds = concrete_sound,
})

minetest.register_craft({
	output = "industrious_concrete:concrete_block_wall 1",
	recipe = {
		{"industrious_concrete:concrete_block", "industrious_concrete:concrete_block"},
		{"industrious_concrete:concrete_block", "industrious_concrete:concrete_block"},
	}
})

-- Concrete Brick
minetest.register_craftitem("industrious_concrete:concrete_brick", {
	description = "Concrete Brick",
	inventory_image = "industrious_concrete_brick.png",
})

minetest.register_craft({
	output = "industrious_concrete:concrete_brick 4",
	recipe = {
		{"industrious_concrete:concrete"},
	}
})

-- Concrete Brick Wall
minetest.register_node("industrious_concrete:concrete_brick_wall", {
	description = "Concrete Brick Wall",
	tiles = {"industrious_concrete_brick_wall.png"},
	groups = {cracky = 2},
	sounds = concrete_sound,
})

minetest.register_craft({
	output = "industrious_concrete:concrete_brick_wall 1",
	recipe = {
		{"industrious_concrete:concrete_brick", "industrious_concrete:concrete_brick"},
		{"industrious_concrete:concrete_brick", "industrious_concrete:concrete_brick"},
	}
})

-- --- STAIRS+ SUPPORT (More Blocks circular saw)
-- Register only these four nodes with Stairs+ / circular saw.
-- stairsplus:register_all() is the More Blocks API call that also registers
-- the material with the circular saw.
if minetest.get_modpath("moreblocks") and stairsplus then
	stairsplus:register_all("industrious_concrete", "concrete",
		"industrious_concrete:concrete", {
			description = "Concrete",
			tiles = {"industrious_concrete.png"},
			groups = {cracky = 2},
			sounds = concrete_sound,
			drop = "industrious_concrete:concrete_powder",
		}
	)

	stairsplus:register_all("industrious_concrete", "concrete_block_wall",
		"industrious_concrete:concrete_block_wall", {
			description = "Concrete Block Wall",
			tiles = {
				"industrious_concrete_block_wall_top.png",
				"industrious_concrete_block_wall_top.png",
				"industrious_concrete_block_wall_side.png",
				"industrious_concrete_block_wall_side.png",
				"industrious_concrete_block_wall_side.png",
				"industrious_concrete_block_wall_side.png",
			},
			groups = {cracky = 2},
			sounds = concrete_sound,
		}
	)

	stairsplus:register_all("industrious_concrete", "concrete_brick_wall",
		"industrious_concrete:concrete_brick_wall", {
			description = "Concrete Brick Wall",
			tiles = {"industrious_concrete_brick_wall.png"},
			groups = {cracky = 2},
			sounds = concrete_sound,
		}
	)

	stairsplus:register_all("industrious_concrete", "concrete_caution",
		"industrious_concrete:concrete_caution", {
			description = "Concrete with Caution Tape",
			tiles = {
				"industrious_concrete_painted_top.png",
				"industrious_concrete_slab.png",
				"industrious_concrete_painted_side.png",
				"industrious_concrete_painted_side.png",
				"industrious_concrete_painted_side.png",
				"industrious_concrete_painted_side.png",
			},
			groups = {cracky = 2},
			sounds = concrete_sound,
			drop = "industrious_concrete:concrete_powder",
		}
	)
end

-- --- NORMAL STAIRS MOD SUPPORT
-- These create standard stairs:stair_* and stairs:slab_* craftable nodes.
-- Unique subnames are used to avoid collisions with other mods.
if minetest.get_modpath("stairs") and stairs then
	stairs.register_stair_and_slab(
		"industrious_concrete_concrete",
		"industrious_concrete:concrete",
		{cracky = 2},
		{"industrious_concrete.png"},
		"Concrete Stair",
		"Concrete Slab",
		concrete_sound,
		false,
		"industrious_concrete:concrete_powder"
	)

	stairs.register_stair_and_slab(
		"industrious_concrete_concrete_block_wall",
		"industrious_concrete:concrete_block_wall",
		{cracky = 2},
		{
			"industrious_concrete_block_wall_top.png",
			"industrious_concrete_block_wall_top.png",
			"industrious_concrete_block_wall_side.png",
			"industrious_concrete_block_wall_side.png",
			"industrious_concrete_block_wall_side.png",
			"industrious_concrete_block_wall_side.png",
		},
		"Concrete Block Wall Stair",
		"Concrete Block Wall Slab",
		concrete_sound,
		false
	)

	stairs.register_stair_and_slab(
		"industrious_concrete_concrete_brick_wall",
		"industrious_concrete:concrete_brick_wall",
		{cracky = 2},
		{"industrious_concrete_brick_wall.png"},
		"Concrete Brick Wall Stair",
		"Concrete Brick Wall Slab",
		concrete_sound,
		false
	)

	stairs.register_stair_and_slab(
		"industrious_concrete_concrete_caution",
		"industrious_concrete:concrete_caution",
		{cracky = 2},
		{
			"industrious_concrete_painted_top.png",
			"industrious_concrete_slab.png",
			"industrious_concrete_painted_side.png",
			"industrious_concrete_painted_side.png",
			"industrious_concrete_painted_side.png",
			"industrious_concrete_painted_side.png",
		},
		"Concrete with Caution Tape Stair",
		"Concrete with Caution Tape Slab",
		concrete_sound,
		false,
		"industrious_concrete:concrete_powder"
	)
end
