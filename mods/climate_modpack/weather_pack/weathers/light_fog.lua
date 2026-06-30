------------------------------
-- Happy Weather: Light Fog

-- License: MIT

-- Credits: TechnoWolfTV / xeranas
------------------------------

local light_fog = {}
light_fog.last_check = 0
light_fog.check_interval = 300

-- Roughly similar rarity to light_rain
light_fog.chance = 0.025

-- Weather identification code
light_fog.code = "light_fog"

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end   = false
local force_trigger_end    = false

-- Skycolor layer id
local SKYCOLOR_LAYER = "happy_weather_light_fog_sky"

-- Fog sky overlay: a faint white-grey wash over the horizon/sky.
local FOG_SKY_COLOR = {
	gradient_colors = {
		{r=0,   g=0,   b=0  },
		{r=175, g=178, b=180},
		{r=200, g=203, b=205},
		{r=175, g=178, b=180},
		{r=0,   g=0,   b=0  }
	}
}

local FOG_CLOUD_COLOR = {
	gradient_colors = {
		{r=155, g=158, b=160},
		{r=185, g=188, b=190},
		{r=210, g=212, b=214},
		{r=185, g=188, b=190},
		{r=155, g=158, b=160}
	},
	density = 0.55
}

----------------------------------------------------------------
-- Engine-level fog and lighting
--
-- No particles. Fog is applied via Luanti's set_sky fog table
-- (5.9+), giving true atmospheric depth with no per-player
-- particle spawning cost.
--
-- Lighting is dimmed 25% at full intensity (ratio target 0.75),
-- matching the technique used by the severe storm tiers.
--
-- Both fade in over FOG_TRANSITION_TIME on entry and fade out
-- over the same duration on exit before the weather deactivates.
----------------------------------------------------------------
local FOG_DISTANCE        = 100    -- nodes, fully opaque at this range
local FOG_START           = 0.4   -- fog begins at this fraction of FOG_DISTANCE
local FOG_LIGHT_TARGET    = 0.925  -- 25% dimmer than normal
local FOG_TRANSITION_TIME = 10    -- seconds for entry/exit fade

-- Weather-level lifecycle (mirrors heavy_rain pattern)
local weather_active_since = nil  -- os.time() when first player entered
local ending_requested     = false
local ending_started_at    = nil
local active_player_count  = 0    -- guards remove_player from wiping state prematurely

-- Per-player state
local fog_start_times  = {}  -- [pname] = os.time() when this player entered fog
local last_fog_t       = {}  -- [pname] = last applied fog_t, skip if unchanged
local shelter_timers   = {}  -- [pname] = accumulated dtime since last shelter check
local player_sheltered = {}  -- [pname] = true if player currently sheltered
local SHELTER_CHECK_INTERVAL = 1.0  -- recalculate shelter at most once per second

local function lerp(a, b, t)
	return a + (b - a) * t
end

local apply_fog_effect = function(player, fog_t)
	-- Interpolate view-distance fog toward target
	local fog_dist  = math.floor(lerp(1000, FOG_DISTANCE, fog_t))
	local fog_start = FOG_START * fog_t

	player:set_sky({
		fog = {
			fog_distance = fog_dist,
			fog_start    = fog_start,
		}
	})

	-- Dim lighting proportional to fog intensity
	local current_ratio = minetest.time_to_day_night_ratio(minetest.get_timeofday())
	local target_ratio  = lerp(current_ratio, FOG_LIGHT_TARGET, fog_t)
	player:override_day_night_ratio(target_ratio)
end

local clear_fog_effect = function(player)
	player:set_sky({ fog = { fog_distance = -1, fog_start = -1 } })
	player:override_day_night_ratio(nil)
end

light_fog.is_starting = function(dtime, position)
	if light_fog.last_check + light_fog.check_interval < os.time() then
		light_fog.last_check = os.time()
		if happy_weather.is_weather_active("heavy_rain") or
		   happy_weather.is_weather_active("snowstorm") then
			return false
		end
		if math.random() < light_fog.chance then
			return true
		end
	end

	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end

	return false
end

