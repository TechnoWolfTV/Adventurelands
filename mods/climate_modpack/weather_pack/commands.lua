------------------------------------
-- Happy Weather API Chat Commands

-- License: MIT

-- Credits: xeranas
-- Modified by TechnoWolfTV
------------------------------------

minetest.register_privilege("weather_manager", {
	description = "Gives ability to control weather",
	give_to_singleplayer = false
})

local weather_codes = "light_rain, rain, heavy_rain, thunder, snow, snowstorm, " ..
	"light_fog, moderate_fog, heavy_fog, severe_storm"

local all_weather_codes = {
	"light_rain", "rain", "heavy_rain", "thunder",
	"snow", "snowstorm",
	"light_fog", "moderate_fog", "heavy_fog",
	"severe_storm"
}

minetest.register_chatcommand("start_weather", {
	params = "<weather_code>",
	description = "Starts weather by given weather code. " ..
		"Available codes: " .. weather_codes,
	privs = {weather_manager = true},
	func = function(name, param)
		if param ~= nil then
			happy_weather.request_to_start(param)
			minetest.log("action", name .. " requested weather '" .. param .. "' from chat command")
		end
	end
})

minetest.register_chatcommand("stop_weather", {
	params = "<weather_code>",
	description = "Ends weather by given weather code. " ..
		"Available codes: " .. weather_codes,
	privs = {weather_manager = true},
	func = function(name, param)
		if param ~= nil then
			happy_weather.request_to_end(param)
			minetest.log("action", name .. " requested weather '" .. param .. "' ending from chat command")
		end
	end
})

minetest.register_chatcommand("weather_status", {
	params = "",
	description = "Displays currently active weather conditions.",
	privs = {weather_manager = true},
	func = function(name, param)
		local active = {}
		for _, code in ipairs(all_weather_codes) do
			if happy_weather.is_weather_active(code) then
				table.insert(active, code)
			end
		end
		if #active == 0 then
			minetest.chat_send_player(name, "Weather status: None active.")
		else
			minetest.chat_send_player(name, "Weather status: " .. table.concat(active, ", "))
		end
	end
})

