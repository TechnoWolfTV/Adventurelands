---------------------------------------
-- Happy Weather: Utilities / Helpers

-- License: MIT

-- Credits: xeranas
---------------------------------------

if not minetest.global_exists("hw_utils") then
	hw_utils = {}
end

local mg_name = minetest.get_mapgen_setting("mg_name")

-- outdoor check based on node light level
hw_utils.is_outdoor = function(pos, offset_y)
	if offset_y == nil then
		offset_y = 0
	end

	if minetest.get_node_light({x=pos.x, y=pos.y + offset_y, z=pos.z}, 0.5) == 15 then
		return true
	end
	return false
end

-- checks if player is undewater. This is needed in order to
-- turn off weather particles generation.
hw_utils.is_underwater = function(player)
	local ppos = player:getpos()
	local offset = player:get_eye_offset()
	local player_eye_pos = {
		x = ppos.x + offset.x, 
		y = ppos.y + offset.y + 1.5, 
		z = ppos.z + offset.z}
	local node_level = minetest.get_node_level(player_eye_pos)
	if node_level == 8 or node_level == 7 then
		return true
	end
	return false
end

-- trying to locate position for particles by player look direction for performance reason.
-- it is costly to generate many particles around player so goal is focus mainly on front view.  
hw_utils.get_random_pos = function(player, offset)
	local look_dir = player:get_look_dir()
	local player_pos = player:getpos()

	local random_pos_x = 0
	local random_pos_y = 0
	local random_pos_z = 0

	if look_dir.x > 0 then
		if look_dir.z > 0 then
			random_pos_x = math.random(player_pos.x - offset.back, player_pos.x + offset.front) + math.random()
			random_pos_z = math.random(player_pos.z - offset.back, player_pos.z + offset.front) + math.random() 
		else
			random_pos_x = math.random(player_pos.x - offset.back, player_pos.x + offset.front) + math.random()
			random_pos_z = math.random(player_pos.z - offset.front, player_pos.z + offset.back) + math.random()
		end
	else
		if look_dir.z > 0 then
			random_pos_x = math.random(player_pos.x - offset.front, player_pos.x + offset.back) + math.random()
			random_pos_z = math.random(player_pos.z - offset.back, player_pos.z + offset.front) + math.random()
		else
			random_pos_x = math.random(player_pos.x - offset.front, player_pos.x + offset.back) + math.random()
			random_pos_z = math.random(player_pos.z - offset.front, player_pos.z + offset.back) + math.random()
		end
	end

	if offset.bottom ~= nil then
		random_pos_y = math.random(player_pos.y - offset.bottom, player_pos.y + offset.top)
	else
		random_pos_y = player_pos.y + offset.top
	end

	return {x=random_pos_x, y=random_pos_y, z=random_pos_z}
end

local is_biome_frozen = function(position)
	if legacy_MT_version then
		return false;
	end
	local heat = minetest.get_heat(position)
	-- below 35 heat biome considered to be frozen type
	return heat < 35
end

hw_utils.is_biome_frozen = function(position)
	if mg_name == "v6" then
		return false -- v6 not supported.
	end
	return is_biome_frozen(position)
end

local is_biome_dry = function(position)
	if legacy_MT_version then
		return false;
	end
	local humidity = minetest.get_humidity(position)
	local heat = minetest.get_heat(position)
	return humidity < 50 and heat > 65
end

hw_utils.is_biome_dry = function(position)
	if mg_name == "v6" then
		return false
	end
	return is_biome_dry(position)
end

local is_biome_tropic = function(position)
	if legacy_MT_version then
		return false;
	end
	local humidity = minetest.get_humidity(position)
	local heat = minetest.get_heat(position)

	-- humid and temp values are taked by testing flying around world (not sure actually)
	return humidity > 55 and heat > 70
end

hw_utils.is_biome_tropic = function(position)
	if mg_name == "v6" then
		return false -- v6 not supported yet.
	end
	return is_biome_tropic(position)
