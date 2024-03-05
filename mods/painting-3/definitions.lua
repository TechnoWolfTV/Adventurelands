
painting.hexcolors = {
	white = "ffffff", yellow = "fff000",
	orange = "ff6c00", red = "ff0000",
	violet = "8a00ff", blue = "000cff",
	green = "0cff00", magenta = "fc00ff",
	cyan = "00ffea", grey = "bebebe",
	dark_grey = "7b7b7b", black = "000000",
	dark_green = "006400", brown = "964b00",
	pink = "ffc0cb"
}

painting.colors = {}

painting.revcolors = {
	"white", "dark_green", "grey", "red", "brown", "cyan", "orange", "violet",
	"dark_grey", "pink", "green", "magenta", "yellow", "black", "blue"
}

if minetest.get_modpath("mcl_dye") then
	painting.hexcolors.lightblue = "00aaff"
end

for i, color in ipairs(painting.revcolors) do
	painting.colors[color] = i
end

