-- модульные тесты для world_map
-- запуск
-- lua -e'package.path = package.path .. ";../lib/?/init.lua;../lib/?.lua;../src/?.lua"' ../lib/testy.lua ./world/world_map_test.lua


local Map = require "world.world_map"


local function test_initNotString()
    local tInitdata = {}
    tInitdata.map = 11

    assert(
        raises(
            "Map data is not string",
            Map.new,
            Map,
            tInitdata
        )
    )
end


local function test_getMapSizes()
    local tInitdata = {}
    tInitdata.map = [[
########
#......#
########]]
    
    local tMap = Map:new(tInitdata)
    
    assert(is_eq(tMap:getWidht(), 8))
    assert(is_eq(tMap:getHeight(), 3))
end 