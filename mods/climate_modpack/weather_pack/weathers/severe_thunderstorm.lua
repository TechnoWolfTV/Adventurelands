----------------------------------------------------------------
-- Happy Weather: Severe Thunderstorm
--
-- The "lesser" tier of severe weather — bad, but not utterly
-- terrifying like PDS Severe Thunderstorm. No green sky, no
-- rumble sound, lighter darkness, less frequent strikes during
-- onslaught, and shorter phase durations.
--
-- Phases:
--   1. Approach  (90s)  sky darkens, distant thunder, no rain
--   2. Build     (90s)  light→rain→heavy rain, thunder builds
--   3. Onslaught (3-5min) full intensity (reduced from PDS)
--   4. Unwind    (90s)  heavy→rain→light rain, mirrors Build
--   5. Retreat   (90s)  light rain stops, sky lightens, mirrors Approach
--
-- License: MIT
-- Credits: TechnoWolfTV / xeranas
----------------------------------------------------------------

local severe_thunderstorm = {}
severe_thunderstorm.code = "severe_thunderstorm"
severe_thunderstorm.last_check = 0
severe_thunderstorm.check_interval = 400

-- Averages ~22 in-game days — twice as rare as heavy_rain
severe_thunderstorm.chance = 0.015

local SKYCOLOR_LAYER = "happy_weather_severe_thunderstorm_sky"

local manual_trigger_start = false
local manual_trigger_end = false

----------------------------------------------------------------
-- Per-player sound tracking
-- We track both the handle AND which sound file is playing
-- so we can restart with the correct file on rain type change.
----------------------------------------------------------------
local sound_handles = {}   -- [pname] = handle
local sound_files   = {}   -- [pname] = "light_rain_drop"|"rain_drop"|"heavy_rain_drop"

-- NOTE: No rumble sound for severe_thunderstorm — that's a PDS-only feature.

----------------------------------------------------------------
-- Phase state machine
----------------------------------------------------------------
local phase = 0
local phase_start_time = 0
local onslaught_duration = 0

local APPROACH_DURATION    = 90
local BUILD_DURATION       = 90
local DISSIPATION_DURATION = 45   -- kept for reference, phases 4+5 are 90 each
local UNWIND_DURATION      = 90
local RETREAT_DURATION     = 90

