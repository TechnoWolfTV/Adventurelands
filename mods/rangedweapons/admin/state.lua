-- Persistent state: which weapons are switched off.
-- Only "root" item names are stored. Variants (reload frames, cooldown
-- frames, unloaded versions) resolve to their root at lookup time.

local rwa = rangedweapons_admin
-- Bundled edition shares rangedweapons' mod storage, so the key is namespaced
-- to avoid colliding with anything the parent mod stores.
local storage = core.get_mod_storage()
local KEY = "rwadmin_disabled"

local disabled = {}

-- Bulk operations touch every item. Without batching, disabling everything
-- meant one JSON write per item. These defer the write until the batch
-- finishes.
rwa.batching = false

local function save()
	if rwa.batching then
		return
	end
	local list = {}
	for name in pairs(disabled) do
		list[#list + 1] = name
	end
	table.sort(list)
	storage:set_string(KEY, core.write_json(list))
end

local function load()
	local raw = storage:get_string(KEY)
	if raw == nil or raw == "" then
		return
	end
	local ok, parsed = pcall(core.parse_json, raw)
	if ok and type(parsed) == "table" then
		for _, name in ipairs(parsed) do
			if type(name) == "string" then
				disabled[name] = true
			end
		end
	end
end

load()

--- Resolve any item name (root or variant) to its root name.
function rwa.root_of(itemname)
	return rwa.registry.root_of[itemname] or itemname
end

--- Is this item switched off? Accepts roots and variants alike.
function rwa.is_disabled(itemname)
	if not itemname or itemname == "" then
		return false
	end
	return disabled[rwa.root_of(itemname)] == true
end

--- Sorted array of disabled root names.
function rwa.disabled_list()
	local list = {}
	for name in pairs(disabled) do
		list[#list + 1] = name
	end
	table.sort(list)
	return list
end

--- Switch a root item off (true) or back on (false).
--- Returns true if the state actually changed.
function rwa.set_disabled(root, off, actor_name)
	root = rwa.root_of(root)
	off = off and true or nil

	if disabled[root] == off then
		return false
	end

	disabled[root] = off
	save()
	rwa.apply(root)

	core.log("action", ("[rangedweapons_admin] %s %s %s"):format(
		actor_name or "server",
		off and "disabled" or "enabled",
		root
	))

	return true
end

--- Apply one state to many roots as a single batch.
--- Returns the number of items that actually changed.
function rwa.set_many(roots, off, actor_name)
	local changed = 0

	rwa.batching = true
	local ok, err = pcall(function()
		for _, root in ipairs(roots) do
			if rwa.set_disabled(root, off, actor_name) then
				changed = changed + 1
			end
		end
	end)
	rwa.batching = false

	-- Flush once, even if something failed part-way, so state on disk always
	-- matches state in memory.
	save()
	rwa.crafting.resync()

	if not ok then
		error(err)
	end

	return changed
end

--- Every root in the catalogue, sorted.
function rwa.all_roots()
	local list = {}
	for root in pairs(rwa.registry.roots) do
		list[#list + 1] = root
	end
	table.sort(list)
	return list
end

function rwa.toggle(root, actor_name)
	root = rwa.root_of(root)
	rwa.set_disabled(root, not rwa.is_disabled(root), actor_name)
	return rwa.is_disabled(root)
end
