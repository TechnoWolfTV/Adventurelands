
-- check mods active

local stairs_mod = core.get_modpath("stairs")
local stairsplus_mod = core.global_exists("stairsplus")
local ethereal_mod = core.get_modpath("ethereal")
local mod_mcl_core = core.get_modpath("mcl_core")
local mod_mcl_stairs = core.global_exists("mcl_stairs")
local mod_default = core.get_modpath("default")

-- settings

local disable_stone = core.settings:get_bool("cblocks.disable_stone")
local disable_brick = core.settings:get_bool("cblocks.disable_brick")
local disable_glass = core.settings:get_bool("cblocks.disable_glass")
local disable_wood = core.settings:get_bool("cblocks.disable_wood")
local disable_stairs = core.settings:get_bool("cblocks.disable_stairs")

-- make sure we are running either default or mcl_core

if not mod_default and not mod_mcl_core then
	print("[cblocks] No compatible game active!")
	do return end
end

-- default dye colours

local colours = {
	{"black",      "Black",      "#000000b0"},
	{"blue",       "Blue",       "#015dbb70"},
	{"brown",      "Brown",      "#a78c4570"},
	{"cyan",       "Cyan",       "#01ffd870"},
	{"dark_green", "Dark Green", "#005b0770"},
	{"dark_grey",  "Dark Grey",  "#303030b0"},
	{"green",      "Green",      "#61ff0170"},
	{"grey",       "Grey",       "#5b5b5bb0"},
	{"magenta",    "Magenta",    "#ff05bb70"},
	{"orange",     "Orange",     "#ff840170"},
	{"pink",       "Pink",       "#ff65b570"},
	{"red",        "Red",        "#ff000070"},
	{"violet",     "Violet",     "#2000c970"},
	{"white",      "White",      "#abababc0"},
	{"yellow",     "Yellow",     "#e3ff0070"}
}

-- mcl_dye colours

if mod_mcl_core then

	local colors = {
		{"white",     "White",       "#abababc0"},
		{"orange",    "Orange",      "#F9801D"},
		{"magenta",   "Magenta",     "#C74EBD"},
		{"light_blue", "Light Blue", "#3AB3DA"},
		{"yellow",    "Yellow",      "#FED83D"},
		{"lime",      "Lime",        "#80C71F"},
		{"pink",      "Pink",        "#F38BAA"},
		{"gray",      "Gray",        "#474F52"},
		{"silver",    "Silver",      "#9D9D97"},
		{"cyan",      "Cyan",        "#169C9C"},
		{"purple",    "Purple",      "#8932B8"},
		{"blue",      "Blue",        "#3C44AA"},
		{"brown",     "Brown",       "#835432"},
		{"green",     "Green",       "#5E7C16"},
		{"red",       "Red",         "#B02E26"},
		{"black",     "Black",       "#1D1D21"}
	}
end

-- main registration function

local function cblocks_stairs(nodename, odef)

	-- register node

	core.register_node(nodename, odef)

	-- register stairs

	if disable_stairs then return end

	if stairs_mod or stairsplus_mod or mod_mcl_stairs then

		local def = table.copy(odef)

		def.groups.wood = nil ; def.groups.stone = nil

		local mod, name = nodename:match("(.*):(.*)")

		for groupname, value in pairs(def.groups) do

			if groupname ~= "cracky" and groupname ~= "pickaxey"
			and groupname ~= "choppy" and groupname ~= "axey"
			and groupname ~="crumbly" and groupname ~= "shovely"
			and groupname ~="snappy" and groupname ~= "swordy"
			and groupname ~= "oddly_breakable_by_hand" and groupname ~= "handy"
			and groupname ~="flammable" then
				def.groups.groupname = nil
			end
		end

		-- register stairs depending on mod being used

		if stairsplus_mod then

			stairsplus:register_all(mod, name, nodename, {
				description = def.description,
				tiles = def.tiles,
				groups = def.groups,
				sounds = def.sounds
			})

		elseif stairs_mod and stairs
		and stairs.mod and stairs.mod == "redo" then

			stairs.register_all(name, nodename,
				def.groups,
				def.tiles,
				def.description,
				def.sounds,
				def.walign
			)

		elseif stairs_mod and not stairs.mod then

			stairs.register_stair_and_slab(name, nodename,
				def.groups,
				def.tiles,
				("%s Stair"):format(def.description),
				("%s Slab"):format(def.description),
				def.sounds,
				def.walign
			)
		elseif mod_mcl_stairs then

			mcl_stairs.register_stair_and_slab(name, {
				baseitem = nodename,
				description_stair = ("%s Stair"):format(def.description),
				description_slab = ("%s Slab"):format(def.description)
			})
		end
	end
