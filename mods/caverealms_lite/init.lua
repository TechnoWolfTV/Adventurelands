caverealms = {} --create a container for functions and constants

--grab a shorthand for the filepath of the mod
local modpath = minetest.get_modpath(minetest.get_current_modname())

--load companion lua files
dofile(modpath .. "/config.lua") --configuration file; holds various constants
dofile(modpath .. "/crafting.lua") --crafting recipes
dofile(modpath .. "/nodes.lua") --node definitions
dofile(modpath .. "/stairs.lua") --stairs (mod auto-detected)
dofile(modpath .. "/plants.lua")
dofile(modpath .. "/functions.lua") --function definitions

if minetest.get_modpath("mobs_monster")
and caverealms.config.dm_spawn == true then
	dofile(modpath .. "/dungeon_master.lua") --special DMs for DM's Lair biome
end

-- Parameters

local YMIN = caverealms.config.ymin -- Approximate realm limits.
local YMAX = caverealms.config.ymax
local TCAVE = caverealms.config.tcave --0.5 -- Cave threshold. 1 = small rare caves, 0.5 = 1/3rd ground volume, 0 = 1/2 ground volume
local BLEND = 128 -- Cave blend distance near YMIN, YMAX

local STAGCHA = caverealms.config.stagcha --0.002 --chance of stalagmites
local STALCHA = caverealms.config.stalcha --0.003 --chance of stalactites
local CRYSTAL = caverealms.config.crystal --0.007 --chance of glow crystal formations
local GEMCHA = caverealms.config.gemcha --0.03 --chance of small glow gems
local MUSHCHA = caverealms.config.mushcha --0.04 --chance of mushrooms
local MYCCHA = caverealms.config.myccha --0.03 --chance of mycena mushrooms
local WORMCHA = caverealms.config.wormcha --0.03 --chance of glow worms
local GIANTCHA = caverealms.config.giantcha --0.001 -- chance of giant mushrooms
local ICICHA = caverealms.config.icicha --0.035 -- chance of icicles
local FLACHA = caverealms.config.flacha --0.04 --chance of constant flames

local DM_TOP = caverealms.config.dm_top -- -4000 --level at which Dungeon Master Realms start to appear
local DM_BOT = caverealms.config.dm_bot -- -5000 --level at which "" ends
local DEEP_CAVE = caverealms.config.deep_cave -- -7000 --level at which deep cave biomes take over

-- 2D noise for biome

local np_biome = {
	offset = 0,
	scale = 1,
	spread = {x = 200, y = 200, z = 200},
	seed = 9130,
	octaves = 3,
	persist = 0.5
}

-- Stuff

subterrain = {}
local random = math.random


-- Content IDs
local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_water = minetest.get_content_id("default:water_source")
local c_lava = minetest.get_content_id("default:lava_source")
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

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)

	--if out of range of caverealms limits
	if minp.y > YMAX or maxp.y < YMIN then
		return --quit; otherwise, you'd have stalagmites all over the place
	end

	-- uncomment if using timer at bottom
--	local t1 = os.clock()

	--easy reference to commonly used values
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z

	--print ("[caverealms] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()

	--mandatory values
	local sidelen = x1 - x0 + 1 --length of a mapblock
	local chulens = {x = sidelen, y = sidelen, z = sidelen} --table of chunk edges
	local chulens2D = {x = sidelen, y = sidelen, z = 1}
	local minposxyz = {x = x0, y = y0, z = z0} --bottom corner
	local minposxz = {x = x0, y = z0} --2D bottom corner

	--2D noise for biomes (will be 3D humidity/temp later)
	local nvals_biome

	nvals_biome = minetest.get_perlin_map(np_biome,
			chulens2D):get_2d_map_flat({x = x0 + 150, y = z0 + 50})

	local nixyz = 1 --3D node index
	local nixz = 1 --2D node index
	local nixyz2 = 1 --second 3D index for second loop

	local vi, ai, aii, bi, bbi, bbbi, c_selected_worm, is_deep
	local biome, n_biome, gems, gidx, spikes, sidx

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
							caverealms:stalactite(x, y, z, area, data)
						end

						if random() < CRYSTAL then
							caverealms:crystal_stalactite(x, y, z, area, data, biome)
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
								caverealms:giant_shroom(x, y, z, area, data)
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
								caverealms:salt_stalagmite(x, y, z, area, data)
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
							caverealms:stalagmite(x, y, z, area, data)
						end

						if random() < CRYSTAL then
							caverealms:crystal_stalagmite(x, y, z, area, data, biome)
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

	--write it to world
	vm:write_to_map(data)
--	vm:update_map()

	--local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	--print ("[caverealms] "..chugent.." ms") --tell people how long
end)


print("[MOD] Caverealms Lite loaded")
