--reverse craft for glow mese
minetest.register_craft({
	output = "default:mese_crystal_fragment 8",
	recipe = {{"caverealms:glow_mese"}}
})

--[[thin ice to water
minetest.register_craft({
	output = "default:water_source",
	recipe = {{"caverealms:thin_ice"}}
})]]

--use for coal dust
minetest.register_craft({
	output = "default:coalblock",
	recipe = {
		{"caverealms:coal_dust","caverealms:coal_dust","caverealms:coal_dust"},
		{"caverealms:coal_dust","caverealms:coal_dust","caverealms:coal_dust"},
		{"caverealms:coal_dust","caverealms:coal_dust","caverealms:coal_dust"}
	}
})

-- DM statue
minetest.register_craft({
	output = "caverealms:dm_statue",
	recipe = {
		{"caverealms:glow_ore","caverealms:hot_cobble","caverealms:glow_ore"},
		{"caverealms:hot_cobble","caverealms:hot_cobble","caverealms:hot_cobble"},
		{"caverealms:hot_cobble","caverealms:hot_cobble","caverealms:hot_cobble"}
	}
})

-- Glow obsidian brick
minetest.register_craft({
	output = "caverealms:glow_obsidian_brick 4",
	recipe = {
		{"caverealms:glow_obsidian", "caverealms:glow_obsidian"},
		{"caverealms:glow_obsidian", "caverealms:glow_obsidian"}
	}
})

minetest.register_craft({
	output = "caverealms:glow_obsidian_brick_2 4",
	recipe = {
		{"caverealms:glow_obsidian_2", "caverealms:glow_obsidian_2"},
		{"caverealms:glow_obsidian_2", "caverealms:glow_obsidian_2"}
	}
})

-- Glow obsidian glass
minetest.register_craft({
	output = "caverealms:glow_obsidian_glass 5",
	recipe = {
		{"default:obsidian_glass", "default:obsidian_glass", "default:obsidian_glass"},
		{"default:obsidian_glass", "default:obsidian_glass", "caverealms:glow_obsidian"}
	}
})

minetest.register_craft({
	output = "caverealms:glow_obsidian_glass 5",
	recipe = {
		{"default:obsidian_glass", "default:obsidian_glass", "default:obsidian_glass"},
		{"default:obsidian_glass", "default:obsidian_glass", "caverealms:glow_obsidian_2"}
	}
})

-- Requires ethereal
if minetest.get_modpath("ethereal") then

	-- Glow Bait
	minetest.register_craftitem("caverealms:glow_bait", {
		description = "Glow Bait",
		inventory_image = "caverealms_glow_bait.png",
		wield_image = "caverealms_glow_bait.png"
	})

	minetest.register_craft({
		output = "caverealms:glow_bait 3",
		recipe = {{"caverealms:glow_worm_green"}}
	})

	-- alias old pro fishing rods
	minetest.register_alias("caverealms:angler_rod", "default:steel_ingot")
	minetest.register_alias("caverealms:angler_rod_baited", "default:steel_ingot")
end
