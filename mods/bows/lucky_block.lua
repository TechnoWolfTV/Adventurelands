
local S = minetest.get_translator("bows")

-- custom lb function

local function arrow_to_knee(pos, player)

	local ppos = player:get_pos()

	player:punch(player, 1.0, {
		full_punch_interval = 1.0,
		damage_groups = {fleshy = 6}
	}, nil)

	minetest.sound_play("player_damage",
			{pos = ppos, gain = 1.0, max_hear_distance = 10}, true)

	minetest.chat_send_player(player:get_player_name(),
			lucky_block.green .. S("You took an arrow to the knee!"))

	minetest.add_item(ppos, "bows:arrow_steel")
end

-- add lucky blocks

lucky_block:add_blocks({
	{"cus", arrow_to_knee},
	{"dro", {"bows:bow_wood"}},
	{"dro", {"bows:bow_steel"}},
	{"dro", {"bows:bow_bronze"}},
	{"dro", {"bows:arrow"}, 10},
	{"dro", {"bows:arrow_steel"}, 8},
	{"dro", {"bows:arrow_mese"}, 7},
	{"dro", {"bows:arrow_diamond"}, 6},
	{"nod", "default:chest", 0, {
		{name = "default:stick", max = 5},
		{name = "default:flint", max = 5},
		{name = "default:steel_ingot", max = 5},
		{name = "default:bronze_ingot", max = 5},
		{name = "default:mese_crystal_fragment", max = 5},
		{name = "farming:string", max = 5},
		{name = bows.feather, max = 5},
		{name = "bows:bow_bowie", max = 1, chance = 5}
	}}
})
