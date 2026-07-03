-- Minetest: builtin/item_entity.lua

function core.spawn_item(pos, item)

	local obj = core.add_entity(pos, "__builtin:item")

	if obj then
		obj:get_luaentity():set_item(ItemStack(item):to_string())
	end

	return obj
end


-- If item_entity_ttl is not set, entity will have default life time
-- Setting it to -1 disables the feature

local time_to_live = tonumber(core.settings:get("item_entity_ttl")) or 900
local gravity = tonumber(core.settings:get("movement_gravity")) or 9.81
local destroy_item = core.settings:get_bool("destroy_item") ~= false

-- localize some math functions and get_node

local math_abs, math_random, math_min = math.abs, math.random, math.min
local get_id = core.get_node_raw
local get_id_name = core.get_name_from_content_id
local get_node = core.get_node

if get_id then get_node = function(pos)

		local id, p1, p2, pos_ok = get_id(pos.x, pos.y, pos.z)

		return {name = get_id_name(id), param1 = p1, param2 = p2, loaded = pos_ok}
	end
end

local function node_ok(pos)

	local node = get_node(pos)

	if core.registered_nodes[node.name] then return node end

	return core.registered_nodes["default:dirt"]
end

-- water flow functions by QwertyMine3, edited by TenPlus1 and Gustavo6046

local function quick_flow_logic(node, pos_testing, direction)

	local node_testing = node_ok(pos_testing)

	if core.registered_nodes[node_testing.name].liquidtype ~= "flowing" then
		return 0
	end

	local diff = node_testing.param2 - node.param2

	if diff == 0 then return 0 end

	if math_abs(diff) > 6 then
		return diff > 0 and direction or -direction
	end

	return diff > 0 and -direction or direction
end

local inv_roots = {[0] = 0, [1] = 1, [2] = 0.7071, [4] = 0.5, [5] = 0.4472, [8] = 0.3535}

local function quick_flow(pos, node)

	local x = quick_flow_logic(node, {x = pos.x - 1, y = pos.y, z = pos.z},-1)
			+ quick_flow_logic(node, {x = pos.x + 1, y = pos.y, z = pos.z}, 1)
	local z = quick_flow_logic(node, {x = pos.x, y = pos.y, z = pos.z - 1},-1)
			+ quick_flow_logic(node, {x = pos.x, y = pos.y, z = pos.z + 1}, 1)

	local sum = x * x + z * z
	local inv = inv_roots[sum] or 0

	return {x = x * inv, y = 0, z = z * inv}
end

-- particle effects for when item is destroyed

local function add_effects(pos)

	core.add_particlespawner({
		amount = 3,
		time = 0.1,
		minpos = vector.new(pos.x + -0.1, pos.y + -0.1, pos.z + -0.1),
		maxpos = vector.new(pos.x + 0.1, pos.y + 0.1, pos.z + 0.1),
		minvel = vector.new(0, 2.5, 0),
		maxvel = vector.new(0, 2.5, 0),
		minacc = vector.new(-0.15, -0.02, -0.15),
		maxacc = vector.new(0.15, -0.01, 0.15),
		minexptime = 2,
		maxexptime = 3,
		minsize = 5,
		maxsize = 5,
		collisiondetection = true,
		texture = "tnt_smoke.png"
	})
end

-- default friction settings

local water_force = tonumber(core.settings:get("builtin_item.waterflow_force") or 1.6)
local water_drag = tonumber(core.settings:get("builtin_item.waterflow_drag") or 0.8)
local dry_friction = tonumber(core.settings:get("builtin_item.friction_dry") or 2.6)
local air_drag = tonumber(core.settings:get("builtin_item.air_drag") or 0.4)
local items_collect_on_slippery = tonumber(
		core.settings:get("builtin_item.items_collect_on_slippery") or 1) ~= 0

-- entity

