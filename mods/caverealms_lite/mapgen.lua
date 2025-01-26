local modpath = minetest.get_modpath("caverealms")
local config = dofile(modpath .. "/config.lua")
local async_env = minetest.save_gen_notify ~= nil

-- Basic params
local YMIN = config.ymin --Approximate realm limits.
local YMAX = config.ymax

local STAGCHA = config.stagcha --chance of stalagmites
local STALCHA = config.stalcha --chance of stalactites
local CRYSTAL = config.crystal --chance of glow crystal formations
local GEMCHA = config.gemcha --chance of small glow gems
local MUSHCHA = config.mushcha --chance of mushrooms
local MYCCHA = config.myccha --chance of mycena mushrooms
local WORMCHA = config.wormcha --chance of glow worms
local GIANTCHA = config.giantcha --chance of giant mushrooms
local ICICHA = config.icicha -- chance of icicles
local FLACHA = config.flacha --chance of constant flames

local DM_TOP = config.dm_top --level at which Dungeon Master Realms start to appear
local DM_BOT = config.dm_bot --level at which "" ends
local DEEP_CAVE = config.deep_cave --level at which deep cave biomes take over

local H_LAG = config.h_lag --max height for stalagmites
local H_LAC = config.h_lac --...stalactites
local H_CRY = config.h_cry --max height of glow crystals
local H_CLAC = config.h_clac --max height of glow crystal stalactites

-- 2D noise for biome
local np_biome = {
	offset = 0,
	scale = 1,
	spread = {x = 200, y = 200, z = 200},
	seed = 9130,
	octaves = 3,
	persist = 0.5
}

local random = math.random
local abs = math.abs

-- Content IDs
local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_ice = minetest.get_content_id("default:ice")
local c_thinice = minetest.get_content_id("caverealms:thin_ice")
local c_crystal = minetest.get_content_id("caverealms:glow_crystal")
local c_gem1 = minetest.get_content_id("caverealms:glow_gem")
local c_saltgem1 = minetest.get_content_id("caverealms:salt_gem")
local c_spike1 = minetest.get_content_id("caverealms:spike")
local c_moss = minetest.get_content_id("caverealms:stone_with_moss")
local c_lichen = minetest.get_content_id("caverealms:stone_with_lichen")
local c_algae = minetest.get_content_id("caverealms:stone_with_algae")
local c_salt = minetest.get_content_id("caverealms:stone_with_salt")
local c_hcobble = minetest.get_content_id("caverealms:hot_cobble")
local c_gobsidian = minetest.get_content_id("caverealms:glow_obsidian")
local c_gobsidian2 = minetest.get_content_id("caverealms:glow_obsidian_2")
local c_coalblock = minetest.get_content_id("default:coalblock")
local c_desand = minetest.get_content_id("default:desert_sand")
local c_coaldust = minetest.get_content_id("caverealms:coal_dust")
local c_fungus = minetest.get_content_id("caverealms:fungus")
local c_mycena = minetest.get_content_id("caverealms:mycena")
local c_worm = minetest.get_content_id("caverealms:glow_worm")
local c_worm_green = minetest.get_content_id("caverealms:glow_worm_green")
local c_fire_vine = minetest.get_content_id("caverealms:fire_vine")
local c_iciu = minetest.get_content_id("caverealms:icicle_up")
local c_icid = minetest.get_content_id("caverealms:icicle_down")
local c_flame = minetest.get_content_id("fire:permanent_flame")

local c_meseore = minetest.get_content_id("default:stone_with_mese")
local c_crystore = minetest.get_content_id("caverealms:glow_ore")
local c_emerald = minetest.get_content_id("caverealms:glow_emerald")
local c_emore = minetest.get_content_id("caverealms:glow_emerald_ore")
local c_mesecry = minetest.get_content_id("caverealms:glow_mese")
local c_ruby = minetest.get_content_id("caverealms:glow_ruby")
local c_rubore = minetest.get_content_id("caverealms:glow_ruby_ore")
local c_ameth = minetest.get_content_id("caverealms:glow_amethyst")
local c_amethore = minetest.get_content_id("caverealms:glow_amethyst_ore")

local c_gills = minetest.get_content_id("caverealms:mushroom_gills")
local c_stem, c_cap

