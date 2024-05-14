local FORMNAME = "essentials:ban_menu"

-- ban menu
function show_ban_menu(name)
	local formspec = [[
        formspec_version[6]
        size[12.5,4.5]
        field[4.5,0.6;6.8,1;player;Player name;]
        field[4.5,2.1;6.8,1;reason;Reason of ban;]
        button[4.5,3.3;6.8,1.1;ban_btn;Ban the player]
        image[0.2,0.2;4.2,4.2;essentials_ban_user.png]
        image_button_exit[11.4,0.1;1,1;essentials_close_btn.png;close_btn;]
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

    if fields.ban_btn then
        local player_ban = minetest.get_player_by_name(fields.player)
        local player_banned = fields.player
        local reason_ban = fields.reason

        if core.is_singleplayer() then
            minetest.chat_send_player(name, core.colorize("red", "You cannot ban in single mode!"))
            minetest.sound_play("error", name)
        elseif not player_ban then
            minetest.chat_send_player(name, core.colorize("red", "Player not found!"))
            minetest.sound_play("error", name)
        elseif reason_ban == "" then
            core.ban_player(fields.player)
            core.chat_send_all("Banned ".. player_banned ..".")
            minetest.sound_play("player_banned")
        else
            core.ban_player(fields.player)
            core.chat_send_all("Banned ".. player_banned .." for ".. reason_ban ..".")
            minetest.sound_play("player_banned")
        end
    end
	return
end)
-- end