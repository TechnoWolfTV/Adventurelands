-- Minetest 0.4 mod: woodpiles
-- See README.txt for licensing and other information.

local woodpiles_woodpile_formspec =
	"size[8,7;]" ..
	default.gui_bg ..
	default.gui_bg_img ..
	default.gui_slots ..
	"list[context;woodpiles;0,0.3;8,2;]" ..
	"list[current_player;main;0,2.85;8,1;]" ..
	"list[current_player;main;0,4.08;8,3;8]" ..
	"listring[context;woodpiles]" ..
	"listring[current_player;main]" ..
	default.get_hotbar_bg(0, 2.85)

local function get_woodpiles_woodpile_formspec(inv)
	local formspec = woodpiles_woodpile_formspec
	local invlist = inv and inv:get_list("woodpiles")
	-- Inventory slots overlay
	local vx, vy = 0, 0.3
	for i = 1, 16 do
		if i == 9 then
			vx = 0
			vy = vy + 1
		end
		if not invlist or invlist[i]:is_empty() then
			formspec = formspec ..
				"image[" .. vx .. "," .. vy .. ";1,1;woodpiles_woodpile_slot.png]"
		end
		vx = vx + 1
	end
	return formspec
end

minetest.register_node("woodpiles:woodpile", {
	description = "Wood Pile",
	tiles = {"woodpiles_woodpile_wood_top.png", "woodpiles_woodpile_wood_top.png", "woodpiles_woodpile_wood_side.png",
		"woodpiles_woodpile_wood_side.png", "woodpiles_woodpile_wood_front.png", "woodpiles_woodpile_wood_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(nil))
		local inv = meta:get_inventory()
		inv:set_size("woodpiles", 8 * 2)
	end,
	can_dig = function(pos,player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("woodpiles")
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			   " moves stuff in woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			   " moves stuff to woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			   " takes stuff from woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "woodpiles", drops)
		drops[#drops + 1] = "woodpiles:woodpile"
		minetest.remove_node(pos)
		return drops
	end,
})

minetest.register_node("woodpiles:woodpile_acacia", {
	description = "Acacia Wood Pile",
	tiles = {"woodpiles_woodpile_acacia_top.png", "woodpiles_woodpile_acacia_top.png", "woodpiles_woodpile_acacia_side.png",
		"woodpiles_woodpile_acacia_side.png", "woodpiles_woodpile_acacia_front.png", "woodpiles_woodpile_acacia_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(nil))
		local inv = meta:get_inventory()
		inv:set_size("woodpiles", 8 * 2)
	end,
	can_dig = function(pos,player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("woodpiles")
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			   " moves stuff in woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			   " moves stuff to woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			   " takes stuff from woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "woodpiles", drops)
		drops[#drops + 1] = "woodpiles:woodpile"
		minetest.remove_node(pos)
		return drops
	end,
})

minetest.register_node("woodpiles:woodpile_pine", {
	description = "Pine Wood Pile",
	tiles = {"woodpiles_woodpile_pine_top.png", "woodpiles_woodpile_pine_top.png", "woodpiles_woodpile_pine_side.png",
		"woodpiles_woodpile_pine_side.png", "woodpiles_woodpile_pine_front.png", "woodpiles_woodpile_pine_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(nil))
		local inv = meta:get_inventory()
		inv:set_size("woodpiles", 8 * 2)
	end,
	can_dig = function(pos,player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("woodpiles")
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			   " moves stuff in woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			   " moves stuff to woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			   " takes stuff from woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "woodpiles", drops)
		drops[#drops + 1] = "woodpiles:woodpile"
		minetest.remove_node(pos)
		return drops
	end,
})

minetest.register_node("woodpiles:woodpile_junglewood", {
	description = "Junglewood Wood Pile",
	tiles = {"woodpiles_woodpile_junglewood_top.png", "woodpiles_woodpile_junglewood_top.png", "woodpiles_woodpile_junglewood_side.png",
		"woodpiles_woodpile_junglewood_side.png", "woodpiles_woodpile_junglewood_front.png", "woodpiles_woodpile_junglewood_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(nil))
		local inv = meta:get_inventory()
		inv:set_size("woodpiles", 8 * 2)
	end,
	can_dig = function(pos,player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("woodpiles")
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			   " moves stuff in woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			   " moves stuff to woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			   " takes stuff from woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "woodpiles", drops)
		drops[#drops + 1] = "woodpiles:woodpile"
		minetest.remove_node(pos)
		return drops
	end,
})

minetest.register_node("woodpiles:woodpile_aspen", {
	description = "Aspen Wood Pile",
	tiles = {"woodpiles_woodpile_aspen_top.png", "woodpiles_woodpile_aspen_top.png", "woodpiles_woodpile_aspen_side.png",
		"woodpiles_woodpile_aspen_side.png", "woodpiles_woodpile_aspen_front.png", "woodpiles_woodpile_aspen_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = default.node_sound_wood_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(nil))
		local inv = meta:get_inventory()
		inv:set_size("woodpiles", 8 * 2)
	end,
	can_dig = function(pos,player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("woodpiles")
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			   " moves stuff in woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			   " moves stuff to woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			   " takes stuff from woodpiles woodpile at ".. minetest.pos_to_string(pos))
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_woodpiles_woodpile_formspec(meta:get_inventory()))
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "woodpiles", drops)
		drops[#drops + 1] = "woodpiles:woodpile"
		minetest.remove_node(pos)
		return drops
	end,
})


minetest.register_craft({
	output = "woodpiles:woodpile",
	recipe = {
		{"", "default:wood", ""},
		{"default:wood", "default:wood", "default:wood"},
		{"default:wood", "default:wood", "default:wood"},
	}
})

minetest.register_craft({
	output = "woodpiles:woodpile_pine",
	recipe = {
		{"", "default:pine_wood", ""},
		{"default:pine_wood", "default:pine_wood", "default:pine_wood"},
		{"default:pine_wood", "default:pine_wood", "default:pine_wood"},
	}
})

minetest.register_craft({
	output = "woodpiles:woodpile_aspen",
	recipe = {
		{"", "default:aspen_wood", ""},
		{"default:aspen_wood", "default:aspen_wood", "default:aspen_wood"},
		{"default:aspen_wood", "default:aspen_wood", "default:aspen_wood"},
	}
})

minetest.register_craft({
	output = "woodpiles:woodpile_junglewood",
	recipe = {
		{"", "default:junglewood", ""},
		{"default:junglewood", "default:junglewood", "default:junglewood"},
		{"default:junglewood", "default:junglewood", "default:junglewood"},
	}
})

minetest.register_craft({
	output = "woodpiles:woodpile_acacia",
	recipe = {
		{"", "default:acacia_wood", ""},
		{"default:acacia_wood", "default:acacia_wood", "default:acacia_wood"},
		{"default:acacia_wood", "default:acacia_wood", "default:acacia_wood"},
	}
})
