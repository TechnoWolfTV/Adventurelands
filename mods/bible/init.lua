-- bible/init.lua
-- Bible Mod for Luanti 5.15.0

bible = {}
bible.data = {}
bible.book_order = {}
bible.translations = {}
bible.bookmarks = {}

-- Compatibility alias: bible_data_kjv.lua was generated when the mod was
-- named holy_bible, so it writes to holy_bible.data. This points that
-- to bible.data so the data lands in the right place.
-- Run tools/import_kjv.py again to regenerate a clean bible_data_kjv.lua
-- without needing this alias.
holy_bible = bible

-- Load Bible data
local mod_path = minetest.get_modpath("bible")

-- KJV (King James Version, 1611) - Public Domain
dofile(mod_path .. "/bible_data_kjv.lua")

-- Optional: World English Bible (WEB) - Public Domain
-- Download from https://ebible.org/eng-web/ then run:
--   python3 tools/import_kjv.py <web.txt> bible_data_web.lua
local web_file = mod_path .. "/bible_data_web.lua"
local web_f = io.open(web_file, "r")
if web_f then web_f:close(); dofile(web_file) end

-- Optional: Young's Literal Translation (YLT, 1862) - Public Domain
-- Download from https://ebible.org/eng-ylt/ then run:
--   python3 tools/import_kjv.py <ylt.txt> bible_data_ylt.lua
local ylt_file = mod_path .. "/bible_data_ylt.lua"
local ylt_f = io.open(ylt_file, "r")
if ylt_f then ylt_f:close(); dofile(ylt_file) end

-- Book order (canonical 66 books)
bible.book_order = {
    "Genesis","Exodus","Leviticus","Numbers","Deuteronomy",
    "Joshua","Judges","Ruth","1 Samuel","2 Samuel",
    "1 Kings","2 Kings","1 Chronicles","2 Chronicles",
    "Ezra","Nehemiah","Esther","Job","Psalms","Proverbs",
    "Ecclesiastes","Song of Solomon","Isaiah","Jeremiah","Lamentations",
    "Ezekiel","Daniel","Hosea","Joel","Amos",
    "Obadiah","Jonah","Micah","Nahum","Habakkuk",
    "Zephaniah","Haggai","Zechariah","Malachi",
    "Matthew","Mark","Luke","John","Acts",
    "Romans","1 Corinthians","2 Corinthians","Galatians","Ephesians",
    "Philippians","Colossians","1 Thessalonians","2 Thessalonians",
    "1 Timothy","2 Timothy","Titus","Philemon","Hebrews",
    "James","1 Peter","2 Peter","1 John","2 John","3 John",
    "Jude","Revelation"
}

-- Register KJV translation (must happen AFTER data is loaded)
bible.translations["KJV"] = {
    name     = "King James Version",
    year     = 1611,
    language = "en",
    data     = bible.data,
}

-- Load optional extra translation packs
local extra = mod_path .. "/bible_data_extra.lua"
local ef = io.open(extra, "r")
if ef then ef:close(); dofile(extra) end


-- ── Persistent bookmark storage ──────────────────────────────────────────────
local storage = minetest.get_mod_storage()

-- Multi-bookmark storage: bookmarks[player] = { {label,book,chapter,translation}, ... }
local function save_bookmarks(player_name)
    local key = "bookmarks2_" .. player_name
    storage:set_string(key, minetest.serialize(bible.bookmarks[player_name] or {}))
end

local function load_bookmarks(player_name)
    local key = "bookmarks2_" .. player_name
    local raw = storage:get_string(key)
    if raw and raw ~= "" then
        local bms = minetest.deserialize(raw)
        if bms then
            bible.bookmarks[player_name] = bms
            return bms
        end
    end
    -- Migrate old single bookmark if present
    local old_raw = storage:get_string("bookmark_" .. player_name)
    if old_raw and old_raw ~= "" then
        local old = minetest.deserialize(old_raw)
        if old and old.book then
            local migrated = {{ label = old.book .. " " .. (old.chapter or 1),
                book = old.book, chapter = old.chapter or 1,
                translation = old.translation or "KJV" }}
            bible.bookmarks[player_name] = migrated
            save_bookmarks(player_name)
            return migrated
        end
    end
    bible.bookmarks[player_name] = {}
    return {}
end

