-- тест фабрики предметов

local ItemsFactory = require "items.itemsfactory"
local Bottle = require "items.bottle"

local function test_factoryReturns()
    local factory = ItemsFactory:new()
    
    local newitem = ItemsFactory:newitem("bottle")
    local newbottle = ItemsFactory:newitem("|")
        
    assert(newbottle:instanceOf(Bottle))    
    assert(newitem:instanceOf(Bottle))
    assert(
        raises(
            "nil Unknown item type!!", 
            ItemsFactory.newitem,
            "x"
        )
    )
end
