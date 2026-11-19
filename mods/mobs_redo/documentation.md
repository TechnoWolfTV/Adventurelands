# Mobs Redo API – Developer Documentation

**API version:** `20261114`
**Framework:** Luanti / Minetest – Mobs Redo

---

# 1. Introduction

Mobs Redo provides a framework for creating, registering and managing custom mobs in Luanti.

The API handles much of the functionality required by a mob, including:

- Entity registration and initialisation.
- Movement and pathfinding.
- Animation and rotation.
- Combat and damage.
- Health and death.
- Item drops.
- Breeding and taming.
- Spawning.
- Mounting and player-controlled movement.
- Custom callbacks and event handling.

Rather than implementing all of these systems yourself, you can register a mob with a definition table and allow Mobs Redo to handle the underlying behaviour.

# 2. Initialising the API

To use Mobs Redo from another mod, declare it as a dependency in your `mod.conf`.

```ini
name = my_mob_mod
depends = mobs
```

Then access the global `mobs` table.

```lua
mobs:register_mob("my_mob_mod:example", {
    type = "animal",
    hp_max = 20,
    damage = 2,
})
```

The global API table is created by `api.lua`.

Some useful global properties include:

| Variable | Description |
|---|---|
| `mobs.mod` | Mod identifier, currently `"redo"`. |
| `mobs.version` | API version string. |
| `mobs.spawning_mobs` | Stores spawning information for registered mobs. |
| `mobs.translate` | Translation function for Mobs Redo. |
| `mobs.node_snow` | Detected snow node. |
| `mobs.node_dirt` | Detected dirt node. |
| `mobs.fallback_node` | Fallback node used for unknown nodes. |
| `mobs.mob_class` | Default mob class and shared methods. |

# 3. Registering a mob

The primary function for creating a mob is:

```lua
mobs:register_mob(name, def)
```

**Parameters:**

- `name`: Full registered entity name, including the mod namespace.
- `def`: Table containing the mob's properties, behaviour and callbacks.

Example:

```lua
mobs:register_mob("my_mob_mod:wolf", {

    type = "animal",
    description = "Wolf",

    hp_max = 20,
    hp_min = 15,
    armor = 100,
    damage = 3,
    attack_type = "dogfight",

    textures = {
        "wolf.png"
    },

    visual = "mesh",
    mesh = "wolf.b3d",
    visual_size = {x = 1, y = 1},

    collisionbox = {
        -0.3, -0.5, -0.3,
         0.3,  0.5,  0.3
    },

    walk_velocity = 2,
    run_velocity = 4,
    jump_height = 4,

    animation = {
        stand_start = 0,
        stand_end = 20,

        walk_start = 21,
        walk_end = 40,

        speed_normal = 15
    }
})
```

The API builds an entity definition from the supplied table and registers it with the engine.

## 3.1 Mob definition properties

The following properties are read by `register_mob`.

### Basic properties

| Property | Description |
|---|---|
| `type` | Mob category, commonly `animal`, `monster` or `npc`. |
| `description` | Display description. Defaults to the entity name. |
| `nametag` | Initial nametag. |
| `owner` | Initial owner name. |
| `order` | Initial mob order. |
| `lifetimer` | Time before the mob expires. Defaults to 180 seconds. |
| `hp_max` | Maximum health. Defaults to 10 before difficulty scaling. |
| `hp_min` | Minimum initial health. Defaults to 5 before difficulty scaling. |
| `drops` | Items dropped when killed. |

### Model and appearance

| Property | Description |
|---|---|
| `visual` | Entity visual type. |
| `visual_size` | Visual dimensions. Defaults to `{x = 1, y = 1}`. |
| `mesh` | Model filename. |
| `textures` | Available mob textures. |
| `texture_mods` | Texture modifier string. |
| `collisionbox` | Physical collision dimensions. |
| `selectionbox` | Selection dimensions. Defaults to the collisionbox. |
| `animation` | Animation definitions. |
| `child_texture` | Child-specific texture. |
| `child_mesh` | Child-specific mesh. |
| `rotate` | Model rotation in degrees. |
| `glow` | Entity glow value. |
| `use_texture_alpha` | Texture transparency configuration. |
| `backface_culling` | Backface culling configuration. |
| `makes_footstep_sound` | Whether the entity makes footstep sounds. |
| `stepheight` | Maximum step height. Defaults to 1.1. |
| `damage_texture_modifier` | Texture modifier applied for damage. |

### Movement and behaviour

| Property | Description |
|---|---|
| `jump_height` | Jump velocity. Defaults to 4. |
| `jump_chance` | Chance-related jump configuration. |
| `fly` | Enables flying behaviour. |
| `fly_in` | Nodes or groups the mob can fly in. Defaults to `"air"`. |
| `keep_flying` | Flying behaviour configuration. |
| `circle_flight` | Enables circular flight behaviour. |
| `circle_radius` | Circular flight radius. |
| `circle_speed` | Circular flight speed. |
| `can_leap` | Allows the mob to leap over obstacles. |
| `view_range` | Normal detection range. Defaults to 5. |
| `view_range_attacking` | Detection range while attacking. |
| `walk_velocity` | Walking speed. Defaults to 1. |
| `run_velocity` | Running speed. Defaults to 2. |
| `fear_height` | Height of drops the mob avoids. |
| `runaway` | Enables runaway behaviour. |
| `runaway_from` | Targets or entities to flee from. |
| `follow` | Items or groups that attract the mob. |
| `floats` | Allows floating behaviour. |
| `pathfinding` | Pathfinding configuration. |
| `pushable` | Allows collision-based pushing. |
| `stay_near` | Nodes the mob tries to remain near. |
| `randomly_turn` | Enables random turning. Defaults to true. |
| `docile_by_day` | Makes the mob docile during daytime. |
| `ignore_invisibility` | Ignores the invisibility compatibility check. |
| `messages` | NPC idle messages. |
| `ai_enabled` | Initial AI enabled state. |

### Health and damage

| Property | Description |
|---|---|
| `armor` | Armor value or armor-group table. Defaults to 100. |
| `damage` | Damage dealt by the mob. |
| `damage_group` | Damage group used for attacks. |
| `light_damage` | Damage caused by light exposure. |
| `light_damage_min` | Minimum light level for light damage. Defaults to 14. |
| `light_damage_max` | Maximum light level for light damage. Defaults to 15. |
| `water_damage` | Damage received in water. |
| `lava_damage` | Damage received in lava. Defaults to 4. |
| `fire_damage` | Damage received from fire. Defaults to 4. |
| `air_damage` | Damage received while in air. |
| `node_damage` | Enables damage from damaging nodes. |
| `suffocation` | Suffocation damage. Defaults to 2. |
| `fall_damage` | Enables fall damage. |
| `fall_speed` | Gravity/falling acceleration. |

