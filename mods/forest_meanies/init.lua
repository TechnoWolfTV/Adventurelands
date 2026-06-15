-- =============================================================================
-- Forest Meanies Mod  (rewritten)
-- Requires: mobs_redo, default, fire
-- =============================================================================

if not mobs then
    error("[forest_meanies] mobs_redo is required but not found!")
end

-- ---------------------------------------------------------------------------
-- Settings (server-configurable via minetest.conf)
-- ---------------------------------------------------------------------------
local cfg = minetest.settings

local NOTICE_RANGE        = tonumber(cfg:get("forest_meanies.notice_range"))        or 22
local AGGRO_RANGE         = tonumber(cfg:get("forest_meanies.aggro_range"))          or 8
local STALK_VELOCITY      = tonumber(cfg:get("forest_meanies.stalk_velocity"))       or 3.2
local HOME_RADIUS         = tonumber(cfg:get("forest_meanies.home_radius"))          or 25
local PATROL_RADIUS       = tonumber(cfg:get("forest_meanies.patrol_radius"))        or 5
local HUNTER_CHANCE       = tonumber(cfg:get("forest_meanies.hunter_chance"))        or 10
local HUNTER_RUN_VELOCITY = tonumber(cfg:get("forest_meanies.hunter_run_velocity"))  or 6.0
local DAYLIGHT_BURN_LEVEL = tonumber(cfg:get("forest_meanies.daylight_burn_level"))  or 12
local DAYLIGHT_BURN_DMG   = tonumber(cfg:get("forest_meanies.daylight_burn_damage")) or 8
local SPAWN_CHANCE        = tonumber(cfg:get("forest_meanies.spawn_chance"))         or 6000
local BURN_FIRE_GAIN      = 0.51
local BURN_ROAR_GAIN      = 0.85
local WIPE_TIME           = 0.292   -- time-of-day fraction at which dawn wipe starts
local WIPE_WINDOW         = 0.012   -- widened from 0.007 for reliability
local SCAN_INTERVAL       = 0.3     -- seconds between player-proximity rescans

-- ---------------------------------------------------------------------------
-- Pure utility helpers
-- ---------------------------------------------------------------------------

local function flat_dist(a, b)
    if not a or not b then return nil end
    local dx, dz = a.x - b.x, a.z - b.z
    return math.sqrt(dx * dx + dz * dz)
end

local function true_dist(a, b)
    if not a or not b then return nil end
    return vector.distance(a, b)
end

-- Move self toward pos at speed, preserving vertical velocity.
local function move_toward(self, pos, speed)
    local obj = self.object
    if not obj or not pos then return end
    local my_pos = obj:get_pos()
    if not my_pos then return end
    local dir = vector.direction(my_pos, pos)
    local vel = vector.multiply(dir, speed)
    vel.y = obj:get_velocity().y
    obj:set_velocity(vel)
    obj:set_yaw(math.atan2(dir.z, dir.x) - math.pi / 2)
end

local function stop_horizontal(self)
    if not self.object then return end
    local v = self.object:get_velocity()
    self.object:set_velocity({x = 0, y = v.y, z = 0})
end

-- ---------------------------------------------------------------------------
-- Sound helpers
-- ---------------------------------------------------------------------------

local function fade_stop_sound(id, fade_rate, stop_delay)
    if not id then return end
    minetest.sound_fade(id, fade_rate, 0.01)
    minetest.after(stop_delay, function()
        minetest.sound_stop(id)
    end)
end

local function fade_stop_whisper(self)
    if not self.whisper_sound_id then return end
    fade_stop_sound(self.whisper_sound_id, 0.8, 0.45)
    self.whisper_sound_id = nil
end

local function fade_stop_roar(self)
    if not self.roar_sound_id then return end
    fade_stop_sound(self.roar_sound_id, 0.6, 0.35)
    self.roar_sound_id = nil
end

