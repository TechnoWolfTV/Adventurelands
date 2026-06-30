--------------------------------
-- Happy Weather: ABM registers

-- License: MIT

-- Credits: xeranas
--------------------------------

-- Heavy rain / severe storms: extinguish outdoor fire quickly (~5 seconds average).
-- Covers both fire:basic_flame and lightning:dying_flame (created by lightning strikes).
minetest.register_abm({
	nodenames = {"fire:basic_flame", "lightning:dying_flame"},
	interval = 4.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if happy_weather.is_weather_active("heavy_rain") or
		   happy_weather.is_weather_active("severe_thunderstorm") or
		   happy_weather.is_weather_active("pds_severe_thunderstorm") then
			if hw_utils.is_outdoor(pos) then
				minetest.remove_node(pos)
			end
		end
	end
})

-- Moderate rain: extinguish outdoor fire more slowly (~10 seconds average).
minetest.register_abm({
	nodenames = {"fire:basic_flame", "lightning:dying_flame"},
	interval = 5.0,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if happy_weather.is_weather_active("rain") then
			if hw_utils.is_outdoor(pos) then
				minetest.remove_node(pos)
			end
		end
	end
})