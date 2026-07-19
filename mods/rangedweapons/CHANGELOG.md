# Changelog

Upstream `rangedweapons` ships no changelog — its README points to the git
commit list instead. This file is therefore new, created to record the changes
made in this fork.

Upstream: https://github.com/daviddoesminetest/rangedweapons

---

## master — 2026

Changes by **TechnoWolfTV**. Everything below is relative to upstream; this is
the first release of the fork, so it is presented as a single version.

Build marker `master` appears in `mod.conf`, `admin/init.lua`
(`rangedweapons_admin.VERSION`), the admin panel header, and `/rwadmin debug`.

---

## Added

### In-game admin panel — `/rwadmin`

A control panel for switching individual weapons, ammunition and components on
and off while the server runs, gated behind the `server` privilege. Lives in
`admin/`, loaded by one line appended to `init.lua`.

Tabs for Firearms, Energy, Thrown, Ammunition and Other, with search and
pagination. The Other tab is further grouped into **Core components**,
**Energy** and **Miscellaneous**. Click an item to switch it off, click again
to switch it back on.

Hovering an item shows its status and full stat block — damage, accuracy, crit
chance, clip size, compatible ammunition, rate of fire — with colour escape
codes stripped.

Bulk actions cover the current tab and search (**Disable these** / **Enable
these**) or every tab at once (**Disable everything** / **Enable everything**).

State persists in mod storage under `rwadmin_disabled` and is restored at every
server start.

### Dependency awareness

Disabling a shared component silently starves everything downstream of it, so
the panel works that out and says so.

Crafting dependencies are derived from the recipe graph rather than hardcoded,
so they stay correct if the crafting tree changes:

| component | items it is used to craft |
|---|---|
| `gunsteel_ingot` | 13 |
| `plastic_sheet` | 13 |
| `gun_power_core` | 5 |
| `ultra_gunsteel_ingot` | 2 |
| `ak47`, `deagle`, `40mm` | 1 each |

Those last three are weapons and ammunition that are themselves ingredients in
upgrade recipes, so the core marking appears on the Firearms and Ammunition
tabs too, not only under Other.

Functional dependencies are tracked as well: disabling an ammunition type
reports how many guns are chambered for it — `9mm` feeds **11** — and warns
more loudly for any gun left with no usable ammunition at all, since those guns
still show as enabled while being useless.

Core components render amber while enabled, their tooltip names how many things
depend on them, and `/rwadmin deps <item>` lists both kinds.

### Player guide — `/rwinfo`

A scrollable in-game help screen, open to every player, no privilege required.
None of this mod's controls are discoverable by guessing: firing, reloading,
unloading, shell ejection and scope zoom are all bound to inputs with no in-game
hint.

Covers controls, firing, reloading, unloading, ammunition, skills, safe zones,
what to do when something stops working, and the full command list with the
privilege each needs. The admin panel links to it.

### Unloading guns — sneak + right-click

Empties a gun, returning every round to the player's inventory and dropping
anything that does not fit at their feet.

Upstream had no unload at all. Rounds left a gun only by being fired, or as a
side effect of reloading — and reloading does nothing unless the player already
holds compatible ammunition, so a gun loaded with ammunition they no longer
carry could not be emptied.

Handled on all three right-click paths, since loaded shotguns and bolt-action
rifles bind right-click to shell ejection rather than reload. Unloading also
works on a disabled gun, so ammunition can always be recovered.

### Optional Unified Inventory tab

If Unified Inventory is installed, a **Gun Skills** button appears in the
inventory and opens a tab showing all nine weapon skills with their icons and
current percentages. Purely optional — declared as an `optional_depends` and
registered only if that mod is present, so `/gunskills` works exactly as
before without it.

Both views read the same accessor, so they cannot disagree.

### Commands

| Command | Privilege | Effect |
|---|---|---|
| `/rwinfo` | anyone | Player guide |
| `/gunskills` | anyone | Weapon skill levels (upstream, unchanged) |
| `/rwadmin` | `server` | Open the admin panel |
| `/rwadmin list` | `server` | What is currently disabled |
| `/rwadmin deps <item>` | `server` | What depends on an item |
| `/rwadmin off <item>` | `server` | Disable one item |
| `/rwadmin on <item>` | `server` | Enable one item |
| `/rwadmin off-all` | `server` | Disable everything |
| `/rwadmin on-all` | `server` | Enable everything |
| `/rwadmin debug` | `server` | Health check |

### Settings

**`rangedweapons_admin_strict`** (default on). A disabled item is inert
everywhere and immediately — it cannot be fired, thrown, reloaded, placed,
crafted, used as a crafting ingredient, or loaded into a gun, and rounds
already chambered will not fire. Placed explosive barrels stop detonating.
Turn it off for gradual behaviour, where disabling only stops an item being
produced and existing stock keeps working until it runs out.