local function stop_whisper_now(self)
    if not self.whisper_sound_id then return end
    minetest.sound_stop(self.whisper_sound_id)
    self.whisper_sound_id = nil
end

local function stop_burn_fire(self)
    if not self.burn_fire_sound_id then return end
    minetest.sound_stop(self.burn_fire_sound_id)
    self.burn_fire_sound_id = nil
end

local function stop_burn_roar(self)
    if not self.burn_roar_sound_id then return end
    minetest.sound_stop(self.burn_roar_sound_id)
    self.burn_roar_sound_id = nil
end

local function play_burn_fire(self)
    if self.burn_fire_sound_id then return end
    self.burn_fire_sound_id = minetest.sound_play("fire_fire", {
        object = self.object,
        gain = BURN_FIRE_GAIN,
        max_hear_distance = 16,
        loop = true,
    })
end

local function play_burn_roar(self)
    if self.burn_roar_sound_id then return end
    self.burn_roar_sound_id = minetest.sound_play("forest_meanie_roar", {
        object = self.object,
        gain = BURN_ROAR_GAIN,
        max_hear_distance = NOTICE_RANGE,
        loop = true,
    })
end

local function stop_all_sounds(self)
    fade_stop_whisper(self)
    fade_stop_roar(self)
    stop_burn_fire(self)
    stop_burn_roar(self)
end

-- ---------------------------------------------------------------------------
-- Combat helper
-- ---------------------------------------------------------------------------

local function do_melee_damage(self, target, dtime)
    if not self.object or not target or not target:is_player() then return end
    local my_pos  = self.object:get_pos()
    local tgt_pos = target:get_pos()
    if not my_pos or not tgt_pos then return end

    self.attack_cooldown = math.max(0, (self.attack_cooldown or 0) - dtime)

    -- Use true_dist for melee so vertical positions are handled correctly.
    if true_dist(my_pos, tgt_pos) <= 2.2 and self.attack_cooldown <= 0 then
        target:punch(self.object, 1.0, {
            full_punch_interval = 1.0,
            damage_groups = {fleshy = self.damage or 8},
        }, nil)
        self.attack_cooldown = 1.0
    end
end

-- ---------------------------------------------------------------------------
-- Daylight-burn VFX
-- ---------------------------------------------------------------------------

local function burn_in_daylight(self, dtime, pos)
    if not self.object then return end

    self.daylight_burn_timer = (self.daylight_burn_timer or 0) + dtime
    self.daylight_fx_timer   = (self.daylight_fx_timer   or 0) + dtime

    if self.daylight_fx_timer >= 0.15 then
        self.daylight_fx_timer = 0

        -- Flames across the body
        minetest.add_particlespawner({
            amount     = 14,
            time       = 0.15,
            minpos     = {x = pos.x - 0.45, y = pos.y + 0.1,  z = pos.z - 0.25},
            maxpos     = {x = pos.x + 0.45, y = pos.y + 1.95, z = pos.z + 0.25},
            minvel     = {x = -0.08, y = 0.25, z = -0.08},
            maxvel     = {x =  0.08, y = 0.85, z =  0.08},
            minacc     = {x = 0, y = 0.2, z = 0},
            maxacc     = {x = 0, y = 0.5, z = 0},
            minexptime = 0.3,
            maxexptime = 0.7,
            minsize    = 3,
            maxsize    = 6,
            texture    = "fire_basic_flame.png",
            glow       = 8,
        })

        -- Smoke column above head
        minetest.add_particlespawner({
            amount     = 8,
            time       = 0.25,
            minpos     = {x = pos.x - 0.18, y = pos.y + 2.1, z = pos.z - 0.18},
            maxpos     = {x = pos.x + 0.18, y = pos.y + 2.4, z = pos.z + 0.18},
            minvel     = {x = -0.04, y = 0.8,  z = -0.04},
            maxvel     = {x =  0.04, y = 1.3,  z =  0.04},
            minacc     = {x = 0, y = 0.05, z = 0},
            maxacc     = {x = 0, y = 0.15, z = 0},
            minexptime = 1.0,
            maxexptime = 1.6,
            minsize    = 4,
            maxsize    = 7,
            texture    = "default_cloud.png",
        })
    end

    if self.daylight_burn_timer >= 1.0 then
        self.daylight_burn_timer = 0
        self.object:set_hp(self.object:get_hp() - DAYLIGHT_BURN_DMG)
    end