light_fog.is_ending = function(dtime)
	local now = os.time()

	-- Admin force-stop: end immediately, no taper.
	if force_trigger_end then
		force_trigger_end  = false
		ending_requested   = false
		ending_started_at  = nil
		return true
	end

	if light_fog.last_check + light_fog.check_interval < now then
		light_fog.last_check = now
		if not ending_requested then
			if happy_weather.is_weather_active("heavy_rain") or
			   happy_weather.is_weather_active("snowstorm") then
				ending_requested = true
			elseif math.random() < 0.45 then
				ending_requested = true
			end
		end
	end

	if manual_trigger_end then
		manual_trigger_end = false
		ending_requested   = true
	end

	if not ending_requested then
		return false
	end

	-- Begin exit taper once ending is requested
	if not ending_started_at then
		ending_started_at = now
	end

	return now - ending_started_at >= FOG_TRANSITION_TIME
end

local set_sky_box = function(player_name)
	local sl = {}
	sl.name = SKYCOLOR_LAYER
	sl.sky_data    = FOG_SKY_COLOR
	sl.clouds_data = FOG_CLOUD_COLOR
	skylayer.add_layer(player_name, sl)
end

light_fog.add_player = function(player)
	local pname = player:get_player_name()
	active_player_count = active_player_count + 1
	if weather_active_since == nil then
		weather_active_since = os.time()
	end
	fog_start_times[pname]  = os.time()
	last_fog_t[pname]       = nil
	shelter_timers[pname]   = SHELTER_CHECK_INTERVAL  -- check immediately on entry
	player_sheltered[pname] = false
	set_sky_box(pname)
end

light_fog.remove_player = function(player)
	local pname = player:get_player_name()
	clear_fog_effect(player)
	skylayer.remove_layer(pname, SKYCOLOR_LAYER)
	fog_start_times[pname]  = nil
	last_fog_t[pname]       = nil
	shelter_timers[pname]   = nil
	player_sheltered[pname] = nil
	active_player_count = math.max(0, active_player_count - 1)
	-- Only reset weather-level state when the last player leaves;
	-- earlier calls would wipe taper state mid-fade for remaining players.
	if active_player_count == 0 then
		weather_active_since = nil
		ending_requested     = false
		ending_started_at    = nil
	end
end

light_fog.in_area = function(position)
	if hw_utils.is_biome_dry(position) then
		return false
	end
	if position.y > -5 and position.y < 150 then
		return true
	end
	return false
end

light_fog.render = function(dtime, player)
	local pname = player:get_player_name()
	local now   = os.time()

	-- Throttled shelter check: once per second, determine if this player
	-- is currently indoors. If sheltered, clear fog for them entirely;
	-- fog is a purely outdoor atmospheric effect.
	shelter_timers[pname] = (shelter_timers[pname] or SHELTER_CHECK_INTERVAL) + dtime
	if shelter_timers[pname] >= SHELTER_CHECK_INTERVAL then
		shelter_timers[pname] = 0
		local shelter = hw_utils.get_shelter_factor(player)
		player_sheltered[pname] = shelter > 0.3
	end

	if player_sheltered[pname] then
		clear_fog_effect(player)
		last_fog_t[pname] = nil  -- force reapply when they step back outside
		return
	end

	-- Entry fade-in: 0.0 → 1.0 over FOG_TRANSITION_TIME from this player's join
	local fog_t = 1.0
	if fog_start_times[pname] then
		local elapsed = now - fog_start_times[pname]
		if elapsed < FOG_TRANSITION_TIME then
			fog_t = elapsed / FOG_TRANSITION_TIME
		end
	end

	-- Exit fade-out: 1.0 → 0.0 over FOG_TRANSITION_TIME once ending_started_at is set
	if ending_started_at then
		local taper_elapsed = now - ending_started_at
		local taper_t = math.min(taper_elapsed / FOG_TRANSITION_TIME, 1)
		fog_t = math.min(fog_t, 1 - taper_t)
	end

	-- Skip update if fog_t hasn't changed meaningfully (steady full fog)
	local last_t = last_fog_t[pname] or -1
	if math.abs(fog_t - last_t) < 0.02 and last_t >= 1.0 then
		return
	end
	last_fog_t[pname] = fog_t

	apply_fog_effect(player, fog_t)
end

light_fog.start = function()
	manual_trigger_start = true
end

light_fog.stop = function()
	manual_trigger_end = true
end

light_fog.force_stop = function()
	force_trigger_end = true
end

minetest.register_on_leaveplayer(function(player)
	local pname = player:get_player_name()
	fog_start_times[pname]  = nil
	last_fog_t[pname]       = nil
	shelter_timers[pname]   = nil
	player_sheltered[pname] = nil
end)

happy_weather.register_weather(light_fog)