end

---------------------------------------
-- Shelter detection
--
-- Casts a ray upward from the player's eye position, sampling up to
-- MAX_SHELTER_NODES nodes. Counts how many solid nodes sit between
-- the player and open sky (sky light == 15).
--
-- Returns a shelter_factor in [0.0, 1.0]:
--   0.0 = fully outdoors (open sky directly overhead)
--   1.0 = fully sheltered (deep cave / many floors of solid overhead)
--
-- The curve is tuned so that:
--   0 solid nodes  → 0.0  (outdoors)
--   1–2 solid nodes → ~0.3–0.55 (one floor / thin roof)
--   3+ solid nodes  → 0.75–1.0  (deep building / hillside / cave)
---------------------------------------

local MAX_SHELTER_NODES = 20

hw_utils.get_shelter_factor = function(player)
	local ppos = player:get_pos()
	local eye_offset = player:get_eye_offset()
	local eye_y = ppos.y + eye_offset.y + 1.5

	-- Fast path: if sky light is 15 right at eye level, fully outdoors.
	local eye_pos = {x = ppos.x, y = eye_y, z = ppos.z}
	if minetest.get_node_light(eye_pos, 0.5) == 15 then
		return 0.0
	end

	local solid_count = 0
	for i = 1, MAX_SHELTER_NODES do
		local check_pos = {x = ppos.x, y = eye_y + i, z = ppos.z}
		local light = minetest.get_node_light(check_pos, 0.5)

		-- Reached open sky
		if light == 15 then
			break
		end

		local node = minetest.get_node(check_pos)
		local def = minetest.registered_nodes[node.name]
		-- Count walkable (solid) nodes; ignore air, water, glass, etc.
		if def and def.walkable then
			solid_count = solid_count + 1
		end
	end

	-- Map solid_count to [0.0, 1.0] with a curve that rises quickly
	-- for the first few nodes then flattens toward 1.0.
	-- Formula: 1 - (1 / (1 + solid_count * 2.0))
	-- solid_count=0 → 0.0, 1 → 0.67, 2 → 0.80, 3 → 0.86, 5 → 0.91, 10 → 0.95
	if solid_count == 0 then
		return 0.0
	end
	return 1.0 - (1.0 / (1.0 + solid_count * 2.0))
end

---------------------------------------
-- Weather sound gain profiles
--
-- Each profile defines:
--   base_gain      - volume at 0.0 shelter (fully outdoors)
--   indoor_gain    - volume at ~0.5 shelter (one floor indoors)
--   cave_gain      - volume at 1.0 shelter (deep cave / full shelter)
--
-- Intermediate shelter values are linearly interpolated between
-- these three anchor points.
---------------------------------------

local SOUND_PROFILES = {
	light_rain  = { base_gain = 1.0,  indoor_gain = 0.13, cave_gain = 0.0  },
	rain        = { base_gain = 0.7,  indoor_gain = 0.15, cave_gain = 0.0  },
	heavy_rain  = { base_gain = 1.0,  indoor_gain = 0.35, cave_gain = 0.0  },
	snowstorm   = { base_gain = 0.6,  indoor_gain = 0.08, cave_gain = 0.0  },
	thunder     = { base_gain = 1.0,  indoor_gain = 0.6,  cave_gain = 0.15 },
	rumble      = { base_gain = 0.51, indoor_gain = 0.31, cave_gain = 0.08 },
}

-- Interpolate gain from a profile given a shelter_factor in [0.0, 1.0].
-- Uses two linear segments: [0, 0.5] maps outdoor→indoor, [0.5, 1.0] maps indoor→cave.
local interpolate_gain = function(profile, shelter_factor)
	if shelter_factor <= 0.0 then
		return profile.base_gain
	elseif shelter_factor >= 1.0 then
		return profile.cave_gain
	elseif shelter_factor <= 0.5 then
		local t = shelter_factor / 0.5  -- 0→1 across first half
		return profile.base_gain + t * (profile.indoor_gain - profile.base_gain)
	else
		local t = (shelter_factor - 0.5) / 0.5  -- 0→1 across second half
		return profile.indoor_gain + t * (profile.cave_gain - profile.indoor_gain)
	end
