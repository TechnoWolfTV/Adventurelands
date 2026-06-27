----------------------------------------------------------------
-- Happy Weather: Severe Storm
--
-- A multi-phase severe storm with dramatic sky darkening,
-- building rain, and escalating thunder/lightning.
--
-- Phases:
--   1. Approach  (180s) sky darkens, distant thunder, no rain
--   2. Build     (180s) light→rain→heavy rain, thunder builds
--   3. Onslaught (3-8min) full intensity
--   4. Unwind    (180s) heavy→rain→light rain, mirrors Build
--   5. Retreat   (180s) light rain stops, sky lightens, mirrors Approach
--
-- License: MIT
-- Credits: TechnoWolfTV / xeranas
----------------------------------------------------------------

local severe_storm = {}
severe_storm.code = "severe_storm"
severe_storm.last_check = 0
severe_storm.check_interval = 400

-- Roughly one fifth the chance of heavy rain
severe_storm.chance = 0.003

local SKYCOLOR_LAYER = "happy_weather_severe_storm_sky"

local manual_trigger_start = false
local manual_trigger_end = false

----------------------------------------------------------------
-- Per-player sound tracking
-- We track both the handle AND which sound file is playing
-- so we can restart with the correct file on rain type change.
----------------------------------------------------------------
local sound_handles = {}   -- [pname] = handle
local sound_files   = {}   -- [pname] = "light_rain_drop"|"rain_drop"|"heavy_rain_drop"

----------------------------------------------------------------
-- Phase state machine
----------------------------------------------------------------
local phase = 0
local phase_start_time = 0
local onslaught_duration = 0

local APPROACH_DURATION    = 180
local BUILD_DURATION       = 180
local DISSIPATION_DURATION = 90   -- kept for reference, phases 4+5 are 180 each
local UNWIND_DURATION      = 180
local RETREAT_DURATION     = 180

-- Thunder delay ranges per phase
local PHASE_THUNDER = {
	[1] = { min_delay = 35, max_delay = 65 },  -- distant, infrequent
	[2] = { min_delay = 15, max_delay = 30 },  -- building
	[3] = { min_delay =  2, max_delay =  7 },  -- frequent, close
	[4] = { min_delay = 15, max_delay = 30 },  -- mirrors phase 2
	[5] = { min_delay = 35, max_delay = 65 },  -- mirrors phase 1
}

local next_strike_time = 0

----------------------------------------------------------------
-- Sky / intensity helpers
----------------------------------------------------------------

local SKY_NORMAL_COLORS = {
	{r=15,  g=15,  b=20  },  -- midnight
	{r=60,  g=75,  b=100 },  -- dawn
	{r=80,  g=100, b=130 },  -- midday
	{r=60,  g=75,  b=100 },  -- dusk
	{r=15,  g=15,  b=20  },  -- midnight
}

local SKY_STORM_COLORS = {
	{r=5,  g=5,  b=8  },
	{r=18, g=20, b=28 },
	{r=22, g=25, b=32 },
	{r=18, g=20, b=28 },
	{r=5,  g=5,  b=8  },
}

local CLOUD_NORMAL = {r=220, g=220, b=225}
local CLOUD_STORM  = {r=18,  g=18,  b=22 }

local function lerp_color(a, b, t)
	return {
		r = math.floor(a.r + (b.r - a.r) * t),
		g = math.floor(a.g + (b.g - a.g) * t),
		b = math.floor(a.b + (b.b - a.b) * t)
	}
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

-- Returns storm intensity 0.0 (normal) → 1.0 (full onslaught)
-- Phases 1-2 ramp up, phase 3 holds at 1.0, phases 4-5 ramp down
local function get_storm_intensity()
	if phase == 0 then return 0.0 end
	local elapsed = os.time() - phase_start_time

	if phase == 1 then
		-- 0.0 → 0.5
		return math.min(elapsed / APPROACH_DURATION, 1.0) * 0.5
	elseif phase == 2 then
		-- 0.5 → 1.0
		return 0.5 + math.min(elapsed / BUILD_DURATION, 1.0) * 0.5
	elseif phase == 3 then
		return 1.0
	elseif phase == 4 then
		-- 1.0 → 0.5 (mirrors phase 2)
		return 1.0 - math.min(elapsed / UNWIND_DURATION, 1.0) * 0.5
	elseif phase == 5 then
		-- 0.5 → 0.0 (mirrors phase 1)
		return 0.5 - math.min(elapsed / RETREAT_DURATION, 1.0) * 0.5
	end
	return 0.0
