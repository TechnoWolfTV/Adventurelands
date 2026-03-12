
-- salt crystal biome

ambience.add_set("caverealms_crystal", {

	frequency = 50,

	sounds = {
		{name = "caverealms_crystal", length = 3, ephemeral = true},
		{name = "caverealms_crystal", length = 3, pitch = 0.9, ephemeral = true},
		{name = "caverealms_crystal", length = 3, pitch = 1.2, ephemeral = true},
	},

	nodes = ({"caverealms:stone_with_salt"}),

	sound_check = function(def)

		local c = (def.totals["caverealms:stone_with_salt"] or 0)

		if c > 250 then return "caverealms_crystal" end
	end
})

-- stone area rumble

ambience.add_set("caverealms_rumble", {

	frequency = 50,

	sounds = {
		{name = "caverealms_deep_whoosh", length = 3, ephemeral = true},
		{name = "caverealms_deep_whoosh", length = 3, pitch = 0.6, ephemeral = true},
		{name = "caverealms_deep_whoosh", length = 3, pitch = 0.8, ephemeral = true},
	},

	nodes = ({"caverealms:stone_with_moss", "caverealms:stone_with_algae",
			"caverealms:stone_with_lichen"}),

	sound_check = function(def)

		local c = (def.totals["caverealms:stone_with_moss"] or 0) +
				(def.totals["caverealms:stone_with_algae"] or 0) +
				(def.totals["caverealms:stone_with_lichen"] or 0)

		if c > 150 then return "caverealms_rumble" end
	end
})