### Combat

| Property | Description |
|---|---|
| `attack_type` | Attack behaviour type. |
| `punch_interval` | Attack punch interval. Defaults to 1. |
| `arrow` | Projectile entity name. |
| `arrow_override` | Projectile override configuration. |
| `shoot_interval` | Shooting interval. Defaults to 2. |
| `shoot_chance` | Shooting chance. Defaults to 80. |
| `shoot_offset` | Projectile launch offset. |
| `homing` | Homing attack configuration. |
| `walk_chance` | Walking behaviour chance. |
| `stand_chance` | Standing behaviour chance. |
| `attack_chance` | Attack behaviour chance. |
| `attack_patience` | How long an attack is maintained. |
| `passive` | Makes the mob passive. |
| `knock_back` | Enables knockback. |
| `blood_amount` | Blood particle amount. |
| `blood_texture` | Blood particle texture. |
| `immune_to` | List of damage or tool immunities. |
| `explosion_radius` | Explosion radius. |
| `explosion_damage_radius` | Explosion entity damage radius. |
| `explosion_timer` | Explosion countdown. Defaults to 3. |
| `allow_fuse_reset` | Allows explosion countdown reset. |
| `stop_to_explode` | Stops movement before exploding. |
| `dogshoot_switch` | Projectile attack mode switch. |
| `dogshoot_count_max` | First projectile attack count. |
| `dogshoot_count2_max` | Second projectile attack count. |
| `group_attack` | Allows group attacks. |
| `group_helper` | Group attack helper configuration. |
| `attack_monsters` | Allows attacks against monsters. |
| `attack_animals` | Allows attacks against animals. |
| `attack_players` | Allows attacks against players. |
| `attack_npcs` | Allows attacks against NPCs. |
| `attack_ignore` | Entities to ignore. |
| `specific_attack` | Specific attack targets. |
| `friendly_fire` | Friendly-fire configuration. |
| `owner_loyal` | Owner loyalty behaviour. |

# 4. Custom callbacks

Callbacks allow your mod to execute custom code when specific mob events occur.

These are assigned inside the mob definition.

## `on_rightclick(self, clicker)`

Called when a player interacts with the mob.

Useful for:
- Opening forms.
- Mounting the mob.
- Feeding or taming.
- Custom interaction behaviour.

## `on_die(self, pos)`

Called when the mob dies.

This is a Mobs Redo-specific death callback.

Returning `true` prevents the normal removal process, allowing custom death handling.

## `on_death(self, killer)`

Uses the engine-style death callback.

The killer is supplied when death resulted from a player punch; otherwise it can be nil.

## `on_flop(self)`

Custom behaviour associated with the mob's flop handling.

## `do_custom(self, dtime)`

Allows custom behaviour to be executed during the mob's AI processing.

## `do_mount_action(self, dtime)`

Called when the rider activates the mob's mount action.

Useful for custom mounted abilities.

## `on_replace(self, pos, oldnode, newnode)`

Custom handling when the mob replaces a node.

## `custom_attack(self, target)`

Provides custom attack behaviour.

## `on_spawn(self)`

Called when the mob spawns.

Returning true sets the `on_spawn_run` flag to prevent the activation-time callback from running again.

## `on_blast(self, damage)`

Called when the mob is affected by a blast.

## `do_punch(self, hitter, tflp, tool_caps, dir, damage)`

Custom punch handling.

## `on_breed(self, mate)`

Custom breeding behaviour.

## `on_grown(self)`

Called when a child mob becomes an adult.

## `on_sound(self, sound_data)`

Called when the mob hears a sound, provided sound hearing is enabled and the mob is within hearing range.

The sound data includes:
- `pos`: Sound position.
- `sound`: Sound name.
- `gain`: Sound volume.
- `max_hear_distance`: Maximum hearing range.
- `distance`: Distance between sound and mob.
- `loudness`: Calculated sound loudness.

# 5. Public API functions

The following functions are exposed through the global `mobs` table.

## Mob management

### `mobs:register_mob(name, def)`

Registers a new mob entity.

### `mobs:add_mob(pos, def)`

Creates a registered mob at a position.

Parameters:
- `pos`: Spawn position.
- `def`: Spawn definition containing at least `name`.

Additional options:
- `texture`: Overrides the mob texture.
- `child`: Spawns the mob as a child.
- `owner`: Assigns an owner.
- `nametag`: Sets its nametag.
- `ignore_count`: Bypasses the per-area count check.

Returns the created Lua entity, or nil if spawning fails.

### `mobs:remove(self, decrease)`

Removes a mob.

Parameters:
- `self`: Mob Lua entity.
- `decrease`: Whether to decrement the active-mob counter.

### `mobs:set_ai(self, enabled)`

Enables or disables mob AI.

Disabling AI clears attack and following targets, resets the state and stops movement.

### `mobs:alias_mob(old_name, new_name)`

Creates a compatibility alias for a renamed mob.

Existing mobs using the old name are redirected to the new entity.

## Spawning

### `mobs:spawn(def)`

Recommended spawning registration function.

Example:

```lua
mobs:spawn({
    name = "my_mob_mod:wolf",

    nodes = {"group:soil"},
    neighbors = {"air"},

    min_light = 0,
    max_light = 15,

    interval = 45,
    chance = 5000,

    active_object_count = 2,

    min_height = -31000,
    max_height = 31000,

    day_toggle = nil,

    on_spawn = function(self, pos)
        -- Custom spawn behaviour
    end,

    on_map_load = false
})
```

Available fields:

| Field | Description |
|---|---|
| `name` | Registered mob name. |
| `nodes` | Nodes on which spawning is permitted. |
| `neighbors` | Required nearby nodes. |
| `min_light` | Minimum light level. |
| `max_light` | Maximum light level. |
| `interval` | Spawn checking interval. |
| `chance` | Spawn probability parameter. |
| `active_object_count` | Maximum number of the same mob in the area. |
| `min_height` | Minimum Y coordinate. |
| `max_height` | Maximum Y coordinate. |
| `day_toggle` | Day/night spawning configuration. |
| `on_spawn` | Spawn callback. |
| `on_map_load` | Registers map-load spawning instead of ABM spawning. |

### `mobs:spawn_specific(...)`

Older, lower-level spawning registration function.

Signature:

