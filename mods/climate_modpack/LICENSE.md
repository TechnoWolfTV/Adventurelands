# Climate Modpack — License Summary

This modpack bundles four independent mods, each with its own license.
moon_phase is included unmodified. breasy and lightning carry small downstream
patches by TechnoWolfTV, released under each mod's own license and documented
in that mod's files. weather_pack is extensively modified by TechnoWolfTV.

---

## breasy
- **Author:** Bas080 (https://content.luanti.org/packages/Bas080/breasy/)
- **License:** GNU Lesser General Public License v2.1 (LGPL 2.1)
- **Full license:** `./breasy/LICENSE.txt`
- **Modified by:** TechnoWolfTV (2026-07-22), under the same LGPL 2.1 terms.
  One change to `init.lua`: fixes NaN wind vectors returned by `get_wind()`,
  which crashed the server via `add_particle`. See `./breasy/CHANGELOG.md`
  entry `2.0.3-tw1`.

---

## lightning
- **Author:** Auke Kok / sofar \<sofar@foo-projects.org\>
- **License:** GNU Lesser General Public License v2.1 (LGPL 2.1)
- **Full license:** `./lightning/README.md`
- **Modified by:** TechnoWolfTV (2026-07-22), under the same LGPL 2.1 terms.
  Deprecated-API updates to `init.lua` only (`table.getn`, `get_sky`,
  `set_sky`), with no intended change in behaviour. See the modification
  notice at the top of `./lightning/README.md`.

---

## moon_phase
- **License:** GNU Lesser General Public License v3 (LGPL 3)
- **Full license:** `./moon_phase/LICENSE.md`
- Included unmodified.

---

## weather_pack
- **Original author:** Artūras Norkus (xeranas)
- **License:** MIT
- **Modified by:** TechnoWolfTV (2025-2026)
- **Full license and modification details:** `./weather_pack/LICENSE`
