-- rangedweapons_admin (bundled edition)
--
-- In-game control panel for switching individual rangedweapons items off
-- and on, for anyone holding the server privilege.
--
-- Design note: rangedweapons fires automatic weapons from a globalstep in
-- cooldown_stuff.lua rather than from on_use. Enforcement therefore wraps
-- the mod's five global entry points as well as the per-item callbacks.

-- Bundled inside rangedweapons: loaded by a dofile at the end of the parent
-- mod's init.lua, so get_current_modname() resolves to "rangedweapons".
rangedweapons_admin = {}

-- Internal build marker.
rangedweapons_admin.VERSION = "master"

local modpath = core.get_modpath(core.get_current_modname()) .. "/admin"

dofile(modpath .. "/registry.lua")
dofile(modpath .. "/state.lua")
dofile(modpath .. "/crafting.lua")
dofile(modpath .. "/enforce.lua")
dofile(modpath .. "/ui.lua")
dofile(modpath .. "/guide.lua")

core.register_on_mods_loaded(function()
	local rwa = rangedweapons_admin

	rwa.registry.build()

	if rwa.registry.raw_count() == 0 then
		core.log("error", "[rangedweapons_admin] no rangedweapons:* items are " ..
			"registered. rangedweapons is not loading — check debug.txt above " ..
			"this line. The admin panel will open but list nothing.")
	end

	rwa.crafting.snapshot_all()
	rwa.registry.build_dependency_graph()
	rwa.registry.build_ammo_graph()
	rwa.install_enforcement()

	-- Craft guides build their recipe index in their own mods_loaded callback,
	-- which may run after this one. Reconciling here would be a no-op against
	-- an index that does not exist yet, leaving items disabled in a previous
	-- session listed with working recipes. core.after(0) runs on the first
	-- server step, by which point every mod has finished loading.
	core.after(0, function()
		rwa.crafting.resync()
	end)

	core.log("action", ("[rangedweapons_admin] build %s ready, %d disabled")
		:format(rwa.VERSION, #rwa.disabled_list()))
end)