```lua
mobs:spawn_specific(
    name, nodes, neighbors,
    min_light, max_light,
    interval, chance, aoc,
    min_height, max_height,
    day_toggle, on_spawn,
    map_load, def
)
```

Prefer `mobs:spawn()` for new integrations.

### `mobs:spawn_abm_check(pos, node, name)`

Additional spawning check hook.

Returning true stops spawning at the checked position.

### `mobs:can_spawn(pos, name)`

Checks whether there is sufficient physical space to spawn a mob.

Returns a valid position or nil.

## Utility functions

### `mobs.is_creative(name)`

Checks whether a player is in creative mode or has the creative privilege.

### `mobs:node_ok(pos, fallback)`

Gets a node at a position.

If the node is unavailable or unknown, a fallback node is returned.

### `mobs:effect(pos, amount, texture, min_size, max_size, radius, grav, glow, fall)`

Creates a particle spawner.

Parameters:
- `pos`: Particle origin.
- `amount`: Number of particles.
- `texture`: Particle texture.
- `min_size`: Minimum particle size.
- `max_size`: Maximum particle size.
- `radius`: Spread radius.
- `grav`: Vertical acceleration.
- `glow`: Particle glow.
- `fall`: Controls initial vertical particle velocity.

### `mobs:is_node_dangerous(mob_object, nodename)`

Checks whether a node can damage a particular mob.

Considers the mob's environmental damage settings and immunity list.

### `mobs:is_invisible(self, player_name)`

Checks whether a player is invisible to the mob.

Uses the optional invisibility mod when available.

## Scaling

### `mobs:scale_mob(self, w, h, perma)`

Changes the visual size, collisionbox and selectionbox of a mob.

Parameters:
- `self`: Mob entity.
- `w`: Width/depth multiplier.
- `h`: Height multiplier.
- `perma`: Whether the new dimensions replace the stored base dimensions.

Example:

```lua
mobs:scale_mob(self, 1.5, 1.5, true)
```

## Combat and explosions

### `mobs:safe_boom(self, pos, radius, texture)`

Creates an explosion effect without node destruction.

It also applies entity physics to nearby objects.

### `mobs:boom(self, pos, node_damage_radius, entity_radius, texture)`

Creates an explosion with compatibility checks for the TNT or MineClone explosion systems.

If node destruction is unavailable or disabled, it falls back to `safe_boom`.

## Capturing and taming

### `mobs:force_capture(self, clicker)`

Forcefully captures a mob into a special mob egg containing serialized mob information.

### `mobs:capture_mob(self, clicker, chance_hand, chance_net, chance_lasso, force_take, replacewith)`

Attempts to capture a mob.

Parameters:
- `self`: Mob entity.
- `clicker`: Player attempting capture.
- `chance_hand`: Capture chance using an empty hand.
- `chance_net`: Capture chance using a net.
- `chance_lasso`: Capture chance using a lasso.
- `force_take`: Allows capturing without normal ownership/taming checks.
- `replacewith`: Optional alternative item to return.

Capture chances are percentage values.

### `mobs:protect(self, clicker)`

Applies protection to a tamed mob using a protection rune.

The function supports two protection levels.

### `mobs:feed_tame(self, clicker, feed_count, breed, tame)`

Handles feeding, healing, taming and breeding.

Parameters:
- `self`: Mob entity.
- `clicker`: Player feeding the mob.
- `feed_count`: Number of feeding actions required.
- `breed`: Enables breeding.
- `tame`: Enables taming.

Feeding also restores up to four health points per interaction.

## Spawn eggs

### `mobs:register_egg(mob, desc, background, addegg, no_creative, can_spawn_protect)`

Registers spawn eggs for a mob.

Parameters:
- `mob`: Registered entity name.
- `desc`: Egg description.
- `background`: Inventory image.
- `addegg`: Adds the chicken egg overlay when set to 1.
- `no_creative`: Hides the egg from creative inventory.
- `can_spawn_protect`: Controls spawning in protected areas.

For non-monster mobs, a special non-stackable `_set` egg is also registered to preserve mob information.

# 6. Mob class methods – `self`

One of the most important concepts in Mobs Redo is `self`.

Whenever a mob class method is called using colon syntax:

```lua
self:set_velocity(2)
```

Lua automatically passes the mob entity as the first argument.

This means:

```lua
function mob_class:set_velocity(v)
```

is equivalent to:

```lua
function mob_class.set_velocity(self, v)
```

`self` represents the Lua entity belonging to the particular mob instance.

For example:

```lua
function mob_class:do_custom(dtime)

    self.health = self.health - 1

    self:set_animation("injured")

end
```

This changes the health and animation of the specific mob executing the function.

## 6.1 Important self variables

The following variables are particularly useful when developing custom mobs.

### Entity and engine references

| Variable | Description |
|---|---|
| `self.object` | The actual Luanti ObjectRef for the mob. |
| `self.name` | Registered entity name. |
| `self.prop` | Cached entity properties obtained from `get_properties()`. |
| `self.temp` | Temporary runtime storage. |
| `self.initial_properties` | Initial entity properties inherited through the registered entity definition. |

`self.object` is particularly important.

It provides access to engine functionality:

```lua
local pos = self.object:get_pos()

self.object:set_velocity({
    x = 0,
    y = 2,
    z = 0
})
```

### Health and survival

| Variable | Description |
|---|---|
| `self.health` | Current mob health. |
| `self.old_health` | Previously recorded health. |
| `self.hp_min` | Minimum initial health. |
| `self.prop.hp_max` | Maximum health from the cached entity properties. |
| `self.armor` | Armor configuration. |
| `self.damage` | Mob attack damage. |
| `self.water_damage` | Water damage amount. |
| `self.lava_damage` | Lava damage amount. |
| `self.fire_damage` | Fire damage amount. |
| `self.air_damage` | Air damage amount. |
| `self.light_damage` | Light damage amount. |
| `self.suffocation` | Suffocation damage configuration. |
| `self.fall_damage` | Whether fall damage is enabled. |
| `self.immune_to` | Immunity configuration. |
| `self.cause_of_death` | Information about the mob's death. |

### Position and movement

| Variable | Description |
|---|---|
| `self.state` | Current AI state. |
| `self.order` | Current mob order. |
| `self.walk_velocity` | Walking speed. |
| `self.run_velocity` | Running speed. |
| `self.jump_height` | Jump velocity. |
| `self.fly` | Whether the mob can fly. |
| `self.fly_in` | Permitted flying nodes or groups. |
| `self.floats` | Floating behaviour. |
| `self.rotate` | Model rotation offset in radians. |
| `self.target_yaw` | Target rotation. |
| `self.delay` | Rotation delay. |
| `self.pushable` | Whether collision pushing is enabled. |
| `self.driver` | Player currently riding the mob. |
| `self.v` | Mount movement speed state. |
| `self.fall_velocity` | Stored fastest falling velocity. |

