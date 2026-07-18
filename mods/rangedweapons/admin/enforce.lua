-- Runtime enforcement.
--
-- rangedweapons routes almost everything through five global functions.
-- Automatic weapons in particular fire from a globalstep in cooldown_stuff.lua
-- and never touch on_use, so wrapping item callbacks alone would leave every
-- automatic gun fully working. Wrapping the globals is the real chokepoint;
-- the callback wrappers catch the handful of items with bespoke logic
-- (the hand grenade) and block placement of the explosive barrel.

local rwa = rangedweapons_admin

local PREFIX = "rangedweapons:"
-- Chat and sound are throttled separately. Text repeated every trigger pull
-- would flood the screen, but audio repeated only every two seconds leaves an
-- automatic weapon feeling unresponsive, so the click is allowed through far
-- more often than the sentence.
local CHAT_COOLDOWN = 2.0
local SOUND_COOLDOWN = 0.4

local last_chat = {}
local last_sound = {}

local MESSAGES = {
	use        = "%s has been disabled on this server.",
	craft      = "%s can no longer be crafted on this server.",
	place      = "%s has been disabled on this server.",
	ingredient = "%s has been disabled on this server, so it cannot be used " ..
	             "as a crafting ingredient. Your materials are untouched.",
	ammo       = "%s has been disabled on this server. Rounds already loaded " ..
	             "will not fire and it cannot be loaded. Your ammunition is untouched.",
	power      = "%s has been disabled on this server, so energy weapons " ..
	             "cannot fire.",
}

--- Friendly name for an item, falling back to its item name.
local function label_of(itemname)
	local entry = rwa.registry.roots[rwa.root_of(itemname)]
	return entry and entry.label or itemname
end

--- Tell a player why nothing happened, without flooding chat when they
--- hold the trigger on an automatic weapon.
function rwa.notify(player, itemname, kind)
	if not player or not player.get_player_name then
		return
	end
	local pname = player:get_player_name()
	if pname == "" then
		return
	end

	local now = core.get_us_time() / 1000000

	-- Always to_player, never positional: the file is stereo, and a positional
	-- stereo sound makes the engine warn on every play.
	local sounded = last_sound[pname]
	if not sounded or (now - sounded) >= SOUND_COOLDOWN then
		last_sound[pname] = now
		core.sound_play("rangedweapons_empty", { to_player = pname }, true)
	end

	local chatted = last_chat[pname]
	if chatted and (now - chatted) < CHAT_COOLDOWN then
		return
	end
	last_chat[pname] = now

	core.chat_send_player(pname, core.colorize("#ff6b6b",
		MESSAGES[kind or "use"]:format(label_of(itemname))))
end

core.register_on_leaveplayer(function(player)
	local pname = player:get_player_name()
	last_chat[pname] = nil
	last_sound[pname] = nil
end)

