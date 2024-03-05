tubelib.register_node('asrs:controller', {}, {
   on_pull_item = function(pos, side)
      local meta = minetest.get_meta(pos)
      return tubelib.get_item(meta, 'storage')
   end,
   on_push_item = function(pos, side, item)
      local meta = minetest.get_meta(pos)
      return tubelib.put_item(meta, 'storage', item)
   end,
   on_unpull_item = function(pos, side, item)
      local meta = minetest.get_meta(pos)
      return tubelib.put_item(meta, 'storage', item)
   end,
   valid_sides = {'B', 'D'}
})

minetest.register_node('asrs:tubelib', {
   description = 'A.S.R.S tubelib interface',
   tiles = {'asrs_cell.png^tubelib_hole.png'},
   groups = {cracky=2, choppy=2, oddly_breakable_by_hand=2},
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
         local sys_inv_max = asrs.data[sys_id].max_inv
         asrs.data[sys_id].max_inv = sys_inv_max + 10
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
      local meta = minetest.get_meta(pos)
      local sys_id = meta:get_string('system_id')
      local sys_inv_max = asrs.data[sys_id].max_inv
      asrs.sort_inventory(asrs.data[sys_id].inv_pos)
      local inv_count = asrs.count_inventory(asrs.data[sys_id].inv_pos)
      if inv_count > (sys_inv_max - 10) then
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
      asrs.data[sys_id].max_inv = sys_inv_max - 10
      local connected_nodes = asrs.data[sys_id].nodes
      asrs.data[sys_id].nodes = connected_nodes - 1
      asrs.save()
   end,
})

minetest.register_craft({
   output = 'asrs:tubelib',
   type = 'shapeless',
   recipe = {'asrs:cell', 'tubelib:tubeS'}
})

tubelib.register_node('asrs:tubelib', {}, {
   on_pull_item = function(pos, side)
      local meta = minetest.get_meta(pos)
      local sys_id = meta:get_string('system_id')
      pos = asrs.data[sys_id].inv_pos
      meta = minetest.get_meta(pos)
      return tubelib.get_item(meta, 'storage')
   end,
   on_push_item = function(pos, side, item)
      local meta = minetest.get_meta(pos)
      local sys_id = meta:get_string('system_id')
      pos = asrs.data[sys_id].inv_pos
      meta = minetest.get_meta(pos)
      return tubelib.put_item(meta, 'storage', item)
   end,
   on_unpull_item = function(pos, side, item)
      local meta = minetest.get_meta(pos)
      local sys_id = meta:get_string('system_id')
      pos = asrs.data[sys_id].inv_pos
      meta = minetest.get_meta(pos)
      return tubelib.put_item(meta, 'storage', item)
   end,
   valid_sides = {'B', 'R', 'F', 'L', 'D', 'U'}
})
