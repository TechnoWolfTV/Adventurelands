
-- Translation support & localize math functions

local S = core.get_translator("stamina")
local math_max, math_min = math.max, math.min
local math_floor, math_random = math.floor, math.random

-- clamp values helper

local function clamp(val, minval, maxval)
	return math_max(math_min(val, maxval), minval)
end

-- global

stamina = {
	players = {}, mod = "redo",
	-- time in seconds after that 1 stamina point is taken
	TICK = tonumber(core.settings:get("stamina_tick")) or 800,
	-- stamina ticks won't reduce stamina below this level
	TICK_MIN = 4,
	-- time in seconds after player gets healed/damaged
	HEALTH_TICK = 4,
	-- time in seconds after the movement is checked
	MOVE_TICK = 0.5,
	-- time in seconds after player is poisoned
	POISON_TICK = 1.25,
	-- exhaustion increased this value after digged node
	EXHAUST_DIG = 2,
	-- after placing node
	EXHAUST_PLACE = 1,
	-- if player movement detected
	EXHAUST_MOVE = 1.5,
	-- if jumping
	EXHAUST_JUMP = 5,
	-- if player crafts
	EXHAUST_CRAFT = 2,
	-- if player punches another player
	EXHAUST_PUNCH = 40,
	-- at what exhaustion player saturation gets lowered
	EXHAUST_LVL = 160,
	-- number of HP player gets healed after stamina.HEALTH_TICK
	HEAL = 1,
	-- lower level of saturation needed to get healed
	HEAL_LVL = 5,
	-- number of HP player gets damaged by stamina after stamina.HEALTH_TICK
	STARVE = 1,
	-- level of staturation that causes starving
	STARVE_LVL = 3,
	-- hud bar extends only to 20
	VISUAL_MAX = 20,
	-- how much faster players can run if satiated.
	SPRINT_SPEED = clamp(tonumber(
			core.settings:get("stamina_sprint_speed")) or 0.5, 0.0, 1.0),
	-- how much higher player can jump if satiated
	SPRINT_JUMP  = clamp(tonumber(
			core.settings:get("stamina_sprint_jump")) or 0.1, 0.0, 1.0),
	-- how fast to drain satation while sprinting (0-1)
	SPRINT_DRAIN  = clamp(tonumber(
			core.settings:get("stamina_sprint_drain")) or 0.35, 0.0, 1.0),
	enable_sprint = core.settings:get_bool("sprint") ~= false,
	enable_sprint_particles = core.settings:get_bool("sprint_particles") ~= false,
	-- fov change
	fov_change = tonumber(minetest.settings:get("stamina_fov_multiplier") or 0.9),
	-- double tap time
	double_tap_time = 0.8
}

-- are we a real player ?

local function is_player(player)

	if player and type(player) == "userdata" and core.is_player(player) then
		return true
	end
end

-- grab stamina level

function stamina.get_saturation(player)

	-- are we a real player?
	if not is_player(player) then return end

	local meta = player:get_meta()
	local level = meta and meta:get_string("stamina:level")

	if level then return tonumber(level) end
end

-- is player stamina & damage enabled

local stamina_enabled = core.settings:get_bool("enable_stamina") ~= false
local damage_enabled = core.settings:get_bool("enable_damage")

-- update stamina level

function stamina.update_saturation(player, level)

	-- pipeworks fake player check
	if not is_player(player) then return end

	local old = stamina.get_saturation(player)

	if level == old then return end -- To suppress HUD update

	-- players without interact priv cannot eat
	if not core.check_player_privs(player, {interact = true}) then return end

	local meta = player and player:get_meta() ; if not meta then return end

	meta:set_string("stamina:level", level)

	player:hud_change(stamina.players[player:get_player_name()].hud_id,
			"number", math_min(stamina.VISUAL_MAX, level))
end

-- global function for mods to amend stamina level

function stamina.change_saturation(player, change)

	local name = player:get_player_name()

	if not damage_enabled or not name or not change or change == 0 then
		return
	end

	local level = stamina.get_saturation(player) + change

	level = clamp(level, 0, stamina.VISUAL_MAX)

	stamina.update_saturation(player, level)

	return true
end

stamina.change = stamina.change_saturation -- for backwards compatibility

-- check for poisoned player

