------------------------------
-- Happy Weather: Moderate Fog

-- License: MIT

-- Credits: TechnoWolfTV / xeranas
------------------------------

local moderate_fog = {}
moderate_fog.last_check = 0
moderate_fog.check_interval = 280

-- Roughly half as common as light fog
moderate_fog.chance = 0.004

-- Weather identification code
moderate_fog.code = "moderate_fog"

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end = false

-- Skycolor layer id
local SKYCOLOR_LAYER = "happy_weather_moderate_fog_sky"

-- Moderate fog: noticeably whiter/greyer sky, denser clouds
local FOG_SKY_COLOR = {
	gradient_colors = {
		{r=0,   g=0,   b=0  },
		{r=155, g=158, b=160},   -- horizon: clearly greyer than light fog
		{r=185, g=188, b=190},   -- daytime: noticeably grey, muted
		{r=155, g=158, b=160},
		{r=0,   g=0,   b=0  }
	}
}

local FOG_CLOUD_COLOR = {
	gradient_colors = {
		{r=125, g=128, b=130},
		{r=160, g=163, b=165},
		{r=185, g=188, b=190},
		{r=160, g=163, b=165},
		{r=125, g=128, b=130}
	},
	density = 0.75
}

moderate_fog.is_starting = function(dtime, position)
	if moderate_fog.last_check + moderate_fog.check_interval < os.time() then
		moderate_fog.last_check = os.time()
		-- Incompatible with heavy rain and snowstorm
		if happy_weather.is_weather_active("heavy_rain") or
		   happy_weather.is_weather_active("snowstorm") then
			return false
		end
		-- Displace light fog if it's running
		if math.random() < moderate_fog.chance then
			happy_weather.request_to_end("light_fog")
			return true
		end
	end

	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end

	return false
end

moderate_fog.is_ending = function(dtime)
	if moderate_fog.last_check + moderate_fog.check_interval < os.time() then
		moderate_fog.last_check = os.time()
		if happy_weather.is_weather_active("heavy_rain") or
		   happy_weather.is_weather_active("snowstorm") then
			return true
		end
		if math.random() < 0.4 then
			-- Sometimes lifts to light fog rather than clearing entirely
			if math.random() < 0.5 then
				happy_weather.request_to_start("light_fog")
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

moderate_fog.add_player = function(player)
	set_sky_box(player:get_player_name())
end

moderate_fog.remove_player = function(player)
	remove_sky_box(player:get_player_name())
end

-- Denser fog particles than light fog — more overlap, slightly larger
local add_fog_particle = function(player)
	local offset = {
		front = 12,
		back = 6,
		top = 2,
		bottom = 1
	}

	local random_pos = hw_utils.get_random_pos(player, offset)
	random_pos.y = random_pos.y + (math.random() * 2.5 - 1.0)

	if hw_utils.is_outdoor(random_pos) then
		local wx, wz = (math.random() - 0.5) * 0.5, (math.random() - 0.5) * 0.5
		if breasy then
			local w = breasy.get_wind(random_pos)
			wx = w.x * 0.15
			wz = w.z * 0.15
		end

		minetest.add_particle({
			pos = random_pos,
			velocity = {x=wx, y=0, z=wz},
			acceleration = {x=0, y=0, z=0},
			expirationtime = math.random(5, 8),
			size = math.random(20, 30),
			collisiondetection = false,
			vertical = false,
			texture = "weather_pack_fog.png^[transform" .. math.random(0,7),
			playername = player:get_player_name()
		})
	end
end

moderate_fog.in_area = function(position)
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

moderate_fog.render = function(dtime, player)
	local shelter = hw_utils.get_shelter_factor(player)

	if shelter < 0.4 then
		local particles_per_update = 2
		for i = particles_per_update, 1, -1 do
			if math.random() < 0.6 then
				add_fog_particle(player)
			end
		end
	end
end

moderate_fog.start = function()
	manual_trigger_start = true
end

moderate_fog.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(moderate_fog)
