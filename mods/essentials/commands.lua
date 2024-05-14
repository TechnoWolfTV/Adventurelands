local enable_damage = core.settings:get_bool("enable_damage")

minetest.register_chatcommand("ip", {
    params = "<name>",
    description = "Show the IP of a player.",
    privs = {server = true},
    func = function(name, param)
		if param == "" then
			minetest.chat_send_player(name, "Your IP address is ".. minetest.get_player_ip(name))
			return
        end
        if minetest.get_player_by_name(param) == nil then
			minetest.chat_send_player(name, core.colorize("red", "Player ".. param .." not found!"))
            minetest.sound_play("error", name)
			return
		end
		minetest.chat_send_player(name, "IP address of ".. param .." is ".. minetest.get_player_ip(param))
    end,
})

minetest.register_chatcommand("broadcast", {
    params = "<message>",
    description = "Send GLOBAL message in chat.",
    privs = {broadcast = true},
    func = function(name, param)
        if param == "" then
            core.chat_send_player(name, core.colorize("red", "Message cannot be empty!"))
            minetest.sound_play("error", name)
            return
        end
        if minetest.check_player_privs(name, {server=true}) then
            core.chat_send_all(core.colorize("#0006FF", "[Announcement] ")..core.colorize("#00FFC6", param))
        else
            core.chat_send_all(core.colorize("#0006FF", "[Announcement] ")..core.colorize("#00FFC6", param).." "..core.colorize("#82909D", string.format("(Announced by %s)", name)))
        end
        for _, player in ipairs(minetest.get_connected_players()) do
            minetest.sound_play("broadcast", player:get_player_name())
        end
    end,
})

minetest.register_chatcommand("biome", {
    params = "<info_name>",
    description = "Shows the current biome information you are in.",
    func = function(name, param)
        local pos = minetest.get_player_by_name(name):get_pos()
        local biomeinfo = minetest.get_biome_data(pos)
        local biome = minetest.get_biome_name(biomeinfo.biome)
        if param == "" then
            core.chat_send_player(name, "Biome: \"".. biome .."\"")
        else
            if minetest.check_player_privs(name, {server=true}) then
                if param == "heat" then
                    core.chat_send_player(name, "\"".. biome .."\": ".. biomeinfo.heat)
                elseif param == "humidity" then
                    core.chat_send_player(name, "\"".. biome .."\": ".. biomeinfo.humidity)
                else
                    core.chat_send_player(name, core.colorize("red", "You specialized wrong information name!"))
                    minetest.sound_play("error", name)
                end
            else
                core.chat_send_player(name, core.colorize("red", "You cant check more information without privelege!"))
                minetest.sound_play("error", name)
            end
        end
    end,
})

--minetest.get_mapgen_object
if essentials.seed then
    minetest.register_chatcommand("seed", {
        description = "Shows the seed of mapgen.",
        func = function(name, param)
            core.chat_send_player(name, "Seed: ["..core.colorize("#00ff00", minetest.get_mapgen_setting("seed")).."]")
        end,
    })
else
    minetest.register_chatcommand("seed", {
        privs = {server = true},
        description = "Shows the seed of mapgen.",
        func = function(name, param)
            core.chat_send_player(name, "Seed: ["..core.colorize("#00ff00", minetest.get_mapgen_setting("seed")).."]")
        end,
    })
end

-- god mode
function god_mode_switch(name, param)
    if enable_damage then
        local player = minetest.get_player_by_name(name)
        local ag = player:get_armor_groups()
        if not ag["immortal"] then
            ag["immortal"] = 1
            core.chat_send_player(name, "God mode enabled")
            minetest.sound_play("god_enabled", name)
        else
            ag["immortal"] = nil
            core.chat_send_player(name, "God mode disabled")
            minetest.sound_play("god_disabled", name)
        end
        player:set_armor_groups(ag)
    else
        core.chat_send_player(name, core.colorize("red", "\"enable_damage\" is disabled!"))
        minetest.sound_play("error", name)
    end
end

minetest.register_chatcommand("god", {
    description = "Enable/Disabe the god mode.",
    privs = {god_mode = true},
    func = god_mode_switch
})
-- end

minetest.register_chatcommand("ban_menu", {
    description = "Open the ban menu.",
    privs = {ban = true},
    func = function(name, param)
        if core.is_singleplayer() then
            minetest.chat_send_player(name, core.colorize("red", "You cannot ban in single mode!"))
            minetest.sound_play("error", name)
            return
        end
        show_ban_menu(name)
    end
})

minetest.register_chatcommand("kick_menu", {
    description = "Open the kick menu.",
    privs = {kick = true},
    func = function(name, param)
        if core.is_singleplayer() then
            minetest.chat_send_player(name, core.colorize("red", "You cannot kick in single mode!"))
            minetest.sound_play("error", name)
            return
        end
        show_kick_menu(name)
    end
})

--[[
minetest.register_chatcommand("mute_menu", {
   description = "Open the mute menu.",
   privs = {mute = true},
   func = function(name, param)
       if core.is_singleplayer() then
           minetest.chat_send_player(name, core.colorize("red", "You cannot mute in single mode!"))
       else
           show_mute_menu(name)
       end
   end
})
]]--

