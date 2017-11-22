-- cell_base.lua


--[[
    Отдельная ячейка имеет такие атрибуты:
    - ID
    - позиция
    - название
    - тип тайла 
    - тайл
    - сообщение при нахождении шероя на этом тайле
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

function Base:init(data)
    self.ID = data.ID
    self.x = data.x or nil
    self.y = data.y or nil
    self.name = data.name
    self.tiletype = data.tiletype
    self.tile = data.tile
    self.standmsg = data.standmsg or nil
    self.walkable = data.walkable
    self.transparent = data.transparent
    self.explored = data.explored
    self.shaded = data.shaded
    
    self.creature = {}
    self.object = {}
    
    self.cancreature = data.cancreature
    self.canobject = data.canobject
end

function Base:setPosition(x, y)
    self.x = x
    self.y = y
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

function Base:getName()
    return self.name
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

function Base:getType()
    return self.tiletype
end

function Base:isType(tiletype)
    if tiletype == self.tiletype then
        return true
    else
        return false
    end
end

function Base:getMsg()
    return self.standmsg
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
    if self.cancreature and not self:isCreature() then
        return true
    else
        return false
    end
end

function Base:canObject()
    if self.canobject and not self:isObject() then
        return true
    else
        return false
    end
end

return Base