if minetest.get_modpath("ethereal") then
	c_stem = minetest.get_content_id("ethereal:mushroom_trunk")
	c_cap = minetest.get_content_id("ethereal:mushroom")
else
	c_stem = minetest.get_content_id("caverealms:mushroom_stem")
	c_cap = minetest.get_content_id("caverealms:mushroom_cap")
end

local c_ignore = minetest.get_content_id("ignore")


-- Helpers
local function above_solid(x, y, z, area, data)

	local ai = area:index(x, y + 1, z - 3)

	if data[ai] == c_air or data[ai] == c_ignore then
		return false
	end

	return true
end


local function below_solid(x, y, z, area, data)

	local ai = area:index(x, y - 1, z - 3)

	if data[ai] == c_air or data[ai] == c_ignore then
		return false
	end

	return true
end

--stalagmite spawner
local function stalagmite(x, y, z, area, data)

	if not below_solid(x, y, z, area, data) then
		return
	end

	local top = random(6, H_LAG) --random height for the stalagmite
	local vi

	for j = 0, top do --y
		for k = -3, 3 do
			for l = -3, 3 do

				if j == 0 then

					if k * k + l * l <= 9 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = c_stone
					end

				elseif j <= top/5 then

					if k * k + l * l <= 4 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = c_stone
					end

				elseif j <= top / 5 * 3 then

					if k * k + l * l <= 1 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = c_stone
					end
				else
					vi = area:index(x, y + j, z - 3)
					data[vi] = c_stone
				end
			end
		end
	end
end


--stalactite spawner
local function stalactite(x, y, z, area, data)

	if not above_solid(x, y, z, area, data) then
		return
	end

	local bot = random(-H_LAC, -6) -- random height for the stalagmite
	local vi

	for j = bot, 0 do --y
		for k = -3, 3 do
			for l = -3, 3 do

				if j >= -1 then

					if k * k + l * l <= 9 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = c_stone
					end

				elseif j >= bot / 5 then

					if k * k + l * l <= 4 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = c_stone
					end

				elseif j >= bot / 5 * 3 then

					if k * k + l * l <= 1 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = c_stone
					end
				else
					vi = area:index(x, y + j, z - 3)
					data[vi] = c_stone
				end
			end
		end
	end
end


--glowing crystal stalagmite spawner
local function crystal_stalagmite(x, y, z, area, data, biome)

	if not below_solid(x, y, z, area, data) then
		return
	end

	--for randomness
	local mode = 1

	if random(15) == 1 then
		mode = 2
	end

	if biome == 3 then

		if random(25) == 1 then
			mode = 2
		else
			mode = 1
		end
	end

	if biome == 4 or biome == 5 then

		if random(3) == 1 then
			mode = 2
		end
	end

	local stalids = {
		{{c_crystore, c_crystal}, {c_emore, c_emerald}},
		{{c_emore, c_emerald}, {c_crystore, c_crystal}},
		{{c_emore, c_emerald}, {c_meseore, c_mesecry}},
		{{c_ice, c_thinice}, {c_crystore, c_crystal}},
		{{c_ice, c_thinice}, {c_crystore, c_crystal}},
		{{c_rubore, c_ruby}, {c_meseore, c_mesecry}},
		{{c_crystore, c_crystal}, {c_rubore, c_ruby}},
		{{c_rubore, c_ruby}, {c_emore, c_emerald}},
		{{c_amethore, c_ameth}, {c_meseore, c_mesecry}}
	}

	local nid_a
	local nid_b
	local nid_s = c_stone --stone base, will be rewritten to ice in certain biomes

	if biome > 3 and biome < 6 then

		if mode == 1 then
			nid_a = c_ice
			nid_b = c_thinice
			nid_s = c_ice
		else
			nid_a = c_crystore
			nid_b = c_crystal
		end

	elseif mode == 1 then
		nid_a = stalids[biome][1][1]
		nid_b = stalids[biome][1][2]
	else
		nid_a = stalids[biome][2][1]
		nid_b = stalids[biome][2][2]
	end

	local top = random(5, H_CRY) --random height for the stalagmite
	local vi

	for j = 0, top do --y
		for k = -3, 3 do
			for l = -3, 3 do

				if j == 0 then

					if k * k + l * l <= 9 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = nid_s
					end

				elseif j <= top / 5 then

					if k * k + l * l <= 4 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = nid_a
					end

				elseif j <= top / 5 * 3 then

					if k * k + l * l <= 1 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = nid_b
					end
				else
					vi = area:index(x, y + j, z - 3)
					data[vi] = nid_b
				end
			end
		end
	end
