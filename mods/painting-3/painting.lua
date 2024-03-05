
local S = painting.translator

local hexcolors = painting.hexcolors
local colors = painting.colors
local revcolors = painting.revcolors

local thickness = 0.1

-- picture node
local picbox = {
	type = "fixed",
	fixed = { -0.499, -0.499, 0.499, 0.499, 0.499, 0.499 - thickness }
}

local current_version = "hexcolors"
local legacy = {}

painting.current_version = current_version

-- puts the version before the compressed data
local function get_metastring(data)
	return current_version.."(version)"..data
end

-- Initiate a white grid.
local function initgrid(res)
	local grid, a, x, y = {}, res-1
	for x = 0, a do
		grid[x] = {}
		for y = 0, a do
			grid[x][y] = hexcolors["white"]
		end
	end
	return grid
end

local function dot(v, w)	-- Inproduct.
	return	v.x * w.x + v.y * w.y + v.z * w.z
end

local function intersect(pos, dir, origin, normal)
	local t = -(dot(vector.subtract(pos, origin), normal)) / dot(dir, normal)
	return vector.add(pos, vector.multiply(dir, t))
end

local function clamp(x, min,max)
	return math.max(math.min(x, max),min)
end

minetest.register_node("painting:pic", {
	description = S("Picture"),
	tiles = { "painting_white.png" },
	inventory_image = "painting_painted.png",
	drawtype = "nodebox",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = picbox,
	selection_box = picbox,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2,
		not_in_creative_inventory=1},

	--handle that right below, don't drop anything
	drop = "",

	after_dig_node = function(pos, _, oldmetadata, digger)
		--find and remove the entity
		for _,e in pairs(minetest.get_objects_inside_radius(pos, 0.5)) do
			if e:get_luaentity().name == "painting:picent" then
				e:remove()
			end
		end

		--put picture data back into inventory item
		local picture = ItemStack("painting:paintedcanvas")
		local meta = picture:get_meta()
		meta:set_int("resolution", oldmetadata.fields["resolution"] or 16)
		meta:set_string("version", oldmetadata.fields["version"])
		meta:set_string("grid", oldmetadata.fields["grid"])
		local inv = digger:get_inventory()
		if inv:room_for_item("main", picture) then
			inv:add_item("main", picture)
		else
			minetest.add_item(digger:get_pos(), picture)
		end
	end
})

-- picture texture entity
minetest.register_entity("painting:picent", {
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	visual = "upright_sprite",
	textures = { "painting_white.png" },

	on_activate = function(self, staticdata)
		local pos = self.object:get_pos()
		local node_meta = minetest.get_meta(pos)
		local data = {
			res = node_meta:get_int("resolution"),
			version = node_meta:get_string("version"),
			grid = node_meta:get_string("grid"),
		}
		if (data.grid=="") then
			-- old version load
			data = legacy.load_itemmeta(node_meta:get_string("painting:picturedata"))
		else
			data.grid = minetest.deserialize(painting.decompress(data.grid))
		end
		if (not data) or (not data.grid) or (data.grid=="") then
			return
		end
		if data.version ~= current_version then
			minetest.log("info", "[painting] updating placed picture data")
			legacy.fix_grid(data.grid, data.version)
			data.version = current_version
			node_meta:set_int("resolution", data.res)
			node_meta:set_string("version", data.version)
			node_meta:set_string("grid", painting.compress(minetest.serialize(data.grid)))
		end
		self.object:set_properties{textures = { painting.to_imagestring(data.grid, data.res) }}
	end
})

-- Figure where it hits the canvas, in fraction given position and direction.

local function figure_paint_pos_raw(pos, d,od, ppos, l, eye_height)
	ppos.y = ppos.y + eye_height

	local normal = { x = d.x, y = 0, z = d.z }
	local p = intersect(ppos, l, pos, normal)

	local off = -0.5
	pos = vector.add(pos, {x=off*od.x, y=off, z=off*od.z})
	p = vector.subtract(p, pos)
	return math.abs(p.x + p.z), 1 - p.y
end

