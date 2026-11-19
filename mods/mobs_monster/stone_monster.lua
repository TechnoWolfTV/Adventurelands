
-- translation and custom stone monster types

local S = core.get_translator("mobs_monster")

local stone_types = {

	{	nodes = {"default:desert_stone"},
		skins = {"mobs_stone_monster3.png"},
		drops = {
			{name = "default:desert_cobble", chance = 1, min = 0, max = 2},
			{name = "default:iron_lump", chance = 5, min = 0, max = 2},
			{name = "default:gold_lump", chance = 5, min = 0, max = 2}
		}
	},

	{	nodes = {"default:sandstone"},
		skins = {"mobs_stone_monster4.png"},
		drops = {
			{name = "default:sandstone", chance = 1, min = 0, max = 2},
			{name = "default:tin_lump", chance = 5, min = 0, max = 2},
			{name = "default:copper_lump", chance = 5, min = 0, max = 2}
		}
	}
}

-- Stone Monster by PilzAdam

mobs:register_mob("mobs_monster:stone_monster", {

	-- basic settings
	description = S("Stone Monster"),
	stepheight = 1.1,
	type = "monster",
	passive = false,
	hp_min = 12,
	hp_max = 35,
	armor = 80,
	reach = 2,

	-- attacks
	attack_type = "dogfight",
	damage = 3,
	view_range = 10,

	-- model and textures
	collisionbox = {-0.3, -1, -0.3, 0.3, 0.7, 0.3},
	visual = "mesh",
	mesh = "mobs_stone_monster.b3d",
	textures = {
		{"mobs_stone_monster.png"},
		{"mobs_stone_monster2.png"} -- by AMMOnym
	},

	-- sounds
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_stonemonster"
	},

	-- movement
	walk_velocity = 1,
	run_velocity = 2,
	jump_height = 0,
	floats = false,

	-- item drops
	drops = {
		{name = "default:cobble", chance = 1, min = 0, max = 2},
		{name = "default:gravel", chance = 1, min = 0, max = 2},
		{name = "default:coal_lump", chance = 3, min = 0, max = 2},
		{name = "default:iron_lump", chance = 5, min = 0, max = 2}
	},

	-- damage
	water_damage = 0,
	lava_damage = 1,
	light_damage = 0,
	fear_height = 5,

	-- items on list deal different damage to normal
	immune_to = {
		{"default:pick_wood", 0}, -- wooden pick doesnt hurt stone monster
		{"default:pick_stone", 4}, -- picks deal more damage to stone monster
		{"default:pick_bronze", 5},
		{"default:pick_steel", 5},
		{"default:pick_mese", 6},
		{"default:pick_diamond", 7}
	},

	-- animations
	animation = {
		speed_normal = 15, speed_run = 15,
		stand_start = 0, stand_end = 14,
		walk_start = 15, walk_end = 38,
		run_start = 40, run_end = 63, run_speed = 40,
		punch_start = 40, punch_end = 63
	},

	-- check surrounding nodes and spawn a specific stone monster
	on_spawn = function(self)

		local pos = self.object:get_pos() ; pos.y = pos.y - 1
		local tmp

		for n = 1, #stone_types do

			tmp = stone_types[n]

			if core.find_node_near(pos, 1, tmp.nodes) then

				self.base_texture = tmp.skins
				self.object:set_properties({textures = tmp.skins})

				if tmp.drops then self.drops = tmp.drops end

				break
			end
		end

		return true -- run only once, false/nil runs every activation
	end
})

-- where to spawn

if not mobs.custom_spawn_monster then

	mobs:spawn({
		name = "mobs_monster:stone_monster",
		nodes = {"default:stone", "default:desert_stone", "default:sandstone",
				"default:permafrost_with_stones"},
		max_light = 7,
		chance = 7000,
		max_height = 0
	})
end

-- spawn egg

mobs:register_egg("mobs_monster:stone_monster", S("Stone Monster"), "default_stone.png", 1)

-- compatibility with older mobs mod

mobs:alias_mob("mobs:stone_monster", "mobs_monster:stone_monster")
