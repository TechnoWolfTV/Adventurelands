minetest.register_globalstep(function(dtime, player)
	for _, player in pairs(minetest.get_connected_players()) do





 local scope_hud = rangedweapons_hud.scope[player:get_player_name()]
 local w_item = player:get_wielded_item()


local controls = player:get_player_control()
if w_item:get_definition().weapon_zoom ~= nil then

	if controls.zoom then
if scope_hud then player:hud_change(scope_hud, "text", "rangedweapons_scopehud.png") end
	else
if scope_hud then player:hud_change(scope_hud, "text", "rangedweapons_empty_icon.png") end
	end

local wpn_zoom = w_item:get_definition().weapon_zoom
	if player:get_properties().zoom_fov ~= wpn_zoom then
		player:set_properties({zoom_fov = wpn_zoom})

	end

end

if w_item:get_definition().weapon_zoom == nil then
	if scope_hud then player:hud_change(scope_hud, "text", "rangedweapons_empty_icon.png") end
	if player:get_inventory():contains_item(
			"main", "binoculars:binoculars") then
		local new_zoom_fov = 10
		if player:get_properties().zoom_fov ~= new_zoom_fov then
		   player:set_properties({zoom_fov = new_zoom_fov})
		end
	else 
		local new_zoom_fov = 0
		if player:get_properties().zoom_fov ~= new_zoom_fov then
		   player:set_properties({zoom_fov = new_zoom_fov})
		end
	end
end


local u_meta = player:get_meta()
local cool_down = u_meta:get_float("rw_cooldown") or 0


if u_meta:get_float("rw_cooldown") > 0 then
u_meta:set_float("rw_cooldown", cool_down - dtime)
end

local itemstack = player:get_wielded_item()

if controls.LMB then
	-- One definition lookup instead of six. This runs for every connected
	-- player on every server step, so the repeated get_wielded_item() calls
	-- were allocating an ItemStack a dozen times per player per tick.
	local def = itemstack:get_definition()

	local gun_caps = def.RW_gun_capabilities
	if gun_caps and gun_caps.automatic_gun and gun_caps.automatic_gun > 0 then
		rangedweapons_shoot_gun(itemstack, player)
		player:set_wielded_item(itemstack)
	end

	local power_caps = def.RW_powergun_capabilities
	if power_caps and power_caps.automatic_gun and power_caps.automatic_gun > 0 then
		rangedweapons_shoot_powergun(itemstack, player)
		player:set_wielded_item(itemstack)
	end
end



--minetest.chat_send_all(u_meta:get_float("rw_cooldown"))

if u_meta:get_float("rw_cooldown") <= 0 then
	local held = player:get_wielded_item()
	local def = held:get_definition()

	if def.loaded_gun ~= nil then
		if def.loaded_sound ~= nil then
			minetest.sound_play(def.loaded_sound, {pos = player:get_pos()}, true)
		end
		held:set_name(def.loaded_gun)
		player:set_wielded_item(held)

		-- The wielded item just changed name, so the next check must look at
		-- the new definition rather than the stale one.
		held = player:get_wielded_item()
		def = held:get_definition()
	end

	if def.rw_next_reload ~= nil then
		if def.load_sound ~= nil then
			minetest.sound_play(def.load_sound, {pos = player:get_pos()}, true)
		end
		local gunMeta = held:get_meta()
		u_meta:set_float("rw_cooldown", gunMeta:get_float("RW_reload_delay"))
		held:set_name(def.rw_next_reload)
		player:set_wielded_item(held)
	end
end

end end)


