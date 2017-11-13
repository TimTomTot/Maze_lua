-- фабрика с предметами

local class = require "30log"

local IDMaker = require "utils.idmaker"
local Bottle = require "items.bottle"

local ItemsFactory = class("ItemsFactory")

function ItemsFactory:init()
	self.idmaker = IDMaker:new()
end

function ItemsFactory:newitem(name)
    local it = nil
    
    if name == "bottle" or name == "|" then
        local newid = self.idmaker:getID()

        it = Bottle:new({ID = newid})
    end
    
    return it
end

return ItemsFactory