minetest.register_chatcommand("getpos", {
    params = "<name>",
    description = "Allows the player to find out the position of another player.",
    privs = {teleport = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(param);
		if param == "" then
			minetest.chat_send_player(name, core.colorize("red", "Player name cannot be empty!"))
            minetest.sound_play("error", name)
			return
        elseif minetest.get_player_by_name(param) == nil then
			minetest.chat_send_player(name, core.colorize("red", "Player ".. param .." not found!"))
            minetest.sound_play("error", name)
            return
        end
        local pos = player:get_pos();
        local round_pos = vector.round(pos);
		minetest.chat_send_player(name, "Position of ".. param .." is ".. round_pos.x .." ".. round_pos.y .." ".. round_pos.z)
        minetest.sound_play("done", name)
    end,
})

minetest.register_chatcommand("rename_me", {
	description = "Show the rename menu.",
	privs = {rename_player = true},
	func = function(name, param)
        show_rename_menu(name)
	end
})

minetest.register_chatcommand("rename_item", {
	description = "Hold item in hand and open this menu for renaming it.",
	privs = {rename_item = true},
	func = function(name, param)
        show_renameitem_menu(name)
	end
})

minetest.register_chatcommand("color", {
	description = "Shows menu for coloring nickname.",
	privs = {colored_nickname = true},
	func = function(name, param)
        show_color_menu(name)
	end
})

minetest.register_chatcommand("set_color", {
    params = "<name> <color>",
	description = "Sets a color for nickname of any player.",
	privs = {server = true},
	func = function(name, param)
        local toname, color = string.match(param, "^([^ ]+) +(.+)$")
        if not toname then
            minetest.chat_send_player(name, core.colorize("red", "Please, specify an nickname of player."))
            return
        end
        if not color then
            minetest.chat_send_player(name, core.colorize("red", "Please, specify an color for nickname."))
            return
        end
        if minetest.get_player_by_name(toname) == nil then
            minetest.chat_send_player(name, core.colorize("red", "Thats player offline or doesnt exist!"))
        else
            minetest.chat_send_player(name, string.format("Color of nickname for player %s successfully changed to %s", toname, color))
            if essentials.changed_by then
                minetest.chat_send_player(toname, core.colorize("#00FF00", "Your color of nickname changed to \'".. color .."\' by ".. name))
            end
            minetest.get_player_by_name(toname):set_properties({
                nametag_color = color
            })
        end
	end
})

minetest.register_chatcommand("kill", {
    params = "<name>",
	description = ("Kill anyone with command."),
    privs = {server = true},
    func = function(name, param)
        if minetest.settings:get_bool("enable_damage") then
            if param == "" or param == nil then
                minetest.get_player_by_name(name):set_hp(0)
            else
                if minetest.get_player_by_name(param) == nil then
                    core.chat_send_player(name, core.colorize("red", "Player ".. param .." not found!"))
                    minetest.sound_play("error", name)
                    return
                end
                minetest.get_player_by_name(param):set_hp(0)
                core.chat_send_player(name, "You killed "..param..".")
                if essentials.killed_by then
                    core.chat_send_player(param, string.format("You has been killed by administrator %s.", name))
                end
            end
        else
            local player = minetest.get_player_by_name(name)
            if param then
                player = minetest.get_player_by_name(param)
                if minetest.get_player_by_name(param) == nil then
                    core.chat_send_player(name, core.colorize("red", "Player ".. param .." not found!"))
                    minetest.sound_play("error", name)
                    return
                end
                if essentials.killed_by then
                    core.chat_send_player(param, string.format("You has been respawned by %s.", name))
                end
            end
            for _, callback in pairs(minetest.registered_on_respawnplayers) do
                if callback(player) then
                    return true
                end
            end
            return false, "No static_spawnpoint defined"
        end
    end,
})


--[[
minetest.register_chatcommand("v", {
    params = "<name>",
    description = "Make player invisible",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(param)
        if param == "" then
            if invisibility[name] then
                invisible(name, false)
                minetest.chat_send_player(name, "Now you are visible!")
                
            elseif not invisibility[name] then
                invisible(name, true)
                minetest.chat_send_player(name, core.colorize("#AAAAAA", "Now you are invisible!"))
                
            end
        elseif not player then
            minetest.chat_send_player(name, core.colorize("red", "Player ".. param .." not found!"))
            minetest.sound_play("error", name)
        else
            if invisibility[param] then
                invisible(param, false)
                minetest.chat_send_player(name, "Now player ".. param .." are visible!")
                minetest.chat_send_player(player, "Now you visible from ".. name .."!")
                
                minetest.sound_play("done", player)
            elseif not invisibility[param] then
                invisible(param, true)
                minetest.chat_send_player(name, core.colorize("#AAAAAA", "Now player ".. param .." are invisible!"))
                minetest.chat_send_player(name, core.colorize("#AAAAAA", "Now you are invisible from ".. name .."!"))
                
                minetest.sound_play("done", player)
            end
        end
    end
})
]]--