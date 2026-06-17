# adventurelands_bridges

A lightweight bridge mod for the [Adventurelands](https://content.luanti.org/packages/TechnoWolfTV/adventurelands/) game for Luanti. Connects third-party mods that don't natively interact, without modifying any upstream mod.

## Current Bridges

- **home_workshop_misc beer mug → stamina drunk effect** — adds the `alcohol` group to `home_workshop_misc:beer_mug` so that consuming 4 or more beer mugs triggers [stamina](https://content.luanti.org/packages/TenPlus1/stamina/)'s 60-second drunk effect, consistent with the behavior of the [wine](https://content.luanti.org/packages/TenPlus1/wine/) mod.

---

## Installation

1. Copy the `adventurelands_bridges/` folder into your Luanti `mods/` directory.
2. Enable the mod in your world settings.

---

## Compatibility

- **Luanti** 5.9+
- **Depends:** `home_workshop_misc`, `stamina`

---

## Design Philosophy

This mod makes no changes to any upstream mod. All bridges are implemented using `minetest.override_item()` and `minetest.after()` so they are safe to add or remove without affecting world data. If a bridged mod is missing, the bridge logs a warning and skips gracefully.

---

## License

MIT License
