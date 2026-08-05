local S = core.get_translator(FB.NAME)

core.register_craftitem(FB.NAME .. ":i00", {
	description = S("Rebar"),
	inventory_image = FB.NAME .. "_i00.png",
	stack_max = 200,
})

core.register_craftitem(FB.NAME .. ":i01", {
	description = S("Handrail"),
	inventory_image = FB.NAME .. "_i01.png",
	stack_max = 350,
})

core.register_craftitem(FB.NAME .. ":i02", {
	description = S("Long handrail"),
	inventory_image = FB.NAME .. "_i02.png",
})