end

-- alias helper function

local function set_alias(col, name)

	if not mod_default or disable_stairs then return end

	core.register_alias("stairs:stair_" .. col .. "_" .. name,
			"stairs:stair_" .. name .. "_" .. col)

	core.register_alias("stairs:slab_" .. col .. "_" .. name,
			"stairs:slab_" .. name .. "_" .. col)

	core.register_alias("stairs:stair_inner_" .. col .. "_" .. name,
			"stairs:stair_inner_" .. name .. "_" .. col)

	core.register_alias("stairs:stair_outer_" .. col .. "_" .. name,
			"stairs:stair_outer_" .. name .. "_" .. col)

	core.register_alias("stairs:slope_" .. col .. "_" .. name,
			"stairs:slope_" .. name .. "_" .. col)
end

-- loop through dye colours

for i = 1, #colours do

	-- helpers

	local colorize = "^[colorize:" .. colours[i][3]
	local dye_mod = mod_mcl_core and "mcl_dye:" or "dye:"

	-- stone brick

	if not disable_stone then

		local stone_nod = mod_mcl_core and "mcl_core:stonebrick" or "default:stonebrick"
		local stone_def = table.copy(core.registered_nodes[stone_nod])

		stone_def.tiles = {"default_stone_brick.png" .. colorize}
		stone_def.description = colours[i][2] .. " Stone Brick"
		stone_def.use_texture_alpha = "opaque"

		cblocks_stairs("cblocks:stonebrick_" .. colours[i][1], stone_def)

		core.register_craft({
			output = "cblocks:stonebrick_" .. colours[i][1] .. " 2",
			recipe = {
				{stone_nod, stone_nod, dye_mod .. colours[i][1]}
			}
		})
	end

	-- glass

	if not disable_glass then

		local glass_nod = mod_mcl_core and "mcl_core:glass" or "default:glass"
		local glass_def = table.copy(core.registered_nodes[glass_nod])

		glass_def.tiles = {"cblocks.png" .. colorize}
		glass_def.drawtype = "glasslike"
		glass_def.description = colours[i][2] .. " Glass Brick"
		glass_def.use_texture_alpha = "blend"

		cblocks_stairs("cblocks:glass_" .. colours[i][1], glass_def)

		set_alias(colours[i][1], "glass")

		core.register_craft({
			output = "cblocks:glass_".. colours[i][1] .. " 2",
			recipe = {
				{glass_nod, glass_nod, dye_mod .. colours[i][1]},
			}
		})
	end

	-- wood

	if not disable_wood then

		local wood_nod = mod_mcl_core and "mcl_core:wood" or "default:wood"
		local wood_def = table.copy(core.registered_nodes[wood_nod])

		wood_def.tiles = {"default_wood.png" .. colorize}
		wood_def.description = colours[i][2] .. " Wooden Planks"
		wood_def.use_texture_alpha = "opaque"

		local col = colours[i][1]

		-- ethereal already has yellow wood so rename to yellow2
		if ethereal_mod and col == "yellow" then
			col = "yellow2"
		end

		cblocks_stairs("cblocks:wood_" .. col, wood_def)

		set_alias(colours[i][1], "wood")

		core.register_craft({
			output = "cblocks:wood_" .. col .. " 2",
			recipe = {
				{wood_nod, wood_nod, dye_mod .. colours[i][1]}
			}
		})
	end

	-- actual brick

	if not disable_brick then

		-- for bricks we make texture grey then colorize it
		colorize = "^[colorizehsl:0,0,50^[colorize:" .. colours[i][3]

		local brick_nod = mod_mcl_core and "mcl_core:brick_block" or "default:brick"
		local brick_def = table.copy(core.registered_nodes[brick_nod])

		brick_def.tiles = mod_mcl_core and {"default_brick.png" .. colorize} or
				{"default_brick.png" .. colorize .. "^[transformFX",
				"default_brick.png" .. colorize}
		brick_def.description = colours[i][2] .. " Brick Block"

		cblocks_stairs("cblocks:brick_" .. colours[i][1], brick_def)

		core.register_craft({
			output = "cblocks:brick_" .. colours[i][1] .. " 2",
			recipe = {
				{brick_nod, brick_nod, dye_mod .. colours[i][1]}
			}
		})
	end
end

-- add lucky blocks

if core.get_modpath("lucky_block") then

	lucky_block:add_blocks({
		{"dro", {"cblocks:wood_"}, 10, true},
		{"dro", {"cblocks:stonebrick_"}, 10, true},
		{"dro", {"cblocks:glass_"}, 10, true},
		{"dro", {"cblocks:brick_"}, 10, true},
		{"exp"}
	})
end


print ("[MOD] CBlocks loaded")
