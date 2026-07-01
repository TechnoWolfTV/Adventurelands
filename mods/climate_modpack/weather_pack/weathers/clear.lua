------------------------------
-- Happy Weather: Clear

-- License: MIT

-- Credits: TechnoWolfTV
------------------------------

local clear = {}
clear.last_check = 0
clear.check_interval = 300

-- Same frequency as overcast
clear.chance = 0.025

-- Weather identification code
clear.code = "clear"

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end   = false

clear.is_starting = function(dtime, position)
	if clear.last_check + clear.check_interval < os.time() then
		clear.last_check = os.time()
		if math.random() < clear.chance then
			return true
		end
	end

	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end

	return false
end

clear.is_ending = function(dtime)
	if clear.last_check + clear.check_interval < os.time() then
		clear.last_check = os.time()
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

clear.add_player = function(player)
	-- Default Luanti blue sky with clouds disabled
	player:set_sky({ clouds = false })
end

clear.remove_player = function(player)
	-- Restore Luanti's full default sky and clouds
	player:set_sky({ type = "regular", clouds = true })
end

clear.render = function(dtime, player)
	-- Sky only, nothing to update each tick
end

clear.in_area = function(position)
	if position.y > -10 and position.y < 120 then
		return true
	end
	return false
end

clear.start = function()
	manual_trigger_start = true
end

clear.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(clear)
