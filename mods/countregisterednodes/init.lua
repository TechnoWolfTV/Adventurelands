minetest.register_chatcommand("count_registered_nodes", {
	params = "",
	description = "counts the total number of registered nodes",
	privs = {
		server = true
	},
	func = function(name, param)
		minetest.after(0, function()
		local cnt = 0
		for name in pairs(minetest.registered_nodes) do
		cnt = math.max(cnt, minetest.get_content_id(name))
		end
		minetest.log("Registered nodes = "..cnt)
		end)
end
})