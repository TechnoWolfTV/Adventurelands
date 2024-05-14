local http = minetest.request_http_api()
local version = "0.7.1"
local modpath = minetest.get_modpath(minetest.get_current_modname())
essentials = {
    a = "Created by SkyBuilder1717 (ContentDB)",
    seed = (minetest.settings:get_bool("essentials_seed") or false),
    killed_by = (minetest.settings:get_bool("essentials_killed_by") or true),
    check_for_updates = (minetest.settings:get_bool("essentials_check_for_updates") or false),
    changed_by = (minetest.settings:get_bool("essentials_changed_by") or true),
    watermark = minetest.settings:get_bool("essentials_watermark"),
    have_unified_inventory = minetest.get_modpath("unified_inventory")
}
if essentials.watermark == nil then
    essentials.watermark = true
end

minetest.log("action", "[Essentials] Mod initialised. Version: ".. version)
minetest.log("action", "\n███████╗░██████╗░██████╗███████╗███╗░░██╗████████╗██╗░█████╗░██╗░░░░░░██████╗\n██╔════╝██╔════╝██╔════╝██╔════╝████╗░██║╚══██╔══╝██║██╔══██╗██║░░░░░██╔════╝\n█████╗░░╚█████╗░╚█████╗░█████╗░░██╔██╗██║░░░██║░░░██║███████║██║░░░░░╚█████╗░\n██╔══╝░░░╚═══██╗░╚═══██╗██╔══╝░░██║╚████║░░░██║░░░██║██╔══██║██║░░░░░░╚═══██╗\n███████╗██████╔╝██████╔╝███████╗██║░╚███║░░░██║░░░██║██║░░██║███████╗██████╔╝\n╚══════╝╚═════╝░╚═════╝░╚══════╝╚═╝░░╚══╝░░░╚═╝░░░╚═╝╚═╝░░╚═╝╚══════╝╚═════╝░\n[Essentials] "..essentials.a)

local function removeLastDot(str)
    local lastDotIndex = string.find(str,"%.[^.]*$")
    if lastDotIndex then
        return string.sub(str,1,lastDotIndex-1)..string.sub(str,lastDotIndex+1)
    else
        return str
    end
end

minetest.after(0, function()
    if essentials.check_for_updates then
        minetest.log("action", "[Essentials] Checking for updates...")
        if not minetest.request_insecure_environment() then
            minetest.log("action", "[Essentials] Getting an Github version...")
            http.fetch({
                url = "https://raw.githubusercontent.com/SkyBuilder1717/essentials/main/gitVersion.txt",
                timeout = 15,
                method = "GET",
        
            },  function(result)
                minetest.log("action", string.format("[Essentials] Github version getted! (v%s)", result.data:gsub("[\n\\]", "")))
                local git = tonumber(removeLastDot(result.data:gsub("[\n\\]", "")))
                local this = tonumber(removeLastDot(version))
                local test = false
                if git > this then
                    test = true
                end
                --core.chat_send_all(dump(test))
                if git > this then
                    minetest.log("warning", "[Essentials] Versions doesnt match!")
                    core.chat_send_all("[Essentials] Your server using old version of mod! ("..core.colorize("red", version)..") Old version can have a bugs! Download v"..core.colorize("lime", result.data:gsub("[\n\\]", "")).." on ContentDB.")
                else
                    local _type
                    if core.is_singleplayer() then
                        _type = "World"
                    else
                        _type = "Server"
                    end
                    minetest.log("action", string.format("[Essentials] All ok! %s using lastest version of mod.", _type))
                end
            end)
        else
            core.chat_send_all("[Essentials] Please, add mod \'essentials\' to \"secure.trusted_mods\" for checking an updates!")
        end
    end
end)

--==[[ connections ]]==--

dofile(modpath.."/commands.lua")
dofile(modpath.."/priveleges.lua")
dofile(modpath.."/ui/watermark.lua")
if essentials.have_unified_inventory then
    dofile(modpath.."/unified_inventory.lua")
end
dofile(modpath.."/ui/ban_menu.lua")
dofile(modpath.."/ui/kick_menu.lua")
dofile(modpath.."/ui/mute_menu.lua")
dofile(modpath.."/ui/color_menu.lua")
dofile(modpath.."/ui/rename_me.lua")
dofile(modpath.."/ui/rename_item.lua")