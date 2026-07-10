# welcome_board

**A polished, fully configurable welcome dialog mod for Luanti (formerly Minetest).**

Shows a private popup window to players when they join your world or server. The dialog features multiple tabs (Welcome, Announcements, Player Guide, Server Rules), personalised greetings for new vs. returning players, a `/welcome` command to reopen it at any time, and extensive customisation via `minetest.conf`.

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
- [In-Game Editing (Authors)](#in-game-editing-authors)
- [Pagination](#pagination)
- [Colour Reference](#colour-reference)
- [Integration with Other Mods](#integration-with-other-mods)
- [File Structure](#file-structure)
- [License](#license)

---

## Features

- **Private popup dialog** — only the joining player sees it; no broadcast to others.
- **Four content tabs** — Welcome, Announcements, Player Guide, and Server Rules (each independently toggleable).
- **Personalised greeting** — different greeting text for first-time visitors vs. returning players.
- **First-join / every-join / never** modes — full control over when the popup appears.
- **Configurable delay** — small delay before showing the popup so the world finishes loading first.
- **`/welcome` command** — players can reopen the dialog at any time; supports `/welcome announcements`, `/welcome guide`, and `/welcome rules` to jump to a specific tab.
- **`/welcome_reset` admin command** — reset a player's first-join flag so they see the dialog again.
- **Chat notification** — optional coloured chat message sent to the joining player.
- **Fully themed appearance** — background colour, title colour, body colour, accent bars, and close button label all configurable.
- **Content editable two ways** — set defaults via `minetest.conf`/`config.lua`, or edit live in-game (requires the `welcome_board_author` or `server` privilege).
- **In-game header editing** — authors can edit the title, subtitle, and greetings via an Edit Header dialog.
- **Automatic pagination** — long content is split into fast-rendering pages, preventing lag.
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

Out of the box, the mod works with no configuration at all. Players will see a welcome popup on their **first join only**, with four tabs containing sensible default content.

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
- A **page-control row** with previous/next arrows and a page indicator (shown
  only when content spans multiple pages).
- A **content area** that displays the current page of text.
- A **close button** at the bottom.

The **Help** button (top-right) is visible to every player and opens an in-game
guide. For authors — players with the `welcome_board_author` **or** `server`
privilege — the header area also shows an **Edit Header** button, and the
page-control row shows an **Edit** button.

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
| `welcome_board_show_announcements` | `true` | Set to `false` to hide the Announcements tab entirely. |
| `welcome_board_announcements_tab_label` | `Announcements` | The label shown on the Announcements tab button. |
| `welcome_board_announcements_body` | *(see below)* | Content of the Announcements tab. Use `\n` for line breaks. Edit in-game as news changes. |
| `welcome_board_show_tips` | `true` | Set to `false` to hide the Player Guide tab entirely. |
| `welcome_board_tips_tab_label` | `Player Guide` | The label shown on the Player Guide tab button. |
| `welcome_board_tips_body` | *(see below)* | Content of the Player Guide tab. Use `\n` for line breaks. |

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

## In-Game Editing (Authors)

Welcome Board content can be edited live in-game by players who hold the
`welcome_board_author` **or** `server` privilege — no file editing or server
restart required.

### Granting author access

Editing is allowed for any player who holds **either** of these privileges:

- **`server`** — server owners and admins can edit out of the box, no extra
  setup required.
- **`welcome_board_author`** — a dedicated privilege for delegating *just* content
  editing to a trusted player, without granting them full server control.

The `welcome_board_author` privilege is **never granted automatically** — not to
singleplayer, and not even to admins with `give_to_admin`. Grant it explicitly:

```
/grant <playername> welcome_board_author
```

This is a deliberate safety boundary: you can let a community manager or builder
edit the welcome text and rules without handing them `server` (which also allows
changing settings, shutting down the server, and more). Revoke it any time with
`/revoke <playername> welcome_board_author`.

Players without either privilege can still read every tab and open the **Help**
button — they simply won't see the Edit buttons.

### How editing works

1. Open the board with `/welcome`.
2. Authors see three controls: an **Edit** button in the page-control row of each
   tab (edits that tab's body), an **Edit Header** button top-right (edits the
   title, subtitle, and greetings), and a **Help** button (opens an in-game
   author guide covering editing, reverting, and pages).
3. Click **Edit** to turn the read-only display into an editable text box showing
   the full content of that tab.
4. Make changes, then click **Save** (or **X** to cancel).
5. Edits are stored in the world's mod storage and persist across restarts.

The editable box shows the text exactly as it will appear. What you type is what
players see — there are no special codes to learn.

### Content storage model

Content resolves in this order:

1. An **override** saved by an in-game author (in mod storage), if present.
2. Otherwise, the **default** from `config.lua` / `minetest.conf`.

This means your configured defaults always remain intact underneath. To discard
an in-game edit and return a field to its configured default, use:

```
/welcome_revert <field>
```

Valid fields: `title`, `subtitle`, `welcome_heading`, `welcome_body`,
`announcements_body`, `tips_body`, `rules_body`, `new_player_greeting`, `return_greeting`, or `all` to
revert everything. Requires the `welcome_board_author` privilege.

## Pagination

To keep rendering fast and prevent any lag from very long content, the dialog
automatically splits body text into pages. Each page holds up to
`welcome_board_chars_per_page` characters (default **3000**), breaking only at
line boundaries so text is never cut mid-line.

Navigation arrows (`<` and `>`) and a "Page X / N" indicator appear at the top of
the content area whenever content spans more than one page.

### Over-limit editing

When an author saves content longer than one page, the mod does **not** silently
reflow it. Instead it shows a confirmation dialog:

> This content is 3,140 characters, over the 3000-character limit. It will be
> automatically split into 2 pages when saved. Save and split, or keep editing?

Choose **Save & Split** to accept the automatic pagination, or **Keep Editing**
to return to the editor and trim the content yourself. A live character counter
below the edit box shows your current length (e.g. `3140 / 3000`) and turns red
when you are over the limit.

## Chat Commands

### /welcome

```
/welcome
/welcome announcements
/welcome guide
/welcome rules
```

Opens the welcome dialog. Any player can use this command at any time.

- `/welcome` — opens the dialog on the Welcome tab.
- `/welcome announcements` — opens the dialog directly on the Announcements tab (if enabled).
- `/welcome guide` — opens the dialog directly on the Player Guide tab (if enabled).
- `/welcome rules` — opens the dialog directly on the Server Rules tab (if enabled).

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

### /welcome_revert

```
/welcome_revert <field>
```

Reverts a single Welcome Board field (or `all`) to its configured default,
discarding any in-game author edit. Requires the `welcome_board_author` or
`server` privilege. Valid fields: `title`, `subtitle`, `welcome_heading`, `welcome_body`,
`announcements_body`, `tips_body`, `rules_body`, `new_player_greeting`, `return_greeting`, `all`.

---

## Enabling / Disabling Individual Tabs

Each tab beyond the first "Welcome" tab can be independently enabled or disabled:

```ini
# Disable the Player Guide tab
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

There are **two ways** to change the board's content, and they work together as
layers:

1. **Defaults** — set via `minetest.conf` or `config.lua` (described in this
   section). These define what everyone sees out of the box and what
   `/welcome_revert` falls back to. This is the right method for server owners
   setting up their content, and for pre-configured game distributions.
2. **In-game overrides** — edited live by players with the `welcome_board_author`
   or `server` privilege (see [In-Game Editing](#in-game-editing-authors)). These
   sit *on top of* the defaults for quick tweaks without file access.

Content resolves as: **in-game override → configured default**. If no author has
edited a field in-game, the configured default below is what shows. Neither
method is obsolete — the config method is the foundation, and in-game editing is
a convenience layer above it. Use `minetest.conf`/`config.lua` to establish your
baseline; use in-game editing for live adjustments.

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
├── init.lua            # Main entry point: callbacks, commands, editing, pagination
├── config.lua          # Settings loader — all default content values live here
├── formspec.lua        # Formspec builder — dialog UI, edit mode, page controls
├── storage.lua         # Content persistence — config defaults vs author overrides
├── pagination.lua      # Splits long content into fixed-length pages
├── settingtypes.txt    # Declares all settings for the Luanti settings GUI
├── mod.conf            # Mod metadata (name, description, min version)
├── textures/
│   └── welcome_board_bg.png   # 9-sliced semi-transparent panel background
└── README.md           # This file
```

| File | Purpose |
|---|---|
| `init.lua` | Registers `on_joinplayer`, `on_player_receive_fields`, chat commands, and the `welcome_board_author` privilege. Routes the main, header, help, and confirmation dialogs, and handles in-game editing. |
| `config.lua` | Loads every configurable value from `minetest.conf` with fallback defaults. |
| `formspec.lua` | Builds all dialogs: main board (view/edit), header editor, author Help, and the split-confirmation. Handles tab layout, pagination controls, and text display. |
| `storage.lua` | Content persistence layer — resolves each field as an author override (mod storage) on top of the config default. |
| `pagination.lua` | Splits long content into fixed-length pages at line boundaries. |
| `settingtypes.txt` | Declares settings to Luanti's settings GUI. Does not affect runtime behaviour — it's purely for the GUI description. |
| `mod.conf` | Standard Luanti mod metadata file. |
| `textures/welcome_board_bg.png` | The 9-sliced, semi-transparent panel background. |

---

## License

MIT License. See LICENSE file (or the top of each source file) for details.

You are free to use, modify, and redistribute this mod in your game or server. Attribution is appreciated but not required.

---

*Made for Adventurelands by TechnoWolfTV. Contributions welcome.*