end


--crystal stalactite spawner
local function crystal_stalactite(x, y, z, area, data, biome)

	if not above_solid(x, y, z, area, data) then
		return
	end

	--for randomness
	local mode = 1

	if random(15) == 1 then
		mode = 2
	end

	if biome == 3 then

		if random(25) == 1 then
			mode = 2
		else
			mode = 1
		end
	end

	if biome == 4 or biome == 5 then

		if random(3) == 1 then
			mode = 2
		end
	end

	local stalids = {
		{{c_crystore, c_crystal}, {c_emore, c_emerald}},
		{{c_emore, c_emerald}, {c_crystore, c_crystal}},
		{{c_emore, c_emerald}, {c_meseore, c_mesecry}},
		{{c_ice, c_thinice}, {c_crystore, c_crystal}},
		{{c_ice, c_thinice}, {c_crystore, c_crystal}},
		{{c_rubore, c_ruby}, {c_meseore, c_mesecry}},
		{{c_crystore, c_crystal}, {c_rubore, c_ruby}},
		{{c_rubore, c_ruby}, {c_emore, c_emerald}},
		{{c_amethore, c_ameth}, {c_meseore, c_mesecry}}
	}

	local nid_a
	local nid_b
	local nid_s = c_stone --stone base, will be rewritten to ice in certain biomes

	if biome > 3 and biome < 6 then

		if mode == 1 then
			nid_a = c_ice
			nid_b = c_thinice
			nid_s = c_ice
		else
			nid_a = c_crystore
			nid_b = c_crystal
		end

	elseif mode == 1 then
		nid_a = stalids[biome][1][1]
		nid_b = stalids[biome][1][2]
	else
		nid_a = stalids[biome][2][1]
		nid_b = stalids[biome][2][2]
	end

	local bot = random(-H_CLAC, -6) --random height for the stalagmite
	local vi

	for j = bot, 0 do --y
		for k = -3, 3 do
			for l = -3, 3 do

				if j >= -1 then

					if k * k + l * l <= 9 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = nid_s
					end

				elseif j >= bot / 5 then

					if k * k + l * l <= 4 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = nid_a
					end

				elseif j >= bot / 5 * 3 then

					if k * k + l * l <= 1 then
						vi = area:index(x + k, y + j, z + l - 3)
						data[vi] = nid_b
					end
				else
					vi = area:index(x, y + j, z - 3)
					data[vi] = nid_b
				end
			end
		end
	end
end


--glowing crystal stalagmite spawner
local function salt_stalagmite(x, y, z, area, data, biome)

	if not below_solid(x, y, z, area, data) then
		return
	end

	local scale = random(2, 4)
	local vi

	if scale == 2 then

		for j = -3, 3 do
			for k = -3, 3 do

				vi = area:index(x + j, y, z + k)
				data[vi] = c_stone

				if abs(j) ~= 3 and abs(k) ~= 3 then
					vi = area:index(x + j, y + 1, z + k)
					data[vi] = c_stone
				end
			end
		end
	else
		for j = -4, 4 do
			for k = -4, 4 do

				vi = area:index(x + j, y, z + k)
				data[vi] = c_stone

				if abs(j) ~= 4 and abs(k) ~= 4 then
					vi = area:index(x + j, y + 1, z + k)
					data[vi] = c_stone
				end
			end
		end
	end

	for j = 2, scale + 2 do --y
		for k = -2, scale - 2 do
			for l = -2, scale - 2 do
				vi = area:index(x + k, y + j, z + l)
				data[vi] = c_salt -- make cube
			end
		end
	end
end


