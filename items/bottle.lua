-- бутылочка - тестовый объект на карте

local class = require "30log"

local Item = require "items.item"

local Bottle = Item:extend("Bottle")

function Bottle:init()
    local data = {
        name = "bottle",
        tile = "|"
    }
    
    self.super.init(self, data)
end

return Bottle
