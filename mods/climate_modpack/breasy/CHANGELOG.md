# Changelog

## 2.0.3-tw1 — downstream patch (not an upstream release)

Modified by TechnoWolfTV, 2026-07-22, for the Adventurelands climate_modpack.
Not authored or endorsed by Bas080. Licensed under the LGPL 2.1, same as the
original.

- Fix NaN wind vectors returned by `wind.get_wind()`.

  The speed curve assumed the noise sample `s` spans [-1, 1]. With 3 octaves
  at persistence 0.5 it actually spans roughly [-1.75, 1.75]. Whenever
  `s < -1`, `(s + 1) * 0.5` went negative, and the 2.0.3 exponent `^ 1.4`
  turned a negative base into NaN. The existing `almost_zero` guard could not
  catch it, because every comparison against NaN evaluates to false, so the
  NaN escaped `get_wind()` and crashed any caller that passed it to
  `add_particle` ("Invalid float value for 'x' (NaN or infinity)").

  Under the mod's own noise configuration this affected roughly 1.3% of
  samples, or about 1 in 76.

  The sample is now divided by the true noise amplitude (1.75) before the
  [0, 1] mapping, making the original assumption correct. `math.max(0, ...)`
  is retained as a backstop.

  This also resolves the low-speed cut-off that 2.0.3 set out to address: both
  symptoms had the same root cause, and dead-calm samples now measure 0.0000%.

- `global_factor` raised from 10 to 10.6. The rescale narrows the speed
  distribution and lowers mean wind speed by about 5.5%; this restores the
  previous average. Revert to 10 for raw rescaled values.


## 2.0.3

- Fix unintended cut-off to zero on slower wind speeds.

## 2.0.2

- Fix accidental definition of a global.
- Removed the mention of particles in features list.
- Add a non documented and experimental get_occluded_wind function.

## 2.0.1

- Likely fixed the wind vector nan source.

## 2.0.0

- Removed the add function since this is not a physics library.
- Wind vector now represents meters per second.
- Found and fixed the `nan` source.
- Defined `breasy` global instead of doing dofile every time.

## 1.0.2

- Fix bug where very small wind values would cause Infinity or NaN.

## 1.0.1

- Use get_modpath instead of string directly.

## 1.0.0

- Have add wind second param act like multiply/factor.

## 0.0.2

- Add some default biome defs.
- Reduce velocity added when already moving with wind.
- Make force applied by wind increase exponentially with wind speed.
- Persist particle toggle to settings.

## 0.0.1

- Fix biome register example.
- Increase wind particle size.
- Improve docs slightly.
- Update to better screenshot.

## 0.0.0

* Provides a **location-based wind system** with direction and speed.
* Wind **slowly rotates** over time, completing configurable oscillations (e.g., ~2 switches per in‑game day).
* **Perlin noise** introduces minor natural variation for both direction and speed.
* **Biome influence**: modders can register biome-specific factors (`wind.register_biome`) to scale local wind speed.
* **Altitude attenuation**: wind weakens below sea level, gradually vanishing toward `MIN_Y`.
* Offers a **Wind:add()** helper to apply wind force to objects considering their density.
