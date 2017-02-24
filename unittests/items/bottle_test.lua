-- модульные тесты для bottle

local Bottle = require "items.bottle"

local function test_init()
    local bt = Bottle:new()
    
    assert(is("bottle", bt.name))
    assert(is("|"), bt.tile)
end