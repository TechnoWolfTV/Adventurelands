------------------------------
-- Happy Weather: Heavy Fog

-- License: MIT

-- Credits: TechnoWolfTV / xeranas
------------------------------

local heavy_fog = {}
heavy_fog.last_check = 0
heavy_fog.check_interval = 320

-- Roughly half as common as moderate fog
heavy_fog.chance = 0.0015

-- Weather identification code
heavy_fog.code = "heavy_fog"

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end = false

-- Skycolor layer id
local SKYCOLOR_LAYER = "happy_weather_heavy_fog_sky"

-- Heavy fog: sky is nearly white-grey, very dim and flat
local FOG_SKY_COLOR = {
	gradient_colors = {
		{r=0,   g=0,   b=0  },
		{r=130, g=133, b=135},   -- horizon: distinctly dark grey
		{r=165, g=168, b=170},   -- daytime: dim, flat grey, sun barely visible
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

heavy_fog.is_starting = function(dtime, position)
	if heavy_fog.last_check + heavy_fog.check_interval < os.time() then
		heavy_fog.last_check = os.time()
		-- Incompatible with rain, heavy rain, and snowstorm
		if happy_weather.is_weather_active("heavy_rain") or
		   happy_weather.is_weather_active("rain") or
		   happy_weather.is_weather_active("snowstorm") then
			return false
		end
		if math.random() < heavy_fog.chance then
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

heavy_fog.is_ending = function(dtime)
	if heavy_fog.last_check + heavy_fog.check_interval < os.time() then
		heavy_fog.last_check = os.time()
		if happy_weather.is_weather_active("heavy_rain") or
		   happy_weather.is_weather_active("rain") or
		   happy_weather.is_weather_active("snowstorm") then
			return true
		end
		if math.random() < 0.35 then
			-- Heavy fog usually lifts to moderate rather than clearing instantly
			if math.random() < 0.7 then
				happy_weather.request_to_start("moderate_fog")
			end
			return true
		end
	end

	if manual_trigger_end then
		manual_trigger_end = false
		return true
	end

	return false
end

local set_sky_box = function(player_name)
	local sl = {}
	sl.name = SKYCOLOR_LAYER
	sl.sky_data = FOG_SKY_COLOR
	sl.clouds_data = FOG_CLOUD_COLOR
	skylayer.add_layer(player_name, sl)
end

local remove_sky_box = function(player_name)
	skylayer.remove_layer(player_name, SKYCOLOR_LAYER)
end

heavy_fog.add_player = function(player)
	set_sky_box(player:get_player_name())
end

heavy_fog.remove_player = function(player)
	remove_sky_box(player:get_player_name())
end

-- Dense fog particles — very large, long-lived, heavy overlap
local add_fog_particle = function(player)
	local offset = {
		front = 14,
		back = 7,
		top = 3,
		bottom = 1
	}

	local random_pos = hw_utils.get_random_pos(player, offset)
	random_pos.y = random_pos.y + (math.random() * 3.0 - 1.0)

	if hw_utils.is_outdoor(random_pos) then
		minetest.add_particle({
			pos = random_pos,
			velocity = {x = (math.random() - 0.5) * 0.4, y = 0, z = (math.random() - 0.5) * 0.4},
			acceleration = {x = 0, y = 0, z = 0},
			expirationtime = math.random(6, 10),
			size = math.random(26, 38),
			collisiondetection = false,
			vertical = false,
			texture = "weather_pack_fog.png^[transform" .. math.random(0,7),
			playername = player:get_player_name()
		})
	end
end

heavy_fog.in_area = function(position)
	if hw_utils.is_biome_dry(position) then
		return false
	end
	if position.y > -5 and position.y < 150 then
		return true
	end
	return false
end

-- Sky layer stays active the whole time so fog is visible through windows.
-- Only particles are suppressed when player is sheltered.

heavy_fog.render = function(dtime, player)
	local shelter = hw_utils.get_shelter_factor(player)

	if shelter < 0.4 then
		local particles_per_update = 3
		for i = particles_per_update, 1, -1 do
			add_fog_particle(player)
		end
	end
end

heavy_fog.start = function()
	manual_trigger_start = true
end

heavy_fog.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(heavy_fog)
