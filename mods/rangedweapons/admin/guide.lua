-- Player guide: /rwinfo
--
-- Open to everyone, no privilege required. The admin panel is a tool for one
-- person; this is the thing the other forty people on the server need, because
-- none of the controls here are discoverable by guessing.

local rwa = rangedweapons_admin

local FORMNAME = "rangedweapons_admin:guide"

local VIEW_W, VIEW_H = 12.6, 8.6
local HEADING_H, LINE_H, GAP_H = 0.78, 0.44, 0.34
local SCROLL_FACTOR = 0.1

-- {kind, text}: "h" heading, "p" body line, "" blank spacer.
-- Lines are pre-wrapped; formspec labels do not wrap on their own.
local GUIDE = {
	{"h", "Controls"},
	{"p", "Left-click            Fire"},
	{"p", "Hold left-click       Keep firing, on automatic weapons"},
	{"p", "Right-click           Reload, or cycle the action"},
	{"p", "Sneak + right-click   Unload, emptying ammo back to your inventory"},
	{"p", "Zoom key              Look through the scope, on scoped rifles"},
	{"", ""},
	{"p", "Sneak is Shift by default and zoom is Z, but both follow whatever"},
	{"p", "you have set in Settings > Controls."},
	{"", ""},

	{"h", "Firing"},
	{"p", "Point and left-click. Automatic weapons keep firing while you hold"},
	{"p", "the button; everything else fires once per click."},
	{"", ""},
	{"p", "Accuracy, damage, rate of fire and clip size differ for every gun."},
	{"p", "Hover a weapon in your inventory to read its full statistics."},
	{"", ""},
	{"p", "Guns wear out with use and will eventually break. Bullets travel"},
	{"p", "and drop over distance, so lead your target at long range."},
	{"", ""},

	{"h", "Reloading"},
	{"p", "Right-click with matching ammunition somewhere in your inventory."},
	{"p", "Each gun accepts only certain ammunition types, listed in its"},
	{"p", "description. Reloading returns whatever was still in the gun before"},
	{"p", "loading the new clip, so nothing is wasted."},
	{"", ""},
	{"p", "If nothing happens when you right-click, you have no ammunition the"},
	{"p", "gun accepts."},
	{"", ""},
	{"p", "Shotguns load one shell at a time: right-click repeatedly. On"},
	{"p", "shotguns and bolt-action rifles, right-clicking a loaded weapon"},
	{"p", "ejects the spent shell and cycles the action instead."},
	{"", ""},

	{"h", "Unloading"},
	{"p", "Sneak and right-click. Every round in the gun returns to your"},
	{"p", "inventory, and anything that does not fit drops at your feet."},
	{"", ""},
	{"p", "Use this to swap ammunition types, or to strip a gun before"},
	{"p", "trading or storing it."},
	{"", ""},

	{"h", "Ammunition"},
	{"p", "Ammunition stacks in different sizes depending on how powerful it"},
	{"p", "is. Pistol rounds stack to several hundred; rockets stack to 15."},
	{"p", "This is deliberate, so heavy ordnance costs you carrying space."},
	{"", ""},
	{"p", "Different ammunition changes how a gun performs. A gun that accepts"},
	{"p", "several types will hit harder or softer depending on what you feed"},
	{"p", "it, so check the numbers before committing to a type."},
	{"", ""},

	{"h", "Skills"},
	{"p", "Using a category of weapon improves your skill with it over time,"},
	{"p", "which makes that whole category more accurate for you. Skills can"},
	{"p", "also degrade. Check yours with /gunskills."},
	{"", ""},

	{"h", "Safe zones"},
	{"p", "Anti-gun blocks stop all shooting and throwing within ten nodes."},
	{"p", "If you are told weapons are prohibited in an area, one is nearby."},
	{"", ""},

	{"h", "If something stops working"},
	{"p", "Server admins can switch individual weapons, ammunition and items"},
	{"p", "off. A disabled item stays in your inventory exactly as it was and"},
	{"p", "is never deleted or taken from you. It simply does nothing until"},
	{"p", "the admin turns it back on, at which point it works again."},
	{"", ""},
	{"p", "You will always get a chat message explaining why, rather than"},
	{"p", "silently failing. Unloading still works on a disabled gun, so you"},
	{"p", "can always recover your ammunition."},
	{"", ""},
	{"p", "A disabled item stays listed in the crafting guide, but its recipe"},
	{"p", "is hidden and it cannot be crafted until an admin re-enables it."},
	{"", ""},

	{"h", "Commands"},
	{"p", "/rwinfo                 This guide.  Anyone."},
	{"p", "/gunskills              Your weapon skills.  Anyone."},
	{"", ""},
	{"p", "The following need the 'server' privilege:"},
	{"", ""},
	{"p", "/rwadmin                Open the admin panel."},
	{"p", "/rwadmin list           What is currently disabled."},
	{"p", "/rwadmin deps <item>    What depends on an item."},
	{"p", "/rwadmin off <item>     Disable one item."},
	{"p", "/rwadmin on <item>      Enable one item."},
	{"p", "/rwadmin off-all        Disable everything."},
	{"p", "/rwadmin on-all         Enable everything."},
	{"p", "/rwadmin debug          Health check."},
	{"", ""},
}

