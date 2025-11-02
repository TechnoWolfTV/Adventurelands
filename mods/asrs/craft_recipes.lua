mats = xcompat.materials

core.register_craft({
   output = 'asrs:controller',
   type   = 'shapeless',
   recipe = {'asrs:lift', 'asrs:lift', mats.steel_block, mats.mese, mats.dye_blue},
})

core.register_craft({
   output = 'asrs:remote_node',
   type   = 'shapeless',
   recipe = {'asrs:lift', 'asrs:lift', mats.steel_ingot, mats.mese, mats.dye_blue},
})

core.register_craft({
   output = 'asrs:cell',
   recipe = {
      { 'group:wood', 'group:wood',      'group:wood' },
      { 'group:wood', mats.mese_crystal, 'group:wood' },
      { 'group:wood', 'group:wood',      'group:wood' },
   }
})

core.register_craft({
   output = 'asrs:cell',
   type   = 'shapeless',
   recipe = {mats.chest, mats.mese_crystal},
})

core.register_craft({
   output = 'asrs:lift',
   recipe = {
      { mats.steel_ingot, mats.steel_ingot,  mats.steel_ingot },
      { mats.steel_ingot, mats.mese_crystal, mats.steel_ingot },
      { mats.steel_ingot, mats.steel_ingot,  mats.steel_ingot },
   }
})

core.register_craft({
   output = 'asrs:remote_item',
   recipe = {
      { mats.diamond,      mats.mese_crystal, mats.diamond      },
      { mats.mese_crystal, 'asrs:controller', mats.mese_crystal },
      { mats.diamond,      mats.mese_crystal, mats.diamond      },
   }
})

