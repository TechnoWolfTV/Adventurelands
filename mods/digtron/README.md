# Modular Tunnel Boring Machine
## aka The Almighty Digtron

![screenshot](screenshot.png)

**More examples: [Digtron Luanti Forum Topic](https://forum.luanti.org/viewtopic.php?t=16295)**

This mod contains a set of blocks that can be used to construct highly customizable and
modular tunnel-boring machines, bridge-builders, road-pavers, wall-o-matics, and other
such construction/destruction contraptions.

## Basic functionality

A digging machine's components must be connected to the control block via a path leading
through the faces of the blocks - diagonal connections across edges and corners don't count.

#### Crucial Digtron blocks

* **Digger heads** excavate material in front of them when the machine is triggered.
    * The mined blocks are shunt into the inventory module. Excess is dropped to ground.
* **Builder heads** build a user-configured node in the direction they're facing.
    * Useful for situations where a tunnel-borer intersects a cavern.
* **Inventory modules** hold material produced by the digger and provide material to the builders.
* **Fuel modules** hold flammable materials to feed the beast.
* **Control blocks** trigger the machine and move it in a particular direction.
    * The auto-controller triggers automatically for a custom number of cycles.

Builder heads can be set to construct their target block "intermittently", allowing
for regularly-spaced structures to be constructed. Common uses include building support
arches at regular intervals in a tunnel, adding a torch on the wall at regular
intervals, laying rails with regularly-spaced powered rails interspersed, and adding
stairs to vertical shafts.

A player can ride their Digtron as it goes.

#### Other specialized Digtron blocks

* **"Axle" block**: allows an assembled Digtron to be rotated into new orientations without needing to be rebuilt block-by-block
* **Crate**: stores an assembled Digtron and allows the player to transport it to a new location
* **Duplicator**: creates a copy of an existing Digtron (if provided with enough spare parts)
* **Item ejector**: moves excavated materials from a Digtron's inventory into pipeworks tubes.
* **Light**: can be mounted on a Digtron to illuminate the workspace as it moves
* Structural components to make it look cool

## License

* Code: MIT
* Textures: CC-BY-SA 3.0
* Sounds: CC BY 3.0 / CC 1.0 ([sounds/license.txt](sounds/license.txt))

See also: [LICENSE.txt](LICENSE.txt).

## Dependencies

#### Mandatory

* Luanti/Minetest >= 5.5.0
* `default` mod (from Minetest Game or compatible games)
* [fakelib](https://content.luanti.org/packages/OgelGames/fakelib/)

#### Optional

* [doc](https://forum.luanti.org/viewtopic.php?t=15912), an in-game documentation mod.
  Detailed documentation for all of the Digtron's individual blocks are included as
  well as pages of general concepts and design tips.
   * Note: The mods `doc` and `doc_items` should be enabled for the best experience.
* [pipeworks](https://forum.luanti.org/viewtopic.php?t=2155) for item transport automation.
* [hopper](https://github.com/minetest-mods/hopper) for item transport automation.
* [awards](https://forum.luanti.org/viewtopic.php?t=4870) to add over 30 Digtron-specific achievements (progression) to the game.
* [technic](https://forum.luanti.org/viewtopic.php?t=2538) to power Digtron with electricity (including batteries!).
* [TechAge](https://forum.luanti.org/viewtopic.php?t=24619), a mod that adds technology stages where the player advances from the water mill and steam engine into future technology. It includes a rechargeable Digtron Battery.

---

## Adventurelands patch notes (downstream modification)

> This copy of Digtron is redistributed in the **Adventurelands** game with a local
> bug-fix applied. The code remains under its original MIT license (see
> [LICENSE.txt](LICENSE.txt), unchanged); this section only documents what was modified,
> as required for redistribution and to keep the divergence from upstream transparent.

**Modified by:** TechnoWolfTV (Adventurelands), 2026
**Based on:** upstream `minetest-mods/digtron` `master`
**Upstream issue:** [minetest-mods/digtron#129](https://github.com/minetest-mods/digtron/issues/129)

### What was fixed

An auto-controller left running unattended (with the player far away) while drilling into
terrain that a mapgen mod — e.g. `dungeonsplus` — is still generating could have its own and
its modules' metadata wiped mid-move: storage/battery boxes would no longer open and the
control module's fields would go blank. Cause: mapgen is allowed to rewrite the outermost
shell of mapblocks bordering the chunk it generates ("overgeneration"), so blocks the machine
occupied could be partially rewritten mid-move, desyncing node vs metadata. (Mechanism
identified by SmallJoker in the upstream issue.)

### What changed

* **`class_layout.lua`** — added `mapgen_safe_to_move(dir)`: before moving, the machine checks
  for ungenerated (`ignore`) map out to one full mapblock (+16 nodes) in the movement
  direction and refuses to advance while mapgen may still manipulate that region. Ungenerated
  blocks are emerged (respecting the existing `digtron_emerge_unloaded_mapblocks` setting), so
  an unattended machine waits briefly and proceeds once generation completes.
* **`util_execute_cycle.lua`** — calls the check from `neighbour_test`; when unsafe, the cycle
  retries with the status "Digtron is waiting for map generation ahead...".
* **`config.lua`** — adds the setting `digtron_wait_for_mapgen` (default `true`; set `false`
  in `minetest.conf` to disable).
* **`nodes/node_controllers.lua`** — hardening for a separate path: a monotonic run-token so
  stale/duplicate `minetest.after` cycle callbacks can't run twice against one machine, and a
  missing `on_timer` on the auto-controller so it clears its own `waiting` flag after an
  obstruction.

### New setting

* `digtron_wait_for_mapgen` (bool, default `true`) — before moving, require the map within one
  mapblock (16 nodes) in the movement direction to be generated, so mapgen overgeneration
  cannot corrupt the machine.

These changes are offered upstream in the issue linked above; this local copy exists so
Adventurelands players are covered until an official fix lands.
