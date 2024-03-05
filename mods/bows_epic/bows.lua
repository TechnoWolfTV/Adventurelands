--BOWS------------------------------------------------------------------------------------
bows_epic.register_bow('bow_wood',{
   description = 'Wooden bow',
   texture = 'bows_bow.png',
   texture_loaded = 'bows_bow_loaded.png',
   uses = 100,
   level = 15,
   craft = {
      {'', 'group:stick', 'farming:string'},
      {'group:stick', '', 'farming:string'},
      {'', 'group:stick', 'farming:string'}
   },
})

--ARROWS----------------------------------------------------------------------------------
minetest.register_craftitem('bows_epic:arrow_ent', {
   inventory_image = 'bows_arrow_ent.png',
   groups = {not_in_creative_inventory=1}
})

bows_epic.register_arrow('arrow_1',{
   description = 'Weak Arrow',
   texture = 'bows_arrow_1.png',
   displayed_entity = 'bows_epic:arrow_ent',
   damage = 4,
   craft_count = 6,
   drop_chance = 3,
   craft = {
      {'group:stick', 'mobs:chicken_feather'}
   },
})

bows_epic.register_arrow('arrow_2',{
   description = 'Fair Arrow',
   texture = 'bows_arrow_2.png',
   displayed_entity = 'bows_epic:arrow_ent',
   speed = 2,
   damage = 6,
   craft_count = 6,
   drop_chance = 2,
   craft = {
      {'default:flint', 'group:stick', 'mobs:chicken_feather'}
   },
})

bows_epic.register_arrow('arrow_3',{
   description = 'Good Arrow',
   texture = 'bows_arrow_3.png',
   displayed_entity = 'bows_epic:arrow_ent',
   speed = 4,
   damage = 10,
   craft_count = 6,
   drop_chance = 1,
   craft = {
      {'default:steel_ingot', 'group:stick', 'mobs:chicken_feather'}
   },
})
