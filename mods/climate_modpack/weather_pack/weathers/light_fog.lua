------------------------------
-- Happy Weather: Light Fog

-- License: MIT

-- Credits: TechnoWolfTV / xeranas
------------------------------

local light_fog = {}
light_fog.last_check = 0
light_fog.check_interval = 250

-- Roughly similar rarity to light_rain
light_fog.chance = 0.008

-- Weather identification code
light_fog.code = "light_fog"

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end = false

-- Skycolor layer id
local SKYCOLOR_LAYER = "happy_weather_light_fog_sky"

-- Fog sky overlay: a faint white-grey wash over the horizon/sky.
-- Light fog is subtle — just a mild milky tint.
local FOG_SKY_COLOR = {
	gradient_colors = {
		{r=0,   g=0,   b=0  },   -- midnight
		{r=175, g=178, b=180},   -- dawn/dusk horizon — soft grey
		{r=200, g=203, b=205},   -- daytime sky — light grey, not white
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

light_fog.is_starting = function(dtime, position)
	if light_fog.last_check + light_fog.check_interval < os.time() then
		light_fog.last_check = os.time()
		-- Don't start if heavy weather is active
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
	if light_fog.last_check + light_fog.check_interval < os.time() then
		light_fog.last_check = os.time()
		-- End immediately if heavy weather takes over
		if happy_weather.is_weather_active("heavy_rain") or
		   happy_weather.is_weather_active("snowstorm") then
			return true
		end
		if math.random() < 0.45 then
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

light_fog.add_player = function(player)
	set_sky_box(player:get_player_name())
end

light_fog.remove_player = function(player)
	remove_sky_box(player:get_player_name())
end

-- Fog haze particles: large soft wisps that overlap and blend.
-- Non-vertical so they lie flat in the air like real fog layers.
-- Drift direction follows wind if breasy is available.
local add_fog_particle = function(player)
	local offset = {
		front = 10,
		back = 5,
		top = 2,
		bottom = 1
	}

	local random_pos = hw_utils.get_random_pos(player, offset)
	random_pos.y = random_pos.y + (math.random() * 2.0 - 1.0)

	if hw_utils.is_outdoor(random_pos) then
		local wx, wz = (math.random() - 0.5) * 0.4, (math.random() - 0.5) * 0.4
		if breasy then
			local w = breasy.get_wind(random_pos)
			-- Light fog drifts very gently with wind
			wx = w.x * 0.12
			wz = w.z * 0.12
		end

		minetest.add_particle({
			pos = random_pos,
			velocity = {x=wx, y=0, z=wz},
			acceleration = {x=0, y=0, z=0},
			expirationtime = math.random(5, 9),
			size = math.random(16, 24),
			collisiondetection = false,
			vertical = false,
			texture = "weather_pack_fog.png^[transform" .. math.random(0,7),
			playername = player:get_player_name()
		})
	end
end

light_fog.in_area = function(position)
	-- Fog doesn't appear in dry biomes
	if hw_utils.is_biome_dry(position) then
		return false
	end
	if position.y > -5 and position.y < 150 then
		return true
	end
	return false
end

-- Sky layer is set on add_player and removed on remove_player only.
-- It stays active the whole time fog is running so the world outside
-- looks foggy even when viewed through a window from indoors.
-- Only particles are suppressed when the player is sheltered.

light_fog.render = function(dtime, player)
	local shelter = hw_utils.get_shelter_factor(player)

	-- Only spawn particles when player is outdoors enough to see them
	if shelter < 0.4 then
		-- Spawn one particle every other render tick on average
		if math.random() < 0.4 then
			add_fog_particle(player)
		end
	end
end

light_fog.start = function()
	manual_trigger_start = true
end

light_fog.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(light_fog)
