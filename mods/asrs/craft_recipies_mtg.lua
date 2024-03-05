minetest.register_craft({
   output = 'asrs:controller',
   type = 'shapeless',
   recipe = {'asrs:lift', 'asrs:lift', 'default:steelblock', 'default:mese_block', 'dye:blue'}
})

minetest.register_craft({
   output = 'asrs:cell',
   recipe = {
      { 'group:wood', 'group:wood', 'group:wood' },
      { 'group:wood', 'default:mese_crystal', 'group:wood' },
      { 'group:wood', 'group:wood', 'group:wood' },
   }
})

minetest.register_craft({
   output = 'asrs:cell',
   type = 'shapeless',
   recipe = {'default:chest', 'default:mese_crystal'}
})

minetest.register_craft({
   output = 'asrs:lift',
   recipe = {
      { 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot' },
      { 'default:steel_ingot', 'default:mese_crystal', 'default:steel_ingot' },
      { 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot' },
   }
})