end

-- ---------------------------------------------------------------------------
-- Orbit patrol helpers
-- ---------------------------------------------------------------------------

-- Find a walkable-surface position on the current orbit arc.
local function get_orbit_target(self)
    if not self.home_pos then return nil end

    local x = self.home_pos.x + math.cos(self.orbit_angle) * self.orbit_radius
    local z = self.home_pos.z + math.sin(self.orbit_angle) * self.orbit_radius
    local base = {x = x, y = self.home_pos.y, z = z}

    for y_off = 4, -6, -1 do
        local check = {x = base.x, y = base.y + y_off, z = base.z}
        local above = {x = check.x, y = check.y + 1,   z = check.z}
        local below = {x = check.x, y = check.y - 1,   z = check.z}

        local node  = minetest.get_node_or_nil(check)
        local anode = minetest.get_node_or_nil(above)
        local bnode = minetest.get_node_or_nil(below)

        if node and anode and bnode then
            local nd = minetest.registered_nodes[node.name]
            local ad = minetest.registered_nodes[anode.name]
            local bd = minetest.registered_nodes[bnode.name]
            if nd and ad and bd
               and not nd.walkable and not ad.walkable and bd.walkable then
                return check
            end
        end
    end
    return nil
end

local function advance_orbit(self, amount)
    self.orbit_angle = (self.orbit_angle or 0) + amount * (self.orbit_dir or 1)
end

-- ---------------------------------------------------------------------------
-- State-machine: transition logic
-- Determines which state the meanie should be in, given the nearest target.
-- Returns: new_state (string), target (obj or nil), dist (number or nil)
-- ---------------------------------------------------------------------------

local function pick_nearest_player(candidates, my_pos)
    local best, best_dist = nil, math.huge
    for _, obj in ipairs(candidates) do
        local d = flat_dist(my_pos, obj:get_pos())
        if d and d < best_dist then
            best      = obj
            best_dist = d
        end
    end
    return best, (best ~= nil and best_dist or nil)
end

local function determine_state(self, my_pos, nearby_players)
    local target, dist = pick_nearest_player(nearby_players, my_pos)

    if target then
        self.last_seen = vector.new(target:get_pos())
        if dist <= AGGRO_RANGE then
            return "aggressive", target, dist
        else
            return "stalking", target, dist
        end
    end

    -- No player visible
    self.attack = nil
    if self.is_hunter and self.last_seen then
        return "searching", nil, nil
    end

    self.last_seen = nil
    if self.home_pos and flat_dist(my_pos, self.home_pos) > 2 then
        return "returning_home", nil, nil
    end

    return "orbiting", nil, nil
end

-- ---------------------------------------------------------------------------
-- State-machine: action logic
-- Executes movement, sounds, and damage for the current state.
-- ---------------------------------------------------------------------------

