-- Admin panel.
--
-- One screen, one gesture: click an item to switch it off, click it again to
-- switch it back on. Disabled items are tinted red and labelled in the
-- tooltip, so the panel doubles as the record of what is currently off.

local rwa = rangedweapons_admin

local FORMNAME = "rangedweapons_admin:panel"
local COLS = 8

local ctx = {}  -- player name -> { cat, page, query, map }

local function get_ctx(pname)
	local c = ctx[pname]
	if not c then
		c = { cat = "gun", page = 1, query = "", map = {} }
		ctx[pname] = c
	end
	return c
end

local function has_access(pname)
	return core.check_player_privs(pname, { server = true })
end

--- Roots in the current tab, narrowed by the search box.
local function visible_roots(c)
	local source = rwa.registry.by_category[c.cat] or {}
	if c.query == "" then
		return source
	end

	local needle = c.query:lower()
	local out = {}
	for _, root in ipairs(source) do
		local entry = rwa.registry.roots[root]
		if entry.label:lower():find(needle, 1, true)
				or root:lower():find(needle, 1, true) then
			out[#out + 1] = root
		end
	end
	return out
end

local SUBGROUPS = {
	{id = "core",   label = "Core components  —  other recipes depend on these"},
	{id = "energy", label = "Energy"},
	{id = "misc",   label = "Miscellaneous"},
}

--- Flatten a tab into rows. The Other tab is grouped into labelled sections;
--- every other tab is a plain grid. Returns a list of rows, each either a
--- header or up to COLS items, so pagination can pack by height.
local function build_rows(c, roots)
	local rows = {}

	local function push_items(list)
		for i = 1, #list, COLS do
			local row = {kind = "items", items = {}}
			for j = i, math.min(i + COLS - 1, #list) do
				row.items[#row.items + 1] = list[j]
			end
			rows[#rows + 1] = row
		end
	end

	if c.cat ~= "misc" then
		push_items(roots)
		return rows
	end

	local buckets = {}
	for _, root in ipairs(roots) do
		local sub = rwa.registry.subcategory(root)
		buckets[sub] = buckets[sub] or {}
		table.insert(buckets[sub], root)
	end

	for _, group in ipairs(SUBGROUPS) do
		local list = buckets[group.id]
		if list and #list > 0 then
			rows[#rows + 1] = {kind = "header", text = group.label, id = group.id}
			push_items(list)
		end
	end

	return rows
end

local HEADER_H, ITEM_H, GRID_TOP, GRID_BOTTOM = 0.62, 1.42, 3.7, 10.7

--- Pack rows into pages by cumulative height.
local function paginate(rows)
	local pages, current, used = {}, {}, 0
	for _, row in ipairs(rows) do
		local h = row.kind == "header" and HEADER_H or ITEM_H
		if used + h > (GRID_BOTTOM - GRID_TOP) and #current > 0 then
			pages[#pages + 1] = current
			current, used = {}, 0
		end
		current[#current + 1] = row
		used = used + h
	end
	if #current > 0 then
		pages[#pages + 1] = current
	end
	if #pages == 0 then
		pages[1] = {}
	end
	return pages
end

local function esc(s)
	return core.formspec_escape(s or "")
end

local function build_formspec(pname)
	local c = get_ctx(pname)
	local roots = visible_roots(c)
	local all_pages = paginate(build_rows(c, roots))

	local pages = #all_pages
	if c.page > pages then
		c.page = pages
	end
	if c.page < 1 then
		c.page = 1
	end

	local page_rows = all_pages[c.page] or {}

	local fs = {
		"formspec_version[4]",
		"size[17,12.6]",
		("label[0.4,0.6;%s]"):format(esc(("Ranged Weapons Admin  (%s)"):format(rwa.VERSION))),
		"label[0.4,1.1;" .. esc("Click an item to switch it off. Click again to switch it back on.") .. "]",
	}

	-- Category tabs
	local x = 0.4
	for _, cat in ipairs(rwa.categories) do
		local count = #(rwa.registry.by_category[cat.id] or {})
		local label = ("%s (%d)"):format(cat.label, count)
		if cat.id == c.cat then
			fs[#fs + 1] = ("style[cat_%s;bgcolor=#3d5a80]"):format(cat.id)
		end
		fs[#fs + 1] = ("button[%f,1.6;2.55,0.8;cat_%s;%s]"):format(x, cat.id, esc(label))
		fs[#fs + 1] = ("tooltip[cat_%s;%s]"):format(cat.id,
			esc(("%d items in %s"):format(count, cat.label)))
		x = x + 2.65
	end

	-- Search
	fs[#fs + 1] = ("field[0.4,2.75;4.6,0.8;query;;%s]"):format(esc(c.query))
	fs[#fs + 1] = "field_close_on_enter[query;false]"
	fs[#fs + 1] = "button[5.1,2.75;1.6,0.8;do_search;Search]"
	fs[#fs + 1] = "button[6.8,2.75;1.6,0.8;clear_search;Clear]"

	-- Grid
	c.map = {}
	local n = 0
	local y = GRID_TOP

	for _, row in ipairs(page_rows) do
		if row.kind == "header" then
			fs[#fs + 1] = ("label[0.45,%f;%s]"):format(y + 0.3, esc(row.text))
			y = y + HEADER_H
		else
			for col, root in ipairs(row.items) do
				n = n + 1
				local entry = rwa.registry.roots[root]
				local bx = 0.4 + (col - 1) * 1.42
				local by = y
				local btn = "it_" .. n

				c.map[btn] = root

				local off = rwa.is_disabled(root)
				local deps = rwa.registry.impact_count(root)

				if off then
					fs[#fs + 1] = ("style[%s;bgcolor=#8c2020;bgcolor_hovered=#a83232]"):format(btn)
				elseif deps > 0 then
					-- amber: still enabled, but disabling it starves other recipes
					fs[#fs + 1] = ("style[%s;bgcolor=#6b4a12;bgcolor_hovered=#8a5f18]"):format(btn)
				end

				fs[#fs + 1] = ("item_image_button[%f,%f;1.25,1.25;%s;%s;]"):format(bx, by, root, btn)

		-- Full stat block from the item definition, so an admin can judge a
		-- weapon without leaving the panel. Status first, since that is the
		-- thing being decided here.
				local status = off and "DISABLED" or "ACTIVE"
				local body = entry.tooltip
				if body == "" or body == entry.label then
					body = entry.label
				end

				local core_note = ""
				local n_craft = #rwa.registry.dependents_of(root)
				local n_guns = #rwa.registry.ammo_users_of(root)
				if n_craft > 0 or n_guns > 0 then
					core_note = "\n\nOTHER ITEMS DEPEND ON THIS"
					if n_craft > 0 then
						core_note = core_note ..
							("\n%d recipe%s use%s it for crafting."):format(n_craft,
								n_craft == 1 and "" or "s", n_craft == 1 and "s" or "")
					end
					if n_guns > 0 then
						core_note = core_note ..
							("\n%d gun%s chambered for it."):format(n_guns,
								n_guns == 1 and " is" or "s are")
					end
				end

				-- Square brackets are formspec delimiters. They survive escaping,
				-- but keeping them out of the text avoids the noise entirely.
				local text = ("%s\n%s%s\n\n%s"):format(status, root, core_note, body)

				local bg = off and "#5c1a1a" or (deps > 0 and "#4a3208" or "#1a1a1a")
				fs[#fs + 1] = ("tooltip[%s;%s;%s;#ffffff]"):format(btn, esc(text), bg)
			end
			y = y + ITEM_H
		end
	end

	if #roots == 0 then
		if rwa.registry.raw_count() == 0 then
			fs[#fs + 1] = "box[0.4,3.8;11.4,2.6;#5c1a1a]"
			fs[#fs + 1] = "label[0.7,4.3;" .. esc("No rangedweapons items are registered on this server.") .. "]"
			fs[#fs + 1] = "label[0.7,4.8;" .. esc("The parent mod is not loading, so there is nothing to list here.") .. "]"
			fs[#fs + 1] = "label[0.7,5.3;" .. esc("Run /rwadmin debug for details, then check debug.txt.") .. "]"
			fs[#fs + 1] = "label[0.7,5.8;" .. esc("This panel is fine — it is reporting an empty world, not failing.") .. "]"
		else
			fs[#fs + 1] = "label[0.4,4.2;" .. esc("Nothing in this tab. Try another tab or clear the search.") .. "]"
		end
	end

	-- Side panel
	local disabled_count = #rwa.disabled_list()
	fs[#fs + 1] = "container[12.3,2.9]"
	fs[#fs + 1] = "box[0,0;4.3,8.5;#00000040]"
	fs[#fs + 1] = ("label[0.25,0.5;%s]"):format(esc(("Disabled right now: %d"):format(disabled_count)))
	fs[#fs + 1] = ("label[0.25,1.0;%s]"):format(esc("Bulk actions apply to the"))
	fs[#fs + 1] = ("label[0.25,1.4;%s]"):format(esc("current tab and search."))
	fs[#fs + 1] = "button[0.25,1.9;3.8,0.8;bulk_off;Disable these]"
	fs[#fs + 1] = "button[0.25,2.8;3.8,0.8;bulk_on;Enable these]"
	fs[#fs + 1] = "button[0.25,4.0;3.8,0.8;all_off;Disable everything]"
	fs[#fs + 1] = "button[0.25,4.9;3.8,0.8;all_on;Enable everything]"
	fs[#fs + 1] = ("tooltip[bulk_off;%s]"):format(
		esc("Disable every item currently listed on the left"))
	fs[#fs + 1] = ("tooltip[bulk_on;%s]"):format(
		esc("Enable every item currently listed on the left"))
	fs[#fs + 1] = ("tooltip[all_off;%s]"):format(
		esc("Disable every item in every tab, not just this one"))
	fs[#fs + 1] = ("tooltip[all_on;%s]"):format(
		esc("Enable every item in every tab. The panic button."))
	fs[#fs + 1] = ("label[0.25,6.0;%s]"):format(esc("Players keep disabled items."))
	fs[#fs + 1] = ("label[0.25,6.4;%s]"):format(esc("They just stop working, including"))
	fs[#fs + 1] = ("label[0.25,6.8;%s]"):format(esc("as crafting ingredients."))
	fs[#fs + 1] = ("label[0.25,7.4;%s]"):format(esc("Disabled items stay listed, but"))
	fs[#fs + 1] = ("label[0.25,7.8;%s]"):format(esc("their recipes are hidden."))
	fs[#fs + 1] = ("label[0.25,8.3;%s]"):format(esc("Amber = core component."))
	fs[#fs + 1] = "container_end[]"

	-- Pagination
	fs[#fs + 1] = "button[0.4,11.4;1.6,0.8;page_prev;<< Back]"
	fs[#fs + 1] = ("label[2.3,11.8;%s]"):format(esc(("Page %d of %d"):format(c.page, pages)))
	fs[#fs + 1] = "button[4.4,11.4;1.6,0.8;page_next;Next >>]"
	fs[#fs + 1] = "button[12.3,11.4;2.4,0.8;show_guide;Player guide]"
	fs[#fs + 1] = ("tooltip[show_guide;%s]"):format(
		esc("The /rwinfo guide every player can open"))
	fs[#fs + 1] = "button_exit[15.0,11.4;1.6,0.8;close;Close]"

	return table.concat(fs)
end

function rwa.show_panel(pname)
	if not has_access(pname) then
		core.chat_send_player(pname, core.colorize("#ff6b6b",
			"You need the server privilege to open this panel."))
		return
	end
	rwa.registry.ensure_built()
	core.show_formspec(pname, FORMNAME, build_formspec(pname))
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local pname = player:get_player_name()

	-- Re-check on every submission. Never trust the form itself.
	if not has_access(pname) then
		return true
	end

	if fields.quit or fields.close then
		ctx[pname] = nil
		return true
	end

	if fields.show_guide then
		rwa.show_guide(pname)
		return true
	end

	local c = get_ctx(pname)
	local refresh = false

	for _, cat in ipairs(rwa.categories) do
		if fields["cat_" .. cat.id] then
			c.cat = cat.id
			c.page = 1
			refresh = true
		end
	end

	if fields.do_search or fields.key_enter_field == "query" then
		c.query = (fields.query or ""):gsub("^%s+", ""):gsub("%s+$", "")
		c.page = 1
		refresh = true
	end

	if fields.clear_search then
		c.query = ""
		c.page = 1
		refresh = true
	end

	if fields.page_prev then
		c.page = c.page - 1
		refresh = true
	end

	if fields.page_next then
		c.page = c.page + 1
		refresh = true
	end

	if fields.bulk_off or fields.bulk_on then
		local off = fields.bulk_off and true or false
		local n = rwa.set_many(visible_roots(c), off, pname)
		core.chat_send_player(pname, core.colorize(off and "#ff6b6b" or "#7ddc7d",
			("%d item%s in this tab %s."):format(n, n == 1 and "" or "s",
				off and "disabled" or "enabled")))
		refresh = true
	end

	if fields.all_off or fields.all_on then
		local off = fields.all_off and true or false
		local n = rwa.set_many(rwa.all_roots(), off, pname)
		core.chat_send_player(pname, core.colorize(off and "#ff6b6b" or "#7ddc7d",
			("%d item%s %s across every tab."):format(n, n == 1 and "" or "s",
				off and "disabled" or "enabled")))
		refresh = true
	end

	for field in pairs(fields) do
		local root = c.map[field]
		if root then
			local now_off = rwa.toggle(root, pname)
			core.chat_send_player(pname, core.colorize(now_off and "#ff6b6b" or "#7ddc7d",
				("%s is now %s."):format(
					rwa.registry.roots[root].label,
					now_off and "disabled" or "enabled")))
			rwa.warn_if_core(pname, root, now_off)
			refresh = true
		end
	end

	if refresh then
		core.show_formspec(pname, FORMNAME, build_formspec(pname))
	end

	return true
end)

core.register_on_leaveplayer(function(player)
	ctx[player:get_player_name()] = nil
end)

core.register_chatcommand("rwadmin", {
	params = "[debug | list | deps <item> | off-all | on-all | off <item> | on <item>]",
	description = "Open the ranged weapons admin panel, or toggle an item by name",
	privs = { server = true },
	func = function(pname, param)
		param = (param or ""):gsub("^%s+", ""):gsub("%s+$", "")

		if param == "" then
			rwa.show_panel(pname)
			return true
		end

		if param == "debug" then
			rwa.registry.ensure_built()
			return true, rwa.registry.diagnose()
		end

		if param == "off-all" or param == "on-all" then
			rwa.registry.ensure_built()
			local off = param == "off-all"
			local n = rwa.set_many(rwa.all_roots(), off, pname)
			return true, ("%d item%s %s."):format(n, n == 1 and "" or "s",
				off and "disabled" or "enabled")
		end

		local dep_target = param:match("^deps%s+(%S+)$")
		if dep_target then
			rwa.registry.ensure_built()
			if not dep_target:find(":") then
				dep_target = "rangedweapons:" .. dep_target
			end
			local root = rwa.root_of(dep_target)
			if not rwa.registry.roots[root] then
				return false, ("Unknown item: %s"):format(dep_target)
			end
			local deps = rwa.registry.dependents_of(root)
			local guns = rwa.registry.ammo_users_of(root)
			local starved = rwa.registry.guns_starved_by(root)

			if #deps == 0 and #guns == 0 then
				return true, ("Nothing depends on %s."):format(root)
			end

			local out = {}
			if #deps > 0 then
				out[#out + 1] = ("%d recipe%s use %s:"):format(#deps,
					#deps == 1 and "" or "s", root)
				out[#out + 1] = "  " .. table.concat(deps, "\n  ")
			end
			if #guns > 0 then
				out[#out + 1] = ("%d gun%s chambered for %s:"):format(#guns,
					#guns == 1 and " is" or "s are", root)
				out[#out + 1] = "  " .. table.concat(guns, "\n  ")
			end
			if #starved > 0 then
				out[#out + 1] = ("Left with no usable ammunition: %s"):format(
					table.concat(starved, ", "))
			end
			return true, table.concat(out, "\n")
		end

		if param == "list" then
			local list = rwa.disabled_list()
			if #list == 0 then
				return true, "Nothing is disabled."
			end
			return true, ("Disabled (%d): %s"):format(#list, table.concat(list, ", "))
		end

		local action, item = param:match("^(%a+)%s+(%S+)$")
		if action ~= "off" and action ~= "on" then
			return false, "Usage: /rwadmin [debug | list | deps <item> | off-all | on-all | off <item> | on <item>]"
		end

		if not item:find(":") then
			item = "rangedweapons:" .. item
		end

		local root = rwa.root_of(item)
		if not rwa.registry.roots[root] then
			return false, ("Unknown item: %s"):format(item)
		end

		rwa.set_disabled(root, action == "off", pname)
		rwa.warn_if_core(pname, root, action == "off")
		return true, ("%s is now %s."):format(root, action == "off" and "disabled" or "enabled")
	end,
})
