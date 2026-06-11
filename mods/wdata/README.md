## World Data Manager library for Luanti

### Description:

A [Luanti] library for managing data files in the world directory.

It takes a little work to read from & write to data in the world directory. `wdata` aims to make
that easier by utilizing just two simple methods.

This mod is essentially an alternative to Luanti's built-in [StorageRef] & was created before I
realized the implementation existed. Some may still find wdata useful as it does allow for
customizing sub-directories & filenames.

<img src="screenshot.png" alt="icon" width="100px" />

### Licensing:

- Code: [MIT](LICENSE.txt)
- Icon: [CC0](https://openclipart.org/detail/270878)

### Usage:

There are two methods:

```
- wdata.read(fname)
  - reads json data from file in world directory & converts to a table.
  - fname:  File basename without suffix (e.g. "my_config" or "my_mod/my_config").

- wdata.write(fname, data[, flags])
  - converts table to json data & writes to file in world directory.
  - fname:  File basename without suffix (e.g. "my_config" or "my_mod/my_config").
  - data:   Table containing data to be exported.
  - flags: Table of modifying flags.
    - styled: Outputs in a human-readable format if this is set (default: true).
    - null_to_table: "null" values will be converted to tables in output (default: `false`).
```

### Requirements:

```
Depends:          none
Optional depends: none
```

### Links

- [![ContentDB](https://content.luanti.org/packages/AntumDeluge/wdata/shields/title/)](https://content.luanti.org/packages/AntumDeluge/wdata/)
- [Forum](https://forum.luanti.org/viewtopic.php?t=26804)
- Git repos:
    - [Codeberg](https://codeberg.org/AntumLuanti/mod-wdata)
    - [GitHub](https://github.com/AntumMT/mod-wdata)
    - [GitLab](https://gitlab.com/AntumMT/mod-wdata)
- [Reference](https://antummt.github.io/mod-wdata/docs/reference/)
- [Changelog](changelog.txt)
- [TODO](TODO.txt)


[Luanti]: https://www.luanti.org/
[StorageRef]: https://github.com/luanti-org/luanti/blob/c9144ae/doc/lua_api.txt#L6883