local function add_bookmark(player_name, label, book, chapter, translation)
    local bms = bible.bookmarks[player_name] or {}
    -- Update existing label if it matches, otherwise append
    for _, bm in ipairs(bms) do
        if bm.label == label then
            bm.book = book; bm.chapter = chapter; bm.translation = translation
            bible.bookmarks[player_name] = bms
            save_bookmarks(player_name)
            return
        end
    end
    table.insert(bms, { label = label, book = book, chapter = chapter, translation = translation })
    bible.bookmarks[player_name] = bms
    save_bookmarks(player_name)
end

local function delete_bookmark(player_name, label)
    local bms = bible.bookmarks[player_name] or {}
    for i, bm in ipairs(bms) do
        if bm.label == label then
            table.remove(bms, i)
            bible.bookmarks[player_name] = bms
            save_bookmarks(player_name)
            return
        end
    end
end

minetest.register_on_joinplayer(function(player)
    load_bookmarks(player:get_player_name())
end)

-- ── Helper functions ─────────────────────────────────────────────────────────
local function get_translation_data(trans_key)
    local t = bible.translations[trans_key]
    return t and t.data or bible.data
end

local function get_chapter_verses(book, chapter, trans_key)
    local data = get_translation_data(trans_key)
    if data[book] and data[book][chapter] then
        return data[book][chapter]
    end
    return nil
end

local function count_chapters(book, trans_key)
    local data = get_translation_data(trans_key)
    if not data[book] then return 0 end
    local n = 0
    for _ in pairs(data[book]) do n = n + 1 end
    return n
end

local function get_book_index(book_name)
    for i, b in ipairs(bible.book_order) do
        if b == book_name then return i end
    end
    return nil
end

