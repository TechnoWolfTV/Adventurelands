-- Minislots game engine
-- by Vanessa "VanessaE" Dannenberg

math.randomseed(os.time())

local char_widths = {
	[32] = {regular = 16, condensed = 12, bold = 24},
	[33] = {regular = 22, condensed = 18, bold = 28},
	[34] = {regular = 29, condensed = 23, bold = 40},
	[35] = {regular = 48, condensed = 39, bold = 47},
	[36] = {regular = 47, condensed = 39, bold = 47},
	[37] = {regular = 74, condensed = 60, bold = 75},
	[38] = {regular = 56, condensed = 46, bold = 61},
	[39] = {regular = 15, condensed = 12, bold = 20},
	[40] = {regular = 29, condensed = 24, bold = 29},
	[41] = {regular = 27, condensed = 22, bold = 28},
	[42] = {regular = 33, condensed = 27, bold = 34},
	[43] = {regular = 48, condensed = 39, bold = 49},
	[44] = {regular = 22, condensed = 18, bold = 23},
	[45] = {regular = 27, condensed = 22, bold = 28},
	[46] = {regular = 22, condensed = 18, bold = 23},
	[47] = {regular = 25, condensed = 21, bold = 24},
	[48] = {regular = 46, condensed = 37, bold = 47},
	[49] = {regular = 46, condensed = 37, bold = 47},
	[50] = {regular = 46, condensed = 37, bold = 47},
	[51] = {regular = 46, condensed = 37, bold = 47},
	[52] = {regular = 46, condensed = 38, bold = 48},
	[53] = {regular = 46, condensed = 37, bold = 47},
	[54] = {regular = 46, condensed = 37, bold = 47},
	[55] = {regular = 46, condensed = 37, bold = 47},
	[56] = {regular = 46, condensed = 37, bold = 47},
	[57] = {regular = 46, condensed = 37, bold = 47},
	[58] = {regular = 22, condensed = 18, bold = 28},
	[59] = {regular = 22, condensed = 18, bold = 28},
	[60] = {regular = 48, condensed = 39, bold = 49},
	[61] = {regular = 48, condensed = 39, bold = 49},
	[62] = {regular = 48, condensed = 39, bold = 49},
	[63] = {regular = 46, condensed = 37, bold = 51},
	[64] = {regular = 84, condensed = 69, bold = 82},
	[65] = {regular = 57, condensed = 47, bold = 61},
	[66] = {regular = 55, condensed = 45, bold = 61},
	[67] = {regular = 60, condensed = 49, bold = 61},
	[68] = {regular = 60, condensed = 49, bold = 61},
	[69] = {regular = 55, condensed = 45, bold = 56},
	[70] = {regular = 50, condensed = 41, bold = 51},
	[71] = {regular = 64, condensed = 53, bold = 65},
	[72] = {regular = 60, condensed = 49, bold = 61},
	[73] = {regular = 22, condensed = 18, bold = 23},
	[74] = {regular = 41, condensed = 33, bold = 47},
	[75] = {regular = 57, condensed = 47, bold = 61},
	[76] = {regular = 46, condensed = 38, bold = 51},
	[77] = {regular = 69, condensed = 56, bold = 70},
	[78] = {regular = 60, condensed = 49, bold = 61},
	[79] = {regular = 64, condensed = 53, bold = 65},
	[80] = {regular = 55, condensed = 45, bold = 56},
	[81] = {regular = 64, condensed = 53, bold = 65},
	[82] = {regular = 60, condensed = 49, bold = 61},
	[83] = {regular = 55, condensed = 45, bold = 56},
	[84] = {regular = 51, condensed = 42, bold = 52},
	[85] = {regular = 60, condensed = 49, bold = 61},
	[86] = {regular = 57, condensed = 47, bold = 57},
	[87] = {regular = 80, condensed = 66, bold = 81},
	[88] = {regular = 56, condensed = 46, bold = 57},
	[89] = {regular = 56, condensed = 46, bold = 56},
	[90] = {regular = 50, condensed = 41, bold = 51},
	[91] = {regular = 24, condensed = 20, bold = 28},
	[92] = {regular = 25, condensed = 21, bold = 24},
	[93] = {regular = 22, condensed = 18, bold = 28},
	[94] = {regular = 40, condensed = 33, bold = 49},
	[95] = {regular = 49, condensed = 41, bold = 49},
	[96] = {regular = 27, condensed = 22, bold = 28},
	[97] = {regular = 48, condensed = 40, bold = 49},
	[98] = {regular = 46, condensed = 37, bold = 51},
	[99] = {regular = 41, condensed = 34, bold = 47},
	[100] = {regular = 46, condensed = 37, bold = 51},
	[101] = {regular = 46, condensed = 37, bold = 47},
	[102] = {regular = 25, condensed = 21, bold = 30},
	[103] = {regular = 46, condensed = 37, bold = 51},
	[104] = {regular = 46, condensed = 37, bold = 51},
	[105] = {regular = 18, condensed = 14, bold = 23},
	[106] = {regular = 18, condensed = 14, bold = 23},
	[107] = {regular = 44, condensed = 36, bold = 48},
	[108] = {regular = 18, condensed = 14, bold = 23},
	[109] = {regular = 69, condensed = 56, bold = 75},
	[110] = {regular = 46, condensed = 37, bold = 51},
	[111] = {regular = 46, condensed = 37, bold = 51},
	[112] = {regular = 46, condensed = 37, bold = 51},
	[113] = {regular = 46, condensed = 37, bold = 51},
	[114] = {regular = 28, condensed = 23, bold = 33},
	[115] = {regular = 41, condensed = 33, bold = 47},
	[116] = {regular = 24, condensed = 20, bold = 28},
	[117] = {regular = 46, condensed = 37, bold = 51},
	[118] = {regular = 43, condensed = 36, bold = 48},
	[119] = {regular = 62, condensed = 51, bold = 67},
	[120] = {regular = 43, condensed = 35, bold = 48},
	[121] = {regular = 43, condensed = 36, bold = 48},
	[122] = {regular = 41, condensed = 33, bold = 42},
	[123] = {regular = 28, condensed = 23, bold = 33},
	[124] = {regular = 21, condensed = 17, bold = 24},
	[125] = {regular = 28, condensed = 23, bold = 33},
	[126] = {regular = 48, condensed = 39, bold = 49},
	[127] = {regular = 45, condensed = 37, bold = 48},
}

local words_numbers = { -- number words for the cash-out ticket
	[0] = "ZERO",
	"ONE",
	"TWO",
	"THREE",
	"FOUR",
	"FIVE",
	"SIX",
	"SEVEN",
	"EIGHT",
	"NINE",
	"TEN",
	"ELEVEN",
	"TWELVE",
	"THIRTEEN",
	"FOURTEEN",
	"FIFTEEN",
	"SIXTEEN",
	"SEVENTEEN",
	"EIGHTEEN",
	"NINETEEN",
}

local words_tens = {
	"",
	"TWENTY",
	"THIRTY",
	"FORTY",
	"FIFTY",
	"SIXTY",
	"SEVENTY",
	"EIGHTY",
	"NINETY",
}

local words_magnitudes = {
	"HUNDRED",
	"THOUSAND",
	"MILLION",
}

minislots.player_last_machine_def = {}
minislots.player_last_machine_pos = {}

-- Mod storage: used for maintenance flag, player sound prefs, etc.
-- Must be obtained at load time; core.get_mod_storage() is not valid in callbacks.
local minislots_storage = core.get_mod_storage()

-- Per-player mute preference (persisted in mod storage under "snd_mute_<name>").
-- Active spin-loop sound handles, keyed by core.hash_node_position(pos).
local spin_handles = {}

function minislots.is_player_muted(name)
	return minislots_storage:get_string("snd_mute_"..name) == "true"
end

function minislots.set_player_mute(name, muted)
	minislots_storage:set_string("snd_mute_"..name, muted and "true" or "false")
end

-- Play a sound directly to a specific player (not spatial/positional).
-- Using to_player ensures the sound reaches the player regardless of their
-- physical distance from the machine node. Silent if the player has muted.
-- Returns the sound handle (or nil if muted).
function minislots.play_sound(player_name, snd_name, pos, looped)
	if minislots.is_player_muted(player_name) then return nil end
	return core.sound_play(snd_name, {
		to_player = player_name,
		gain = 1.0,
		loop = looped or false,
	})
end

-- Stop the spinning sound loop for a machine at pos.
function minislots.stop_spin_sound(pos)
	local key = core.hash_node_position(pos)
	if spin_handles[key] then
		core.sound_stop(spin_handles[key])
		spin_handles[key] = nil
	end
end

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	local pos = minislots.player_last_machine_pos[name]
	if pos then minislots.stop_spin_sound(pos) end
	minislots.player_last_machine_def[name] = nil
	minislots.player_last_machine_pos[name] = nil
end)

function minislots.spin_reels(def)
	local spin = {[1] = {}, [2] = {}, [3] = {}}
	for reel = 1, def.constants.numreels do
		local n = math.random(2, def.constants.numsymbols*2+1)/2
		if math.random(1, 100) >= def.half_stops_weight then n = math.floor(n) end

-- force a mixed-7's win, 3-reel
--		local n = 3
--		if reel == 2 then n = 10 end
--		if reel == 3 then n = 14 end

-- force a mixed-7's win, 5-reel
--		local n = 3
--		if reel == 2 then n = 10 end
--		if reel == 3 then n = 3 end
--		if reel == 4 then n = 10 end
--		if reel == 5 then n = 14 end

-- force a mixed-7's win, 5-reel, but with one wild card on the mixed-7's payline
--		local n = 3
--		if reel == 2 then n = 10 end
--		if reel == 3 then n = 9 end
--		if reel == 4 then n = 10 end
--		if reel == 5 then n = 14 end

-- force the all-wilds win shown in the cabinet graphics, 3-reel
--		local n = 10
--		if reel == 2 then n = 9 end
--		if reel == 3 then n = 8 end

-- force the all-wilds win shown in the cabinet graphics, 5-reel
--		local n = 10
--		if reel == 3 then n = 9 end
--		if reel > 3 then n = 8 end

-- force a no-win spin
--		local n = 1
--		if reel == 2 then n = 4 end
--		if reel == 3 then n = 10 end

--		local n = 12 -- force a scatter win

--		local n = 16 -- force a bonus win + 3 line wins

		spin[1][reel] = {n-1, def.symbols[n-1]}
		spin[2][reel] = {n, def.symbols[n]}
		spin[3][reel] = {n+1, def.symbols[n+1]}
	end
	return spin
end

function minislots.reset_reels(def)
	local resetspin = {[1] = {}, [2] = {}, [3] = {}}
	for reel = 1, def.constants.numreels do
		resetspin[1][reel] = {0, def.symbols[0]}
		resetspin[2][reel] = {1, def.symbols[1]}
		resetspin[3][reel] = {2, def.symbols[2]}
	end
	return resetspin
end

function minislots.check_win(spin, def, maxlines)
	local allwins = {total = 0, line_wins_total = 0}
	local paylinecontent = {}
	allwins.scatter = {count = 0, pos = {}}
	allwins.bonus = {value = -1, count = 0, pos = {}}

	for payline,paylineoffsets in ipairs(def.lines) do
		local highestwin = nil
		local wildcount = 0
		if payline > maxlines then break end
		paylinecontent[payline] = {}

		for _,m in ipairs(def.matches) do
			local matchwin = true
			local wc = 0

			for reel = 1, def.constants.numreels do
				local row = paylineoffsets[reel]+2
				if not m[reel+1] or type(m[reel+1]) == "string" then
					paylinecontent[payline][reel] = spin[row][reel][2]
					if m[reel+1]
						and spin[row][reel][2] ~= m[reel+1]
						and (spin[row][reel][2] ~= "wild"
						or (spin[row][reel][2] == "wild"
							and def.wild_doesnt_match
							and def.wild_doesnt_match[m[reel+1]])) then
						matchwin = false
						break
					end
					if spin[row][reel][2] == "wild" then wc = wc + 1 end
				else
					local sublistmatch = false
					for e in ipairs(m[reel+1]) do
						paylinecontent[payline][reel] = spin[row][reel][2]
						if spin[row][reel][2] == m[reel+1][e] or (spin[row][reel][2] == "wild"
								and not (def.wild_doesnt_match and def.wild_doesnt_match[m[reel+1][e]])) then
							sublistmatch = true
						end
					end
					if not sublistmatch then
						matchwin = false
						break
					end
					if spin[row][reel][2] == "wild" then wc = wc + 1 end
				end
			end

			if matchwin and (not highestwin or m[1] > highestwin) then
				wildcount = wc
				highestwin = m[1]
			end
		end
		if highestwin then
			-- Applies the wild multiplier exponentially: each wild multiplies the win
			-- by wild_multiplier once. With multiplier=1 (current default) this is a no-op.
			-- Formula: value * (multiplier ^ wildcount). Example: multiplier=2, 2 wilds -> 4x.
			if wildcount > 0 then highestwin = highestwin * (def.wild_multiplier ^ wildcount) end
			table.insert(allwins, {payline = payline, value = highestwin, symbols = paylinecontent[payline]})
		end
	end

	for row = 1, 3 do
		for reel = 1, def.constants.numreels do
			if spin[row][reel][2] == "scatter" then
				allwins.scatter.count = allwins.scatter.count + 1
				table.insert(allwins.scatter.pos, {reel, row} )
			elseif spin[row][reel][2] == "bonus" then
				allwins.bonus.count = allwins.bonus.count + 1
				table.insert(allwins.bonus.pos, {reel, row} )
			end
		end
	end

	if #allwins > 0 then
		for _, win in ipairs(allwins) do
			allwins.line_wins_total = allwins.line_wins_total + win.value
		end
	end

	return allwins
