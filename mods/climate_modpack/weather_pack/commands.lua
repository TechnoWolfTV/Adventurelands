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

local weather_codes = "light_rain, rain, heavy_rain, overcast, clear, thunder, snow, snowstorm, " ..
	"light_fog, moderate_fog, dense_fog, severe_thunderstorm, pds_severe_thunderstorm"

local all_weather_codes = {
	"light_rain", "rain", "heavy_rain", "overcast", "clear", "thunder",
	"snow", "snowstorm",
	"light_fog", "moderate_fog", "dense_fog",
	"severe_thunderstorm", "pds_severe_thunderstorm"
}

----------------------------------------------------------------
-- Persistent disable/enable via mod storage
----------------------------------------------------------------
local storage = minetest.get_mod_storage()

local function is_disabled(code)
	return storage:get_string("disabled:" .. code) == "true"
end

local function set_disabled(code, value)
	if value then
		storage:set_string("disabled:" .. code, "true")
	else
		storage:set_string("disabled:" .. code, "")
	end
end

----------------------------------------------------------------
-- Weather codes suppressed while a severe storm (either tier) is active.
-- Rain and fog types are suppressed since severe storms take over the sky
-- and supersede them. Thunder is suppressed so it doesn't layer additional
-- uncoordinated lightning on top of the severe storm's own strikes.
-- Snow/snowstorm are intentionally excluded — severe storms are biome
-- restricted away from frozen areas, so there's no overlap to guard against.
----------------------------------------------------------------
local SUPPRESSED_DURING_SEVERE_STORM = {
	light_rain = true,
	rain = true,
	heavy_rain = true,
	overcast = true,
	clear = true,
	thunder = true,
	light_fog = true,
	moderate_fog = true,
	dense_fog = true,
}

----------------------------------------------------------------
-- Intercept happy_weather.request_to_start to enforce disabled state
-- and severe storm suppression
----------------------------------------------------------------
local original_request_to_start = happy_weather.request_to_start

happy_weather.request_to_start = function(code)
	if is_disabled(code) then
		return  -- silently block natural triggers
	end
	if SUPPRESSED_DURING_SEVERE_STORM[code] and hw_utils.is_severe_storm_active() then
		return  -- silently block while severe storm is active
	end
	original_request_to_start(code)
end

-- Also intercept is_starting for each weather by wrapping
-- happy_weather.register_weather to patch is_starting on registration
local original_register_weather = happy_weather.register_weather

happy_weather.register_weather = function(weather)
	local original_is_starting = weather.is_starting
	weather.is_starting = function(dtime, position)
		if is_disabled(weather.code) then
			return false
		end
		if SUPPRESSED_DURING_SEVERE_STORM[weather.code] and hw_utils.is_severe_storm_active() then
			return false
		end
		return original_is_starting(dtime, position)
	end
	original_register_weather(weather)
end

----------------------------------------------------------------
-- Commands
----------------------------------------------------------------

minetest.register_chatcommand("start_weather", {
	params = "<weather_code>",
	description = "Starts weather by given weather code. " ..
		"Available codes: " .. weather_codes,
	privs = {weather_manager = true},
	func = function(name, param)
		if not param or param == "" then
			minetest.chat_send_player(name, "Usage: /start_weather <weather_code>")
			return
		end
		if is_disabled(param) then
			minetest.chat_send_player(name, "Weather '" .. param .. "' is currently disabled. Use /enable_weather " .. param .. " first.")
			return
		end
		happy_weather.request_to_start(param)
		minetest.log("action", name .. " requested weather '" .. param .. "' from chat command")
	end
})

minetest.register_chatcommand("stop_weather", {
	params = "<weather_code|all>",
	description = "Ends weather by given weather code, or 'all' to stop all active weathers. " ..
		"Available codes: " .. weather_codes,
	privs = {weather_manager = true},
	func = function(name, param)
		if not param or param == "" then
			minetest.chat_send_player(name, "Usage: /stop_weather <weather_code|all>")
			return
		end
		if param == "all" then
			local stopped = {}
			for _, code in ipairs(all_weather_codes) do
				if happy_weather.is_weather_active(code) then
					happy_weather.force_end(code)
					table.insert(stopped, code)
				end
			end
			if #stopped == 0 then
				minetest.chat_send_player(name, "No active weathers to stop.")
			else
				minetest.chat_send_player(name, "Stopped: " .. table.concat(stopped, ", "))
			end
			minetest.log("action", name .. " stopped all weather from chat command")
		else
			happy_weather.force_end(param)
			minetest.log("action", name .. " requested weather '" .. param .. "' ending from chat command")
		end
	end
})

