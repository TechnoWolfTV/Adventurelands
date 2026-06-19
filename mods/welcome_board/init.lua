-- welcome_board/init.lua
-- Main entry point. Registers join callbacks, tab-switch handling, and /welcome command.

local cfg = dofile(minetest.get_modpath("welcome_board") .. "/config.lua")
local fs  = dofile(minetest.get_modpath("welcome_board") .. "/formspec.lua")

local MODNAME = "welcome_board"

-- ---------------------------------------------------------------------------
-- Helper: is this player's very first join?
-- ---------------------------------------------------------------------------
local function is_new_player(player)
    local meta = player:get_meta()
    return (meta:get_int("welcome_board_joined") == 0)
end

-- ---------------------------------------------------------------------------
-- Helper: mark a player as having joined before
-- ---------------------------------------------------------------------------
local function mark_joined(player)
    player:get_meta():set_int("welcome_board_joined", 1)
end

-- ---------------------------------------------------------------------------
-- Helper: build and show the dialog to a specific player
-- ---------------------------------------------------------------------------
local function show_dialog(player, tab)
    local name    = player:get_player_name()
    local new     = is_new_player(player)
    local formstr, formname = fs.build(cfg, name, new, tab or 1)
    minetest.show_formspec(name, formname, formstr)
end

-- ---------------------------------------------------------------------------
-- Helper: resolve the rules/tips tab index based on which tabs are enabled
-- ---------------------------------------------------------------------------
local function tips_tab_index()
    return cfg.show_tips and 2 or nil
end

local function rules_tab_index()
    if cfg.show_tips  and cfg.show_rules then return 3 end
    if not cfg.show_tips and cfg.show_rules then return 2 end
    return nil
end

-- ---------------------------------------------------------------------------
-- Helper: format the chat notification string
-- ---------------------------------------------------------------------------
local function format_chat_text(player_name, is_new)
    local greeting
    if cfg.vary_return then
        greeting = is_new and cfg.new_player_greeting or cfg.return_greeting
    else
        greeting = cfg.new_player_greeting
    end

    local msg = cfg.chat_text
    msg = msg:gsub("{greeting}", greeting)
    msg = msg:gsub("{player}",   player_name)
    msg = msg:gsub("{server}",   cfg.server_name)
    return msg
end

-- ---------------------------------------------------------------------------
-- on_joinplayer: decide whether to show the dialog
-- ---------------------------------------------------------------------------
minetest.register_on_joinplayer(function(player)
    local name    = player:get_player_name()
    local new     = is_new_player(player)
    local show_on = cfg.show_on

    local should_show = false
    if show_on == "every_join" then
        should_show = true
    elseif show_on == "first_join" and new then
        should_show = true
    end
    -- show_on == "never" leaves should_show as false

    -- Send chat notification regardless of popup setting (if enabled)
    if cfg.chat_notify then
        minetest.after(cfg.delay * 0.5, function()
            local p = minetest.get_player_by_name(name)
            if p then
                minetest.chat_send_player(name,
                    minetest.colorize("#aaddff", format_chat_text(name, new)))
            end
        end)
    end

    if should_show then
        -- Delay popup so the client has time to finish loading
        minetest.after(cfg.delay, function()
            local p = minetest.get_player_by_name(name)
            if p then
                show_dialog(p, 1)
            end
        end)
    end

    -- Mark them as having joined (persists between sessions via player meta)
    -- We do this after the delay so the is_new_player check above still works
    minetest.after(cfg.delay + 0.1, function()
        local p = minetest.get_player_by_name(name)
        if p then mark_joined(p) end
    end)
end)

-- ---------------------------------------------------------------------------
-- on_player_receive_fields: handle tab switches and close
-- ---------------------------------------------------------------------------
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= fs.formname then return false end

    -- Player closed the dialog (button_exit fires automatically)
    if fields.wm_close or fields.quit then
        return true
    end

    -- Tab switch (manual buttons wb_tab_1, wb_tab_2, wb_tab_3)
    for i = 1, 3 do
        if fields["wb_tab_" .. i] then
            show_dialog(player, i)
            return true
        end
    end

    return false
end)

-- ---------------------------------------------------------------------------
-- /welcome command — reopen the dialog at any time
-- ---------------------------------------------------------------------------
minetest.register_chatcommand("welcome", {
    description = "Show the welcome guide dialog.",
    privs       = {},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "You must be in-game to use this command."
        end

        -- Optional: allow /welcome tips or /welcome rules to jump to a tab
        local tab = 1
        if param == "tips" and tips_tab_index() then
            tab = tips_tab_index()
        elseif param == "rules" and rules_tab_index() then
            tab = rules_tab_index()
        end

        show_dialog(player, tab)
        return true, nil
    end,
})

-- ---------------------------------------------------------------------------
-- /welcome_reset command (admin) — clear a player's first-join flag
-- ---------------------------------------------------------------------------
minetest.register_chatcommand("welcome_reset", {
    description = "Reset the first-join flag for a player so they see the welcome dialog again on next join. Usage: /welcome_reset <playername>",
    privs       = { server = true },
    func = function(caller_name, param)
        local target_name = param:match("^%s*(.-)%s*$")
        if target_name == "" then
            return false, "Usage: /welcome_reset <playername>"
        end

        local player = minetest.get_player_by_name(target_name)
        if player then
            -- Player is online — reset directly
            player:get_meta():set_int("welcome_board_joined", 0)
            return true, ("Reset welcome flag for online player '%s'."):format(target_name)
        else
            -- Player is offline — try via storage (note: player meta is only writable when online)
            return false, ("Player '%s' is not currently online. They must be online to reset their flag."):format(target_name)
        end
    end,
})

minetest.log("action", "[welcome_board] Loaded. show_on=" .. cfg.show_on)
