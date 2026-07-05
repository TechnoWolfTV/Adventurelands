# Changelog — minislots (TechnoWolfTV fork)

Original engine by Vanessa "VanessaE" Dannenberg and the mt-mods team.
Modifications by TechnoWolfTV, 2026. The original LGPL v3 and CC-BY-SA 4.0
licenses are unchanged and apply to all original content; see the LICENSE file.

This file documents the changes made in this fork. It is provided for
transparency and is not part of the license terms.

---

minislots_engine/engine.lua  (pass 1 -- bug fixes)
  - Fixed bet and payline selection buttons being stuck at 1: the
    button value was parsed from the output of core.serialize() using
    fixed character offsets, which broke after Luanti's serializer
    format changed. Values are now read directly from the field keys.
  - Fixed bet-initiated spins never recording a spin timestamp, which
    caused the 60-second watchdog to abort the spin after taking the
    bet.
  - Fixed cash-out clearing the machine balance before confirming the
    player had inventory room, which could destroy the money. Fixed
    the last_cashout statistic recording 0 instead of the amount paid.
  - Fixed closing the form or inserting money mid-spin discarding
    pending winnings or disturbing a running spin.
  - Gated bet/lines/spin/cashout handling behind an at-rest state
    check and removed the unconditional timer stop, preventing a
    forged mid-spin field from re-multiplying a payout or freezing
    the machine.
  - Fixed check_win awarding the last-listed matching combination
    rather than the highest-value one.
  - Guarded the bitmap font routines (str_width_pix, print_string)
    against characters outside the font table, which previously
    crashed on non-ASCII input.
  - Fixed the casino-name save handler: corrected an always-true
    field comparison, stopped formspec escapes from compounding on
    each edit, and stripped unrenderable characters.
  - Added recovery for machines stuck in a win state with a dead
    timer (reset to idle on right-click).
  - Added an on_leaveplayer handler to clear the per-player caches,
    fixing a slow memory leak.
  - Removed the dead Minetest 5.0.x code path (the modpack requires
    5.2.0) and assorted unused/redundant locals and stale comments.

minislots_engine/mod.conf
  - Declared "creative" as an optional dependency, since the engine
    references it during node digging.

minislots_engine/engine.lua  (pass 2 -- maintenance mode & more fixes)
  - Added /disable_minislots, /enable_minislots, and /minislots_status
    server commands (require "server" privilege). State persists via
    mod storage across server restarts. When disabled, the machine's
    stored node-meta formspec is overwritten with a maintenance screen
    so right-clicking opens the maintenance notice rather than the
    playable UI (which is what caused the disable to appear non-
    functional in earlier versions). on_receive_fields also blocks all
    game actions and re-asserts the maintenance screen. The disable
    command actively sweeps all loaded machines; enable restores them.
    Players at machines are automatically cashed out and ejected via a
    globalstep (in-flight spins finish first; overflow currency drops
    at the machine). Admins (server priv) bypass all maintenance gates.
  - Fixed allow_metadata_inventory_put refusing an entire item stack
    when only part of it would overflow maxbalance; now accepts as many
    items as fit.
  - Removed the always-true `if stackmeta then` guard in after_place_node
    (get_meta() never returns nil; dead code).
  - Fixed the machine lockout being cleared when the admin closes the
    admin form; lockout now persists until explicitly unlocked.
  - Fixed win cycling leaving a machine permanently stuck in win_1 state
    when there is exactly one winning line and no scatter/bonus.

minislots_engine/engine.lua  (pass 3 -- correctness fixes)
  - initiate_bonus now receives linebet as a third argument and allwins
    as a fourth argument, so bonus payouts can scale with the player's
    wager and reflect the actual number of bonus symbols that appeared.
  - Fixed wild multiplier formula from linear (value * wildcount * mult)
    to the correct exponential form (value * mult^wildcount), matching
    the README description and real-slot behaviour.
  - Removed dead 'local balance = 0' assignment in after_place_node
    that was immediately overwritten; fixed shadow re-declaration of
    the state variable in on_metadata_inventory_put.