### Environment

| Variable | Description |
|---|---|
| `self.standing_in` | Node the mob is currently inside. |
| `self.standing_on` | Node beneath the mob. |
| `self.looking_at` | Node the mob is looking towards. |
| `self.looking_above` | Node above the mob's forward position. |
| `self.time_of_day` | Current time of day. |
| `self.touching_ground` | Whether the mob is touching the ground. |
| `self.facing_fence` | Whether the mob is facing a fence-like obstacle. |
| `self.fear_height` | Height-based cliff avoidance setting. |

### AI and targeting

| Variable | Description |
|---|---|
| `self.ai_enabled` | Whether AI is enabled. |
| `self.attack` | Current attack target. |
| `self.following` | Current follow target. |
| `self.follow` | Items that attract the mob. |
| `self.runaway` | Whether runaway behaviour is enabled. |
| `self.runaway_from` | Entities or targets to flee from. |
| `self.attack_monsters` | Whether monsters can be targeted. |
| `self.attack_animals` | Whether animals can be targeted. |
| `self.attack_players` | Whether players can be targeted. |
| `self.attack_npcs` | Whether NPCs can be targeted. |
| `self.attack_ignore` | Targets to ignore. |
| `self.group_attack` | Whether group attacks are enabled. |
| `self.path` | Current pathfinding information. |

The `self.path` table contains:

```lua
self.path = {
    way = {},
    lastpos = {x = 0, y = 0, z = 0},
    stuck = false,
    stuck_timer = 0,
    following = false
}
```

### Ownership and breeding

| Variable | Description |
|---|---|
| `self.owner` | Owner's player name. |
| `self.tamed` | Whether the mob is tamed. |
| `self.protected` | Protection level. |
| `self.horny` | Whether the mob can breed. |
| `self.hornytimer` | Breeding or growth timer. |
| `self.child` | Whether the mob is a child. |
| `self.gotten` | Whether the mob has been captured or otherwise marked as gotten. |
| `self.food` | Feeding progress. |
| `self.mommy_tex` | Stored adult texture for a child mob. |
| `self._nametag` | Custom mob name. |
| `self._breed_countdown` | Breeding progress display. |
| `self._tame_countdown` | Taming progress display. |

### Appearance and animation

| Variable | Description |
|---|---|
| `self.base_texture` | Original texture. |
| `self.base_mesh` | Original mesh. |
| `self.base_size` | Original visual size. |
| `self.base_colbox` | Original collisionbox. |
| `self.base_selbox` | Original selectionbox. |
| `self.texture_mods` | Current texture modifier string. |
| `self.animation` | Animation definitions. |
| `self.animation_current` | Currently playing animation. |
| `self.animation_set` | Requested animation group. |
| `self.animation_priority` | Current animation priority. |
| `self.animation_timer` | Animation lock timer stored in `self.temp`. |
| `self.sounds` | Sound definition table. |

### Important temporary variables

`self.temp` is a special table used for values that should not be saved when the mob is serialized.

Examples include:

```lua
self.temp.blinktimer
self.temp.jump_count
self.temp.animation_timer
```

Use it for temporary timers, counters and other runtime-only information.

Example:

```lua
function mob_class:do_custom(dtime)

    self.temp.my_timer =
        (self.temp.my_timer or 0) + dtime

    if self.temp.my_timer >= 5 then

        self.temp.my_timer = 0

        self:mob_sound("my_mod_custom_sound")

    end
end
```

This prevents temporary state from being included in saved mob data.

# 7. Mob class methods

These functions belong to `mobs.mob_class` and are generally called using `self:function()`.

They are not all global functions in the `mobs` table.

## Movement and rotation

| Method | Description |
|---|---|
| `self:set_velocity(v)` | Moves the mob in its facing direction. |
| `self:get_velocity()` | Returns horizontal movement speed. |
| `self:set_yaw(yaw, delay)` | Changes horizontal rotation. |
| `self:set_pitch(pitch)` | Changes pitch rotation. |
| `self:set_roll(roll)` | Changes roll rotation. |
| `self:yaw_to_pos(target, rot, delay)` | Turns the mob towards a position. |
| `self:collision()` | Calculates player collision-pushing forces. |
| `self:do_jump()` | Handles jumping behaviour. |
| `self:is_at_cliff()` | Checks whether the mob is approaching a dangerous drop. |

## Animation and sound

| Method | Description |
|---|---|
| `self:set_animation(anim, force)` | Changes the mob animation. |
| `self:ground_animation(anim1, anim2, force)` | Selects a ground or flying animation. |
| `self:mob_sound(sound)` | Plays a mob sound. |
| `self:update_tag(newname)` | Updates nametag and infotext. |
| `self:death_anim()` | Handles the death animation. |

## Environment and navigation

| Method | Description |
|---|---|
| `self:line_of_sight(pos1, pos2)` | Checks line of sight between positions. |
| `self:flight_check()` | Checks whether the mob is in a permitted flying medium. |
| `self:attempt_flight_correction(override)` | Attempts to move the mob into a valid flying medium. |
| `self:do_stay_near()` | Handles stay-near node behaviour. |
| `self:is_inside(itemtable)` | Checks whether specified nodes or groups intersect the mob's collision area. |
| `self:do_env_damage()` | Applies environmental damage. |
| `self:falling(pos)` | Handles falling and fall damage. |
| `self:get_nodes()` | Updates node information around the mob. |

## AI and combat

| Method | Description |
|---|---|
| `self:do_attack(player, force)` | Starts an attack against a target. |
| `self:general_attack()` | Handles general attack target selection. |
| `self:follow_target(s, p, dtime)` | Handles following a target. |
| `self:follow_flop(dtime)` | Handles following behaviour for flopping mobs. |
| `self:follow_teleport()` | Handles teleporting to a follow target. |
| `self:do_runaway_from()` | Handles runaway behaviour. |
| `self:stop_attack()` | Stops the current attack. |
| `self:do_states(dtime)` | Processes the mob's current AI state. |
| `self:smart_mobs(s, target_pos, dist, dtime)` | Handles smart mob pathfinding. |
| `self:apply_path(way, target_pos, add_jump, set_velocity)` | Applies a pathfinding route. |
| `self:go_to(pos)` | Directs the mob towards a position. |
| `self:dogswitch(dtime)` | Handles the dogshoot attack state. |