-- Thunder delay ranges per phase.
-- Phase 3 (onslaught) frequency reduced ~33% vs PDS (delays increased ~33%)
local PHASE_THUNDER = {
	[1] = { min_delay = 35, max_delay = 65 },  -- distant, infrequent
	[2] = { min_delay = 15, max_delay = 30 },  -- building
	[3] = { min_delay =  3, max_delay =  9 },  -- reduced ~33% from PDS (2-7s)
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

-- Storm colors reduced ~33% darkness from PDS (lighter, less terrifying)
local SKY_STORM_COLORS = {
	{r=8,  g=8,  b=12 },
	{r=32, g=38, b=52 },
	{r=41, g=50, b=64 },
	{r=32, g=38, b=52 },
	{r=8,  g=8,  b=12 },
}

local CLOUD_NORMAL = {r=112, g=110, b=119}  -- matches heavy_rain cloud color at onset
local CLOUD_STORM  = {r=65,  g=64,  b=70 }  -- reduced ~33% from PDS, then a further 25%

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
-- Drives cloud density, cloud speed, rain particles, rumble.
local function get_storm_intensity()
	if phase == 0 then return 0.0 end
	local elapsed = os.time() - phase_start_time

	if phase == 1 then
		return math.min(elapsed / APPROACH_DURATION, 1.0) * 0.5
	elseif phase == 2 then
		return 0.5 + math.min(elapsed / BUILD_DURATION, 1.0) * 0.5
	elseif phase == 3 then
		return 1.0
	elseif phase == 4 then
		return 1.0 - math.min(elapsed / UNWIND_DURATION, 1.0) * 0.5
	elseif phase == 5 then
		return 0.5 - math.min(elapsed / RETREAT_DURATION, 1.0) * 0.5
	end
	return 0.0
end

-- Returns sky darkening intensity 0.0 (normal) → 1.0 (full onslaught)
-- Drives sky gradient and day/night ratio ONLY.
-- Darkening begins immediately at the start of phase 1 and ramps
-- continuously through phase 2, reaching full target right at the
-- start of phase 3 (onslaught). Mirrors in reverse for phase 4/5.
local function get_sky_intensity()
	if phase == 0 then return 0.0 end

	if phase == 1 then
		local elapsed = os.time() - phase_start_time
		-- 0.0 → 0.5 over the full APPROACH_DURATION
		return math.min(elapsed / APPROACH_DURATION, 1.0) * 0.5

	elseif phase == 2 then
		local elapsed = os.time() - phase_start_time
		-- 0.5 → 1.0 over the full BUILD_DURATION
		return 0.5 + math.min(elapsed / BUILD_DURATION, 1.0) * 0.5

	elseif phase == 3 then
		return 1.0

	elseif phase == 4 then
		local elapsed = os.time() - phase_start_time
		-- 1.0 → 0.5 over the full UNWIND_DURATION
		return 1.0 - math.min(elapsed / UNWIND_DURATION, 1.0) * 0.5

	elseif phase == 5 then
		local elapsed = os.time() - phase_start_time
		-- 0.5 → 0.0 over the full RETREAT_DURATION
		return 0.5 - math.min(elapsed / RETREAT_DURATION, 1.0) * 0.5
	end
	return 0.0
end

-- Returns green tint intensity 0.0 (none) → 1.0 (full ominous green)
-- Timeline:
-- NOTE: severe_thunderstorm has NO green sky — that's a PDS-only feature.
-- This always returns 0.0 so apply_green() becomes a no-op everywhere,
-- keeping the surrounding sky logic identical to PDS without duplicating it.
local function get_green_intensity()
	return 0.0
end

-- Green tint color to blend into sky — unused since get_green_intensity
-- always returns 0.0 for severe_thunderstorm, but kept for structural parity.
local GREEN_TINT = {r = 35, g = 55, b = 0}

-- Blend green tint into a sky color by intensity
local function apply_green(color, green_t)
	if green_t <= 0.0 then return color end
	return {
		r = math.min(255, math.floor(color.r + GREEN_TINT.r * green_t)),
		g = math.min(255, math.floor(color.g + GREEN_TINT.g * green_t)),
		b = math.max(0,   math.floor(color.b - 10 * green_t)),  -- slight blue reduction adds to sickly feel
	}
end

-- Track last sent sky values to avoid unnecessary re-adds (prevents flash)
local last_sky_intensity = {}
local last_sky_green = {}
local SKY_CHANGE_THRESHOLD = 0.02  -- only update if intensity changed by this much
local SKY_UPDATE_INTERVAL  = 2.0   -- seconds between sky recalculations

local function update_sky(player_name, storm_intensity, sky_intensity)
	local player = minetest.get_player_by_name(player_name)
	if not player then return end

	local green_t = get_green_intensity()

	-- Skip update if values haven't changed meaningfully — prevents flash on re-add
	-- Exception: during onslaught (phase 3) force refresh every update cycle
	-- to prevent skylayer losing state and showing engine default sky
	local last_i = last_sky_intensity[player_name] or -1
	local last_g = last_sky_green[player_name] or -1
	if phase ~= 3 and
	   math.abs(sky_intensity - last_i) < SKY_CHANGE_THRESHOLD and
	   math.abs(green_t - last_g) < SKY_CHANGE_THRESHOLD then
		-- Still update lighting ratio even if sky hasn't changed
		local current_ratio = minetest.time_to_day_night_ratio(minetest.get_timeofday())
		local target_ratio  = lerp(current_ratio, 0.652, sky_intensity)  -- reduced ~33% from PDS, then a further 20%
		player:override_day_night_ratio(target_ratio)
		return
	end
	last_sky_intensity[player_name] = sky_intensity
	last_sky_green[player_name] = green_t

	local cloud_intensity = math.min(storm_intensity * 1.4, 1.0)

	-- Cloud COLOR darkens on its own slower S-curve so clouds stay
	-- ominously dark-grey (not black) during the green phase, then
	-- accelerate to full black as heavy rain arrives.
	-- storm_intensity: 0→0.5 = phase 1, 0.5→1.0 = phase 2, 1.0 = phase 3+
	local cloud_color_intensity
	if storm_intensity <= 0.5 then
		-- Phase 1: slow creep to 0.35
		local t = storm_intensity / 0.5
		cloud_color_intensity = t * 0.35
	elseif storm_intensity <= 0.667 then
		-- Phase 2 light rain: 0.35 → 0.5
		local t = (storm_intensity - 0.5) / 0.167
		cloud_color_intensity = lerp(0.35, 0.5, t)
	elseif storm_intensity <= 0.833 then
		-- Phase 2 regular rain: 0.5 → 0.8
		local t = (storm_intensity - 0.667) / 0.166
		cloud_color_intensity = lerp(0.5, 0.8, t)
	else
		-- Phase 2 heavy rain → onslaught: 0.8 → 1.0
		local t = (storm_intensity - 0.833) / 0.167
		cloud_color_intensity = lerp(0.8, 1.0, t)
	end

	-- Cloud density on a custom slow curve driven by storm_intensity.
	-- Ceiling reduced ~33% from PDS (max 0.67 instead of 1.0) so the sky
	-- never fully closes over during onslaught.
	-- Continuous ramp from normal density (0.4) at phase 1 start to the
	-- 0.67 ceiling at phase 3 start — no flat plateau, no sudden jump.
	local cloud_density = lerp(0.4, 0.67, storm_intensity)

	-- Sky gradient uses sky_intensity (delayed start, no green brightening issue)
	local faded = {}
	for i = 1, 5 do
		local base = lerp_color(SKY_NORMAL_COLORS[i], SKY_STORM_COLORS[i], sky_intensity)
		faded[i] = apply_green(base, green_t)
	end

	local sl = {}
	sl.name = SKYCOLOR_LAYER
	sl.sky_data = { gradient_colors = faded }

	-- Cloud color uses cloud_color_intensity (slower darkening curve)
	local cc  = lerp_color(CLOUD_NORMAL, CLOUD_STORM, cloud_color_intensity)
	cc = apply_green(cc, green_t * 0.7)
	local cc2 = { r = math.max(0, cc.r-15), g = math.max(0, cc.g-15), b = math.max(0, cc.b-15) }
	sl.clouds_data = {
		gradient_colors = { cc2, cc, cc2, cc, cc2 },
		density = cloud_density,
		speed   = { x = 0, z = lerp(2, 25, storm_intensity) }
	}
	skylayer.add_layer(player_name, sl)

	-- Dim outdoor lighting using sky_intensity (delayed, matches sky darkening)
	local current_ratio = minetest.time_to_day_night_ratio(minetest.get_timeofday())
	local target_ratio  = lerp(current_ratio, 0.652, sky_intensity)  -- reduced ~33% from PDS, then a further 20%
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

-- NOTE: start_rumble / stop_rumble / kill_rumble intentionally omitted —
-- severe_thunderstorm has no rumble sound (PDS-only feature).

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
		onslaught_duration = 180 + math.random(0, 120)  -- 3-5 min (reduced from PDS 3-8 min)
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
	hw_utils.set_severe_storm_active(true)

	local weathers_to_end = {
		"light_rain", "rain", "heavy_rain", "thunder",
		"light_fog", "moderate_fog", "dense_fog"
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
severe_thunderstorm.is_starting = function(dtime, position)
	if severe_thunderstorm.last_check + severe_thunderstorm.check_interval < os.time() then
		severe_thunderstorm.last_check = os.time()
		if phase > 0 then return false end
		-- Don't start if the other severe storm tier is already active
		if hw_utils.is_severe_storm_active() then return false end
		if math.random() < severe_thunderstorm.chance then
			return true
		end
	end
	if manual_trigger_start then
		manual_trigger_start = false
		if phase == 0 and hw_utils.is_severe_storm_active() then
			-- Other tier is running — silently ignore manual trigger
			return false
		end
		return true
	end
	return false
end

local manual_stopped = false  -- true when stopped via command rather than natural end

severe_thunderstorm.is_ending = function(dtime)
	-- End only after phase 5 completes naturally
	if phase == 5 then
		local elapsed = os.time() - phase_start_time
		if elapsed >= RETREAT_DURATION then
			phase = 0
			manual_stopped = false
			hw_utils.set_severe_storm_active(false)
			return true
		end
	end

	if manual_trigger_end then
		manual_trigger_end = false
		manual_stopped = true
		phase = 0
		hw_utils.set_severe_storm_active(false)
		return true
	end

	return false
end

local render_timer = {}

severe_thunderstorm.in_area = function(position)
	-- Severe storms don't occur in frozen or dry biomes
	if hw_utils.is_biome_frozen(position) or
		hw_utils.is_biome_dry(position) then
		return false
	end
	return position.y > -10 and position.y < 200
end

severe_thunderstorm.add_player = function(player)
	-- Only initialize the phase machine once; additional players joining
	-- mid-storm should NOT reset it back to phase 1.
	if phase == 0 then
		start_storm()
	end
end

severe_thunderstorm.remove_player = function(player)
	local pname = player:get_player_name()
	stop_rain_sound(player)
	last_sky_intensity[pname] = nil
	last_sky_green[pname] = nil
	render_timer[pname] = nil

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
severe_thunderstorm.render = function(dtime, player)
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
	local sky_intensity = get_sky_intensity()

	-- Sky + lighting (throttled)
	render_timer[pname] = (render_timer[pname] or SKY_UPDATE_INTERVAL) + dtime
	if render_timer[pname] >= SKY_UPDATE_INTERVAL then
		render_timer[pname] = 0
		update_sky(pname, intensity, sky_intensity)
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
		-- Particles are gated per-position via is_outdoor() below, not by the
		-- player's overall shelter, so rain stays visible through a window.
		do
			local count, size, texture = rain_particles_for_progress(build_t)
			for i = 1, count do
				local rpos = hw_utils.get_random_pos(player, {front=10, back=5, top=8})
				if hw_utils.is_outdoor(rpos) then
					local wx, wz = 0, 0
					if breasy then
						local w = hw_utils.get_wind(rpos)
						wx = w.x * 0.5
						wz = w.z * 0.5
					end
					minetest.add_particle({
						pos = rpos,
						velocity = {x=wx, y=-12, z=wz},
						acceleration = {x=wx*0.1, y=-18, z=wz*0.1},
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

		-- No rumble sound for severe_thunderstorm (PDS-only feature)

		-- Particles are gated per-position via is_outdoor() below, not by the
		-- player's overall shelter, so rain stays visible through a window.
		do
			for i = 1, 10 do
				local rpos = hw_utils.get_random_pos(player, {front=10, back=5, top=8})
				if hw_utils.is_outdoor(rpos) then
					local wx, wz = 0, 0
					if breasy then
						local w = hw_utils.get_wind(rpos)
						wx = w.x
						wz = w.z
					end
					minetest.add_particle({
						pos = rpos,
						velocity = {x=wx, y=-12, z=wz},
						acceleration = {x=wx*0.1, y=-18, z=wz*0.1},
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
		-- (no rumble to fade out — PDS-only feature)
		local unwind_t = math.min(elapsed / UNWIND_DURATION, 1.0)
		local reversed_t = 1.0 - unwind_t  -- treat as if counting down build progress
		local wanted_file, sound_profile = rain_type_for_progress(reversed_t)
		ensure_rain_sound(player, wanted_file, sound_profile)
		sound_handles[pname] = hw_utils.update_weather_sound(
			sound_handles[pname], sound_profile, dtime, player)

		-- Particles are gated per-position via is_outdoor() below, not by the
		-- player's overall shelter, so rain stays visible through a window.
		do
			local count, size, texture = rain_particles_for_progress(reversed_t)
			for i = 1, count do
				local rpos = hw_utils.get_random_pos(player, {front=10, back=5, top=8})
				if hw_utils.is_outdoor(rpos) then
					local wx, wz = 0, 0
					if breasy then
						local w = hw_utils.get_wind(rpos)
						wx = w.x * 0.5
						wz = w.z * 0.5
					end
					minetest.add_particle({
						pos = rpos,
						velocity = {x=wx, y=-12, z=wz},
						acceleration = {x=wx*0.1, y=-18, z=wz*0.1},
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

severe_thunderstorm.start = function()
	manual_trigger_start = true
end

severe_thunderstorm.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(severe_thunderstorm)
