-- Craft handling.
--
-- Design note, after a hard engine crash in live testing:
--
-- This module deliberately performs NO runtime mutation of engine state. It
-- does not clear or re-register recipes, and it does not override items.
-- Earlier versions did both; the engine explicitly warns that runtime item
-- overrides "can cause problems related to data inconsistency", and a bulk
-- toggle performed dozens of craft-table mutations back to back. Crafting a
-- disabled item through Unified Inventory then crashed the engine hard enough
-- to leave no Lua traceback.
--
-- What remains is two things, both of which are ordinary Lua table state:
--
--   1. Blocking, via the register_craft_predict / register_on_craft callbacks.
--      These are the supported way to reject a craft and mutate nothing. They
--      catch every craft path: the player's inventory grid, a crafting bench,
--      and any recipe another mod added.
--
--   2. Display, by hiding the recipe entry in Unified Inventory's own cached
--      index. Symmetric: entries are stashed on disable and restored on
--      enable. The item itself stays listed — only its recipe is hidden — so
--      a disabled item remains visible and inspectable, it simply cannot be
--      crafted.
--
-- Hiding the recipe is not merely cosmetic. Unified Inventory's craft button
-- reads the same index, and returns early when an item has no recipes, so
-- hiding the entry makes that programmatic craft path unreachable rather than
-- relying on it to fail gracefully.

local rwa = rangedweapons_admin
local crafting = {}
rwa.crafting = crafting

local PREFIX = "rangedweapons:"

--- Recipes producing each item, captured once at load for the dependency
--- graph. Read-only: nothing here is ever written back to the engine.
local snapshots = {}

function crafting.all_snapshots()
	return snapshots
end

function crafting.snapshot_all()
	for root in pairs(rwa.registry.roots) do
		for _, member in ipairs(rwa.registry.family(root)) do
			local recipes = core.get_all_craft_recipes(member)
			if recipes and #recipes > 0 then
				snapshots[member] = recipes
			end
		end
	end
end

----------------------------------------------------------------------
-- Display: Unified Inventory's cached recipe index
----------------------------------------------------------------------

local ui_backup = {}

local function ui_recipe_index()
	if type(unified_inventory) ~= "table" then
		return nil
	end
	local cf = unified_inventory.crafts_for
	if type(cf) ~= "table" or type(cf.recipe) ~= "table" then
		return nil
	end
	return cf.recipe
end

--- Reconcile the craft guide against the current disabled set.
---
--- Scans the guide's own index rather than walking this mod's item families.
--- The index is the authority on what is listed: it can contain keys this mod
--- does not enumerate (aliases, variants, guide-generated entries), and any
--- key missed here stays visible with a working recipe. Reconciling both
--- directions in one pass also makes the operation idempotent, so it can be
--- run at any time to bring the guide back in step.
local function resync_guide()
	local index = ui_recipe_index()
	if not index then
		return
	end

	-- Hide the recipes of anything currently disabled.
	-- Assigning nil to the current key during a pairs() traversal is safe.
	for name in pairs(index) do
		if name:sub(1, #PREFIX) == PREFIX and rwa.is_disabled(name) then
			ui_backup[name] = index[name]
			index[name] = nil
		end
	end

	-- Put back anything that is no longer disabled.
	for name, entry in pairs(ui_backup) do
		if not rwa.is_disabled(name) then
			index[name] = entry
			ui_backup[name] = nil
		end
	end
end

--- Public: bring the craft guide in step with the current state.
function crafting.resync()
	local ok, err = pcall(resync_guide)
	if not ok then
		core.log("error", "[rangedweapons_admin] could not update the craft " ..
			"guide listing, continuing anyway: " .. tostring(err))
	end
end

--- Number of recipe entries currently hidden. Diagnostic only.
function crafting.hidden_guide_entries()
	local n = 0
	for _ in pairs(ui_backup) do
		n = n + 1
	end
	return n
end



----------------------------------------------------------------------
-- Blocking: craft callbacks
----------------------------------------------------------------------

--- Crafting obeys the single strict-mode policy, so "disabled" means the same
--- thing whether an item is being crafted with, loaded into a gun, or fired.
local function block_ingredients()
	return rwa.strict()
end

--- First disabled item found in the craft grid, if any.
local function disabled_ingredient(grid)
	if type(grid) ~= "table" then
		return nil
	end
	for _, stack in pairs(grid) do
		if stack and stack.is_empty and not stack:is_empty()
				and rwa.is_disabled(stack:get_name()) then
			return stack:get_name()
		end
	end
	return nil
end

-- These run inside engine inventory transactions, where an uncaught Lua error
-- takes the server down. Every path is wrapped: on any internal failure the
-- guard logs loudly and fails open rather than crashing.
--
-- The ingredient check only runs when a recipe actually matched (itemstack is
-- non-empty). Otherwise it would fire on every idle shuffle of the craft grid.
local function craft_guard(itemstack, player, old_craft_grid, notify_output)
	if not itemstack or itemstack:is_empty() then
		return nil
	end

	if rwa.is_disabled(itemstack:get_name()) then
		if notify_output then
			rwa.notify(player, itemstack:get_name(), "craft")
		end
		return ItemStack("")
	end

	if block_ingredients() then
		local bad = disabled_ingredient(old_craft_grid)
		if bad then
			rwa.notify(player, bad, "ingredient")
			return ItemStack("")
		end
	end

	return nil
end

local function safe_guard(itemstack, player, old_craft_grid, notify_output)
	local ok, result = pcall(craft_guard, itemstack, player, old_craft_grid, notify_output)
	if ok then
		return result
	end
	core.log("error", "[rangedweapons_admin] craft guard failed, allowing " ..
		"the craft rather than crashing: " .. tostring(result))
	return nil
end

core.register_craft_predict(function(itemstack, player, old_craft_grid)
	return safe_guard(itemstack, player, old_craft_grid, false)
end)

core.register_on_craft(function(itemstack, player, old_craft_grid)
	return safe_guard(itemstack, player, old_craft_grid, true)
end)
