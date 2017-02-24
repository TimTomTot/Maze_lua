-- фабрика с предметами

local class = require "30log"

local Bottle = require "items.bottle"

local ItemsFactory = class("ItemsFactory")

function ItemsFactory:newitem(name)
    local it = nil
    
    if name == "bottle" or name == "|" then
        it = Bottle:new()
    else
        error(tostring(name) .. " Unknown item type!!", 0)
    end
    
    return it
end

return ItemsFactory
