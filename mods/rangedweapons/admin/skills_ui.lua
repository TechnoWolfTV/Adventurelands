-- Optional Unified Inventory integration: a Gun Skills tab.
--
-- Entirely optional. If Unified Inventory is not installed nothing here runs
-- and /gunskills continues to work on its own. Registration happens in
-- register_on_mods_loaded because that mod may load after this one, and its
-- page and button tables do not exist until it has.
--
-- The skill values come from rangedweapons_get_skills(), the same accessor
-- /gunskills uses, so the two views can never disagree.

local COLS = 3
local COL_W = 3.3
local ROW_H = 0.85
local ICON = 0.7

local function esc(s)
	return core.formspec_escape(tostring(s))
end

local function build_page(player, layout)
	local base_x = layout.form_header_x
	local base_y = layout.form_header_y

	local fs = {
		layout.standard_inv_bg,
		("label[%f,%f;%s]"):format(base_x, base_y, esc("Gun Skills")),
		("label[%f,%f;%s]"):format(base_x, base_y + 0.55,
			esc("Efficiency raises damage, accuracy and critical hit chance.")),
	}

	local top = base_y + 1.15

	for i, skill in ipairs(rangedweapons_get_skills(player)) do
		local col = (i - 1) % COLS
		local row = math.floor((i - 1) / COLS)
		local x = base_x + col * COL_W
		local y = top + row * ROW_H

		fs[#fs + 1] = ("image[%f,%f;%f,%f;%s]"):format(x, y, ICON, ICON, skill.icon)
		fs[#fs + 1] = ("label[%f,%f;%s]"):format(x + ICON + 0.15, y + 0.12,
			esc(("%s: %d%%"):format(skill.label, skill.value)))
	end

	return table.concat(fs)
end

core.register_on_mods_loaded(function()
	if type(unified_inventory) ~= "table"
			or type(unified_inventory.register_page) ~= "function"
			or type(unified_inventory.register_button) ~= "function" then
		return
	end

	local ok, err = pcall(function()
		unified_inventory.register_page("rangedweapons_skills", {
			get_formspec = function(player, perplayer_formspec)
				return { formspec = build_page(player, perplayer_formspec) }
			end,
		})

		unified_inventory.register_button("rangedweapons_skills", {
			type = "image",
			image = "rangedweapons_handgun_img.png",
			tooltip = "Gun Skills",
		})
	end)

	if ok then
		core.log("action", "[rangedweapons_admin] Unified Inventory gun skills tab registered")
	else
		core.log("warning", "[rangedweapons_admin] could not add the Unified " ..
			"Inventory gun skills tab, continuing without it: " .. tostring(err))
	end
end)