local dirs = {	-- Directions the painting may be.
	[0] = { x = 0, z = 1 },
	[1] = { x = 1, z = 0 },
	[2] = { x = 0, z =-1 },
	[3] = { x =-1, z = 0 }
}
-- .. idem .. given self and puncher.
local function figure_paint_pos(self, puncher)
	local x,y = figure_paint_pos_raw(self.object:get_pos(),
		dirs[self.fd], dirs[(self.fd + 1) % 4],
		puncher:get_pos(), puncher:get_look_dir(),
		puncher:get_properties().eye_height)
	return math.floor(self.res*clamp(x, 0, 1)), math.floor(self.res*clamp(y, 0, 1))
end

local function HexToRGBA(hex)
  local color = {
      r = tonumber(string.sub(hex, 1, 2), 16),
      g = tonumber(string.sub(hex, 3, 4), 16),
      b = tonumber(string.sub(hex, 5, 6), 16),
			a = 255,
    }
	if hex:len()==8 then
		color.a = tonumber(string.sub(hex, 7, 8), 16)
	end
	return color
end
local function RGBAToHex(color)
  local hex = string.format("%02x%02x%02x", color.r, color.g, color.b)
	if (color.a~=255) then
		hex = hex..string.format("%02x", color.a)
	end
	return hex
end

local function apply_color(self, x, y, a, color)
	if 			(x>=0) and (x<self.res) 
			and (y>=0) and (y<self.res) then
		local add_clr = HexToRGBA(color)
		local have_clr = HexToRGBA(self.grid[x][y])
		
		-- Ao = Aa + Ab(1-Aa)
		-- Co = (CaAa+CbAb(1-Aa))/Ao
		local aa = add_clr.a/255 * a
		local ha = (have_clr.a/255)*(1-aa)
		local ja = aa + ha
		
		local new_clr = {
			r = math.round((add_clr.r*aa + have_clr.r*ha)/ja),
			g = math.round((add_clr.g*aa + have_clr.g*ha)/ja),
			b = math.round((add_clr.b*aa + have_clr.b*ha)/ja),
			--a = math.round(ja*255),
      a = 255, -- always without transparency
		}
		
		self.grid[x][y] = RGBAToHex(new_clr)
	end
end

local function apply_brush(self, x, y, brush)
	for _,point in pairs(brush.points) do
		apply_color(self, x+point.x, y+point.y, point.a, brush.color)
	end
end

local function draw_input(self, brush, x,y, as_line)
	local x0 = self.x0
	if as_line and x0 and vector.twoline then -- Draw line if requested *and* have a previous position.
		local y0 = self.y0
		local line = vector.twoline(x0-x, y0-y)	-- This figures how to do the line.
		for _,coord in pairs(line) do
			apply_brush(self, x+coord[1], y+coord[2], brush)
			--self.grid[x+coord[1]][y+coord[2]] = brush.color
		end
	else	-- Draw just single point.
		apply_brush(self, x, y, brush)
		--self.grid[x][y] = brush.color
	end
	self.x0, self.y0 = x, y -- Update previous position.
	-- Actually update the grid.
	self.object:set_properties{textures = { painting.to_imagestring(self.grid, self.res) }}
end

local paintbox = {
	[0] = { -0.5,-0.5,0,0.5,0.5,0 },
	[1] = { 0,-0.5,-0.5,0,0.5,0.5 }
}

