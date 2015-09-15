framexml2lua
============

framexml2lua is a tool for quickly converting WoW addon XML to its Lua equivalent. It outputs valid but suboptimal code, as a starting point for porting XML-based addons to pure Lua. Manual editing of the generated code is highly recommended.

**Warning**: Always validate your input files (and remove Unicode BOM) before attempting to convert them; LuaXML's parser may OOM or segfault on malformed XML. Furthermore, output of framexml2lua is *not* guaranteed to be correct or safe; use common sense and read the Lua before running it yourself. **I take no responsibility for ~~sharded purples~~ ~~empty guild banks~~ _any_ results of running code generated with this tool. Use at your own risk!**

Usage: `framexml2lua.lua /path/to/input.xml >/path/to/output.lua`

Dependencies:

* Lua 5.1
* LuaXML module. <http://viremo.eludi.net/LuaXML/>
