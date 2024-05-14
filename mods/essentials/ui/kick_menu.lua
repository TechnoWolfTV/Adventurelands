local FORMNAME = "essentials:kick_menu"

-- ban menu
function show_kick_menu(name)
	local formspec = [[
        formspec_version[6]
        size[12.5,4.5]
        field[1.2,0.6;6.8,1;player;Player name;]
        field[1.2,2.1;6.8,1;reason;Reason of kick;]
        button[1.2,3.3;6.8,1.1;kick_btn;Kick the player]
        image[8.2,0.2;4.2,4.2;essentials_kick_user.png]
        image_button_exit[0.1,0.1;1,1;essentials_close_btn.png;close_btn;]
    ]]

	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
	if formname ~= FORMNAME then
		return
	end

    if fields.close_btn then
        minetest.sound_play("clicked", name)
    end

    if fields.kick_btn then
        local player_kick = minetest.get_player_by_name(fields.player)
        local player_kicked = fields.player
        local reason_kick = fields.reason

        if core.is_singleplayer() then
            minetest.chat_send_player(name, core.colorize("red", "You cannot kick in single mode!"))
            minetest.sound_play("error", name)
        elseif not player_kick then
            minetest.chat_send_player(name, core.colorize("red", "Player not found!"))
            minetest.sound_play("error", name)
        elseif reason_kick == "" then
            core.kick_player(fields.player, fields.reason)
            core.chat_send_all("Kicked ".. player_kicked ..".")
            minetest.sound_play("player_kicked")
        else
            core.kick_player(fields.player, fields.reason)
            core.chat_send_all("Kicked ".. player_kicked .." for ".. reason_kick ..".")
            minetest.sound_play("player_kicked")
        end
    end
	return
end)
-- end