-- welcome_board/formspec.lua
-- Builds the welcome dialog formspec string.
-- Uses manual button-based tabs instead of tabheader[] for precise layout control.

local FORMNAME = "welcome_board:dialog"

local function get_tabs(c)
    local tabs = { "Welcome" }
    if c.show_tips  then table.insert(tabs, c.tips_tab_label)  end
    if c.show_rules then table.insert(tabs, c.rules_tab_label) end
    return tabs
end

local function esc(s)
    return minetest.formspec_escape(s)
end

local function col(color, text)
    return minetest.colorize(color, text)
end

local function build_formspec(c, player_name, is_new_player, active_tab)
    active_tab = active_tab or 1

    local w   = c.width
    local h   = c.height
    local pad = 0.3

    -- Header rows — slightly more spacing for the larger subtitle/greeting text
    local y_title    = 0.65
    local y_subtitle = y_title + 0.6
    local y_greeting = y_subtitle + 0.55

    -- Tab bar sits below the greeting, no ambiguity
    local tab_bar_y  = y_greeting + 0.6
    local tab_bar_h  = 0.6
    local content_top = tab_bar_y + tab_bar_h + 0.15
    local content_h   = h - content_top - 1.2

    local greeting
    if c.vary_return then
        greeting = is_new_player and c.new_player_greeting or c.return_greeting
    else
        greeting = c.new_player_greeting
    end

    local tabs     = get_tabs(c)
    local n_tabs   = #tabs
    local tab_w    = w / n_tabs

    local body_text
    if active_tab == 1 then
        body_text = c.welcome_heading .. "\n\n" .. c.welcome_body
    elseif active_tab == 2 and c.show_tips then
        body_text = c.tips_body
    elseif (active_tab == 3 and c.show_tips and c.show_rules)
        or  (active_tab == 2 and not c.show_tips and c.show_rules)
    then
        body_text = c.rules_body
    else
        body_text = c.welcome_body
    end

    local f = {
        "formspec_version[4]",
        ("size[%g,%g]"):format(w, h),

        -- CRITICAL: disable the game's default formspec background (formspec_prepend),
        -- which is solid. Without this, the solid default is drawn behind our PNG.
        "no_prepend[]",

        -- Match Unified Inventory exactly: transparent window colour, 9-sliced PNG with alpha
        -- The fullscreen dim darkens the world around the panel for contrast
        "bgcolor[#00000080;true]",
        "bgcolor[#0000]",
        "background9[0,0;1,1;welcome_board_bg.png;true;16]",

        -- Top accent bar (inset from edges so it doesn't overhang the rounded corners)
        ("box[0.25,0;%g,0.07;%s]"):format(w - 0.5, c.title_color),
        -- Bottom accent bar (inset to match)
        ("box[0.25,%g;%g,0.07;%s]"):format(h - 0.07, w - 0.5, c.title_color),

        -- Title
        ("style_type[label;font=bold;font_size=20]"),
        ("label[%g,%g;%s]"):format(pad, y_title,
            esc(col(c.title_color, c.title))),

        -- Subtitle (larger than default, smaller than title)
        ("style_type[label;font=normal;font_size=15]"),
        ("label[%g,%g;%s]"):format(pad, y_subtitle,
            esc(col(c.subtitle_color, c.subtitle))),

        -- Greeting (bold, same larger size as subtitle)
        ("style_type[label;font=bold;font_size=15]"),
        ("label[%g,%g;%s]"):format(pad, y_greeting,
            esc(col(c.greeting_color, greeting .. " " .. player_name .. "!"))),

        -- Reset label style
        "style_type[label;font=normal;font_size=16]",

        -- Divider line above tab bar (inset to avoid corner overhang)
        ("box[0.25,%g;%g,0.03;%s]"):format(
            tab_bar_y - 0.06, w - 0.5, c.title_color .. "88"),
    }

    -- Tab buttons — manual, so we control Y precisely
    for i, label in ipairs(tabs) do
        local bx = (i - 1) * tab_w
        local is_active = (i == active_tab)

        -- Active tab: highlighted background; inactive: dimmer
        local bg = is_active and c.title_color or "#323232"
        local tc = is_active and "#ffffff"      or "#b0b0b0"

        table.insert(f,
            ("style[wb_tab_%d;bgcolor=%s;textcolor=%s;font=bold;border=false]")
                :format(i, bg, tc))
        table.insert(f,
            ("button[%g,%g;%g,%g;wb_tab_%d;%s]")
                :format(bx, tab_bar_y, tab_w, tab_bar_h, i, esc(label)))
    end

    -- Thin line under tab bar (inset to avoid corner overhang)
    table.insert(f,
        ("box[0.25,%g;%g,0.03;%s]"):format(
            tab_bar_y + tab_bar_h, w - 0.5, c.title_color .. "88"))

    -- Content area
    table.insert(f,
        ("box[%g,%g;%g,%g;#00000040]"):format(
            pad, content_top - 0.05,
            w - pad * 2, content_h + 0.1))

    -- Scrollable read-only textarea
    table.insert(f,
        ("textarea[%g,%g;%g,%g;;%s;]"):format(
            pad + 0.1, content_top,
            w - pad * 2 - 0.2, content_h,
            esc(body_text)))

    -- Close button
    table.insert(f,
        ("style[wm_close;font=bold;font_size=14;bgcolor=%s;textcolor=#1a1a2e]")
            :format(c.title_color))
    table.insert(f,
        ("button_exit[%g,%g;3.5,0.8;wm_close;%s]"):format(
            (w - 3.5) / 2, h - 1.05,
            esc(c.close_label)))

    return table.concat(f, ""), FORMNAME
end

return {
    build    = build_formspec,
    formname = FORMNAME,
    get_tabs = get_tabs,
}