end

----------------------------------------------------------------
-- Sky and lighting update (throttled to every 2s)
----------------------------------------------------------------
local sky_update_timer = {}
local SKY_UPDATE_INTERVAL = 2.0

local function update_sky(player_name, intensity)
	local player = minetest.get_player_by_name(player_name)
	if not player then return end

	local cloud_intensity = math.min(intensity * 1.4, 1.0)

	-- Interpolate sky gradient
	local faded = {}
	for i = 1, 5 do
		faded[i] = lerp_color(SKY_NORMAL_COLORS[i], SKY_STORM_COLORS[i], intensity)
	end

	local sl = {}
	sl.name = SKYCOLOR_LAYER
	sl.sky_data = { gradient_colors = faded }

	local cc  = lerp_color(CLOUD_NORMAL, CLOUD_STORM, cloud_intensity)
	local cc2 = { r = math.max(0, cc.r-15), g = math.max(0, cc.g-15), b = math.max(0, cc.b-15) }
	sl.clouds_data = {
		gradient_colors = { cc2, cc, cc2, cc, cc2 },
		density = lerp(0.4, 1.0, cloud_intensity),
		speed   = { x = 0, z = lerp(2, 25, intensity) }
	}
	skylayer.add_layer(player_name, sl)

	-- Dim outdoor lighting proportionally
	local current_ratio = minetest.time_to_day_night_ratio(minetest.get_timeofday())
	local target_ratio  = lerp(current_ratio, 0.35, intensity)
	player:override_day_night_ratio(target_ratio)
end

----------------------------------------------------------------
-- Rain type helpers
-- Returns "light_rain_drop", "rain_drop", or "heavy_rain_drop"
-- and matching profile name for update_weather_sound
----------------------------------------------------------------

-- Given a 0.0-1.0 build progress, return which rain type we're in
-- Used for both build (phase 2) and unwind (phase 4, reversed)
local function rain_type_for_progress(t)
	if t < 0.33 then
		return "light_rain_drop", "light_rain"
	elseif t < 0.66 then
		return "rain_drop", "rain"
	else
		return "heavy_rain_drop", "heavy_rain"
	end
end

local function rain_particles_for_progress(t)
	if t < 0.33 then
		return 2,  math.random(1,4), "happy_weather_light_rain_raindrop_" .. math.random(1,4) .. ".png"
	elseif t < 0.66 then
		return 5,  math.random(1,4), "happy_weather_light_rain_raindrop_" .. math.random(1,4) .. ".png"
	else
		return 8,  30,              "happy_weather_heavy_rain_drops.png"
	end
end

----------------------------------------------------------------
-- Sound management
-- Tracks which file is currently playing and restarts if type changes
----------------------------------------------------------------
local function ensure_rain_sound(player, wanted_file, sound_profile)
	local pname = player:get_player_name()
	if sound_files[pname] == wanted_file and sound_handles[pname] then
		return  -- already playing the right file
	end
	-- Stop existing sound and clear all rain shelter state
	if sound_handles[pname] then
		minetest.sound_stop(sound_handles[pname])
		sound_handles[pname] = nil
	end
	hw_utils.clear_sound_state(pname, "light_rain")
	hw_utils.clear_sound_state(pname, "rain")
	hw_utils.clear_sound_state(pname, "heavy_rain")
	-- Start new sound at zero gain — shelter system fades it in immediately
	sound_handles[pname] = minetest.sound_play(wanted_file, {
		object = player,
		max_hear_distance = 2,
		loop = true,
		gain = 0.0,
	})
	sound_files[pname] = wanted_file
end

local function stop_rain_sound(player)
	local pname = player:get_player_name()
	if sound_handles[pname] then
		minetest.sound_stop(sound_handles[pname])
		sound_handles[pname] = nil
		sound_files[pname] = nil
		hw_utils.clear_sound_state(pname, "light_rain")
		hw_utils.clear_sound_state(pname, "rain")
		hw_utils.clear_sound_state(pname, "heavy_rain")
	end
end

