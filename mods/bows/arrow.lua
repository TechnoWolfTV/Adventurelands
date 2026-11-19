
local math_random = math.random

-- helper to remove arrow entity and maybe drop arrow item

local function on_hit_remove(self, pos)

	-- chance of dropping arrow
	local def = core.registered_items[self.name]
	local chance = def and def.drop_chance or 10

	core.sound_play(bows.registered_arrows[self.name].on_hit_sound,
			{pos = pos, max_hear_distance = 12}, true)

	if pos and math_random(chance) == 1 then
		core.add_item({x = pos.x, y = pos.y + 0.5, z = pos.z}, self.name)
	end

	self.object:remove()
end

-- when arrow hits an entity

local function on_hit_object(self, target, hp, user, lastpos)

	if target:get_pos() then

		target:punch(user, 1.0, {
			full_punch_interval = 1.0, damage_groups = {fleshy = hp}}, nil)
	end

	if bows.registered_arrows[self.name].on_hit_object then

		bows.registered_arrows[self.name].on_hit_object(self, target, hp, user, lastpos)
	end
end

-- arrow entity

core.register_entity("bows:arrow",{

	initial_properties = {
		visual = "wielditem",
		visual_size = {x = 0.20, y = 0.20},
		collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
		physical = true,
		textures = {"air"},
		static_save = false
	},

	_is_arrow = true,
	timer = 10,

	on_activate = function(self, staticdata)

		local data = bows.players[staticdata or ""]

		if not (data and data.arrow) then
			self.object:remove() ; return
		end

		self.arrow = data.arrow
		self.user = data.user
		self.name = data.name
		self.dmg = bows.registered_arrows[self.name].damage
		self.do_custom = bows.registered_arrows[self.name].do_custom

		self.object:set_properties({textures = {self.arrow}})
	end,

	on_step = function(self, dtime, moveresult)

		self.timer = self.timer - dtime

		if self.timer < 0 then
			self.object:remove() ; return
		end

		if self.do_custom and self:do_custom(dtime, moveresult) == false then
			return
		end

		if not (moveresult and moveresult.collides) then return end -- nothing hit

		local pos = self.object:get_pos() ; if not pos then return end
		local hit = moveresult.collisions and moveresult.collisions[1] or {}

		self.moveresult = moveresult -- pass moveresult into arrow entity

		if hit.type == "node" and bows.registered_arrows[self.name].on_hit_node then

			self.node_pos = hit.node_pos -- store node and pos in self
			self.node = core.get_node(self.node_pos)

			-- (self, pos, user, arrow_pos)
			bows.registered_arrows[self.name].on_hit_node(
					self, self.node_pos, self.user, pos)

		elseif hit.type == "object" and hit.object then

			-- (self, target, hp, user, lastpos)
			on_hit_object(self, hit.object, self.dmg, self.user, pos)
		end

		on_hit_remove(self, pos)
	end
})
