function asrs.create_id(player_name, pos)
   local i = 1
   local system_id = player_name..'_'..i
   while asrs.data[system_id] do
      i = i + 1
      system_id = player_name..'_'..i
   end
   local new_data = {}
   new_data.inv_pos = pos
   new_data.max_inv = 0
   new_data.name = player_name
   new_data.nodes = 0
   asrs.data[system_id] = new_data
   return system_id
end

function asrs.update_inventory(pos)
   local meta = minetest.get_meta(pos)
   local sys_id = meta:get_string('system_id')
   local sys_data = asrs.data[sys_id]
   if sys_data then
      local sys_inv_max = sys_data.max_inv
      local inv = meta:get_inventory()
      inv:set_size('storage', sys_inv_max)
   end
end

function asrs.count_inventory(pos)
   local meta = minetest.get_meta(pos)
   local inv = meta:get_inventory()
   local inv_list = inv:get_list('storage')
   local count = 0
   local size = inv:get_size('storage')
   for i = 1, size do
      local stack = inv_list[i]
      local empty = stack:is_empty()
      if not empty then
         count = count + 1
      end
   end
   return count
end

function asrs.sort_inventory(pos)  -- Copied from the Technic_chests mod.
   local meta = minetest.get_meta(pos)
   local inv = meta:get_inventory()
   local inlist = inv:get_list('storage')
   if inlist then
      local typecnt = {}
      local typekeys = {}
      for _, st in ipairs(inlist) do
         if not st:is_empty() then
            local n = st:get_name()
            local w = st:get_wear()
            local m = st:get_metadata()
            local k = string.format("%s %05d %s", n, w, m)
            if not typecnt[k] then
               typecnt[k] = {
                  name = n,
                  wear = w,
                  metadata = m,
                  stack_max = st:get_stack_max(),
                  count = 0,
               }
               table.insert(typekeys, k)
            end
            typecnt[k].count = typecnt[k].count + st:get_count()
         end
      end
      table.sort(typekeys)
      local outlist = {}
      for _, k in ipairs(typekeys) do
         local tc = typecnt[k]
         while tc.count > 0 do
            local c = math.min(tc.count, tc.stack_max)
            table.insert(outlist, ItemStack({
               name = tc.name,
               wear = tc.wear,
               metadata = tc.metadata,
               count = c,
            }))
            tc.count = tc.count - c
         end
      end
      if #outlist > #inlist then return end
      while #outlist < #inlist do
         table.insert(outlist, ItemStack(nil))
      end
      inv:set_list('storage', outlist)
   end
end

function asrs.connected_nodes(pos, node_name)
   local positions = {
      {x=pos.x+1, y=pos.y,   z=pos.z},
      {x=pos.x-1, y=pos.y,   z=pos.z},
      {x=pos.x,   y=pos.y+1, z=pos.z},
      {x=pos.x,   y=pos.y-1, z=pos.z},
      {x=pos.x,   y=pos.y,   z=pos.z+1},
      {x=pos.x,   y=pos.y,   z=pos.z-1},
   }
   local found_node = false
   local other_pos
   for _, loc in ipairs(positions) do
      local name = minetest.get_node(loc).name
      if string.find(node_name, name) then
         other_pos = loc
         found_node = true
         break
      end
   end
   return found_node, other_pos
end


fdir_table = {
   {  1,  0 },
   {  0, -1 },
   { -1,  0 },
   {  0,  1 },
   {  1,  0 },
   {  0, -1 },
   { -1,  0 },
   {  0,  1 },
}

function asrs.space_to_place(pos)
   local node = minetest.get_node(pos)
   local fdir = node.param2 % 32
   local pos2 = {x = pos.x + fdir_table[fdir+1][1], y=pos.y, z = pos.z + fdir_table[fdir+1][2]}
   local pos3 = {x = pos2.x, y = pos2.y+1, z = pos2.z}
   local pos4 = {x = pos.x, y = pos.y+1, z = pos.z}
   local node2 = minetest.get_node(pos2) -- Node to the right
   local node3 = minetest.get_node(pos3) -- Node above to the right
   local node4 = minetest.get_node(pos4) -- Node above
   local node2def = minetest.registered_nodes[node2.name] or nil
   local node3def = minetest.registered_nodes[node3.name] or nil
   local node4def = minetest.registered_nodes[node4.name] or nil
   if not node2def.buildable_to or not node3def.buildable_to or not node4def.buildable_to then
      return false
   else
      minetest.after(1, function()
         minetest.set_node(pos2,{name = 'asrs:blank'})
         minetest.set_node(pos3,{name = 'asrs:blank'})
         minetest.set_node(pos4,{name = 'asrs:connection_point'})
      end)
      return true
   end
end

function asrs.remove_side_node(pos, oldnode)
   local fdir = oldnode.param2 % 32
   local pos2 = {x = pos.x + fdir_table[fdir+1][1], y=pos.y, z = pos.z + fdir_table[fdir+1][2]}
   local pos3 = {x = pos2.x, y = pos2.y+1, z = pos2.z}
   local pos4 = {x = pos.x, y = pos.y+1, z = pos.z}
   minetest.remove_node(pos2)
   minetest.remove_node(pos3)
   minetest.remove_node(pos4)
end

function asrs.load()
   local file = io.open(minetest.get_worldpath() .. '/asrs_systems', 'r')
   if file then
      asrs.data = minetest.deserialize(file:read('*a'))
      file:close()
   else
      asrs.data = {}
   end
end

function asrs.save()
   local file = io.open(minetest.get_worldpath() .. '/asrs_systems', 'w')
   file:write(minetest.serialize(asrs.data))
   file:close()
end