-- Painting as being painted.
minetest.register_entity("painting:paintent", {
	collisionbox = { 0, 0, 0, 0, 0, 0 },
	visual = "upright_sprite",
	textures = { "painting_white.png" },

	on_punch = function(self, puncher)
		--check for brush.
		local wielded = puncher:get_wielded_item()
		local def = wielded:get_definition()
		if (not def) or (not def._painting_brush) then -- Not one of the brushes; can't paint.
			return
		end
		local color = def._painting_brush.color
		if not color then
			local meta = puncher:get_wielded_item():get_meta()
			color = meta:get("color")
		end
		if not color then
			minetest.log("warning", "[painting] Brush color not found - "..def.name)
			return
		end

		assert(self.object)
		local x,y = figure_paint_pos(self, puncher)
		draw_input(self, def._painting_brush, x,y, puncher:get_player_control().sneak)
		
		if def._painting_brush.wear then
			wielded:add_wear(def._painting_brush.wear)
			if wielded:get_count()==0 then
				if def._painting_brush.break_stack then
					wielded = ItemStack(def._painting_brush.break_stack)
				end
			end
		end
		puncher:set_wielded_item(wielded)
	end,

	on_activate = function(self, staticdata)
		local data = minetest.deserialize(staticdata)
		if not data then
			return
		end
		self.fd = data.fd
		self.x0, self.y0 = data.x0, data.y0
		self.res = data.res
		self.version = data.version
		self.grid = data.grid
		legacy.fix_grid(self.grid, self.version)
    self.version = current_version
		self.object:set_properties{ textures = { painting.to_imagestring(self.grid, self.res) }}
		if not self.fd then
			return
		end
		self.object:set_properties{ collisionbox = paintbox[self.fd%2] }
		self.object:set_armor_groups{immortal=1}
	end,

	get_staticdata = function(self)
		return minetest.serialize{fd = self.fd, res = self.res,
			grid = self.grid, x0 = self.x0, y0 = self.y0, version = self.version
		}
	end
})

-- just pure magic
local walltoface = {-1, -1, 1, 3, 0, 2}

--paintedcanvas picture inventory item
minetest.register_craftitem("painting:paintedcanvas", {
	description = S("Painted Canvas"),
	inventory_image = "painting_painted.png",
	stack_max = 1,
	groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory=1 },

	on_place = function(itemstack, placer, pointed_thing)
		--place node
		local pos = pointed_thing.above
		if minetest.is_protected(pos, placer:get_player_name()) then
			return
		end

		local under = pointed_thing.under

		local wm = minetest.dir_to_wallmounted(vector.subtract(under, pos))

		local fd = walltoface[wm + 1]
		if fd == -1 then
			return itemstack
		end

		minetest.add_node(pos, {name = "painting:pic", param2 = fd})

		--save metadata
		local item_meta = itemstack:get_meta()
		local node_meta = minetest.get_meta(pos)
		local data = {
			res = item_meta:get_int("resolution"),
			version = item_meta:get_string("version"),
			grid = item_meta:get_string("grid"),
		}
		if data.grid=="" then
			data = legacy.load_itemmeta(itemstack:get_metadata())
			if not data or not data.grid then
				minetest.log("info", "[painting] Painting data fix failed.")
				return itemstack
			end
		end
		legacy.fix_grid(data.grid, data.version)
    data.version = current_version
		node_meta:set_int("resolution", data.res)
		node_meta:set_string("version", data.version)
		node_meta:set_string("grid", data.grid)

		--add entity
		local dir = dirs[fd]
		local off = 0.5 - thickness - 0.01

		pos.x = pos.x + dir.x * off
		pos.z = pos.z + dir.z * off
		
		data.grid = minetest.deserialize(painting.decompress(data.grid))

		local obj = minetest.add_entity(pos, "painting:picent")
		obj:set_properties{ textures = { painting.to_imagestring(data.grid, data.res) }}
		obj:set_yaw(math.pi * fd / -2)

		return ItemStack("")
	end
})

--canvas inventory items
for i = 4,6 do
	minetest.register_craftitem("painting:canvas_"..2^i, {
		description = S("Canvas").." "..(2^i).."x"..(2^i),
		inventory_image = "default_paper.png",
		stack_max = 99,
		_painting_canvas_resolution = 2^i,
	})
end

--canvas for drawing
local canvasbox = {
	type = "fixed",
	fixed = { -0.5, -0.5, 0, 0.5, 0.5, thickness }
}

minetest.register_node("painting:canvasnode", {
	description = S("Canvas"),
	tiles = { "painting_white.png" },
	inventory_image = "painting_painted.png",
	drawtype = "nodebox",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = canvasbox,
	selection_box = canvasbox,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2,
		not_in_creative_inventory=1},

	drop = "",

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		--get data and remove pixels
		local data = {}
		for _,e in pairs(minetest.get_objects_inside_radius(pos, 0.1)) do
			e = e:get_luaentity()
			if e.grid then
				data.grid = e.grid
				data.version = e.version
				data.res = e.res
				e.object:remove()
				break
			end
		end

		pos.y = pos.y-1
		local meta = minetest.get_meta(pos)
		meta:set_int("has_canvas", 0)
		meta:set_int("gametime", minetest.get_gametime()+2)

		if not data.grid then
			return
		end
		legacy.fix_grid(data.grid, data.version)
    data.version = current_version
		local item = ItemStack("painting:paintedcanvas")
		local item_meta = item:get_meta()
		item_meta:set_int("resolution", data.res)
		item_meta:set_string("version", data.version)
		item_meta:set_string("grid", painting.compress(minetest.serialize(data.grid)))
		digger:get_inventory():add_item("main", item)
	end
})

