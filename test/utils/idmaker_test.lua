-- test IDmaker

-- lua -e'package.path = package.path .. ";../lib/?/init.lua;../lib/?.lua;../src/?.lua"' ../lib/testy.lua ./utils/idmaker_test.lua


local Maker = require "utils.idmaker"


local function test_GetID()
    local tMaker = Maker:new()
    
    assert(is(tMaker:getID(), 1))
    assert(is(tMaker:getID(), 2))
    assert(is(tMaker:getID(), 3))
    
    local tNewMaker = Maker:new()
    
    assert(is(tNewMaker:getID(), 4))
    assert(is(tNewMaker:getID(), 5))
    
    assert(is(tMaker:getID(), 6))
    assert(is(tNewMaker:getID(), 7))
end
