
minetest.register_privilege("painting_export", {
    description = "Right for export painting into files in world directory.",
    give_to_singleplayer = false,
    give_to_admin = false,
  })

minetest.register_privilege("painting_import", {
    description = "Right for import painting from files in world directory.",
    give_to_singleplayer = false,
    give_to_admin = false,
  })

minetest.register_chatcommand("painting_export", {
    params = "<filename> [position]",
    description = "Export painting data to lua file in world directory. If not position is set, wielded item is used.",
    privs = {painting_export=true},
    func = function(name, param)
        local params = string.split(param or "", " ")
        if (param==nil) or (param=="") then
          return false, "Use /painting_export file_name [position]"
        end
        
        local data = nil
        if #params>1 then
          -- node
          local pos = minetest.string_to_pos(params[2])
          if (not pos) then
            return false, "Bad position format."
          end
          local node_meta = minetest.get_meta(pos)
          data = {
              res = node_meta:get_int("resolution"),
              version = node_meta:get_string("version"),
              grid = node_meta:get_string("grid"),
            }
        else
          -- wielded item
          local player = minetest.get_player_by_name(name)
          local stack = player:get_wielded_item()
          local meta = stack:get_meta()
          data = {
              res = meta:get_int("resolution"),
              version = meta:get_string("version"),
              grid = meta:get_string("grid"),
            }
        end
        if (data.grid=="") then
          return false, "Wielded item or node is not valid painting."
        else
          data.grid = minetest.deserialize(painting.decompress(data.grid))
        end
        if (not data) or (not data.grid) or (data.grid=="") then
          return false, "Wielded item or node is not valid painting."
        end
        if data.version ~= painting.current_version then
          return false, "Wielded item or node is old version painting."
        end
        if painting.file_exists(params[1]) then
          return false, "File \""..pstsmd[1].."\" already exists."
        end
        if painting.string_to_file(params[1], minetest.serialize(data)) then
          return true, "Painting has been exported to file \""..params[1].."\"."
        end
        return false, "Exporting painting to file failed."
      end,
  })

minetest.register_chatcommand("painting_import", {
    params = "<filename> [position]",
    description = "Import painting data from lua file in world directory. If not position is set, wielded item is used.",
    privs = {painting_import=true},
    func = function(name, param)
        local params = string.split(param or "", " ")
        if (param==nil) or (param=="") then
          return false, "Use /painting_export file_name [position]"
        end
        
        local data = painting.file_to_string(params[1])
        if (not data) then
          return false, "File reading failed."
        end
        data = minetest.deserialize(data)
        
        if (not data.res) or (not data.version) or (not data.grid) then
          return false, "Bad imported data format.."
        end
        
        if (data.res>64) then
          return false, "Resolution of imported image is buigger then 64."
        end
        
        if #params>1 then
          -- node
          local pos = minetest.string_to_pos(params[2])
          if (not pos) then
            return false, "Bad position format."
          end
          local node_meta = minetest.get_meta(pos)
          node_meta:set_int("resolution", data.res)
          node_meta:set_string("version", data.version)
          node_meta:set_string("grid", painting.compress(minetest.serialize(data.grid)))
        else
          -- wielded item
          local player = minetest.get_player_by_name(name)
          local stack = player:get_wielded_item()
          local meta = stack:get_meta()
          meta:set_int("resolution", data.res)
          meta:set_string("version", data.version)
          meta:set_string("grid", painting.compress(minetest.serialize(data.grid)))
          player:set_wielded_item(stack)
        end
        return true, "Painting has been imported."
    end,
  })

