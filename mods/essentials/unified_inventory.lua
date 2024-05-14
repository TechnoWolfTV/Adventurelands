
    unified_inventory.register_button("ban_menu", {
        type = "image",
        image = "unified_inventory_ban.png",
        tooltip = "Ban menu",
        action = function(player)
            local name = player:get_player_name()
		    if minetest.check_player_privs(name, {ban=true}) then
                show_ban_menu(name)
            else
                core.chat_send_player(name, "You dont have privilege \'ban\'!")
            end
        end
    })

    unified_inventory.register_button("kick_menu", {
        type = "image",
        image = "unified_inventory_kick.png",
        tooltip = "Kick menu",
        action = function(player)
            local name = player:get_player_name()
		    if minetest.check_player_privs(name, {kick=true}) then
                show_kick_menu(name)
            else
                core.chat_send_player(name, "You dont have privilege \'kick\'!")
            end
        end
    })

    unified_inventory.register_button("rename_me", {
        type = "image",
        image = "unified_inventory_amogus.png",
        tooltip = "Rename yourself",
        action = function(player)
            local name = player:get_player_name()
		    if minetest.check_player_privs(name, {rename_player=true}) then
                show_rename_menu(name)
            else
                core.chat_send_player(name, "You dont have privilege \'rename_player\'!")
            end
        end
    })
    
    unified_inventory.register_button("rename_item", {
        type = "image",
        image = "unified_inventory_amogus.png",
        tooltip = "Rename item in hand",
        action = function(player)
            local name = player:get_player_name()
		    if minetest.check_player_privs(name, {rename_item=true}) then
                show_renameitem_menu(name)
            else
                core.chat_send_player(name, "You dont have privilege \'rename_item\'!")
            end
        end
    })

    unified_inventory.register_button("color_nickname", {
        type = "image",
        image = "unified_inventory_color_nickname.png",
        tooltip = "Coloring your nickname",
        action = function(player)
            local name = player:get_player_name()
		    if minetest.check_player_privs(name, {colored_nickname=true}) then
                show_color_menu(name)
            else
                core.chat_send_player(name, "You dont have privilege \'colored_nickname\'!")
            end
        end
    })

    --[[
    unified_inventory.register_button("mute_menu", {
        type = "image",
        image = "unified_inventory_mute.png",
        tooltip = "Mute menu",
        action = function(player)
            local name = player:get_player_name()
		    if minetest.check_player_privs(name, {mute=true}) then
                show_mute_menu(name)
            else
                core.chat_send_player(name, "You dont have privilege 'mute'!")
            end
        end
    })
    ]]--