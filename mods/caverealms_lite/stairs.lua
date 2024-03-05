-- stair mods active
local stairs_mod = minetest.get_modpath("stairs")
local stairs_redo = stairs_mod and stairs.mod and stairs.mod == "redo"
local stairs_plus = minetest.global_exists("stairsplus")

-- stair selection function
local do_stair = function(
		description, name, node, groups, texture, sound, sunlight, light_source)

	if stairs_redo then

		stairs.register_all(name, node,	groups, texture, description, sound)

	elseif stairs_plus then

		local mod = "caverealms"
		local registrations = {"register_stair", "register_slab", "register_slope",
				"register_panel", "register_micro"}

		for i, reg in ipairs(registrations) do

			stairsplus[reg](stairsplus, mod, name, node, {
				description = description,
				tiles = {texture[i] or texture[1]},
				groups = groups,
				sunlight_propagates = sunlight,
				light_source = light_source,
				sounds = sound
			})
		end

		-- aliases need to be set for previous stairs to avoid unknown nodes
		minetest.register_alias_force("stairs:stair_" .. name,
				mod .. ":stair_" .. name)

		minetest.register_alias_force("stairs:stair_outer_" .. name,
				mod .. ":stair_" .. name .. "_outer")

		minetest.register_alias_force("stairs:stair_inner_" .. name,
				mod .. ":stair_" .. name .. "_inner")

		minetest.register_alias_force("stairs:slab_"  .. name,
				mod .. ":slab_"  .. name)

	elseif stairs_mod then

		stairs.register_stair_and_slab(name, node, groups, texture,
				description .. " Stair", description .. " Slab", sound)
	end
end


-- Register Stairs (stair mod will be auto-selected)
do_stair(
	"Glow Obsidian Brick",
	"glow_obsidian_brick",
	"caverealms:glow_obsidian_brick",
	{cracky = 1, level = 2},
	{"caverealms_glow_obsidian_brick.png"},
	default.node_sound_stone_defaults(),
	false,
	7)

do_stair(
	"Glow Obsidian Brick",
	"glow_obsidian_brick_2",
	"caverealms:glow_obsidian_brick_2",
	{cracky = 1, level = 2},
	{"caverealms_glow_obsidian_brick_2.png"},
	default.node_sound_stone_defaults(),
	false,
	9)


-- Glow Obsidian Glass (stairs registered seperately to use special texture)

local gsides = minetest.settings:get_bool("stairs.glass_sides") ~= false
local face_tex = "caverealms_glow_obsidian_glass.png"
local side_tex = gsides and "caverealms_glow_obsidian_glass_quarter.png" or face_tex

if not stairs_plus and stairs_mod then

	stairs.register_stair(
		"glow_obsidian_glass",
		"caverealms:glow_obsidian_glass",
		{cracky = 2},
		{side_tex, face_tex, side_tex, side_tex, face_tex, side_tex},
		"Glow Obsidian Glass Stair",
		default.node_sound_glass_defaults(),
		false
	)

	stairs.register_slab(
		"glow_obsidian_glass",
		"caverealms:glow_obsidian_glass",
		{cracky = 2},
		{face_tex, face_tex, side_tex},
		"Glow Obsidian Glass Slab",
		default.node_sound_glass_defaults(),
		false
	)

	stairs.register_stair_inner(
		"glow_obsidian_glass",
		"caverealms:glow_obsidian_glass",
		{cracky = 2},
		{side_tex, face_tex, side_tex, face_tex, face_tex, side_tex},
		"",
		default.node_sound_glass_defaults(),
		false,
		"Inner Glow Obsidian Glass Stair"
	)

	stairs.register_stair_outer(
		"glow_obsidian_glass",
		"caverealms:glow_obsidian_glass",
		{cracky = 2},
		{side_tex, face_tex, side_tex, side_tex, side_tex, side_tex},
		"",
		default.node_sound_glass_defaults(),
		false,
		"Outer Glow Obsidian Glass Stair"
	)

	if stairs_redo then

		stairs.register_slope(
			"glow_obsidian_glass",
			"caverealms:glow_obsidian_glass",
			{cracky = 2},
			{face_tex},
			"Glow Obsidian Glass Slope",
			default.node_sound_glass_defaults()
		)

		stairs.register_slope_inner(
			"glow_obsidian_glass",
			"caverealms:glow_obsidian_glass",
			{cracky = 2},
			{face_tex},
			"Glow Obsidian Glass Inner Slope",
			default.node_sound_glass_defaults()
		)

		stairs.register_slope_outer(
			"glow_obsidian_glass",
			"caverealms:glow_obsidian_glass",
			{cracky = 2},
			{face_tex},
			"Glow Obsidian Glass Outer Slope",
			default.node_sound_glass_defaults()
		)
	end
end

-- this will use above function to register stairs_plus only nodes
if stairs_plus then

	do_stair(
		"Glow Obsidian Glass",
		"glow_obsidian_glass",
		"caverealms:glow_obsidian_glass",
		{cracky = 3},
		{side_tex, face_tex, face_tex, face_tex, side_tex},
		default.node_sound_glass_defaults(),
		true,
		13)
end