local function run_state_actions(self, dtime, pos, state, target, dist)
    local chase_speed = self.is_hunter and HUNTER_RUN_VELOCITY or self.run_velocity

    -- ---- Sound management ------------------------------------------------
    if state == "aggressive" then
        stop_whisper_now(self)
        if not self.roar_sound_id then
            self.roar_sound_id = minetest.sound_play("forest_meanie_roar", {
                object           = self.object,
                gain             = 1.36,
                max_hear_distance = 32,
                loop             = true,
            })
        end

    elseif state == "stalking" then
        fade_stop_roar(self)
        self.sound_timer = math.max(0, self.sound_timer - dtime)
        if self.sound_timer <= 0 and not self.whisper_sound_id then
            self.whisper_sound_id = minetest.sound_play("forest_meanie_whisper", {
                object           = self.object,
                gain             = 0.425,
                loop             = true,
                max_hear_distance = NOTICE_RANGE,
            })
            self.sound_timer = 3
        end

    else
        fade_stop_whisper(self)
        fade_stop_roar(self)
    end

    -- ---- Movement & combat -----------------------------------------------
    if state == "stalking" and target then
        self.attack = nil
        move_toward(self, target:get_pos(), STALK_VELOCITY)

    elseif state == "aggressive" and target then
        self.attack = target
        if dist and dist > 1.2 then
            move_toward(self, target:get_pos(), chase_speed)
        else
            stop_horizontal(self)
        end
        do_melee_damage(self, target, dtime)

    elseif state == "searching" and self.last_seen then
        self.attack = nil
        move_toward(self, self.last_seen, self.walk_velocity)
        if flat_dist(pos, self.last_seen) < 1.5 then
            self.last_seen = nil
            -- Will naturally fall to returning_home or orbiting next tick
        end

    elseif state == "returning_home" and self.home_pos then
        self.attack = nil
        if flat_dist(pos, self.home_pos) > 1.5 then
            move_toward(self, self.home_pos, self.walk_velocity)
        else
            stop_horizontal(self)
            self.orbit_timer = 0
        end

    elseif state == "orbiting" and self.home_pos then
        self.attack = nil
        if self.orbit_timer <= 0
           or not self.orbit_target
           or flat_dist(pos, self.orbit_target) < 1.5 then
            advance_orbit(self, 0.8)
            self.orbit_target = get_orbit_target(self)
            self.orbit_timer  = 1.5
        end
        if self.orbit_target then
            move_toward(self, self.orbit_target, self.walk_velocity)
        else
            stop_horizontal(self)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Persistence helpers (save/restore home_pos across server restarts)
-- ---------------------------------------------------------------------------

local function serialize_static(self)
    if not self.home_pos then return "" end
    return minetest.serialize({
        home_pos   = self.home_pos,
        is_hunter  = self.is_hunter,
        orbit_angle = self.orbit_angle,
        orbit_radius = self.orbit_radius,
        orbit_dir   = self.orbit_dir,
    })
end

local function deserialize_static(self, data)
    if not data or data == "" then return end
    local ok, t = pcall(minetest.deserialize, data)
    if not ok or type(t) ~= "table" then return end
    self.home_pos     = t.home_pos
    self.is_hunter    = t.is_hunter
    self.orbit_angle  = t.orbit_angle
    self.orbit_radius = t.orbit_radius
    self.orbit_dir    = t.orbit_dir
end

-- ---------------------------------------------------------------------------
-- Mob registration
-- ---------------------------------------------------------------------------

