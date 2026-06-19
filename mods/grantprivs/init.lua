-- grantprivs: Admin-configurable privilege grants for joining players
-- By TechnoWolfTV
-- https://github.com/TechnoWolfTV/grantprivs

local storage = minetest.get_mod_storage()

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

-- Deserialise the stored priv list into a set  { priv = true, ... }
local function load_join_privs()
    local raw = storage:get_string("join_privs")
    if not raw or raw == "" then return {} end
    return minetest.deserialize(raw) or {}
end

local function save_join_privs(privs_set)
    storage:set_string("join_privs", minetest.serialize(privs_set))
end

-- Timed priv rules: list of { priv=string, minutes=number }
local function load_timed_rules()
    local raw = storage:get_string("timed_rules")
    if not raw or raw == "" then return {} end
    return minetest.deserialize(raw) or {}
end

local function save_timed_rules(rules)
    storage:set_string("timed_rules", minetest.serialize(rules))
end

-- Cumulative playtime in seconds, keyed by player name
local function get_playtime(name)
    return storage:get_int("pt:" .. name)  -- 0 if missing
end

local function set_playtime(name, seconds)
    storage:set_int("pt:" .. name, seconds)
end

-- Turn a comma-separated string into a set, validating each priv
-- Returns  ok (bool), result_set or err_string
local function parse_priv_list(str)
    local result = {}
    local all_privs = minetest.registered_privileges
    for token in str:gmatch("[^,%s]+") do
        local p = token:lower()
        if not all_privs[p] then
            return false, ("Unknown privilege: '%s'"):format(p)
        end
        result[p] = true
    end
    return true, result
end