end

local horizscale = 0.805	-- scaling to apply to any position values that need it (will be most)
local vertscale = 0.867
local hanchor = 0.23		-- the position of (0,0) relative to the upper-left formspec corner
local vanchor = 0.24
local pix2iu = 0.0175
local spincouthelp_scalex = 0.8455
local spincouthelp_scaley = 1.0241

function minislots.register_machine(mdef)
	local mdef_copy = table.copy(mdef)
	mdef_copy.constants = {}

	mdef_copy.constants.cashout_screen_ctrx = (mdef_copy.geometry.base_user_interface_width/2)*horizscale - hanchor
	mdef_copy.constants.cashoutticketimg_posx = (mdef_copy.geometry.base_user_interface_width/2 - 4)*horizscale - hanchor

	mdef_copy.constants.form_header = "size["..(mdef_copy.geometry.base_user_interface_width*0.785)..","..
								((mdef_copy.geometry.upper_section_height+mdef_copy.geometry.lower_section_height)*0.823).."]"
	mdef_copy.constants.mainpref = "image[-"..hanchor..",-"..vanchor..";"..
								mdef_copy.geometry.base_user_interface_width..","..mdef_copy.geometry.upper_section_height..";"
	mdef_copy.constants.screenposx = mdef_copy.geometry.screen_posx * horizscale - hanchor
	mdef_copy.constants.screenposy = mdef_copy.geometry.screen_posy * vertscale - vanchor
	mdef_copy.constants.lscrnpref = "image["..mdef_copy.constants.screenposx

	mdef_copy.constants.lscrnypos1 = ","..(mdef_copy.constants.screenposy)..";"
	mdef_copy.constants.lscrnypos2 = ","..(mdef_copy.constants.screenposy + mdef_copy.geometry.screen_line_height * vertscale)..";"

	mdef_copy.constants.cslotposx = mdef_copy.geometry.cash_slot_posx * horizscale - hanchor
	mdef_copy.constants.cslotposy = mdef_copy.geometry.cash_slot_posy * vertscale - vanchor
	mdef_copy.constants.cslotbtnszx = mdef_copy.geometry.cash_slot_sizex * spincouthelp_scalex
	mdef_copy.constants.cslotbtnszy = mdef_copy.geometry.cash_slot_sizey * spincouthelp_scaley

	mdef_copy.constants.spincoutposx = mdef_copy.geometry.spin_cashout_posx * horizscale - hanchor
	mdef_copy.constants.spinposy = mdef_copy.geometry.button_rows_posy * vertscale - vanchor
	mdef_copy.constants.coutposy = (mdef_copy.geometry.button_rows_posy
								+ mdef_copy.geometry.main_button_spacing) * vertscale - vanchor
	mdef_copy.constants.spincoutsizex = mdef_copy.geometry.main_button_size*2
	mdef_copy.constants.spincoutsizey = mdef_copy.geometry.main_button_size
	mdef_copy.constants.spincoutbtnszx = mdef_copy.constants.spincoutsizex * 0.91
	mdef_copy.constants.spincoutbtnszy = mdef_copy.constants.spincoutsizey * 1.05

	mdef_copy.constants.helpposx = mdef_copy.geometry.button_help_posx * horizscale - hanchor
	mdef_copy.constants.helpposy = mdef_copy.geometry.button_help_posy * vertscale - vanchor
	mdef_copy.constants.helpbtnsizex = mdef_copy.geometry.button_help_sizex * spincouthelp_scalex
	mdef_copy.constants.helpbtnposy = mdef_copy.geometry.button_help_sizey * spincouthelp_scaley

	mdef_copy.constants.reelspc = mdef_copy.geometry.reel_sizex*1.3333
	mdef_copy.constants.highlightboxszx = mdef_copy.geometry.reel_sizex*1.3333
	mdef_copy.constants.highlightboxszy = mdef_copy.geometry.reel_sizey/3*1.3333
	mdef_copy.constants.highlightboxoffsx = 1-(mdef_copy.geometry.reel_sizex/6)
	mdef_copy.constants.highlightboxoffsy = 1-(mdef_copy.geometry.reel_sizey/18)

	mdef_copy.constants.screenlnht2 = mdef_copy.geometry.screen_line_height * 0.6667
	mdef_copy.constants.screenlnht3 = mdef_copy.geometry.screen_line_height * 0.3333
	mdef_copy.constants.digitmed = mdef_copy.geometry.digit_glyph_sizex * 0.45
	mdef_copy.constants.digitsm = mdef_copy.geometry.digit_glyph_sizex * 0.4
	mdef_copy.constants.lscrnypos3 = ","..(mdef_copy.constants.screenposy + (mdef_copy.geometry.screen_line_height + mdef_copy.constants.screenlnht2) * vertscale)..";"
	mdef_copy.constants.medlblsz1 = mdef_copy.geometry.label_medium_sizex..","..mdef_copy.geometry.screen_line_height..";"
	mdef_copy.constants.medlblsz2 = mdef_copy.geometry.label_medium_sizex..","..mdef_copy.constants.screenlnht2..";"
	mdef_copy.constants.posy3 = mdef_copy.constants.screenposy + (mdef_copy.geometry.screen_line_height + mdef_copy.constants.screenlnht2) * vertscale
	mdef_copy.constants.lnwinlblsz = mdef_copy.geometry.line_win_label_sizex..","..mdef_copy.constants.screenlnht3..";"
	mdef_copy.constants.parensize = mdef_copy.geometry.digit_glyph_sizex/4
	mdef_copy.constants.parenlblsz = mdef_copy.constants.parensize..","..mdef_copy.constants.screenlnht3..";"
	mdef_copy.constants.ln3dig = mdef_copy.geometry.digit_glyph_sizex/4

	mdef_copy.constants.numreels = #mdef_copy.lines[1]
	mdef_copy.constants.numsymbols = #mdef_copy.symbols
	mdef_copy.symbols[#mdef_copy.symbols+1] = mdef_copy.symbols[1]
	mdef_copy.symbols[0] = mdef_copy.symbols[mdef_copy.constants.numsymbols]

	mdef_copy.constants.fast_med_cutover = mdef_copy.cutover_frames*2
	mdef_copy.constants.med_slow_cutover = mdef_copy.constants.fast_med_cutover + mdef_copy.cutover_frames*2
	mdef_copy.constants.slow_stop_cutover = mdef_copy.constants.med_slow_cutover + mdef_copy.cutover_frames*2
	mdef_copy.constants.last_step = mdef_copy.inter_reel_steps * (mdef_copy.constants.numreels-1) + mdef_copy.constants.slow_stop_cutover
	mdef_copy.constants.reel_wraparound_buf = mdef_copy.constants.numsymbols*10

	mdef_copy.constants.basename			= "minislots_"..mdef_copy.name.."_"

	mdef_copy.constants.emptyimg			= "minislots_empty_img.png"

	mdef_copy.constants.reelimg 			= mdef_copy.constants.basename.."reel_background.png"
	mdef_copy.constants.reelshadowimg		= ":0,0="..mdef_copy.constants.basename.."reel_shadow.png]"
	mdef_copy.constants.scatterhlimg		= mdef_copy.constants.highlightboxszx..","..mdef_copy.constants.highlightboxszy..";"..
										mdef_copy.constants.basename.."highlight_scatter.png]"
	mdef_copy.constants.bonushlimg		= mdef_copy.constants.highlightboxszx..","..mdef_copy.constants.highlightboxszy..";"..
										mdef_copy.constants.basename.."highlight_bonus.png]"
	mdef_copy.constants.cashslotscrnbg	= mdef_copy.constants.basename.."cash_slot_screen_background.png"
	mdef_copy.constants.paytablescrnbg	= mdef_copy.constants.basename.."paytable_bg.png"
	mdef_copy.constants.paylinescrnbg		= mdef_copy.constants.basename.."payline_bg.png"
	mdef_copy.constants.lines_bg			= mdef_copy.constants.basename.."paytable_lines_bg.png"

	mdef_copy.constants.symbolsfast		= mdef_copy.constants.basename.."reel_symbols_fast.png"
	mdef_copy.constants.symbolsmedium		= mdef_copy.constants.basename.."reel_symbols_medium.png"
	mdef_copy.constants.symbolsslow		= mdef_copy.constants.basename.."reel_symbols_slow.png"
	mdef_copy.constants.symbolsstopped	= mdef_copy.constants.basename.."reel_symbols_stopped.png"

	mdef_copy.constants.ballabelimg		= mdef_copy.constants.basename.."label_balance.png]"
	mdef_copy.constants.betlabelimg		= mdef_copy.constants.basename.."label_bet.png]"
	mdef_copy.constants.winlabelimg		= mdef_copy.constants.basename.."label_win.png]"
	mdef_copy.constants.linewinlabelimg	= mdef_copy.constants.basename.."label_linewin.png]"
	mdef_copy.constants.scatterwinlabelimg = mdef_copy.geometry.scatter_win_label_sizex..","..mdef_copy.constants.screenlnht3..";"..mdef_copy.constants.basename.."label_scatterwin.png]"
	mdef_copy.constants.bonuswinlabelimg	= mdef_copy.geometry.bonus_win_label_sizex..","..mdef_copy.constants.screenlnht3..";"..mdef_copy.constants.basename.."label_bonuswin.png]"
	mdef_copy.constants.curlabelimg		= ";"..mdef_copy.constants.basename.."label_currency.png"

	mdef_copy.constants.lparenimg			= mdef_copy.constants.basename.."glyph_lparen.png]"
	mdef_copy.constants.rparenimg			= mdef_copy.constants.basename.."glyph_rparen.png]"
	mdef_copy.constants.colonimg			= mdef_copy.constants.basename.."glyph_colon.png]"

	mdef_copy.constants.lnbetpref			= mdef_copy.geometry.main_button_size..","..mdef_copy.geometry.main_button_size..";"

	mdef_copy.constants.behindreels		= mdef_copy.constants.mainpref..mdef_copy.constants.basename.."behind_reels.png]"
	mdef_copy.constants.overlay_upper 	= mdef_copy.constants.mainpref..mdef_copy.constants.basename.."overlay_upper.png]"

	mdef_copy.constants.buttonspin		= "image["..mdef_copy.constants.spincoutposx..","..mdef_copy.constants.spinposy..";"..
										mdef_copy.constants.spincoutsizex..","..mdef_copy.constants.spincoutsizey..";"..
										mdef_copy.constants.basename.."button_spin.png]"..
										"image_button["..mdef_copy.constants.spincoutposx..","..mdef_copy.constants.spinposy..
										";"..mdef_copy.constants.spincoutbtnszx..","..mdef_copy.constants.spincoutbtnszy..";"..
										mdef_copy.constants.emptyimg..";spin;]"
	mdef_copy.constants.buttonspin_dis	= "image["..mdef_copy.constants.spincoutposx..","..mdef_copy.constants.spinposy..";"..
										mdef_copy.constants.spincoutsizex..","..mdef_copy.constants.spincoutsizey..";"..
										mdef_copy.constants.basename.."button_spin_dis.png]"

	mdef_copy.constants.buttoncashout		= "image["..mdef_copy.constants.spincoutposx..","..mdef_copy.constants.coutposy..";"..
										mdef_copy.constants.spincoutsizex..","..mdef_copy.constants.spincoutsizey..";"..
										mdef_copy.constants.basename.."button_cash_out.png]"..
										"image_button["..mdef_copy.constants.spincoutposx..","..mdef_copy.constants.coutposy..";"..
										mdef_copy.constants.spincoutbtnszx..","..mdef_copy.constants.spincoutbtnszy..";"..
										mdef_copy.constants.emptyimg..";cout;]"
	mdef_copy.constants.buttoncashout_dis = "image["..mdef_copy.constants.spincoutposx..","..mdef_copy.constants.coutposy..";"..
										mdef_copy.constants.spincoutsizex..","..mdef_copy.constants.spincoutsizey..";"..
										mdef_copy.constants.basename.."button_cash_out_dis.png]"

	mdef_copy.constants.buttonquit		= "image["..mdef_copy.constants.spincoutposx..","..mdef_copy.constants.coutposy..";"..
										mdef_copy.constants.spincoutsizex..","..mdef_copy.constants.spincoutsizey..";"..
										mdef_copy.constants.basename.."button_quit.png]"..
										"image_button_exit["..mdef_copy.constants.spincoutposx..","..mdef_copy.constants.coutposy..";"..
										mdef_copy.constants.spincoutbtnszx..","..mdef_copy.constants.spincoutbtnszy..";"..
										mdef_copy.constants.emptyimg..";quit;]"

	mdef_copy.constants.buttoncashslot	= "image["..mdef_copy.constants.cslotposx..","..mdef_copy.constants.cslotposy..";"..
										mdef_copy.geometry.cash_slot_sizex..","..mdef_copy.geometry.cash_slot_sizey..";"..
										mdef_copy.constants.basename.."cash_slot.png]"..
										"image_button["..mdef_copy.constants.cslotposx..","..mdef_copy.constants.cslotposy..";"..
										mdef_copy.constants.cslotbtnszx..","..mdef_copy.constants.cslotbtnszy..";"..
										mdef_copy.constants.emptyimg..";cslot;]"

	mdef_copy.constants.buttoncashslot_dis = "image["..mdef_copy.constants.cslotposx..","..mdef_copy.constants.cslotposy..";"..
										mdef_copy.geometry.cash_slot_sizex..","..mdef_copy.geometry.cash_slot_sizey..";"..
										mdef_copy.constants.basename.."cash_slot.png]"

	mdef_copy.constants.button_close = "minislots_close_button.png"

	mdef_copy.constants.buttonhelp		= "image["..mdef_copy.constants.helpposx..","..mdef_copy.constants.helpposy..";"..
										mdef_copy.geometry.button_help_sizex..","..mdef_copy.geometry.button_help_sizey..";"..
										mdef_copy.constants.basename.."button_help.png]"..
										"image_button["..mdef_copy.constants.helpposx..","..mdef_copy.constants.helpposy..";"..
										mdef_copy.constants.helpbtnsizex..","..mdef_copy.constants.helpbtnposy..";"..
										mdef_copy.constants.emptyimg..";help;]"

	mdef_copy.constants.buttonhelp_dis	= "image["..mdef_copy.constants.helpposx..","..mdef_copy.constants.helpposy..";"..
										mdef_copy.geometry.button_help_sizex..","..mdef_copy.geometry.button_help_sizey..";"..
										mdef_copy.constants.basename.."button_help.png]"

	mdef_copy.constants.reelsymsizex		= mdef_copy.geometry.reel_sizex*64
	mdef_copy.constants.reelsymsizey		= mdef_copy.geometry.reel_sizey/3*64

	mdef_copy.constants.reelcombinepref	= ","..(mdef_copy.geometry.reel_posy*vertscale-vanchor)..";"..
										(mdef_copy.geometry.reel_sizex)..","..(mdef_copy.geometry.reel_sizey)..";"..
										mdef_copy.constants.reelimg..
										"^[combine:"..mdef_copy.constants.reelsymsizex.."x"..
										mdef_copy.constants.reelsymsizey

	mdef_copy.constants.reelunderlightpref = mdef_copy.constants.basename.."reel_underlight_"
	mdef_copy.constants.overlaylinepref	= mdef_copy.constants.basename.."overlay_line_"
	mdef_copy.constants.overlay_lower		= "image[-"..hanchor..","..(11*vertscale-vanchor)..";"..
										mdef_copy.geometry.base_user_interface_width..","..mdef_copy.geometry.lower_section_height..";"..
										mdef_copy.constants.basename.."overlay_lower.png]"

	mdef_copy.constants.upperbezel		= mdef_copy.constants.mainpref.."minislots_golden7s_overlay_upper_bezel.png]"
	mdef_copy.constants.cashoutbackground	= mdef_copy.constants.mainpref.."minislots_blue_img.png]"
	mdef_copy.constants.cashoutticketimg	= "image["..mdef_copy.constants.cashoutticketimg_posx..","..(3.5-vanchor)..
										";8,3;minislots_cashout_ticket.png]"

	mdef_copy.constants.paylinestable_pref = "image_button[8.85,10.28;2,0.5;"
	mdef_copy.constants.button_showpaytable = mdef_copy.constants.paylinestable_pref..mdef_copy.constants.basename..
										"button_show_paytable.png;showpaytable;]"
	mdef_copy.constants.button_showpaylines = mdef_copy.constants.paylinestable_pref..mdef_copy.constants.basename..
										"button_show_paylines.png;showpaylines;]"

	mdef_copy.constants.buttonadmin = "image["..
								((mdef_copy.geometry.cash_slot_posx - mdef_copy.constants.cslotbtnszy - 0.02)* horizscale - hanchor)..","..
								(mdef_copy.geometry.cash_slot_posy * vertscale - vanchor)..";"..
								mdef_copy.constants.cslotbtnszy..","..mdef_copy.constants.cslotbtnszy..
								";minislots_button_admin.png]"..
								"image_button["..
								((mdef_copy.geometry.cash_slot_posx - mdef_copy.constants.cslotbtnszy - 0.02)* horizscale - hanchor)..","..
								(mdef_copy.geometry.cash_slot_posy * vertscale - vanchor)..";"..
								mdef_copy.constants.cslotbtnszy..","..mdef_copy.constants.cslotbtnszy..
								";"..mdef_copy.constants.emptyimg..";admin;]"

	mdef_copy.constants.buttonadmin_dis = "image["..
								((mdef_copy.geometry.cash_slot_posx - mdef_copy.constants.cslotbtnszy - 0.02)* horizscale - hanchor)..","..
								(mdef_copy.geometry.cash_slot_posy * vertscale - vanchor)..";"..
								mdef_copy.constants.cslotbtnszy..","..mdef_copy.constants.cslotbtnszy..
								";minislots_button_admin.png]"


	mdef_copy.constants.buttons_n_lines = {}
	mdef_copy.constants.buttons_bet_n = {}

	for i, value in ipairs(mdef_copy.linebuttons) do
		mdef_copy.constants.buttons_n_lines[value] = {}
		local posx = ((mdef_copy.geometry.button_rows_posx
						+ (i-1)*mdef_copy.geometry.main_button_spacing) * horizscale - hanchor)

		for _, state in ipairs( {"dis", "off", "on"} ) do
			local btn = "image["..posx..","..mdef_copy.constants.spinposy..";"..
				mdef_copy.constants.lnbetpref..mdef_copy.constants.basename.."button_lines_"..state.."_"..value..".png]"
			if state ~= "dis" then
				btn = btn.."image_button["..posx..","..mdef_copy.constants.spinposy..";"..
				mdef_copy.constants.lnbetpref.."minislots_empty_img.png;lines_"..value..";]"
			end
			mdef_copy.constants.buttons_n_lines[value][state] = btn
		end
	end

	for i, value in ipairs(mdef_copy.betbuttons) do
		mdef_copy.constants.buttons_bet_n[value] = {}

		local posx = ((mdef_copy.geometry.button_rows_posx
						+ (i-1)*mdef_copy.geometry.main_button_spacing) * horizscale - hanchor)

		for _, state in ipairs( {"dis", "off", "on"} ) do
			local btn = "image["..posx..","..mdef_copy.constants.coutposy..";"..
				mdef_copy.constants.lnbetpref..mdef_copy.constants.basename.."button_bet_"..state.."_"..value..".png]"
			if state ~= "dis" then
				btn = btn.."image_button["..posx..","..mdef_copy.constants.coutposy..";"..
				mdef_copy.constants.lnbetpref.."minislots_empty_img.png;bet_"..value..";]"
			end
			mdef_copy.constants.buttons_bet_n[value][state] = btn
		end
	end

	mdef_copy.constants.digits = {}
	for i = 0, 9 do
		mdef_copy.constants.digits[tostring(i)] = mdef_copy.constants.basename.."glyph_digit_"..i..".png"
	end

	mdef_copy.constants.symlookup = {}
	for num,sym in ipairs(mdef_copy.symbols) do
		mdef_copy.constants.symlookup["sym_"..sym] = num
	end

	local mesh = ""
	local cbox = {}

	if mdef_copy.machine_shape == "upright" then
		mesh = "minislots_generic_machine_upright.obj"
		cbox = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
				{-0.5, 0.5, -0.1875, 0.5, 1.5, 0.5},
			}
		}
	elseif mdef_copy.machine_shape == "upright_big" then
		mesh = "minislots_generic_machine_upright_big.obj"
		cbox = {
			type = "fixed",
			fixed = {-1, -0.5, -0.5, 1.5, 3.5, 1.5}
		}
	end

	core.register_node(":minislots:"..mdef_copy.name, {
		description = mdef_copy.description,
		drawtype = "mesh",
		mesh = mesh,
		tiles = {"minislots_"..mdef_copy.name.."_cabinet_graphics.png"},
		node_box = cbox, -- this is used to create proper collision info.
		paramtype2 = "facedir",
		selection_box = cbox,
		is_ground_content = false,
		groups = {cracky = 1, level = 2},
		sounds = default.node_sound_metal_defaults(),
		machine_def = table.copy(mdef_copy),
		on_timer = minislots.cycle_states,
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			local meta = core.get_meta(pos)
			local player_name = clicker:get_player_name()
			local oldform = meta:get_string("formspec")
			local balance = meta:get_int("balance")
			local def = core.registered_items[node.name].machine_def

			-- global maintenance flag: non-admins get the maintenance screen.
			-- The playable UI lives in the node's formspec metadata and is
			-- opened by the client on right-click *before* this callback runs,
			-- so we overwrite that metadata with the maintenance screen and
			-- re-show it to guarantee the player can't see or use the game.
			if not minislots.is_enabled() then
				if not core.check_player_privs(player_name, {server = true}) then
					meta:set_string("formspec", minislots.generate_maintenance_screen())
					core.show_formspec(player_name, "minislots:maintenance",
						minislots.generate_maintenance_screen())
					core.chat_send_player(player_name,
						"This machine is currently down for maintenance.")
					return
				else
					-- make the bypass visible so admins don't mistake it
					-- for the disable not working
					core.chat_send_player(player_name,
						"[Minislots] Maintenance mode is ACTIVE. You are able to "..
						"use this machine only because you have the server privilege; "..
						"regular players are locked out.")
				end
			end

			minislots.player_last_machine_def[player_name] = def
			minislots.player_last_machine_pos[player_name] = pos

			if not string.find(oldform, "locked-out") then
				local state = meta:get_string("state")
				if state ~= "stopped" then
					if string.find(state, "win") and not core.get_node_timer(pos):is_started() then
						-- the machine got stuck showing a win (e.g. its timer
						-- died); wins are always credited before a win state
						-- is entered, so it's safe to reset it to idle
						state = "stopped"
						meta:set_string("state", state)
					else
						return
					end
				end
				-- Always regenerate the stored formspec on right-click of an idle
				-- machine. This guarantees the current UI (including the sound
				-- mute button) is present even on machines whose stored formspec
				-- predates a mod update.
				local spin = core.deserialize(meta:get_string("spin"))
				local linebet = meta:get_int("linebet")
				local maxlines = meta:get_int("maxlines")
				meta:set_string("last_right_clicker", clicker:get_player_name())
				meta:set_string("formspec",
					minislots.generate_display(def, {
						state = state,
						spin = spin,
						allwins = {},
						balance = balance,
						linebet = linebet,
						maxlines = maxlines,
						pos = pos,
						player_name = player_name,
						admin = default.can_interact_with_node(clicker, pos)
					})
				)
			elseif meta:get_string("owner") == player_name then
				core.get_node_timer(pos):stop()
				core.show_formspec(player_name, "minislots:admin_form",
					minislots.generate_admin_form(def, pos, balance))
				return
			end
		end,
		on_construct = function(pos)
			local node = core.get_node(pos)
			local def = core.registered_items[node.name].machine_def
			local meta = core.get_meta(pos)
			local resetspin = minislots.reset_reels(def)
			local balance = 0
			local linebet = 1
			local maxlines = 1
			local emptywins = {
				scatter = {count = 0, pos = {}},
				bonus = {value = -1, count = 0, pos = {}}
			}
			meta:set_int("balance", balance)
			meta:set_int("last_cashout", 0)
			meta:set_int("linebet", linebet)
			meta:set_int("maxlines", maxlines)
			meta:set_int("bonus_result", -1)
			meta:set_string("state", "stopped")
			meta:set_string("spin", core.serialize(resetspin))
			meta:set_int("spin_timestamp", os.time())

			meta:set_string("install_date", os.date())
			meta:set_int("spin_count", 0)
			meta:set_int("money_in", 0)
			meta:set_int("money_out", 0)
			meta:set_int("total_bets", 0)
			meta:set_int("total_wins", 0)
			meta:set_int("scatter_hits", 0)
			meta:set_int("bonus_hits", 0)

			meta:set_string("casino_name", "LocalGames Casino/Hotel")

			meta:set_string("allwins", core.serialize(emptywins))
			meta:mark_as_private({
				"balance",
				"last_cashout",
				"linebet",
				"maxlines",
				"bonus_result",
				"state",
				"spin",
				"spin_timestamp",
				"allwins",
				"casino_name",
				"install_date",
				"spin_count",
				"money_in",
				"money_out",
				"total_bets",
				"total_wins",
				"scatter_hits",
				"bonus_hits"
			})

			local inv = meta:get_inventory()
			inv:set_size("main", 1)
		end,
		on_dig = function(pos, node, digger)
			local def = core.registered_items[node.name].machine_def
			local player_name = digger:get_player_name()
			if default.can_interact_with_node(digger, pos) then
				local stack = ItemStack("minislots:"..def.name)
				local nodemeta = core.get_meta(pos)
				local stackmeta = stack:get_meta()

				local balance = nodemeta:get_int("balance") or 0
				local casino = nodemeta:get_string("casino_name")
				stackmeta:set_int("balance", balance)
				stackmeta:set_string("casino_name", casino)
				stackmeta:set_int("last_cashout", nodemeta:get_int("last_cashout"))
				stackmeta:set_string("install_date", nodemeta:get_string("install_date"))
				stackmeta:set_int("spin_count", nodemeta:get_int("spin_count"))
				stackmeta:set_int("money_in", nodemeta:get_int("money_in"))
				stackmeta:set_int("money_out", nodemeta:get_int("money_out"))
				stackmeta:set_int("total_bets", nodemeta:get_int("total_bets"))
				stackmeta:set_int("total_wins", nodemeta:get_int("total_wins"))
				stackmeta:set_int("scatter_hits", nodemeta:get_int("scatter_hits"))
				stackmeta:set_int("bonus_hits", nodemeta:get_int("bonus_hits"))
				stackmeta:set_string("description",
					def.description.."\n(balance: "..balance.." Mg;\ncasino: "..casino..")")
				local inv = digger:get_inventory()
				if inv:room_for_item("main", stack) then
					if (not creative or not creative.is_enabled_for(player_name))
						or (creative and creative.is_enabled_for(player_name)
							and not inv:contains_item("main", stack, true)) then
							inv:add_item("main", stack)
					end
					core.remove_node(pos)
				end
			end
		end,
		after_place_node = function(pos, placer, itemstack)
			local node = core.get_node(pos)
			local def = core.registered_items[node.name].machine_def
			local nodemeta = core.get_meta(pos)
			local player_name = placer:get_player_name()
			local stackmeta = itemstack:get_meta()

			local resetspin = minislots.reset_reels(def)
			local linebet = 1
			local maxlines = 1
			local emptywins = {
				scatter = {count = 0, pos = {}},
				bonus = {value = -1, count = 0, pos = {}}
			}
			local casino = stackmeta:get_string("casino_name")

			-- get_meta() never returns nil; `if stackmeta then` was dead code.
			-- Stats are always restored from the item metadata.
			local balance = stackmeta:get_int("balance")
			nodemeta:set_int("balance", balance)

			if casino ~= "" then
				nodemeta:set_string("casino_name", casino)
			end
			nodemeta:set_int("last_cashout", stackmeta:get_int("last_cashout"))
			nodemeta:set_int("spin_count", stackmeta:get_int("spin_count"))
			nodemeta:set_int("money_in", stackmeta:get_int("money_in"))
			nodemeta:set_int("money_out", stackmeta:get_int("money_out"))
			nodemeta:set_int("total_bets", stackmeta:get_int("total_bets"))
			nodemeta:set_int("total_wins", stackmeta:get_int("total_wins"))
			nodemeta:set_int("scatter_hits", stackmeta:get_int("scatter_hits"))
			nodemeta:set_int("bonus_hits", stackmeta:get_int("bonus_hits"))
			nodemeta:set_string("owner", player_name)
			nodemeta:set_string("infotext", def.description.."\nOwned by "..player_name)
			nodemeta:set_string("formspec",
				minislots.generate_display(def, {
					state = "stopped",
					spin = resetspin,
					allwins = emptywins,
					balance = balance,
					linebet = linebet,
					maxlines = maxlines,
					admin = default.can_interact_with_node(placer, pos)
				})
			)
		end,
		can_dig = function(pos, player)
			return default.can_interact_with_node(player, pos)
		end,
		on_metadata_inventory_put = function(pos, listname, index, stack, player)
			local node = core.get_node(pos)
			local def = core.registered_items[node.name].machine_def
			local player_name = player:get_player_name()
			local meta = core.get_meta(pos)
			local state = meta:get_string("state")
			local spin = core.deserialize(meta:get_string("spin"))
			local balance = meta:get_int("balance")
			local linebet = meta:get_int("linebet")
			local maxlines = meta:get_int("maxlines")
			local timer = core.get_node_timer(pos)
			local inv = meta:get_inventory()
			inv:remove_item("main", stack)
			if state ~= "stopped" and not string.find(state, "win") then
				-- money arrived while the reels are moving (the intake form
				-- can stay open across spins); the balance was already
				-- credited in allow_metadata_inventory_put, so just accept
				-- it without disturbing the running machine
				core.show_formspec(player_name, "minislots:cash_intake",
					minislots.generate_cashslot_form(def, pos, balance, player_name))
				return
			end
			timer:stop()
			state = "stopped"
			meta:set_string("state", state)
			meta:set_string("formspec",
				minislots.generate_display(def, {
					state = state,
					spin = spin,
					allwins = {},
					balance = balance,
					linebet = linebet,
					maxlines = maxlines,
					player_name = player_name,
					admin = default.can_interact_with_node(player, pos)
				})
			)
			core.show_formspec(player_name, "minislots:cash_intake",
				minislots.generate_cashslot_form(def, pos, balance, player_name))
		end,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			-- refuse money while the machine is in maintenance
			if not minislots.is_enabled() then return 0 end
			local node = core.get_node(pos)
			local def = core.registered_items[node.name].machine_def
			local meta = core.get_meta(pos)
			local sn = stack:get_name()
			local mg
			if string.find(sn, "currency:minegeld") and not string.find(sn, "bundle") then
				if not string.find(sn, "cent") then
					mg = tonumber(string.sub(sn, 19))
					if not mg then mg = 1 end
				else
					mg = tonumber(string.sub(sn, 24)) / 100
				end
				if mg < def.currency_min or mg > def.currency_max then return 0 end
				local balance = meta:get_int("balance")
				local headroom = def.maxbalance - balance
				if headroom > 0 then
					-- allow only as many items as fit without overflowing maxbalance
					local allowed = math.min(stack:get_count(), math.floor(headroom / mg))
					if allowed > 0 then
						local amount = mg * allowed
						balance = balance + amount
						meta:set_int("balance", balance)
						meta:set_int("money_in", meta:get_int("money_in") + amount)
						-- coin insert sound
						local pname = player:get_player_name()
						minislots.play_sound(pname, "minislots_coin_insert", pos, false)
						return allowed
					end
				end
			end
			return 0
		end,
		on_receive_fields = function(pos, formname, fields, sender)
			local node = core.get_node(pos)
			local def = core.registered_items[node.name].machine_def
			local player_name = sender:get_player_name()
			local meta = core.get_meta(pos)
			local state = meta:get_string("state")
			local spin = core.deserialize(meta:get_string("spin"))
			local balance = meta:get_int("balance")
			local linebet = meta:get_int("linebet")
			local maxlines = meta:get_int("maxlines")
			local timer = core.get_node_timer(pos)

			-- extract "bet_<n>" / "lines_<n>" button presses directly from
			-- the field names (the old method of string-parsing the output
			-- of core.serialize() broke when the serializer was rewritten)
			local newlinebet
			local newmaxlines
			for k in pairs(fields) do
				newlinebet = newlinebet or tonumber(string.match(k, "^bet_(%d+)$"))
				newmaxlines = newmaxlines or tonumber(string.match(k, "^lines_(%d+)$"))
			end

			-- true when the machine is idle or just cycling through winning
			-- lines (wins are always credited before a win state is entered),
			-- i.e. when it's safe to accept bets, spins, or cash-outs.
			-- Note: the timer is deliberately NOT stopped globally here, only
			-- in the branches that actually change the machine's state --
			-- otherwise a stray formspec event mid-spin would freeze the
			-- machine and eat the player's winnings.
			local at_rest = (state == "stopped") or (string.find(state, "win") ~= nil)

			-- refuse ALL game actions while in maintenance (non-admins). We also
			-- overwrite the stored formspec with the maintenance screen so the
			-- machine can't be reopened into a playable state, and swap the
			-- player's open form to the maintenance notice.
			if not minislots.is_enabled()
					and not core.check_player_privs(player_name, {server = true}) then
				-- allow the player to simply dismiss the maintenance screen
				if not (fields.quit or fields.close or fields.key_enter or fields.maint_mode_ok) then
					meta:set_string("formspec", minislots.generate_maintenance_screen())
					core.show_formspec(player_name, "minislots:maintenance",
						minislots.generate_maintenance_screen())
					core.chat_send_player(player_name,
						"This machine is currently down for maintenance.")
				end
				return
			end

			if fields.admin then
				if player_name == meta:get_string("owner") then
					timer:stop()
					meta:set_string("formspec", "size[4,1]"..
						"image_button_exit[3.65,-0.2;0.55,0.5;"..def.constants.button_close..";close;]"..
						"label[0.3,0.2;This machine has been locked-out by]"..
						"label[0.1,0.5;the Administrator. Please come back later.]")
					core.show_formspec(player_name, "minislots:admin_form",
						minislots.generate_admin_form(def, pos, balance))
					return
				end
			elseif fields.cslot then
				core.show_formspec(player_name, "minislots:cash_intake",
					minislots.generate_cashslot_form(def, pos, balance, player_name))
				return
			elseif fields.help then
				core.show_formspec(player_name, "minislots:help_screen",
					minislots.generate_paytable_form(def))
				return
			elseif fields.snd_mute then
				-- toggle this player's machine-sound mute flag. Only affects
				-- this mod's sounds (play_sound honors the flag); the player's
				-- Luanti client volume is untouched. We confirm via chat because
				-- the button lives in the shared node-meta formspec and cannot
				-- show per-player state in its label.
				local now_muted = not minislots.is_player_muted(player_name)
				minislots.set_player_mute(player_name, now_muted)
				core.chat_send_player(player_name, now_muted
					and "[Minislots] Machine sounds are now OFF for you."
					or  "[Minislots] Machine sounds are now ON for you.")
				return
			elseif fields.cout then
				if at_rest and balance > 0 and balance <= def.maxbalance then
					local last_cashout = balance
					local fifties = math.floor(last_cashout/50)
					local tens = math.floor((last_cashout - fifties*50)/10)
					local fives = math.floor((last_cashout - fifties*50 - tens*10)/5)
					local ones = math.floor(last_cashout - fifties*50 - tens*10 - fives*5)
					local inv = sender:get_inventory()
					-- only take the money out of the machine once we know the
					-- player can actually receive it, otherwise it would be
					-- destroyed when the player's inventory is full
					if (fifties == 0 or inv:room_for_item("main", "currency:minegeld_50 "..fifties))
						and (tens == 0 or inv:room_for_item("main", "currency:minegeld_10 "..tens))
						and (fives == 0 or inv:room_for_item("main", "currency:minegeld_5 "..fives))
						and (ones == 0 or inv:room_for_item("main", "currency:minegeld "..ones)) then

						if fifties > 0 then inv:add_item("main", "currency:minegeld_50 "..fifties) end
						if tens > 0 then inv:add_item("main", "currency:minegeld_10 "..tens) end
						if fives > 0 then inv:add_item("main", "currency:minegeld_5 "..fives) end
						if ones > 0 then inv:add_item("main", "currency:minegeld "..ones) end
						meta:set_int("money_out", meta:get_int("money_out")+last_cashout)

						timer:stop()
						local state = "stopped"
						local casino_name = meta:get_string("casino_name")
						balance = 0
						meta:set_string("state", state)
						meta:set_int("last_cashout", last_cashout)
						meta:set_int("balance", balance)
						meta:set_string("formspec",
							minislots.generate_display(def, {
								state = state,
								spin = spin,
								allwins = {},
								balance = balance,
								linebet = linebet,
								maxlines = maxlines,
								last_cashout = last_cashout,
								pos = pos,
								player_name = player_name,
								casino_name = casino_name,
								admin = default.can_interact_with_node(sender, pos)
							})
						)
					end
					return
				end
			elseif fields.quit then
				if not at_rest then
					-- the player closed the form while the reels were still
					-- moving; leave the machine alone so it can finish the
					-- spin and credit any winnings
					return
				end
				timer:stop()
				local state = "stopped"
				meta:set_string("state", state)
				local oldform = meta:get_string("formspec")
				if not string.find(oldform, "locked-out") then
					meta:set_string("formspec",
						minislots.generate_display(def, {
							state = state,
							spin = spin,
							allwins = {},
							balance = balance,
							linebet = linebet,
							maxlines = maxlines,
							admin = default.can_interact_with_node(sender, pos)
						})
					)
				end
				return
			elseif fields.spin then
				if at_rest then
					if (linebet*maxlines) > balance or balance > def.maxbalance then return end
					timer:stop()
					meta:set_int("spin_timestamp", os.time())
					local spin = minislots.spin_reels(def)
					local allwins = minislots.check_win(spin, def, maxlines)
					meta:set_string("spin", core.serialize(spin))
					meta:set_string("allwins", core.serialize(allwins))
					meta:set_string("state", "start")
					minislots.cycle_states(pos)
					return
				end
			elseif newlinebet then
				-- ignore bet changes while the reels are moving: a forged
				-- mid-spin "bet_n" field could otherwise multiply the payout
				-- of an already-determined spin (or double-start a spin)
				if not at_rest then return end
				local linebet = newlinebet
				if def.bet_initiates_spin then
					if maxlines*linebet > balance or balance > def.maxbalance then return end
					timer:stop()
					meta:set_int("linebet", linebet)
					meta:set_int("spin_timestamp", os.time())
					local spin = minislots.spin_reels(def)
					local allwins = minislots.check_win(spin, def, maxlines)
					meta:set_string("spin", core.serialize(spin))
					meta:set_string("allwins", core.serialize(allwins))
					meta:set_string("state", "start")
					minislots.cycle_states(pos)
					return
				else
					if maxlines*linebet <= balance then
						timer:stop()
						local state = "stopped"
						meta:set_string("state", state)
						meta:set_int("linebet", linebet)
						meta:set_string("formspec",
							minislots.generate_display(def, {
								state = state,
								spin = spin,
								allwins = {},
								balance = balance,
								linebet = linebet,
								maxlines = maxlines,
								showlines = true,
								admin = default.can_interact_with_node(sender, pos)
							})
						)
					end
				end
			elseif newmaxlines then
				if not at_rest then return end
				local maxlines = newmaxlines
				if maxlines*linebet <= balance then
					timer:stop()
					local state = "stopped"
					meta:set_string("state", state)
					meta:set_int("maxlines", maxlines)
					meta:set_string("formspec",
						minislots.generate_display(def, {
							state = state,
							spin = spin,
							allwins = {},
							balance = balance,
							linebet = linebet,
							maxlines = maxlines,
							showlines = true,
							admin = default.can_interact_with_node(sender, pos)
						})
					)
				end
			end
		end
	})