mobs:register_mob("forest_meanies:meanie", {
    type         = "monster",
    passive      = false,
    -- Use attack_type "none" so mobs_redo does NOT run its own parallel
    -- attack/pathfinding loop; we manage all movement and damage ourselves.
    attack_type  = "none",
    reach        = 2,
    damage       = 8,
    hp_min       = 80,
    hp_max       = 120,
    armor        = 80,
    collisionbox = {-0.35, 0.0, -0.35, 0.35, 1.9, 0.35},
    selectionbox = {-0.35, 0.0, -0.35, 0.35, 1.9, 0.35},
    visual       = "mesh",
    mesh         = "forest_meanie.b3d",
    textures     = {{"forest_meanie.png"}},
    visual_size  = {x = 1.08, y = 1.08},
    glow         = 3,
    makes_footstep_sound = true,
    -- Suppress mobs_redo's random sound trigger; we control sounds ourselves.
    sounds       = {},
    walk_velocity  = 1.2,
    run_velocity   = 4.5,
    view_range     = 25,
    jump           = true,
    stepheight     = 1.1,
    fear_height    = 4,
    lava_damage    = 5,
    light_damage   = 0,
    water_damage   = 1,
    knock_back     = 1,
    blood_amount   = 15,
    animation = {
        speed_normal = 15,
        speed_run    = 25,
        stand_start  = 0,
        stand_end    = 79,
        walk_start   = 168,
        walk_end     = 187,
        run_start    = 168,
        run_end      = 187,
        punch_start  = 200,
        punch_end    = 219,
    },

    -- ------------------------------------------------------------------
    -- get_staticdata / on_activate for home_pos persistence
    -- ------------------------------------------------------------------
    get_staticdata = function(self)
        return serialize_static(self)
    end,

    on_activate = function(self, staticdata, dtime_s)
        deserialize_static(self, staticdata)
        -- Timers
        self.sound_timer         = 0
        self.orbit_timer         = 0
        self.attack_cooldown     = 0
        self.daylight_burn_timer = 0
        self.daylight_fx_timer   = 0
        self.scan_timer          = 0
        self.wipe_checked        = false
        self.meanie_state        = self.meanie_state or "orbiting"
        -- Sound handles
        self.whisper_sound_id   = nil
        self.roar_sound_id      = nil
        self.burn_fire_sound_id = nil
        self.burn_roar_sound_id = nil
        -- Cached nearby-player list
        self.nearby_players_cache = {}
    end,

    -- ------------------------------------------------------------------
    -- on_spawn: initialise fields that don't need to persist
    -- ------------------------------------------------------------------
    on_spawn = function(self)
        local pos = self.object:get_pos()

        -- Prevent clustering: remove self if another meanie is already
        -- within 30 nodes. This stops hotspots from accumulating multiple
        -- meanies anchored to the same patch of forest floor.
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 30)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "forest_meanies:meanie" and obj ~= self.object then
                self.object:remove()
                return
            end
        end
        -- Only set home_pos if on_activate didn't restore one.
        if not self.home_pos then
            self.home_pos = pos and vector.round(pos) or nil
        end
        if self.is_hunter == nil then
            self.is_hunter = (math.random(1, 100) <= HUNTER_CHANCE)
        end
        self.orbit_angle  = self.orbit_angle  or (math.random() * math.pi * 2)
        self.orbit_radius = self.orbit_radius or (PATROL_RADIUS - 1 + math.random())
        self.orbit_dir    = self.orbit_dir    or (math.random(0, 1) == 0 and -1 or 1)
        self.orbit_timer  = 0
        self.orbit_target = get_orbit_target(self)
        self.object:set_properties({visual_size = {x = 1.08, y = 1.08}})
    end,

    -- ------------------------------------------------------------------
    -- on_death: clean up all looping sounds
    -- ------------------------------------------------------------------
    on_death = function(self)
        stop_all_sounds(self)
    end,

    -- ------------------------------------------------------------------
    -- do_custom: main per-tick logic
    -- ------------------------------------------------------------------
    do_custom = function(self, dtime)
        -- ---- Guard -------------------------------------------------------
        local pos = self.object:get_pos()
        if not pos then return end

        -- ---- Tick timers -------------------------------------------------
        self.sound_timer    = math.max(0, (self.sound_timer    or 0) - dtime)
        self.orbit_timer    = math.max(0, (self.orbit_timer    or 0) - dtime)
        self.scan_timer     = math.max(0, (self.scan_timer     or 0) - dtime)
        self.particle_timer = math.max(0, (self.particle_timer or 0) - dtime)

        -- ---- Hunter red particle aura ------------------------------------
        -- Emits a slow drift of dark red particles around hunter variants,
        -- giving a subtle sinister visual cue without lighting up surroundings.
        if self.is_hunter and self.particle_timer <= 0 then
            self.particle_timer = 0.5
            minetest.add_particlespawner({
                amount     = 2,
                time       = 0.5,
                minpos     = {x = pos.x - 0.3, y = pos.y + 0.4, z = pos.z - 0.3},
                maxpos     = {x = pos.x + 0.3, y = pos.y + 1.6, z = pos.z + 0.3},
                minvel     = {x = -0.05, y = 0.04, z = -0.05},
                maxvel     = {x =  0.05, y = 0.10, z =  0.05},
                minacc     = {x = 0, y = 0, z = 0},
                maxacc     = {x = 0, y = 0, z = 0},
                minexptime = 1.5,
                maxexptime = 2.5,
                minsize    = 1.0,
                maxsize    = 2.0,
                texture    = "meanie_hunter_particle.png",
                glow       = 3,
            })
        end

        -- ---- Dawn wipe ---------------------------------------------------
        -- Meanies dissolve at dawn (unless already burning, which means
        -- they'll die naturally from burn damage).
        local tod = minetest.get_timeofday()
        local in_wipe_window = tod >= WIPE_TIME and tod < (WIPE_TIME + WIPE_WINDOW)

        if in_wipe_window and not self.wipe_checked then
            self.wipe_checked = true
            if self.meanie_state ~= "burning" then
                stop_all_sounds(self)
                self.object:remove()
                return
            end
        elseif not in_wipe_window then
            self.wipe_checked = false
        end

        -- ---- Daylight burn -----------------------------------------------
        local light = minetest.get_node_light(pos) or 0
        if light >= DAYLIGHT_BURN_LEVEL then
            self.attack      = nil
            self.last_seen   = nil
            self.meanie_state = "burning"
            stop_horizontal(self)
            fade_stop_whisper(self)
            fade_stop_roar(self)

            -- Only play burn sounds when a player can hear them.
            local player_nearby = false
            for _, obj in ipairs(minetest.get_objects_inside_radius(pos, NOTICE_RANGE)) do
                if obj:is_player() then player_nearby = true; break end
            end
            if player_nearby then
                play_burn_fire(self)
                play_burn_roar(self)
            else
                stop_burn_fire(self)
                stop_burn_roar(self)
            end

            self.object:set_animation({x = 200, y = 219}, 35, 0, true)
            burn_in_daylight(self, dtime, pos)
            return
        end

        stop_burn_fire(self)
        stop_burn_roar(self)

        -- ---- Throttled player scan ---------------------------------------
        -- We only re-query nearby objects every SCAN_INTERVAL seconds to
        -- avoid calling get_objects_inside_radius on every single tick.
        if self.scan_timer <= 0 then
            self.scan_timer = SCAN_INTERVAL
            local raw = minetest.get_objects_inside_radius(pos, NOTICE_RANGE)
            local players = {}
            for _, obj in ipairs(raw) do
                if obj:is_player() then
                    -- Double-check with flat_dist because the radius query
                    -- uses 3-D distance and we want the flat check.
                    if flat_dist(pos, obj:get_pos()) <= NOTICE_RANGE then
                        players[#players + 1] = obj
                    end
                end
            end
            self.nearby_players_cache = players
        end

        -- ---- State transition --------------------------------------------
        local new_state, target, dist =
            determine_state(self, pos, self.nearby_players_cache)

        -- Reset roar flag when returning to passive states.
        if new_state == "orbiting" or new_state == "returning_home" then
            self.roared = false
        end

        self.meanie_state = new_state

        -- ---- State actions -----------------------------------------------
        run_state_actions(self, dtime, pos, new_state, target, dist)
    end,
})

-- ---------------------------------------------------------------------------
-- Spawn registration
-- ---------------------------------------------------------------------------

mobs:spawn({
    name                = "forest_meanies:meanie",
    nodes               = {"default:dirt_with_grass"},
    neighbors           = {"group:tree"},
    min_light           = 0,
    max_light           = 7,
    interval            = 30,
    chance              = SPAWN_CHANCE,
    active_object_count = 8,
    min_height          = 1,
    max_height          = 200,
})

mobs:register_egg("forest_meanies:meanie", "Forest Meanie", "default_tree.png", 1)
