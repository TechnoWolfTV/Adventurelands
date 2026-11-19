
local S = core.get_translator("mobs_monster")

-- custom dirt monster type

local dirt_types = {

	{	nodes = {"ethereal:dry_dirt"},
		skins = {"mobs_dirt_monster3.png"},
		drops = {
			{name = "ethereal:dry_dirt", chance = 1, min = 0, max = 2},
			{name = "ethereal:charcoal_lump", chance = 2, min = 0, max = 1}
		}
	}
}

-- Dirt Monster by PilzAdam

mobs:register_mob("mobs_monster:dirt_monster", {

	-- basic settings
	description = S("Dirt Monster"),
	type = "monster",
	passive = false,
	hp_min = 3,
	hp_max = 27,
	armor = 100,
	reach = 2,

	-- attacks
	attack_type = "dogfight",
	pathfinding = true,
	damage = 2,
	view_range = 15,

	-- model and textures
	collisionbox = {-0.3, -1, -0.3, 0.3, 0.7, 0.3},
	visual = "mesh",
	mesh = "mobs_stone_monster.b3d",
	textures = {
		{"mobs_dirt_monster.png"},
		{"mobs_dirt_monster2.png"}
	},
	blood_texture = "default_dirt.png",

	-- sounds
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_dirtmonster"
	},

	-- movement
	walk_velocity = 1,
	run_velocity = 3,

	-- item drops
	drops = {
		{name = "default:dirt", chance = 1, min = 0, max = 2},
		{name = "default:clay_lump", chance = 2, min = 0, max = 1}
	},

	-- damage
	water_damage = 1,
	lava_damage = 5,
	light_damage = 3,
	fear_height = 4,

	-- animations
	animation = {
		speed_normal = 15, speed_run = 15,
		stand_start = 0, stand_end = 14,
		walk_start = 15, walk_end = 38,
		run_start = 40, run_end = 63, run_speed = 45,
		punch_start = 40, punch_end = 63
	},

	-- check spawn position for specific nodes and select mob texture
	on_spawn = function(self)

		local pos = self.object:get_pos() ; pos.y = pos.y - 1
		local tmp

		for n = 1, #dirt_types do

			tmp = dirt_types[n]

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
		name = "mobs_monster:dirt_monster",
		nodes = {"default:dirt_with_grass", "ethereal:gray_dirt", "ethereal:dry_dirt"},
		min_light = 0,
		max_light = 7,
		chance = 6000,
		active_object_count = 2,
		min_height = 0,
		day_toggle = false
	})
end

-- spawn egg

mobs:register_egg("mobs_monster:dirt_monster", S("Dirt Monster"), "default_dirt.png", 1)

-- compatibility with older mobs mod

mobs:alias_mob("mobs:dirt_monster", "mobs_monster:dirt_monster")
