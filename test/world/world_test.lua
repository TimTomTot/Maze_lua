--  lua -e'package.path = package.path .. ";../lib/?/init.lua;../lib/?.lua;../src/?.lua"' ../lib/testy.lua ./world/world_test.lua


require "const"
local World = require "world.world"


local function test_CheckParseMap()
	local tWorld = World:new()

	local tMap = [[
##########
#........#
##########]]

	tWorld:parseMap(tMap)

	local mapX, mapY = tWorld:getMapSize()

	assert(is_eq(mapX, 10))
	assert(is_eq(mapY, 3))
end