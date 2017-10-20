-- wall.lua

--[[
    ячейка стены
    
    Отдельная ячейка имеет такие атрибуты:
    - ID
    - название
    - тайл
    - проходима
    - прозрачна
    - разведана
    - затенена
    - существо
    - предмет    
--]]


local class = require "30log"


local Wall = class("WallCell")

function Wall:init(data)
    self.ID = data.ID
    self.name = "wall"
    self.tile = "#"
    self.walkable = false
    self.transparent = false
    self.explored = false
    self.shaded = true
    
    self.creature = {}
    self.object = {}
end

-- методы доступа
function Wall:isWalkable()
    return self.walkable
end

function Wall:isTransparent()
    return self.transparent
end

function Wall:isExplored()
    return self.explored
end

function Wall:isShaded()
    return self.shaded
end

function Wall:isCreature()
    if next (self.creature) then
        return true
    else
        return false
    end
end

function Wall:getCreature()
    if self:isCreature() then
        return self.creature[1]
    else
        error("It is no creature on cell " .. tostring(self.ID), 0)
    end
end

function Wall:setCreature(creature)
    if not self:isCreature() then
        table.insert(self.creature, creature)
    else
        error("In cell " .. tostring(self.ID) .. " alredy stay creature", 0)
    end
end

function Wall:removeCreature()
    local cr = self:getCreature()
    
    table.remove(self.creature)
    
    return cr
end

function Wall:isObject()
    if next(self.object) then
        return true
    else
        return false
    end
end

function Wall:getObject()
    if self:isObject() then
        return self.object[1]
    else
        error("It is no object on cell " .. tostring(self.ID), 0)
    end
end

function Wall:setObject(object)
    if not self:isObject() then
        table.insert(self.object, object)
    else
        error("Cell " .. tostring(self.ID) .. " alredy hawe object", 0)
    end
end

function Wall:removeObject()
    local obj = self:getObject()
    
    table.remove(self.object)
    
    return obj
end

function Wall:explore()
    self.explored = true
end

function Wall:forget()
    self.explored = false
end

function Wall:illuminate()
    self.shaded = false
end

function Wall:obscure()
    self.shaded = true
end

return Wall