core.register_entity(":__builtin:item", {

	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
		visual = "wielditem",
		visual_size = {x = 0.4, y = 0.4},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false,
		infotext = ""
	},

	itemstring = "",
	falling_state = true,
	slippery_state = false,
	waterflow_state = false,
	age = 0,

	accel = {x = 0, y = 0, z = 0},

	set_item = function(self, item)

		local stack = ItemStack(item or self.itemstring)

		self.itemstring = stack:to_string()

		if self.itemstring == "" then return end

		local itemname = stack:is_known() and stack:get_name() or "unknown"
		local max_count = stack:get_stack_max()
		local count = math_min(stack:get_count(), max_count)
		local size = 0.2 + 0.1 * (count / max_count) ^ (1 / 3)
		local col_height = size * 0.75
		local def = core.registered_nodes[itemname]
		local glow = def and def.light_source
		local c1, c2 = "", ""

		if not(stack:get_count() == 1) then
			c1 = " x" .. tostring(stack:get_count())
			c2 = " " .. tostring(stack:get_count())
		end

		local name1 = stack:get_meta():get_string("description")
		local name

		if name1 == "" then
			name = core.registered_items[itemname].description
		else
			name = name1
		end

		-- small random size bias to counter Z-fighting
		local bias = math_random() * 0.001

		self.object:set_properties({
			is_visible = true,
			visual = "wielditem",
			textures = {itemname},
			visual_size = {x = size + bias, y = size + bias, z = size + bias},
			collisionbox = {-size, -col_height, -size, size, col_height, size},
			selectionbox = {-size, -size, -size, size, size, size},
			automatic_rotate = 0.314 / size,
			wield_item = self.itemstring,
			glow = glow,
			infotext = name .. c1 .. "\n(" .. itemname .. c2 .. ")"
		})
	end,

	get_staticdata = function(self)

		return core.serialize({
			itemstring = self.itemstring,
			age = self.age,
			dropped_by = self.dropped_by
		})
	end,

	on_activate = function(self, staticdata, dtime_s)

		if string.sub(staticdata, 1, 6) == "return" then

			local data = core.deserialize(staticdata)

			if data and type(data) == "table" then
				self.itemstring = data.itemstring
				self.age = (data.age or 0) + dtime_s
				self.dropped_by = data.dropped_by
			end
		else
			self.itemstring = staticdata
		end

		self.object:set_armor_groups({immortal = 1})
		self:set_item()
	end,

	try_merge_with = function(self, own_stack, object, entity)

		if self.age == entity.age then return end -- Can not merge with itself

		local stack = ItemStack(entity.itemstring)
		local name = stack:get_name()

		if own_stack:get_name() ~= name
		or own_stack:get_meta() ~= stack:get_meta()
		or own_stack:get_wear() ~= stack:get_wear()
		or own_stack:get_free_space() == 0 then
			return -- Can not merge different or full stack
		end

		local total_count = stack:get_count() + own_stack:get_count()

		if total_count > stack:get_stack_max() then return end

		-- Merge the remote stack into this one
		local pos, self_pos = object:get_pos(), self.object:get_pos()

		self.age = 0 -- Reset age
		self.object:move_to(vector.offset(pos,
				(self_pos.x - pos.x) / 2, 0, (self_pos.z - pos.z) / 2))

		-- Merge velocities
		local vel_a, vel_b = self.object:get_velocity(), object:get_velocity()

		self.object:set_velocity({
			x = (vel_a.x + vel_b.x) / 2,
			y = (vel_a.y + vel_b.y) / 2,
			z = (vel_a.z + vel_b.z) / 2
		})

		-- Merge stacks
		own_stack:set_count(total_count)
		self:set_item(own_stack)

		entity.itemstring = ""
		object:remove()

		return true
	end,

	step_update_node_state = function(self, moveresult, dtime)

		local pos = self.object:get_pos()

		-- get nodes every 1/4 second
		self.timer = (self.timer or 0) + dtime

		if self.timer < 0.25 and self.node_inside then return end

		self.timer = 0

		self.node_inside = get_node(pos)
		self.def_inside = core.registered_nodes[self.node_inside.name]

		-- get ground node for collision
		self.node_under = nil
		self.falling_state = true

		--[[ new ground check (glitchy)
		if moveresult and moveresult.touching_ground then

			for _, info in ipairs(moveresult.collisions) do

				if info.axis == "y" then

					self.node_under = core.get_node_or_nil(info.node_pos)
					self.falling_state = false

					break
				end
			end
		end]]

		-- old ground check (stable)
		self.node_under = get_node({
			x = pos.x,
			y = pos.y + self.object:get_properties().collisionbox[2] - 0.05,
			z = pos.z
		})

		self.def_under = core.registered_nodes[self.node_under.name]

		-- part of old ground check
		if self.def_under and self.def_under.walkable then
			self.falling_state = false
		end
	end,

	step_node_inside_checks = function(self)

		if self.itemstring == "" then
			self.object:remove()
			return true
		end

		-- Delete in 'ignore' nodes
		if self.node_inside and self.node_inside.name == "ignore" then
			self.itemstring = ""
			self.object:remove()
			return true
		end

		local def = self.def_inside ; if not def then return end
		local pos = self.object:get_pos()

		-- item inside block, move to vacant space
		if def.walkable ~= false
		and (def.collision_box == nil or def.collision_box.type == "regular")
		and (def.node_box == nil or def.node_box.type == "regular") then

			local npos = core.find_node_near(pos, 1, "air")

			if npos then
				self.object:move_to(npos)
			end

			self.node_inside = nil -- force get_node
		end

		-- destroy item when dropped into lava (if enabled)
		if destroy_item and def.groups.lava then

			core.sound_play("builtin_item_lava",
					{pos = pos, max_hear_distance = 6, gain = 0.5}, true)

			self.itemstring = ""
			self.object:remove()

			add_effects(pos)

			return true
		end
	end,

	step_check_slippery = function(self)

		-- don't check for slippery if we're not on the ground
		if self.falling_state or not self.node_under then
			self.slippery_state = false ; return
		end

		if self.def_under and self.def_under.walkable then
			self.slippery_state = self.def_under.groups.slippery
		end
	end,

	step_water_physics = function(self)

		self.waterflow_state = self.def_inside and self.def_inside.liquidtype == "flowing"

		if self.waterflow_state then

			local pos = self.object:get_pos()
			local vel = self.object:get_velocity()

			-- get flow velocity
			local flow_vel = quick_flow(pos, self.node_inside)

			-- calculate flow force and drag
			local flow_force_x = flow_vel.x * water_force
			local flow_force_z = flow_vel.z * water_force

			local flow_drag_x = (flow_force_x - vel.x) * water_drag
			local flow_drag_z = (flow_force_z - vel.z) * water_drag

			-- apply water force and friction
			self.accel.x = self.accel.x + flow_force_x + flow_drag_x
			self.accel.z = self.accel.z + flow_force_z + flow_drag_z
		end
	end,

	step_gravity = function(self)

		local vel = self.object:get_velocity()

		-- apply gravity if falling or Y velocity not 0 (just incase)
		if self.falling_state or (vel and vel.y ~= 0) then
			self.accel.y = self.accel.y - gravity
		end
	end,

	step_ground_friction = function(self)

		-- don't apply ground friction when falling!
		if self.falling_state then return end

		local vel = self.object:get_velocity()

		-- this stops the entity drift glitch by re-setting entity pos when not moving
		if vel.x == 0 and vel.y == 0 and vel.z == 0 then

			if self.is_moving then

				self.is_moving = false

				self.object:set_pos(self.object:get_pos()) -- this stops drift
			end
		else
			self.is_moving = true
		end

		local this_dry_friction = dry_friction

		-- apply slip factor (tiny friction that depends on the actual block type)
		if self.slippery_state and (math_abs(vel.x) > 0.2 or math_abs(vel.z) > 0.2) then

			local slippery = self.def_under and self.def_under.groups.slippery

			this_dry_friction = 4.0 / (slippery + 4)
		end

		self.accel.x = self.accel.x - vel.x * this_dry_friction
		self.accel.z = self.accel.z - vel.z * this_dry_friction
	end,

	step_apply_forces = function(self)
		self.object:set_acceleration(self.accel)
	end,

	-- let items die out after enough time
	step_check_timeout = function(self, dtime)

		self.age = self.age + dtime

		if time_to_live > 0 and self.age > time_to_live then

			add_effects(self.object:get_pos())

			self.itemstring = ""
			self.object:remove()

			return true
		end
	end,

	step_check_custom_step = function(self, dtime, moveresult)

		local name = self.itemstring:match("^[^%s]+") or self.itemstring
		local def = core.registered_items[name]

		if not (def and def.dropped_step) then return end

		if def.dropped_step(self, self.object:get_pos(), dtime, moveresult) == false then
			return true -- skip further checks if false
		end
	end,

	step_try_collect = function(self)

		-- Don't collect items if falling
		if self.falling_state then return end

		-- Check if we should collect items while sliding
		if self.slippery_state and not items_collect_on_slippery then return end

		-- Collect the items around to merge with
		local own_stack = ItemStack(self.itemstring)

		if own_stack:get_free_space() == 0 then return end

		local self_pos = self.object:get_pos()
		local objects = core.get_objects_inside_radius(self_pos, 1.0)

		for _, obj in pairs(objects) do

			local entity = obj:get_luaentity()

			if entity and entity.name == "__builtin:item" and not entity.is_falling then

				if self:try_merge_with(own_stack, obj, entity) then

					-- item will be moved up due to try_merge_with
					self.falling_state = true

					own_stack = ItemStack(self.itemstring)

					if own_stack:get_free_space() == 0 then return end
				end
			end
		end
	end,

	step_air_drag_physics = function(self)

		local vel = self.object:get_velocity()

		-- apply air drag
		if self.falling_state or (self.slippery_state and not self.waterflow_state) then
			self.accel.x = self.accel.x - vel.x * air_drag
			self.accel.z = self.accel.z - vel.z * air_drag
		end
	end,

	on_step = function(self, dtime, moveresult)

		self.accel = {x = 0, y = 0, z = 0} -- reset acceleration

		-- check item timeout
		if self:step_check_timeout(dtime) then return end -- deleted, stop here

		-- check custom step function
		if self:step_check_custom_step(dtime, moveresult) then return end -- overriden

		self:step_update_node_state(moveresult, dtime) -- do general checks

		if self:step_node_inside_checks() then return end -- destroyed

		-- do physics checks, then apply
		self:step_water_physics()
		self:step_check_slippery()
		self:step_ground_friction()
		self:step_air_drag_physics()
		self:step_gravity()
		self:step_apply_forces()
		self:step_try_collect() -- merge
	end,

	on_punch = function(self, hitter, ...)

		if self.itemstring == "" then
			self.object:remove() ; return
		end

		if core.item_pickup then

			-- Call on_pickup callback in item definition.
			local itemstack = ItemStack(self.itemstring)
			local callback = itemstack:get_definition().on_pickup
			local ret = callback(itemstack, hitter,
					{type = "object", ref = self.object}, ...)

			if not ret then return end -- Don't modify (and don't reset rotation)

			itemstack = ItemStack(ret)

			-- Handle the leftover itemstack
			if itemstack:is_empty() then
				self.itemstring = ""
				self.object:remove()
			else
				self:set_item(itemstack)
			end
		else
			-- old method of pickup for backwards compatibility
			local inv = hitter:get_inventory()

			if inv then

				local left = inv:add_item("main", self.itemstring)

				if left and not left:is_empty() then
					self:set_item(left) ; return
				end
			end

			self.itemstring = ""
			self.object:remove()
		end
	end
})


print("[MOD] Built-in Item loaded")
