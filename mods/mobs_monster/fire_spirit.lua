
-- translation and drops

local S = core.get_translator("mobs_monster")

local mob_drops = {
	{name = "fireflies:firefly", chance = 1, min = 1, max = 1}
}

if core.get_modpath("ethereal") then

	table.insert(mob_drops,
			{name = "ethereal:fire_dust", chance = 1, min = 1, max = 1})
end

-- Fire Spirit

mobs:register_mob("mobs_monster:fire_spirit", {

	-- basic settings
	description = S("Fire Spirit"),
	type = "monster",
	passive = false,
	hp_min = 25,
	hp_max = 45,
	armor = 100,
	reach = 2,

	-- attacks
	attack_type = "dogfight",
	pathfinding = true,
	damage = 4,
	view_range = 14,

	-- model and textures
	collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
	visual_scale = {x = 0.5, y = 0.5, z = 0.5},
	visual = "sprite",
	textures = {
		{"mobs_fire_spirit.png"}
	},
	glow = 14,
	blood_texture = "fire_basic_flame.png",

	-- having "all" below means nothing will harm mob apart from the entries before
	immune_to = {
		{"bucket:bucket_water", 4},
		{"bucket:bucket_river_water", 4},
		{"all"}
	},

	-- sounds
	makes_footstep_sound = false,
	sounds = {
		random = "fire_fire",
		damage = "fire_extinguish_flame",
		death = "fire_extinguish_flame"
	},

	-- movement
	walk_velocity = 2,
	run_velocity = 3,
	jump_height = 6,

	-- item drops (specified above)
	drops = mob_drops,

	-- damage
	water_damage = 4,
	lava_damage = 0,
	fire_damage = 0,
	light_damage = 0,
	fall_damage = false,
	fear_height = 8,

	-- animations
	animation = {},

	-- custom function to run on mob death
	on_die = function(self, pos)

		mobs:effect(pos, 20, "tnt_smoke.png", 3, 5, 2, 0.5, nil, false)

		self.object:remove()
	end,

	-- custom function to run with mob
	do_custom = function(self, dtime)

		self.temp.flame_timer = (self.temp.flame_timer or 0) + dtime
		if self.temp.flame_timer < 0.1 then return end
		self.temp.flame_timer = 0

		local pos = self.object:get_pos()

		-- pos, amount, texture, min_size, max_size, radius, gravity, glow, fall
		mobs:effect(pos, 5, "fire_basic_flame.png", 2, 3, 0.1, 0, 14, nil)
	end
})

-- where to spawn

if not mobs.custom_spawn_monster then

	mobs:spawn({
		name = "mobs_monster:fire_spirit",
		nodes = {"default:obsidian", "caverealms:hot_cobble"},
		neighbors = {"group:fire"},
		min_light = 12,
		max_light = 15,
		chance = 1500,
		active_object_count = 1,
		max_height = -150
	})
end

-- spawn egg

mobs:register_egg("mobs_monster:fire_spirit", S("Fire Spirit"), "fire_basic_flame.png", 1)
