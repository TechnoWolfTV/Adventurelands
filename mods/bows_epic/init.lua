-- Bows Mod by UjEdwin

bows_epic = {
   pvp = minetest.settings:get_bool('enable_pvp'),
   registered_arrows = {},
   registered_bows = {},
}

local creative_mode_cache = minetest.settings:get_bool('creative_mode')

function bows_epic.is_creative(name)
   return creative_mode_cache or minetest.check_player_privs(name, {creative = true})
end

bows_epic.register_arrow = function(name, def)
   if name == nil
   or name == '' then
      return false
   end
   def.damage = def.damage or 0
   def.name = 'bows_epic:' .. name
   def.level = def.level or 1
   def.disp_entity = def.displayed_entity or def.name
   def.on_hit_object = def.on_hit_object
   def.on_hit_node = def.on_hit_node
   def.speed = def.speed or 0
   def.on_hit_sound = def.on_hit_sound or 'default_dig_dig_immediate'
   bows_epic.registered_arrows[def.name] = def
   if def.type == 'bolt' then
      minetest.register_craftitem(':bows_epic:' .. name, {
         description = def.description or name,
         inventory_image = def.texture or 'bows_arrow_wooden.png',
         groups = {bolt = 1},
         drop_chance = def.drop_chance
      })
   else
      minetest.register_craftitem(':bows_epic:' .. name, {
         description = def.description or name,
         inventory_image = def.texture or 'bows_arrow_wooden.png',
         groups = {arrow = 1},
         drop_chance = def.drop_chance
      })
   end
   if def.craft then
      minetest.register_craft({
         output = def.name ..' ' .. (def.craft_count or 1),
         recipe = def.craft
      })
   end
end

bows_epic.register_bow = function(name, def)
   if name == nil
   or name == '' then
      return false
   end
   def.replace = 'bows_epic:' .. name .. '_loaded'
   def.name = 'bows_epic:' .. name
   def.uses = def.uses - 1 or 49
   def.ammo = def.ammo or 'arrow'
   bows_epic.registered_bows[def.replace] = def
   bows_epic.registered_bows[def.name] = def
   minetest.register_tool(':' .. def.name, {
      description = def.description or name,
      inventory_image = def.texture or 'bows_bow.png',
      on_use = bows_epic.load,
      groups = {bow = 1},
   })
   minetest.register_tool(':' .. def.replace, {
      description = def.description or name,
      inventory_image = def.texture_loaded or 'bows_bow_loaded.png',
      on_use = bows_epic.shoot,
      groups = {bow = 1, not_in_creative_inventory = 1},
   })
   if def.craft then
      minetest.register_craft({output = def.name,recipe = def.craft})
   end
end

bows_epic.load = function(itemstack, user, pointed_thing)
   local name = itemstack:get_name()
   local ammo = bows_epic.registered_bows[name].ammo
   local inv = user:get_inventory()
   local index = user:get_wield_index() - 1
   local arrow = inv:get_stack('main', index)
   if minetest.get_item_group(arrow:get_name(), ammo) == 0 then
      return itemstack
   end
   local item = itemstack:to_table()
   local meta = minetest.deserialize(item.metadata)
   meta = {arrow = arrow:get_name()}
   item.metadata = minetest.serialize(meta)
   item.name = item.name .. '_loaded'
   itemstack:replace(item)
   if not bows_epic.is_creative(user:get_player_name()) then
      inv:set_stack('main', index,
            ItemStack(arrow:get_name() .. ' ' .. (arrow:get_count() - 1)))
   end
   return itemstack
end

bows_epic.shoot = function(itemstack, user, pointed_thing)
   local item = itemstack:to_table()
   local meta = minetest.deserialize(item.metadata)
   if (not (meta and meta.arrow))
   or (not bows_epic.registered_arrows[meta.arrow]) then
      return itemstack
   end
   local name = itemstack:get_name()
   local replace = bows_epic.registered_bows[name].name
   local ar = bows_epic.registered_bows[name].uses
   local wear = bows_epic.registered_bows[name].uses
   local arrow_speed = bows_epic.registered_arrows[meta.arrow].speed
   local level = bows_epic.registered_bows[name].level + arrow_speed
   bows_epic.tmp = {}
   bows_epic.tmp.arrow = meta.arrow
   bows_epic.tmp.user = user
   bows_epic.tmp.name = meta.arrow
   item.arrow = ''
   item.metadata = minetest.serialize(meta)
   item.name = replace
   itemstack:replace(item)
   local pos = user:get_pos()
   local dir = user:get_look_dir()
   local e = minetest.add_entity({
      x = pos.x,
      y = pos.y + 1.5,
      z = pos.z
   }, 'bows_epic:arrow')
   e:set_velocity({x = dir.x * level, y = dir.y * level, z = dir.z * level})
   e:set_acceleration({x = dir.x * -3, y = -4, z = dir.z * -3})
   e:set_yaw(user:get_look_horizontal() - math.pi/2)
   if not bows_epic.is_creative(user:get_player_name()) then
      itemstack:add_wear(65535 / wear)
   end
   minetest.sound_play('bows_shoot', {pos = pos})
   return itemstack
end

local path = minetest.get_modpath('bows_epic')

dofile(path .. '/arrow.lua')
dofile(path .. '/bows.lua')
dofile(path .. '/crossbows.lua')

minetest.register_alias('castle_weapons:crossbow',      'bows_epic:crossbow')
minetest.register_alias('castle_weapons:crossbow_bolt', 'bows_epic:bolt_3')
