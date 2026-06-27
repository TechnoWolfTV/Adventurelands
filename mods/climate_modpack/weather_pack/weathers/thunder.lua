----------------------------------------------------------------
-- Happy Weather: Thunder

-- License: MIT

-- Credits: xeranas

-- See also: lightning mod for actual lightning effect, sounds.  
----------------------------------------------------------------

local thunder = {}
thunder.last_check = 0
thunder.check_interval = 100
--thunder.chance = 0.8
thunder.chance = 0.2

-- Weather identification code
thunder.code = "thunder"

local thunder_target_weather_code = "heavy_rain"

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end = false

-- Thunder weather appearance control
local thunder_weather_chance = 5 -- 5 percent appearance during heavy rain
local thunder_weather_next_check = 0
local thunder_weather_check_delay = 600 -- to avoid checks continuously

thunder.is_starting = function(dtime)
	thunder.next_strike = 0
	thunder.min_delay = 5
	thunder.max_delay = math.random(5, 45)

	if thunder.last_check + thunder.check_interval < os.time() then
		thunder.last_check = os.time()
		if math.random() < thunder.chance and happy_weather.is_weather_active("heavy_rain") then
			return true
		end
	end

	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end
	
	return false
end

thunder.is_ending = function(dtime)
	if thunder.last_check + thunder.check_interval < os.time() then
		thunder.last_check = os.time()
		if math.random() < 0.4 or happy_weather.is_weather_active("heavy_rain") == false then
			return true
		end
	end

	if manual_trigger_end then
		manual_trigger_end = false
		return true
	end

	return false
end

local calculate_thunder_strike_delay = function()
	local delay = math.random(thunder.min_delay, thunder.max_delay)
	thunder.next_strike = os.time() + delay
end

-- Returns true if at least one connected player has enough sky exposure
-- that a lightning strike would be meaningful (visible or audible).
-- We use a threshold of < 0.95 shelter so that extremely deep caves
-- (where neither flash nor sound would register) suppress the strike
-- entirely, saving the processing cost of a strike nobody experiences.
-- In practice this threshold is only reached many solid nodes underground.
local any_player_can_perceive_strike = function()
	for _, player in ipairs(minetest.get_connected_players()) do
		if hw_utils.get_shelter_factor(player) < 0.95 then
			return true
		end
	end
	return false
end

thunder.render = function(dtime, player)
	local player_name = player:get_player_name()
	if happy_weather.is_player_in_weather_area(player_name, "heavy_rain") == false then
		return
	end

	if thunder.next_strike <= os.time() then
		-- Only strike if at least one player can perceive it.
		-- This preserves the lightning visual for anyone near a window
		-- while avoiding pointless strikes when all players are deep underground.
		if any_player_can_perceive_strike() then
			lightning.strike()
		end
		calculate_thunder_strike_delay()
	end
end

thunder.start = function()
	manual_trigger_start = true
end

thunder.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(thunder)