-- Build verse text for display (chapter mode)
local function build_chapter_text(book, chapter, trans_key)
    local verses = get_chapter_verses(book, chapter, trans_key)
    if not verses then
        return "[No text available for this chapter.\nUse tools/import_kjv.py to load the full Bible.]"
    end
    local lines = {}
    for i, v in ipairs(verses) do
        lines[#lines+1] = i .. ". " .. v
    end
    return table.concat(lines, "\n")
end

-- Build full-book text
local function build_book_text(book, trans_key)
    local data = get_translation_data(trans_key)
    if not data[book] then
        return "[No text available for " .. book .. ".]"
    end
    local lines = {}
    local ch_count = count_chapters(book, trans_key)
    for ch = 1, ch_count do
        local verses = data[book][ch]
        if verses then
            lines[#lines+1] = "── Chapter " .. ch .. " ──"
            for i, v in ipairs(verses) do
                lines[#lines+1] = i .. ". " .. v
            end
            lines[#lines+1] = ""
        end
    end
    return table.concat(lines, "\n")
end

-- Search verses for a keyword, return list of matches
local function search_verses(query, trans_key)
    local data = get_translation_data(trans_key)
    local results = {}
    local q = query:lower()
    for _, book in ipairs(bible.book_order) do
        if data[book] then
            for ch_idx, verses in pairs(data[book]) do
                for v_idx, verse in ipairs(verses) do
                    if verse:lower():find(q, 1, true) then
                        results[#results+1] = {
                            book = book, chapter = ch_idx,
                            verse = v_idx, text = verse
                        }
                        if #results >= 200 then return results end
                    end
                end
            end
        end
    end
    return results
end

-- Build dropdown lists
local function get_book_list()
    return table.concat(bible.book_order, ",")
end

local function get_chapter_list(book, trans_key)
    local n = count_chapters(book, trans_key)
    if n == 0 then return "1" end
    local t = {}
    for i = 1, n do t[i] = tostring(i) end
    return table.concat(t, ",")
end

local function get_translation_list()
    local t = {}
    for k, v in pairs(bible.translations) do
        t[#t+1] = k .. " - " .. v.name
    end
    table.sort(t)
    return table.concat(t, ",")
end

local function translation_key_list()
    local t = {}
    for k in pairs(bible.translations) do t[#t+1] = k end
    table.sort(t)
    return t
end

-- ── Formspec builder ─────────────────────────────────────────────────────────
--
-- State table passed between form submissions:
-- { book, chapter, mode ("chapter"|"book"), translation, search_query, search_results_page }

local player_state = {}  -- { [name] = state }

local RESULTS_PER_PAGE = 20
local TEXT_AREA_H = 9.5

local function make_formspec(state)
    local book       = state.book or bible.book_order[1] or "Genesis"
    local chapter    = state.chapter or 1
    local mode       = state.mode or "chapter"
    local trans_key  = state.translation or "KJV"
    local sq         = state.search_query or ""
    local sr_page    = state.search_results_page or 1

    -- Indices for dropdowns (1-based)
    local book_idx = get_book_index(book) or 1
    local ch_count = count_chapters(book, trans_key)
    if chapter > ch_count and ch_count > 0 then chapter = ch_count end

    local trans_keys = translation_key_list()
    local trans_idx = 1
    for i, k in ipairs(trans_keys) do
        if k == trans_key then trans_idx = i; break end
    end

    -- Build main text
    local main_text = ""
    if mode == "chapter" then
        main_text = "── " .. book .. "  •  Chapter " .. chapter .. " ──\n\n"
            .. build_chapter_text(book, chapter, trans_key)
    elseif mode == "book" then
        main_text = "══ " .. book .. " (Full Book) ══\n\n"
            .. build_book_text(book, trans_key)
    elseif mode == "search" then
        if sq == "" then
            main_text = "Enter a search term above and press Search."
        else
            local results = search_verses(sq, trans_key)
            if #results == 0 then
                main_text = 'No results found for "' .. sq .. '".'
            else
                local start = (sr_page - 1) * RESULTS_PER_PAGE + 1
                local lines = { "Results for: \"" .. sq .. '"  ('
                    .. #results .. " found)\n" }
                for i = start, math.min(start + RESULTS_PER_PAGE - 1, #results) do
                    local r = results[i]
                    lines[#lines+1] = r.book .. " " .. r.chapter .. ":" .. r.verse
                        .. "  — " .. r.text
                    lines[#lines+1] = ""
                end
                state._search_results_count = #results
                state._search_results = results  -- cache for this render
                main_text = table.concat(lines, "\n")
            end
        end
    end

    -- Bookmark indicator
    local bm_label = "☆ Bookmark"
    if state._has_bookmark then bm_label = "★ Bookmarked" end

    -- Search page nav
    local total_pages = 1
    if state._search_results_count then
        total_pages = math.ceil(state._search_results_count / RESULTS_PER_PAGE)
    end

    local W, H = 14, 14

    local fs = "formspec_version[6]"
        .. "size[" .. W .. "," .. H .. "]"
        .. "bgcolor[#1a0d00;true]"

        -- ── Title bar ──
        .. "no_prepend[]"
        .. "image[0,0;14,0.8;bible_titlebar.png]"
        .. "button_exit[12.8,0.1;1.0,0.6;btn_close;X Close]"
        .. "label[0.3,0.42;Bible — " .. (bible.translations[trans_key] and bible.translations[trans_key].name or trans_key) .. "]"

        -- ── Translation selector ──
        .. "label[0.2,1.1;Translation:]"
        .. "dropdown[1.8,0.8;3.5,0.6;dd_translation;" .. get_translation_list() .. ";" .. trans_idx .. ";true]"

        -- ── Book selector ──
        .. "label[0.2,1.9;Book:]"
        .. "dropdown[1.8,1.6;4.5,0.6;dd_book;" .. get_book_list() .. ";" .. book_idx .. ";true]"

        -- ── Chapter selector (shown only in chapter mode) ──
        .. "label[6.5,1.9;Chapter:]"
        .. "dropdown[7.8,1.6;2.0,0.6;dd_chapter;" .. get_chapter_list(book, trans_key) .. ";" .. chapter .. ";true]"

        -- ── Go + Mode buttons (inline with selectors) ──
        .. "button[9.9,1.6;1.2,0.6;btn_go;▶ Go]"
        .. "button[11.2,1.6;1.4,0.6;btn_chapter;By Ch.]"
        .. "button[12.7,1.6;1.1,0.6;btn_book;Full]"

        -- ── Navigation row ──
        .. "button[0.2,2.4;1.4,0.6;btn_prev_ch;◀ Prev]"
        .. "button[1.7,2.4;1.4,0.6;btn_next_ch;Next ▶]"
        .. "button[3.2,2.4;1.9,0.6;btn_prev_book;◀◀ Book]"
        .. "button[5.2,2.4;1.9,0.6;btn_next_book;Book ▶▶]"
        .. "button[7.2,2.4;2.3,0.6;btn_bookmark;✚ Bookmark]"
        .. "button[9.6,2.4;2.1,0.6;btn_bm_manager;☰ Bookmarks]"
        .. "button[11.8,2.4;2.0,0.6;btn_random;Random Ch.]"

        -- ── Search bar ──
        .. "field[0.2,3.35;9.0,0.6;search_query;;" .. minetest.formspec_escape(sq) .. "]"
        .. "field_close_on_enter[search_query;false]"
        .. "button[9.3,3.2;2.0,0.6;btn_search;🔍 Search]"
        .. "button[11.4,3.2;2.4,0.6;btn_clear_search;✕ Clear]"

        -- ── Search page nav (only in search mode) ──

        -- ── Main text area ──
        .. "textarea[0.2,4.1;13.6," .. TEXT_AREA_H .. ";;;" .. minetest.formspec_escape(main_text) .. "]"

    -- Search result paging
    if mode == "search" and total_pages > 1 then
        fs = fs
            .. "button[0.2," .. (H - 0.8) .. ";1.8,0.6;btn_sr_prev;◀ Prev]"
            .. "label[2.2," .. (H - 0.45) .. ";Page " .. sr_page .. " / " .. total_pages .. "]"
            .. "button[4.0," .. (H - 0.8) .. ";1.8,0.6;btn_sr_next;Next ▶]"
    end

    return fs
end

-- ── Bookmark manager formspec ────────────────────────────────────────────────
local function show_bookmark_manager(player)
    local name = player:get_player_name()
    local bms = bible.bookmarks[name] or {}
    local W, H = 10, 8

    local rows = ""
    if #bms == 0 then
        rows = "label[0.3,2.0;No bookmarks saved yet.]"
    else
        for i, bm in ipairs(bms) do
            local y = 1.4 + (i - 1) * 0.8
            local lbl = minetest.formspec_escape(bm.label)
            local loc = minetest.formspec_escape(bm.book .. " " .. bm.chapter .. " (" .. (bm.translation or "KJV") .. ")")
            rows = rows
                .. "label[0.3," .. (y + 0.45) .. ";" .. lbl .. "  —  " .. loc .. "]"
                .. "button[7.5," .. y .. ";1.0,0.6;bm_goto_" .. i .. ";Go]"
                .. "button[8.6," .. y .. ";1.2,0.6;bm_del_" .. i .. ";Delete]"
        end
    end

    local fs = "formspec_version[6]"
        .. "size[" .. W .. "," .. H .. "]"
        .. "bgcolor[#1a0d00;true]"
        .. "no_prepend[]"
        .. "image[0,0;10,0.8;bible_titlebar.png]"
        .. "label[0.3,0.42;Bible — Bookmark Manager]"
        .. "button_exit[8.8,0.1;1.0,0.6;btn_bm_close;X Close]"
        .. "box[0.2,1.0;9.6,0.05;#8B6914]"
        .. rows
        .. "box[0.2," .. (H - 1.2) .. ";9.6,0.05;#8B6914]"
        .. "label[0.3," .. (H - 0.9) .. ";To add a bookmark: navigate to a chapter in the reader, then press ✚ Bookmark.]"
    minetest.show_formspec(name, "bible:bookmarks", fs)
end

-- ── Show / update formspec ───────────────────────────────────────────────────
local function show_bible(player)
    local name = player:get_player_name()
    local state = player_state[name]
    if not state then
        local bm = bible.bookmarks[name]
        state = {
            book        = (bm and bm.book) or bible.book_order[1] or "Genesis",
            chapter     = (bm and bm.chapter) or 1,
            mode        = "chapter",
            translation = (bm and bm.translation) or "KJV",
            search_query = "",
            search_results_page = 1,
        }
        player_state[name] = state
    end

    -- Check if current location is already bookmarked
    local bms = bible.bookmarks[name] or {}
    state._has_bookmark = false
    for _, bm in ipairs(bms) do
        if bm.book == state.book and bm.chapter == state.chapter then
            state._has_bookmark = true; break
        end
    end

    bible._is_open = bible._is_open or {}
    bible._is_open[name] = true
    minetest.show_formspec(name, "bible:reader", make_formspec(state))
end

-- ── Item definition ──────────────────────────────────────────────────────────
minetest.register_tool("bible:bible", {
    description = "Bible (KJV)\nRight-click to read",
    inventory_image = "bible_cover.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        if user then
            local name = user:get_player_name()
            if not (bible._is_open and bible._is_open[name]) then
                show_bible(user)
            end
        end
        return itemstack
    end,
    on_secondary_use = function(itemstack, user, pointed_thing)
        if user then
            local name = user:get_player_name()
            if not (bible._is_open and bible._is_open[name]) then
                show_bible(user)
            end
        end
        return itemstack
    end,
})

-- ── Craft recipe (expensive, symbolic) ──────────────────────────────────────
minetest.register_craft({
    output = "bible:bible",
    recipe = {
        { "default:paper", "default:paper", "default:paper" },
        { "default:paper", "default:gold_ingot", "default:paper" },
        { "default:paper", "default:paper", "default:paper" },
    },
})

-- ── Form receive handler ─────────────────────────────────────────────────────
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "bible:reader" then return end

    local name = player:get_player_name()
    -- ESC key or button_exit both set fields.quit
    if fields.quit then
        bible._is_open = bible._is_open or {}
        bible._is_open[name] = false
        return
    end
    local state = player_state[name]
    if not state then return end

    local trans_key = state.translation or "KJV"
    local book      = state.book
    local chapter   = state.chapter

    -- Dropdowns + Go button
    -- All three dropdowns are always submitted together, so we only
    -- apply them when the Go button is pressed to avoid them fighting.
    if fields.btn_go then
        -- Translation: index into sorted key list
        if fields.dd_translation and fields.dd_translation ~= "" then
            local trans_keys = translation_key_list()
            local idx = tonumber(fields.dd_translation)
            local chosen
            if idx and trans_keys[idx] then
                chosen = trans_keys[idx]
            else
                -- try direct key match
                chosen = fields.dd_translation:match("^([^%s]+)")
            end
            if chosen and bible.translations[chosen] then
                state.translation = chosen
                trans_key = chosen
            end
        end
        -- Book: index into book_order (Luanti dropdowns return 1-based index)
        if fields.dd_book and fields.dd_book ~= "" then
            local idx = tonumber(fields.dd_book)
            if idx and bible.book_order[idx] then
                state.book = bible.book_order[idx]
                book = state.book
            elseif bible.data[fields.dd_book] then
                state.book = fields.dd_book
                book = fields.dd_book
            end
        end
        -- Chapter: numeric string
        if fields.dd_chapter and fields.dd_chapter ~= "" then
            local ch = tonumber(fields.dd_chapter)
            if ch then state.chapter = ch; chapter = ch end
        end
        state.mode = "chapter"
    end

    -- Mode buttons
    if fields.btn_chapter then
        state.mode = "chapter"
    elseif fields.btn_book then
        state.mode = "book"
    end

    -- Navigation: previous / next chapter
    if fields.btn_prev_ch then
        if chapter > 1 then
            state.chapter = chapter - 1
        else
            -- Go to previous book
            local idx = get_book_index(book) or 1
            if idx > 1 then
                state.book = bible.book_order[idx - 1]
                state.chapter = count_chapters(state.book, trans_key)
            end
        end
        state.mode = "chapter"
    end

    if fields.btn_next_ch then
        local ch_count = count_chapters(book, trans_key)
        if chapter < ch_count then
            state.chapter = chapter + 1
        else
            local idx = get_book_index(book) or 1
            if idx < #bible.book_order then
                state.book = bible.book_order[idx + 1]
                state.chapter = 1
            end
        end
        state.mode = "chapter"
    end

    -- Navigation: previous / next book
    if fields.btn_prev_book then
        local idx = get_book_index(book) or 1
        if idx > 1 then
            state.book = bible.book_order[idx - 1]
            state.chapter = 1
        end
        state.mode = "chapter"
    end

    if fields.btn_next_book then
        local idx = get_book_index(book) or 1
        if idx < #bible.book_order then
            state.book = bible.book_order[idx + 1]
            state.chapter = 1
        end
        state.mode = "chapter"
    end

    -- Random chapter
    if fields.btn_random then
        local avail = {}
        local data = get_translation_data(trans_key)
        for _, b in ipairs(bible.book_order) do
            if data[b] then
                local n = count_chapters(b, trans_key)
                for c = 1, n do avail[#avail+1] = {b, c} end
            end
        end
        if #avail > 0 then
            local pick = avail[math.random(#avail)]
            state.book    = pick[1]
            state.chapter = pick[2]
            state.mode    = "chapter"
        end
    end

    -- Bookmark: add current location
    if fields.btn_bookmark then
        local label = state.book .. " " .. state.chapter
        add_bookmark(name, label, state.book, state.chapter, state.translation)
        minetest.chat_send_player(name, "[Bible] Bookmark saved: " .. label)
    end

    -- Bookmark: open manager
    if fields.btn_bm_manager then
        show_bookmark_manager(player)
        return
    end

    -- Search
    if fields.btn_search or (fields.key_enter_field == "search_query") then
        local q = (fields.search_query or ""):match("^%s*(.-)%s*$")
        state.search_query = q
        state.search_results_page = 1
        state.mode = "search"
    end

    if fields.btn_clear_search then
        state.search_query = ""
        state.search_results_page = 1
        state.mode = "chapter"
    end

    -- Search result paging
    if fields.btn_sr_prev and state.search_results_page > 1 then
        state.search_results_page = state.search_results_page - 1
    end
    if fields.btn_sr_next then
        state.search_results_page = (state.search_results_page or 1) + 1
    end

    -- Re-open formspec with updated state
    show_bible(player)
end)

-- ── Chat commands ─────────────────────────────────────────────────────────────
minetest.register_chatcommand("bible", {
    description = "Open the Bible reader",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if player then
            -- Optional: jump to reference, e.g. /bible John 3
            if param and param ~= "" then
                local parts = param:match("^(.-)%s+(%d+)$")
                local book_part, ch_part = param:match("^(.-)%s+(%d+)$")
                if book_part and ch_part then
                    -- Find closest book name match
                    local lp = book_part:lower()
                    for _, b in ipairs(bible.book_order) do
                        if b:lower():find(lp, 1, true) then
                            player_state[name] = {
                                book = b,
                                chapter = tonumber(ch_part) or 1,
                                mode = "chapter",
                                translation = "KJV",
                                search_query = "",
                                search_results_page = 1,
                            }
                            break
                        end
                    end
                end
            end
            show_bible(player)
            return true, "Opening Bible..."
        end
        return false, "Player not found."
    end
})

minetest.register_chatcommand("biblesearch", {
    description = "Search the Bible. Usage: /biblesearch <word or phrase>",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if player and param and param ~= "" then
            player_state[name] = {
                book = bible.book_order[1] or "Genesis",
                chapter = 1,
                mode = "search",
                translation = "KJV",
                search_query = param:match("^%s*(.-)%s*$"),
                search_results_page = 1,
            }
            show_bible(player)
            return true, "Searching for: " .. param
        end
        return false, "Usage: /biblesearch <term>"
    end
})

-- ── Bookmark manager receive handler ─────────────────────────────────────────
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "bible:bookmarks" then return end
    if fields.quit or fields.btn_bm_close then
        -- Reopen the Bible reader when bookmark manager is closed
        show_bible(player)
        return
    end

    local name = player:get_player_name()
    local bms = bible.bookmarks[name] or {}

    -- Check for Go or Delete buttons (named bm_goto_N / bm_del_N)
    for key, _ in pairs(fields) do
        local idx = tonumber(key:match("^bm_goto_(%d+)$"))
        if idx and bms[idx] then
            local bm = bms[idx]
            player_state[name] = player_state[name] or {}
            local state = player_state[name]
            state.book        = bm.book
            state.chapter     = bm.chapter
            state.translation = bm.translation or "KJV"
            state.mode        = "chapter"
            state.search_query = ""
            show_bible(player)
            return
        end
        local didx = tonumber(key:match("^bm_del_(%d+)$"))
        if didx and bms[didx] then
            local label = bms[didx].label
            delete_bookmark(name, label)
            minetest.chat_send_player(name, "[Bible] Deleted bookmark: " .. label)
            show_bookmark_manager(player)
            return
        end
    end
end)

-- ── Cleanup on leave ─────────────────────────────────────────────────────────
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_state[name] = nil
    if bible._is_open then bible._is_open[name] = false end
end)

minetest.log("action", "[bible] Loaded. Books with data: " .. (function()
    local n = 0
    for _, b in ipairs(bible.book_order) do
        if bible.data[b] then n = n + 1 end
    end
    return n
end)() .. " / " .. #bible.book_order)