--function to create giant 'shrooms
local function giant_shroom(x, y, z, area, data)

	if not below_solid(x, y, z, area, data) then
		return
	end

	z = z - 5

	local vi

	--cap
	for k = -5, 5 do
	for l = -5, 5 do

		if k * k + l * l <= 25 then
			vi = area:index(x + k, y + 5, z + l)
			data[vi] = c_cap
		end

		if k * k + l * l <= 16 then
			vi = area:index(x + k, y + 6, z + l)
			data[vi] = c_cap
			vi = area:index(x + k, y + 5, z + l)
			data[vi] = c_gills
		end

		if k * k + l * l <= 9 then
			vi = area:index(x + k, y + 7, z + l)
			data[vi] = c_cap
		end

		if k * k + l * l <= 4 then
			vi = area:index(x + k, y + 8, z + l)
			data[vi] = c_cap
		end
	end
	end

	local ai

	--stem
	for j = 0, 5 do
		for k = -1, 1 do

			vi = area:index(x + k, y + j, z)

			data[vi] = c_stem

			if k == 0 then

				ai = area:index(x, y + j, z + 1)

				data[ai] = c_stem

				ai = area:index(x, y + j, z - 1)

				data[ai] = c_stem
			end
		end
	end
end

-- Generator

local data = {} -- localized data buffer to reduce waste of RAM

local function generate(vm, minp, maxp)

	--if out of range of caverealms limits
	if minp.y > YMAX or maxp.y < YMIN then
		return --quit; otherwise, you'd have stalagmites all over the place
	end

	local t1 = os.clock()

	--easy reference to commonly used values
	local x1, y1, z1 = maxp.x, maxp.y, maxp.z
	local x0, y0, z0 = minp.x, minp.y, minp.z

	local pos1, pos2 = vm:get_emerged_area()
	local area = VoxelArea:new{MinEdge = pos1, MaxEdge = pos2}

	vm:get_data(data)

	--mandatory values
	local sidelen = x1 - x0 + 1 --length of a mapblock
	local chulens2D = {x = sidelen, y = sidelen, z = 1}

	--2D noise for biomes (will be 3D humidity/temp later)
	local nvals_biome = minetest.get_perlin_map(np_biome, chulens2D):get_2d_map_flat(
			{x = x0 + 150, y = z0 + 50})

	local nixyz = 1 --3D node index
	local nixz = 1 --2D node index
	local nixyz2 = 1 --second 3D index for second loop

	local vi, ai, aii, bi, bbi, bbbi, c_selected_worm, is_deep
	local biome, n_biome

	for z = z0, z1 do -- for each xy plane progressing northwards

		--increment indices
		nixyz = nixyz + 1

		--decoration loop
		for y = y0, y1 do -- for each x row progressing upwards

			c_selected_worm = c_worm

			is_deep = false

			if y < DEEP_CAVE then
				is_deep = true
			end

			vi = area:index(x0, y, z)

			for x = x0, x1 do -- for each node do

				--determine biome
				biome = 0 --preliminary declaration
				n_biome = nvals_biome[nixz] --make an easier reference to the noise

				--compare noise values to determine a biome
				if n_biome <= -0.5 then

					if is_deep and n_biome <= -0.25 then
						biome = 8 --glow obsidian
					else
						biome = 2 --fungal
						c_selected_worm = c_worm_green
					end

				elseif n_biome < 0 then
					biome = 0 -- none

				elseif n_biome < 0.5 then

					if is_deep and n_biome <= 0.25 then
						biome = 7 --salt crystal
					else
						biome = 1 --moss
					end

				elseif n_biome < 0.65 then
					biome = 0

				elseif n_biome < 0.85 then

					if is_deep and n_biome <= 0.75 then
						biome = 9 --coal dust
					else
						biome = 3 --algae
						c_selected_worm = c_worm_green
					end
				else
					if is_deep and n_biome <= 0.95 then
						biome = 5 --deep glaciated
					else
						biome = 4 --glaciated
					end
				end

