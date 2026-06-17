-- adventurelands_bridges/init.lua
-- Merges the alcohol group into home_workshop_misc:beer_mug
-- so stamina's drunk effect triggers after drinking 4 mugs.

minetest.after(0, function()
    local def = minetest.registered_items["home_workshop_misc:beer_mug"]
    if not def then
        minetest.log("warning", "[adventurelands_bridges] beer_mug not found - bridge did nothing")
        return
    end

    local new_groups = table.copy(def.groups or {})
    new_groups.alcohol = 1

    minetest.override_item("home_workshop_misc:beer_mug", {
        groups = new_groups
    })

    minetest.log("action", "[adventurelands_bridges] alcohol group added to home_workshop_misc:beer_mug")
end)
