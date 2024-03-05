minetest.register_craft({
   output = 'asrs:controller',
   type = 'shapeless',
   recipe = {'asrs:lift', 'asrs:lift', 'mcl_core:ironblock', 'mesecons_torch:redstoneblock', 'mcl_dye:blue'}
})

minetest.register_craft({
   output = 'asrs:cell',
   recipe = {
      { 'group:wood', 'group:wood', 'group:wood' },
      { 'group:wood', 'mesecons:redstone', 'group:wood' },
      { 'group:wood', 'group:wood', 'group:wood' },
   }
})

minetest.register_craft({
   output = 'asrs:cell',
   type = 'shapeless',
   recipe = {'mcl_chests:chest', 'mesecons:redstone'}
})

minetest.register_craft({
   output = 'asrs:lift',
   recipe = {
      { 'mcl_core:iron_ingot', 'mcl_core:iron_ingot', 'mcl_core:iron_ingot' },
      { 'mcl_core:iron_ingot', 'mesecons:redstone', 'mcl_core:iron_ingot' },
      { 'mcl_core:iron_ingot', 'mcl_core:iron_ingot', 'mcl_core:iron_ingot' },
   }
})
