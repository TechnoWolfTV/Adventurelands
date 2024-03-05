
local function to_tgacolor(color)
  return {
    tonumber(color:sub(1,2),16),
    tonumber(color:sub(3,4),16),
    tonumber(color:sub(5,6),16),
  }
end

local function to_tgapixels(data, res)
  local pixels = {}
	for y = 0, res - 1 do
    pixels[y+1] = {}
		local xs = data[y]
		for x = 0, res - 1 do
			pixels[y+1][x+1] = to_tgacolor(xs[x] or "000000")
    end
  end
  
  return pixels
end

minetest.register_chatcommand("painting_export_tga", {
    params = "<filename> [position]",
    description = "Export painting data to tga file in world directory. If not position is set, wielded item is used.",
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
        local pixels = to_tgapixels(data.grid, data.res)
        tga_encoder.image(pixels):save(painting.complete_path(params[1]))
        return true, "Painting has been exported to file \""..params[1].."\"."
      end,
  })