local easelbox = { -- Specifies 3d model.
	type = "fixed",
	fixed = {
		--feet
		{-0.4, -0.5, -0.5, -0.3, -0.4, 0.5 },
		{ 0.3, -0.5, -0.5,	0.4, -0.4, 0.5 },
		--legs
		{-0.4, -0.4, 0.1, -0.3, 1.5, 0.2 },
		{ 0.3, -0.4, 0.1,	0.4, 1.5, 0.2 },
		--shelf
		{-0.5, 0.35, -0.3, 0.5, 0.45, 0.1 }
	}
}

minetest.register_node("painting:easel", {
	description = S("Easel"),
	tiles = { "default_wood.png" },
	drawtype = "nodebox",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = easelbox,
	selection_box = easelbox,

	groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 2 },

	on_punch = function(pos, node, player)
		local meta = minetest.get_meta(pos)
		
		-- prevent canvas to be place immediately into easel again
		if (meta:get_int("gametime")>minetest.get_gametime()) then
			return
		end
		
		local wield_item = player:get_wielded_item()
		local wield_meta = wield_item:get_meta()
		local def = wield_item:get_definition()
		if (not def) or ((not def._painting_canvas_resolution) and (wield_meta:get_int("resolution")==0)) then	-- Can only put the canvas on there.
			return
		end

		pos.y = pos.y+1
		if minetest.get_node(pos).name ~= "air" then
			-- this is not likely going to happen
			return
		end
		local fd = node.param2
		minetest.add_node(pos, { name = "painting:canvasnode", param2 = fd})

		local dir = dirs[fd]
		pos.x = pos.x - 0.01 * dir.x
		pos.z = pos.z - 0.01 * dir.z

		local obj = minetest.add_entity(pos, "painting:paintent")
		obj:set_properties{ collisionbox = paintbox[fd%2] }
		obj:set_armor_groups{immortal=1}
		obj:set_yaw(math.pi * fd / -2)
		local ent = obj:get_luaentity()
		local wield_meta = wield_item:get_meta();
		local data = {
			res = wield_meta:get_int("resolution"),
			version = wield_meta:get_string("version"),
			grid = wield_meta:get_string("grid"),
		}
		if (data.res>0) and (data.version=="hexcolors") and (data.grid~="") then
			ent.grid = minetest.deserialize(painting.decompress(data.grid))
			ent.res = data.res
			ent.version = data.version
			obj:set_properties{textures = { painting.to_imagestring(ent.grid, ent.res) }}
		else
			ent.grid = initgrid(def._painting_canvas_resolution)
			ent.res = def._painting_canvas_resolution
			ent.version = current_version
		end
		ent.fd = fd

		meta:set_int("has_canvas", 1)
		player:get_inventory():remove_item("main", wield_item:take_item())
	end,

	can_dig = function(pos)
		return minetest.get_meta(pos):get_int("has_canvas") == 0
	end
})

--brushes
local brush = {
	wield_image = "",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=0,
		groupcaps = {}
	},
	groups = {not_in_creative_inventory = 1},
	_painting_brush = {
		points = {
			{x=0,y=0,a=1},
		},
		wear = 256,
	},
}

local textures = {
	white = "white.png", yellow = "yellow.png",
	orange = "orange.png", red = "red.png",
	violet = "violet.png", blue = "blue.png",
	green = "green.png", magenta = "magenta.png",
	cyan = "cyan.png", grey = "grey.png",
	dark_grey = "darkgrey.png", black = "black.png",
	dark_green = "darkgreen.png", brown="brown.png",
	pink = "pink.png"
}

