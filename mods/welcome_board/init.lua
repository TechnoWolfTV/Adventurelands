-- welcome_board/init.lua
-- Entry point: join callbacks, author privilege, in-game editing, pagination.

local modpath = minetest.get_modpath("welcome_board")
local cfg     = dofile(modpath .. "/config.lua")
local fs      = dofile(modpath .. "/formspec.lua")
local storage = dofile(modpath .. "/storage.lua")
local pagination = dofile(modpath .. "/pagination.lua")

-- ---------------------------------------------------------------------------
-- Author privilege — NEVER auto-granted, not even to singleplayer or admin.
-- Must be granted explicitly with: /grant <name> welcome_board_author
-- ---------------------------------------------------------------------------
minetest.register_privilege("welcome_board_author", {
    description = "Allows editing the Welcome Board content in-game "
        .. "(open with /welcome, then click Edit). The 'server' privilege also grants this.",
    give_to_singleplayer = false,
    give_to_admin = false,
})

-- ---------------------------------------------------------------------------
-- Per-player UI state (transient, lives only while dialog is open)
-- ---------------------------------------------------------------------------
local ui_state = {}

local function get_state(name)
    if not ui_state[name] then
        ui_state[name] = {
            active_tab = 1,
            page = 1,
            edit_mode = false,
            is_author = false,
        }
    end
    return ui_state[name]
end

-- Editing is allowed for holders of welcome_board_author OR server.
-- This lets server owners edit out of the box while still allowing narrow
-- delegation of content editing to a trusted non-server player.
local function is_author(name)
    return minetest.check_player_privs(name, { welcome_board_author = true })
        or minetest.check_player_privs(name, { server = true })
end

-- ---------------------------------------------------------------------------
-- First-join tracking via player meta
-- ---------------------------------------------------------------------------
local function is_new_player(player)
    return (player:get_meta():get_int("welcome_board_joined") == 0)
end

local function mark_joined(player)
    player:get_meta():set_int("welcome_board_joined", 1)
end

-- ---------------------------------------------------------------------------
-- Show the dialog
-- ---------------------------------------------------------------------------
local function show_dialog(player, opts)
    opts = opts or {}
    local name = player:get_player_name()
    local st = get_state(name)

    if opts.tab then st.active_tab = opts.tab end
    if opts.page then st.page = opts.page end
    if opts.reset_page then st.page = 1 end
    st.is_author = is_author(name)
    -- Non-authors can never be in edit mode
    if not st.is_author then st.edit_mode = false end

    local new = is_new_player(player)
    local formstr, formname = fs.build(cfg, storage, name, new, st)
    minetest.show_formspec(name, formname, formstr)
end

-- ---------------------------------------------------------------------------
-- Chat notification helper
-- ---------------------------------------------------------------------------
local function format_chat_text(player_name, new)
    local greeting
    if cfg.vary_return then
        greeting = new and cfg.new_player_greeting or cfg.return_greeting
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
-- on_joinplayer
-- ---------------------------------------------------------------------------
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local new  = is_new_player(player)
    local show_on = cfg.show_on

    local should_show = (show_on == "every_join")
        or (show_on == "first_join" and new)

    if cfg.chat_notify then
        minetest.after(cfg.delay * 0.5, function()
            if minetest.get_player_by_name(name) then
                minetest.chat_send_player(name,
                    minetest.colorize("#aaddff", format_chat_text(name, new)))
            end
        end)
    end

    if should_show then
        minetest.after(cfg.delay, function()
            local p = minetest.get_player_by_name(name)
            if p then show_dialog(p, { tab = 1, reset_page = true }) end
        end)
    end

    minetest.after(cfg.delay + 0.1, function()
        local p = minetest.get_player_by_name(name)
        if p then mark_joined(p) end
    end)
end)

minetest.register_on_leaveplayer(function(player)
    ui_state[player:get_player_name()] = nil
end)

-- ---------------------------------------------------------------------------
-- Determine which field the active tab maps to
-- ---------------------------------------------------------------------------
local function active_field(st)
    local tabs = fs.get_tabs(cfg)
    local tabdef = tabs[st.active_tab] or tabs[1]
    return tabdef.field
end

