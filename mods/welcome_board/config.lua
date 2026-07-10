-- welcome_board/config.lua
-- Loads all settings from minetest.conf, falling back to sensible defaults.
-- Edit values here OR set them in minetest.conf (minetest.conf takes priority).

local S = minetest.settings

local function get_str(key, default)
    local v = S:get(key)
    if v and v ~= "" then return v end
    return default
end

local function get_bool(key, default)
    local v = S:get_bool(key)
    if v == nil then return default end
    return v
end

local function get_float(key, default, min, max)
    local v = tonumber(S:get(key))
    if not v then return default end
    if min then v = math.max(min, v) end
    if max then v = math.min(max, v) end
    return v
end

-- Unescape \n sequences from settings strings
local function unescape(s)
    return s:gsub("\\n", "\n")
end

local cfg = {}

-- When to show the popup
cfg.show_on = get_str("welcome_board_show_on", "first_join")

-- Delay before popup appears (seconds)
cfg.delay = get_float("welcome_board_delay", 0.8, 0.0, 5.0)

-- Maximum characters per page before content is split into multiple pages
cfg.chars_per_page = get_float("welcome_board_chars_per_page", 3000, 500, 10000)

-- General
cfg.title        = get_str("welcome_board_title",       "Welcome! Your Adventure Begins Here.")
cfg.subtitle     = get_str("welcome_board_subtitle",    "Explore, Build, Craft & Survive")
cfg.server_name  = get_str("welcome_board_server_name", "This World")

-- Welcome tab
cfg.welcome_heading = get_str("welcome_board_welcome_heading", "A New Adventure Awaits")
cfg.welcome_body    = unescape(get_str("welcome_board_welcome_body",
    "This world is yours to explore, build, and survive in.\n" ..
    "Ahead of you lies a Luanti experience featuring exploration across diverse biomes, " ..
    "deep mines full of rare ores, challenging monsters that come alive at night, and a rich crafting " ..
    "system to take you from wooden tools all the way to powerful equipment.\n\n" ..
    "Whether you prefer to build sprawling bases, brave dangerous dungeons, or simply wander and " ..
    "discover — there is something here for you.\n\n" ..
    "Use the tabs above to check announcements, read the player guide, and review " ..
    "the server rules. You can reopen this dialog any time with the /welcome command."
))

-- Announcements tab
cfg.show_announcements      = get_bool("welcome_board_show_announcements", true)
cfg.announcements_tab_label = get_str("welcome_board_announcements_tab_label", "Announcements")
cfg.announcements_body      = unescape(get_str("welcome_board_announcements_body",
    "Nothing new to report right now. Enjoy your adventure!"
))

-- Player Guide tab
cfg.show_tips      = get_bool("welcome_board_show_tips", true)
cfg.tips_tab_label = get_str("welcome_board_tips_tab_label", "Player Guide")
cfg.tips_body      = unescape(get_str("welcome_board_tips_body",
    "GETTING STARTED\n" ..
    "- Punch a tree trunk to collect Wood.\n" ..
    "- Open your inventory (I or Tab) and craft a Crafting Grid from 4 Wood Planks.\n" ..
    "- Place the crafting grid and make basic tools: a Wooden Pickaxe, Axe, and Sword.\n" ..
    "- Find or craft a Bed and sleep through your first night to avoid monsters.\n\n" ..
    "MINING & RESOURCES\n" ..
    "- Stone tools are stronger than wood — smelt Cobblestone into Stone or mine for Coal first.\n" ..
    "- Iron is found underground roughly 5–30 blocks below the surface.\n" ..
    "- Gold and rare ores are found deeper, below Y=-20.\n" ..
    "- Always carry a Torch! Darkness causes mobs to spawn inside caves.\n\n" ..
    "SURVIVAL\n" ..
    "- Your health recovers slowly when your hunger bar is above half — eat regularly.\n" ..
    "- Monsters (mobs) spawn in the dark. Light up your base with Torches or Lanterns.\n" ..
    "- Falling into deep water is safer than falling onto stone — use water as a landing pad.\n" ..
    "- Craft Armour early — even leather armour dramatically reduces damage taken.\n\n" ..
    "BUILDING & CRAFTING\n" ..
    "- Press I or Tab to open your inventory and access the crafting guide.\n" ..
    "- Almost all recipes can be viewed in the Crafting Guide (the book icon in inventory).\n" ..
    "- You can sleep in a Bed to skip the night and reset your spawn point.\n" ..
    "- Signs can be placed and written on to label your storage chests.\n\n" ..
    "MULTIPLAYER TIPS\n" ..
    "- Be respectful of other players' builds — grief is not tolerated.\n" ..
    "- Use /help to see available commands.\n" ..
    "- Use /spawn to return to the world spawn point at any time.\n" ..
    "- Type /msg <playername> <message> to send a private message to another player."
))

