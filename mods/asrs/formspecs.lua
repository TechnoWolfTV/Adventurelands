local esc = core.formspec_escape

function asrs.loading_screen()
   local formspec =
   'formspec_version[7]'..
   'size[13.25,10.5]'..
   'no_prepend[]'..
   'bgcolor[;true;#080808BB]'..
   'style_type[box;colors=#484848;bordercolors=#224c9a;borderwidths=-6]'..
   'box[0,0;13.25,10.5;]'.. --Background
   'style_type[box;colors=#363636;bordercolors=#565656;borderwidths=-2]'..
   'box[.375,.375;12.5,9.5;]'.. --Secondary Background
   'box[.375,.375;12.5,3.75;]'.. --Node Inventory
   'box[.375,5..;2.5,5;]'.. --Buttons
   'box[2.875,5;10,5;]'.. --Player Inventory
   'image[.375,.375;12.5,3.75;asrs_logo.png]'..
   'hypertext[.375,4.125;12.5,.9;;<style size=30><global halign=center valign=middle>Connecting to system...</style>]'
   return formspec
end

local function base(inv_rows)
   local inv_rows = inv_rows or 0
   local height = 10.5
   local offset = 4
   if inv_rows ~= 0 then
      height = 6.75 + (1.25*inv_rows)
      offset = (1.25*inv_rows) + .25
   end
   local formspec =
      'formspec_version[7]'..
      'size[13.25,'..height..']'..
      'no_prepend[]'..
      'bgcolor[;true;#080808BB]'..
      'style_type[box;colors=#484848;bordercolors=#224c9a;borderwidths=-6]'..
      'box[0,0;13.25,'..height..';]'.. --Background
      'style_type[box;colors=#363636;bordercolors=#565656;borderwidths=-2]'..
      'box[.375,.375;12.5,'..5.5+offset..';]'.. --Secondary Background
      'box[.375,.375;12.5,'..offset-.25 ..';]'.. --Node Inventory
      'box[.375,'..offset+1 ..'..;2.5,5;]'.. --Buttons
      'box[2.875,'..offset+1 ..';10,5;]'.. --Player Inventory
      'style_type[image_button;border=false]'..
      'image_button[.5,'..1.125+offset..';1,1;asrs_main.png;main;]'..
      'tooltip[main;Main Inventory Screen]'..
      'image_button[1.75,'..1.125+offset..';1,1;asrs_sort.png;sort;]'..
      'tooltip[sort;Sort System Inventory]'..
      'image_button[.5,'..2.3755+offset..';1,1;asrs_settings.png;settings;]'..
      'tooltip[settings;Settings]'..
      'image_button[1.75,'..2.375+offset..';1,1;asrs_debug.png;debug;]'..
      'tooltip[debug;Debug Information]'..
      'image_button[.5,'..3.625+offset..';1,1;asrs_help.png;help;]'..
      'tooltip[help;How to use the system.]'..
      'image_button[.5,'..4.875+offset..';1,1;asrs_exit.png;exit;]'..
      'tooltip[exit;Exit this dialog]'
   return formspec
end

