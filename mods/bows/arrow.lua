
local math_random = math.random

-- helper to remove or maybe drop arrow item

local function on_hit_remove(self)

	minetest.sound_play(
		bows.registered_arrows[self.name].on_hit_sound, {
			pos = self.object:get_pos(),
			gain = 1.0,
			max_hear_distance = 12
		}, true)

	-- chance of dropping arrow
	local chance = minetest.registered_items[self.name].drop_chance or 10
	local pos = self.object:get_pos()

	if pos and math_random(chance) == 1 then

		pos.y = pos.y + 0.5

		minetest.add_item(pos, self.name)
	end

	self.object:remove()

	return self
end

-- when arrow hits an entity

local function on_hit_object(self, target, hp, user, lastpos)

	target:punch(user, 1.0, {
		--full_punch_interval = 1.0,
		damage_groups = {fleshy = hp},
	}, nil)

	if bows.registered_arrows[self.name].on_hit_object then

		bows.registered_arrows[self.name].on_hit_object(
				self, target, hp, user, lastpos)
	end

	on_hit_remove(self)

	return self
end

-- arrow entity

minetest.register_entity("bows:arrow",{

	initial_properties = {
		hp_max = 10,
		visual = "wielditem",
		visual_size = {x = .20, y = .20},
		collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
		physical = false,
		textures = {"air"}
	},

	_is_arrow = true,
	timer = 10,

	on_activate = function(self, staticdata)

		if not self then
			self.object:remove() ; return
		end

		if bows.tmp and bows.tmp.arrow ~= nil then

			self.arrow = bows.tmp.arrow
			self.user = bows.tmp.user
			self.name = bows.tmp.name
			self.dmg = bows.registered_arrows[self.name].damage

			bows.tmp = nil

			self.object:set_properties({textures = {self.arrow}})
		else
			self.object:remove()
		end
	end,

	on_step = function(self, dtime, ...)

		self.timer = self.timer - dtime

		if self.timer < 0 then
			self.object:remove() ; return
		end

		local pos = self.object:get_pos() ; self.oldpos = self.oldpos or pos
		local cast = minetest.raycast(self.oldpos, pos, true, true)
		local thing = cast:next()
		local ok = true

		-- loop through things
		while thing do

			-- ignore the object that is the arrow
			if thing.type == "object" and thing.ref ~= self.object then

				-- add entity name to thing table (if not player)
				if not thing.ref:is_player() then
					thing.name = thing.ref:get_luaentity() and thing.ref:get_luaentity().name
				end

				-- check if dropped item or yourself
				if thing.name == "__builtin:item"
				or (not thing.name
				and thing.ref:get_player_name() == self.user:get_player_name()) then
					ok = false
				end

				-- can we hit entity ?
				if ok then

--print("-- hit entity", thing.name)

					on_hit_object(self, thing.ref, self.dmg, self.user, pos)

					return self
				end

			-- are we inside a node ?
			elseif thing.type == "node" then

				self.node = minetest.get_node(pos)

				local def = minetest.registered_nodes[self.node.name]

				if def and def.walkable then

--print("-- hit node", self.node.name)

					if bows.registered_arrows[self.name].on_hit_node then

						bows.registered_arrows[self.name].on_hit_node(
								self, pos, self.user, self.oldpos)
					end

					on_hit_remove(self)

					return self
				end
			end

			thing = cast:next()
		end

		self.oldpos = pos
	end
})