## Mob lifecycle

| Method | Description |
|---|---|
| `self:mob_activate(staticdata, def, dtime)` | Initialises or restores a mob. |
| `self:mob_staticdata()` | Serializes mob information. |
| `self:on_step(dtime, moveresult)` | Main mob update function. |
| `self:mob_expire(pos, dtime)` | Handles mob expiration. |
| `self:check_for_death(cmi_cause)` | Checks health and processes death. |
| `self:item_drop()` | Generates mob drops. |
| `self:on_punch(hitter, tflp, tool_caps, dir, damage)` | Handles damage from punches. |
| `self:on_blast(damage)` | Handles blast damage. |
| `self:breed()` | Handles breeding and child growth. |
| `self:replace(pos, dtime)` | Handles node replacement. |
| `self:check_item_pickup(pos)` | Handles item pickup. |
| `self:day_docile()` | Handles daytime docile behaviour. |
| `self:follow_flop(dtime)` | Handles movement while flopping. |

# 8. Animation system

Animations are configured through the `animation` definition table.

Example:

```lua
animation = {

    speed_normal = 15,

    stand_start = 0,
    stand_end = 20,

    walk_start = 21,
    walk_end = 40,

    run_start = 41,
    run_end = 60,

    punch_start = 61,
    punch_end = 80,

    die_start = 81,
    die_end = 100,
    die_loop = false,
    die_locked = 2, -- locks animation for 2 seconds
}
```

The API supports multiple animation variants:

```lua
stand1_start = 0,
stand1_end = 20,

stand2_start = 21,
stand2_end = 40
```

The API can randomly choose between variants.

Supported default animation priorities:

| Animation | Priority |
|---|---:|
| `stand` | 0 |
| `walk` | 1 |
| `run` | 1 |
| `fly` | 1 |
| `glide` | 1 |
| `eat` | 1 |
| `jump` | 2 |
| `falling` | 2 |
| `punch` | 3 |
| `shoot` | 3 |
| `injured` | 3 |
| `die` | 4 |

Custom priorities can be assigned using fields such as `walk_priority`.

Use:

```lua
self:set_animation("walk")
```

To override animation locking:

```lua
self:set_animation("die", true)
```

# 9. Projectile registration

Projectiles are registered using:

```lua
mobs:register_arrow(name, def)
```

Example:

```lua
mobs:register_arrow("my_mob_mod:arrow", {

    visual = "sprite",
    textures = {"arrow.png"},

    velocity = 12,
    lifetime = 4.5,

    hit_player = function(self, player)
        -- Player collision
    end,

    hit_node = function(self, pos, node)
        -- Node collision
    end,

    hit_mob = function(self, mob)
        -- Mobs Redo mob collision
    end,

    hit_object = function(self, object)
        -- Other entity collision
    end
})
```

Important projectile definition fields:

| Field | Description |
|---|---|
| `physical` | Whether the projectile is physical. |
| `collide_with_objects` | Whether it collides with objects. |
| `visual` | Projectile visual type. |
| `visual_size` | Projectile dimensions. |
| `mesh` | Projectile mesh. |
| `textures` | Projectile textures. |
| `collisionbox` | Collision dimensions. |
| `glow` | Glow level. |
| `velocity` | Projectile velocity. |
| `lifetime` | Maximum lifetime. Defaults to 4.5 seconds. |
| `owner_id` | Projectile owner identifier. |
| `rotate` | Automatic movement-facing rotation configuration. |
| `tail_texture` | Optional particle trail. |
| `tail_size` | Trail particle size. |
| `expire` | Trail particle expiration time. |
| `drop` | Whether or how often the projectile drops an item. |
| `drop_item` | Custom dropped item. |
| `hit_player` | Player collision callback. |
| `hit_node` | Node collision callback. |
| `hit_mob` | Mobs Redo entity collision callback. |
| `hit_object` | Other entity collision callback. |
| `do_custom` | Custom projectile update callback. |
| `on_activate` | Activation callback. |
| `on_punch` | Punch callback. |
| `on_step` | Custom update function. |

The default projectile update handles lifetime, homing, particle trails and collision detection.

# 10. Mounting API – mount.lua

The second file provides functionality for attaching players to mobs and allowing them to control those mobs.

Mount support requires either:

- `player_api`, or
- MineClone support through `mcl_mobs`.

If neither is installed, the following functions are created as empty functions:

```lua
mobs.attach()
mobs.detach()
mobs.fly()
mobs.drive()
```

This means calls do not perform actual mounting functionality in that situation.

## 10.1 `mobs.attach(entity, player)`

Attaches a player to a mob.

Example:

```lua
mobs.attach(self, clicker)
```

Parameters:
- `entity`: Mob entity.
- `player`: Player ObjectRef.

The function:
- Stores the driver on `entity.driver`.
- Detaches the player from any previous attachment.
- Attaches the player to the mob object.
- Applies player rotation and eye offsets.
- Applies driver visual scaling.
- Changes the player's animation to a sitting animation.
- Synchronises the player's horizontal look direction with the mob.

## 10.2 `mobs.detach(player)`

Detaches a player from their current mount.

Example:

```lua
mobs.detach(self.driver)
```

The function:
- Removes the attachment.
- Clears the mob's driver reference when appropriate.
- Resets player animation and visual size.
- Searches for a nearby free position.
- Moves the player to the resulting position.

## 10.3 `mobs.drive(entity, moving_anim, stand_anim, can_fly, dtime)`

Handles player-controlled movement for a mounted mob.

Parameters:

| Parameter | Description |
|---|---|
| `entity` | Mob being controlled. |
| `moving_anim` | Animation while moving. |
| `stand_anim` | Animation while stationary. |
| `can_fly` | Enables vertical flight controls. |
| `dtime` | Time since the previous update. |

The function handles:
- Forward movement.
- Reverse movement.
- Acceleration.
- Braking.
- Turning.
- Jumping.
- Optional vertical flight.
- Movement and idle animations.
- Custom mount actions.

Example:

```lua
function mob_class:on_step(dtime)

    if self.driver then
        mobs.drive(
            self,
            "walk",
            "stand",
            false,
            dtime
        )
    end

end
```

## 10.4 `mobs.fly(entity, dtime, speed, shoots, arrow, moving_anim, stand_anim)`

Provides a flight control system for mounted flying mobs.

Parameters:

