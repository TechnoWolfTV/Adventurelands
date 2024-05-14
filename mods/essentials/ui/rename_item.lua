local FORMNAME = "essentials:rename_item"

function show_renameitem_menu(name)
	local formspec = string.format([[
        formspec_version[6]
        size[9.6,9.6]
        field[2.7,6.2;4.3,1.1;new_name;New name;]
        button[0.1,8.3;9.4,1.2;rename;Rename]
        image_button_exit[8.5,0.1;1,1;essentials_close_btn.png;close_btn;]
        label[3.2,0.9;Hold item in hand and]
        label[3.1,1.4;press "Rename" button]
        label[1.8,1.9;(Empty name for reset name of the item)]
        checkbox[3.7,4;format;Formatting;%s]
        label[2.8,0.3;--=How to rename item?=--]
        tooltip[format;Allows you to use "Minetest Lua" code for make text more cooler!]
		]],
		minetest.get_player_by_name(name):get_meta()
			:get_string("essentials_item_renamer_formatting")
	)

	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, field)
    local itemstack = player:get_wielded_item()
	local meta = itemstack:get_meta()
    --local color = field.color

	if formname ~= FORMNAME then
		return
	end

    if field.format ~= nil then
		local pmeta = player:get_meta()
		pmeta:set_string("essentials_item_renamer_formatting", field.format)
		return
	end

    if field.close_btn then
        minetest.sound_play("clicked")
		return
    end

    if not field.rename then return end

	local format = player:get_meta()
		:get_string("essentials_item_renamer_formatting")

	if format == "true" then
        local parsed = loadstring("return " .. field.new_name)
        meta:set_string("description", parsed())
    else
        meta:set_string("description", field.new_name)
    end

	--meta:set_string("color", field.color)
	player:set_wielded_item(itemstack)
    minetest.close_formspec(player:get_player_name(), formname)
end)