**`rangedweapons_skill_messages`** (default off). Upstream announced every gun
skill gain and loss in chat. Skills drift constantly, so the running commentary
is noise during normal play; it is now silent by default while the skills
themselves rise and fall exactly as before. Players check their levels with
`/gunskills`, or the Gun Skills tab. Set to `true` for the old behaviour.

**`rangedweapons_ammo_stack_max`** (default 0). Forces every ammunition type to
the same stack size. `0` keeps upstream's per-ammo values, which scale
inversely with ammunition power and are deliberate rather than an oversight:

| ammo | stack | damage | note |
|---|---|---|---|
| 9mm | 500 | 1 | |
| 45acp | 450 | 2 | |
| 10mm | 400 | 2 | |
| 556mm | 300 | 3 | |
| 762mm | 250 | 4 | |
| 357 / 44 | 150 | 4 | |
| 50ae | 100 | 8 | |
| 308winchester | 75 | 8 | |
| shell (12 gauge) | 50 | 2 | ×4–6 pellets per shot |
| 408cheytac | 40 | 10 | |
| 40mm | 25 | 10 | |
| rocket | 15 | 15 | |

---

## What "disabled" means

| | disabled item |
|---|---|
| Firing, throwing, reloading | blocked |
| Ammunition already loaded in a gun | will not fire |
| Loading that ammunition into a gun | blocked |
| Energy weapons, when `power_particle` is disabled | blocked |
| Explosive barrels already placed in the world | inert |
| Crafting the item | blocked |
| Using it as a crafting ingredient | blocked |
| Its recipe in the craft guide | hidden |
| Listed in creative inventory and craft guide | **yes, still listed** |
| Unloading a disabled gun | **still works** |
| Removed from player inventories | **never** |

Nothing is ever deleted or taken. Stock is kept but inactive and works again
the moment an admin re-enables the item.

Players get an empty-chamber click and a chat message naming the reason, rather
than silent failure. The two are throttled separately: the message at most once
every two seconds so held automatic fire cannot flood the screen, the sound far
more often so the weapon still feels responsive. Both are sent to that player
alone.

---

## Fixed

Upstream bugs found by scanning compiled bytecode for `SETGLOBAL` opcodes,
running upstream's own luacheck configuration, and manual review.

### Multiplayer: HUD ids stored in globals — serious

`init.lua` assigned HUD element ids to bare globals in
`register_on_joinplayer`. HUD ids are per-player, so every player shared the
**last-joined player's** ids, and hit markers and the scope overlay were
applied to the wrong player on any server with more than one person online.
Now stored per-player with cleanup on leave. Affects `init.lua`,
`cooldown_stuff.lua`, `ammo.lua`.

### Multiplayer: `/gunskills` showed someone else's skills

The command looped over every connected player, read each one's metadata, and
showed the *caller* a form built from whichever player the loop happened to
reach last. Alone it looked correct; on a server you saw another player's
numbers. It now reads the caller's own skills, and handles the caller not being
in game.

### Crash: `eject_shell` nil dereference — serious

The guard read `if bulletStack ~= ""`, comparing an ItemStack to a string,
which is always true. A gun with no ammunition name in its metadata then
indexed a nil capabilities table and crashed.

### Crash: hit marker on a departed shooter

`ammo.lua` called `hud_change` on a player reference that is nil if the shooter
disconnected while their bullet was still in flight.

### Ammunition silently deleted

Unloading a gun returns its remaining rounds with `inv:add_item(...)`, but the
return value — whatever did not fit — was discarded at both call sites.
Reloading with a full inventory destroyed the ammunition in the gun. The
remainder is now dropped at the player's feet.

### Divide by zero on durability

`add_wear(65535 / gun_durability)` with `gun_durability` defaulting to zero.
Every current gun defines it, so this was latent rather than live, but any gun
added without it would produce infinity. Guarded for guns and energy weapons.

### Settings that silently did nothing

Both read names that `settingtypes.txt` never declared, so they had no effect
at any value:

| File | Was | Now |
|---|---|---|
| `init.lua` | `rangedweapon_forceguns` | `rangedweapons_forceguns` |
| `crafting.lua` | `rangedweapons_other_weapons_crafting` | `rangedweapons_other_weapon_crafting` |

### Performance: redundant work every server step

`cooldown_stuff.lua` runs for every connected player on every server step and
called `player:get_wielded_item()` thirteen times per player per tick, each
call allocating an ItemStack and repeating the same definition lookup. On a
forty-player server that is roughly ten thousand allocations a second for
information that cannot change within a tick. Reduced to a handful, preserving
the one re-fetch that is load-bearing.

### Positional stereo sound assets

