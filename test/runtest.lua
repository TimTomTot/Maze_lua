-- runtest.lua


package.path = package.path .. ";../lib/?/init.lua;../lib/?.lua;../src/?.lua"



local luaunit = require "luaunit.luaunit"

require "world_test.cell_base_test"
require "world_test.map_test"


os.exit(luaunit.LuaUnit.run())