----------------------------------------------------------------
-- Lightning
----------------------------------------------------------------
local function can_perceive_strike()
	for _, player in ipairs(minetest.get_connected_players()) do
		if hw_utils.get_shelter_factor(player) < 0.95 then
			return true
		end
	end
	return false
end

local function do_strike()
	if can_perceive_strike() then
		lightning.strike()
	end
end

local function schedule_next_strike()
	local td = PHASE_THUNDER[phase]
	if not td then return end
	local delay = td.min_delay + math.random() * (td.max_delay - td.min_delay)
	next_strike_time = os.time() + delay
end

----------------------------------------------------------------
-- Phase transitions
----------------------------------------------------------------
local function advance_phase()
	phase = phase + 1
	phase_start_time = os.time()
	if phase == 3 then
		onslaught_duration = 180 + math.random(0, 300)
	end
	if PHASE_THUNDER[phase] then
		schedule_next_strike()
	end
end

local function start_storm()
	phase = 1
	phase_start_time = os.time()
	onslaught_duration = 0
	next_strike_time = os.time() + 20  -- first distant rumble after 20s

	minetest.chat_send_all(minetest.colorize("#FF0000", "*** SEVERE THUNDERSTORM WARNING! ***"))

	local weathers_to_end = {
		"light_rain", "rain", "heavy_rain", "thunder",
		"snow", "snowstorm", "light_fog", "moderate_fog", "heavy_fog"
	}
	for _, code in ipairs(weathers_to_end) do
		happy_weather.request_to_end(code)
	end
end

local function stop_storm()
	-- Jump to unwind rather than cutting off
	if phase > 0 and phase < 4 then
		phase = 4
		phase_start_time = os.time()
		schedule_next_strike()
	end
end

----------------------------------------------------------------
-- Happy Weather lifecycle
----------------------------------------------------------------
severe_storm.is_starting = function(dtime, position)
	if severe_storm.last_check + severe_storm.check_interval < os.time() then
		severe_storm.last_check = os.time()
		if phase > 0 then return false end
		if math.random() < severe_storm.chance then
			return true
		end
	end
	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end
	return false
end

local manual_stopped = false  -- true when stopped via command rather than natural end

severe_storm.is_ending = function(dtime)
	-- End only after phase 5 completes naturally
	if phase == 5 then
		local elapsed = os.time() - phase_start_time
		if elapsed >= RETREAT_DURATION then
			phase = 0
			manual_stopped = false
			return true
		end
	end

	if manual_trigger_end then
		manual_trigger_end = false
		manual_stopped = true
		phase = 0
		return true
	end

	return false
end

severe_storm.in_area = function(position)
	return position.y > -10 and position.y < 200
end

severe_storm.add_player = function(player)
	start_storm()
end

severe_storm.remove_player = function(player)
	local pname = player:get_player_name()
	stop_rain_sound(player)

	-- Reset clouds to default before removing layer so they
	-- don't stay dark and fast after the storm ends
	local sl = {}
	sl.name = SKYCOLOR_LAYER
	sl.clouds_data = {
		gradient_colors = {
			{r=220, g=220, b=225},
			{r=220, g=220, b=225},
			{r=220, g=220, b=225},
			{r=220, g=220, b=225},
			{r=220, g=220, b=225},
		},
		density = 0.4,
		speed = { x = 0, z = 2 }
	}
	skylayer.add_layer(pname, sl)
	skylayer.remove_layer(pname, SKYCOLOR_LAYER)

	-- Explicitly restore engine default sky in case skylayer
	-- doesn't fully revert the gradient on its own
	player:set_sky({
		type = "regular",
		clouds = true,
	})

	-- Reset day/night ratio to normal
	player:override_day_night_ratio(nil)

	-- Only hand off to light rain on natural completion, not manual stop
	if phase == 0 and not manual_stopped then
		happy_weather.request_to_start("light_rain")
	end
	manual_stopped = false
end

----------------------------------------------------------------
-- Render
----------------------------------------------------------------
local render_timer = {}

