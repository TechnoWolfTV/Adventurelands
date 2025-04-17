
-- Translation support & localize math functions

local S = minetest.get_translator("stamina")
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
	TICK = tonumber(minetest.settings:get("stamina_tick")) or 800,
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
	-- .. after digging node
	EXHAUST_PLACE = 1,
	-- .. if player movement detected
	EXHAUST_MOVE = 1.5,
	-- .. if jumping
	EXHAUST_JUMP = 5,
	-- .. if player crafts
	EXHAUST_CRAFT = 2,
	-- .. if player punches another player
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
			minetest.settings:get("stamina_sprint_speed")) or 0.5, 0.0, 1.0),
	-- how much higher player can jump if satiated
	SPRINT_JUMP  = clamp(tonumber(
			minetest.settings:get("stamina_sprint_jump")) or 0.1, 0.0, 1.0),
	-- how fast to drain satation while sprinting (0-1)
	SPRINT_DRAIN  = clamp(tonumber(
			minetest.settings:get("stamina_sprint_drain")) or 0.35, 0.0, 1.0),
	enable_sprint = minetest.settings:get_bool("sprint") ~= false,
	enable_sprint_particles = minetest.settings:get_bool("sprint_particles") ~= false
}

-- are we a real player ?

local function is_player(player)

	if player and type(player) == "userdata" and minetest.is_player(player) then
		return true
	end
end

-- grab stamina level

function stamina.get_saturation(player)

	-- are we a real player?
	if not is_player(player) then return nil end

	local meta = player:get_meta()
	local level = meta and meta:get_string("stamina:level")

	if level then return tonumber(level) end

	return nil
end

-- is player stamina & damage enabled

local stamina_enabled = minetest.settings:get_bool("enable_stamina") ~= false
local damage_enabled = minetest.settings:get_bool("enable_damage")

-- update stamina level

function stamina.update_saturation(player, level)

	-- pipeworks fake player check
	if not is_player(player) then return nil end

	local old = stamina.get_saturation(player)

	if level == old then return end -- To suppress HUD update

	-- players without interact priv cannot eat
	if not minetest.check_player_privs(player, {interact = true}) then return end

	local meta = player and player:get_meta() ; if not meta then return end

	meta:set_string("stamina:level", level)

	player:hud_change(
		stamina.players[player:get_player_name()].hud_id,
		"number",
		math_min(stamina.VISUAL_MAX, level)
	)
end

-- global function for mods to amend stamina level

function stamina.change_saturation(player, change)

	local name = player:get_player_name()

	if not damage_enabled or not name or not change or change == 0 then
		return false
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

	return name and stamina.players[name] and stamina.players[name].poisoned
			and stamina.players[name].poisoned > 0
end

-- reduce stamina level

function stamina.exhaust_player(player, v)

	if not is_player(player) or not player.set_attribute then return end

	local name = player:get_player_name() ; if not name then return end

	local exhaustion = stamina.players[name].exhaustion + v

	if exhaustion > stamina.EXHAUST_LVL then

		exhaustion = 0

		local h = stamina.get_saturation(player)

		if h > 0 then stamina.update_saturation(player, h - 1) end
	end

	stamina.players[name].exhaustion = exhaustion
end

-- mod check

local monoids = minetest.get_modpath("player_monoids")
local pova_mod = minetest.get_modpath("pova")

-- turn sprint on/off

function stamina.set_sprinting(player, sprinting)

	if not player then return end

	local name = player:get_player_name()

	-- get player physics
	local def = player:get_physics_override()

--print ("---", def.speed, def.jump)

	if sprinting == true and not stamina.players[name].sprint then

		if pova_mod then

			pova.add_override(name, "sprint", {
					speed = stamina.SPRINT_SPEED, jump = stamina.SPRINT_JUMP})

			pova.do_override(player)

			stamina.players[name].sprint = true

		elseif monoids then

			stamina.players[name].sprint = player_monoids.speed:add_change(
					player, def.speed + stamina.SPRINT_SPEED)

			stamina.players[name].jump = player_monoids.jump:add_change(
					player, def.jump + stamina.SPRINT_JUMP)
		else
			player:set_physics_override({
				speed = def.speed + stamina.SPRINT_SPEED,
				jump = def.jump + stamina.SPRINT_JUMP,
			})

			stamina.players[name].sprint = true
		end

	elseif sprinting == false
	and stamina.players[name] and stamina.players[name].sprint then

		if pova_mod then

			pova.del_override(name, "sprint")
			pova.do_override(player)

			stamina.players[name].sprint = nil

		elseif monoids then

			player_monoids.speed:del_change(player, stamina.players[name].sprint)
			player_monoids.jump:del_change(player, stamina.players[name].jump)

			stamina.players[name].sprint = nil
			stamina.players[name].jump = nil

		else
			player:set_physics_override({
				speed = def.speed - stamina.SPRINT_SPEED,
				jump = def.jump - stamina.SPRINT_JUMP,
			})

			stamina.players[name].sprint = nil
		end
	end
