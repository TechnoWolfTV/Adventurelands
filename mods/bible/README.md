# Bible Mod for Luanti

A craftable, read-only Bible item with a full-featured in-game reader.

## Features

- **Read-only Bible** — cannot be edited by players
- **Book & Chapter navigation** — dropdown selectors + Prev/Next buttons
- **Full-book mode** — read an entire book in one scrollable view
- **Verse search** — keyword search across all loaded books, paginated results
- **Per-player bookmarks** — saved persistently across sessions
- **Random chapter** — jump to a random chapter at any time
- **Multiple translation support** — drop in additional translation packs
- **Chat commands** — `/bible`, `/bible John 3`, `/biblesearch love`

---

## Installation

1. Copy the `bible/` folder into your Luanti `mods/` directory.
2. Enable the mod in your world settings.

---

> ⚠️ **Note:** Modern translations (NKJV, ESV, NIV, NASB, NLT, etc.) are under
> copyright and may not be freely redistributed. Please only use public domain
> translations with this mod.

## Crafting Recipe

```
[ Paper ] [ Paper  ] [ Paper ]
[ Paper ] [ Gold   ] [ Paper ]
[ Paper ] [ Paper  ] [ Paper ]
```

Nine crafting slots: 8× `default:paper` + 1× `default:gold_ingot` (center).

---

## Chat Commands

| Command               | Description                            |
|---------------------|--------------------------------------|
| `/bible`              | Open the Bible reader                  |
| `/bible John 3`       | Open directly to John chapter 3        |
| `/biblesearch <word>` | Search all verses for a word or phrase |

---

## Compatibility

- **Luanti** 5.9+
- **Depends:** `default` (for paper and gold_ingot)
- No optional dependencies required

---

## License

Mod code: MIT License
KJV Bible text: Public Domain (1611, crown copyright expired)