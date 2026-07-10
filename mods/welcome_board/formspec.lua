-- welcome_board/formspec.lua
-- Builds the welcome dialog formspec: pagination (top-only), view/edit modes,
-- author controls, header editing, character counter, and an author Help panel.

local FORMNAME         = "welcome_board:dialog"
local FORMNAME_CONFIRM = "welcome_board:confirm"
local FORMNAME_HEADER  = "welcome_board:header"
local FORMNAME_HELP    = "welcome_board:help"

local modpath    = minetest.get_modpath("welcome_board")
local pagination = dofile(modpath .. "/pagination.lua")

local function esc(s)
    return minetest.formspec_escape(s)
end

local function col(color, text)
    return minetest.colorize(color, text)
end

-- Which tabs are shown, and the field each maps to
local function get_tabs(c)
    local tabs = {
        { label = "Welcome", field = "welcome_body" },
    }
    if c.show_announcements then
        table.insert(tabs, { label = c.announcements_tab_label, field = "announcements_body" })
    end
    if c.show_tips  then
        table.insert(tabs, { label = c.tips_tab_label,  field = "tips_body" })
    end
    if c.show_rules then
        table.insert(tabs, { label = c.rules_tab_label, field = "rules_body" })
    end
    return tabs
end

-- Resolve the raw body text for the active tab.
local function get_body(c, storage, active_tab)
    local tabs = get_tabs(c)
    local tabdef = tabs[active_tab] or tabs[1]
    local field = tabdef.field

    if field == "welcome_body" then
        local heading = storage.get("welcome_heading", c)
        local body    = storage.get("welcome_body", c)
        return heading .. "\n\n" .. body, field
    else
        return storage.get(field, c), field
    end
end