-- ---------------------------------------------------------------------------
-- Field receive handler
-- ---------------------------------------------------------------------------
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    local st = get_state(name)
    st.is_author = is_author(name)

    -- ==================================================================
    -- HELP panel
    -- ==================================================================
    if formname == fs.formname_help then
        if fields.wb_help_close then
            show_dialog(player, {})  -- return to main dialog
        end
        return true
    end

    -- ==================================================================
    -- HEADER edit dialog
    -- ==================================================================
    if formname == fs.formname_header then
        if fields.wb_h_cancel or fields.quit then
            show_dialog(player, {})
            return true
        end
        if fields.wb_h_save and st.is_author then
            if fields.wb_h_title    then storage.set("title", fields.wb_h_title) end
            if fields.wb_h_subtitle then storage.set("subtitle", fields.wb_h_subtitle) end
            if fields.wb_h_newgreet then storage.set("new_player_greeting", fields.wb_h_newgreet) end
            if fields.wb_h_retgreet then storage.set("return_greeting", fields.wb_h_retgreet) end
            show_dialog(player, {})
            return true
        end
        return true
    end

    -- ==================================================================
    -- SPLIT confirmation dialog
    -- ==================================================================
    if formname == fs.formname_confirm then
        if fields.wb_confirm_split then
            if st.is_author and st.pending_edit and st.pending_field then
                storage.set(st.pending_field, st.pending_edit)
                st.pending_edit = nil
                st.pending_field = nil
                st.edit_mode = false
                st.page = 1
            end
            show_dialog(player, {})
            return true
        end
        if fields.wb_confirm_cancel or fields.quit then
            -- Keep their unsaved text by stashing it as a temporary override,
            -- then re-open edit mode so they can continue trimming.
            if st.is_author and st.pending_edit and st.pending_field then
                storage.set(st.pending_field, st.pending_edit)
            end
            st.pending_edit = nil
            st.pending_field = nil
            st.edit_mode = true
            show_dialog(player, {})
            return true
        end
        return true
    end

    -- ==================================================================
    -- MAIN dialog
    -- ==================================================================
    if formname ~= fs.formname then return false end

    -- Close
    if fields.wm_close or fields.quit then
        st.edit_mode = false
        return true
    end

    -- Tab switch
    for i = 1, #fs.get_tabs(cfg) do
        if fields["wb_tab_" .. i] then
            st.active_tab = i
            st.page = 1
            st.edit_mode = false
            show_dialog(player, {})
            return true
        end
    end

    -- Pagination
    if fields.wb_prev then
        st.page = math.max(1, st.page - 1)
        show_dialog(player, {})
        return true
    end
    if fields.wb_next then
        st.page = st.page + 1  -- clamped in formspec build
        show_dialog(player, {})
        return true
    end

    -- Open Help panel — available to ALL players
    if fields.wb_help then
        local formstr, fn = fs.build_help(cfg)
        minetest.show_formspec(name, fn, formstr)
        return true
    end

    -- Author-only actions below this point
    if not st.is_author then return true end

    -- Open Header edit dialog
    if fields.wb_edit_header then
        local formstr, fn = fs.build_header(cfg, storage)
        minetest.show_formspec(name, fn, formstr)
        return true
    end

    -- Enter edit mode
    if fields.wb_edit then
        st.edit_mode = true
        show_dialog(player, {})
        return true
    end

    -- Cancel edit
    if fields.wb_cancel then
        st.edit_mode = false
        show_dialog(player, {})
        return true
    end

    -- Save edit
    if fields.wb_save then
        local field = active_field(st)
        local new_text = fields.wb_editbox or ""
        local max_chars = cfg.chars_per_page or 3000

        if #new_text > max_chars then
            -- Warn-first: stash the pending text and show confirmation dialog
            st.pending_edit = new_text
            st.pending_field = field
            local page_count = pagination.count_pages(new_text, max_chars)
            local formstr, formname2 = fs.build_confirm(
                cfg, name, field, #new_text, page_count)
            minetest.show_formspec(name, formname2, formstr)
            return true
        end

        -- Within limit — save directly
        storage.set(field, new_text)
        st.edit_mode = false
        st.page = 1
        show_dialog(player, {})
        return true
    end

    return true
end)

-- ---------------------------------------------------------------------------
-- /welcome — open the dialog any time
-- ---------------------------------------------------------------------------
minetest.register_chatcommand("welcome", {
    description = "Open the Welcome Board (Welcome, Tips, and Rules tabs). "
        .. "Optionally jump to a tab: /welcome tips  or  /welcome rules. "
        .. "Players with 'welcome_board_author' or 'server' can also edit it here.",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "You must be in-game." end

        local st = get_state(name)
        st.edit_mode = false
        local tab = 1
        local tabs = fs.get_tabs(cfg)
        for i, t in ipairs(tabs) do
            if param == "tips"  and t.field == "tips_body"  then tab = i end
            if param == "rules" and t.field == "rules_body" then tab = i end
        end
        show_dialog(player, { tab = tab, reset_page = true })
        return true
    end,
})

-- ---------------------------------------------------------------------------
-- /welcome_reset <name> — reset a player's first-join flag (admin)
-- ---------------------------------------------------------------------------
minetest.register_chatcommand("welcome_reset", {
    description = "Reset the first-join flag for a player so they see the welcome "
        .. "popup again on next join. Requires the 'server' privilege. "
        .. "Usage: /welcome_reset <playername>",
    privs = { server = true },
    func = function(caller, param)
        local target = param:match("^%s*(.-)%s*$")
        if target == "" then return false, "Usage: /welcome_reset <playername>" end
        local player = minetest.get_player_by_name(target)
        if player then
            player:get_meta():set_int("welcome_board_joined", 0)
            return true, ("Reset welcome flag for '%s'."):format(target)
        end
        return false, ("Player '%s' is not online."):format(target)
    end,
})

-- ---------------------------------------------------------------------------
-- /welcome_revert <field> — revert a field to its config default.
-- Allowed for holders of welcome_board_author OR server.
-- ---------------------------------------------------------------------------
minetest.register_chatcommand("welcome_revert", {
    description = "Revert an edited Welcome Board field to its default. "
        .. "Requires the 'welcome_board_author' or 'server' privilege. "
        .. "Fields: title, subtitle, welcome_heading, welcome_body, tips_body, "
        .. "rules_body, new_player_greeting, return_greeting, all",
    func = function(name, param)
        if not is_author(name) then
            return false, "You need the 'welcome_board_author' or 'server' privilege to do that."
        end
        param = param:match("^%s*(.-)%s*$")
        if param == "all" then
            for field, _ in pairs(storage.fields) do
                storage.reset(field)
            end
            return true, "All Welcome Board content reverted to defaults."
        end
        if storage.fields[param] then
            storage.reset(param)
            return true, ("Field '%s' reverted to default."):format(param)
        end
        return false, "Unknown field. Options: title, subtitle, welcome_heading, "
            .. "welcome_body, tips_body, rules_body, new_player_greeting, "
            .. "return_greeting, all"
    end,
})

minetest.log("action", "[welcome_board] Loaded. show_on=" .. cfg.show_on
    .. " chars_per_page=" .. cfg.chars_per_page)