--print(biome)

				if biome > 0 then

					if y <= DM_TOP and y >= DM_BOT then
						biome = 6 --DUNGEON MASTER'S LAIR
						c_selected_worm = c_fire_vine
					end

					--ceiling
					ai = area:index(x, y + 1, z) --above index
					aii = area:index(x, y + 2, z) --above above index

					if data[aii] == c_stone
					and data[ai] == c_stone and data[vi] == c_air then --ceiling

						if random() < ICICHA and (biome == 4 or biome == 5) then
							data[vi] = c_icid
						end

						if random() < WORMCHA then

							data[vi] = c_selected_worm
							bi = area:index(x, y - 1, z)
							data[bi] = c_selected_worm

							if random(2) == 1 then

								bbi = area:index(x, y - 2, z)
								data[bbi] = c_selected_worm

								if random(2) == 1 then
									bbbi = area:index(x, y - 3, z)
									data[bbbi] = c_selected_worm
								end
							end
						end

						if random() < STALCHA then
							stalactite(x, y, z, area, data)
						end

						if random() < CRYSTAL then
							crystal_stalactite(x, y, z, area, data, biome)
						end
					end

					--ground
					bi = area:index(x, y - 1, z) --below index

					if data[bi] == c_stone and data[vi] == c_air then --ground

						ai = area:index(x, y + 1, z)

						--place floor material, add plants/decorations
						if biome == 1 then

							data[vi] = c_moss

							if random() < GEMCHA then
								data[ai] = c_gem1
							end

						elseif biome == 2 then

							data[vi] = c_lichen

							if random() < MUSHCHA then --mushrooms
								data[ai] = c_fungus
							end

							if random() < MYCCHA then --mycena mushrooms
								data[ai] = c_mycena
							end

							if random() < GIANTCHA then --giant mushrooms
								giant_shroom(x, y, z, area, data)
							end

						elseif biome == 3 then

							data[vi] = c_algae

						elseif biome == 4 then

							data[vi] = c_thinice
							bi = area:index(x, y - 1, z)
							data[bi] = c_thinice

							if random() < ICICHA then --if glaciated, place icicles
								data[ai] = c_iciu
							end

						elseif biome == 5 then

							data[vi] = c_ice
							bi = area:index(x, y - 1, z)
							data[bi] = c_ice

							if random() < ICICHA then --if glaciated, place icicles
								data[ai] = c_iciu
							end

						elseif biome == 6 then

							data[vi] = c_hcobble

							if random() < FLACHA then --neverending flames
								data[ai] = c_flame
							end

						elseif biome == 7 then

							bi = area:index(x, y - 1, z)
							data[vi] = c_salt
							data[bi] = c_salt

							if random() < GEMCHA then
								data[ai] = c_saltgem1
							end

							if random() < STAGCHA then
								salt_stalagmite(x, y, z, area, data)
							end

						elseif biome == 8 then

							bi = area:index(x, y - 1, z)

							if random() < 0.5 then
								data[vi] = c_gobsidian
								data[bi] = c_gobsidian
							else
								data[vi] = c_gobsidian2
								data[bi] = c_gobsidian2
							end

							if random() < FLACHA then --neverending flames
								data[ai] = c_flame
							end

						elseif biome == 9 then

							bi = area:index(x, y - 1, z)

							if random() < 0.05 then
								data[vi] = c_coalblock
								data[bi] = c_coalblock

							elseif random() < 0.15 then
								data[vi] = c_coaldust
								data[bi] = c_coaldust
							else
								data[vi] = c_desand
								data[bi] = c_desand
							end

							if random() < FLACHA * 0.75 then --neverending flames
								data[ai] = c_flame
							end

							if random() < GEMCHA then
								data[ai] = c_spike1
							end
						end

						if random() < STAGCHA then
							stalagmite(x, y, z, area, data)
						end

						if random() < CRYSTAL then
							crystal_stalagmite(x, y, z, area, data, biome)
						end
					end
				end

				nixyz2 = nixyz2 + 1
				nixz = nixz + 1
				vi = vi + 1
			end

			nixz = nixz - sidelen --shift the 2D index back
		end

		nixz = nixz + sidelen --shift the 2D index up a layer
	end

	--send data back to voxelmanip
	vm:set_data(data)

	--calc lighting
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()

	-- write it to world
	if not async_env then
		vm:write_to_map(data)
	end

	data = {} -- blank data

	collectgarbage("collect") -- Gargabge collection doesn't run automatically in mapgen env
--[[
	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took

	print("[caverealms] Took "..chugent.." ms generating "
		.. minetest.pos_to_string(minp) .. " to "
		.. minetest.pos_to_string(maxp)) --tell people how long
		print("[caverealms] Used memory: " .. collectgarbage("count") / 1024 .. " MiB")
]]
end

if async_env then -- async env (5.9+)
	minetest.register_on_generated(function(vm, minp, maxp, blockseed)
		generate(vm, minp, maxp)
	end)
else -- main thread (5.8 and earlier)
	minetest.register_on_generated(function(minp, maxp, blockseed)
		generate(minetest.get_mapgen_object("voxelmanip"), minp, maxp)
	end)
end
