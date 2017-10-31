-- lua -e'package.path = package.path .. ";../lib/?/init.lua;../lib/?.lua;../src/?.lua"' ../lib/testy.lua ./view/layer_map_test.lua


local matrix = require "utils.matrix"
local MapLayer = require "view.layer_base"


local function test_CheckLayerMap()
    local initdata = {
        name = "map",
        W = 5,
        H = 3,
        avalibleTiles = {
            ".",
            "#",
            "-",
            "+",
            ">"
        },
        defaultTile = "."        
    }
    
    local tLayer = MapLayer:new(initdata)
    
    local tMapMatrix = matrix:new(5, 3)
    tMapMatrix:set(1, 1, "#")
    tMapMatrix:set(2, 1, ".")
    tMapMatrix:set(3, 1, ">")
    tMapMatrix:set(4, 1, "+")
    tMapMatrix:set(5, 1, "-")
    
    tMapMatrix:set(1, 2, "M")
    tMapMatrix:set(2, 2, "?")
    
    tLayer:updateLayer(tMapMatrix)
    
    local tData = tLayer:getLayer()
    
    assert(is_eq(tData.map:get(1, 1), "#"))
    assert(is_eq(tData.map:get(2, 1), "."))
    assert(is_eq(tData.map:get(3, 1), ">"))
    assert(is_eq(tData.map:get(4, 1), "+"))
    assert(is_eq(tData.map:get(5, 1), "-"))
    
    assert(is_eq(tData.map:get(1, 2), "."))
    assert(is_eq(tData.map:get(2, 2), "."))
    
    assert(is_eq(tData.map:get(2, 3), tData.map.empty))
    
    local tNewMatrix = matrix:new(5, 3)
    
    tNewMatrix:set(1, 1, ">")
    
    tLayer:updateLayer(tNewMatrix)
    
    assert(is_eq(tData.map:get(1, 1), ">"))
    assert(is_eq(tData.map:get(2, 1), tData.map.empty))
    assert(is_eq(tData.map:get(3, 1), tData.map.empty))
    assert(is_eq(tData.map:get(4, 1), tData.map.empty))
    assert(is_eq(tData.map:get(5, 1), tData.map.empty))
    
end


