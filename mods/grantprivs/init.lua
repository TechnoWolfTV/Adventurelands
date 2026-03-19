-- grantprivs: auto-grant selected privileges on join

local privs_to_grant = {
    home = true,
    -- add more here if you want:
    -- fast = true,
    -- fly = true,
}

local function grant_privs_safely(name)
    -- Always start from current privileges
    local current = minetest.get_player_privs(name)

    -- Copy to avoid accidental reference issues
    local new_privs = {}
    for priv, val in pairs(current) do
        new_privs[priv] = val
    end

    local changed = false

    for priv, _ in pairs(privs_to_grant) do
        if not new_privs[priv] then
            new_privs[priv] = true
            changed = true
        end
    end

    -- Only write if something actually changed
    if changed then
        minetest.set_player_privs(name, new_privs)
    end
end

-- Choose ONE of these depending on behavior you want:

-- Option A: only once (recommended for multiplayer)
minetest.register_on_newplayer(function(player)
    grant_privs_safely(player:get_player_name())
end)

-- Option B: every join (forces privileges)
-- minetest.register_on_joinplayer(function(player)
--     grant_privs_safely(player:get_player_name())
-- end)
