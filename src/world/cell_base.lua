-- cell_base.lua


--[[
    Отдельная ячейка имеет такие атрибуты:
    - ID
    - позиция
    - название
    - тайл
    - проходима
    - прозрачна
    - разведана
    - затенена
    - существо
    - предмет  
    - может ли размещаться предмет
    - может ли размещаться существо     
--]]


local class = require "30log"


local Base = class("BaseCell")

function Base:init()

end

function Base:getX()
    return self.x
end

function Base:getY()
    return self.y
end

function Base:getPosition()
    return self.x, self.y
end

function Base:isWalkable()
    return self.walkable
end

function Base:isTransparent()
    return self.transparent
end

function Base:isExplored()
    return self.explored
end

function Base:isShaded()
    return self.shaded
end

function Base:isCreature()
    if next (self.creature) then
        return true
    else
        return false
    end
end

function Base:getCreature()
    if self:isCreature() then
        return self.creature[1]
    else
        error("It is no creature on cell " .. tostring(self.ID), 0)
    end
end

function Base:setCreature(creature)
    if not self:isCreature() then
        table.insert(self.creature, creature)
    else
        error("In cell " .. tostring(self.ID) .. " alredy stay creature", 0)
    end
end

function Base:removeCreature()
    local cr = self:getCreature()
    
    table.remove(self.creature)
    
    return cr
end

function Base:isObject()
    if next(self.object) then
        return true
    else
        return false
    end
end

function Base:getObject()
    if self:isObject() then
        return self.object[1]
    else
        error("It is no object on cell " .. tostring(self.ID), 0)
    end
end

function Base:setObject(object)
    if not self:isObject() then
        table.insert(self.object, object)
    else
        error("Cell " .. tostring(self.ID) .. " alredy hawe object", 0)
    end
end

function Base:removeObject()
    local obj = self:getObject()
    
    table.remove(self.object)
    
    return obj
end

function Base:explore()
    self.explored = true
end

function Base:forget()
    self.explored = false
end

function Base:illuminate()
    self.shaded = false
end

function Base:obscure()
    self.shaded = true
end

function Base:canCreature()
    return self.cancreature
end

function Base:canObject()
    return self.canobject
end

return Base

