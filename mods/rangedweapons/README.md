# rangedweapons

A direct clone of https://github.com/daviddoesminetest/rangedweapons. ALL CREDIT GOES THERE!
See also: https://forum.minetest.net/viewtopic.php?f=9&t=15173

See list of commits for improvements.

---

# Modifications

Modified by **TechnoWolfTV**, 2026. This is a fork, not the upstream mod — the
notes above this line are upstream's and refer to the original repository.

Full detail in [CHANGELOG.md](CHANGELOG.md). Licensing and attribution in
[license.txt](license.txt); this fork remains CC BY-SA 4.0.

## What was added

**Admin panel — `/rwadmin`** (requires the `server` privilege)

Switch individual weapons, ammunition and components on and off while the
server is running, without restarting or editing config. A disabled item stops
firing, throwing, reloading, being placed, and being crafted, and its recipe is
hidden from the crafting guide.

Nothing is ever removed from a player's inventory. Disabled items stay where
they are, stay listed in creative and in the crafting guide, and simply do
nothing until re-enabled — at which point they work again immediately. Players
get a chat message explaining why something did not work, rather than silent
failure.

The panel warns before you disable something other items depend on: it knows
which components feed which recipes, and which guns are chambered for which
ammunition.

**Player guide — `/rwinfo`** (open to every player, no privilege)

A scrollable in-game help screen covering controls, firing, reloading,
unloading, ammunition, skills and safe zones. Worth having, because none of
this mod's controls are discoverable by guessing.

**Unloading a gun — sneak + right-click**

Returns every round to your inventory. Upstream had no way to empty a gun at
all; rounds only left by being fired.

## What was fixed

Upstream bugs, in brief:

- **Multiplayer HUD handling.** HUD element ids were stored in global
  variables, so every player shared the last-joined player's ids. Hit markers
  and the scope overlay were applied to the wrong player whenever more than one
  person was online.
- **Two crashes in upstream's code**: one when cycling the action on a gun with
  no ammunition recorded in its metadata, and one when a player disconnected
  while their bullet was still in flight.
- **Ammunition loss.** Unloading a gun while your inventory was full silently
  destroyed the rounds instead of dropping them.
- **Two settings that did nothing**, because the names read in code never
  matched the names declared in `settingtypes.txt`.
- **Per-tick overhead** in the weapon globalstep, which repeated the same
  lookup thirteen times per player per server step.
- Deprecated engine calls, a latent divide-by-zero, and eleven variables
  leaking into the global namespace.
- Six sound files that shipped as stereo but were played positionally, which
  the engine cannot do — they are now mono, so 3D audio works and the console
  warnings stop.

## Settings

Two new options in `settingtypes.txt`, both optional:

- `rangedweapons_admin_strict` (default on) — whether a disabled item is inert
  everywhere immediately, or only stops being produced while existing stock
  keeps working.
- `rangedweapons_ammo_stack_max` (default 0) — force every ammunition type to
  one stack size. `0` keeps upstream's per-ammo values.

## Layout

The admin panel lives in `admin/`, loaded by a single line appended to the end
of `init.lua`:

```lua
dofile(modpath .. "/admin/init.lua")
```

Delete `admin/` and that one line and the mod behaves as upstream does, with
the bug fixes above still in place.

## Requirements

Luanti 5.8 or later. Requires `default` and `tnt`; optionally uses `doors`,
`xpanes`, `vessels`, `moreores` and `3d_armor` when present.
