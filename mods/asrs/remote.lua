local BLOCKSIZE = core.MAP_BLOCKSIZE
local function get_blockpos(pos)
    return vector.apply(vector.copy(pos)/BLOCKSIZE,math.floor)
end

core.register_craftitem('asrs:remote_item', {
   description = 'Remote Access Device',
   inventory_image = 'asrs_remote_item.png',
   on_place = function(itemstack, user, pointed_thing) --clicking on a node.
      local pos = pointed_thing.under
      local item_meta = itemstack:get_meta()
      if pos then
         local node = core.get_node(pos).name
         local name = user:get_player_name()
         if node == 'asrs:controller' then
            local meta = core.get_meta(pos)
            local owner = meta:get_string('owner')
            if owner == name then
               local sys_id = meta:get_string('system_id')
               local spos = minetest.pos_to_string(pos)
               local infotext = meta:get_string('infotext')
               item_meta:set_string('system_id', sys_id)
               item_meta:set_string('description', 'Remote Access tied to: '..infotext..'\nSystem located at '..spos)
               core.chat_send_player(name, 'Remote configured!')
               core.chat_send_player(name, 'Right or Left click to connect to this system in the future.')
               return itemstack
            else
               core.chat_send_player(name, 'You can only connect this to a system you own.')
            end
         elseif node == 'asrs:remote_node' then
            core.chat_send_player(name, 'You can only use this on the main controller.')
         else
            local sys_id = item_meta:get_string('system_id')
            if sys_id ~= '' then
               local pos = asrs.data[sys_id].inv_pos
               asrs.clicker[name] = {pos = pos, filter = '', node = 'remote'}
               if not user:send_mapblock(get_blockpos(pos)) then
                  core.show_formspec(name, 'asrs:control_panel', asrs.loading_screen())
                  core.after(1, function ()
                     core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, 'remote'))
                  end)
               else
                  core.show_formspec(name, 'asrs:control_panel', asrs.loading_screen())
                  core.after(0.1, function ()
                     core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, 'remote'))
                  end)
               end
            else
               core.chat_send_player(name, 'You must use this on a controller node to configure it.')
            end
         end
      end
   end,
   on_use = function(itemstack, placer, pointed_thing)
      local item_meta = itemstack:get_meta()
      local sys_id = item_meta:get_string('system_id')
      local name = placer:get_player_name()
      if sys_id ~= '' then --Should be valid, connect to system
         local pos = asrs.data[sys_id].inv_pos
         asrs.clicker[name] = {pos = pos, filter = '', node = 'remote'}
         if not placer:send_mapblock(get_blockpos(pos)) then
            core.show_formspec(name, 'asrs:control_panel', asrs.loading_screen())
            core.after(1, function ()
               core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, 'remote'))
            end)
         else
            core.show_formspec(name, 'asrs:control_panel', asrs.loading_screen())
            core.after(0.1, function ()
               core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, 'remote'))
            end)
         end
      else
         core.chat_send_player(name, 'You must configure this before using it.')
      end
   end,
   on_secondary_use = function(itemstack, user, pointed_thing)
      local item_meta = itemstack:get_meta()
      local sys_id = item_meta:get_string('system_id')
      local name = user:get_player_name()
      if sys_id ~= '' then --Should be valid, connect to system
         local pos = asrs.data[sys_id].inv_pos
         asrs.clicker[name] = {pos = pos, filter = '', node = 'remote'}
         if not user:send_mapblock(get_blockpos(pos)) then
            core.show_formspec(name, 'asrs:control_panel', asrs.loading_screen())
            core.after(1, function ()
               core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, 'remote'))
            end)
         else
            core.show_formspec(name, 'asrs:control_panel', asrs.loading_screen())
            core.after(0.1, function ()
               core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, 'remote'))
            end)
         end
      else
         core.chat_send_player(name, 'You must configure this before using it.')
      end
   end,
})