minetest.register_chatcommand("disable_weather", {
	params = "<weather_code|all>",
	description = "Disables a weather type so it cannot start naturally or manually. " ..
		"Use 'all' to disable all weathers. Persists between restarts. " ..
		"Available codes: " .. weather_codes,
	privs = {weather_manager = true},
	func = function(name, param)
		if not param or param == "" then
			minetest.chat_send_player(name, "Usage: /disable_weather <weather_code|all>")
			return
		end
		if param == "all" then
			local disabled = {}
			for _, code in ipairs(all_weather_codes) do
				if not is_disabled(code) then
					set_disabled(code, true)
					table.insert(disabled, code)
				end
				-- Stop if active
				if happy_weather.is_weather_active(code) then
					happy_weather.force_end(code)
				end
			end
			if #disabled == 0 then
				minetest.chat_send_player(name, "All weathers were already disabled.")
			else
				minetest.chat_send_player(name, "Disabled: " .. table.concat(disabled, ", "))
			end
			minetest.log("action", name .. " disabled all weather")
		else
			-- Validate code
			local valid = false
			for _, code in ipairs(all_weather_codes) do
				if code == param then valid = true; break end
			end
			if not valid then
				minetest.chat_send_player(name, "Unknown weather code: '" .. param .. "'. Available: " .. weather_codes)
				return
			end
			set_disabled(param, true)
			-- Stop if currently active
			if happy_weather.is_weather_active(param) then
				happy_weather.force_end(param)
				minetest.chat_send_player(name, "Weather '" .. param .. "' disabled and stopped.")
			else
				minetest.chat_send_player(name, "Weather '" .. param .. "' disabled.")
			end
			minetest.log("action", name .. " disabled weather '" .. param .. "'")
		end
	end
})

minetest.register_chatcommand("enable_weather", {
	params = "<weather_code|all>",
	description = "Re-enables a previously disabled weather type. " ..
		"Use 'all' to enable all weathers. " ..
		"Available codes: " .. weather_codes,
	privs = {weather_manager = true},
	func = function(name, param)
		if not param or param == "" then
			minetest.chat_send_player(name, "Usage: /enable_weather <weather_code|all>")
			return
		end
		if param == "all" then
			local enabled = {}
			for _, code in ipairs(all_weather_codes) do
				if is_disabled(code) then
					set_disabled(code, false)
					table.insert(enabled, code)
				end
			end
			if #enabled == 0 then
				minetest.chat_send_player(name, "All weathers were already enabled.")
			else
				minetest.chat_send_player(name, "Enabled: " .. table.concat(enabled, ", "))
			end
			minetest.log("action", name .. " enabled all weather")
		else
			-- Validate code
			local valid = false
			for _, code in ipairs(all_weather_codes) do
				if code == param then valid = true; break end
			end
			if not valid then
				minetest.chat_send_player(name, "Unknown weather code: '" .. param .. "'. Available: " .. weather_codes)
				return
			end
			set_disabled(param, false)
			minetest.chat_send_player(name, "Weather '" .. param .. "' enabled.")
			minetest.log("action", name .. " enabled weather '" .. param .. "'")
		end
	end
})

minetest.register_chatcommand("weather_status", {
	params = "",
	description = "Displays currently active, enabled, and disabled weather conditions.",
	privs = {weather_manager = true},
	func = function(name, param)
		local active = {}
		local enabled = {}
		local disabled = {}

		for _, code in ipairs(all_weather_codes) do
			if happy_weather.is_weather_active(code) then
				local duration = happy_weather.get_active_duration(code)
				if duration then
					local minutes = math.floor(duration / 60)
					local seconds = duration % 60
					table.insert(active, code .. " (" .. minutes .. "m " .. seconds .. "s)")
				else
					table.insert(active, code)
				end
			end
			if is_disabled(code) then
				table.insert(disabled, code)
			else
				table.insert(enabled, code)
			end
		end

		local function format_line(label, list)
			if #list == 0 then
				return label .. ": None"
			end
			return label .. ": " .. table.concat(list, ", ")
		end

		minetest.chat_send_player(name, "--- Weather Status ---")
		minetest.chat_send_player(name, format_line("Active", active))
		minetest.chat_send_player(name, format_line("Enabled", enabled))
		minetest.chat_send_player(name, format_line("Disabled", disabled))
	end
})
