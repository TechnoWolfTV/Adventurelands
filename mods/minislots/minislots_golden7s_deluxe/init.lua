
-- Golden 7's Deluxe example machine
--
-- By Vanessa "VanessaE" Dannenberg
--
-- Most symbol images taken from clker.com
-- others drawn or rendered by me.

minislots.register_machine({
	name = "golden7s_deluxe",
	description = "Golden 7's Deluxe slot machine",
	machine_shape = "upright",
	lines = { -- reel symbol pay line positions: 0 = center, -1 = top, +1 = bottom
		{0, 0, 0, 0, 0}, -- pay line 1: center symbol on each reel
		{-1, -1, -1, -1, -1},-- 2: top symbol on each reel
		{1, 1, 1, 1, 1}, -- 3: bottom symbol on each reel
		{-1, -1, 0, 1, 1}, -- 4: top of reels 1 and 2, center of 3, bottom of 4 and 5
		{1, 1, 0, -1, -1}, -- 5: bottom of reels 1, 2, center 3, top 4, 5
		{-1, -1, -1, 0, 1}, -- 6: top of 1, 2, 3, center 4, bottom 5
		{1, 1, 1, 0, -1}, -- 7: bottom of 1, 2, 3, center 4, top 5
		{-1, 0, 1, 1, 1}, -- 8: top of 1, center 2, bottom 3, 4, 5
		{1, 0, -1, -1, -1}, -- 9: bottom of 1, center 2, top 3, 4, 5
		{1, 0, -1, 0, 1}, -- 10: bottom 1, center 2, top 3, center 4, bottom 5
		{-1, 0, 1, 0, -1}, -- 11: top 1, center 2, bottom 3, center 4, top 5
		{0, -1, -1, -1, -1}, -- 12: center 1, top 2, 3, 4, 5
		{0, 1, 1, 1, 1}, -- 13: center 1, bottom 2, 3, 4, 5
		{-1, -1, -1, -1, 0}, -- 14: top 1, 2, 3, 4, center 5
		{1, 1, 1, 1, 0}, -- 15: bottom 1, 2, 3, 4, center 5
	},
	symbols = {
		"bar",
		"lemon",
		"77",
		"cherry",
		"jackpot",
		"melon",
		"2bar",
		"lemon",
		"wild",
		"7",
		"bell",
		"scatter",
		"3bar",
		"777",
		"melon",
		"bonus"
	},
	linebuttons = {-- number of lines on each button, from left to right
		1,
		3,
		5,
		9,
		15
	},
	betbuttons = {-- line bet amount on each button, from left to right
		1,
		2,
		5,
		10,
		25
	},
	matches = {-- nil == don't care about that reel in a given match
		{1, "lemon", "lemon", nil, nil, nil},
		{1, "lemon", "lemon", "lemon", nil, nil},
		{3, "lemon", "lemon", "lemon", "lemon", nil},
		{4, "lemon", "lemon", "lemon", "lemon", "lemon"},

		{4, "melon", "melon", "melon", nil, nil},
		{5, "melon", "melon", "melon", "melon", nil},
		{7, "melon", "melon", "melon", "melon", "melon"},

		{7, "cherry", "cherry", nil, nil, nil},
		{7, "cherry", "cherry", "cherry", nil, nil},
		{8, "cherry", "cherry", "cherry", "cherry", nil},
		{10, "cherry", "cherry", "cherry", "cherry", "cherry"},

		{10, "bell", "bell", "bell", nil, nil},
		{14, "bell", "bell", "bell", "bell", nil},
		{18, "bell", "bell", "bell", "bell", "bell"},

		{23,
			{"bar", "2bar", "3bar"},
			{"bar", "2bar", "3bar"},
			{"bar", "2bar", "3bar"},
			{"bar", "2bar", "3bar"},
			{"bar", "2bar", "3bar"}
		},

		{27, "bar", "bar", "bar", nil, nil},
		{31, "bar", "bar", "bar", "bar", nil},
		{37, "bar", "bar", "bar", "bar", "bar"},

		{45, "2bar", "2bar", "2bar", nil, nil},
		{51, "2bar", "2bar", "2bar", "2bar", nil},
		{55, "2bar", "2bar", "2bar", "2bar", "2bar"},

		{64, "3bar", "3bar", "3bar", nil, nil},
		{67, "3bar", "3bar", "3bar", "3bar", nil},
		{68, "3bar", "3bar", "3bar", "3bar", "3bar"},

		{73,
			{"7", "77", "777"},
			{"7", "77", "777"},
			{"7", "77", "777"},
			{"7", "77", "777"},
			{"7", "77", "777"}
		},

		{78, "7", "7", "7", nil, nil},
		{81, "7", "7", "7", "7", nil},
		{82, "7", "7", "7", "7", "7"},

		{82, "77", "77", "77", nil, nil},
		{86, "77", "77", "77", "77", nil},
		{92, "77", "77", "77", "77", "77"},

		{92, "777", "777", "777", nil, nil},
		{114, "777", "777", "777", "777", nil},

		{137, "777", "777", "777", "777", "777"},

		{400, "jackpot", "jackpot", "jackpot", "jackpot", "jackpot"},

	},
	paytable_desc = {
		{"@lemon", "@lemon", "@X", "@X", "@X", " pays 1"},
		{"@lemon", "@lemon", "@lemon", "@X", "@X", " pays 1"},
		{"@lemon", "@lemon", "@lemon", "@lemon", "@X", " pays 3"},
		{"@lemon", "@lemon", "@lemon", "@lemon", "@lemon", " pays 4"},

		{"@melon", "@melon", "@melon", "@X", "@X", " pays 4"},
		{"@melon", "@melon", "@melon", "@melon", "@X", " pays 5"},
		{"@melon", "@melon", "@melon", "@melon", "@melon", " pays 7"},

		{"@cherry", "@cherry", "@X", "@X", "@X", " pays 7"},
		{"@cherry", "@cherry", "@cherry", "@X", "@X", " pays 7"},
		{"@cherry", "@cherry", "@cherry", "@cherry", "@X", " pays 8"},
		{"@cherry", "@cherry", "@cherry", "@cherry", "@cherry", " pays 10"},

		{"@bell", "@bell", "@bell", "@X", "@X", " pays 10"},
		{"@bell", "@bell", "@bell", "@bell", "@X", " pays 14"},
		{"@bell", "@bell", "@bell", "@bell", "@bell", " pays 18"},

		{"Any five ", "@bar", "/", "@2bar", "/", "@3bar", " pays 23"},
		{"@bar", "@bar", "@bar", "@X", "@X", " pays 27"},
		{"@bar", "@bar", "@bar", "@bar", "@X", " pays 31"},
		{"@bar", "@bar", "@bar", "@bar", "@bar", " pays 37"},

		{"@2bar", "@2bar", "@2bar", "@X", "@X", " pays 45"},
		{"@2bar", "@2bar", "@2bar", "@2bar", "@X", " pays 51"},
		{"@2bar", "@2bar", "@2bar", "@2bar", "@2bar", " pays 55"},

		{"@wild", " substitutes for any symbol except ", "@scatter", ", ", "@bonus", " or ", "@jackpot", "."},
		{"@bonus", " pays 7x bonus count x line bet (4+ needed)."},
		{"@scatter", " pays 4x per visible symbol (4+ needed, line bet x)."},
		{"All wins are multiplied by your line bet."},

		"@wrap",

		{"@3bar", "@3bar", "@3bar", "@X", "@X", " pays 64"},
		{"@3bar", "@3bar", "@3bar", "@3bar", "@X", " pays 67"},
		{"@3bar", "@3bar", "@3bar", "@3bar", "@3bar", " pays 68"},

		{"Any five ", "@7", "/", "@77", "/", "@777", " pays 73"},
		{"@7", "@7", "@7", "@X", "@X", " pays 78"},
		{"@7", "@7", "@7", "@7", "@X", " pays 81"},
		{"@7", "@7", "@7", "@7", "@7", " pays 82"},

		{"@77", "@77", "@77", "@X", "@X", " pays 82"},
		{"@77", "@77", "@77", "@77", "@X", " pays 86"},
		{"@77", "@77", "@77", "@77", "@77", " pays 92"},

		{"@777", "@777", "@777", "@X", "@X", " pays 92"},
		{"@777", "@777", "@777", "@777", "@X", " pays 114"},
		{"@777", "@777", "@777", "@777", "@777", " pays 137"},
		{"@jackpot", "@jackpot", "@jackpot", "@jackpot", "@jackpot", " pays 400"},

	},
	paylines_desc = {
		"Paylines 1 - 3:",
		"@1 3",
		"Paylines 4 and 5:",
		"@4 5",
		"Paylines 6 and 7:",
		"@6 7",
		"Paylines 8 and 9:",
		"@8 9",
		"Paylines 10 and 11:",
		"@10 11",
		"Paylines 12 - 15:",
		"@12 15"
	},
	maxbalance = 3260000,			-- 65535 50 Mg notes, minus maximum possible payout, minus a fudge amount
	currency_min = 1,				-- smallest and largest denominations of minegeld to allow
	currency_max = 100,
	bet_initiates_spin = true,		-- Most machines initiate a spin when the user presses a "Bet n" button, using
									-- the selected bet value.

									-- timings should be an even multiple of the step interval (usually 0.1s)
	reel_fast_timeout = 0.2,		-- time between "frames" while spinning fast, medium speed, or slow
	reel_medium_timeout = 0.1,
	reel_slow_timeout = 0.1,
	cutover_frames = 5,				-- number of frames to run for each fast, medium, and slow cycle
	inter_reel_steps = 3,			-- number of frames between stopping reels (using slow timeout)

	win_delay = 0.5,				-- time to wait after reels stop before showing winning lines
	line_timeout = 1,				-- time to wait between cycling among winning lines
	half_stops_weight = 5,			-- likelihood that a reel will stop between symbols, max 100 (if you want to
									-- disable that behavior and always land on a symbol, set this to 1).
	min_scatter = 4,				-- minimum number of scatter symbols needed before computing a scatter win
	scatter_value = 4,				-- value of the scatter symbol, will be multiplied by number visible * line bet
	min_bonus = 4,					-- minimum number of symbols needed to trigger the bonus round
	initiate_bonus = function(spin, def, linebet, allwins)
		-- Bonus pays 7x per bonus symbol visible x line bet.
		-- Uses the 4th argument (allwins) for the actual count so we don't have to
		-- re-scan the grid; falls back to min_bonus (4) if allwins is unavailable.
		local bonus_count = (allwins and allwins.bonus and allwins.bonus.count) or 4
		return 7 * bonus_count * (linebet or 1)
	end,
	wild_doesnt_match = {
		jackpot = true
	},
	wild_multiplier = 1,				-- For every wild that contributes to a line win, multiply win by this
										-- (so one wild mult. by this, two mult. by twice this, etc)

	geometry = {						-- all measures are in Minetest formspec "inventory slots" units

		base_user_interface_width = 14.667,	-- width of the user interface
		upper_section_height = 11,		-- height of the upper section (the reels et. al)
		lower_section_height = 2,		-- height of lower section (screen, buttons)

		reel_posx = 1,					-- X/Y position of first reel, others drawn as indicated below
		reel_posy = 1,

		reel_sizex = 2,					-- Nominal X/Y size of one reel. Note that reels are drawn with a
		reel_sizey = 9,					-- spacing of 1.3333 times their width (leaves a 0.6667 IU gap between
										-- reels on this machine).

		button_rows_posx = 6.9,			-- X starting pos for "n Lines"/"Bet n" buttons, Y pos for Spin button
		spin_cashout_posx = 12.75,		-- X pos for Spin and Cash-out/Quit buttons
		button_rows_posy = 11.14,		-- Y pos for "n Lines" row, and Cash Out/Quit button

		main_button_size = 0.8,			-- X/Y size of Lines/Bet buttons; X*2 x Y for Spin and Cash Out
		main_button_spacing = 0.9,		-- X/Y Spacing between Lines/Bet buttons, and between Spin and
										-- Cash Out buttons

		button_help_sizex = 1.6,		-- Size and position of the "Help / Pays" button
		button_help_sizey = 0.8,
		button_help_posx = 0.125,
		button_help_posy = 10.0938,

		screen_posx = 0.125,			-- X/Y position of top-left corner of lower screen (i.e. (0,0))
		screen_posy = 11.094,

		screen_line_height = 0.875,		-- Height of line 1, and 2 in 2-line mode. In 3-line mode, line 2
										-- hight will be 2/3 of this, and line 3 height will be 1/3 of it.

		label_medium_sizex = 1.125,		-- X size of "Bal:", "Bet:", "Win:".
		line_win_label_sizex = 2.0,		-- X size of "Line Win" label
		scatter_win_label_sizex = 3.0,	-- X size of "Scatter Win:" label
		bonus_win_label_sizex = 2.75,	-- X size of "Bonus Win:" label

		digit_glyph_sizex = 0.75,		-- Nominal X size of digits, before scaling down as noted below

		cash_slot_sizex = 5.0,			-- X/Y size and position of the cash slot
		cash_slot_sizey = 0.8125,
		cash_slot_posx = 9.5781,
		cash_slot_posy = 10.0938,
		cash_slot_cin_posx = 1.9,		-- X/Y position within the "cash intake" form (uses the same size as
		cash_slot_cin_posy = 2.27,		-- above)

		paytable_column1 = 0.65,		-- position of left/right columns in the paytable screen.
		paytable_column2 = 6.9,
		paytable_posy = 0.25,
		paytable_lineheight = 0.43,		-- height of a pay table line. sets the Y spacing of the lines, and the
										-- X/Y size of reel symbols shown therein, minus a bit of padding.
		paytable_textheight = 0.30,		-- height of printed text within said line, which will be vert. centered
		paytable_textshift = 0.065,		-- use this to fine tune the text vertical position relative to symbols

		paylines_column1 = 1.5,			-- position of left and right columns in paylines screen
		paylines_column2 = 7.25,
		paylines_posy = 0.2,			-- position of first row
		paylines_sizex = 4,				-- size of the pay lines graphic
		paylines_sizey = 3,
		paylines_lineheight = 0.65,		-- text line height and font height
		paylines_textheight = 0.35,
		paylines_img_padding = 0.3		-- extra blank space to add below pay lines graphic
	}
})
