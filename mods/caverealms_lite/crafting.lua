--reverse craft for glow mese
core.register_craft({
	output = "default:mese_crystal_fragment 8",
	recipe = {{"caverealms:glow_mese"}}
})

--[[thin ice to water
core.register_craft({
	output = "default:water_source",
	recipe = {{"caverealms:thin_ice"}}
})]]

--use for coal dust
core.register_craft({
	output = "default:coalblock",
	recipe = {
		{"caverealms:coal_dust","caverealms:coal_dust","caverealms:coal_dust"},
		{"caverealms:coal_dust","caverealms:coal_dust","caverealms:coal_dust"},
		{"caverealms:coal_dust","caverealms:coal_dust","caverealms:coal_dust"}
	}
})

-- DM statue
core.register_craft({
	output = "caverealms:dm_statue",
	recipe = {
		{"caverealms:glow_ore","caverealms:hot_cobble","caverealms:glow_ore"},
		{"caverealms:hot_cobble","caverealms:hot_cobble","caverealms:hot_cobble"},
		{"caverealms:hot_cobble","caverealms:hot_cobble","caverealms:hot_cobble"}
	}
})

-- Glow obsidian brick
core.register_craft({
	output = "caverealms:glow_obsidian_brick 4",
	recipe = {
		{"caverealms:glow_obsidian", "caverealms:glow_obsidian"},
		{"caverealms:glow_obsidian", "caverealms:glow_obsidian"}
	}
})

core.register_craft({
	output = "caverealms:glow_obsidian_brick_2 4",
	recipe = {
		{"caverealms:glow_obsidian_2", "caverealms:glow_obsidian_2"},
		{"caverealms:glow_obsidian_2", "caverealms:glow_obsidian_2"}
	}
})

-- Glow obsidian glass
core.register_craft({
	output = "caverealms:glow_obsidian_glass 5",
	recipe = {
		{"default:obsidian_glass", "default:obsidian_glass", "default:obsidian_glass"},
		{"default:obsidian_glass", "default:obsidian_glass", "caverealms:glow_obsidian"}
	}
})

core.register_craft({
	output = "caverealms:glow_obsidian_glass 5",
	recipe = {
		{"default:obsidian_glass", "default:obsidian_glass", "default:obsidian_glass"},
		{"default:obsidian_glass", "default:obsidian_glass", "caverealms:glow_obsidian_2"}
	}
})

-- Requires ethereal
if core.get_modpath("ethereal") then

	-- Glow Bait
	core.register_craftitem("caverealms:glow_bait", {
		description = "Glow Bait",
		inventory_image = "caverealms_glow_bait.png",
		wield_image = "caverealms_glow_bait.png"
	})

	core.register_craft({
		output = "caverealms:glow_bait 3",
		recipe = {{"caverealms:glow_worm_green"}}
	})

	local ethereal_fish = {
		"ethereal:fish_chichlid", "ethereal:fish_chichlid", "ethereal:fish_chichlid",
		"ethereal:fish_chichlid", "ethereal:fish_chichlid", "default:grass_1",
		"ethereal:fish_bluefin", "ethereal:fish_bluefin", "ethereal:fish_bluefin",
		"ethereal:fish_bluefin", "ethereal:fish_bluefin", "default:stick",
		"ethereal:fish_clownfish", "ethereal:fish_clownfish", "ethereal:fish_clownfish",
		"ethereal:fish_clownfish", "ethereal:fish_clownfish", "farming:string"}

-- Used when right-clicking with fishing rod to check for worm and bait rod
	local function rod_use(itemstack, placer, pointed_thing)

		local inv = placer:get_inventory()

		if inv:contains_item("main", "caverealms:glow_bait") then

			inv:remove_item("main", "caverealms:glow_bait")

			return ItemStack("caverealms:angler_rod_baited")
		end

		return itemstack
	end

	-- Fishing Rod
	core.register_craftitem("caverealms:angler_rod", {
		description = "Simple Fishing Rod",
		inventory_image = "caverealms_angler_rod.png",
		wield_image = "caverealms_angler_rod.png^[transformFYR90",
		on_place = rod_use,
		on_secondary_use = rod_use
	})

	core.register_craft({
		output = "caverealms:angler_rod",
		recipe = {
			{"","","default:steel_ingot"},
			{"", "default:steel_ingot", "caverealms:mushroom_gills"},
			{"default:steel_ingot", "", "caverealms:mushroom_gills"}
		}
	})

	-- Pro Fishing Rod (Baited)
	core.register_craftitem("caverealms:angler_rod_baited", {
		description = "Baited Simple Fishing Rod (USE on water source)",
		inventory_image = "caverealms_angler_rod_baited.png",
		wield_image = "caverealms_angler_rod_baited.png^[transformFYR90",
		stack_max = 1,
		liquids_pointable = true,

		on_use = function (itemstack, user, pointed_thing)

			if pointed_thing.type == "node" and math.random(100) < 6
			and core.get_node(pointed_thing.under).name == "default:water_source" then

				local fish = ethereal_fish[math.random(#ethereal_fish)]
				local inv = user:get_inventory()

				if inv:room_for_item("main", {name = fish}) then

					inv:add_item("main", {name = fish})

					return ItemStack("caverealms:angler_rod")
				else
					core.chat_send_player(user:get_player_name(),
							"Inventory full, Fish Got Away!")
				end
			end

			return itemstack
		end
	})

	core.register_craft({
		output = "caverealms:angler_rod_baited",
		recipe = {{"caverealms:angler_rod", "caverealms:glow_bait"}}
	})
end
