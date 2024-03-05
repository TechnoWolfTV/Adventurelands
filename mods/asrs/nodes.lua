local controller_box = {
   type = 'fixed',
   fixed = {
      {-.5, -.5, -.4375, 1.4375, .5, .5}, --Desk
      {.375, .75, .375, 1.3125, 1.5, .5}, --TV
      {-.5, .5, -.5, -.125, 1.5, .5} -- Extractor
   }
}

minetest.register_node('asrs:controller', {
   description = 'A.S.R.S Controller',
   drawtype = 'mesh',
   mesh = 'asrs_controller.obj',
   tiles = {'asrs_controller.png'},
   paramtype = 'light',
   paramtype2 = 'facedir',
   selection_box = controller_box,
   collision_box = controller_box,
   groups = {cracky=2, choppy=2, oddly_breakable_by_hand=2, tubedevice = 1, tubedevice_receiver = 1, handy=1, pixkaxey=1},
   after_place_node = function(pos, placer)
      if asrs.space_to_place(pos) then
         local meta = minetest.get_meta(pos)
         local player_name = placer:get_player_name()
         local sys_id = asrs.create_id(player_name, pos)
         local inv = meta:get_inventory()
         inv:set_size('storage', 0)
         inv:set_size('search', 0)
         meta:set_string('infotext', 'Automated Storage & Retrieval System')
         meta:set_string('system_id', sys_id)
         meta:set_string('owner', player_name)
         meta:set_int('inv_page', 0)
      else
         minetest.remove_node(pos)
         minetest.chat_send_player(placer:get_player_name(), 'It looks like there is a node in the way.')
         return true
      end
   end,
   on_rightclick = function(pos, node, clicker)
      asrs.update_inventory(pos)
      local meta = minetest.get_meta(pos)
      local owner = meta:get_string('owner')
      local players = ' '..meta:get_string('players')..' '
      local name = clicker:get_player_name()
      if name == owner or string.find(players, ' '..name..' ') then
         local inv = meta:get_inventory()
         inv:set_size('search', 0)
         asrs.clicker[name] = {pos = pos, filter = ''}
         minetest.show_formspec(name, 'asrs:control_panel', asrs.main(pos))
      else
         minetest.chat_send_player(name, 'You do not have access to this system.')
      end
   end,
   can_dig = function(pos, player)
      local meta = minetest.get_meta(pos)
      local sys_id = meta:get_string('system_id')
      if sys_id ~= '' then
         local connected_nodes = asrs.data[sys_id].nodes
         if connected_nodes <= 1 then
            return true
         else
            minetest.chat_send_player(player:get_player_name(), 'Please remove lifts and cells first.')
            return false
         end
      else
         return true
      end
   end,
   after_dig_node = function(pos, oldnode, oldmetadata)
      local sys_id = oldmetadata.fields.system_id
      if sys_id then
         asrs.data[sys_id] = nil
      end
      asrs.remove_side_node(pos, oldnode)
      asrs.save()
   end,
   on_metadata_inventory_take = function(pos, listname, index, stack, player)
      if listname == 'search' then
         if stack and stack:get_count() > 0 then
            minetest.log('action', player:get_player_name()..' took '..stack:get_name()..' from the asrs.')
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            inv:remove_item('storage', stack)
         end
      end
   end,
   on_metadata_inventory_put = function(pos, listname, index, stack, player)
      if listname == 'search' then
         if stack and stack:get_count() > 0 then
            minetest.log('action', player:get_player_name()..' placed '..stack:get_name()..' into the asrs.')
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            inv:add_item('storage', stack)
         end
      end
   end,
   tube = {
      insert_object = function(pos, node, stack, direction)
         local meta = minetest.get_meta(pos)
         local inv = meta:get_inventory()
         return inv:add_item('storage', stack)
      end,
      can_insert = function(pos, node, stack, direction)
         local meta = minetest.get_meta(pos)
         local inv = meta:get_inventory()
         return inv:room_for_item('storage', stack)
      end,
      input_inventory = 'storage',
      connect_sides = {back = 1, bottom = 1}
   },
})

minetest.register_node('asrs:blank', {
   description = 'Invisible Border',
   drawtype = 'airlike',
   paramtype = 'light',
   pointable = false,
   walkable = false,
   tiles = {'air.png'},
   groups = {not_in_creative_inventory=1},
})

minetest.register_node('asrs:connection_point', {
   description = 'Invisible Border',
   drawtype = 'airlike',
   paramtype = 'light',
   pointable = false,
   walkable = false,
   tiles = {'air.png'},
   groups = {not_in_creative_inventory=1},
   on_construct = function(pos)
      local pos1 = {x = pos.x, y = pos.y-1, z = pos.z}
      local this_meta = minetest.get_meta(pos)
      local that_meta = minetest.get_meta(pos1)
      local sys_id = that_meta:get_string('system_id')
      local children = that_meta:get_int('children')
      this_meta:set_string('system_id', sys_id)
      that_meta:set_int('children', children + 1)
      local connected_nodes = asrs.data[sys_id].nodes
      asrs.data[sys_id].nodes = connected_nodes + 1
   end
})