-- ---------------------------------------------------------------------------
-- Main dialog
-- ---------------------------------------------------------------------------
local function build_formspec(c, storage, player_name, is_new_player, state)
    state = state or {}
    local active_tab = state.active_tab or 1
    local page       = state.page or 1
    local edit_mode  = state.edit_mode or false
    local is_author  = state.is_author or false

    local w   = c.width
    local h   = c.height
    local pad = 0.3

    local y_title    = 0.65
    local y_subtitle = y_title + 0.6
    local y_greeting = y_subtitle + 0.55
    local tab_bar_y  = y_greeting + 0.6
    local tab_bar_h  = 0.6
    local content_top = tab_bar_y + tab_bar_h + 0.7
    local content_h   = h - content_top - 1.2

    local greeting
    local ng = storage.get("new_player_greeting", c)
    local rg = storage.get("return_greeting", c)
    if c.vary_return then
        greeting = is_new_player and ng or rg
    else
        greeting = ng
    end

    local tabs   = get_tabs(c)
    local n_tabs = #tabs
    local tab_w  = w / n_tabs

    -- Resolve content and paginate
    local body_text, field = get_body(c, storage, active_tab)
    local max_chars = c.chars_per_page or 3000
    local pages = pagination.paginate(body_text, max_chars)
    local num_pages = #pages
    page = pagination.clamp_page(page, num_pages)
    local page_text = pages[page] or ""

    local disp_title    = storage.get("title", c)
    local disp_subtitle = storage.get("subtitle", c)

    local f = {
        "formspec_version[4]",
        ("size[%g,%g]"):format(w, h),
        "no_prepend[]",
        "bgcolor[#00000080;true]",
        "bgcolor[#0000]",
        "background9[0,0;1,1;welcome_board_bg.png;true;16]",

        ("box[0.25,0;%g,0.07;%s]"):format(w - 0.5, c.title_color),
        ("box[0.25,%g;%g,0.07;%s]"):format(h - 0.07, w - 0.5, c.title_color),

        "style_type[label;font=bold;font_size=20]",
        ("label[%g,%g;%s]"):format(pad, y_title, esc(col(c.title_color, disp_title))),

        "style_type[label;font=normal;font_size=15]",
        ("label[%g,%g;%s]"):format(pad, y_subtitle, esc(col(c.subtitle_color, disp_subtitle))),

        "style_type[label;font=bold;font_size=15]",
        ("label[%g,%g;%s]"):format(pad, y_greeting,
            esc(col(c.greeting_color, greeting .. " " .. player_name .. "!"))),

        "style_type[label;font=normal;font_size=16]",

        ("box[0.25,%g;%g,0.03;%s]"):format(tab_bar_y - 0.06, w - 0.5, c.title_color .. "88"),
    }

    -- Help button: visible to ALL players (top-right).
    -- Edit Header button: authors only, sits to the left of Help.
    if is_author then
        table.insert(f, "style[wb_edit_header;bgcolor=#3a5a3a;textcolor=#ffffff;font_size=12]")
        table.insert(f, ("button[%g,%g;1.9,0.5;wb_edit_header;Edit Header]")
            :format(w - pad - 1.9 - 1.2, y_title - 0.05))
    end
    table.insert(f, "style[wb_help;bgcolor=#3a3a5a;textcolor=#ffffff;font_size=12]")
    table.insert(f, ("button[%g,%g;1.1,0.5;wb_help;Help]")
        :format(w - pad - 1.1, y_title - 0.05))

    -- Tab buttons
    for i, tabdef in ipairs(tabs) do
        local bx = (i - 1) * tab_w
        local is_active = (i == active_tab)
        local bg = is_active and c.title_color or "#323232"
        local tc = is_active and "#ffffff"      or "#b0b0b0"
        table.insert(f, ("style[wb_tab_%d;bgcolor=%s;textcolor=%s;font=bold;border=false]")
            :format(i, bg, tc))
        table.insert(f, ("button[%g,%g;%g,%g;wb_tab_%d;%s]")
            :format(bx, tab_bar_y, tab_w, tab_bar_h, i, esc(tabdef.label)))
    end

    table.insert(f, ("box[0.25,%g;%g,0.03;%s]")
        :format(tab_bar_y + tab_bar_h, w - 0.5, c.title_color .. "88"))

    -- Page + author controls row
    local pc_y = tab_bar_y + tab_bar_h + 0.1
    local ctrl_h = 0.45
    if num_pages > 1 then
        table.insert(f, "style[wb_prev;bgcolor=#323232;textcolor=#ffffff]")
        table.insert(f, ("button[%g,%g;0.8,%g;wb_prev;<]"):format(pad, pc_y, ctrl_h))
        table.insert(f, "style[wb_next;bgcolor=#323232;textcolor=#ffffff]")
        table.insert(f, ("button[%g,%g;0.8,%g;wb_next;>]"):format(w - pad - 0.8, pc_y, ctrl_h))
    end
    local page_label = ("Page %d / %d"):format(page, num_pages)
    local label_half_w = (#page_label * 0.115) / 2
    table.insert(f, "style_type[label;font=normal;font_size=13]")
    table.insert(f, ("label[%g,%g;%s]"):format(
        w / 2 - label_half_w, pc_y + 0.22, esc(col("#c2c2c2", page_label))))

    if is_author then
        local ctrl_x = w - pad - (num_pages > 1 and 1.7 or 0.9)
        if not edit_mode then
            table.insert(f, "style[wb_edit;bgcolor=#3a5a3a;textcolor=#ffffff]")
            table.insert(f, ("button[%g,%g;0.8,%g;wb_edit;Edit]"):format(ctrl_x, pc_y, ctrl_h))
        else
            table.insert(f, "style[wb_save;bgcolor=#3a5a3a;textcolor=#ffffff]")
            table.insert(f, ("button[%g,%g;0.8,%g;wb_save;Save]"):format(ctrl_x - 0.9, pc_y, ctrl_h))
            table.insert(f, "style[wb_cancel;bgcolor=#5a3a3a;textcolor=#ffffff]")
            table.insert(f, ("button[%g,%g;0.8,%g;wb_cancel;X]"):format(ctrl_x, pc_y, ctrl_h))
        end
    end

    -- Content area background
    table.insert(f, ("box[%g,%g;%g,%g;#00000040]")
        :format(pad, content_top - 0.05, w - pad * 2, content_h + 0.1))

    if edit_mode and is_author then
        -- Editable textarea (full field, not paginated)
        local full_text = (field == "welcome_body")
            and storage.get("welcome_body", c)
            or  storage.get(field, c)

        table.insert(f, ("textarea[%g,%g;%g,%g;wb_editbox;%s;%s]")
            :format(pad + 0.1, content_top, w - pad * 2 - 0.2, content_h - 0.6,
                esc("Editing: " .. field),
                esc(full_text)))

        local cur_len = #full_text
        local over = cur_len > max_chars
        local counter_col = over and "#ff6666" or "#88ff88"
        local counter_txt = ("%d / %d characters"):format(cur_len, max_chars)
        if over then
            counter_txt = counter_txt .. "  (will split into "
                .. pagination.count_pages(full_text, max_chars) .. " pages on save)"
        end
        table.insert(f, "style_type[label;font=normal;font_size=13]")
        table.insert(f, ("label[%g,%g;%s]"):format(
            pad + 0.1, content_top + content_h - 0.4, esc(col(counter_col, counter_txt))))
    else
        -- Read-only textarea display (tight, uniform line spacing).
        -- An empty field name makes the textarea read-only.
        table.insert(f, ("textarea[%g,%g;%g,%g;;%s;]")
            :format(pad + 0.1, content_top, w - pad * 2 - 0.2, content_h,
                esc(page_text)))
    end

    -- Close button
    table.insert(f, ("style[wm_close;font=bold;font_size=14;bgcolor=%s;textcolor=#1a1a2e]")
        :format(c.title_color))
    table.insert(f, ("button_exit[%g,%g;3.5,0.8;wm_close;%s]")
        :format((w - 3.5) / 2, h - 1.05, esc(c.close_label)))

    return table.concat(f, ""), FORMNAME
end

-- ---------------------------------------------------------------------------
-- Split confirmation dialog (warn-first over-limit save)
-- ---------------------------------------------------------------------------
local function build_split_confirm(c, player_name, field, char_count, page_count)
    local w, h = 9, 4.5
    local f = {
        "formspec_version[4]",
        ("size[%g,%g]"):format(w, h),
        "no_prepend[]",
        "bgcolor[#00000080;true]",
        "bgcolor[#0000]",
        "background9[0,0;1,1;welcome_board_bg.png;true;16]",
        ("box[0.25,0;%g,0.07;%s]"):format(w - 0.5, c.title_color),
        ("box[0.25,%g;%g,0.07;%s]"):format(h - 0.07, w - 0.5, c.title_color),
        "style_type[label;font=bold;font_size=16]",
        ("label[0.4,0.7;%s]"):format(esc(col(c.title_color, "Content Exceeds Page Limit"))),
        "style_type[label;font=normal;font_size=13]",
        ("textarea[0.4,1.2;%g,1.8;;;%s]"):format(w - 0.8,
            esc(("This content is %d characters, over the %d-character limit.\n\n"
                .. "It will be automatically split into %d pages when saved. "
                .. "Page numbering will change accordingly.\n\n"
                .. "Save and split, or keep editing?")
                :format(char_count, c.chars_per_page or 3000, page_count))),
        "style[wb_confirm_split;bgcolor=#3a5a3a;textcolor=#ffffff;font=bold]",
        ("button[0.4,%g;4,0.8;wb_confirm_split;Save & Split]"):format(h - 1.05),
        "style[wb_confirm_cancel;bgcolor=#5a3a3a;textcolor=#ffffff;font=bold]",
        ("button[%g,%g;4,0.8;wb_confirm_cancel;Keep Editing]"):format(w - 4.4, h - 1.05),
    }
    return table.concat(f, ""), FORMNAME_CONFIRM
end

-- ---------------------------------------------------------------------------
-- Header edit dialog (title / subtitle / greetings)
-- ---------------------------------------------------------------------------
local function build_header_edit(c, storage)
    local w, h = 11, 8
    local f = {
        "formspec_version[4]",
        ("size[%g,%g]"):format(w, h),
        "no_prepend[]",
        "bgcolor[#00000080;true]",
        "bgcolor[#0000]",
        "background9[0,0;1,1;welcome_board_bg.png;true;16]",
        ("box[0.25,0;%g,0.07;%s]"):format(w - 0.5, c.title_color),
        ("box[0.25,%g;%g,0.07;%s]"):format(h - 0.07, w - 0.5, c.title_color),
        "style_type[label;font=bold;font_size=18]",
        ("label[0.4,0.65;%s]"):format(esc(col(c.title_color, "Edit Header"))),
        "style_type[label;font=normal;font_size=13]",
        ("label[0.4,1.2;%s]"):format(esc(col("#c2c2c2",
            "Edit the title, subtitle, and greeting prefixes shown at the top."))),

        "field[0.4,1.9;%s,0.7;wb_h_title;Title;%s]",
        "field_close_on_enter[wb_h_title;false]",
        "field[0.4,3.1;%s,0.7;wb_h_subtitle;Subtitle;%s]",
        "field_close_on_enter[wb_h_subtitle;false]",
        "field[0.4,4.3;%s,0.7;wb_h_newgreet;New-player greeting prefix;%s]",
        "field_close_on_enter[wb_h_newgreet;false]",
        "field[0.4,5.5;%s,0.7;wb_h_retgreet;Returning-player greeting prefix;%s]",
        "field_close_on_enter[wb_h_retgreet;false]",

        "style[wb_h_save;bgcolor=#3a5a3a;textcolor=#ffffff;font=bold]",
        ("button[0.4,%g;3,0.8;wb_h_save;Save Header]"):format(h - 1.05),
        "style[wb_h_cancel;bgcolor=#5a3a3a;textcolor=#ffffff;font=bold]",
        ("button[%g,%g;3,0.8;wb_h_cancel;Cancel]"):format(w - 3.4, h - 1.05),
    }

    -- Fill values (fields need width + current value substituted)
    local fw = w - 0.8
    local str = table.concat(f, "")
    str = str:format(
        fw, esc(storage.get("title", c)),
        fw, esc(storage.get("subtitle", c)),
        fw, esc(storage.get("new_player_greeting", c)),
        fw, esc(storage.get("return_greeting", c))
    )
    return str, FORMNAME_HEADER
end

-- ---------------------------------------------------------------------------
-- Help panel — visible to all players; explains editing (which needs a priv).
-- ---------------------------------------------------------------------------
local function build_help(c)
    local w, h = 12, 10
    local help_text = table.concat({
        "Editing the Welcome Board requires the 'welcome_board_author' or 'server'\n",
        "privilege. If you don't have it, you can still read every tab, but the Edit\n",
        "buttons won't appear. Ask a server admin if you'd like editing access.\n",
        "\n",
        "EDITING CONTENT\n",
        "- Open any tab (Welcome, Tips, Rules) and click Edit to change that tab's text.\n",
        "- Click Save to store your changes, or X to cancel without saving.\n",
        "- Click Edit Header (top-right) to change the title, subtitle, and greeting prefixes.\n",
        "- Edits are saved to the world and persist across restarts.\n",
        "\n",
        "REVERTING TO DEFAULTS\n",
        "- Use the chat command /welcome_revert <field> to restore a field to its default.\n",
        "- Fields: title, subtitle, welcome_heading, welcome_body, announcements_body, tips_body, rules_body,\n",
        "  new_player_greeting, return_greeting, or 'all' to reset everything.\n",
        "\n",
        "PAGES\n",
        "- Long content is automatically split into pages of about "
            .. (c.chars_per_page or 3000) .. " characters.\n",
        "- Navigation arrows appear at the top when content spans more than one page.\n",
        "- If you save content longer than one page, you'll be asked to confirm the\n",
        "  split first, so page numbering never changes unexpectedly.\n",
        "\n",
        "TEXT LAYOUT\n",
        "- Press Enter for a new line. Leave a blank line between paragraphs or sections\n",
        "  for clear spacing.\n",
        "- Your text displays exactly as you type it — what you see is what players get.\n",
        "\n",
        "TIPS\n",
        "- Keep each tab focused: Welcome for a greeting, Announcements for news,\n",
        "  Player Guide for gameplay help, and Server Rules for your rules.\n",
        "- The character counter below the edit box turns red if you go over the page\n",
        "  limit, and tells you how many pages it will become.\n",
        "\n",
        "MORE OPTIONS\n",
        "- For advanced customisation — colours, sizing, default content, which tabs\n",
        "  appear, and every available setting — see the mod's README.md file.\n",
    })

    local f = {
        "formspec_version[4]",
        ("size[%g,%g]"):format(w, h),
        "no_prepend[]",
        "bgcolor[#00000080;true]",
        "bgcolor[#0000]",
        "background9[0,0;1,1;welcome_board_bg.png;true;16]",
        ("box[0.25,0;%g,0.07;%s]"):format(w - 0.5, c.title_color),
        ("box[0.25,%g;%g,0.07;%s]"):format(h - 0.07, w - 0.5, c.title_color),
        "style_type[label;font=bold;font_size=18]",
        ("label[0.4,0.55;%s]"):format(esc(col(c.title_color, "Welcome Board Author Guide"))),
        ("textarea[0.3,1.0;%g,%g;;%s;]")
            :format(w - 0.6, h - 2.1, esc(help_text)),
        "style[wb_help_close;bgcolor=" .. c.title_color .. ";textcolor=#1a1a2e;font=bold]",
        ("button[%g,%g;3,0.8;wb_help_close;Back]"):format((w - 3) / 2, h - 1.0),
    }
    return table.concat(f, ""), FORMNAME_HELP
end

return {
    build           = build_formspec,
    build_confirm   = build_split_confirm,
    build_header    = build_header_edit,
    build_help      = build_help,
    formname        = FORMNAME,
    formname_confirm= FORMNAME_CONFIRM,
    formname_header = FORMNAME_HEADER,
    formname_help   = FORMNAME_HELP,
    get_tabs        = get_tabs,
    get_body        = get_body,
}