end

-- particle effect when eating

local function head_particle(player, texture)

	local prop = player and player:get_properties() ; if not prop then return end
	local pos = player:get_pos() ; pos.y = pos.y + (prop.eye_height or 1.23) -- mouth level
	local dir = player:get_look_dir()

	minetest.add_particlespawner({
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

	for _,player in pairs(minetest.get_connected_players()) do

		local name = player and player:get_player_name()

		if name and stamina.players[name] and stamina.players[name].drunk then

			-- play burp sound every 20 seconds when drunk
			local num = stamina.players[name].drunk

			if num and num > 0 and math_floor(num / 20) == num / 20 then

				head_particle(player, "bubble.png")

				minetest.sound_play("stamina_burp",
						{to_player = name, gain = 0.7}, true)
			end

			stamina.players[name].drunk = stamina.players[name].drunk - 1

			if stamina.players[name].drunk < 1 then

				stamina.players[name].drunk = nil
				stamina.players[name].units = 0

				if not stamina.players[name].poisoned then

					player:hud_change(stamina.players[name].hud_id,
							"text", "stamina_hud_fg.png")
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

	for _,player in pairs(minetest.get_connected_players()) do

		local name = player and player:get_player_name()

		if name then

			local air = player:get_breath() or 0
			local hp = player:get_hp()
			local h = stamina.get_saturation(player)

			-- damage player by 1 hp if saturation is < 2
			if h and h < stamina.STARVE_LVL and hp > 0 then
				player:set_hp(hp - stamina.STARVE, {hunger = true})
			end

			-- don't heal if drowning or dead or poisoned
			if h and h >= stamina.HEAL_LVL and h >= hp and hp > 0 and air > 0
			and not stamina.players[name].poisoned then

				player:set_hp(hp + stamina.HEAL)

				stamina.update_saturation(player, h - 1)
			end
		end
	end
end

-- movement check

local function action_tick()

	for _,player in pairs(minetest.get_connected_players()) do

		local controls = player and player:get_player_control()

		-- Determine if the player is walking or jumping
		if controls then

			if controls.jump then
				stamina.exhaust_player(player, stamina.EXHAUST_JUMP)

			elseif controls.up or controls.down or controls.left or controls.right then
				stamina.exhaust_player(player, stamina.EXHAUST_MOVE)
			end
		end

		--- START sprint
		if stamina.enable_sprint then

			local name = is_player(player) and player:get_player_name()

			-- check if player can sprint (stamina must be over 6 points)
			if name
			and stamina.players[name]
			and not stamina.players[name].poisoned
			and not stamina.players[name].drunk
			and controls and controls.aux1 and controls.up
			and not minetest.check_player_privs(player, {fast = true})
			and stamina.get_saturation(player) > 6 then

				stamina.set_sprinting(player, true)

				-- create particles behind player when sprinting
				if stamina.enable_sprint_particles then

					local pos = player:get_pos()
					local node = minetest.get_node({
						x = pos.x,
						y = pos.y - 1,
						z = pos.z
					})

					if node.name ~= "air" then

						minetest.add_particlespawner({
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
			end
		end
		-- END sprint
	end
end

-- poisoned check

local function poison_tick()

	for _,player in pairs(minetest.get_connected_players()) do

		local name = player and player:get_player_name()

		if name
		and stamina.players[name]
		and stamina.players[name].poisoned
		and stamina.players[name].poisoned > 0 then

			stamina.players[name].poisoned = stamina.players[name].poisoned - 1

			local hp = player:get_hp() - 1

			head_particle(player, "stamina_poison_particle.png")

			if hp > 0 then
				player:set_hp(hp, {poison = true})
			end

		elseif name and stamina.players[name] and stamina.players[name].poisoned then

			if not stamina.players[name].drunk then

				player:hud_change(stamina.players[name].hud_id,
						"text", "stamina_hud_fg.png")
			end

			stamina.players[name].poisoned = nil
		end
	end
end

-- stamina check

local function stamina_tick()

	for _,player in pairs(minetest.get_connected_players()) do

		local h = player and stamina.get_saturation(player)

		if h and h > stamina.TICK_MIN then
			stamina.update_saturation(player, h - 1)
		end
	end
end

-- Time based stamina functions

local stamina_timer, health_timer, action_timer, poison_timer, drunk_timer = 0,0,0,0,0

local function stamina_globaltimer(dtime)

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

if damage_enabled and minetest.settings:get_bool("enable_stamina") ~= false then

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

		if hp_change > 0 then

			stamina.update_saturation(user, level + hp_change)

		elseif hp_change < 0 then

			-- assume hp_change < 0
			user:hud_change(stamina.players[name].hud_id, "text", "stamina_hud_poison.png")

			stamina.players[name].poisoned = -hp_change
		end

		-- if {drink=1} group set then use sip sound instead of default eat
		local snd, gain = "stamina_eat", 0.7
		local itemname = itemstack:get_name()
		local def = minetest.registered_items[itemname]

		if def and def.groups and def.groups.drink then
			snd = "stamina_sip" ; gain = 1.0
		end

		minetest.sound_play(snd, {to_player = name, gain = gain}, true)

		-- particle effect when eating
		local texture  = minetest.registered_items[itemname].inventory_image

		texture = texture or minetest.registered_items[itemname].wield_image

		head_particle(user, texture)

		-- if player drinks milk then stop poison and being drunk
		local item_name = itemstack:get_name() or ""

		if item_name == "mobs:bucket_milk"
		or item_name == "mobs:glass_milk"
		or item_name == "farming:soy_milk" then

			stamina.players[name].poisoned = 0
			stamina.players[name].drunk = 0
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
		local units = minetest.registered_items[itemname].groups
				and minetest.registered_items[itemname].groups.alcohol or 0

		if units > 0 then

			stamina.players[name].units = (stamina.players[name].units or 0) + 1

			if stamina.players[name].units > 3 then

				stamina.players[name].drunk = 60
				stamina.players[name].units = 0

				user:hud_change(stamina.players[name].hud_id, "text",
						"stamina_hud_poison.png")

				minetest.chat_send_player(name,
						minetest.get_color_escape_sequence("#1eff00")
						.. S("You suddenly feel tipsy!"))
			end
		end

		return itemstack
	end

	minetest.register_on_joinplayer(function(player)

		if not player then return end

		local level = stamina.VISUAL_MAX -- TODO

		if stamina.get_saturation(player) then
			level = math_min(stamina.get_saturation(player), stamina.VISUAL_MAX)
		end

		local meta = player:get_meta()

		if meta then meta:set_string("stamina:level", level) end

		local name = player:get_player_name()
		local hud_style = minetest.has_feature("hud_def_type_field")
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
			hud_id = id,
			exhaustion = 0,
			poisoned = nil,
			drunk = nil,
			sprint = nil
		}
	end)

	minetest.register_on_respawnplayer(function(player)

		local name = player and player:get_player_name() ; if not name then return end

		if stamina.players[name].poisoned
		or stamina.players[name].drunk then
			player:hud_change(stamina.players[name].hud_id, "text", "stamina_hud_fg.png")
		end

		stamina.players[name].exhaustion = 0
		stamina.players[name].poisoned = nil
		stamina.players[name].drunk = nil
		stamina.players[name].sprint = nil

		stamina.update_saturation(player, stamina.VISUAL_MAX)
	end)

	minetest.register_globalstep(stamina_globaltimer)

	minetest.register_on_placenode(function(pos, oldnode, player, ext)
		stamina.exhaust_player(player, stamina.EXHAUST_PLACE)
	end)

	minetest.register_on_dignode(function(pos, oldnode, player, ext)
		stamina.exhaust_player(player, stamina.EXHAUST_DIG)
	end)

	minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
		stamina.exhaust_player(player, stamina.EXHAUST_CRAFT)
	end)

	minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch,
			tool_capabilities, dir, damage)
		stamina.exhaust_player(hitter, stamina.EXHAUST_PUNCH)
	end)

else -- create player table on join
	minetest.register_on_joinplayer(function(player)

		if player then
			stamina.players[player:get_player_name()] = {
				poisoned = nil, sprint = nil, drunk = nil, exhaustion = 0}
		end
	end)
end

-- clear when player leaves

minetest.register_on_leaveplayer(function(player)

	if player then
		stamina.players[player:get_player_name()] = nil
	end
end)

-- add lucky blocks (if damage and stamina active)

if minetest.get_modpath("lucky_block")
and minetest.settings:get_bool("enable_damage")
and minetest.settings:get_bool("enable_stamina") ~= false then

	local MP = minetest.get_modpath(minetest.get_current_modname())

	dofile(MP .. "/lucky_block.lua")
end

print("[MOD] Stamina loaded")
