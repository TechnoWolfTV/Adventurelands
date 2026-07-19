local S = minetest.get_translator("rangedweapons")
local skill_list = {
	{id="handgun_skill",name="Handgun",short="Handgun",icon="rangedweapons_handgun_img.png"},
	{id="mp_skill",name="Machine Pistol",short="M.Pistol",icon="rangedweapons_machinepistol_img.png"},
	{id="smg_skill",name="S.M.G.",short="S.M.G.",icon="rangedweapons_smg_img.png"},
	{id="shotgun_skill",name="Shotgun",short="Shotgun",icon="rangedweapons_shotgun_img.png"},
	{id="heavy_skill",name="Heavy MG",short="Heavy MG",icon="rangedweapons_heavy_img.png"},
	{id="arifle_skill",name="A.Rifle",short="A.Rifle",icon="rangedweapons_arifle_img.png"},
	{id="revolver_skill",name="Revolver/magnum",short="Revl./mgn.",icon="rangedweapons_revolver_img.png"},
	{id="rifle_skill",name="Rifle",short="Rifle",icon="rangedweapons_rifle_img.png"},
	{id="throw_skill",name="Throwing weapons",short="Throwing",icon="rangedweapons_yeetable_img.png"},
}

--- Are skill gain/loss chat messages wanted? Off by default: skills drift
--- constantly, and the running commentary is noise. Players can check their
--- levels whenever they like with /gunskills.
function rangedweapons_skill_messages()
	return minetest.settings:get_bool("rangedweapons_skill_messages", false)
end

--- One player's skills, in display order. Shared by /gunskills and the
--- optional Unified Inventory page so they can never disagree.
function rangedweapons_get_skills(player)
	local meta = player:get_meta()
	local out = {}
	for i, skill in ipairs(skill_list) do
		out[i] = {
			label = skill.short,
			icon = skill.icon,
			value = meta:get_int(skill.id),
		}
	end
	return out
end

minetest.register_on_joinplayer(
   function(player)
      local meta = player:get_meta()
      for _,skill in ipairs(skill_list) do
	 if meta:get_int(skill.id) == 0 then
	    meta:set_int(skill.id,100)
	 end
      end
   end
)

--- Build the standalone /gunskills form. Layout matches the original: six
--- entries down the left, three down the right.
local function gunskills_formspec(player)
	local skills = rangedweapons_get_skills(player)
	local fs = {
		"size[11,7]",
		"label[0,0;Gun efficiency: increases damage, accuracy and crit chance.]",
		"button_exit[9,0;2,1;exit;Done]",
	}
	for i, skill in ipairs(skills) do
		local col = i <= 6 and 0 or 5
		local row = i <= 6 and i or (i - 6)
		fs[#fs + 1] = ("image[%d,%d;1,1;%s]"):format(col, row, skill.icon)
		fs[#fs + 1] = ("label[%d,%s;%s efficiency: %d%%]"):format(
			col + 1, row + 0.2, skill.label, skill.value)
	end
	return table.concat(fs)
end

minetest.register_chatcommand("gunskills", {
	description = "Show your weapon skill levels",
	func = function(name)
		-- Was: loop over every connected player and show the caller the last
		-- one's skills. On a server you saw somebody else's numbers.
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "You need to be in game to check your gun skills."
		end
		minetest.show_formspec(name, "rangedweapons:gunskills_form",
			gunskills_formspec(player))
		return true
	end,
})

local min_gun_efficiency = tonumber(minetest.settings:get("rangedweapons_min_gun_efficiency")) or 40
local timer = 0
minetest.register_globalstep(
   function(dtime, player)
      timer = timer + dtime;

      if timer > 60 then
	 for _, player in pairs(minetest.get_connected_players()) do
	    local meta = player:get_meta()
	    for _,skill in ipairs(skill_list) do
	       if math.random(1, 40) == 1 then
		  if meta:get_int(skill.id) > min_gun_efficiency then
		     meta:set_int(skill.id, meta:get_int(skill.id) - 1)
		     if rangedweapons_skill_messages() then
			minetest.chat_send_player(player:get_player_name(),
					       minetest.colorize("#ff0000",S("@1 skill degraded!", S(skill.name))))
		     end
		  end
	       end
	    end
	    timer = 0
	 end
      end
end)
