--CROSSBOWS-------------------------------------------------------------------------------
bows_epic.register_bow('crossbow',{
   description = 'Crossbow',
   texture = 'bows_crossbow_inv.png',
   texture_loaded = 'bows_crossbow_loaded.png',
   ammo = 'bolt',
   uses = 300,
   level = 25,
   craft = {
      {'default:steel_ingot', 'default:stick', 'default:steel_ingot'},
      {'farming:string', 'farming:string', 'farming:string'},
      {'', 'default:stick', ''},
   },
})

--CROSSBOW BOLTS--------------------------------------------------------------------------
minetest.register_craftitem('bows_epic:bolt_ent', {
   inventory_image = 'bows_bolt_ent.png',
   groups = {not_in_creative_inventory=1}
})

bows_epic.register_arrow('bolt_1',{
   description = 'Weak Crossbow Bolt',
   texture = 'bows_bolt_1.png',
   displayed_entity = 'bows_epic:bolt_ent',
   type = 'bolt',
   damage = 6,
   craft_count = 6,
   drop_chance = 3,
   craft = {
      {'default:stick', 'default:stick'}
   },
})

bows_epic.register_arrow('bolt_2',{
   description = 'Fair Crossbow Bolt',
   texture = 'bows_bolt_2.png',
   displayed_entity = 'bows_epic:bolt_ent',
   type = 'bolt',
   speed = 2,
   damage = 8,
   craft_count = 6,
   drop_chance = 2,
   craft = {
      {'default:stick', 'default:stick', 'default:flint'}
   },
})

bows_epic.register_arrow('bolt_3',{
   description = 'Good Crossbow Bolt',
   texture = 'bows_bolt_3.png',
   displayed_entity = 'bows_epic:bolt_ent',
   type = 'bolt',
   speed = 4,
   damage = 12,
   craft_count = 6,
   drop_chance = 1,
   craft = {
      {'default:stick', 'default:stick', 'default:steel_ingot'}
   },
})

bows_epic.register_arrow('bolt_exploding',{
   description = 'Exploding Crossbow Bolt',
   texture = 'bows_bolt_exp.png',
   displayed_entity = 'bows_epic:bolt_ent',
   type = 'bolt',
   speed = 2,
   damage = 5,
   craft_count = 6,
   drop_chance = 0,
   craft = {
      {'bows_epic:bolt_3', 'tnt:tnt_stick'}
   },
   on_hit_node = function(self, pos, user, arrow_pos)
      local player_name = user:get_player_name()
      if minetest.check_player_privs(player_name, { fire = true }) then
         if self.node.name ~= '' and not minetest.is_protected(pos, player_name) then
            tnt.boom(vector.round(pos), {radius = 2, damage_radius = 4})
         end
      else
         minetest.chat_send_player(player_name, 'You need the fire priv for this arrow to work!')
      end
   end,
})