| Parameter | Description |
|---|---|
| `entity` | Mob being controlled. |
| `dtime` | Time since the previous update. |
| `speed` | Flight speed. |
| `shoots` | Enables the legacy projectile shooting option. |
| `arrow` | Projectile entity name. |
| `moving_anim` | Moving animation. |
| `stand_anim` | Stationary animation. |

Controls:
- Forward: Fly in the direction the player is looking.
- Backward: Fly in reverse relative to the look direction.
- No movement: Descend.
- Sneak + left mouse button: Execute the mount action or legacy shooting behaviour.

# 11. Important mount variables

Mount functionality relies on several properties stored directly on the mob entity.

These are particularly important when implementing rideable mobs.

| Variable | Description |
|---|---|
| `self.driver` | Player currently riding the mob. |
| `self.player_rotation` | Player rotation while attached. |
| `self.driver_attach_at` | Position offset used to attach the player. |
| `self.driver_eye_offset` | Player eye offset while riding. |
| `self.driver_scale` | Player visual scaling while riding. |
| `self.accel` | Mount acceleration. |
| `self.v` | Current horizontal movement speed. |
| `self.max_speed_forward` | Maximum forward speed. |
| `self.max_speed_reverse` | Maximum reverse speed. |
| `self.alt_turn` | Enables alternative turning controls. |
| `self.fall_speed` | Falling acceleration used by driving. |
| `self.jump_height` | Jump velocity. |
| `self.rotate` | Mob model rotation offset. |
| `self.arrow_shoot_timer` | Legacy projectile shooting timer. |
| `self.do_mount_action` | Custom mounted ability callback. |

## 11.1 Example mount configuration

The following is an example of configuring a mob for riding:

```lua
mobs:register_mob("my_mob_mod:mount", {

    type = "animal",

    hp_max = 30,

    visual = "mesh",
    mesh = "mount.b3d",

    textures = {"mount.png"},

    collisionbox = {
        -0.5, -0.5, -0.5,
         0.5,  1.0,  0.5
    },

    on_rightclick = function(self, clicker)

        if self.driver then

            if self.driver == clicker then
                mobs.detach(clicker)
            end

        elseif self.tamed and self.owner == clicker:get_player_name() then

            mobs.attach(self, clicker)

        end

    end,

    do_mount_action = function(self, dtime)

        -- Custom mounted ability

    end

})
```

To handle movement, call the driving function during the mob's update cycle.

```lua
if self.driver then

    mobs.drive(
        self,
        "walk",
        "stand",
        false,
        dtime
    )

end
```

# 12. Important internal settings

The API reads several settings from `core.settings`.

These affect how mobs behave globally.

| Setting | Description |
|---|---|
| `enable_damage` | Whether damage is enabled. |
| `mobs_spawn` | Enables or disables mob spawning. |
| `only_peaceful_mobs` | Restricts spawning to peaceful mobs. |
| `mobs_disable_blood` | Controls blood effects. |
| `mob_hit_effect` | Controls hit effects. |
| `mobs_drop_items` | Enables item drops. |
| `mobs_griefing` | Enables mob-related node destruction. |
| `mobs_spawn_protected` | Controls spawning in protected areas. |
| `mobs_spawn_monster_protected` | Controls monster spawning in protected areas. |
| `remove_far_mobs` | Controls removal of distant untamed monsters. |
| `mob_area_spawn` | Controls area-based spawn clearance. |
| `mob_difficulty` | Scales health and damage. |
| `max_objects_per_block` | Maximum objects per block. |
| `mob_nospawn_range` | Player proximity spawn restriction. |
| `mob_active_limit` | Maximum active mob count. |
| `mob_chance_multiplier` | Spawn chance multiplier. |
| `enable_peaceful_player` | Peaceful player behaviour setting. |
| `mob_smooth_rotate` | Enables smooth rotation. |
| `mob_height_fix` | Adjusts small mob collisionboxes. |
| `mob_log_spawn` | Logs mob spawning. |
| `mob_infotext` | Enables mob infotext. |
| `movement_gravity` | Movement gravity. |
| `mob_node_timer_interval` | Node update interval. |
| `mob_main_timer_interval` | Main update interval. |
| `mob_pathfinding_enable` | Enables pathfinding. |
| `mob_pathfinding_stuck_timeout` | General stuck timeout. |
| `mob_pathfinding_stuck_path_timeout` | Path stuck timeout. |
| `mob_pathfinding_algorithm` | Pathfinding algorithm. |
| `mob_pathfinding_max_jump` | Maximum pathfinding jump. |
| `mob_pathfinding_max_drop` | Maximum pathfinding drop. |
| `mob_pathfinding_searchdistance` | Pathfinding search distance. |
| `mobs_disable_damage_kb` | Disables damage knockback. |
| `mobs_can_hear` | Enables mob sound hearing. |
| `mobs_can_hear_node` | Enables sound callbacks for nodes. |

# 13. Compatibility

The API includes checks for several optional mods.

| Mod | Integration |
|---|---|
| `cmi` | Creature interface and damage/death notifications. |
| `mcl_core` | MineClone node compatibility. |
| `visual_harm_1ndicators` | Health bar integration. |
| `toolranks` | Tool compatibility detection. |
| `invisibility` | Player invisibility detection. |
| `player_api` | Player attachment and mount animations. |
| `mcl_mobs` | MineClone mounting compatibility. |
| `mcl_explosions` | MineClone explosion integration. |
| `tnt` | TNT explosion integration. |

Optional integrations are checked before being used.

# 14. Important development notes

## Always use the correct entity reference

The API distinguishes between the mob Lua entity and its ObjectRef.

```lua
self
```

Represents the Lua entity.

```lua
self.object
```

Represents the engine ObjectRef.

Use the Lua entity to access mob-specific variables and methods.

Use the ObjectRef to manipulate the actual entity in the world.

## Use `self.temp` for temporary data

Avoid placing temporary timers and counters directly on `self` if they should not persist through serialization.

```lua
self.temp.timer = (self.temp.timer or 0) + dtime
```

## Preserve the original mob properties

When scaling a mob, use `mobs:scale_mob()` rather than modifying only the visual size.

The API maintains base size, collisionbox and selectionbox information.

## Respect the API's callbacks

Avoid replacing built-in lifecycle methods unless you understand their responsibilities.

For example, replacing `on_step` entirely can bypass movement, AI, environmental damage and other systems.

Prefer `do_custom` for additional per-update behaviour.

## Account for optional dependencies

Always check whether optional integrations exist before accessing their globals.

Mounting also requires the appropriate player API.

