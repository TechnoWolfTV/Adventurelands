unused_args = false
allow_defined_top = true
max_line_length = 110

globals = {
    "minetest",
    "core",
    "facade",
}

read_globals = {
    string = {fields = {"split", "trim"}},
    table = {fields = {"copy", "getn"}},

    "default",
    "chisel",
}