function stamina.is_poisoned(player)

	local name = player and player:get_player_name()
	local data = stamina.players[name]

	return data and data.poisoned > 0
end

-- reduce stamina level

function stamina.exhaust_player(player, v)

	if not is_player(player) or not player.set_attribute then return end

	local name = player:get_player_name()
	local data = stamina.players[name]

	if data then

		local exhaustion = data.exhaustion + v

		if exhaustion > stamina.EXHAUST_LVL then

			exhaustion = 0

			local h = stamina.get_saturation(player)

			if h > 0 then stamina.update_saturation(player, h - 1) end
		end

		data.exhaustion = exhaustion
	end
end

-- mod check

local mod_monoids = core.get_modpath("player_monoids")
local mod_pova = core.get_modpath("pova")
local mod_playerphysics = core.get_modpath("playerphysics")

-- attach helpers

local is_54 = core.has_feature("direct_velocity_on_players")

local function is_attached(player)

	if player:get_attach() then return true end

	if is_54 then -- check attached children entities that would disallow sprinting

		for _, obj in pairs(player:get_children()) do

			local ent = obj:get_luaentity() or {}

			if ent.name == "hangglider:glider" then return true end
		end
	end
end

-- turn sprint on/off

function stamina.set_sprinting(player, sprinting)

	if not player or is_attached(player) then return end

	local name = player:get_player_name()
	local data = stamina.players[name]
	local def = player:get_physics_override() -- get player physics

--print ("---", def.speed, def.jump)

	if sprinting == true and not data.sprint then

		if mod_pova then

			pova.add_override(name, "sprint", {
					speed = stamina.SPRINT_SPEED, jump = stamina.SPRINT_JUMP})

			pova.do_override(player)

		elseif mod_monoids then

			player_monoids.speed:add_change(
					player, def.speed + stamina.SPRINT_SPEED, "stamina:speed")

			player_monoids.jump:add_change(
					player, def.jump + stamina.SPRINT_JUMP, "stamina:jump")

		elseif mod_playerphysics then

			playerphysics.add_physics_factor(player, "speed", "stamina:sprint",
					def.speed + stamina.SPRINT_SPEED)

			playerphysics.add_physics_factor(player, "jump", "stamina:jump",
					def.jump + stamina.SPRINT_JUMP)
		else
			player:set_physics_override({
				speed = def.speed + stamina.SPRINT_SPEED,
				jump = def.jump + stamina.SPRINT_JUMP,
			})
		end

		data.sprint = true

		if stamina.fov_change ~= 0 then
			player:set_fov(stamina.fov_change, true, 0.2)
		end

	elseif sprinting == false and data.sprint then

		if mod_pova then

			pova.del_override(name, "sprint")
			pova.do_override(player)

		elseif mod_monoids then

			player_monoids.speed:del_change(player, "stamina:speed")
			player_monoids.jump:del_change(player, "stamina:jump")

		elseif mod_playerphysics then

			playerphysics.remove_physics_factor(player, "stamina:sprint")
			playerphysics.remove_physics_factor(player, "stamina:jump")

		else
			player:set_physics_override({
				speed = def.speed - stamina.SPRINT_SPEED,
				jump = def.jump - stamina.SPRINT_JUMP,
			})
		end

		data.sprint = nil

		if stamina.fov_change ~= 0 then
			player:set_fov(1, true, 0.4)
		end
	end
end

-- particle effect when eating

local function head_particle(player, texture)

	local prop = player and player:get_properties() ; if not prop then return end
	local pos = player:get_pos() ; pos.y = pos.y + (prop.eye_height or 1.23)
	local dir = player:get_look_dir()

	core.add_particlespawner({
		amount = 5,
		time = 0.1,
		minpos = pos,
		maxpos = pos,
		minvel = {x = dir.x - 1, y = dir.y, z = dir.z - 1},
		maxvel = {x = dir.x + 1, y = dir.y, z = dir.z + 1},
		minacc = {x = 0, y = -5, z = 0},
		maxacc = {x = 0, y = -9, z = 0},
		minexptime = 1,
		maxexptime = 1,
		minsize = 1,
		maxsize = 2,
		texture = texture
	})
end

-- drunk check

