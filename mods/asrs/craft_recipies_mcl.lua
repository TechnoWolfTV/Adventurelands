core.register_craft({
   output = 'asrs:controller',
   type = 'shapeless',
   recipe = {'asrs:lift', 'asrs:lift', 'mcl_core:ironblock', 'mesecons_torch:redstoneblock', 'mcl_dye:blue'}
})

core.register_craft({
   output = 'asrs:remote_node',
   type = 'shapeless',
   recipe = {'asrs:lift', 'asrs:lift', 'mcl_core:iron_ingot', 'mesecons_torch:redstoneblock', 'mcl_dye:blue'}
})

core.register_craft({
   output = 'asrs:cell',
   recipe = {
      { 'group:wood', 'group:wood',        'group:wood' },
      { 'group:wood', 'mesecons:redstone', 'group:wood' },
      { 'group:wood', 'group:wood',        'group:wood' },
   }
})

core.register_craft({
   output = 'asrs:cell',
   type = 'shapeless',
   recipe = {'mcl_chests:chest', 'mesecons:redstone'}
})

core.register_craft({
   output = 'asrs:lift',
   recipe = {
      { 'mcl_core:iron_ingot', 'mcl_core:iron_ingot', 'mcl_core:iron_ingot' },
      { 'mcl_core:iron_ingot', 'mesecons:redstone', 'mcl_core:iron_ingot' },
      { 'mcl_core:iron_ingot', 'mcl_core:iron_ingot', 'mcl_core:iron_ingot' },
   }
})

core.register_craft({
   output = 'asrs:remote_item',
   recipe = {
      {'mcl_core:diamond',      'mesecons:redstone',    'mcl_core:diamond'},
      {'mesecons:redstone',    'asrs:controller',      'mesecons:redstone'},
      {'mcl_core:diamond',      'mesecons:redstone',    'mcl_core:diamond'}
   }
})
