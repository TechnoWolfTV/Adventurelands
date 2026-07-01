------------------------------
-- Happy Weather: Overcast

-- License: MIT

-- Credits: TechnoWolfTV
------------------------------

local overcast = {}
overcast.last_check = 0
overcast.check_interval = 300

-- Same frequency as rain
overcast.chance = 0.025

-- Weather identification code
overcast.code = "overcast"

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end   = false

-- Skycolor layer id
local SKYCOLOR_LAYER = "happy_weather_overcast_sky"

-- Sky/cloud colors copied directly from heavy_rain -- overcast applies
-- only the sky box with no rain, sound, particles, or lighting changes.
local SKY_COLORS = {
	gradient_colors = {
		{r=0,   g=0,   b=0  },
		{r=85,  g=86,  b=98 },
		{r=142, g=140, b=149},
		{r=85,  g=86,  b=98 },
		{r=0,   g=0,   b=0  }
	}
}

local CLOUD_COLORS = {
	gradient_colors = {
		{r=0,   g=0,   b=0  },
		{r=82,  g=83,  b=98 },
		{r=140, g=138, b=149},
		{r=82,  g=83,  b=98 },
		{r=0,   g=0,   b=0  }
	},
	speed   = {z = 10, y = -40},
	density = 0.6
}

overcast.is_starting = function(dtime, position)
	if overcast.last_check + overcast.check_interval < os.time() then
		overcast.last_check = os.time()
		if math.random() < overcast.chance then
			return true
		end
	end

	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end

	return false
end

overcast.is_ending = function(dtime)
	if overcast.last_check + overcast.check_interval < os.time() then
		overcast.last_check = os.time()
		if math.random() < 0.4 then
			return true
		end
	end

	if manual_trigger_end then
		manual_trigger_end = false
		return true
	end

	return false
end

overcast.add_player = function(player)
	local pname = player:get_player_name()
	local sl = {}
	sl.name        = SKYCOLOR_LAYER
	sl.sky_data    = SKY_COLORS
	sl.clouds_data = CLOUD_COLORS
	skylayer.add_layer(pname, sl)
end

overcast.remove_player = function(player)
	skylayer.remove_layer(player:get_player_name(), SKYCOLOR_LAYER)
end

overcast.render = function(dtime, player)
	-- Sky box only, nothing to update each tick
end

overcast.in_area = function(position)
	if position.y > -10 and position.y < 120 then
		return true
	end
	return false
end

overcast.start = function()
	manual_trigger_start = true
end

overcast.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(overcast)