function asrs.main(pos, node) --The main inventory screen.
   local spos = pos.x .. "," .. pos.y .. "," .. pos.z
   local meta = core.get_meta(pos)
   local inv = meta:get_inventory()
   local inv_name = 'storage'
   if inv:get_size('search') > 0 then
      inv_name = 'search'
   end
   local inv_rows = math.max(meta:get_int('rows'), 3)
   local offset = (1.25*inv_rows) + .375
   local index = meta:get_int('inv_page') or 0
   local sys_id = meta:get_string('system_id')
   local sys_data = asrs.data[sys_id]
   local sys_inv_max = sys_data.max_inv
   local quantity = meta:get_int('rows') or 3
   local total_pages = math.floor(sys_inv_max/(quantity*10))
   local formspec =
      base(inv_rows)..
      'field[.4,'..(offset+.0625)..';3.75,.75;inv_search_filter;;]'..
      'field_close_on_enter[inv_search_filter;false]'..
      'image_button[4.25,'..(offset+.0625)..';.75,.75;asrs_search.png;inv_search;]'..
      'tooltip[inv_search;Search for an item.]'..
      'image_button[5.25,'..(offset+.0625)..';.75,.75;asrs_clear_search.png;reset_search;]'..
      'tooltip[reset_search;Clear search filter/show all items.]'..
      'image_button[9,'..(offset+.0625)..';.75,.75;asrs_first.png;first_page;]'..
      'tooltip[first_page;Jump to first page.]'..
      'image_button[10,'..(offset+.0625)..';.75,.75;asrs_previous.png;prev_page;]'..
      'tooltip[prev_page;Go back one page.]'..
      'image_button[11,'..(offset+.0625)..';.75,.75;asrs_next.png;next_page;]'..
      'tooltip[next_page;Go forward one page.]'..
      'image_button[12,'..(offset+.0625)..';.75,.75;asrs_last.png;last_page;]'..
      'tooltip[last_page;Jump to last page.]'..
      'hypertext[6.25,'..(offset+.0625)..';2.75,.75;;<style size=24><global halign=center valign=middle>page: '..((index/(quantity*10))+1)..'/'..total_pages..'</style>]'..
      'list[nodemeta:'..spos..';'..inv_name..';.5,.5;10,'..inv_rows..';'..index..']'..
      'list[current_player;main;3,'..1+offset..';8,4]'..
      'listring[]'
   if node == 'remote' then
      formspec = formspec ..
      'box[.375,'..offset+.875 ..'..;2.5,5;]'.. --Masks buttons
      'image_button[1.75,'..offset+1 ..';1,1;asrs_sort.png;sort;]'..
      'tooltip[sort;Sort System Inventory]'
   end
   return formspec
end

function asrs.settings(pos)
   local meta = core.get_meta(pos)
   local name = meta:get_string('infotext')
   local players = meta:get_string('players') or ''
   local owner = meta:get_string('owner') or ''
   local inv_rows = meta:get_int('rows')
   local formspec =
      base()..
      'image[.375,.375;12.5,3.75;asrs_logo.png]'..
      'field[3,5.25;9.75,.5;name;System Name:;'..esc(name)..']'..
      'field[3,6.25;9.75,.5;players;Player Access: (These players can access inventory. Separate with a space.);'..esc(players)..']'..
      'field[3,7.25;9.75,.5;inv_rows;Inventory Rows: (How many rows of the A.S.R.S inventory should be shown.);'..inv_rows..']'..
      'button[3,9;3,.75;settings_remove;Remove node]'..
      'tooltip[settings_remove;Removes the ASRS controller. Useful if you get an error when trying to dig the node.\nWARNING!!! Any inventory in the system will be lost!]'..
      'button[10.75,9;2,.75;settings_save;Save]'
   return formspec
end

function asrs.debug(pos) --Any information that would be useful for debugging errors.
   local meta = core.get_meta(pos)
   local sys_id = meta:get_string('system_id')
   local sys_data = asrs.data[sys_id]
   local sys_inv_max = sys_data.max_inv or 0
   local con_nodes = sys_data.nodes-1 or 0
   local inv_count =  asrs.count_inventory(pos)
   local formspec =
      base()..
      'image[.375,.375;12.5,3.75;asrs_logo.png]'..
      'textarea[3,5;9.75,4.75;;;The system currently has '..con_nodes..' connected nodes. '..
      'This includes storage cells and lifts.\n'..inv_count..' of '..sys_inv_max..' slots are filled.\n'..
      'The internal system ID is: '..sys_id..']'
   return formspec
end

local asrs_help =
   base()..
   'image[.375,.375;12.5,3.75;asrs_logo.png]'..
   'textarea[3,5;9.75,4.75;;;To get started place some lift nodes to the left of the controller. '..
   'You can connect more lift nodes to these nodes, to increase the amount of storage you can link up. '..
   'Add some storage cells that connect to the lift nodes.'..
   'Each storage cell will give the system an extra twenty slots of inventory.\n'..
   'You can change how many rows of system inventory are displayed in the configuration tab. Between 3 and 20 are allowed.'..
   'You can sort the system inventory by clicking the sort button to the left. You can click sort on any screen.\n'..
   'If you are playing with the pipeworks mod enabled you can add inventory to the system by connecting tubes to the back and bottom of this node. You can also use the Pipework interface node.'..
   'Likewise you can remove inventory from the back and bottom with an injector.\n'..
   'If you are playing with techpack or techage you can do the same with the appropriate interface nodes. These interface nodes will also allow you to remove inventory.]'

