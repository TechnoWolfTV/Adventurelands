
Lightning mod for minetest


DOWNSTREAM MODIFICATION NOTICE (TechnoWolfTV, 2026-07-22)

This copy has been modified for the Adventurelands climate_modpack and is not
the pristine upstream release. Changes to init.lua, all deprecated-API updates
with no intended change in behaviour:

  - table.getn(playerlist) replaced with #playerlist (deprecated Lua).
  - player:get_sky() with no argument replaced with player:get_sky(true).
    The no-argument form is deprecated; the table form additionally preserves
    sky_color and fog, which the old three-value form discarded on restore.
  - Both player:set_sky() calls converted from the deprecated positional
    signature to the modern table form. The positional form also hid the
    sun, moon and stars for non-"regular" sky types as a side effect, which
    the table form does not do, so set_sun/set_moon/set_stars are now called
    explicitly to preserve the original strike appearance.

Modifications are released under the same LGPL 2.1 terms as the original.
Upstream: https://github.com/minetest-mods/lightning
Please report upstream bugs there rather than to Adventurelands.

===============================================================================



Copyright (C) 2016 - Auke Kok <sofar@foo-projects.org>

"lightning" is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1
of the license, or (at your option) any later version.


Textures: CC-BY-SA-4.0 by sofar
    lightning_1.png
    lightning_2.png
    lightning_3.png

Sounds:
    thunder.1.ogg - CC-BY-SA - hantorio - http://www.freesound.org/people/hantorio/sounds/121945/
    thunder.2.ogg - CC-BY-SA - juskiddink - http://www.freesound.org/people/juskiddink/sounds/101948/
    thunder.3.ogg - CC-BY-SA - IllusiaProductions - http://www.freesound.org/people/IllusiaProductions/sounds/249950/
