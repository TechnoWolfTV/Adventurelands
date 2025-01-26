
local S = minetest.get_translator("bows")

-- detect feather item to use

local feather = "default:leaves"

if minetest.get_modpath("animalia") then
	feather = "animalia:feather"
elseif minetest.get_modpath("mobs_animal") then
	feather = "mobs:chicken_feather"
elseif minetest.get_modpath("xanadu") then
	feather = "mobs:chicken_feather"
end

-- helpful recipes

minetest.register_craft({
	output = "default:flint",
	recipe = {{"default:gravel"}}
})

minetest.register_craft({
	output = "farming:cotton 4",
	recipe = {{"group:wool"}}
})

-- wooden bow

bows.register_bow("bow_wood",{
	description = S("Wooden bow"),
	texture = "bows_bow.png",
	texture_loaded = "bows_bow_loaded.png",
	uses = 50,
	level = 1,
	craft = {
		{"", "group:stick", "farming:string"},
		{"group:stick", "", "farming:string"},
		{"", "group:stick", "farming:string"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "bows:bow_wood",
	burntime = 3
})

-- steel bow

bows.register_bow("bow_steel",{
	description = S("Steel bow"),
	texture = "bows_bow_steel.png",
	texture_loaded = "bows_bow_loaded_steel.png",
	uses = 280,
	level = 5,
	craft = {
		{"", "default:steel_ingot", "farming:string"},
		{"default:steel_ingot", "", "farming:string"},
		{"", "default:steel_ingot", "farming:string"}
	}
})

-- bronze bow

bows.register_bow("bow_bronze",{
	description = S("Bronze bow"),
	texture = "bows_bow_bronze.png",
	texture_loaded = "bows_bow_loaded_bronze.png",
	uses = 140,
	level = 3,
	craft = {
		{"", "default:bronze_ingot", "farming:string"},
		{"default:bronze_ingot", "", "farming:string"},
		{"", "default:bronze_ingot", "farming:string"}
	}
})

-- special David BOWie (lucky block drop)

bows.register_bow("bow_bowie",{
	description = S("David BOWie"),
	texture = "bows_bow_bowie.png",
	texture_loaded = "bows_bow_loaded_bowie.png",
	uses = 500,
	level = 7
})

-- wooden arrow

bows.register_arrow("arrow",{
	description = S("Wooden arrow"),
	texture = "bows_arrow_wood.png",
	damage = 2,
	craft_count = 4,
	drop_chance = 10,
	craft = {
		{"default:flint", "group:stick", feather}
	},
	on_hit_sound = "bows_arrow_hit",
--[[
	on_hit_node = function(self, pos, user, arrow_pos)

		minetest.add_particle({
			pos = pos,
			velocity = {x=0, y=0, z=0},
			acceleration = {x=0, y=0, z=0},
			expirationtime = 1,
			size = 4,
			collisiondetection = false,
			vertical = false,
			texture = "heart.png",
		})
	end]]
})

minetest.register_craft({
	type = "fuel",
	recipe = "bows:arrow",
	burntime = 1
})

-- steel arrow

bows.register_arrow("arrow_steel",{
	description = S("Steel arrow"),
	texture = "bows_arrow_wood.png^[colorize:#FFFFFFcc",
	damage = 6,
	craft_count = 4,
	drop_chance = 9,
	craft = {
		{"default:steel_ingot", "group:stick", feather}
	},
	on_hit_sound = "bows_arrow_hit",
--[[
	on_hit_object = function(self, target, hp, user, lastpos)
		if target
		and target:get_luaentity()
		and target:get_luaentity().name
		and target:get_luaentity().name == "mob_horse:horse" then
			print ("--- aww da horsey!!!")
		end
	end,]]
	on_hit_node = function(self, pos, user, arrow_pos)
	end
})

-- mese arrow (enables node mesecons when hit)

bows.register_arrow("arrow_mese",{
	description = S("Mese arrow"),
	texture = "bows_arrow_wood.png^[colorize:#e3ff00cc",
	damage = 7,
	craft_count = 4,
	drop_chance = 8,
	craft = {
		{"default:mese_crystal", "group:stick", feather}
	},
	on_hit_sound = "bows_arrow_hit",
	on_hit_node = function(self, pos, user, arrow_pos)

		if self.node.name == "mesecons_switch:mesecon_switch_on"
		or self.node.name == "mesecons_switch:mesecon_switch_off" then

			local def = minetest.registered_nodes[self.node.name]

			-- This toggles the mesecons switch on/off
			if def and def.on_rightclick then
				def.on_rightclick(vector.round(pos), self.node, user)
			end
		end
	end
})

-- diamond arrow (breaks glass node when hit)

bows.register_arrow("arrow_diamond",{
	description = S("Diamond arrow"),
	texture = "bows_arrow_wood.png^[colorize:#15d7c2cc",
	damage = 8,
	craft_count = 4,
	drop_chance = 7,
	craft = {
		{"default:diamond", "group:stick", feather}
	},
	on_hit_sound = "bows_arrow_hit",
	on_hit_node = function(self, pos, user, arrow_pos)
		if self.node.name == "default:glass"
		and not minetest.is_protected(pos, user:get_player_name()) then
			minetest.sound_play("default_break_glass", {
				pos = pos, gain = 1.0, max_hear_distance = 10}, true)
			minetest.remove_node(pos)
			minetest.add_item(pos, "vessels:glass_fragments")
		end
	end
})