core.register_on_player_receive_fields(function(player, formname, fields)
   if formname == 'asrs:control_panel' then
      local name = player:get_player_name()
      local pos = asrs.clicker[name].pos
      local node = asrs.clicker[name].node
      if fields.inv_search or fields.key_enter_field == 'inv_search_filter' then
         local meta = core.get_meta(pos)
         local inv = meta:get_inventory()
         local items = inv:get_list('storage')
         local filter = fields.inv_search_filter:lower()
         asrs.clicker[name].filter = filter
         local preserve = {}
         if filter and filter ~= "" then
            for _, v in pairs(items) do
               if v:get_name():find(filter) then
                  preserve[#preserve + 1] = v
               end
            end
         end
         inv:set_size('search', #preserve)
         inv:set_list('search', preserve)
         core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, node))
      elseif fields.reset_search then
         local meta = core.get_meta(pos)
         local inv = meta:get_inventory()
         inv:set_size('search', 0)
         inv:set_list('search', {})
         core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, node))
      elseif fields.first_page then
         local meta = core.get_meta(pos)
         meta:set_int('inv_page', 0)
         core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, node))
      elseif fields.prev_page then
         local meta = core.get_meta(pos)
         local index = meta:get_int('inv_page')
         local quantity = meta:get_int('rows')*10
         meta:set_int('inv_page', math.max(index - quantity, 0))
         core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, node))
      elseif fields.next_page then
         local meta = core.get_meta(pos)
         local index = meta:get_int('inv_page')
         local quantity = meta:get_int('rows')*10
         local sys_id = meta:get_string('system_id')
         local sys_data = asrs.data[sys_id]
         local sys_inv_max = sys_data.max_inv
         meta:set_int('inv_page', math.min((index + quantity), (sys_inv_max - quantity)))
         core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, node))
      elseif fields.last_page then
         local meta = core.get_meta(pos)
         local index = meta:get_int('inv_page')
         local quantity = meta:get_int('rows')*10
         local sys_id = meta:get_string('system_id')
         local sys_data = asrs.data[sys_id]
         local sys_inv_max = sys_data.max_inv
         meta:set_int('inv_page', sys_inv_max - quantity)
         core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, node))
      elseif fields.main then
         core.show_formspec(name, 'asrs:control_panel', asrs.main(pos, node))
      elseif fields.settings then
         local meta = core.get_meta(pos)
         local owner = meta:get_string('owner')
         if owner == name then
            core.show_formspec(name, 'asrs:control_panel', asrs.settings(pos))
         end
      elseif fields.sort then
         asrs.sort_inventory(pos)
      elseif fields.debug then
         core.show_formspec(name, 'asrs:control_panel', asrs.debug(pos))
      elseif fields.help then
         core.show_formspec(name, 'asrs:control_panel', asrs_help)
      elseif fields.settings_save then
         local meta = core.get_meta(pos)
         local owner = meta:get_string('owner')
         if owner == name then
            local sys_id = meta:get_string('system_id')
            meta:set_string('infotext', fields.name)
            asrs.data[sys_id].infotext = fields.name
            meta:set_string('players', fields.players)
            if tonumber(fields.inv_rows) then
               meta:set_int('rows', math.max(3,(math.min(fields.inv_rows,20))))
            else
               meta:set_int('rows', 3)
            end
         else
            core.chat_send_player(name, 'Only the owner can change these options.')
         end
      elseif fields.settings_remove then
         local meta = core.get_meta(pos)
         local owner = meta:get_string('owner')
         local node = core.get_node(pos)
         if owner == name then
            asrs.remove_side_node(pos, node)
            core.remove_node(pos)
            local sys_id = meta:get_string('system_id')
            if sys_id ~= '' then
               asrs.data[sys_id] = nil
            end
            local player_inv = player:get_inventory()
            if player_inv:room_for_item('main', 'asrs:controller') then
               player_inv:add_item('main', 'asrs:controller')
            else
               local drop_pos = player:get_pos()
               core.add_item(drop_pos, 'asrs:controller')
            end
            core.close_formspec(name, 'asrs:control_panel')
         end
      elseif fields.exit then
         core.close_formspec(name, 'asrs:control_panel')
      end
   end
end)