Six sound files shipped as stereo but are played positionally:
`hit.ogg`, `rangedweapons_bulletdrop.ogg`, `rangedweapons_empty.ogg`,
`rangedweapons_glock.ogg`, `rangedweapons_rifle_a.ogg` and
`rangedweapons_shotgun_full.ogg`.

Luanti can only place mono sources in 3D. A stereo file played with a position
makes the engine log `Creating positional stereo sound` on every play, and the
sound is not actually positioned — distance and direction do nothing for it.

All six are now mono, at their original sample rates and durations. Two of
them, `rangedweapons_empty` and `rangedweapons_rifle_a`, have partly
out-of-phase channels — averaging them would have cancelled 5 dB and 1.3 dB of
level respectively, so those take a single channel instead. Levels are within
0.3 dB of the originals across all six, so nothing sounds quieter or louder
than before; the difference is that positional audio now works and the warnings
stop.

### Deprecated and obsolete API

- `add_player_velocity` (deprecated since 5.4) replaced with `add_velocity` in
  `forcegun.lua` (×2) and `bullet_knockback.lua`.
- `hud_elem_type` replaced with `type` in HUD registration.
- `alpha = 160` on `rangedweapons:broken_glass` replaced with opacity baked
  into the texture plus `use_texture_alpha = "blend"`, preserving the same
  translucency.

### Global namespace pollution

Eleven variables leaked into the global namespace, ten of them silenced by
whitelist entries in `.luacheckrc` rather than addressed: `hit`, `scope_hud`,
`javStack`, `rw_proj_kb_pos_x/y/z`, `throw_projectiles`, `gun_unload_sound`,
`forbidden_ents`, `knockback` and `btimer`. All are now locals or properly
namespaced, and the stale whitelist entries were removed.

Only genuine API functions remain global.

---

## Design notes

Worth knowing before modifying this mod.

**Automatic weapons do not use `on_use`.** They fire from a globalstep in
`cooldown_stuff.lua`, so enforcement wraps the mod's global entry points as
well as the per-item callbacks. Overriding item callbacks alone would leave
every automatic gun fully working.

**Each weapon is a family.** `rangedweapons:glock17` is accompanied by hidden
definitions for its reload and cooldown frames (`_r`, `_rr`, `_rrr`, `_rld`).
Disabling covers the whole family, so a player holding a half-reloaded gun does
not keep a working weapon.

**No engine state is mutated at runtime.** The admin panel never calls
`core.override_item`, `core.clear_craft` or `core.register_craft` after load.
The engine documents runtime item overrides as unsupported, and the panel does
not need them: guards are installed once at startup and toggling an item only
changes a Lua table. Blocking is done entirely through the documented craft,
use, place and reload callbacks, all of which fail open on an internal error
rather than risking a server.

**Craft-guide changes are confined to that guide's own cache**, are symmetric,
and are reconciled in a single idempotent pass that can be re-run at any time.
Because craft guides build their index in their own `mods_loaded` callback,
which may run after this one, the initial reconcile is deferred to the first
server step.

---

## Known limits

Disabled items remain listed in the creative inventory and the craft guide;
only their recipes are hidden. Using them does nothing and the player is told
why.

Recipe hiding depends on a craft guide keeping its recipes in
`unified_inventory.crafts_for.recipe`. If a future version restructures that
table, recipes would stay visible; crafting them would still be blocked, and
the access is defensive so nothing breaks. Craft guides other than Unified
Inventory are not hooked, so they may still display a disabled item's recipe —
crafting it is still blocked.

---

## Checked and deliberately left alone

- **`rengedweapons_ricochet`** in `make_sparks` looks like a typo, but
  `sounds/rengedweapons_ricochet.ogg` is misspelled the same way. Code and
  asset agree, so it works. Renaming both would be churn.
- **`itemstack = ""` in `hand_grenade.lua`** destroys the stack rather than
  taking one item, but the grenade is `stack_max = 1`, so it is equivalent.
- **Shared `gtimer` in `hand_grenade.lua`** is global fuse state across all
  players. Fixing it properly means reworking the fuse to per-entity timers,
  which is a behaviour change rather than a bug fix.
- **The `doors:hidden` ABM in `init.lua`** runs once a second against every
  hidden door node in the world. A real cost on a large, door-heavy server, but
  changing it risks breaking door interaction.

---

## Verifying this build

`.luacheckrc` and `.github/workflows/luacheck.yml` ship with the mod, so
upstream's own linter reproduces these numbers:

```
luacheck .
```

| | files | warnings | errors |
|---|---|---|---|
| upstream | 51 | 53 | 0 |
| this build | 59 | 45 | 0 |

The `admin/` directory contributes zero warnings. The remainder are
pre-existing upstream style notes — trailing whitespace and two shadowed
arguments — left alone as churn.

`/rwadmin debug` reports live state: build marker, item counts, whether the
enforcement hooks are in place, and how many craft-guide recipes are hidden.
