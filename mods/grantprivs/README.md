# Grant Privs
*By TechnoWolfTV*

An admin tool for [Luanti](https://luanti.org) that lets server operators configure which privileges are automatically granted to players — either on join, or after they've accumulated a set amount of playtime. All managed in-game, no config-file editing required.

> **Why not just use `default_privs` in `minetest.conf`?**
> You can! But `default_privs` requires direct file access to the server config, can't do timed/conditional grants, and has no in-game interface. This mod adds all of that.

---

## Commands

All sub-commands require the **`server`** privilege.

### Join privs

| Command | Effect |
|---|---|
| `/grantprivs` or `/grantprivs status` | Show current configuration |
| `/grantprivs set <privs>` | Replace the join-priv list (comma-separated) |
| `/grantprivs add <privs>` | Add one or more privs to the list |
| `/grantprivs remove <privs>` | Remove one or more privs from the list |
| `/grantprivs clear` | Wipe the join-priv list |
| `/grantprivs rejoin <on\|off>` | Toggle whether join privs re-apply on every join (default: off — new players only) |

### Timed rules

| Command | Effect |
|---|---|
| `/grantprivs timed add <minutes> <priv>` | Grant `priv` once a player reaches `minutes` of total playtime |
| `/grantprivs timed remove <minutes> <priv>` | Remove a timed rule |
| `/grantprivs timed list` | List all timed rules |
| `/grantprivs timed clear` | Remove all timed rules |

### Playtime lookup

| Command | Effect |
|---|---|
| `/grantprivs playtime <playername>` | Check a player's total recorded playtime |

---

## Examples

```
-- Grant 'home' to every new player
/grantprivs set home

-- After 30 minutes of playtime, grant 'fast'
/grantprivs timed add 30 fast

-- After 2 hours (120 min), grant 'fly'
/grantprivs timed add 120 fly

-- Check how long a player has been active
/grantprivs playtime Steve

-- See the full current config
/grantprivs status
```

---

## Behaviour

- **New players** always receive join privs (if configured).
- **Returning players** only receive join privs if `rejoin on` is set — useful for rolling out a new priv to your whole existing playerbase.
- **Timed rules** are checked every 30 seconds while the player is online, and once immediately on join (to catch any threshold crossed while they were offline).
- **Playtime** is tracked cumulatively across sessions and saved when a player leaves. It survives server restarts.
- Players are notified in chat when they receive a timed priv grant.
- All priv names are validated against registered privileges — typos are rejected immediately.
- Everything is logged to the server log with player name and reason.

---

## Installation

1. Copy the `grantprivs` folder into your world's `mods/` directory (or your game's `mods/` folder).
2. Enable it in your world settings.
3. In-game, use `/grantprivs set <privs>` and `/grantprivs timed add <minutes> <priv>` to configure it.

No `minetest.conf` changes needed.

---

## License

MIT — see `LICENSE.txt`.
