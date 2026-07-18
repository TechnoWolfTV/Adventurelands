minetest.register_craftitem("rangedweapons:glass_shards", {
		description = "" ..core.colorize("#35cdff","Glass shards\n")..core.colorize("#FFFFFF", "3 of those, can be crafted into a file of glass fragments"),
	inventory_image = "rangedweapons_glass_shards.png",
})
minetest.register_craft({
	output = "vessels:glass_fragments",
	recipe = {
		{"rangedweapons:glass_shards", "rangedweapons:glass_shards", "rangedweapons:glass_shards"},
	}
})

minetest.register_node("rangedweapons:broken_glass", {
	description = "Broken glass",
	drawtype = "glasslike",
	-- Was the deprecated numeric `alpha = 160`. The modern equivalent keeps
	-- the same uniform translucency by baking the opacity into the texture
	-- and telling the engine to alpha-blend it.
	tiles = {
		"rangedweapons_broken_glass.png^[opacity:160"
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	is_ground_content = false,
	liquidtype = "source",
	liquid_alternative_flowing = "rangedweapons:broken_glass",
	liquid_alternative_source = "rangedweapons:broken_glass",
	liquid_viscosity = 7,
	liquid_range= 0,
	liquid_renewable = false,
	damage_per_second = 2,
	groups = {oddly_breakable_by_hand = 3},
})