-- Turn a set into a sorted, comma-separated string for display
local function set_to_string(privs_set)
    local list = {}
    for p in pairs(privs_set) do list[#list + 1] = p end
    table.sort(list)
    return table.concat(list, ", ")
end

local function fmt_time(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return ("%dh %dm %ds"):format(h, m, s)
    elseif m > 0 then
        return ("%dm %ds"):format(m, s)
    else
        return ("%ds"):format(s)
    end
end

---------------------------------------------------------------------------
-- Grant helpers
---------------------------------------------------------------------------

local function grant_privs_to(player_name, priv_set, reason)
    local current   = minetest.get_player_privs(player_name)
    local new_privs = {}
    for k, v in pairs(current) do new_privs[k] = v end

    local granted = {}
    for priv in pairs(priv_set) do
        if not new_privs[priv] then
            new_privs[priv] = true
            granted[#granted + 1] = priv
        end
    end

    if #granted > 0 then
        table.sort(granted)
        minetest.set_player_privs(player_name, new_privs)
        minetest.log("action", ("[grantprivs] Granted to %s (%s): %s"):format(
            player_name, reason, table.concat(granted, ", ")))
        -- Notify the player in-game if they are online
        local player = minetest.get_player_by_name(player_name)
        if player then
            minetest.chat_send_player(player_name,
                ("[grantprivs] You have been granted: %s"):format(
                    table.concat(granted, ", ")))
        end
    end
end

local function grant_join_privs(player_name, is_new)
    local join_privs = load_join_privs()
    if next(join_privs) == nil then return end
    local context = is_new and "new player" or "returning player"
    grant_privs_to(player_name, join_privs, context)
end

---------------------------------------------------------------------------
-- Session tracking + timed priv checks
---------------------------------------------------------------------------

-- session_start[name] = os.time() when they joined this session
local session_start = {}

-- Check whether any timed rules now qualify for this player and grant them
local function check_timed_privs(player_name, cumulative_seconds)
    local rules = load_timed_rules()
    if #rules == 0 then return end

    for _, rule in ipairs(rules) do
        local threshold = rule.minutes * 60
        if cumulative_seconds >= threshold then
            local current = minetest.get_player_privs(player_name)
            if not current[rule.priv] then
                grant_privs_to(player_name, { [rule.priv] = true },
                    ("playtime >= %d min"):format(rule.minutes))
            end
        end
    end
end

-- Check timed priv rules for all online players every CHECK_INTERVAL seconds
local CHECK_INTERVAL = 30
local check_timer = 0
minetest.register_globalstep(function(dtime)
    check_timer = check_timer + dtime
    if check_timer < CHECK_INTERVAL then return end
    check_timer = 0

    for _, player in ipairs(minetest.get_connected_players()) do
        local name  = player:get_player_name()
        local start = session_start[name]
        if start then
            local session_secs  = os.time() - start
            local total_secs    = get_playtime(name) + session_secs
            check_timed_privs(name, total_secs)
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    session_start[name] = os.time()

    -- Join-priv grants (new-player case handled by register_on_newplayer)
    if storage:get_int("grant_on_rejoin") == 1 then
        grant_join_privs(name, false)
    end

    -- Also check timed privs immediately on join (catches offline accrual gap)
    check_timed_privs(name, get_playtime(name))
end)

minetest.register_on_newplayer(function(player)
    grant_join_privs(player:get_player_name(), true)
end)

minetest.register_on_leaveplayer(function(player)
    local name  = player:get_player_name()
    local start = session_start[name]
    if start then
        local session_secs = os.time() - start
        local total_secs   = get_playtime(name) + session_secs
        set_playtime(name, total_secs)
        session_start[name] = nil
        minetest.log("action", ("[grantprivs] %s playtime saved: %s total"):format(
            name, fmt_time(total_secs)))
    end
end)

---------------------------------------------------------------------------
-- Chat commands
---------------------------------------------------------------------------

minetest.register_chatcommand("grantprivs", {
    privs       = { server = true },
    description = "Manage auto-granted privileges for joining players.",
    params      = "set|add|remove|clear|rejoin|timed|playtime|status",
    func = function(caller, param)
        local args = {}
        for token in param:gmatch("%S+") do args[#args + 1] = token end
        local cmd = args[1] and args[1]:lower()

        -- ── status ──────────────────────────────────────────────────────
        if not cmd or cmd == "status" then
            local join_privs   = load_join_privs()
            local rules        = load_timed_rules()
            local rejoin_label = storage:get_int("grant_on_rejoin") == 1 and "ON" or "OFF"
            local priv_display = next(join_privs) and set_to_string(join_privs) or "(none)"

            local lines = {
                "=== grantprivs status ===",
                "Join privs     : " .. priv_display,
                "Grant on rejoin: " .. rejoin_label,
            }

            if #rules == 0 then
                lines[#lines + 1] = "Timed rules    : (none)"
            else
                lines[#lines + 1] = "Timed rules    :"
                -- sort by threshold for readability
                local sorted = {}
                for i, r in ipairs(rules) do sorted[i] = r end
                table.sort(sorted, function(a, b) return a.minutes < b.minutes end)
                for _, r in ipairs(sorted) do
                    lines[#lines + 1] = ("  %d min -> grant '%s'"):format(r.minutes, r.priv)
                end
            end

            lines[#lines + 1] = ""
            lines[#lines + 1] = "Sub-commands: set, add, remove, clear, rejoin, timed, playtime"
            return true, table.concat(lines, "\n")

        -- ── set ─────────────────────────────────────────────────────────
        elseif cmd == "set" then
            local rest = param:match("^set%s+(.+)$")
            if not rest then return false, "Usage: /grantprivs set <priv1, priv2, ...>" end
            local ok, result = parse_priv_list(rest)
            if not ok then return false, result end
            save_join_privs(result)
            return true, "Join privs set to: " .. (next(result) and set_to_string(result) or "(none)")

        -- ── add ─────────────────────────────────────────────────────────
        elseif cmd == "add" then
            local rest = param:match("^add%s+(.+)$")
            if not rest then return false, "Usage: /grantprivs add <priv1, priv2, ...>" end
            local ok, result = parse_priv_list(rest)
            if not ok then return false, result end
            local current = load_join_privs()
            for p in pairs(result) do current[p] = true end
            save_join_privs(current)
            return true, "Join privs are now: " .. set_to_string(current)

        -- ── remove ──────────────────────────────────────────────────────
        elseif cmd == "remove" then
            local rest = param:match("^remove%s+(.+)$")
            if not rest then return false, "Usage: /grantprivs remove <priv1, priv2, ...>" end
            local ok, result = parse_priv_list(rest)
            if not ok then return false, result end
            local current = load_join_privs()
            local removed = {}
            for p in pairs(result) do
                if current[p] then
                    current[p] = nil
                    removed[#removed + 1] = p
                end
            end
            save_join_privs(current)
            if #removed == 0 then
                return true, "None of those privs were in the list (no change)."
            end
            table.sort(removed)
            local remaining = next(current) and set_to_string(current) or "(none)"
            return true, ("Removed: %s. Remaining: %s"):format(
                table.concat(removed, ", "), remaining)

        -- ── clear ───────────────────────────────────────────────────────
        elseif cmd == "clear" then
            save_join_privs({})
            return true, "Join priv list cleared. No privs will be auto-granted on join."

        -- ── rejoin ──────────────────────────────────────────────────────
        elseif cmd == "rejoin" then
            local toggle = args[2] and args[2]:lower()
            if toggle == "on" then
                storage:set_int("grant_on_rejoin", 1)
                return true, "Rejoin grants ON — join privs re-applied every time a player joins."
            elseif toggle == "off" then
                storage:set_int("grant_on_rejoin", 0)
                return true, "Rejoin grants OFF — join privs only granted to brand-new players."
            else
                return false, "Usage: /grantprivs rejoin <on|off>"
            end

        -- ── timed ───────────────────────────────────────────────────────
        elseif cmd == "timed" then
            local sub = args[2] and args[2]:lower()

            -- /grantprivs timed add <minutes> <priv>
            if sub == "add" then
                local minutes = tonumber(args[3])
                local priv    = args[4] and args[4]:lower()
                if not minutes or not priv then
                    return false, "Usage: /grantprivs timed add <minutes> <priv>"
                end
                if minutes <= 0 then
                    return false, "Minutes must be greater than 0."
                end
                if not minetest.registered_privileges[priv] then
                    return false, ("Unknown privilege: '%s'"):format(priv)
                end
                local rules = load_timed_rules()
                -- Prevent exact duplicates
                for _, r in ipairs(rules) do
                    if r.priv == priv and r.minutes == minutes then
                        return false, ("Rule already exists: %d min -> '%s'"):format(minutes, priv)
                    end
                end
                rules[#rules + 1] = { priv = priv, minutes = minutes }
                save_timed_rules(rules)
                return true, ("Timed rule added: grant '%s' after %d minutes of playtime."):format(priv, minutes)

            -- /grantprivs timed remove <minutes> <priv>
            elseif sub == "remove" then
                local minutes = tonumber(args[3])
                local priv    = args[4] and args[4]:lower()
                if not minutes or not priv then
                    return false, "Usage: /grantprivs timed remove <minutes> <priv>"
                end
                local rules   = load_timed_rules()
                local new     = {}
                local removed = false
                for _, r in ipairs(rules) do
                    if r.priv == priv and r.minutes == minutes then
                        removed = true
                    else
                        new[#new + 1] = r
                    end
                end
                if not removed then
                    return false, ("No rule found for %d min -> '%s'."):format(minutes, priv)
                end
                save_timed_rules(new)
                return true, ("Timed rule removed: %d min -> '%s'."):format(minutes, priv)

            -- /grantprivs timed clear
            elseif sub == "clear" then
                save_timed_rules({})
                return true, "All timed rules cleared."

            -- /grantprivs timed list
            elseif sub == "list" or not sub then
                local rules = load_timed_rules()
                if #rules == 0 then
                    return true, "No timed rules configured."
                end
                local sorted = {}
                for i, r in ipairs(rules) do sorted[i] = r end
                table.sort(sorted, function(a, b) return a.minutes < b.minutes end)
                local lines = { "Timed rules:" }
                for _, r in ipairs(sorted) do
                    lines[#lines + 1] = ("  %d min -> grant '%s'"):format(r.minutes, r.priv)
                end
                return true, table.concat(lines, "\n")

            else
                return false, "Usage: /grantprivs timed <add|remove|clear|list>"
            end

        -- ── playtime ────────────────────────────────────────────────────
        elseif cmd == "playtime" then
            local target = args[2]
            if not target then
                return false, "Usage: /grantprivs playtime <playername>"
            end
            local saved = get_playtime(target)
            -- Add live session time if player is currently online
            local live = 0
            if session_start[target] then
                live = os.time() - session_start[target]
            end
            local total = saved + live
            local online_note = live > 0 and " (online, session: " .. fmt_time(live) .. ")" or ""
            return true, ("%s playtime: %s%s"):format(target, fmt_time(total), online_note)

        else
            return false, ("Unknown sub-command '%s'. Try /grantprivs status"):format(cmd)
        end
    end,
})

---------------------------------------------------------------------------
-- Startup log
---------------------------------------------------------------------------
do
    local join_privs   = load_join_privs()
    local rules        = load_timed_rules()
    local rejoin_label = storage:get_int("grant_on_rejoin") == 1 and "ON" or "OFF"
    local priv_display = next(join_privs) and set_to_string(join_privs) or "(none)"
    minetest.log("action", ("[grantprivs] Loaded. Join privs: [%s]  Rejoin: %s  Timed rules: %d"):format(
        priv_display, rejoin_label, #rules))
end
