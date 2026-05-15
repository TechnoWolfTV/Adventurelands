
local S = core.get_translator("stamina")

-- colour helpers

local green = core.get_color_escape_sequence("#bada55")
local green2 = core.get_color_escape_sequence("#33ff55")

-- poison and drunk effects function

local effect_me = function(pos, player, def)

	local name = player:get_player_name() ; if not name then return end

	if def.poison or def.drunk then

		player:hud_change(stamina.players[name].hud_id, "text", "stamina_hud_poison.png")
	end

	if def.poison and def.poison > 0 then

		stamina.players[name].poisoned = def.poison

		core.chat_send_player(name, green .. S("Seems you have been poisoned!"))

	elseif def.drunk and def.drunk > 0 then

		stamina.players[name].drunk = def.drunk

		core.chat_send_player(name, green .. S("You suddenly feel tipsy!"))
	end
end

-- restore stamina function

local full_stamina = function(pos, player, def)

	local name = player:get_player_name() ; if not name then return end

	stamina.change(player, 100) -- set to 100 incase of default stamina increase

	core.chat_send_player(name, green2 .. S("You suddenly feel full!"))
end

-- drop food item with chance of food charm

local food_list = {}

if core.get_modpath("default") then
	table.insert(food_list, "default:apple")
	table.insert(food_list, "default:blueberries")
	table.insert(food_list, "farming:bread")
end

core.after(0.1, function() -- let mods load than add all food items to list

	for item, def in pairs(core.registered_items) do
		if def.groups.food then
			table.insert(food_list, item)
		end
	end
end)

local food_drop = function(pos, player, def)

	local drop = food_list[math.random(#food_list)]

	if math.random(100) == 7 then drop = "stamina:charm_hunger" end

	local obj = core.add_item(pos, drop)

	if obj then
		obj:set_velocity({x = math.random() - 0.5, y = 5, z = math.random() - 0.5})
	end
end

-- add lucky blocks

lucky_block:add_blocks({
	{"cus", full_stamina},
	{"cus", effect_me, {poison = 5}},
	{"cus", effect_me, {poison = 10}},
	{"cus", effect_me, {drunk = 30}},
	{"cus", food_drop}
})