end


--###################
-- the state machine
--###################

function minislots.cycle_states(pos)
	local node = core.get_node(pos)
	local def = core.registered_items[node.name].machine_def
	local meta = core.get_meta(pos)
	local state = meta:get_string("state")
	local spin = core.deserialize(meta:get_string("spin"))
	local linebet = meta:get_int("linebet")
	local maxlines = meta:get_int("maxlines")
	local balance = meta:get_int("balance")
	local allwins = core.deserialize(meta:get_string("allwins"))
	local numscatter = (allwins and allwins.scatter and allwins.scatter.count) or 0
	local numbonus = (allwins and allwins.bonus and allwins.bonus.count) or 0
	local last_right_clicker = meta:get_string("last_right_clicker")
	local player = core.get_player_by_name(last_right_clicker)
	local admin = player and default.can_interact_with_node(player, pos)

	local timeout = 0

	if state == "start" then
		balance = meta:get_int("balance") - linebet*maxlines
		meta:set_int("balance", balance)
		meta:set_int("spin_count", meta:get_int("spin_count")+1)
		meta:set_int("total_bets", meta:get_int("total_bets")+linebet*maxlines)
		state = "spinning_fast_0"
		timeout = def.reel_fast_timeout
		-- start the spinning loop sound (stop any stale handle first so every
		-- spin begins from a clean state, then loop for the whole spin cycle)
		if last_right_clicker ~= "" then
			minislots.stop_spin_sound(pos)
			local key = core.hash_node_position(pos)
			spin_handles[key] = minislots.play_sound(last_right_clicker, "minislots_spin_loop", pos, true)
		end
	elseif string.find(state, "spinning_fast_") then
		local c = tonumber(string.sub(state, 15))
		c = c + 2
		if c >= def.constants.fast_med_cutover then
			state = "spinning_medm_"..def.constants.fast_med_cutover
			timeout = def.reel_medium_timeout
		else
			state = "spinning_fast_"..c
			timeout = def.reel_fast_timeout
		end
	elseif string.find(state, "spinning_medm_") then
		local c = tonumber(string.sub(state, 15))
		c = c + 2
		if c >= def.constants.med_slow_cutover then
			state = "spinning_slow_"..def.constants.med_slow_cutover
			timeout = def.reel_slow_timeout
		else
			state = "spinning_medm_"..c
			timeout = def.reel_medium_timeout
		end
	elseif string.find(state, "spinning_slow_") then
		local c = tonumber(string.sub(state, 15))
		c = c + 2
		if c >= def.constants.slow_stop_cutover then
			state = "reels_stopping_"..def.constants.slow_stop_cutover
			timeout = def.reel_slow_timeout
		else
			state = "spinning_slow_"..c
			timeout = def.reel_slow_timeout
		end
	elseif string.find(state, "reels_stopping_") then
		local sr = tonumber(string.sub(state, 16))
		-- Fire the stop sound once as each reel locks in. The spin loop keeps
		-- playing underneath (it is stopped later, once ALL reels have settled).
		-- Reels lock one per inter_reel_steps frames, starting at slow_stop_cutover.
		local steps_in = sr - def.constants.slow_stop_cutover
		if steps_in >= 0 and steps_in % def.inter_reel_steps == 0 then
			local reel_idx = math.floor(steps_in / def.inter_reel_steps)
			if reel_idx < def.constants.numreels and last_right_clicker ~= "" then
				minislots.play_sound(last_right_clicker, "minislots_reel_stop", pos, false)
			end
		end
		sr = sr + 1
		if sr <= def.constants.last_step then
			state = "reels_stopping_"..sr
			timeout = def.reel_slow_timeout
		else
			-- all reels have stopped: cut the spin loop now
			minislots.stop_spin_sound(pos)
			if numscatter >= def.min_scatter or numbonus >= def.min_bonus then
				state = "stopped"
				timeout = 0.1
			else
				state = "stopped"
				timeout = def.win_delay
			end
		end
	elseif state == "stopped" then
		if #allwins > 0 then
			local amount = allwins.line_wins_total*linebet
			balance = balance + amount
			allwins.total = allwins.total + amount
			meta:set_int("total_wins", meta:get_int("total_wins")+amount)
		end
		if numscatter >= def.min_scatter then
			local amount = allwins.scatter.count*def.scatter_value*linebet
			balance = balance + amount
			allwins.total = allwins.total + amount
			meta:set_int("scatter_hits", meta:get_int("scatter_hits")+1)
			meta:set_int("total_wins", meta:get_int("total_wins")+amount)
		end
		if numbonus >= def.min_bonus and allwins.bonus.value < 0 then
			-- initiate_bonus(spin, def, linebet, allwins)
			-- spin and def are passed for backwards compat; allwins carries bonus.count
			allwins.bonus.value = def.initiate_bonus(spin, def, linebet, allwins)
			balance = balance + allwins.bonus.value
			allwins.total = allwins.total + allwins.bonus.value
			meta:set_int("bonus_hits", meta:get_int("bonus_hits")+1)
			meta:set_int("total_wins", meta:get_int("total_wins")+allwins.bonus.value)
		end
		meta:set_string("allwins", core.serialize(allwins))
		meta:set_int("balance", balance)
		if numbonus >= def.min_bonus then
			state = "bonus_win"
			timeout = def.line_timeout
			if last_right_clicker ~= "" then
				minislots.play_sound(last_right_clicker, "minislots_win_jingle", pos, false)
			end
		elseif numscatter >= def.min_scatter then
			state = "scatter_win"
			timeout = def.line_timeout
			if last_right_clicker ~= "" then
				minislots.play_sound(last_right_clicker, "minislots_win", pos, false)
			end
		elseif #allwins > 0 then
			state = "win_1"
			timeout = def.line_timeout
			-- pick win sound by win value relative to linebet:
			--   jackpot symbol (def.jackpot_win_threshold or 200x): fanfare
			--   big win (>= 50x linebet total): jingle
			--   small win: win
			if last_right_clicker ~= "" and allwins[1] then
				local top_val = allwins[1].value  -- base value, before linebet multiply
				local jackpot_threshold = def.jackpot_win_threshold or 200
				local snd
				if top_val >= jackpot_threshold then
					snd = "minislots_jackpot"
				elseif top_val * linebet >= 50 then
					snd = "minislots_win_jingle"
				else
					snd = "minislots_win"
				end
				minislots.play_sound(last_right_clicker, snd, pos, false)
			end
		end
	elseif state == "bonus_win" then
		if numscatter >= def.min_scatter then
			state = "scatter_win"
			timeout = def.line_timeout
		elseif #allwins > 0 then
			state = "win_1"
			timeout = def.line_timeout
		end
	elseif state == "scatter_win" then
		if #allwins > 0 then
			state = "win_1"
			timeout = def.line_timeout
		end
	elseif string.find(state, "win_") then
		local w = tonumber(string.sub(state, 5)) + 1
		if w > #allwins then
			if numbonus >= def.min_bonus then
				state = "bonus_win"
				timeout = def.line_timeout
			elseif numscatter >= def.min_scatter then
				state = "scatter_win"
				timeout = def.line_timeout
			else
				-- only 1 winning line, no scatter/bonus: stop cycling so the machine
				-- doesn't get stuck needing a player right-click to unblock
				if #allwins > 1 then
					state = "win_1"
					timeout = def.line_timeout
				else
					state = "stopped"
				end
			end
		else
			state = "win_"..w
			timeout = def.line_timeout
		end
	end

	if meta:get_int("spin_timestamp") < (os.time() - 60) then
		core.get_node_timer(pos):stop()
		minislots.stop_spin_sound(pos)
		state = "stopped"
		meta:set_string("state", state)
		meta:set_string("formspec",
			minislots.generate_display(def, {
				state = state,
				spin = spin,
				allwins = allwins,
				balance = balance,
				linebet = linebet,
				maxlines = maxlines,
				player_name = last_right_clicker ~= "" and last_right_clicker or nil,
				admin = admin
			})
		)
		return
	end

	meta:set_string("state", state)
	meta:set_string("formspec",
		minislots.generate_display(def, {
			state = state,
			spin = spin,
			allwins = allwins,
			balance = balance,
			linebet = linebet,
			maxlines = maxlines,
			player_name = last_right_clicker ~= "" and last_right_clicker or nil,
			admin = admin
		})
	)
	if timeout > 0 then
		local timer = core.get_node_timer(pos)
		timer:start(timeout)
	end
	return false
