# welcome_board

**A polished, fully configurable welcome dialog mod for Luanti (formerly Minetest).**

Shows a private popup window to players when they join your world or server. The dialog features multiple tabs (Welcome, Tips & Guide, Server Rules), personalised greetings for new vs. returning players, a `/welcome` command to reopen it at any time, and extensive customisation via `minetest.conf`.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
  - [The Popup Dialog](#the-popup-dialog)
  - [First Join vs. Every Join](#first-join-vs-every-join)
  - [New Player vs. Returning Player Greeting](#new-player-vs-returning-player-greeting)
  - [Chat Notification](#chat-notification)
  - [Player Data Persistence](#player-data-persistence)
- [All Configuration Settings](#all-configuration-settings)
  - [Behaviour Settings](#behaviour-settings)
  - [Content — General](#content--general)
  - [Content — Welcome Tab](#content--welcome-tab)
  - [Content — Tips Tab](#content--tips-tab)
  - [Content — Rules Tab](#content--rules-tab)
  - [Appearance Settings](#appearance-settings)
  - [Chat Notification Settings](#chat-notification-settings)
- [Chat Commands](#chat-commands)
  - [/welcome](#welcome)
  - [/welcome_reset](#welcome_reset)
- [Enabling / Disabling Individual Tabs](#enabling--disabling-individual-tabs)
- [Customising Content](#customising-content)
  - [Line Breaks in minetest.conf](#line-breaks-in-minetestconf)
  - [Editing config.lua directly](#editing-configlua-directly)
- [Colour Reference](#colour-reference)
- [Integration with Other Mods](#integration-with-other-mods)
- [File Structure](#file-structure)
- [License](#license)

---

## Features

- **Private popup dialog** — only the joining player sees it; no broadcast to others.
- **Three content tabs** — Welcome, Tips & Guide, and Server Rules (each independently toggleable).
- **Personalised greeting** — different greeting text for first-time visitors vs. returning players.
- **First-join / every-join / never** modes — full control over when the popup appears.
- **Configurable delay** — small delay before showing the popup so the world finishes loading first.
- **`/welcome` command** — players can reopen the dialog at any time; supports `/welcome tips` and `/welcome rules` to jump to a specific tab.
- **`/welcome_reset` admin command** — reset a player's first-join flag so they see the dialog again.
- **Chat notification** — optional coloured chat message sent to the joining player.
- **Fully themed appearance** — background colour, title colour, body colour, accent bars, and close button label all configurable.
- **All content editable via `minetest.conf`** — no Lua knowledge required to customise text.
- **Ships with complete default content** — ready to use out of the box with appropriate tips, rules, and welcome text. Just change the server name and you're done.

---

## Installation

1. Download or clone this repository.
2. Place the `welcome_board` folder inside your game's `mods/` directory:
   ```
   <your_game>/mods/welcome_board/
   ```
3. No dependencies are required beyond Luanti 5.4+.
4. The mod is automatically active for any world running your game. No `world.mt` changes needed when the mod is inside a game's `mods/` folder.

> **Tip:** If you are installing this as a standalone mod (outside a game), enable it for your world via the Mods tab in the Luanti main menu, or add `load_mod_welcome_board = true` to your world's `world.mt` file.

---

## Quick Start

Out of the box, the mod works with no configuration at all. Players will see a welcome popup on their **first join only**, with three tabs containing default Adventurelands-themed content.

To personalise it for your server, add any of the following to your `minetest.conf`:

```ini
# Your server's name (used in greetings and chat notifications)
welcome_board_server_name = My Awesome Server

# Change the dialog title
welcome_board_title = Welcome to My Awesome Server!

# Change the subtitle
welcome_board_subtitle = Building, Survival & Adventure

# Show the popup every time players join (not just first join)
welcome_board_show_on = every_join
```

---

## How It Works

### The Popup Dialog

When a player joins, the mod waits for a configurable delay (default: 0.8 seconds) before showing the dialog. This delay ensures the player's client has finished loading the world before the formspec appears — without the delay, the popup can appear over a black screen on slower hardware.

The dialog is built using Luanti's **formspec** system. It is sent directly to the joining player using `minetest.show_formspec(player_name, ...)`, which means it is entirely private — no other player on the server sees it.

The dialog has:
- A **header area** with your title, subtitle, and a personalised greeting.
- A **tab bar** for navigating between content sections.
- A **scrollable text area** that displays the content for the active tab.
- A **close button** at the bottom.

Clicking the close button (or pressing Escape) dismisses the dialog. The player can reopen it at any time using `/welcome`.

### First Join vs. Every Join

The `welcome_board_show_on` setting controls when the popup appears:

| Value | Behaviour |
|---|---|
| `first_join` | Shown only the very first time a player joins. Never shown again after that. *(default)* |
| `every_join` | Shown every single time a player joins or rejoins the server. |
| `never` | The auto-popup is disabled entirely. Players can still open the dialog manually with `/welcome`. |

### New Player vs. Returning Player Greeting

When `welcome_board_vary_return` is `true` (the default), the greeting line inside the dialog is personalised:

- **First-time visitor:** uses `welcome_board_new_player_greeting` (e.g. `"Welcome to Adventurelands,"`)
- **Returning player:** uses `welcome_board_return_greeting` (e.g. `"Welcome back,"`)

Both are followed by the player's name automatically. So a returning player named `Steve` would see:

> *Welcome back, Steve!*

Set `welcome_board_vary_return = false` to always use the same greeting regardless of visit history.

### Chat Notification

Separately from the popup, the mod can send a brief coloured message to the joining player in chat. This is useful as a lightweight reminder even on `never` mode (where the popup is disabled).

The chat message is formatted using a template string:

```ini
welcome_board_chat_text = {greeting} {player}! Type /welcome to view the welcome guide at any time.
```

The following placeholders are replaced automatically:

| Placeholder | Replaced with |
|---|---|
| `{player}` | The joining player's name |
| `{greeting}` | The appropriate greeting (new or returning, based on `vary_return`) |
| `{server}` | The value of `welcome_board_server_name` |

Disable the chat notification with `welcome_board_chat_notify = false`.

### Player Data Persistence

The mod uses **player metadata** (via `player:get_meta()`) to track whether a player has joined before. This data is stored in the player's save file and persists across server restarts. It is not stored in mod storage — it is tied to the player object, so it moves with the player's account.

The metadata key used is `welcome_board_joined` (integer, 0 = never joined before, 1 = has joined). This key is namespaced to avoid conflicts with other mods.

---

## All Configuration Settings

All settings can be placed in `minetest.conf` (in your Luanti user data directory, or in the world folder as `world.mt`). They are also visible in the Luanti settings GUI under **Mods → welcome_board**.

### Behaviour Settings

| Setting | Default | Description |
|---|---|---|
| `welcome_board_show_on` | `first_join` | When to auto-show the popup: `first_join`, `every_join`, or `never`. |
| `welcome_board_delay` | `0.8` | Seconds to wait after join before showing the popup. Range: 0.0–5.0. |

### Content — General

| Setting | Default | Description |
|---|---|---|
| `welcome_board_title` | `Welcome to Adventurelands!` | The large title at the top of the dialog. |
| `welcome_board_subtitle` | `An Open World of Exploration, Survival & Adventure` | Smaller subtitle below the title. |
| `welcome_board_server_name` | `Adventurelands` | Your server/game name. Used in `{server}` placeholder and default greeting. |

### Content — Welcome Tab

| Setting | Default | Description |
|---|---|---|
| `welcome_board_welcome_heading` | `A New Adventure Awaits` | Bold heading at the top of the Welcome tab body. |
| `welcome_board_welcome_body` | *(see below)* | Main body text of the Welcome tab. Use `\n` for line breaks. |

### Content — Tips Tab

| Setting | Default | Description |
|---|---|---|
| `welcome_board_show_tips` | `true` | Set to `false` to hide the Tips tab entirely. |
| `welcome_board_tips_tab_label` | `Tips & Guide` | The label shown on the Tips tab button. |
| `welcome_board_tips_body` | *(see below)* | Content of the Tips tab. Use `\n` for line breaks. |

### Content — Rules Tab

| Setting | Default | Description |
|---|---|---|
| `welcome_board_show_rules` | `true` | Set to `false` to hide the Rules tab entirely. |
| `welcome_board_rules_tab_label` | `Server Rules` | The label shown on the Rules tab button. |
| `welcome_board_rules_body` | *(see below)* | Content of the Rules tab. Use `\n` for line breaks. |

### Appearance Settings

| Setting | Default | Description |
|---|---|---|
| `welcome_board_bg_color` | `#1a1a2eCC` | Dialog background colour (RGBA hex). The last two hex digits are opacity (CC = ~80%). |
| `welcome_board_title_color` | `#f0c040` | Colour of the title text and accent bars (golden yellow by default). |
| `welcome_board_subtitle_color` | `#aaddff` | Colour of the subtitle text (light blue). |
| `welcome_board_greeting_color` | `#88ff88` | Colour of the personalised greeting line (light green). |
| `welcome_board_body_color` | `#dddddd` | Colour of the body text in tabs (light grey). |
| `welcome_board_tab_color` | `#2a2a4a` | Background colour of the tab panel. |
| `welcome_board_close_label` | `Let's Play!` | Label on the close button. |
| `welcome_board_width` | `14.0` | Width of the dialog in formspec units. Range: 8.0–20.0. |
| `welcome_board_height` | `9.5` | Height of the dialog in formspec units. Range: 6.0–16.0. |

### Chat Notification Settings

| Setting | Default | Description |
|---|---|---|
| `welcome_board_chat_notify` | `true` | Whether to send a chat message to the joining player. |
| `welcome_board_chat_text` | *(see above)* | Template for the chat message. Supports `{player}`, `{greeting}`, `{server}`. |
| `welcome_board_vary_return` | `true` | Use different greetings for new vs. returning players. |
| `welcome_board_new_player_greeting` | `Welcome to Adventurelands,` | Greeting text for first-time visitors. |
| `welcome_board_return_greeting` | `Welcome back,` | Greeting text for returning players. |

---

## Chat Commands

### /welcome

```
/welcome
/welcome tips
/welcome rules
```

Opens the welcome dialog. Any player can use this command at any time.

- `/welcome` — opens the dialog on the Welcome tab.
- `/welcome tips` — opens the dialog directly on the Tips tab (if enabled).
- `/welcome rules` — opens the dialog directly on the Rules tab (if enabled).

No special privileges are required.

### /welcome_reset

```
/welcome_reset <playername>
```

Resets the first-join flag for the named player, so they will see the first-join popup the next time they join (or see the "new player" greeting in the dialog). Requires the `server` privilege.

The target player must be **online** when you run this command, as player metadata can only be written to online players. Example:

```
/welcome_reset Steve
```

---

## Enabling / Disabling Individual Tabs

Each tab beyond the first "Welcome" tab can be independently enabled or disabled:

```ini
# Disable the Tips tab (only Welcome and Rules will appear)
welcome_board_show_tips = false

# Disable the Rules tab (only Welcome and Tips will appear)
welcome_board_show_rules = false

# Disable both extra tabs (only the Welcome tab will appear — no tab bar shown)
welcome_board_show_tips = false
welcome_board_show_rules = false
```

When only one tab is present, the tab header bar is still rendered but shows only one tab. This is normal Luanti behaviour.

---

## Customising Content

### Line Breaks in minetest.conf

In `minetest.conf`, use `\n` (a backslash followed by the letter n) wherever you want a line break in your text. The mod automatically converts these into real newlines when building the formspec.

Example:
```ini
welcome_board_welcome_body = Welcome to my server!\n\nEnjoy your stay.\n\nCheck the rules tab before you begin.
```

This will render as:
```
Welcome to my server!

Enjoy your stay.

Check the rules tab before you begin.
```

> **Note:** You cannot use actual newlines in `minetest.conf` values — they must be on a single line using `\n` escape sequences.

### Editing config.lua directly

If you prefer not to use `minetest.conf`, all default content is defined in `config.lua` as Lua strings. You can edit the defaults there directly. This is useful if you are distributing a pre-configured game (like Adventurelands) where you want the defaults to already reflect your game without requiring users to set anything in `minetest.conf`.

For example, in `config.lua`, find:
```lua
cfg.title = get_str("welcome_board_title", "Welcome to Adventurelands!")
```

And change the second argument (the default) to your desired value:
```lua
cfg.title = get_str("welcome_board_title", "Welcome to My Epic Server!")
```

Values set in `minetest.conf` always take priority over the `config.lua` defaults.

---

## Colour Reference

Colours are specified as hex strings. Luanti supports:

- **6-digit hex (RGB):** `#rrggbb` — fully opaque.
- **8-digit hex (RGBA):** `#rrggbbaa` — with alpha transparency. `FF` = fully opaque, `00` = fully transparent, `80` = 50% transparent.

Some useful starting colours:

| Colour | Hex | Use case |
|---|---|---|
| Golden yellow | `#f0c040` | Title, accent bars |
| Light blue | `#aaddff` | Subtitle |
| Light green | `#88ff88` | Greeting |
| Light grey | `#dddddd` | Body text |
| Dark navy (80% opaque) | `#1a1a2eCC` | Dialog background |
| Dark purple | `#2a1a4a` | Dialog background (alternate) |
| Deep forest green | `#0d2b1a` | Dialog background (nature theme) |
| Warm parchment | `#3a2a1a` | Dialog background (fantasy theme) |
| Pure black (75% opaque) | `#000000BF` | Minimal dark theme |

---

## Integration with Other Mods

**welcome_board** has no dependencies and does not call into any other mod's API. It is designed to be self-contained.

However, you can integrate it with other mods by editing `init.lua`:

- **Custom privilege gate (like `newplayer`):** Check a player's privileges inside `register_on_joinplayer` and conditionally call `show_dialog` only if they have (or lack) a specific privilege.
- **Custom spawn mods:** The delay setting (`welcome_board_delay`) can be increased to account for teleport delays from custom spawn mods. Set it slightly higher than your spawn mod's own delay.
- **News/MOTD mods:** If you use a separate MOTD or news mod, consider setting `welcome_board_show_on = first_join` so the welcome dialog only appears once, while the MOTD mod handles repeat visit announcements.

---

## File Structure

```
welcome_board/
├── init.lua            # Main entry point: callbacks, commands, dialog display logic
├── config.lua          # Settings loader — all configurable values live here
├── formspec.lua        # Formspec builder — constructs the dialog UI string
├── settingtypes.txt    # Declares all settings for the Luanti settings GUI
├── mod.conf            # Mod metadata (name, description, min version)
└── README.md           # This file
```

| File | Purpose |
|---|---|
| `init.lua` | Registers `on_joinplayer`, `on_player_receive_fields`, and chat commands. Decides when and how to show the dialog. |
| `config.lua` | Loads every configurable value from `minetest.conf` with fallback defaults. Import this with `dofile` at the top of `init.lua`. |
| `formspec.lua` | Pure function that takes the config and player state and returns a formspec string. Handles tab layout, colours, sizing, and content switching. |
| `settingtypes.txt` | Declares settings to Luanti's settings GUI. Does not affect runtime behaviour — it's purely for the GUI description. |
| `mod.conf` | Standard Luanti mod metadata file. |

---

## License

MIT License. See LICENSE file (or the top of each source file) for details.

You are free to use, modify, and redistribute this mod in your game or server. Attribution is appreciated but not required.

---

*Made for Adventurelands by TechnoWolfTV. Contributions welcome.*
