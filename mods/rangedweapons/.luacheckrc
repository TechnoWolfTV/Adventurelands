std = "minetest+min"

unused = false
max_line_length = 1000

globals = {
	"rangedweapons_reload_gun",
	"rangedweapons_yeet",
	"rangedweapons_shoot_gun",
	"rangedweapons_single_load_gun",
	"rangedweapons_shoot_powergun",
	"rangedweapons_gain_skill",
	"rangedweapons_launch_projectile",
	"eject_shell",
	"rangedweapons_unload_gun",
	"make_sparks",
	"projectile_kb",
	"rangedweapons_hud",
	"rangedweapons_admin",
	"rangedweapons_ammo_allowed",
	"rangedweapons_item_active",
	"rangedweapons_skill_messages",
	"rangedweapons_get_skills"
}

read_globals = {
	"core",
	"tnt",
	"default",
	"armor",
	-- read defensively; the panel hides recipe entries in this mod's cache
	"unified_inventory"
}