minetest.register_craftitem("painting:brush", {
		description = "Brush",
		inventory_image = "painting_brush_stem.png^(painting_brush_head.png^[colorize:#FFFFFF:128)^painting_brush_head.png",
	})

local vage_revcolours = {} -- ← colours in pairs order
for color, _ in pairs(textures) do
	local brush_new = table.copy(brush)
	brush_new.description = color:gsub("^%l", string.upper).." brush"
	brush_new.inventory_image = "painting_brush_stem.png^(painting_brush_head.png^[colorize:#"..hexcolors[color]..":255)^painting_brush_head.png"
	brush_new._painting_brush.color = hexcolors[color]
	minetest.register_tool("painting:brush_"..color, brush_new)

	vage_revcolours[#vage_revcolours+1] = color
end

if minetest.get_modpath("unifieddyes") then
	--print("Pallete idx: "..dump(unifieddyes.make_colored_itemstack("painting:brush_white", "extended", "unifieddyes:red")))
end

-- If you want to use custom pairs order, e.g. if the map is played on a
-- different pc, uncomment this line:

--print("vage_revcolours = "..dump(vage_revcolours)) error"↑"

-- then load the world with this mod on the original pc in a terminal, after
-- that put the printed thing ("vage_revcolours = […]}") here ↓



-- then the mod with the world can be used on other pc, of course you need to
-- have re-commented that line above

--[[
for i, color in ipairs(revcolors) do
	colors[color] = i
end
--]]


-- legacy

minetest.register_alias("easel", "painting:easel")
minetest.register_alias("canvas", "painting:canvas_16")

-- fixes the colours which were set by pairs
local function fix_eldest_grid(data)
	for y in pairs(data) do
		local xs = data[y]
		for x in pairs(xs) do
			-- it was done in pairs order
			xs[x] = hexcolors[vage_revcolours[xs[x]]]
		end
	end
	return data
end
local function fix_nopairs_grid(data)
	for y in pairs(data) do
		local xs = data[y]
		for x in pairs(xs) do
			-- it was done in pairs order
			xs[x] = hexcolors[revcolors[xs[x]]]
		end
	end
	return data
end

-- possibly updates grid
function legacy.fix_grid(grid, version)
	if version == current_version then
		return
	end

	minetest.log("info", "[painting] updating grid version "..dump(version))
	--print("Updating grid version "..dump(version))
	
	if version == "nopairs" then
		fix_nopairs_grid(grid)
	else
		fix_eldest_grid(grid)
	end
end

-- gets the compressed data from meta
function legacy.load_itemmeta(data)
	local vend = data:find"(version)"
	if not vend then -- the oldest version
		local t = minetest.deserialize(data)
		if not t then
			minetest.log("error", "[painting] this musn't happen! dump: "..dump(data))
			return {
				grid = initgrid(16),
				res = 16,
				version = current_version,
			}
		end
		if t.version then
			minetest.log("error", "[painting] this musn't happen!")
		end
		minetest.log("info", "[painting] updating painting meta")
		--legacy.fix_grid(t.grid)
		--t.version = current_version
		return t
	end
	local version = data:sub(1, vend-2)
	data = data:sub(vend+8)
	if version == current_version then
		return minetest.deserialize(painting.decompress(data))
	end
	local t = minetest.deserialize(painting.old_decompress(data))
	t.version = version
	--legacy.fix_grid(t.grid)
	--t.version = current_version
	return t
end

--[[ allows using many colours, doesn't work
function to_imagestring(data, res)
	if not data then
		return
	end
	local t,n = {},1
	local sbc = {}
	for y = 0, res - 1 do
		for x = 0, res - 1 do
			local col = revcolors[data[x][y] ]
			sbc[col] = sbc[col] or {}
			sbc[col][#sbc[col] ] = {x,y}
		end
	end
	for col,ps in pairs(sbc) do
		t[n] = "([combine:"..res.."x"..res..":"
		n = n+1
		for _,p in pairs(ps) do
			t[n] = p[1]..","..p[2].."=white.png:"
			n = n+1
		end
		t[n-1] = string.sub(t[n-1], 1,-2)
		t[n] = "^[colorize:"..col..")^"
		n = n+1
	end
	t[n-1] = string.sub(t[n-1], 1,-2)
	return table.concat(t)
end--]]