severe_storm.render = function(dtime, player)
	local pname = player:get_player_name()
	local now = os.time()

	-- Phase advancement
	local elapsed = now - phase_start_time
	if phase == 1 and elapsed >= APPROACH_DURATION then
		advance_phase()
	elseif phase == 2 and elapsed >= BUILD_DURATION then
		advance_phase()
	elseif phase == 3 and elapsed >= onslaught_duration then
		advance_phase()
	elseif phase == 4 and elapsed >= UNWIND_DURATION then
		advance_phase()
	elseif phase == 5 and elapsed >= RETREAT_DURATION then
		-- phase ending handled in is_ending
	end

	local intensity = get_storm_intensity()

	-- Sky + lighting (throttled)
	render_timer[pname] = (render_timer[pname] or SKY_UPDATE_INTERVAL) + dtime
	if render_timer[pname] >= SKY_UPDATE_INTERVAL then
		render_timer[pname] = 0
		update_sky(pname, intensity)
	end

	-- Rain sound and particles
	if phase == 1 or phase == 5 then
		-- No rain in approach or retreat — stop if somehow playing
		if sound_handles[pname] then
			stop_rain_sound(player)
		end

	elseif phase == 2 then
		-- Build: light → rain → heavy
		local build_t = math.min(elapsed / BUILD_DURATION, 1.0)
		local wanted_file, sound_profile = rain_type_for_progress(build_t)
		ensure_rain_sound(player, wanted_file, sound_profile)
		sound_handles[pname] = hw_utils.update_weather_sound(
			sound_handles[pname], sound_profile, dtime, player)

		-- Particles
		local shelter = hw_utils.get_shelter_factor(player)
		if shelter < 0.6 then
			local count, size, texture = rain_particles_for_progress(build_t)
			for i = 1, count do
				local rpos = hw_utils.get_random_pos(player, {front=10, back=5, top=8})
				if hw_utils.is_outdoor(rpos) then
					minetest.add_particle({
						pos = rpos,
						velocity = {x=0, y=-12, z=0},
						acceleration = {x=0, y=-18, z=0},
						expirationtime = 4,
						size = size,
						collisiondetection = true,
						collision_removal = true,
						vertical = true,
						texture = texture,
						playername = pname
					})
				end
			end
		end

	elseif phase == 3 then
		-- Onslaught: full heavy rain
		ensure_rain_sound(player, "heavy_rain_drop", "heavy_rain")
		sound_handles[pname] = hw_utils.update_weather_sound(
			sound_handles[pname], "heavy_rain", dtime, player)

		local shelter = hw_utils.get_shelter_factor(player)
		if shelter < 0.6 then
			for i = 1, 10 do
				local rpos = hw_utils.get_random_pos(player, {front=10, back=5, top=8})
				if hw_utils.is_outdoor(rpos) then
					minetest.add_particle({
						pos = rpos,
						velocity = {x=0, y=-12, z=0},
						acceleration = {x=0, y=-18, z=0},
						expirationtime = 4,
						size = 30,
						collisiondetection = true,
						collision_removal = true,
						vertical = true,
						texture = "happy_weather_heavy_rain_drops.png",
						playername = pname
					})
				end
			end
		end

	elseif phase == 4 then
		-- Unwind: mirrors Build in reverse
		-- elapsed 0→UNWIND means progress 1.0→0.0
		local unwind_t = math.min(elapsed / UNWIND_DURATION, 1.0)
		local reversed_t = 1.0 - unwind_t  -- treat as if counting down build progress
		local wanted_file, sound_profile = rain_type_for_progress(reversed_t)
		ensure_rain_sound(player, wanted_file, sound_profile)
		sound_handles[pname] = hw_utils.update_weather_sound(
			sound_handles[pname], sound_profile, dtime, player)

		local shelter = hw_utils.get_shelter_factor(player)
		if shelter < 0.6 then
			local count, size, texture = rain_particles_for_progress(reversed_t)
			for i = 1, count do
				local rpos = hw_utils.get_random_pos(player, {front=10, back=5, top=8})
				if hw_utils.is_outdoor(rpos) then
					minetest.add_particle({
						pos = rpos,
						velocity = {x=0, y=-12, z=0},
						acceleration = {x=0, y=-18, z=0},
						expirationtime = 4,
						size = size,
						collisiondetection = true,
						collision_removal = true,
						vertical = true,
						texture = texture,
						playername = pname
					})
				end
			end
		end
	end

	-- Lightning in all active phases
	if phase >= 1 and phase <= 5 and now >= next_strike_time then
		if PHASE_THUNDER[phase] then
			do_strike()
			schedule_next_strike()
		end
	end
end

severe_storm.start = function()
	manual_trigger_start = true
end

severe_storm.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(severe_storm)
