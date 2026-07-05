# Minislots Game Engine

Maintained by TechnoWolfTV (2026-07-03)  
Original engine by Vanessa "VanessaE" Dannenberg

This package provides a simple "engine" to drive slimmed-down slot machines.
It takes-in money (and pays out, in "currency" mod Minegeld), spins reels,
awards wins, and so forth.

It features wild cards, variable matching, multiple pay lines, and scatter
wins and bonus rounds.

Machines are fully themeable, from the biggest parts of the UI graphics to the
smallest details of the labels and numerals.  Most of the important UI
elements' sizes and positions can be controlled.

Two example machines are included (described below).

This is a maintained fork. For a full, file-by-file list of the changes made
in this fork (bug fixes, odds rebalancing, crafting recipes, sounds, and
more), see CHANGELOG.md. Licensing and attribution are in the LICENSE file.

Note: The bonus round calls a function (`initiate_bonus`) provided in the machine
definition, which now receives the current line bet and the allwins table as arguments,
allowing fully proportional payouts.  The two example machines both implement meaningful
bonus payouts that scale with the player's wager.  Custom machines can implement any
bonus logic they like inside this function.

## Depends

- Luanti 5.2.0 or later (Minetest Game branch)
- [Minetest Game](https://github.com/luanti-org/minetest_game)
- [currency](https://github.com/mt-mods/currency)

> **Note on RTP rebalancing:** The example machines (Golden 7s and Golden 7s Deluxe)
> have been rebalanced to realistic house-edge RTP values (~90% and ~89% respectively),
> measured empirically by simulating the real engine over millions of spins. Golden 7s
> hits on ~12.5% of spins (medium volatility); the Deluxe hits ~31% (lower volatility,
> more paylines). The original shipped configuration paid out well over 100% RTP,
> meaning the house lost money on every spin. See the LICENSE file for a full
> breakdown of what was changed and why.

## Source Artwork

To keep the download small, this release omits the `minislots_work_files/`
directory (~14 MB of GIMP `.xcf` source files used to create the textures).
It is not a mod and is never loaded by the game. If you want to edit the
original artwork, the work files are available in the upstream repository:
https://github.com/mt-mods/minislots

## Sound Effects

Both machines include sound effects: a continuous spinning-reel loop, a
bell as each reel stops, coin insert, and distinct sounds for small wins,
large wins, and jackpots. Each player can mute or unmute the machine sounds
using the "Sound On/Off" button on the machine's main screen (next to the
Help / Pays button). Clicking it toggles that player's machine audio and
confirms the new state in chat. The setting is saved per-player and persists
across all machines and server sessions.

Muting affects only this modpack's machine sounds, for that player only. It
never changes the player's Luanti client volume or any other mod's audio.

All sound assets are CC0 (public domain). The "Sound On/Off" button image was
created for this fork by TechnoWolfTV. See the LICENSE file for full credits.

## Playing

Insert money via the cash slot, choose your number of lines and your bet
per line, then press SPIN. Selecting a bet amount only sets the bet -- it
does not start a spin -- so you can adjust lines and bet freely before
spinning. Wins are paid to the machine balance; use CASH OUT to collect.

## Crafting Recipes

Both machines use shaped 3×3 recipes and display correctly in Unified Inventory.
The Minegeld note is the seed float — money built into the machine on assembly.

**Golden 7's**

| | Left | Centre | Right |
|---|---|---|---|
| **Top** | `default:goldblock` | `default:mese` | `default:goldblock` |
| **Mid** | `default:goldblock` | `default:obsidian_glass` | `default:goldblock` |
| **Bot** | `default:diamond` | `currency:minegeld_50` | `default:acacia_wood` |

Cost breakdown: 4× gold block, 1× mese block, 1× obsidian glass, 1× diamond,
1× 50 Mg note, 1× acacia wood plank.

**Golden 7's Deluxe**

| | Left | Centre | Right |
|---|---|---|---|
| **Top** | `default:goldblock` | `default:mese` | `default:goldblock` |
| **Mid** | `default:goldblock` | `default:obsidian_glass` | `default:goldblock` |
| **Bot** | `default:diamondblock` | `currency:minegeld_100` | `default:acacia_wood` |

Cost breakdown: 4× gold block, 1× mese block, 1× obsidian glass, 1× diamond block,
1× 100 Mg note, 1× acacia wood plank.

The Deluxe is a serious end-game investment, requiring a full diamond block and
obsidian glass among its materials. Both machines can
be picked up and re-placed without losing their balance, statistics, or casino name.

## Server Administration Commands

Three chat commands are available to server operators (requires `server` privilege):

| Command | Effect |
|---|---|
| `/disable_minislots` | Takes all machines offline for maintenance. Players currently at a machine are automatically cashed out and ejected within one second (in-flight spins are allowed to finish first). |
| `/enable_minislots` | Brings all machines back online. |
| `/minislots_status` | Reports whether machines are currently enabled or disabled. |

The enabled/disabled state persists across server restarts via mod storage.

When a machine is disabled, players who right-click it receive the message:
> *This machine is currently down for maintenance.*

Server-privilege players can still open machines while disabled (for inspection or configuration).

## DISCLAIMER

---

THIS IS A SLOT MACHINE "MINI GAME" PROJECT FOR THE LUANTI/MINETEST OPEN SOURCE GAME
ENGINE/PLATFORM.  IT IS NOT IN ANY WAY, SHAPE, OR FORM ASSOCIATED WITH,
REGULATED BY, OR OTHERWISE UNDER THE CONTROL OR INFLUENCE OF ANY LOCAL,
COUNTY, STATE, OR FEDERAL GAMING AGENCY, COMMISSION, OR OFFICE.

THE "CURRENCY" USED BY THIS PROJECT IS ENTIRELY FICTIONAL, EXISTING ONLY
WITHIN THE ONLINE WORLD FOR WHICH IT WAS CREATED, AND NO PART OF THIS PROJECT
SEEKS TO MAKE IT CONVERTIBLE, EXCHANGEABLE, OR OTHERWISE NEGOTIABLE FROM OR
INTO ANY LEGAL TENDER CURRENCY OR OTHER VALUABLE ASSETS OF ANY KIND OR ORIGIN,
WHETHER TANGIBLE OR INTANGIBLE, PHYSICAL OR ELECTRONIC.

NO CLAIMS REGARDING THE FITNESS OF THIS PROJECT FOR ANY PURPOSE ARE HEREIN
MADE, AND NO WARRANTY OR GUARANTEE OF ANY KIND IS OFFERED BY ANY PARTY.  SEE
ALSO, "LICENSE" IN THE MAIN PROJECT DIRECTORY.

---

### Additional Notes (added by the TechnoWolfTV fork)

The following notes supplement — and do not modify — the disclaimer above.

This modpack is a work of interactive fiction that *simulates* the appearance
of casino slot machines for entertainment within the game world. It is not a
gambling product:

- **No real money is involved.** There is no mechanism in this modpack to
  purchase in-game currency with real-world money, and no mechanism to convert
  in-game winnings into real-world money, goods, or anything of real value.
  The in-game "Minegeld" is provided by a separate fictional-currency mod and
  has no cash value.
- **No real-value prizes.** Nothing won, lost, or wagered in these machines
  has any value outside the game world.
- **Server operators:** you are responsible for how you deploy this modpack.
  Do not connect the in-game currency to anything of real-world value — for
  example by selling in-game currency for real money, allowing players to cash
  out, tying wagers to real-money donations or perks, or bridging the currency
  to cryptocurrency or other tradeable real-value assets. Doing so may cause
  the deployment to be treated as real gambling under the laws of your
  jurisdiction, which vary by country and region. The authors and contributors
  of this modpack accept no responsibility for such use.
- **Content note.** Because this modpack simulates gambling, server operators
  and parents may wish to consider its suitability for younger or vulnerable
  players, and any applicable content-rating or platform requirements.

Nothing in these notes is legal advice. If you are unsure whether deploying
this modpack in a particular way is lawful where you are, consult a qualified
lawyer in your jurisdiction.
