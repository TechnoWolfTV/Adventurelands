-- welcome_board/storage.lua
-- Content persistence layer.
--
-- Content resolves in this order:
--   1. An override saved in mod storage (set by an in-game author), if present.
--   2. The default from config.lua (which itself may come from minetest.conf).
--
-- This lets authors with the welcome_board_author priv edit content live in-game
-- without touching any files, while still shipping sensible defaults.

local storage = minetest.get_mod_storage()

local M = {}

-- Editable content fields. Keys map to config.lua fields and to storage keys.
-- Each entry: { cfg = <config field name>, label = <human label> }
M.fields = {
    title               = { cfg = "title",               label = "Title" },
    subtitle            = { cfg = "subtitle",             label = "Subtitle" },
    welcome_heading     = { cfg = "welcome_heading",      label = "Welcome Heading" },
    welcome_body        = { cfg = "welcome_body",         label = "Welcome Body" },
    announcements_body  = { cfg = "announcements_body",   label = "Announcements Body" },
    tips_body           = { cfg = "tips_body",            label = "Player Guide Body" },
    rules_body          = { cfg = "rules_body",           label = "Rules Body" },
    new_player_greeting = { cfg = "new_player_greeting",  label = "New-player Greeting" },
    return_greeting     = { cfg = "return_greeting",      label = "Returning-player Greeting" },
}

-- Storage key prefix to avoid collisions
local PREFIX = "wb_content:"

-- Get the effective value for a field: override if set, else the config default.
function M.get(field, cfg)
    local override = storage:get_string(PREFIX .. field)
    if override and override ~= "" then
        return override
    end
    -- Fall back to the config default
    local fdef = M.fields[field]
    if fdef and cfg[fdef.cfg] then
        return cfg[fdef.cfg]
    end
    return ""
end

-- Returns true if a field currently has an author override saved.
function M.has_override(field)
    local override = storage:get_string(PREFIX .. field)
    return override ~= nil and override ~= ""
end

-- Save an author override for a field.
function M.set(field, value)
    if not M.fields[field] then return false end
    storage:set_string(PREFIX .. field, value or "")
    return true
end

-- Clear an author override, reverting the field to its config default.
function M.reset(field)
    if not M.fields[field] then return false end
    storage:set_string(PREFIX .. field, "")
    return true
end

return M
