local H_LAG = caverealms.config.h_lag --15 --max height for stalagmites
local H_LAC = caverealms.config.h_lac --20 --...stalactites
local H_CRY = caverealms.config.h_cry --9 --max height of glow crystals
local H_CLAC = caverealms.config.h_clac --13 --max height of glow crystal stalactites


-- Contend ID's --

local c_air = minetest.get_content_id("air")
local c_stone = minetest.get_content_id("default:stone")
local c_ice = minetest.get_content_id("default:ice")
local c_meseore = minetest.get_content_id("default:stone_with_mese")

local c_salt = minetest.get_content_id("caverealms:salt_crystal")
local c_crystal = minetest.get_content_id("caverealms:glow_crystal")
local c_crystore = minetest.get_content_id("caverealms:glow_ore")
local c_emerald = minetest.get_content_id("caverealms:glow_emerald")
local c_emore = minetest.get_content_id("caverealms:glow_emerald_ore")
local c_mesecry = minetest.get_content_id("caverealms:glow_mese")
local c_ruby = minetest.get_content_id("caverealms:glow_ruby")
local c_rubore = minetest.get_content_id("caverealms:glow_ruby_ore")
local c_ameth = minetest.get_content_id("caverealms:glow_amethyst")
local c_amethore = minetest.get_content_id("caverealms:glow_amethyst_ore")
local c_thinice = minetest.get_content_id("caverealms:thin_ice")

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

-- FUNCTIONS --

function caverealms:above_solid(x, y, z, area, data)

	local ai = area:index(x, y + 1, z - 3)

	if data[ai] == c_air or data[ai] == c_ignore then
		return false
	end

	return true
end


function caverealms:below_solid(x, y, z, area, data)

	local ai = area:index(x, y - 1, z - 3)

	if data[ai] == c_air or data[ai] == c_ignore then
		return false
	end

	return true
end

local random = math.random
local abs = math.abs

--stalagmite spawner
function caverealms:stalagmite(x, y, z, area, data)

	if not caverealms:below_solid(x, y, z, area, data) then
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
function caverealms:stalactite(x, y, z, area, data)

	if not caverealms:above_solid(x, y, z, area, data) then
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
function caverealms:crystal_stalagmite(x, y, z, area, data, biome)

	if not caverealms:below_solid(x, y, z, area, data) then
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
function caverealms:crystal_stalactite(x, y, z, area, data, biome)

	if not caverealms:above_solid(x, y, z, area, data) then
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
function caverealms:salt_stalagmite(x, y, z, area, data, biome)

	if not caverealms:below_solid(x, y, z, area, data) then
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
function caverealms:giant_shroom(x, y, z, area, data)

	if not caverealms:below_solid(x, y, z, area, data) then
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
