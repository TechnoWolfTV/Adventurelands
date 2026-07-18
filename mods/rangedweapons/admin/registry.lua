-- Builds the catalogue of rangedweapons items.
--
-- Each weapon in rangedweapons is really a *family* of item definitions:
-- the visible one (rangedweapons:glock17) plus hidden frames used for the
-- reload and cooldown animations (_r, _rr, _rrr, _rld) and unloaded or
-- primed states (_nopin). Disabling a weapon has to cover the whole family,
-- otherwise a player holding a half-reloaded gun keeps a working weapon.

local rwa = rangedweapons_admin

local registry = {
	roots = {},        -- root name -> entry
	root_of = {},      -- any member name -> root name
	by_category = {},  -- category id -> sorted array of root names
}
rwa.registry = registry

rwa.categories = {
	{ id = "gun",   label = "Firearms" },
	{ id = "power", label = "Energy" },
	{ id = "throw", label = "Thrown" },
	{ id = "ammo",  label = "Ammunition" },
	{ id = "misc",  label = "Other" },
}

local PREFIX = "rangedweapons:"

local function is_rw(name)
	return name:sub(1, #PREFIX) == PREFIX
end

local function strip_colors(s)
	if core.strip_colors then
		local ok, out = pcall(core.strip_colors, s)
		if ok and out then
			return out
		end
	end
	return (s:gsub("\27%(.-%)", ""):gsub("\27.", ""))
end

--- First line of the description, cleaned up, as a display label.
local function short_label(name, def)
	local desc = def.description or ""
	desc = strip_colors(desc)
	local first = desc:match("^%s*([^\n]+)") or ""
	first = first:gsub("^%s+", ""):gsub("%s+$", "")
	if first == "" then
		first = name:sub(#PREFIX + 1):gsub("_", " ")
	end
	return first
end

local function category_of(def)
	if def.RW_gun_capabilities then
		return "gun"
	elseif def.RW_powergun_capabilities then
		return "power"
	elseif def.RW_throw_capabilities then
		return "throw"
	elseif def.RW_ammo_capabilities then
		return "ammo"
	end
	return "misc"
end

local function hidden(def)
	return def.groups and (def.groups.not_in_creative_inventory or 0) > 0
end

--- Walk the state-machine links out of a root definition to collect its family.
local function collect_family(root)
	local family = { [root] = true }
	local queue = { root }

	while #queue > 0 do
		local name = table.remove(queue)
		local def = core.registered_items[name]
		if def then
			local caps = def.RW_gun_capabilities or def.RW_powergun_capabilities
			local links = {
				def.rw_next_reload,
				def.loaded_gun,
				caps and caps.gun_unloaded,
				caps and caps.gun_cooling,
				caps and caps.power_cooling,
			}
			for _, link in ipairs(links) do
				if type(link) == "string" and link ~= "" and not family[link]
						and core.registered_items[link] then
					family[link] = true
					queue[#queue + 1] = link
				end
			end
		end
	end

	return family
end

function registry.build()
	registry.built = true
	registry.roots = {}
	registry.root_of = {}
	registry.by_category = {}

	for _, cat in ipairs(rwa.categories) do
		registry.by_category[cat.id] = {}
	end

	-- Pass 1: anything visible in creative with a real description is a root.
	for name, def in pairs(core.registered_items) do
		if is_rw(name) and not hidden(def) and (def.description or "") ~= "" then
			registry.roots[name] = {
				name = name,
				label = short_label(name, def),
				tooltip = strip_colors(def.description or name),
				category = category_of(def),
				family = { name },
			}
			registry.root_of[name] = name
		end
	end

	-- Pass 2: attach linked animation/state frames to their root.
	for root, entry in pairs(registry.roots) do
		for member in pairs(collect_family(root)) do
			if not registry.root_of[member] then
				registry.root_of[member] = root
				entry.family[#entry.family + 1] = member
			end
		end
	end

	-- Pass 3: name-prefix fallback, for frames not reachable by link
	-- (the hand grenade's primed state, for example). Longest root wins.
	for name, def in pairs(core.registered_items) do
		if is_rw(name) and not registry.root_of[name] and hidden(def) then
			local best
			for root in pairs(registry.roots) do
				if name:sub(1, #root + 1) == root .. "_" then
					if not best or #root > #best then
						best = root
					end
				end
			end
			if best then
				registry.root_of[name] = best
				local fam = registry.roots[best].family
				fam[#fam + 1] = name
			end
		end
	end

	-- Sort each category by display label.
	for root, entry in pairs(registry.roots) do
		local bucket = registry.by_category[entry.category]
		bucket[#bucket + 1] = root
	end
	for _, bucket in pairs(registry.by_category) do
		table.sort(bucket, function(a, b)
			return registry.roots[a].label:lower() < registry.roots[b].label:lower()
		end)
	end

	local count = 0
	for _ in pairs(registry.roots) do
		count = count + 1
	end
	core.log("action", ("[rangedweapons_admin] catalogued %d items"):format(count))
end

--- Every item name belonging to a root, including the root itself.
function registry.family(root)
	local entry = registry.roots[root]
	return entry and entry.family or { root }
end

--- Which items are ingredients in other rangedweapons recipes.
---
--- Disabling one of these stops that component being crafted, which starves
--- every recipe downstream of it even when those items are still enabled.
--- Detected from the recipe graph rather than hardcoded, so it stays correct
--- if upstream changes its crafting tree.
function registry.build_dependency_graph()
	registry.dependents = {}

	for output, recipes in pairs(rwa.crafting.all_snapshots()) do
		local out_root = registry.root_of[output]
		if out_root then
			for _, rec in ipairs(recipes) do
				local seen = {}
				for _, ingredient in pairs(rec.items or {}) do
					if type(ingredient) == "string" and is_rw(ingredient) then
						local in_root = registry.root_of[ingredient]
						if in_root and in_root ~= out_root and not seen[in_root] then
							seen[in_root] = true
							registry.dependents[in_root] = registry.dependents[in_root] or {}
							local list = registry.dependents[in_root]
							list[#list + 1] = out_root
						end
					end
				end
			end
		end
	end

	for _, list in pairs(registry.dependents) do
		table.sort(list)
	end
end

--- Which guns accept each ammunition type.
---
--- Crafting dependencies are not the only kind. Disabling an ammo type leaves
--- every gun chambered for it inert while the panel still shows those guns as
--- enabled, so the panel has to know about it.
function registry.build_ammo_graph()
	registry.ammo_users = {}
	registry.gun_ammo = {}

	for root in pairs(registry.roots) do
		local def = core.registered_items[root]
		local caps = def and (def.RW_gun_capabilities or def.RW_powergun_capabilities)
		local suitable = caps and caps.suitable_ammo

		if type(suitable) == "table" then
			for _, entry in pairs(suitable) do
				local ammo = type(entry) == "table" and entry[1] or entry
				if type(ammo) == "string" and ammo ~= "" then
					local ammo_root = registry.root_of[ammo] or ammo
					registry.ammo_users[ammo_root] = registry.ammo_users[ammo_root] or {}
					table.insert(registry.ammo_users[ammo_root], root)
					registry.gun_ammo[root] = registry.gun_ammo[root] or {}
					table.insert(registry.gun_ammo[root], ammo_root)
				end
			end
		end
	end

	for _, list in pairs(registry.ammo_users) do
		table.sort(list)
	end
end

--- Guns that accept this ammunition.
function registry.ammo_users_of(ammo_root)
	return (registry.ammo_users or {})[ammo_root] or {}
end

--- Guns that would be left with no usable ammunition at all.
function registry.guns_starved_by(ammo_root)
	local starved = {}
	for _, gun in ipairs(registry.ammo_users_of(ammo_root)) do
		local any_left = false
		for _, ammo in ipairs((registry.gun_ammo or {})[gun] or {}) do
			if ammo ~= ammo_root and not rwa.is_disabled(ammo) then
				any_left = true
				break
			end
		end
		if not any_left then
			starved[#starved + 1] = gun
		end
	end
	table.sort(starved)
	return starved
end

--- Total number of things affected by disabling this item, for display.
function registry.impact_count(root)
	return #registry.dependents_of(root) + #registry.ammo_users_of(root)
end

--- Roots that can no longer be crafted if `root` is disabled.
function registry.dependents_of(root)
	return (registry.dependents or {})[root] or {}
end

--- Sub-grouping used inside the Other tab.
function registry.subcategory(root)
	if #registry.dependents_of(root) > 0 then
		return "core"
	end
	local short = root:sub(#PREFIX + 1)
	if short:find("power") or short:find("generator") then
		return "energy"
	end
	return "misc"
end

--- Build on demand, in case the mods_loaded hook never ran.
function registry.ensure_built()
	if not registry.built then
		core.log("warning", "[rangedweapons_admin] catalogue built lazily; " ..
			"the mods_loaded hook did not fire")
		registry.build()
		return true
	end
	return false
end

--- Count of raw rangedweapons:* items the engine knows about.
function registry.raw_count()
	local n = 0
	for name in pairs(core.registered_items) do
		if is_rw(name) then
			n = n + 1
		end
	end
	return n
end

--- Human-readable health check. Answers "is it me or is it the parent mod?"
function registry.diagnose()
	local lines = {}

	-- The panel is bundled inside rangedweapons, so if this code is running
	-- the parent mod loaded. The meaningful signal is whether it managed to
	-- register its items.
	lines[#lines + 1] = ("build: %s (bundled in rangedweapons)"):format(rwa.VERSION)

	local raw = registry.raw_count()
	lines[#lines + 1] = ("rangedweapons:* items registered: %d"):format(raw)

	local roots = 0
	for _ in pairs(registry.roots) do
		roots = roots + 1
	end
	lines[#lines + 1] = ("catalogue built: %s, items catalogued: %d"):format(
		registry.built and "yes" or "NO", roots)

	local missing = {}
	for _, fname in ipairs(rwa.global_names) do
		if type(rawget(_G, fname)) ~= "function" then
			missing[#missing + 1] = fname
		end
	end
	lines[#lines + 1] = ("enforcement hooks missing: %s"):format(
		#missing == 0 and "none" or table.concat(missing, ", "))
	lines[#lines + 1] = ("craft-guide recipes hidden: %d"):format(
		rwa.crafting.hidden_guide_entries())

	if raw == 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Diagnosis: rangedweapons loaded this panel but registered no"
		lines[#lines + 1] = "items of its own, so its own init failed part-way. Check"
		lines[#lines + 1] = "debug.txt for the first rangedweapons error, and confirm the"
		lines[#lines + 1] = "default and tnt dependencies are satisfied by your game."
	elseif roots == 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Diagnosis: items exist but none matched. Report this."
	else
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Diagnosis: healthy."
	end

	return table.concat(lines, "\n")
end