minislots_engine/engine.lua  (pass 4 -- maintenance disable fix)
  - Fixed /disable_minislots having no effect when right-clicking a
    machine: Luanti opens a node's stored formspec metadata before
    on_rightclick runs, so the playable UI appeared regardless of the
    maintenance flag. The disable command now overwrites the stored
    formspec on all loaded machines; on_rightclick overwrites it on any
    machine opened while disabled; on_receive_fields blocks and
    re-asserts the maintenance screen for all actions. The maintenance
    screen's internal marker was moved from a visible label to the
    button element name so it no longer appears on screen.
  - Added a visible chat notice to server-privilege players who open a
    machine while maintenance mode is active, so the admin bypass is
    not mistaken for the disable being broken.

minislots_golden7s/init.lua  -- odds rebalance
minislots_golden7s_deluxe/init.lua  -- odds rebalance

  The original payout tables resulted in >100% RTP (the house lost
  money on every spin). The root causes and final configurations are
  documented below.

  Root causes identified:

  1. "Any mixed 7s" and "any mixed bars" list-match entries, combined
     with nil-reel partial matches for cherry and bell, gave very high
     hit rates. With only 16 reel positions, list matches covering
     3+ symbols plus wild hit on ~25% of reel stops per reel.
  2. wild_multiplier: a value of 2 (tried during rebalancing) added
     ~97% RTP by itself via exponential compounding. Kept at 1 (pure
     substitute, no boost).
  3. The bonus initiate_bonus function returned a flat value (123 /
     400) regardless of line bet, contributing enormous RTP at low
     bet sizes. Both machines now return a linebet-proportional value.
  4. The "half-stop" mechanic (half_stops_weight=25) causes ~12% of
     reel stops to land between symbols (nil), which analytical
     probability models failed to account for. RTP was therefore
     re-calibrated empirically by running the actual spin_reels() and
     check_win() engine functions over millions of simulated spins.
     Empirical measurement is the only reliable method for this engine.

  Golden 7s final configuration (~90% RTP, house edge ~10%):
    Payouts (x line bet): lemon=7, melon=9, cherry=12, bell=19,
      bar=31, 2bar=61, 3bar=94, 7=61, 77=125, 777=217, jackpot=350.
    scatter: min=3, value=3. bonus: 31 * linebet (flat, scales).
    wild_multiplier=1. Hit frequency ~12.5%, medium volatility.
    RTP stable across all line bet values.

  Golden 7s Deluxe final configuration (~89% RTP, house edge ~11%):
    Payouts scaled x1.37 from prior values, preserving the tiered
    2/3/4/5-of-a-kind structure. Jackpot 400x. Mixed bar/7 list
    matches pay 23x and 73x respectively. scatter: min=4, value=4.
    bonus: 7 * bonus_count * linebet (proportional).
    wild_multiplier=1. Hit frequency ~31%, lower volatility.
    RTP stable across all line bet values.

  Paytable accuracy: with wild_multiplier=1, every value shown in the
  in-game paytable is the exact payout. Wild is described as a pure
  substitute. There are no hidden payouts.

minislots_golden7s/init.lua  -- paytable layout fix
minislots_golden7s_deluxe/init.lua  -- paytable layout fix
  - Reduced paytable_lineheight and paytable_textheight on both machines
    so all entries fit cleanly within the background panel without
    overflowing the right or bottom edges.
    Golden 7s: lineheight 0.65->0.52, textheight 0.45->0.38.
    Golden 7s Deluxe: lineheight 0.50->0.43, textheight 0.35->0.30.

