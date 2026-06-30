------------------------------
-- Happy Weather: Dense Fog

-- License: MIT

-- Credits: TechnoWolfTV / xeranas
------------------------------

local dense_fog = {}
dense_fog.last_check = 0
dense_fog.check_interval = 400

-- Roughly half as common as moderate fog
dense_fog.chance = 0.0075

-- Weather identification code
dense_fog.code = "dense_fog"

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end   = false
local force_trigger_end    = false

-- Skycolor layer id
local SKYCOLOR_LAYER = "happy_weather_dense_fog_sky"

-- Dense fog: sky is nearly white-grey, very dim and flat
local FOG_SKY_COLOR = {
	gradient_colors = {
		{r=0,   g=0,   b=0  },
		{r=130, g=133, b=135},
		{r=165, g=168, b=170},
		{r=130, g=133, b=135},
		{r=0,   g=0,   b=0  }
	}
}

local FOG_CLOUD_COLOR = {
	gradient_colors = {
		{r=100, g=103, b=105},
		{r=135, g=138, b=140},
		{r=165, g=168, b=170},
		{r=135, g=138, b=140},
		{r=100, g=103, b=105}
	},
	density = 1.0
}

local FOG_DISTANCE        = 20
local FOG_START           = 0.1
local FOG_LIGHT_TARGET    = 0.75
local FOG_TRANSITION_TIME = 10

local weather_active_since = nil
local ending_requested     = false
local ending_started_at    = nil
local active_player_count  = 0    -- guards remove_player from wiping state prematurely

local fog_start_times  = {}
local last_fog_t       = {}
local shelter_timers   = {}
local player_sheltered = {}
local SHELTER_CHECK_INTERVAL = 1.0

local function lerp(a, b, t)
	return a + (b - a) * t
end

local apply_fog_effect = function(player, fog_t)
	local fog_dist  = math.floor(lerp(1000, FOG_DISTANCE, fog_t))
	local fog_start = FOG_START * fog_t

	player:set_sky({
		fog = {
			fog_distance = fog_dist,
			fog_start    = fog_start,
		}
	})

	local current_ratio = minetest.time_to_day_night_ratio(minetest.get_timeofday())
	local target_ratio  = lerp(current_ratio, FOG_LIGHT_TARGET, fog_t)
	player:override_day_night_ratio(target_ratio)
end

local clear_fog_effect = function(player)
	player:set_sky({ fog = { fog_distance = -1, fog_start = -1 } })
	player:override_day_night_ratio(nil)
end

dense_fog.is_starting = function(dtime, position)
	if dense_fog.last_check + dense_fog.check_interval < os.time() then
		dense_fog.last_check = os.time()
		-- Incompatible with rain, heavy rain, and snowstorm
		if happy_weather.is_weather_active("heavy_rain") or
		   happy_weather.is_weather_active("rain") or
		   happy_weather.is_weather_active("snowstorm") then
			return false
		end
		if math.random() < dense_fog.chance then
			happy_weather.request_to_end("light_fog")
			happy_weather.request_to_end("moderate_fog")
			return true
		end
	end

	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end

	return false
end

dense_fog.is_ending = function(dtime)
	local now = os.time()

	if force_trigger_end then
		force_trigger_end  = false
		ending_requested   = false
		ending_started_at  = nil
		return true
	end

	if dense_fog.last_check + dense_fog.check_interval < now then
		dense_fog.last_check = now
		if not ending_requested then
			if happy_weather.is_weather_active("heavy_rain") or
			   happy_weather.is_weather_active("rain") or
			   happy_weather.is_weather_active("snowstorm") then
				ending_requested = true
			elseif math.random() < 0.35 then
				-- Dense fog usually lifts to moderate rather than clearing instantly
				if math.random() < 0.7 then
					happy_weather.request_to_start("moderate_fog")
				end
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

dense_fog.add_player = function(player)
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

dense_fog.remove_player = function(player)
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

dense_fog.in_area = function(position)
	if hw_utils.is_biome_dry(position) then
		return false
	end
	if position.y > -5 and position.y < 150 then
		return true
	end
	return false
end

dense_fog.render = function(dtime, player)
	local pname = player:get_player_name()
	local now   = os.time()

	-- Throttled shelter check: once per second, determine if this player
	-- is currently indoors. If sheltered, clear fog for them entirely.
	shelter_timers[pname] = (shelter_timers[pname] or SHELTER_CHECK_INTERVAL) + dtime
	if shelter_timers[pname] >= SHELTER_CHECK_INTERVAL then
		shelter_timers[pname] = 0
		local shelter = hw_utils.get_shelter_factor(player)
		player_sheltered[pname] = shelter > 0.3
	end

	if player_sheltered[pname] then
		clear_fog_effect(player)
		last_fog_t[pname] = nil
		return
	end

	local fog_t = 1.0
	if fog_start_times[pname] then
		local elapsed = now - fog_start_times[pname]
		if elapsed < FOG_TRANSITION_TIME then
			fog_t = elapsed / FOG_TRANSITION_TIME
		end
	end

	if ending_started_at then
		local taper_elapsed = now - ending_started_at
		local taper_t = math.min(taper_elapsed / FOG_TRANSITION_TIME, 1)
		fog_t = math.min(fog_t, 1 - taper_t)
	end

	local last_t = last_fog_t[pname] or -1
	if math.abs(fog_t - last_t) < 0.02 and last_t >= 1.0 then
		return
	end
	last_fog_t[pname] = fog_t

	apply_fog_effect(player, fog_t)
end

dense_fog.start = function()
	manual_trigger_start = true
end

dense_fog.stop = function()
	manual_trigger_end = true
end

dense_fog.force_stop = function()
	force_trigger_end = true
end

minetest.register_on_leaveplayer(function(player)
	local pname = player:get_player_name()
	fog_start_times[pname]  = nil
	last_fog_t[pname]       = nil
	shelter_timers[pname]   = nil
	player_sheltered[pname] = nil
end)

happy_weather.register_weather(dense_fog)
