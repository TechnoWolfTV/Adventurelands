------------------------------
-- Happy Weather: Heavy Rain

-- License: MIT

-- Credits: xeranas
-- Modified by TechnoWolfTV
------------------------------

local heavy_rain = {}
heavy_rain.last_check = 0
heavy_rain.check_interval = 200

-- Weather identification code
heavy_rain.code = "heavy_rain"

-- Keeps sound handlers
local sound_handlers = {}

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end = false
local force_trigger_end = false  -- admin force-stop, bypasses taper entirely

-- Skycolor layer id
local SKYCOLOR_LAYER = "happy_weather_heavy_rain_sky"

----------------------------------------------------------------
-- Natural entry/exit envelope
--
-- Goal: heavy rain can still begin and end relatively quickly
-- (real storms do), but never instantly. Sky goes overcast right
-- away; rain itself ramps in over a few seconds rather than
-- switching on at full intensity, and tapers back out the same
-- way before the sky reverts -- regardless of *why* it's ending
-- (its own natural roll, an admin command, or another weather
-- type like rain.lua yanking it via request_to_end).
----------------------------------------------------------------
local RAIN_ONSET_DELAY    = 10  -- seconds of sky-fade-in before any rain appears
local RAIN_RAMP_DURATION  = 10  -- seconds to ramp from first drop to full intensity
local MIN_ACTIVE_DURATION = 30  -- seconds a storm must run before any end request is honored
local EXIT_TAPER_DURATION = 10  -- seconds to fade rain/sound/sky out once ending begins

-- Weather-level (not per-player) lifecycle state
local active_players      = {}  -- [pname] = true, players currently counted toward this weather
local active_player_count = 0
local weather_active_since = nil -- os.time() when this weather first had a player, nil if inactive
local ending_requested    = false -- true once something has asked this weather to end
local ending_started_at   = nil  -- os.time() when the exit taper began

-- Per-player one-shot sound fade tracking
local exit_fade_started = {}  -- [pname] = true once the fade-out has been kicked off