end

---------------------------------------
-- Per-player sound update state
-- Tracks the last recalculation time per player per weather code,
-- and the last shelter factor to avoid unnecessary fade calls.
---------------------------------------

local sound_update_timers = {}  -- [player_name][weather_code] = time_since_last_update
local sound_last_shelter  = {}  -- [player_name][weather_code] = last shelter_factor

local SOUND_UPDATE_INTERVAL = 1.0   -- recalculate shelter every N seconds
local SHELTER_CHANGE_THRESHOLD = 0.05  -- only fade if shelter changed by this much
local FADE_STEP_TIME = 0.5          -- minetest.sound_fade step parameter

-- Call this from each weather's render() function.
-- handle     : the sound handle returned by minetest.sound_play
-- weather_code: string key into SOUND_PROFILES (e.g. "heavy_rain", "thunder")
-- dtime      : dtime from render()
-- player     : the player object
--
-- Returns the handle unchanged (sound_fade doesn't invalidate it).
hw_utils.update_weather_sound = function(handle, weather_code, dtime, player)
	if not handle then return handle end

	local profile = SOUND_PROFILES[weather_code]
	if not profile then return handle end

	local pname = player:get_player_name()

	-- Initialise per-player tables on first call
	if not sound_update_timers[pname] then
		sound_update_timers[pname] = {}
	end
	if not sound_last_shelter[pname] then
		sound_last_shelter[pname] = {}
	end

	-- Accumulate dtime; only recalculate on interval
	sound_update_timers[pname][weather_code] =
		(sound_update_timers[pname][weather_code] or SOUND_UPDATE_INTERVAL) + dtime

	if sound_update_timers[pname][weather_code] < SOUND_UPDATE_INTERVAL then
		return handle
	end
	sound_update_timers[pname][weather_code] = 0

	-- Calculate current shelter and target gain
	local shelter = hw_utils.get_shelter_factor(player)
	local last_shelter = sound_last_shelter[pname][weather_code]

	-- Skip fade if shelter hasn't changed meaningfully
	if last_shelter and math.abs(shelter - last_shelter) < SHELTER_CHANGE_THRESHOLD then
		return handle
	end

	sound_last_shelter[pname][weather_code] = shelter
	local target_gain = interpolate_gain(profile, shelter)

	minetest.sound_fade(handle, FADE_STEP_TIME, target_gain)
	return handle
end

-- Call this when a player leaves a weather (remove_player) or disconnects,
-- to clean up the timer state for that player/weather combination.
hw_utils.clear_sound_state = function(player_name, weather_code)
	if sound_update_timers[player_name] then
		sound_update_timers[player_name][weather_code] = nil
	end
	if sound_last_shelter[player_name] then
		sound_last_shelter[player_name][weather_code] = nil
	end
end

-- Clean up all state when a player disconnects entirely.
minetest.register_on_leaveplayer(function(player)
	local pname = player:get_player_name()
	sound_update_timers[pname] = nil
	sound_last_shelter[pname] = nil
end)

----------------------------------------------------------------
-- Severe storm active flag
--
-- Set by severe_thunderstorm.lua and pds_severe_thunderstorm.lua
-- when they start/stop. Used to suppress competing rain/fog/thunder
-- weather from starting (or restarting mid-storm) while a severe
-- storm is in progress. Snow/snowstorm are intentionally excluded
-- since severe storms are biome-restricted away from frozen areas
-- and there's no overlap scenario to guard against.
----------------------------------------------------------------
local severe_storm_active = false

hw_utils.set_severe_storm_active = function(active)
	severe_storm_active = active
end

hw_utils.is_severe_storm_active = function()
	return severe_storm_active
end
