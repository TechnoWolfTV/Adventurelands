-- painting - in-game painting for minetest

function painting.compress(string)
  return minetest.encode_base64(minetest.compress(string, "deflate"))
end

function painting.decompress(string)
  return minetest.decompress(minetest.decode_base64(string), "deflate")
end

function painting.to_imagestring(data, res)
	if not data then
		minetest.log("error", "[painting] missing data")
		return
	end
	local cols = {}
	for y = 0, res - 1 do
		local xs = data[y]
		for x = 0, res - 1 do
			local col = xs[x]
			--if col ~= "white" then
				cols[col] = cols[col] or {}
				cols[col][#cols[col]+1] = {y, x}
			--end
		end
	end
	local t,n = {},1
	local groupopen = "([combine:"..res.."x"..res
	for hexcolour,ps in pairs(cols) do
		t[n] = groupopen
		n = n+1
		for _,p in pairs(ps) do
			local y,x = unpack(p)
			t[n] = ":"..p[1]..","..p[2].."=w.png"
			n = n+1
		end
		t[n] = "^[colorize:#"..hexcolour..")^"
		n = n+1
	end
	n = n-1
	if n == 0 then
		minetest.log("error", "[painting] no texels")
		return "w.png"
	end
	t[n] = t[n]:sub(1,-2)
	--print("Image string len: "..string.len(table.concat(t)))
	return table.concat(t)
end

function painting.old_compress(string)
  return minetest.compress(string, "deflate")
end

function painting.old_decompress(string)
  return minetest.decompress(string, "deflate")
end