minetest.register_node('asrs:cell', {
   description = 'A.S.R.S Storage Cell',
   tiles = {'asrs_cell.png'},
   groups = {cracky=2, choppy=2, oddly_breakable_by_hand=2, handy=1, pixkaxey=1},
   after_place_node = function(pos, placer)
      local neighbor, pos1 = asrs.connected_nodes(pos, 'asrs:lift')
      if neighbor then
         local this_meta = minetest.get_meta(pos)
         local that_meta = minetest.get_meta(pos1)
         local sys_id = that_meta:get_string('system_id')
         local children = that_meta:get_int('children')
         this_meta:set_string('system_id', sys_id)
         that_meta:set_int('children', children + 1)
         local sys_inv_max = asrs.data[sys_id].max_inv
         asrs.data[sys_id].max_inv = sys_inv_max + 20
         local connected_nodes = asrs.data[sys_id].nodes
         asrs.data[sys_id].nodes = connected_nodes + 1
         asrs.save()
      else
         local name = placer:get_player_name()
         minetest.chat_send_player(name, 'You must place this adjacent to a lift node.')
         minetest.remove_node(pos)
         return true
      end
   end,
   can_dig = function(pos, player)
      local meta = minetest.get_meta(pos)
      local sys_id = meta:get_string('system_id')
      local sys_inv_max = asrs.data[sys_id].max_inv
      asrs.sort_inventory(asrs.data[sys_id].inv_pos)
      local inv_count = asrs.count_inventory(asrs.data[sys_id].inv_pos)
      if inv_count > (sys_inv_max - 20) then
         minetest.chat_send_player(player:get_player_name(), 'Remove some inventory from the system first.')
         return false
      else
         return true
      end
   end,
   after_dig_node = function(pos, _, oldmetadata)
      local _, pos1 = asrs.connected_nodes(pos, 'asrs:lift')
      if pos1 then
         local that_meta = minetest.get_meta(pos1)
         local children = that_meta:get_int('children')
         that_meta:set_int('children', children - 1)
      end
      local sys_id = oldmetadata.fields.system_id
      local sys_inv_max = asrs.data[sys_id].max_inv
      asrs.data[sys_id].max_inv = sys_inv_max - 20
      local connected_nodes = asrs.data[sys_id].nodes
      asrs.data[sys_id].nodes = connected_nodes - 1
      asrs.save()
   end,
})

minetest.register_node('asrs:lift', {
   description = 'A.S.R.S Lift',
   tiles = {'asrs_lift_top.png', 'asrs_lift_top.png', 'asrs_lift_side.png'},
   groups = {cracky=2, choppy=2, oddly_breakable_by_hand=2, handy=1, pixkaxey=1},
   after_place_node = function(pos, placer)
      local neighbor, pos1 = asrs.connected_nodes(pos, 'asrs:lift, asrs:connection_point')
      if neighbor then
         local this_meta = minetest.get_meta(pos)
         local that_meta = minetest.get_meta(pos1)
         local children = that_meta:get_int('children')
         local sys_id = that_meta:get_string('system_id')
         this_meta:set_string('system_id', sys_id)
         this_meta:set_int('children', 0)
         that_meta:set_int('children', children + 1)
         local connected_nodes = asrs.data[sys_id].nodes
         asrs.data[sys_id].nodes = connected_nodes + 1
         asrs.save()
      else
         local name = placer:get_player_name() or ''
         minetest.chat_send_player(name, 'You must place this adjacent to a lift or controller node.')
         minetest.remove_node(pos)
         return true
      end
   end,
   can_dig = function(pos, player)
      --local undiggable, pos1 = asrs.connected_nodes(pos, 'asrs:cell')
      local meta = minetest.get_meta(pos)
      local children = meta:get_int('children')
      --if undiggable then
      if children > 0 then
         minetest.chat_send_player(player:get_player_name(), 'Remove connected nodes first.')
         return false
      else
         return true
      end
   end,
   after_dig_node = function(pos, _, oldmetadata)
      local _, pos1 = asrs.connected_nodes(pos, 'asrs:lift')
      if pos1 then
         that_meta = minetest.get_meta(pos1)
         local children = that_meta:get_int('children')
         that_meta:set_int('children', children - 1)
      end
      local sys_id = oldmetadata.fields.system_id
      local connected_nodes = asrs.data[sys_id].nodes
      asrs.data[sys_id].nodes = connected_nodes - 1
      asrs.save()
   end,
})