local function drunk_tick()

	for _,player in pairs(core.get_connected_players()) do

		local name = player and player:get_player_name()
		local data = stamina.players[name]

		if data and data.drunk then

			-- play burp sound every 20 seconds when drunk
			local num = data.drunk

			if num and num > 0 and math_floor(num / 20) == num / 20 then

				head_particle(player, "bubble.png")

				core.sound_play("stamina_burp", {to_player = name, gain = 0.7}, true)
			end

			data.drunk = data.drunk - 1

			if data.drunk < 1 then

				data.drunk = nil
				data.units = 0

				if not data.poisoned then
					player:hud_change(data.hud_id, "text", "stamina_hud_fg.png")
				end
			end

			-- effect only works when not riding boat/cart/horse etc.
			if not player:get_attach() then

				local yaw = player:get_look_horizontal() + math_random(-0.5, 0.5)

				player:set_look_horizontal(yaw)
			end
		end
	end
end

-- health check

local function health_tick()

	for _,player in pairs(core.get_connected_players()) do

		local name = player and player:get_player_name()
		local data = stamina.players[name]

		if data then

			local air = player:get_breath() or 0
			local hp = player:get_hp()
			local h = stamina.get_saturation(player)

			-- damage player by 1 hp if saturation is < 2
			if h and h < stamina.STARVE_LVL and hp > 0 then
				player:set_hp(hp - stamina.STARVE, {hunger = true})
			end

			-- don't heal if drowning or dead or poisoned
			if h and h >= stamina.HEAL_LVL and h >= hp and hp > 0 and air > 0
			and not data.poisoned then

				player:set_hp(hp + stamina.HEAL)

				stamina.update_saturation(player, h - 1)
			end
		end
	end
end

-- movement check

local function action_tick()

	for _,player in pairs(core.get_connected_players()) do

		local controls = player and player:get_player_control()

		if controls then

			if controls.jump then
				stamina.exhaust_player(player, stamina.EXHAUST_JUMP)

			elseif controls.up or controls.down or controls.left or controls.right then
				stamina.exhaust_player(player, stamina.EXHAUST_MOVE)
			end
		end

		--- START sprint
		if stamina.enable_sprint then

			local name = player and player:get_player_name()
			local data = stamina.players[name]

			-- check if player can sprint (stamina must be over 6 points)
			if data and not data.poisoned and not data.drunk
			and controls and controls.up and (controls.aux1 or data.double_tap)
			and not core.check_player_privs(player, {fast = true})
			and stamina.get_saturation(player) > 6 then

				stamina.set_sprinting(player, true)

				-- create particles behind player when sprinting
				if stamina.enable_sprint_particles then

					local pos = player:get_pos()
					local node = core.get_node({x = pos.x, y = pos.y - 1, z = pos.z})

					if node.name ~= "air" then

						core.add_particlespawner({
							amount = 5,
							time = 0.5,
							minpos = {x = -0.3, y = 0.1, z = -0.3},
							maxpos = {x = 0.3, y = 0.1, z = 0.3},
							minvel = {x = 0, y = 4, z = 0},
							maxvel = {x = 0, y = 4, z = 0},
							minacc = {x = 0, y = -13, z = 0},
							maxacc = {x = 0, y = -13, z = 0},
							minexptime = 0.1,
							maxexptime = 1,
							minsize = 0.5,
							maxsize = 1.5,
							vertical = false,
							collisiondetection = false,
							attached = player,
							texture = "stamina_sprint_particle.png"
						})
					end
				end

				-- Lower the player's stamina when sprinting
				local level = stamina.get_saturation(player)

				stamina.update_saturation(player,
						level - (stamina.SPRINT_DRAIN * stamina.MOVE_TICK))

			elseif name then
				stamina.set_sprinting(player, false)
				data.double_tap = false
			end
		end
		-- END sprint
	end
end

-- poisoned check

local function poison_tick()

	for _,player in pairs(core.get_connected_players()) do

		local name = player and player:get_player_name()
		local data = stamina.players[name]

		if data and data.poisoned and data.poisoned > 0 then

			data.poisoned = data.poisoned - 1

			local hp = player:get_hp() - 1

			head_particle(player, "stamina_poison_particle.png")

			if hp > 0 then
				player:set_hp(hp, {poison = true})
			end

		elseif data and data.poisoned then

			if not data.drunk then
				player:hud_change(data.hud_id, "text", "stamina_hud_fg.png")
			end

			data.poisoned = nil
		end
	end