local function esc(s)
	return core.formspec_escape(s or "")
end

local function content_height()
	local h = 0
	for _, row in ipairs(GUIDE) do
		if row[1] == "h" then
			h = h + HEADING_H
		elseif row[1] == "p" then
			h = h + LINE_H
		else
			h = h + GAP_H
		end
	end
	return h
end

local function build_formspec()
	local total = content_height()
	local overflow = math.max(0, total - VIEW_H)
	local max_scroll = math.ceil(overflow / SCROLL_FACTOR)

	-- Thumb size proportional to how much of the document is on screen.
	local thumb = math.max(50, math.floor(max_scroll * (VIEW_H / math.max(total, 0.01))))

	local fs = {
		"formspec_version[4]",
		"size[14,11.4]",
		("label[0.5,0.7;%s]"):format(esc("Ranged Weapons — Player Guide")),
		("label[0.5,1.18;%s]"):format(
			esc("Scroll for more. Everything here works for any player.")),
		("scrollbaroptions[max=%d;thumbsize=%d]"):format(max_scroll, thumb),
		("scrollbar[13.1,1.6;0.35,%f;vertical;guide_scroll;0]"):format(VIEW_H),
		("scroll_container[0.5,1.6;%f,%f;guide_scroll;vertical;%f]")
			:format(VIEW_W, VIEW_H, SCROLL_FACTOR),
	}

	local y = 0
	for _, row in ipairs(GUIDE) do
		if row[1] == "h" then
			y = y + 0.34
			fs[#fs + 1] = ("label[0,%f;%s]"):format(y, esc(row[2]))
			y = y + HEADING_H - 0.34
		elseif row[1] == "p" then
			fs[#fs + 1] = ("label[0.2,%f;%s]"):format(y + 0.2, esc(row[2]))
			y = y + LINE_H
		else
			y = y + GAP_H
		end
	end

	fs[#fs + 1] = "scroll_container_end[]"
	fs[#fs + 1] = ("box[0.5,10.35;13,0.02;#ffffff22]")
	fs[#fs + 1] = "button_exit[11.9,10.5;1.6,0.8;close;Close]"

	return table.concat(fs)
end

function rwa.show_guide(pname)
	core.show_formspec(pname, FORMNAME, build_formspec())
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end
	if fields.quit or fields.close then
		return true
	end
	return true
end)

core.register_chatcommand("rwinfo", {
	description = "How to use the ranged weapons mod: controls, reloading, commands",
	privs = {},
	func = function(pname)
		rwa.show_guide(pname)
		return true
	end,
})