minislots_engine/engine.lua  (pass 5 -- sound system)
  - Added sound triggers in cycle_states: a spinning loop starts with the
    spin and loops continuously through the entire spin cycle, stopping
    only once all reels have settled; a reel-stop sound fires once as each
    reel locks in, played over the still-looping spin sound; win sounds
    play on entering win states (small win / large win / jackpot each use
    a different sound). The spin loop is also stopped on any interruption
    (watchdog timeout, maintenance eject) to avoid an orphaned loop.
  - Added a coin-insert sound in allow_metadata_inventory_put.
  - Added a per-player sound mute toggle. Sounds are delivered per-player
    (core.sound_play with to_player) and the mute flag simply suppresses
    this modpack's own sounds for that player; it never alters the Luanti
    client's master volume or any other mod's audio. The mute state is
    persisted per-player in mod storage across sessions and machines.
  - Added a "Sound On/Off" image_button to each machine's main UI
    (generate_display), on the Help/Pays row. It is an image_button (plain
    button[] elements do not render in this image-based formspec). Clicking
    it toggles the player's mute flag and confirms the new state in chat.
    jackpot_win_threshold was added to each machine definition so the
    jackpot fanfare fires on the correct top-tier win.

minislots_golden7s/init.lua  -- bet no longer auto-spins
minislots_golden7s_deluxe/init.lua  -- bet no longer auto-spins
  - Set bet_initiates_spin = false on both machines. Selecting a bet
    amount now only sets the line bet; the player presses SPIN separately
    to spin. This prevents accidental spins when adjusting the bet.

minislots_golden7s/init.lua  -- crafting recipe
minislots_golden7s_deluxe/init.lua  -- crafting recipe
  - Added shaped 3x3 crafting recipes (absent from the original proof-of-concept).
    Golden 7s: 4x default:goldblock, 1x default:mese,
      1x default:obsidian_glass, 1x default:diamond,
      1x currency:minegeld_50, 1x default:acacia_wood.
    Golden 7s Deluxe: 4x default:goldblock, 1x default:mese,
      1x default:obsidian_glass, 1x default:diamondblock,
      1x currency:minegeld_100, 1x default:acacia_wood.
    The currency note is a seed float -- money built into the machine.
    The Deluxe is gated behind a diamond block, making it
    a genuine end-game crafting goal.

Files removed from the distribution (to reduce download size)
  - minislots_work_files/  (~14 MB of GIMP .xcf source files used to author
    the textures). This directory is not a mod and is never loaded by the
    game. The source art remains available in the upstream repository at
    https://github.com/mt-mods/minislots
  - .github/  (CI workflow) and .luacheckrc (lint config): development-only
    files not needed by players.
  No original mod code, textures, or license content was removed.

---

## Known limitations (documented, not bugs in normal play)

A full audit of the currency-handling paths (deposits, win crediting, cashout,
and balance preservation across dig/replace) found them correct: money is never
short-changed or overpaid in normal play, wins are credited exactly once, and
cashout denominations always sum exactly to the balance. Two theoretical edge
cases are documented in code comments and noted here for maintainers:

- Fractional "cent" currency notes (0.05 / 0.10 / 0.25 Mg) cannot be deposited,
  because the machine balance is an integer and both machines set
  currency_min = 1 (which rejects cent notes before any math runs). If you lower
  currency_min below 1 to accept cent notes, switch the balance to a fixed-point
  representation first, or fractional amounts will be floored away and lost. See
  the comment in allow_metadata_inventory_put in minislots_engine/engine.lua.

- The cashout button requires balance <= maxbalance. A single very large
  multi-line win could push the balance slightly above maxbalance (the deposit
  cap leaves headroom for a single win but not the theoretical maximum
  simultaneous multi-line jackpot), which would refuse the cashout button until
  the balance is brought back under the cap by spinning. No money is lost -- the
  balance stays intact and survives dig/replace. Reaching this requires a
  machine loaded to near maxbalance (tens of thousands of notes). See the
  comment on the fields.cout handler in minislots_engine/engine.lua.