-- Drops a player out of the weather-level lifecycle bookkeeping.
-- Used both by the normal remove_player callback and by the
-- on_leaveplayer cleanup (which remove_player never sees, since a
-- disconnected player drops out of the engine's player loop first).
local deactivate_for_player = function(pname)
	if active_players[pname] then
		active_players[pname] = nil
		active_player_count = math.max(0, active_player_count - 1)
		if active_player_count == 0 then
			weather_active_since = nil
			ending_requested = false
			ending_started_at = nil
		end
	end
end

heavy_rain.is_starting = function(dtime, position)
	if heavy_rain.last_check + heavy_rain.check_interval < os.time() then
		heavy_rain.last_check = os.time()
		local heavy_rain_chance = 0.015
		if hw_utils.is_biome_tropic(position) then
			heavy_rain_chance = 0.1
		end
		if math.random() < heavy_rain_chance then
			happy_weather.request_to_end("light_rain")
			happy_weather.request_to_end("rain")
			return true
		end
	end

	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end

	return false
end

heavy_rain.is_ending = function(dtime)
	local now = os.time()

	-- Admin force-stop (/stop_weather, /disable_weather): end right now,
	-- no minimum duration, no taper, no exceptions.
	if force_trigger_end then
		force_trigger_end = false
		ending_requested = false
		ending_started_at = nil
		return true
	end

	-- Look for a reason to end, but only latch it -- we don't act on it
	-- immediately. This runs once even after ending_requested is true so
	-- that a manual_trigger_end firing here is still consumed/cleared.
	if heavy_rain.last_check + heavy_rain.check_interval < now then
		heavy_rain.last_check = now
		if not ending_requested and math.random() < 0.7 then
			if math.random() < 0.4 then
				happy_weather.request_to_start("rain")
			end
			ending_requested = true
		end
	end

	if manual_trigger_end then
		manual_trigger_end = false
		ending_requested = true
	end

	if not ending_requested then
		return false
	end

	-- A severe storm starting is a hard takeover, not a soft suggestion:
	-- both severe storm tiers call request_to_end("heavy_rain") specifically
	-- to clear our sky/sound/particles before laying down their own custom
	-- sky. Holding heavy_rain open here (even just to taper out) would mean
	-- two skies fighting for several seconds, which is the exact bug the
	-- severe storm files were written to avoid. So: end immediately, no
	-- minimum duration and no taper, whenever a severe storm is active.
	if hw_utils.is_severe_storm_active() then
		return true
	end

	-- Don't let any other end request -- ours or another weather's (e.g.
	-- rain.lua calling request_to_end("heavy_rain")) -- cut this storm off
	-- before it's had a minimum amount of time to actually be heavy rain.
	-- Short storms are fine; instantly-killed storms aren't.
	if weather_active_since and (now - weather_active_since) < MIN_ACTIVE_DURATION then
		return false
	end

	-- Past the minimum duration: begin (or continue) the exit taper.
	if not ending_started_at then
		ending_started_at = now
	end

	return now - ending_started_at >= EXIT_TAPER_DURATION
end

-- Storm sky/cloud colors (as before -- applied instantly on add_player).
local STORM_SKY_COLORS = {
	{r=0, g=0, b=0},
	{r=85, g=86, b=98},
	{r=142, g=140, b=149},
	{r=85, g=86, b=98},
	{r=0, g=0, b=0}
}
local STORM_CLOUD_COLORS = {
	{r=0, g=0, b=0},
	{r=65, g=66, b=78},
	{r=112, g=110, b=119},
	{r=65, g=66, b=78},
	{r=0, g=0, b=0}
}
local STORM_CLOUD_DENSITY = 0.6
local STORM_CLOUD_SPEED = {z = 10, y = -40}

-- Target "clear sky" the exit fade interpolates toward, so the eventual
-- skylayer.remove_layer (which is always instant) lands on colors close
-- enough to default that the final snap is imperceptible.
local CLEAR_SKY_COLORS = {
	{r=0,   g=0,   b=0  },
	{r=130, g=170, b=200},
	{r=150, g=200, b=250},
	{r=130, g=170, b=200},
	{r=0,   g=0,   b=0  }
}
local CLEAR_CLOUD_COLORS = {
	{r=200, g=200, b=200},
	{r=230, g=230, b=230},
	{r=255, g=255, b=255},
	{r=230, g=230, b=230},
	{r=200, g=200, b=200}
}
local CLEAR_CLOUD_DENSITY = 0.4
local CLEAR_CLOUD_SPEED = {z = 2, y = -10}

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function lerp_color(a, b, t)
	return {
		r = math.floor(lerp(a.r, b.r, t)),
		g = math.floor(lerp(a.g, b.g, t)),
		b = math.floor(lerp(a.b, b.b, t))
	}
end

local function lerp_gradient(a_list, b_list, t)
	local result = {}
	for i = 1, #a_list do
		result[i] = lerp_color(a_list[i], b_list[i], t)
	end
	return result
end

-- Builds a sky layer interpolated between the clear-sky target (storm_t=0)
-- and full storm colors (storm_t=1). Shared by the initial (clear) layer,
-- the entry fade-in, and the exit fade-out.
local build_sky_layer = function(storm_t)
	local sl = {}
	sl.name = SKYCOLOR_LAYER
	sl.sky_data = {
		gradient_colors = lerp_gradient(CLEAR_SKY_COLORS, STORM_SKY_COLORS, storm_t),
	}
	sl.clouds_data = {
		gradient_colors = lerp_gradient(CLEAR_CLOUD_COLORS, STORM_CLOUD_COLORS, storm_t),
		density = lerp(CLEAR_CLOUD_DENSITY, STORM_CLOUD_DENSITY, storm_t),
		speed = {
			z = lerp(CLEAR_CLOUD_SPEED.z, STORM_CLOUD_SPEED.z, storm_t),
			y = lerp(CLEAR_CLOUD_SPEED.y, STORM_CLOUD_SPEED.y, storm_t)
		}
	}
	return sl
end

-- Per-player reference to the SAME table object handed to skylayer.add_layer.
-- skylayer stores this table by reference, so mutating its fields directly
-- updates what's rendered without ever removing/re-adding the layer --
-- removing it (even briefly) makes skylayer hard-reset to the engine's
-- default sky before the next add takes effect, which looked like rapid
-- flashing when done repeatedly during a fade.
local sky_layer_refs = {}  -- [pname] = live layer table

-- Per-player throttling so we're not recalculating colors every single
-- tick -- a few times a second is plenty smooth.
local sky_fade_timers = {}  -- [pname] = time_since_last_update
local SKY_FADE_UPDATE_INTERVAL = 0.3

-- Mutates the player's existing sky layer toward the given storm_t
-- (0=clear, 1=full storm). Used during both the entry fade-in and the
-- exit fade-out. Setting `updated = false` tells skylayer's own update
-- loop to push the change to the engine on its very next step rather
-- than waiting for its normal multi-second refresh interval.
local apply_sky_fade = function(pname, dtime, storm_t)
	local layer = sky_layer_refs[pname]
	if not layer then return end

	sky_fade_timers[pname] = (sky_fade_timers[pname] or SKY_FADE_UPDATE_INTERVAL) + dtime
	if sky_fade_timers[pname] < SKY_FADE_UPDATE_INTERVAL then
		return
	end
	sky_fade_timers[pname] = 0

	local updated = build_sky_layer(storm_t)
	layer.sky_data = updated.sky_data
	layer.clouds_data = updated.clouds_data
	layer.updated = false
end

local set_rain_sound = function(player, gain)
	return minetest.sound_play("heavy_rain_drop", {
		object = player,
		max_hear_distance = 2,
		loop = true,
		gain = gain or 1.0,
	})
end

local remove_rain_sound = function(player)
	local pname = player:get_player_name()
	local sound = sound_handlers[pname]
	if sound ~= nil then
		minetest.sound_stop(sound)
		sound_handlers[pname] = nil
		hw_utils.clear_sound_state(pname, "heavy_rain")
	end
	exit_fade_started[pname] = nil
	sky_fade_timers[pname] = nil
	sky_layer_refs[pname] = nil
end

heavy_rain.add_player = function(player)
	local pname = player:get_player_name()
	if not active_players[pname] then
		active_players[pname] = true
		active_player_count = active_player_count + 1
		if weather_active_since == nil then
			weather_active_since = os.time()
		end
	end
	-- Sky starts clear and fades in via render(), reaching full storm
	-- exactly as rain starts falling (see RAIN_ONSET_DELAY).
	sky_fade_timers[pname] = 0
	local layer = build_sky_layer(0)
	skylayer.add_layer(pname, layer)
	sky_layer_refs[pname] = layer
end

heavy_rain.remove_player = function(player)
	local pname = player:get_player_name()
	remove_rain_sound(player)
	skylayer.remove_layer(pname, SKYCOLOR_LAYER)
	deactivate_for_player(pname)
end

local rain_drop_texture = "happy_weather_heavy_rain_drops.png"

local add_close_range_rain_particle = function(player)
	local offset = {front=1, back=0, top=6}
	local random_pos = hw_utils.get_random_pos(player, offset)
	local rain_texture_size_offset_y = -1

	if hw_utils.is_outdoor(random_pos, rain_texture_size_offset_y) then
		local wx, wz = 0, 0
		if breasy then
			local w = breasy.get_wind(random_pos)
			wx = w.x
			wz = w.z
		end

		minetest.add_particle({
			pos = {x=random_pos.x, y=random_pos.y, z=random_pos.z},
			velocity = {x=wx, y=-10, z=wz},
			acceleration = {x=wx * 0.1, y=-10, z=wz * 0.1},
			expirationtime = 5,
			size = 30,
			collisiondetection = true,
			collision_removal = true,
			vertical = true,
			texture = rain_drop_texture,
			playername = player:get_player_name()
		})
	end
end

local add_wide_range_rain_particle = function(player)
	local offset = {front=10, back=5, top=8}
	local random_pos = hw_utils.get_random_pos(player, offset)

	if hw_utils.is_outdoor(random_pos) then
		local wx, wz = 0, 0
		if breasy then
			local w = breasy.get_wind(random_pos)
			wx = w.x
			wz = w.z
		end

		minetest.add_particle({
			pos = {x=random_pos.x, y=random_pos.y, z=random_pos.z},
			velocity = {x=wx, y=-10, z=wz},
			acceleration = {x=wx * 0.1, y=-15, z=wz * 0.1},
			expirationtime = 5,
			size = 30,
			collisiondetection = true,
			collision_removal = true,
			vertical = true,
			texture = rain_drop_texture,
			playername = player:get_player_name()
		})
	end
end

-- Spawns rain particles scaled to `intensity` (0..1). The wide-range count
-- uses a whole-number-plus-probabilistic-remainder split so low intensities
-- still show occasional drops instead of nothing at all (e.g. intensity 0.3
-- spawns 1 drop 50% of ticks rather than always flooring to 1 or 0).
local display_rain_particles = function(player, intensity)
	if hw_utils.is_underwater(player) then
		return
	end

	if math.random() < intensity then
		add_close_range_rain_particle(player)
	end

	local base_count = 5 * intensity
	local whole = math.floor(base_count)
	local remainder = base_count - whole
	if math.random() < remainder then
		whole = whole + 1
	end
	for i = whole, 1, -1 do
		add_wide_range_rain_particle(player)
	end
end

heavy_rain.render = function(dtime, player)
	local pname = player:get_player_name()
	local now = os.time()

	-- Entry ramp: dark sky only for RAIN_ONSET_DELAY, then a linear ramp
	-- up to full intensity over RAIN_RAMP_DURATION.
	local elapsed = now - (weather_active_since or now)
	local entry_intensity = 1
	if elapsed < RAIN_ONSET_DELAY then
		entry_intensity = 0
	elseif elapsed < RAIN_ONSET_DELAY + RAIN_RAMP_DURATION then
		entry_intensity = (elapsed - RAIN_ONSET_DELAY) / RAIN_RAMP_DURATION
	end

	-- Sky fade-in: clear -> full storm, reaching 100% exactly when rain
	-- starts falling (RAIN_ONSET_DELAY), mirroring the exit fade-out below.
	local sky_entry_t = math.min(elapsed / RAIN_ONSET_DELAY, 1)

	-- Exit taper: once is_ending has started counting down, fade back out.
	local exit_intensity = 1
	local ending = ending_started_at ~= nil
	if ending then
		local taper_elapsed = now - ending_started_at
		local taper_t = math.min(taper_elapsed / EXIT_TAPER_DURATION, 1)
		exit_intensity = 1 - taper_t
	end

	-- Only touch the sky layer while an actual transition is in progress
	-- (entry fade-in or exit fade-out) -- not on every tick of steady rain.
	if ending then
		apply_sky_fade(pname, dtime, exit_intensity)
	elseif sky_entry_t < 1 then
		apply_sky_fade(pname, dtime, sky_entry_t)
	end

	local intensity = math.min(entry_intensity, exit_intensity)

	if intensity <= 0 then
		return
	end

	-- Sound: start quiet and fade in to full over the ramp window. Once
	-- running, hw_utils.update_weather_sound keeps adjusting gain for
	-- indoor/outdoor shelter as normal. When the exit taper begins, fade
	-- the sound out (one-shot per player) ahead of the storm actually ending.
	if not sound_handlers[pname] then
		sound_handlers[pname] = set_rain_sound(player, 0.05)
		-- minetest.sound_fade's second arg is a STEP (gain change per
		-- second), not a duration. Divide the gain we need to cover by
		-- how many seconds we want it to take, so this actually ramps
		-- over RAIN_RAMP_DURATION instead of snapping almost instantly.
		minetest.sound_fade(sound_handlers[pname], (1.0 - 0.05) / RAIN_RAMP_DURATION, 1.0)
	end

	if ending_started_at and not exit_fade_started[pname] then
		exit_fade_started[pname] = true
		-- Same fix: step, not duration.
		minetest.sound_fade(sound_handlers[pname], 1.0 / EXIT_TAPER_DURATION, 0.0)
	end

	sound_handlers[pname] = hw_utils.update_weather_sound(
		sound_handlers[pname], "heavy_rain", dtime, player)

	display_rain_particles(player, intensity)
end

heavy_rain.start = function()
	manual_trigger_start = true
end

heavy_rain.stop = function()
	manual_trigger_end = true
end

heavy_rain.force_stop = function()
	force_trigger_end = true
end

heavy_rain.in_area = function(position)
	if hw_utils.is_biome_frozen(position) or
		hw_utils.is_biome_dry(position) then
		return false
	end
	if position.y > -10 and position.y < 120 then
		return true
	end
	return false
end

-- Clean up bookkeeping if a player disconnects mid-weather. remove_player
-- never fires for this case since a disconnected player drops out of the
-- engine's connected-players loop before render_if_in_area runs again.
minetest.register_on_leaveplayer(function(player)
	local pname = player:get_player_name()
	local sound = sound_handlers[pname]
	if sound ~= nil then
		minetest.sound_stop(sound)
		sound_handlers[pname] = nil
		hw_utils.clear_sound_state(pname, "heavy_rain")
	end
	exit_fade_started[pname] = nil
	sky_fade_timers[pname] = nil
	sky_layer_refs[pname] = nil
	deactivate_for_player(pname)
end)

happy_weather.register_weather(heavy_rain)
