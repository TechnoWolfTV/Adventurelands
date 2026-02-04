dofile(core.get_modpath("myglass").."/glass.lua")	
dofile(core.get_modpath("myglass").."/xpanes.lua")
dofile(core.get_modpath("myglass").."/framed.lua")
dofile(core.get_modpath("myglass").."/misc.lua")
dofile(core.get_modpath("myglass").."/nodes.lua")
dofile(core.get_modpath("myglass").."/shutters.lua")


local colors = {"red", "cyan", "green", "violet", "purple", "white"}
for _,col in pairs(colors) do
	if core.get_modpath("lucky_block") then
		lucky_block:add_blocks({
			{"dro", {"myglass:window_frame"}, 4},
			{"dro", {"myglass:window_horizontal"}, 4},
			{"dro", {"myglass:window_vertical"}, 4},
			{"dro", {"myglass:window_plus"}, 4},
			{"dro", {"myglass:window_frame_white"}, 4},
			{"dro", {"myglass:window_horizontal_white"}, 4},
			{"dro", {"myglass:window_vertical_white"}, 4},
			{"dro", {"myglass:window_plus_white"}, 4},
			{"dro", {"myglass:blinds_"..col}, 4},
			{"dro", {"myglass:window_shutter"}, 6},
			{"dro", {"myglass:window_shutter2"}, 6},
			{"dro", {"myglass:myglass_framed_black"}, 10},
			{"dro", {"myglass:myglass_framed_yellow"}, 10},
			{"dro", {"myglass:myglass_framed_white"}, 10},
			{"dro", {"myglass:myglass_framed_blue"}, 10},
			{"dro", {"myglass:myglass_framed_red"}, 10},
			{"dro", {"myglass:myglass_framed_lime"}, 10},
			{"dro", {"myglass:myglass_black"}, 1},
			{"dro", {"myglass:myglass_yellow"}, 1},
			{"dro", {"myglass:myglass_white"}, 1},
			{"dro", {"myglass:myglass_blue"}, 1},
			{"dro", {"myglass:myglass_red"}, 1},
			{"dro", {"myglass:myglass_lime"}, 1},
			{"dro", {"myglass:myglass_mesh"}, 1},
			{"dro", {"myglass:myglass_cross"}, 1},
			{"dro", {"myglass:myglass_hole"}, 1},
			{"dro", {"myglass:myglass_bars"}, 1},
			{"dro", {"myglass:myglass_grid"}, 1},
			{"dro", {"myglass:glass_pane_black"}, 1},
			{"dro", {"myglass:glass_pane_white"}, 1},
			{"dro", {"myglass:glass_pane_yellow"}, 1},
			{"dro", {"myglass:glass_pane_blue"}, 1},
			{"dro", {"myglass:glass_pane_red"}, 1},
			{"dro", {"myglass:glass_pane_lime"}, 1},
		})
	end
end