end

-- stamina check

local function stamina_tick()

	for _,player in pairs(core.get_connected_players()) do

		local h = player and stamina.get_saturation(player)

		if h and h > stamina.TICK_MIN then
			stamina.update_saturation(player, h - 1)
		end

		local name = player and player:get_player_name()
		local data = stamina.players[name]

		if data and data.units and data.units > 0 then
			data.units = data.units - 1
		end
	end
end

-- check for double tap forward (thanks xXOsielXx)

local function check_for_double_tap(controls, data, DOUBLE_TAP_TIME)

	if controls and controls.up and not data.was_pressing_forward and not controls.down
	and not controls.sneak and not data.sprint then

		local current_time = minetest.get_us_time() / 1e6
		if (current_time - (data.last_key_time or 0)) < stamina.double_tap_time then
			return true
		end
		data.double_tap = false
		data.last_key_time = current_time
	end
end

-- check if player double taps

local function double_tap_tick()

	for _, player in pairs(minetest.get_connected_players()) do

		local name = player and player:get_player_name()
		local data = stamina.players[name]

		if data then

			local control = player:get_player_control()
			local double_tap = check_for_double_tap(control, data, DOUBLE_TAP_TIME)

			if double_tap then
				data.double_tap = true
			end

			data.was_pressing_forward = control.up
		end
	end
end

-- Time based stamina functions

local stamina_timer, health_timer, action_timer, poison_timer, drunk_timer = 0,0,0,0,0

local function stamina_globaltimer(dtime)

	double_tap_tick()

	stamina_timer = stamina_timer + dtime
	health_timer = health_timer + dtime
	action_timer = action_timer + dtime
	poison_timer = poison_timer + dtime
	drunk_timer = drunk_timer + dtime

	-- simulate drunk walking (thanks LumberJ)
	if drunk_timer > 1.0 then drunk_tick() ; drunk_timer = 0 end

	-- hurt player when poisoned
	if poison_timer > stamina.POISON_TICK then poison_tick() ; poison_timer = 0 end

	-- sprint control and particle animation
	if action_timer > stamina.MOVE_TICK then action_tick() ; action_timer = 0 end

	-- lower saturation by 1 point after stamina.TICK
	if stamina_timer > stamina.TICK then stamina_tick() ; stamina_timer = 0 end

	-- heal or damage player, depending on saturation
	if health_timer > stamina.HEALTH_TICK then health_tick() ; health_timer = 0 end
end

-- stamina and eating functions disabled if damage is disabled