end


--####################
-- the display engine
--####################

local function calcrp(def, spin, i, statenum)
	local rp = (
				spin[2][i+1][1]*2-2
				+ statenum
				+ def.constants.reel_wraparound_buf
				- def.constants.last_step
				+ (def.constants.numreels-i-1)*def.inter_reel_steps
			) % (def.constants.numsymbols * 2)
	return rp/2
end

function minislots.generate_display(def, options)
	local state = options.state
	local spin = options.spin
	local allwins = options.allwins
	local balance = options.balance
	local linebet = options.linebet
	local maxlines = options.maxlines
	local showlines = options.showlines
	local last_cashout = options.last_cashout
	local pos = options.pos
	local casino_name = options.casino_name
	local admin = options.admin

	local reels			= ""
	local lines			= ""
	local scatters		= ""
	local bonuses		= ""
	local underlights	= {}

	for i = 1, def.constants.numreels do underlights[i] = "" end

	if state == "scatter_win" and allwins.scatter.count > 0 then
		for reel = 1, def.constants.numreels do
			local t = {}
			for row = 0, 2 do
				if spin[row+1][reel][2] == "scatter" then
					t[#t+1] = ":0,"..(row*def.constants.reelsymsizey).."="
							..def.constants.reelunderlightpref..(row+1)..".png"
				end
			end
			if #t > 0 then
				underlights[reel] = table.concat(t, ":")
			end
		end
	elseif state == "bonus_win" and allwins.bonus.count > 0 then
		for reel = 1, def.constants.numreels do
			local t = {}
			for row = 0, 2 do
				if spin[row+1][reel][2] == "bonus" then
					t[#t+1] = ":0,"..(row*def.constants.reelsymsizey).."="
							..def.constants.reelunderlightpref..(row+1)..".png"
				end
			end
			if #t > 0 then
				underlights[reel] = table.concat(t, ":")
			end
		end
	end

	local statenum = tonumber(string.sub(state, (string.find(state, "stopping") and 16 or 15)))
	if string.find(state, "spinning_fast_") then
		local t = {}
		for i = 0, def.constants.numreels-1 do
			local rs = calcrp(def, spin, i, statenum) * -def.constants.reelsymsizey
			t[i+1] = "image["..((i*def.constants.reelspc+def.geometry.reel_posx)*horizscale-hanchor)..
				def.constants.reelcombinepref..
				":0,"..rs.."="..def.constants.symbolsfast..
				def.constants.reelshadowimg
		end
		reels = table.concat(t)
	elseif string.find(state, "spinning_medm_") then
		local t = {}
		for i = 0, def.constants.numreels-1 do
			local rs = calcrp(def, spin, i, statenum) * -def.constants.reelsymsizey
			t[i+1] = "image["..((i*def.constants.reelspc+def.geometry.reel_posx)*horizscale-hanchor)..
				def.constants.reelcombinepref..
				":0,"..rs.."="..def.constants.symbolsmedium..
				def.constants.reelshadowimg
		end
		reels = table.concat(t)
	elseif string.find(state, "spinning_slow_") then
		local t = {}
		for i = 0, def.constants.numreels-1 do
			local rs = calcrp(def, spin, i, statenum) * -def.constants.reelsymsizey
			t[i+1] = "image["..((i*def.constants.reelspc+def.geometry.reel_posx)*horizscale-hanchor)..
				def.constants.reelcombinepref..
				":0,"..rs.."="..def.constants.symbolsslow..
				def.constants.reelshadowimg
		end
		reels = table.concat(t)
	elseif string.find(state, "reels_stopping_") then
		local t = {}
		for i = 0, def.constants.numreels-1 do
			if i > ((statenum-def.constants.slow_stop_cutover-1)/def.inter_reel_steps) then
				local rs = calcrp(def, spin, i, statenum) * -def.constants.reelsymsizey
				t[i+1] = "image["..((i*def.constants.reelspc+def.geometry.reel_posx)*horizscale-hanchor)..
					def.constants.reelcombinepref..
					":0,"..rs.."="..def.constants.symbolsslow..
					def.constants.reelshadowimg
			else
				local rs = (spin[2][i+1][1]-1) * -def.constants.reelsymsizey
				t[i+1] = "image["..((i*def.constants.reelspc+def.geometry.reel_posx)*horizscale-hanchor)..
					def.constants.reelcombinepref..
					underlights[i+1]..":0,"..rs.."="..def.constants.symbolsstopped..
					def.constants.reelshadowimg
			end
		end
		reels = table.concat(t)
	elseif state == "stopped" or state == "start" or string.find(state, "win") then
		local t = {}
		for i = 0, def.constants.numreels-1 do
			local rs = (spin[2][i+1][1]-1) * -def.constants.reelsymsizey
			t[i+1] = "image["..((i*def.constants.reelspc+def.geometry.reel_posx)*horizscale-hanchor)..
				def.constants.reelcombinepref..
				underlights[i+1]..":0,"..rs.."="..def.constants.symbolsstopped..
				def.constants.reelshadowimg
		end
		reels = table.concat(t)
	end

	if not showlines then
		if string.find(state, "win_") then
			local w = string.sub(state, 5)
			local linewin = allwins[tonumber(w)].payline
			lines = def.constants.mainpref..def.constants.overlaylinepref..linewin..".png]"
		end
	else
		local t = {}
		for i = 1, maxlines do
			t[i] = def.constants.mainpref..def.constants.overlaylinepref..i..".png]"
		end
		lines = table.concat(t)
	end

	local t = {}
	if state == "scatter_win" and allwins.scatter.count > 0 then
		for i,pos in ipairs(allwins.scatter.pos) do
 			t[i] = "image["..(((pos[1]-1)*def.constants.reelspc+def.constants.highlightboxoffsx)*horizscale-hanchor)..","..
				(((pos[2]-1)*(def.geometry.reel_sizey/3)+def.constants.highlightboxoffsy)*vertscale-vanchor)..";"..
				def.constants.scatterhlimg
		end
		scatters = table.concat(t)
	end

	local t = {}
	if state == "bonus_win" and allwins.bonus.count > 0 then
		for i,pos in ipairs(allwins.bonus.pos) do
 			t[i] = "image["..(((pos[1]-1)*def.constants.reelspc+def.constants.highlightboxoffsx)*horizscale-hanchor)..","..
				(((pos[2]-1)*(def.geometry.reel_sizey/3)+def.constants.highlightboxoffsy)*vertscale-vanchor)..";"..
				def.constants.bonushlimg
		end
		bonuses = table.concat(t)
	end

-- all the stuff that is shown in the lower section's "screen"

	local posx = def.constants.screenposx + def.geometry.label_medium_sizex * horizscale
	local posy2 = def.constants.screenposy + def.geometry.screen_line_height * vertscale
	local tb = maxlines*linebet
	local dgszx = def.geometry.digit_glyph_sizex*0.75

	local bal = def.constants.lscrnpref..def.constants.lscrnypos1..def.constants.medlblsz1..def.constants.ballabelimg..
		minislots.print_number(def,
			balance,
			posx,
			def.constants.screenposy,
			dgszx,
			def.geometry.screen_line_height,
			true)

	local betwin = def.constants.lscrnpref..def.constants.lscrnypos2..def.constants.medlblsz1..def.constants.betlabelimg..
		minislots.print_number(def,
			tb,
			posx,
			posy2,
			dgszx,
			def.geometry.screen_line_height,
			true)

	if string.find(state, "win") and allwins.total > 0 then
		-- switch to 3-line mode

		local tblen = string.len(tostring(tb))

		betwin = def.constants.lscrnpref..def.constants.lscrnypos2..def.constants.medlblsz2..def.constants.betlabelimg..
			minislots.print_number(def,
				tb,
				posx,
				posy2,
				def.constants.digitmed,
				def.constants.screenlnht2,
				true)..

			"image["..(def.constants.screenposx + (def.geometry.label_medium_sizex
				+ def.constants.digitmed * (tblen+2.3333)) * horizscale)..
			def.constants.lscrnypos2..def.constants.medlblsz2..def.constants.winlabelimg..

			minislots.print_number(def,
				allwins.total,
				def.constants.screenposx + (def.geometry.label_medium_sizex*2
					+ def.constants.digitmed * (tblen+2.3333)) * horizscale,
				posy2,
				def.constants.digitmed,
				def.constants.screenlnht2,
				true)

		if state == "scatter_win" then

			betwin = betwin..def.constants.lscrnpref..def.constants.lscrnypos3..def.constants.scatterwinlabelimg..
				minislots.print_number(def,
					allwins.scatter.count * def.scatter_value * linebet,
					def.constants.screenposx + def.geometry.scatter_win_label_sizex * horizscale,
					def.constants.posy3,
					def.constants.digitsm,
					def.constants.screenlnht3,
					true)
		elseif state == "bonus_win" then
			if allwins.bonus.value > -1 then

				betwin = betwin..def.constants.lscrnpref..def.constants.lscrnypos3..def.constants.bonuswinlabelimg..
					minislots.print_number(def,
						allwins.bonus.value,
						def.constants.screenposx + def.geometry.bonus_win_label_sizex * horizscale,
						def.constants.posy3,
						def.constants.digitsm,
						def.constants.screenlnht3,
						true)
			end
		else
			local w = string.sub(state, 5)
			local lwlen = string.len(w)
			local s = tonumber(w)
			local lwn = allwins[s].payline

			betwin = betwin..def.constants.lscrnpref..def.constants.lscrnypos3..def.constants.lnwinlblsz..
				def.constants.linewinlabelimg..
				"image["..(
					def.constants.screenposx
					+ (def.geometry.line_win_label_sizex
					+ def.constants.ln3dig) * horizscale)..
				def.constants.lscrnypos3..def.constants.parenlblsz..def.constants.lparenimg..

				minislots.print_number(def,
					lwn,
					def.constants.screenposx
						+ (def.geometry.line_win_label_sizex
						+ def.constants.ln3dig
						+ def.constants.parensize) * horizscale,
					def.constants.posy3,
					def.constants.digitsm,
					def.constants.screenlnht3,
					false)..

				"image["..(
						def.constants.screenposx
						+ (def.geometry.line_win_label_sizex
						+ def.constants.ln3dig
						+ def.constants.parensize
						+ def.constants.digitsm * lwlen) * horizscale)..
				def.constants.lscrnypos3..def.constants.parenlblsz..def.constants.rparenimg..

				"image["..(
						def.constants.screenposx
						+ (def.geometry.line_win_label_sizex
						+ def.constants.ln3dig
						+ def.constants.parensize*2 -- i.e. two colon/paren spaces' worth
						+ def.constants.digitsm * lwlen) * horizscale)..
				def.constants.lscrnypos3..def.constants.parenlblsz..def.constants.colonimg..

				minislots.print_number(def,
					allwins[s].value*linebet,
					def.constants.screenposx
						+ (def.geometry.line_win_label_sizex
						+ def.constants.digitsm -- that is, two separate 1/2 spaces' worth
						+ def.constants.parensize*3 -- i.e. three colon/paren spaces' worth
						+ def.constants.digitsm * lwlen) * horizscale,
					def.constants.posy3,
					def.constants.digitsm,
					def.constants.screenlnht3,
					true)
		end
	end

	local onoff
	local linesbetbuttons = {}
	for _, b in ipairs(def.linebuttons) do
		onoff = "off"
		if b*linebet > balance or string.find(state, "spinning") or string.find(state, "reels_stopping_") then onoff = "dis"
		elseif maxlines == tonumber(b) then onoff = "on"
		end
		linesbetbuttons[#linesbetbuttons+1] = def.constants.buttons_n_lines[b][onoff]
	end

	for _, b in ipairs(def.betbuttons) do
		onoff = "off"
		if b*maxlines > balance or string.find(state, "spinning") or string.find(state, "reels_stopping_") then onoff = "dis"
		elseif linebet == tonumber(b) then onoff = "on"
		end
		linesbetbuttons[#linesbetbuttons+1] = def.constants.buttons_bet_n[b][onoff]
	end

	local spincashoutbuttons = ""
	local upper_screen = ""
	local cash_slot = ""
	local button_admin = ""
	local button_help = ""

	if not (string.find(state, "spinning") or string.find(state, "reels_stopping_")) then
		button_help = def.constants.buttonhelp
		cash_slot = def.constants.buttoncashslot
		if balance > 0 then
			spincashoutbuttons = def.constants.buttonspin..def.constants.buttoncashout
		else
			spincashoutbuttons = def.constants.buttonspin_dis..def.constants.buttonquit
		end
		if admin then button_admin = def.constants.buttonadmin end
	else
		button_help = def.constants.buttonhelp_dis
		cash_slot = def.constants.buttoncashslot_dis
		spincashoutbuttons = def.constants.buttonspin_dis..def.constants.buttoncashout_dis
		if admin then button_admin = def.constants.buttonadmin_dis end
	end

	-- Machine sound mute toggle, placed on the Help/Pays row in the gap
	-- between the Help button and the cash-slot indicator. This only silences
	-- THIS mod's machine sounds (play_sound checks the per-player mute flag);
	-- it never touches the player's Luanti client volume or other mods.
	-- The button always renders (the stored node-meta formspec is shared by all
	-- viewers, and mute is per-player, so we show a neutral label and resolve
	-- the actual per-player state when it is clicked).
	local button_mute = ""
	if not last_cashout then
		-- Mute toggle as an image_button (plain button[] does not render in
		-- this image-based formspec). Uses the same gray/gold aesthetic as the
		-- Help button. Positioned on the Help/Pays row, right of the Help button.
		local mx = (def.geometry.button_help_posx + def.geometry.button_help_sizex + 0.25)
					* horizscale - hanchor
		local my = def.geometry.button_help_posy * vertscale - vanchor
		local bw = def.geometry.button_help_sizex
		local bh = def.geometry.button_help_sizey
		button_mute =
			"image["..mx..","..my..";"..bw..","..bh..";"..
			def.constants.basename.."button_sound.png]"..
			"image_button["..mx..","..my..";"..
			(bw * spincouthelp_scalex)..","..(bh * spincouthelp_scaley)..";"..
			def.constants.emptyimg..";snd_mute;]"
	end

	if not last_cashout then
		upper_screen =
			def.constants.behindreels..
			reels..
			def.constants.overlay_upper..
			scatters..
			bonuses..
			cash_slot..
			button_admin..
			button_help..
			button_mute
	else
		local maxw = 6
		local maxmw = 2.25

		local posy = 3.6 - vanchor

		local txtszy = 0.25
		local numszy = 0.85
		local nameszy = 0.35
		local mstr_sizey = 0.15

		local w = minislots.str_width_pix(casino_name, "regular")*pix2iu*nameszy
		local name_sizex = w < maxw and w or maxw

		local numberwords = minislots.number_to_words(last_cashout).." Minegeld"
		local w = minislots.str_width_pix(numberwords, "condensed")*pix2iu*txtszy
		local numwords_maxszx = w < maxw and w or maxw

		local lastcoutstr = tostring(last_cashout).." Mg"
		local w = minislots.str_width_pix(lastcoutstr, "bold")*pix2iu*numszy
		local numstr_maxszx = w < maxw and w or maxw

		local machinestr = "MACHINE #"..string.format("%.0f", core.hash_node_position(pos))
		local w = minislots.str_width_pix(machinestr, "bold")*pix2iu*mstr_sizey
		local mstr_sizex = w < maxmw and w or maxmw

		local nameposx = def.constants.cashout_screen_ctrx - name_sizex*horizscale/2
		local numwordsposx = def.constants.cashout_screen_ctrx - numwords_maxszx*horizscale/2
		local numstrposx = def.constants.cashout_screen_ctrx - numstr_maxszx*horizscale/2
		local mstr_posx = 6.25

		upper_screen =
			def.constants.cashoutbackground..
			def.constants.upperbezel..
			def.constants.cashoutticketimg..
			minislots.print_string(def, casino_name, nameposx, posy, name_sizex, nameszy, "regular", false, "black")..
			minislots.print_string(def, numberwords, numwordsposx, posy+1.4, numwords_maxszx, txtszy, "condensed", false, "black")..
			minislots.print_string(def, lastcoutstr, numstrposx, posy+1.6, numstr_maxszx, numszy, "bold", false, "black")..
			minislots.print_string(def, machinestr, mstr_posx, posy+2.36, mstr_sizex, mstr_sizey, "bold", false, "black")
	end

	return	def.constants.form_header..
			def.constants.overlay_lower..
			upper_screen..
			table.concat(linesbetbuttons)..
			spincashoutbuttons..
			lines..
			bal..
			betwin
end

function minislots.str_width_pix(str, weight)
	local w = 0
	local len = string.len(str)
	for i = 1, len do
		local cw = char_widths[string.byte(str, i)]
		-- treat characters outside the bitmap font's range as spaces
		-- instead of crashing on a nil index
		w = w + (cw and cw[weight] or char_widths[32][weight])
	end
	return w
end

function minislots.print_string(def, str, posx, posy, sizex, sizey, weight, shadow, color)
	local t = {}
	if not str then return "" end
	local len = string.len(str)
	if len < 1 then return "" end
	local colorize = color and "\\^[colorize\\:"..color.."\\:255" or ""
	local shadowcolor = "\\^[colorize\\:black\\:255"

	local px = 0
	for i = 1, len do
		local asc = string.byte(str, i)
		local cw = char_widths[asc]
		if cw then
			t[#t+1] = px..",0=minislots_font_"..weight.."_char_"..asc..".png"
			px = px + cw[weight]
		else
			-- no glyph for this character; leave a space-sized gap
			px = px + char_widths[32][weight]
		end
	end

	local text = "image["..posx..","..posy..";"..sizex..","..sizey..";"..
			core.formspec_escape("[combine:"..px.."x80:")..
			table.concat(t, ":")..colorize.."]"
	if shadow then
		text = "image["..(posx+0.03)..","..(posy+0.03)..";"..sizex..","..sizey..";"..
			core.formspec_escape("[combine:"..px.."x80:")..
			table.concat(t, ":")..shadowcolor.."]"..text
	end
	return text
end

function minislots.print_number(def, num, posx, posy, sizex, sizey, cur, color)
	local t = {}
	local sn = tostring(num)
	local len = string.len(sn)
	local colorize = color and core.formspec_escape("^[colorize:"..color..":255").."]" or "]"

	for i = 1, len do
		t[#t+1] = "image["..(posx + (i-1)*sizex * horizscale)..","..posy..";"..
				sizex..","..sizey..";"..def.constants.digits[string.sub(sn, i, i)]..colorize
	end

	if cur then
		t[#t+1] = "image["..(posx + (len*sizex+sizex/4) * horizscale)..","..posy..";"..
				(sizex*1.3333)..","..(sizey)..def.constants.curlabelimg..colorize
	end

	return table.concat(t)
end

function minislots.number_to_words(number)

	local numstr = tostring(number)
	local numlen = string.len(numstr)
	local words = {}

	if number == 0 then return words_numbers[0] end

	local i = 1
	while i <= numlen do
		if (i+2)/3 == math.floor((i+2)/3) then -- it's a one's digit
			local n = tonumber(string.sub(numstr, -i-1, -i))
			local num = words_numbers[n]
			if not num then -- it's > 19
				n = tonumber(string.sub(numstr, -i, -i))
				if n > 0 then
					words[#words+1] = words_numbers[n]
				end
				words[#words+1] = words_tens[tonumber(string.sub(numstr, -i-1, -i-1))]
			elseif n > 0 then
				words[#words+1] = num
			end
			i = i + 2 -- skip over the ten's place, since we already handled it.
		elseif i/3 == math.floor(i/3) then -- it's a hundred's digit
			local h = string.sub(numstr, -i, -i)
			if h ~= "0" then -- we should only print "hundred" if the hundreds place is non-zero
				words[#words+1] = words_magnitudes[1]
				words[#words+1] = words_numbers[tonumber(h)]
			end
			i = i + 1
		end
		if i > numlen then break end
		if tonumber(string.sub(numstr, -i-2, -i)) ~= 0 then -- the magnitude is non-zero
			if i == 4 then
				words[#words+1] = words_magnitudes[2] -- thousand
			elseif i == 7 then
				words[#words+1] = words_magnitudes[3] -- million
			end
		end
	end

	local w = {}
	for i = #words, 1, -1 do
		w[#w+1] = words[i]
	end

	return table.concat(w, " ")
end

function minislots.generate_paytable_form(def)
	local t = {}
	t[1] = "size[10.7,10.4]background[-0.14,-0.17;11,11;"..def.constants.paytablescrnbg.."]"..
		"image_button_exit[10.25,-0.1;0.55,0.5;"..def.constants.button_close..";close;]"

	local y = def.geometry.paytable_posy
	local sympadding = 0.05
	local column = def.geometry.paytable_column1

	if def.paytable_desc then
		for _, line in ipairs(def.paytable_desc) do
			if line == "@wrap" then
				column = def.geometry.paytable_column2
				y = def.geometry.paytable_posy
			else
				local x = column
				for _, item in ipairs(line) do
					if string.sub(item, 1, 1) == "@" then
						if item == "@X" then
							t[#t+1] = "image["..(x*horizscale)..","..(y*vertscale)..";"..
										def.geometry.paytable_lineheight..","..def.geometry.paytable_lineheight..
										";"..def.constants.emptyimg.."]"
						else
							local sym = string.sub(item, 2)
							local sympos = def.constants.symlookup["sym_"..sym] * -def.constants.reelsymsizey - (def.constants.reelsymsizey - def.constants.reelsymsizex)/2
							t[#t+1] = "image["..(x*horizscale)..","..(y*vertscale)..";"..
									(def.geometry.paytable_lineheight-sympadding)..","..
									(def.geometry.paytable_lineheight-sympadding)..";"..
									"[combine:"..def.constants.reelsymsizex.."x"..def.constants.reelsymsizex..
									":0\\,"..sympos.."="..def.constants.symbolsstopped.."]"
						end
						x = x + def.geometry.paytable_lineheight
					else
						local szx = minislots.str_width_pix(item, "regular")*pix2iu*def.geometry.paytable_textheight
						t[#t+1] = minislots.print_string(def, item, x*horizscale, (y+def.geometry.paytable_textshift)*vertscale, szx, def.geometry.paytable_textheight, "regular", true)
						x = x + szx
					end
				end
			end
		y = y + def.geometry.paytable_lineheight
		end
	end
	t[#t+1] = def.constants.button_showpaylines
	return table.concat(t)
end

function minislots.generate_paylines_form(def)
	local t = {}
	local height = 10.4
	t[1] = "size[10.7,"..height.."]background[-0.14,-0.17;11,11;"..def.constants.paylinescrnbg.."]"..
		"image_button_exit[10.25,-0.1;0.55,0.5;"..def.constants.button_close..";close;]"
	if def.paylines_desc then

		local x = def.geometry.paylines_column1
		local y = def.geometry.paylines_posy

		for _, item in ipairs(def.paylines_desc) do
			if item == "@wrap" then
				y = def.geometry.paylines_posy
				x = def.geometry.paylines_column2
			elseif string.sub(item, 1, 1) == "@" then
				local split = string.find(item, " ")
				local s = tonumber(string.sub(item, 2, split))
				local e = tonumber(string.sub(item, split))
				t[#t+1] = "image["..x*horizscale..","..y*vertscale..";"..
					def.geometry.paylines_sizex..","..def.geometry.paylines_sizey..";"..
					def.constants.lines_bg.."]"

				for l = s, e do
					t[#t+1] = "image["..x*horizscale..","..y*vertscale..";"..
						def.geometry.paylines_sizex..","..def.geometry.paylines_sizey..";"..
						def.constants.overlaylinepref..l..".png]"
				end
				y = y + def.geometry.paylines_sizey + def.geometry.paylines_img_padding
			else
				local szx = minislots.str_width_pix(item, "regular")*pix2iu*def.geometry.paylines_textheight
				t[#t+1] = minislots.print_string(def, item, x*horizscale, y*vertscale, szx, def.geometry.paylines_textheight, "regular", true)
				y = y + def.geometry.paylines_lineheight
			end

			if y > height then
				y = def.geometry.paylines_posy
				x = def.geometry.paylines_column2
			end
		end
	end
	t[#t+1] = def.constants.button_showpaytable
	return table.concat(t)
end

function minislots.generate_admin_form(def, pos, balance)
	local meta = core.get_meta(pos)
	local casino = meta:get_string("casino_name")

	local money_in = meta:get_int("money_in")
	local money_out = meta:get_int("money_out")
	local total_bets = meta:get_int("total_bets")
	local total_wins = meta:get_int("total_wins")
	local spin_count = meta:get_int("spin_count")
	local scatter_hits = meta:get_int("scatter_hits")
	local bonus_hits = meta:get_int("bonus_hits")
	local install_date = meta:get_string("install_date")

	local pay_percent = 0
	if total_bets > 0 then pay_percent = math.floor((total_wins/total_bets+0.0005)*1000)/10 end

	local balancestr = "Current Balance: "..balance.." Mg"
	local money_instr = "Money in: "..money_in.." Mg"
	local money_outstr = "Money out: "..money_out.." Mg"
	local total_betsstr = "Total bets: "..total_bets.." Mg"
	local total_winsstr = "Total wins: "..total_wins.." Mg"
	local percent_str = "Payout percentage: "..pay_percent.."%"
	local spin_countstr = "Spin count: "..spin_count
	local scatter_hitsstr = "Scatter wins (count): "..scatter_hits
	local bonus_hitsstr = "Bonus wins (count): "..bonus_hits
	local install_datestr = "Install Date: "..install_date
	local cstr = "Casino name:"

	local sizey = 0.23

	local balw = minislots.str_width_pix(balancestr, "regular")*pix2iu*sizey
	local miw = minislots.str_width_pix(money_instr, "regular")*pix2iu*sizey
	local mow = minislots.str_width_pix(money_outstr, "regular")*pix2iu*sizey
	local tbw = minislots.str_width_pix(total_betsstr, "regular")*pix2iu*sizey
	local tww = minislots.str_width_pix(total_winsstr, "regular")*pix2iu*sizey
	local pctw = minislots.str_width_pix(percent_str, "regular")*pix2iu*sizey
	local spcw = minislots.str_width_pix(spin_countstr, "regular")*pix2iu*sizey
	local sccw = minislots.str_width_pix(scatter_hitsstr, "regular")*pix2iu*sizey
	local bcw = minislots.str_width_pix(bonus_hitsstr, "regular")*pix2iu*sizey
	local idw = minislots.str_width_pix(install_datestr, "regular")*pix2iu*sizey
	local cnw = minislots.str_width_pix(cstr, "regular")*pix2iu*sizey

	local formspec =
		"size[6,4.5]"..
		"image_button_exit[5.65,-0.2;0.55,0.5;"..def.constants.button_close..";close;]"..
		minislots.print_string(def, "Admin/configuration", 0.85, -0.15, 5, 0.4, "bold", true)..
		minislots.print_string(def, balancestr, 0, 0.5, balw, sizey, "regular", true)..
		minislots.print_string(def, money_instr, 0, 0.8, miw, sizey, "regular", true)..
		minislots.print_string(def, money_outstr, 0, 1.1, mow, sizey, "regular", true)..
		minislots.print_string(def, total_betsstr, 0, 1.4, tbw, sizey, "regular", true)..
		minislots.print_string(def, total_winsstr, 0, 1.7, tww, sizey, "regular", true)..
		minislots.print_string(def, percent_str, 0, 2, pctw, sizey, "regular", true)..
		minislots.print_string(def, spin_countstr, 0, 2.3, spcw, sizey, "regular", true)..
		minislots.print_string(def, scatter_hitsstr, 0, 2.6, sccw, sizey, "regular", true)..
		minislots.print_string(def, bonus_hitsstr, 0, 2.9, bcw, sizey, "regular", true)..
		minislots.print_string(def, install_datestr, 0, 3.2, idw, sizey, "regular", true)..
		minislots.print_string(def, cstr, 1, 3.7, cnw, sizey, "regular", true)..

		"field[1.3,3.4;4,3;casino_input;;"..core.formspec_escape(casino).."]"..
		"field_close_on_enter[casino_input;true]"
	return formspec
end

function minislots.generate_cashslot_form(def, pos, balance, player_name)
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z
	local formspec =
		"size[8,7]"..
		"background[-0.2,-0.25;8.4,7.74;"..def.constants.cashslotscrnbg.."]"..
		"image_button_exit[7.55,-0.1;0.55,0.5;"..def.constants.button_close..";close;]"..
		"list[nodemeta:".. spos .. ";main;3.5,1;1,1;]"..
		"label[2.5,-0.25;Insert money into the space below.]"..
		"label[2.2,0;When you're done, close this screen, then]"..
		"label[2.2,0.25;go back to the machine to continue playing.]"..
		"label[2.5,0.5;The machine's balance is: "..balance.." Mg]"..
		"image["..def.geometry.cash_slot_cin_posx..","..def.geometry.cash_slot_cin_posy..";"..
		def.geometry.cash_slot_sizex..","..def.geometry.cash_slot_sizey..";"..
		def.constants.basename.."cash_slot.png]"..
		"list[current_player;main;0,3.28;8,4;]"..
		"listring[]"
	return formspec
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if string.find(formname, "minislots:") then

		local player_name = player:get_player_name()
		local def = minislots.player_last_machine_def[player_name]
		local pos = minislots.player_last_machine_pos[player_name]
		local meta
		if pos then meta = core.get_meta(pos) end

		if fields.close and (formname == "minislots:cash_intake"
			or formname == "minislots:help_screen") then
			core.close_formspec(player_name, formname)
		elseif fields.showpaylines and formname == "minislots:help_screen" then
			if not def then
				core.show_formspec(player_name, "minislots:update_form", minislots.generate_too_old_screen())
				return
			end
			core.show_formspec(player_name, "minislots:help_screen",
				minislots.generate_paylines_form(minislots.player_last_machine_def[player_name]))
		elseif fields.showpaytable and formname == "minislots:help_screen" then
			if not def then
					core.show_formspec(player_name, "minislots:update_form", minislots.generate_too_old_screen())
				return
			end
			core.show_formspec(player_name, "minislots:help_screen",
				minislots.generate_paytable_form(minislots.player_last_machine_def[player_name]))
		elseif fields.key_enter_field == "casino_input" and fields.casino_input then
			if not def then
				core.show_formspec(player_name, "minislots:update_form", minislots.generate_too_old_screen())
				return
			end
			if def and pos and meta and meta:get_string("owner") == player_name then
				meta:set_string("formspec", "")
				-- store the raw name (it's escaped when inserted into a
				-- formspec, not here, otherwise escapes compound on every
				-- save) and strip characters the bitmap font can't render
				meta:set_string("casino_name", fields.casino_input:gsub("[^\32-\126]", ""))
			end
		elseif (fields.close or fields.quit) and formname == "minislots:admin_form" then
			if not def then
				core.show_formspec(player_name, "minislots:update_form", minislots.generate_too_old_screen())
				return
			end
			if def and pos and meta and meta:get_string("owner") == player_name then
				-- only clear formspec when not locked-out; clearing it while locked
				-- would erase the lockout message for other players
				local stored = meta:get_string("formspec")
				if not string.find(stored, "locked-out") then
					meta:set_string("formspec", "")
				end
			end
		end
	end
end)

function minislots.generate_too_old_screen()
		local form = "size[4,1]"..
		"image_button_exit[3.65,-0.2;0.55,0.5;minislots_close_button.png;close;]"..
		"label[0.32,0.2;Sorry, your client is too old to]"..
		"label[0.15,0.5;show this screen. Please update.]"
	return form
end


--###############################################
-- Global enable / disable  (maintenance mode)
--###############################################

-- Returns true when machines are open for play (default: enabled).
function minislots.is_enabled()
	return minislots_storage:get_string("enabled") ~= "false"
end

-- A small "down for maintenance" screen shown in place of the machine UI.
-- IMPORTANT: this is stored as the node's formspec metadata so that
-- right-clicking a machine (which opens the node-meta formspec directly,
-- before on_rightclick runs) shows the maintenance notice instead of the
-- playable UI. The "maint_mode" marker lives in the button's element name
-- (invisible to the player) so the stored formspec remains identifiable.
function minislots.generate_maintenance_screen()
	return "size[7,2.4]"..
		"label[0.4,0.4;This machine is currently down for maintenance.]"..
		"label[0.4,0.9;Please check back later.]"..
		"button_exit[2.5,1.6;2,0.7;maint_mode_ok;OK]"
end

-- Cashout helper shared by the maintenance eject and the normal cashout path.
-- Gives the player their balance in notes; drops any overflow at the machine.
local function forced_cashout(pos, player)
	local meta = core.get_meta(pos)
	local balance = meta:get_int("balance")
	if balance <= 0 then return end

	local fifties = math.floor(balance / 50)
	local tens    = math.floor((balance - fifties*50) / 10)
	local fives   = math.floor((balance - fifties*50 - tens*10) / 5)
	local ones    = balance - fifties*50 - tens*10 - fives*5

	local inv = player:get_inventory()
	local function give(item, count)
		if count <= 0 then return end
		local leftover = inv:add_item("main", item.." "..count)
		if leftover and leftover:get_count() > 0 then
			core.add_item(pos, leftover)
		end
	end
	give("currency:minegeld_50", fifties)
	give("currency:minegeld_10", tens)
	give("currency:minegeld_5",  fives)
	give("currency:minegeld",    ones)

	meta:set_int("money_out", meta:get_int("money_out") + balance)
	meta:set_int("last_cashout", balance)
	meta:set_int("balance", 0)
	meta:set_string("state", "stopped")
	core.get_node_timer(pos):stop()
	minislots.stop_spin_sound(pos)

	-- rebuild the formspec so the machine shows 0 balance if reopened
	local node = core.get_node(pos)
	local def = core.registered_items[node.name] and core.registered_items[node.name].machine_def
	if def then
		local spin = core.deserialize(meta:get_string("spin"))
		meta:set_string("formspec",
			minislots.generate_display(def, {
				state = "stopped",
				spin = spin,
				allwins = {},
				balance = 0,
				linebet = meta:get_int("linebet"),
				maxlines = meta:get_int("maxlines"),
				admin = false,
			})
		)
	end
end

-- Globalstep: when maintenance mode is active, eject any players sitting at
-- a machine (let a spin that is already in flight finish first).
local eject_interval = 1.0
local eject_timer = 0

core.register_globalstep(function(dtime)
	if minislots.is_enabled() then return end
	eject_timer = eject_timer + dtime
	if eject_timer < eject_interval then return end
	eject_timer = 0

	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		-- skip server-privilege players; they are allowed to remain
		if not core.check_player_privs(name, {server = true}) then
			local pos = minislots.player_last_machine_pos[name]
			if pos then
				local meta = core.get_meta(pos)
				local state = meta:get_string("state")

				-- let a spin already in flight finish; catch it next tick
				if not (string.find(state, "spinning") or
						string.find(state, "reels_stopping")) then

					-- force-close the formspec, cash out, clear the cache
					core.show_formspec(name, "", "")
					if meta:get_int("balance") > 0 then
						forced_cashout(pos, player)
					end
					minislots.player_last_machine_pos[name] = nil
					minislots.player_last_machine_def[name] = nil
					core.chat_send_player(name,
						"This machine is currently down for maintenance.")
				end
			end
		end
	end
end)

-- Rebuilds the normal playable formspec for a machine at pos (used to restore
-- a machine after maintenance ends).
local function restore_machine_formspec(pos)
	local node = core.get_node(pos)
	local reg = core.registered_items[node.name]
	if not reg or not reg.machine_def then return end
	local def = reg.machine_def
	local meta = core.get_meta(pos)
	local spin = core.deserialize(meta:get_string("spin")) or minislots.reset_reels(def)
	meta:set_string("state", "stopped")
	core.get_node_timer(pos):stop()
	meta:set_string("formspec",
		minislots.generate_display(def, {
			state = "stopped",
			spin = spin,
			allwins = {},
			balance = meta:get_int("balance"),
			linebet = meta:get_int("linebet"),
			maxlines = meta:get_int("maxlines"),
			admin = false,
		})
	)
end

-- Sweeps every player currently at a machine, swapping loaded machines'
-- formspec metadata to the given handler. Returns how many were touched.
local function sweep_tracked_machines(fn)
	local seen = {}
	for name, pos in pairs(minislots.player_last_machine_pos) do
		local key = core.hash_node_position(pos)
		if not seen[key] then
			seen[key] = true
			fn(pos)
		end
	end
end

-- Server commands (/disable_minislots, /enable_minislots, /minislots_status)
core.register_chatcommand("disable_minislots", {
	description = "Take all slot machines offline for maintenance.",
	privs = {server = true},
	func = function(name, _)
		if not minislots.is_enabled() then
			return true, "Minislots is already disabled."
		end
		minislots_storage:set_string("enabled", "false")
		-- Immediately swap any machine a player currently has open to the
		-- maintenance screen (the globalstep will then cash them out/eject).
		sweep_tracked_machines(function(pos)
			local meta = core.get_meta(pos)
			meta:set_string("formspec", minislots.generate_maintenance_screen())
		end)
		return true, "Minislots disabled. Players will be ejected from machines within 1 second."
	end,
})

core.register_chatcommand("enable_minislots", {
	description = "Bring slot machines back online after maintenance.",
	privs = {server = true},
	func = function(name, _)
		if minislots.is_enabled() then
			return true, "Minislots is already enabled."
		end
		minislots_storage:set_string("enabled", "true")
		-- Restore playable forms on any machines still showing maintenance.
		sweep_tracked_machines(restore_machine_formspec)
		return true, "Minislots enabled. Machines are open for play."
	end,
})

core.register_chatcommand("minislots_status", {
	description = "Show whether slot machines are enabled or disabled.",
	privs = {server = true},
	func = function(name, _)
		if minislots.is_enabled() then
			return true, "Minislots status: ENABLED (machines are open for play)."
		else
			return true, "Minislots status: DISABLED (maintenance mode active)."
		end
	end,
})

print("[Minislots] Loaded!")