-- Rules tab
cfg.show_rules      = get_bool("welcome_board_show_rules", true)
cfg.rules_tab_label = get_str("welcome_board_rules_tab_label", "Server Rules")
cfg.rules_body      = unescape(get_str("welcome_board_rules_body",
    "Please read and follow these rules. Violation may result in a warning, kick, or permanent ban.\n\n" ..
    "1. BE RESPECTFUL\n" ..
    "   Treat all players with respect. Harassment, hate speech, discrimination, and personal attacks are strictly prohibited.\n\n" ..
    "2. NO GRIEFING\n" ..
    "   Do not destroy, steal from, or interfere with another player's builds or property without their explicit permission.\n\n" ..
    "3. NO CHEATING OR EXPLOITING\n" ..
    "   Using hacked clients, duplication exploits, or unfair advantages is not allowed.\n\n" ..
    "4. NO SPAMMING OR ADVERTISING\n" ..
    "   Do not flood the chat with repeated messages, and do not advertise other servers or websites.\n\n" ..
    "5. KEEP CHAT APPROPRIATE\n" ..
    "   Keep conversation suitable for all ages. Excessive profanity and inappropriate content are not welcome.\n\n" ..
    "6. RESPECT THE ENVIRONMENT\n" ..
    "   Do not build excessively near other players' land without consent. Leave some space between builds.\n\n" ..
    "7. REPORT ISSUES\n" ..
    "   If you witness rule-breaking or find a bug, report it to an admin rather than retaliating or exploiting it.\n\n" ..
    "8. ADMIN DECISIONS ARE FINAL\n" ..
    "   Server staff have final say in disputes. If you disagree with a decision, raise it politely.\n\n" ..
    "By playing here, you agree to follow these rules. Have fun and enjoy your adventure!"
))

-- Return visit messaging
cfg.vary_return         = get_bool("welcome_board_vary_return", true)
cfg.new_player_greeting = get_str("welcome_board_new_player_greeting", "Welcome,")
cfg.return_greeting     = get_str("welcome_board_return_greeting",     "Welcome back,")

-- Appearance
cfg.bg_color       = get_str("welcome_board_bg_color",       "#3d3d3dE6")
cfg.title_color    = get_str("welcome_board_title_color",    "#f0c040")
cfg.subtitle_color = get_str("welcome_board_subtitle_color", "#c2c2c2")
cfg.greeting_color = get_str("welcome_board_greeting_color", "#e0e0e0")
cfg.body_color     = get_str("welcome_board_body_color",     "#ffffff")
cfg.tab_color      = get_str("welcome_board_tab_color",      "#323232")
cfg.close_label    = get_str("welcome_board_close_label",    "Let's Play!")
cfg.width          = get_float("welcome_board_width",  14.0, 8.0, 20.0)
cfg.height         = get_float("welcome_board_height",  9.5, 6.0, 16.0)

-- Chat notification
cfg.chat_notify = get_bool("welcome_board_chat_notify", true)
cfg.chat_text   = get_str("welcome_board_chat_text",
    "{greeting} {player}! Type /welcome to view the welcome guide at any time.")

return cfg