## Avoid relying on internal local functions

Functions such as `get_distance`, `node_ok` (the local implementation), `drop_item` and `remove_mob` are internal helpers.

Some have public wrappers, but the local functions themselves are not accessible from other mods.

# 15. Quick reference

## Main global API

| Function | Purpose |
|---|---|
| `mobs:register_mob()` | Register a mob. |
| `mobs:add_mob()` | Create a mob. |
| `mobs:remove()` | Remove a mob. |
| `mobs:set_ai()` | Enable or disable AI. |
| `mobs:spawn()` | Register spawning. |
| `mobs:spawn_specific()` | Legacy spawning registration. |
| `mobs:can_spawn()` | Check spawning clearance. |
| `mobs:register_arrow()` | Register a projectile. |
| `mobs:register_egg()` | Register spawn eggs. |
| `mobs:scale_mob()` | Scale a mob. |
| `mobs:node_ok()` | Safely retrieve a node. |
| `mobs:effect()` | Create particle effects. |
| `mobs:boom()` | Create an explosion. |
| `mobs:safe_boom()` | Create an explosion without node damage. |
| `mobs:capture_mob()` | Capture a mob. |
| `mobs:force_capture()` | Force capture a mob. |
| `mobs:feed_tame()` | Feed, tame and breed. |
| `mobs:protect()` | Protect a tamed mob. |
| `mobs:alias_mob()` | Add a compatibility alias. |
| `mobs.is_creative()` | Check creative status. |
| `mobs:is_invisible()` | Check player invisibility. |
| `mobs:is_node_dangerous()` | Check node danger. |

## Main mount API

| Function | Purpose |
|---|---|
| `mobs.attach()` | Attach a player to a mob. |
| `mobs.detach()` | Detach a player. |
| `mobs.drive()` | Handle ground movement. |
| `mobs.fly()` | Handle mounted flight. |

## Most useful self variables

| Variable | Purpose |
|---|---|
| `self.object` | Entity ObjectRef. |
| `self.health` | Current health. |
| `self.state` | AI state. |
| `self.attack` | Attack target. |
| `self.following` | Follow target. |
| `self.owner` | Owner name. |
| `self.tamed` | Taming status. |
| `self.child` | Child status. |
| `self.driver` | Mounted player. |
| `self.temp` | Temporary storage. |
| `self.path` | Pathfinding data. |
| `self.animation` | Animation definitions. |
| `self.sounds` | Sound definitions. |
| `self.standing_in` | Current node. |
| `self.standing_on` | Ground node. |
| `self.base_texture` | Original texture. |
| `self.base_mesh` | Original mesh. |

---


# 16. Items, tools and craftables – crafts.lua

The `crafts.lua` file registers the items, tools and nodes supplied by Mobs Redo. It also defines their crafting recipes, cooking behaviour, fuel values and a small number of helper functions.

## 16.1 Registered items

The following craft items are registered by Mobs Redo.

| Item name | Description | Behaviour and properties |
|---|---|---|
| `mobs:nametag` | Name Tag | Intended to be used by right-clicking a Mobs Redo mob to apply a name. Has the `nametag` group. |
| `mobs:leather` | Leather | Craft item with the `leather` group. |
| `mobs:meat_raw` | Raw Meat | Can be eaten and restores 3 health points. Has the `food_meat_raw` group. |
| `mobs:meat` | Meat | Cooked meat. Can be eaten and restores 8 health points. Has the `food_meat` group. |
| `mobs:protector` | Mob Protection Rune | Used to protect a tamed mob. |
| `mobs:protector2` | Mob Protection Rune (Level 2) | Higher-level protection rune. |
| `mobs:saddle` | Saddle | Item used by rideable mobs; has the `saddle` group. |

The food items are registered with `mobs.add_eatable()`, which adds the `eatable`, `flammable` and `food` groups to an already registered item when that item exists.

### `mobs.add_eatable(item, hp, ftype)`

Adds Mobs Redo food-related groups to an existing registered item.

**Parameters:**

- `item`: Registered item name to modify.
- `hp`: Health value assigned to the `eatable` group.
- `ftype`: Optional food group value. (Defaults to `2` for food, use '3' for drink).

The function copies the item's existing groups before adding or replacing these values, then applies the updated groups with `core.override_item()`.

Example:

```lua
mobs.add_eatable("mobs:meat", 8)
```

## 16.2 Registered tools

| Tool name | Description | Behaviour |
|---|---|---|
| `mobs:lasso` | Lasso | Right-click an animal to put it into the player's inventory. |
| `mobs:net` | Net | Right-click an animal to put it into the player's inventory. |
| `mobs:shears` | Steel Shears | Right-click an animal to shear it. |
| `mobs:mob_reset_stick` | Mob Reset Stick | Utility tool for resetting a mob entity or changing its texture. |

`mobs:magic_lasso` is registered as an alias of `mobs:lasso` for compatibility.

### Mob Reset Stick

The Mob Reset Stick is registered as:

```lua
mobs:mob_reset_stick
```

It has a maximum stack size of one and belongs to the `not_in_creative_inventory` group.

When used on an object:

- **Normal use:** Creates a replacement entity of the same registered mob type at the original mob's position. It copies the mob's protection, owner, nametag, capture state, taming state, health and order, then removes the original entity.
- **Sneak-use:** Opens a formspec allowing the player to enter a texture filename. The entered value is limited to 64 characters and is applied as the mob's base texture.

The texture form can only update the mob if the mob still exists and the player is still wielding the Mob Reset Stick.

## 16.3 Registered nodes

| Node name | Description | Behaviour |
|---|---|---|
| `mobs:mob_repellent` | Mob Repellent | Prevents mobs from spawning within a 16-node radius, as stated in its in-game description. |
| `mobs:fence_wood` | Mob Fence | Registered only when the `default` mod and its `register_fence` function are available. Uses a taller collision box to help contain mobs. |
| `mobs:fence_top` | Mob Fence Top | Fence-top component with an enlarged collision and selection box intended to stop mobs getting over the fence. |
| `mobs:meatblock` | Meat Block | Edible node that restores 20 health points when eaten. |
| `mobs:meatblock_raw` | Raw Meat Block | Edible raw-meat node that restores 20 health points when eaten. |
| `mobs:hearing_vines` | Hearing Vines | Non-walkable plant-like node that reacts to sufficiently loud sounds. |
| `mobs:hearing_vines_active` | Active Hearing Vines | Temporary active state of Hearing Vines. Emits light, damages entities standing in it and changes back after its timer expires. |

### Mob Repellent