--- Spell out the knock-on effect of switching off a crafting component.
--- Disabling one does not make dependent recipes vanish; it stops the
--- component itself being produced, which starves them once stock runs out.
function rwa.warn_if_core(pname, root, now_off)
	if not now_off then
		return
	end

	local deps = rwa.registry.dependents_of(root)
	local guns = rwa.registry.ammo_users_of(root)

	if #guns > 0 then
		local starved = rwa.registry.guns_starved_by(root)
		core.chat_send_player(pname, core.colorize("#ffb14a",
			("Heads up: %d gun%s chambered for %s. Rounds already loaded will not "):format(
				#guns, #guns == 1 and " is" or "s are", root) ..
			"fire, and it cannot be loaded."))
		if #starved > 0 then
			core.chat_send_player(pname, core.colorize("#ff6b6b",
				("%d of those gun%s now have no usable ammunition at all, though they "):format(
					#starved, #starved == 1 and "" or "s") ..
				"still show as enabled. Run /rwadmin deps " .. root .. " for the list."))
		end
	end

	if #deps == 0 then
		return
	end

	local immediate = core.settings:get_bool("rangedweapons_admin_block_ingredients", true)

	core.chat_send_player(pname, core.colorize("#ffb14a",
		("Heads up: %s is a core component. %d recipe%s use%s it, and those items "):format(
			root, #deps, #deps == 1 and "" or "s", #deps == 1 and "s" or "") ..
		(immediate
			and "can no longer be crafted as of now, even though they are still enabled. Players keep their stock; it just stops working until you re-enable this."
			or "can no longer be made once existing stock runs out — even though they are still enabled.")))
	core.chat_send_player(pname, core.colorize("#ffb14a",
		("Run /rwadmin deps %s to see the full list."):format(root)))
end

--- Is strict mode on? Strict means a disabled item is inert everywhere,
--- immediately. Off means disabling only stops the item being produced, and
--- existing stock keeps working until it runs out.
---
--- Reads the old block_ingredients key as a fallback so an existing
--- minetest.conf keeps behaving as its owner intended.
function rwa.strict()
	local v = core.settings:get_bool("rangedweapons_admin_strict")
	if v == nil then
		v = core.settings:get_bool("rangedweapons_admin_block_ingredients")
	end
	if v == nil then
		return true
	end
	return v
end

--- The ammunition currently chambered in a gun, or nil.
local function loaded_ammo(itemstack)
	if not itemstack or not itemstack.get_meta then
		return nil
	end
	local name = itemstack:get_meta():get_string("RW_ammo_name")
	if name == nil or name == "" then
		return nil
	end
	return name
end

-- Extra per-function checks. A gun can be enabled while the rounds inside it
-- are not; firing consumes the ammo, so the ammo has to be checked too.
--- Would this reload fail purely because every suitable round the player
--- holds has been disabled? If so, name the first disabled type so the
--- player is told the real reason instead of getting silence.
local function reload_blocked_by_disabling(itemstack, player)
	local def = itemstack and itemstack.get_definition and itemstack:get_definition()
	local caps = def and def.RW_gun_capabilities
	local suitable = caps and caps.suitable_ammo
	if type(suitable) ~= "table" or not player or not player.get_inventory then
		return nil
	end

	local inv = player:get_inventory()
	if not inv then
		return nil
	end

	local held_disabled = nil
	for i = 1, inv:get_size("main") do
		local held = inv:get_stack("main", i):get_name()
		if held ~= "" then
			for _, ammo in pairs(suitable) do
				local name = type(ammo) == "table" and ammo[1] or ammo
				if held == name then
					if rwa.is_disabled(name) then
						held_disabled = held_disabled or name
					else
						-- an enabled round exists; reload will succeed
						return nil
					end
				end
			end
		end
	end
	return held_disabled
end

local EXTRA_CHECKS = {
	rangedweapons_shoot_gun = function(itemstack)
		local ammo = loaded_ammo(itemstack)
		if ammo and rwa.is_disabled(ammo) then
			return ammo, "ammo"
		end
	end,
	rangedweapons_shoot_powergun = function()
		if rwa.is_disabled("rangedweapons:power_particle") then
			return "rangedweapons:power_particle", "power"
		end
	end,
}

-- Functions that double as the way a player gets ammunition back out of a gun.
-- When the player is sneaking these are an unload, and an unload is always
-- permitted: a disabled item must not hold someone's property hostage.
local RETRIEVAL = {
	rangedweapons_reload_gun = true,
	rangedweapons_single_load_gun = true,
}

local function is_unloading(player)
	return player and player.get_player_control and player:get_player_control().sneak
end

--- Wrap a rangedweapons global so it bails out for disabled items.
local function guard_global(fname)
	local original = rawget(_G, fname)
	if type(original) ~= "function" then
		core.log("warning", ("[rangedweapons_admin] %s not found; " ..
			"rangedweapons may have changed. Enforcement may be incomplete."):format(fname))
		return
	end

	local extra = EXTRA_CHECKS[fname]

	rawset(_G, fname, function(itemstack, player, ...)
		if RETRIEVAL[fname] and is_unloading(player) then
			return original(itemstack, player, ...)
		end

		if itemstack and itemstack.get_name and rwa.is_disabled(itemstack:get_name()) then
			rwa.notify(player, itemstack:get_name(), "use")
			return
		end

		if extra and rwa.strict() then
			local blocked, kind = extra(itemstack, player)
			if blocked then
				rwa.notify(player, blocked, kind)
				return
			end
		end

		if RETRIEVAL[fname] and rwa.strict() then
			local starved = reload_blocked_by_disabling(itemstack, player)
			if starved then
				rwa.notify(player, starved, "ammo")
				return
			end
		end

		return original(itemstack, player, ...)
	end)
end

local function guard_item_callbacks()
	for name, def in pairs(core.registered_items) do
		if name:sub(1, #PREFIX) == PREFIX then
			local override = {}
			local touched = false

			local orig_use = def.on_use
			if orig_use then
				touched = true
				override.on_use = function(itemstack, user, pointed_thing)
					if rwa.is_disabled(itemstack:get_name()) then
						rwa.notify(user, itemstack:get_name(), "use")
						return itemstack
					end
					return orig_use(itemstack, user, pointed_thing)
				end
			end

			local orig_secondary = def.on_secondary_use
			if orig_secondary then
				touched = true
				local is_gun = def.RW_gun_capabilities ~= nil
				override.on_secondary_use = function(itemstack, user, pointed_thing)
					-- Retrieval exception, at the layer the engine actually
					-- calls. Sneak + right-click on a gun is an unload, and
					-- unloading must work on disabled guns, otherwise disabled
					-- ammunition is stuck inside them. The original callback
					-- routes to the unload itself.
					if is_gun and is_unloading(user) then
						return orig_secondary(itemstack, user, pointed_thing)
					end

					if rwa.is_disabled(itemstack:get_name()) then
						rwa.notify(user, itemstack:get_name(), "use")
						return itemstack
					end
					return orig_secondary(itemstack, user, pointed_thing)
				end
			end

			-- Only guard placement where placement is meaningful: nodes, or
			-- items that define their own handler. Leaving other items alone
			-- avoids changing default right-click behaviour.
			local orig_place = def.on_place
			if orig_place or core.registered_nodes[name] then
				touched = true
				override.on_place = function(itemstack, placer, pointed_thing, ...)
					if rwa.is_disabled(itemstack:get_name()) then
						rwa.notify(placer, itemstack:get_name(), "place")
						return itemstack
					end
					if orig_place then
						return orig_place(itemstack, placer, pointed_thing, ...)
					end
					return core.item_place(itemstack, placer, pointed_thing, ...)
				end
			end

			if touched then
				core.override_item(name, override)
			end
		end
	end
end

rwa.global_names = {
	"rangedweapons_shoot_gun",
	"rangedweapons_shoot_powergun",
	"rangedweapons_yeet",
	"rangedweapons_reload_gun",
	"rangedweapons_single_load_gun",
}

--- Take over the parent mod's neutral hooks.
local function install_hooks()
	-- Deliberately silent: the reload scan probes this once per inventory
	-- slot per accepted ammo type, including slots it merely passes over on
	-- the way to ammo that will load fine. Feedback for a reload that fails
	-- because of disabling comes from the reload wrapper instead, which can
	-- see the whole picture.
	rangedweapons_ammo_allowed = function(ammo_name, _)
		if not rwa.strict() then
			return true
		end
		return not rwa.is_disabled(ammo_name)
	end

	rangedweapons_item_active = function(itemname)
		if not rwa.strict() then
			return true
		end
		return not rwa.is_disabled(itemname)
	end
end

function rwa.install_enforcement()
	install_hooks()
	for _, fname in ipairs(rwa.global_names) do
		guard_global(fname)
	end
	guard_item_callbacks()
end

--- React to one item's state changing.
---
--- Deliberately mutates no engine state: no core.override_item, no craft-table
--- changes. Runtime overrides are what the engine logs as unsupported ("can
--- cause problems related to data inconsistency"), and a bulk toggle performed
--- dozens back to back before two hard crashes. Enforcement never depended on
--- them — the guards are installed once at startup and toggling only flips a
--- Lua table — so all that is needed here is to bring the craft guide's
--- listing back in step.
---
--- Bulk operations suppress this and reconcile once at the end, keeping a mass
--- toggle linear rather than quadratic.
function rwa.apply(_)
	if rwa.batching then
		return
	end
	rwa.crafting.resync()
end


