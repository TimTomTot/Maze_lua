-- cellfactopy_test.lua
-- lua -e'package.path = package.path .. ";../lib/?/init.lua;../lib/?.lua;../src/?.lua"' ../lib/testy.lua ./world/cellfactory_test.lua


local CellFactory = require "world.cellfactory"


local function test_CheckCellGeneration()
    local tFactory = CellFactory:new()
    
    local tWall1 = tFactory:generateCell("#")
    local tWall2 = tFactory:generateCell("wall")
    
    local tFloor1 = tFactory:generateCell(".")
    local tFloor2 = tFactory:generateCell("floor")
    
    local tOdoor1 = tFactory:generateCell("-")
    local tOdoor2 = tFactory:generateCell("opendoor")
    
    local tCdoor1 = tFactory:generateCell("+")
    local tCdoor2 = tFactory:generateCell("closedoor")
    
    local tStairs1 = tFactory:generateCell(">")
    local tStairs2 = tFactory:generateCell("stairs")    
    
    local tDefault1 = tFactory:generateCell("й")
    local tDefault2 = tFactory:generateCell("unknown tile name")
    
    assert(is(tWall1.tile, "#"))
    assert(is(tWall1.ID, 1))
    
    assert(is(tWall2.tile, "#"))
    assert(is(tWall2.ID, 2))
    
    assert(is(tFloor1.tile, "."))
    assert(is(tFloor1.ID, 3))
    
    assert(is(tFloor2.tile, "."))
    assert(is(tFloor2.ID, 4))
    
    assert(is(tOdoor1.tile, "-"))
    assert(is(tOdoor1.ID, 5))
    
    assert(is(tOdoor2.tile, "-"))
    assert(is(tOdoor2.ID, 6))
    
    assert(is(tDefault1.tile, "#"))
    assert(is(tDefault1.ID, 11))
    
    assert(is(tDefault2.tile, "#"))
    assert(is(tDefault2.ID, 12))
end