if damage_enabled and core.settings:get_bool("enable_stamina") ~= false then

	-- override core.do_item_eat() so we can redirect hp_change to stamina
	core.do_item_eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)

		if not is_player(user) then return end -- abort if called by fake player

		local old_itemstack = itemstack

		itemstack = stamina.eat(
				hp_change, replace_with_item, itemstack, user, pointed_thing)

		for _, callback in pairs(core.registered_on_item_eats) do

			local result = callback(hp_change, replace_with_item, itemstack, user,
					pointed_thing, old_itemstack)

			if result then return result end
		end

		return itemstack
	end

	-- not local since it's called from within core context
	function stamina.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)

		if not itemstack or not user then return itemstack end

		local level = stamina.get_saturation(user) or 0

		if level >= stamina.VISUAL_MAX then return itemstack end

		local name = user:get_player_name()
		local data = stamina.players[name]

		if hp_change > 0 then

			stamina.update_saturation(user, level + hp_change)

		elseif hp_change < 0 then

			-- assume hp_change < 0
			user:hud_change(data.hud_id, "text", "stamina_hud_poison.png")

			data.poisoned = -hp_change
		end

		-- if {drink=1} group set then use sip sound instead of default eat
		local snd, gain = "stamina_eat", 0.7
		local itemname = itemstack:get_name()
		local def = core.registered_items[itemname]

		if def and def.groups and def.groups.drink then
			snd = "stamina_sip" ; gain = 1.0
		end

		core.sound_play(snd, {to_player = name, gain = gain}, true)

		-- particle effect when eating
		local texture  = core.registered_items[itemname].inventory_image

		texture = texture or core.registered_items[itemname].wield_image

		head_particle(user, texture)

		-- if player drinks milk then stop poison and being drunk
		local item_name = itemstack:get_name() or ""

		if item_name == "mobs:bucket_milk"
		or item_name == "mobs:glass_milk"
		or item_name == "farming:soy_milk" then
			data.poisoned = 0 ; data.drunk = 0
		end

		itemstack:take_item()

		if replace_with_item then

			if itemstack:is_empty() then
				itemstack:add_item(replace_with_item)
			else
				local inv = user:get_inventory()

				if inv:room_for_item("main", {name = replace_with_item}) then
					inv:add_item("main", replace_with_item)
				else
					local pos = user:get_pos()

					if pos then core.add_item(pos, replace_with_item) end
				end
			end
		end

		-- check for alcohol
		local units = core.registered_items[itemname].groups
				and core.registered_items[itemname].groups.alcohol or 0

		if units > 0 then

			data.units = (data.units or 0) + 1

			if data.units > 3 then

				data.drunk = 60 ; data.units = 0

				user:hud_change(data.hud_id, "text", "stamina_hud_poison.png")

				core.chat_send_player(name,
						core.get_color_escape_sequence("#1eff00")
						.. S("You suddenly feel tipsy!"))
			end
		end

		return itemstack
	end

	core.register_on_joinplayer(function(player)

		if not player then return end

		local level = stamina.VISUAL_MAX -- TODO

		if stamina.get_saturation(player) then
			level = math_min(stamina.get_saturation(player), stamina.VISUAL_MAX)
		end

		local meta = player:get_meta()

		if meta then meta:set_string("stamina:level", level) end

		local name = player:get_player_name()
		local hud_style = core.has_feature("hud_def_type_field")
		local hud_tab = {
			name = "stamina",
			position = {x = 0.5, y = 1},
			size = {x = 24, y = 24},
			text = "stamina_hud_fg.png",
			number = level,
			alignment = {x = -1, y = -1},
			offset = {x = -266, y = -110},
			max = 0
		}

		if hud_style then
			hud_tab["type"] = "statbar"
		else
			hud_tab["hud_elem_type"] = "statbar"
		end

		local id = player:hud_add(hud_tab)

		stamina.players[name] = {
			hud_id = id, exhaustion = 0, poisoned = nil, drunk = nil, sprint = nil}
	end)

	core.register_on_respawnplayer(function(player)

		local name = player and player:get_player_name() ; if not name then return end
		local data = stamina.players[name]

		if data.poisoned or data.drunk then
			player:hud_change(data.hud_id, "text", "stamina_hud_fg.png")
		end

		data.exhaustion = 0
		data.poisoned = nil
		data.drunk = nil
		data.sprint = nil

		stamina.update_saturation(player, stamina.VISUAL_MAX)

		if stamina.fov_change ~= 0 then
			player:set_fov(1, true, 0.2)
		end
	end)

	core.register_globalstep(stamina_globaltimer)

	core.register_on_placenode(function(pos, oldnode, player, ext)
		stamina.exhaust_player(player, stamina.EXHAUST_PLACE)
	end)

	core.register_on_dignode(function(pos, oldnode, player, ext)
		stamina.exhaust_player(player, stamina.EXHAUST_DIG)
	end)

	core.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
		stamina.exhaust_player(player, stamina.EXHAUST_CRAFT)
	end)

	core.register_on_punchplayer(function(player, hitter, tflp, toolcaps, dir, damage)
		stamina.exhaust_player(hitter, stamina.EXHAUST_PUNCH)
	end)

else -- create player table on join
	core.register_on_joinplayer(function(player)

		if player then
			stamina.players[player:get_player_name()] = {
				poisoned = nil, sprint = nil, drunk = nil, exhaustion = 0}
		end
	end)
end

-- clear when player leaves

core.register_on_leaveplayer(function(player)

	if player then
		stamina.players[player:get_player_name()] = nil
	end
end)

-- add lucky blocks (if damage and stamina active)

if core.get_modpath("lucky_block")
and core.settings:get_bool("enable_damage")
and core.settings:get_bool("enable_stamina") ~= false then

	local MP = core.get_modpath(core.get_current_modname())

	dofile(MP .. "/lucky_block.lua")
end

print("[MOD] Stamina loaded")