The Mob Repellent is crafted from obsidian, red dye and a Mob Protection Rune. Its description states that it stops mobs spawning within a 8-block radius.

If the optional `vizlib` mod is installed, punching the node with an empty hand can display a visual cube showing the repellent area.

### Mob Fence

`mobs:fence_wood` is conditional: it is registered through `default.register_fence()` only when the `default` mod is present and provides that function.

The fence uses a collision box extending to a height of 1.9 nodes.

`mobs:fence_top` is registered separately and has enlarged collision and selection boxes. Its recipe produces 12 fence-top pieces.

### Meat Blocks

Both meat blocks can be eaten directly:

| Node | Food value | Recipe |
|---|---:|---|
| `mobs:meatblock` | 20 | 9 cooked meat |
| `mobs:meatblock_raw` | 20 | 9 raw meat |

The raw meat block can be cooked into `mobs:meatblock` with a cooking time of 30 seconds.

### Hearing Vines

Hearing Vines use the `on_sound` callback. When the received sound has a loudness greater than `0.5`, the normal node changes into `mobs:hearing_vines_active`.

The active node:

- Emits light level 1.
- Deals 4 damage per second.
- Starts a one-second node timer when constructed.
- Changes back into `mobs:hearing_vines` when the timer expires.
- Sends receptor-on and receptor-off signals when Mesecons is available.

The active node drops the normal Hearing Vines node.

## 16.4 Crafting and cooking recipes

Recipes use a compatibility table named `items` in `crafts.lua`. It selects ingredient names according to whether MineClone's `mcl_core` mod is available or the Minetest `default` environment is being used.

| Recipe ingredient key | MineClone item or group | Default item or group |
|---|---|---|
| `paper` | `mcl_core:paper` | `default:paper` |
| `dye_black` | `mcl_dye:black` | `dye:black` |
| `dye_red` | `mcl_dye:red` | `dye:red` |
| `string` | `mcl_mobitems:string` | `farming:string` |
| `stick` | `mcl_core:stick` | `default:stick` |
| `diamond` | `mcl_core:diamond` | `default:diamond` |
| `steel_ingot` | `mcl_core:iron_ingot` | `default:steel_ingot` |
| `gold_block` | `mcl_core:goldblock` | `default:goldblock` |
| `diamond_block` | `mcl_core:diamondblock` | `default:diamondblock` |
| `stone` | `mcl_core:stone` | `default:stone` |
| `mese_crystal` | `mcl_core:gold_ingot` | `default:mese_crystal` |
| `wood` | `mcl_core:wood` | `default:wood` |
| `fence_wood` | `group:fence_wood` | `default:fence_wood` |
| `meat_raw` | `mcl_mobitems:beef` | `group:food_meat_raw` |
| `meat_cooked` | `mcl_mobitems:cooked_beef` | `group:food_meat` |
| `obsidian` | `mcl_core:obsidian` | `default:obsidian` |

The recipes registered in `crafts.lua` are:

| Output | Recipe |
|---|---|
| `mobs:nametag` | Paper + black dye + string |
| `mobs:lasso` | String in all four corners; diamond in the centre |
| `mobs:net` | Sticks in the two outer columns of the first two rows; string, stick, string in the bottom row |
| `mobs:shears` | Steel ingot at the top-middle; stick at the bottom-middle; steel ingot at the bottom-right |
| `mobs:protector` | Stone surrounding a gold block in the centre |
| `mobs:protector2` | Mob Protection Runes in the corners, mese crystal around a diamond block |
| `mobs:mob_repellent` | Obsidian around a Mob Protection Rune, with red dye at the top-middle |
| `mobs:saddle` | Leather in the outer positions, with steel ingots in the middle positions of the bottom two rows |
| `mobs:fence_top 12` | Three wood-group items across the top row and a fence-wood item in the centre of the middle row |
| `mobs:meatblock` | 9 cooked meat |
| `mobs:meatblock_raw` | 9 raw meat |

The cooking recipes are:

| Input | Output | Cooking time |
|---|---|---:|
| `mobs:meat_raw` | `mobs:meat` | 5 seconds |
| `mobs:meatblock_raw` | `mobs:meatblock` | 30 seconds |

Leather, the Mob Reset Stick, Hearing Vines and the normal Mob Fence do not have crafting recipes registered in this file. The normal Mob Fence is registered only through the optional `default` integration.

## 16.5 Fuel values

The following fuel recipes are registered:

| Item | Burn time |
|---|---:|
| `mobs:nametag` | 3 seconds |
| `mobs:lasso` | 7 seconds |
| `mobs:net` | 8 seconds |
| `mobs:leather` | 4 seconds |
| `mobs:saddle` | 7 seconds |
| `mobs:fence_wood` | 7 seconds |
| `mobs:fence_top` | 2 seconds |

The fuel recipes are registered directly in `crafts.lua`. The file does not define fuel values for every item or node it registers.

## 16.6 Compatibility and sound helpers

At initialisation, `crafts.lua` selects recipe ingredients based on whether `mcl_core` or `default` is available.

It also assigns the following sound helper functions to the global `mobs` table:

- `mobs.node_sound_defaults()`
- `mobs.node_sound_stone_defaults()`
- `mobs.node_sound_dirt_defaults()`
- `mobs.node_sound_sand_defaults()`
- `mobs.node_sound_gravel_defaults()`
- `mobs.node_sound_wood_defaults()`
- `mobs.node_sound_leaves_defaults()`
- `mobs.node_sound_ice_defaults()`
- `mobs.node_sound_metal_defaults()`
- `mobs.node_sound_water_defaults()`
- `mobs.node_sound_snow_defaults()`
- `mobs.node_sound_glass_defaults()`

Each helper uses the corresponding function from `default` when available, otherwise the MineClone `mcl_sounds` implementation when available. If neither is available, it falls back to a function returning an empty table.

---

# 17. Conclusion

Mobs Redo provides a comprehensive framework for developing custom entities without having to implement every system independently.

The most important concepts to understand when developing against this API are:

1. `mobs:register_mob()` creates and configures your entity.
2. The mob definition table controls its appearance, movement, health and behaviour.
3. `self` represents the individual mob entity.
4. `self.object` provides access to the Luanti engine entity.
5. `self.temp` stores temporary runtime information.
6. Custom callbacks allow additional behaviour without replacing the built-in systems.
7. `mobs:register_arrow()` provides projectile registration.
8. The mount API provides player attachment and vehicle-like movement.
9. The built-in AI, pathfinding, combat and lifecycle systems should be reused wherever possible.
