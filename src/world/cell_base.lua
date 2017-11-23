--- 
-- Базовый класс, описывающий ячейку на карте игрового мира
-- @module CellBase


local class = require "30log"


local Base = class("BaseCell")

---
-- Конструктор
-- @param data таблица со всеми инициализирующими значениями:
-- @param data.ID уникальный числовой идентификатор ячейки
-- @param data.x х-координата ячейки (необязательный параметр)
-- @param data.y у-координата ячейки (необязательный параметр)
-- @param data.name имя тайла
-- @param data.tiletype тип тайла, специфичный для некоторого набора - напремер все двери будут иметь одинаковый tiletype
-- @param data.tile тайл, в таком виде, как он должен парситься из строки с картой - одиночный символ
-- @param data.standmsg сообщение, которое будет отображаться, когда персонаж игрока будет заходить на данный тайл (необязательный параметр)
-- @param data.walkable является ли тайл проходимым
-- @param data.transparent является ли тайл прозрачным
-- @param data.explored исследован ли тайл (по умолчанию false)
-- @param data.shaded затенен ли тайл (по умолчанию true)
-- @param data.cancreature может ли на тайл вставать существо
-- @param data.canobject может ли на тайле находиться игровой предмет
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
    self.explored = data.explored or false
    self.shaded = data.shaded or true
    
    self.creature = {}
    self.object = {}
    
    self.cancreature = data.cancreature
    self.canobject = data.canobject
end

---
-- Установить координаты тайла
-- @param x Х-координата
-- @param y У-координата
function Base:setPosition(x, y)
    self.x = x
    self.y = y
end

---
-- Получить Х-координату тайла
-- @return Х-координата
function Base:getX()
    return self.x
end

---
-- Получить У-координату тайла
-- @return У-координата
function Base:getY()
    return self.y
end

---
-- Получить координаты тайла
-- @return Х-координата
-- @return У-координата
function Base:getPosition()
    return self.x, self.y
end

---
-- Получить имя тайла
-- @return имя тайла, заданое в конструкторе в параметре data.name
function Base:getName()
    return self.name
end

--- 
-- Проверка, является ли тайл проходимым
-- @return true если тайл задан как проходимый в параметре data.walkable
function Base:isWalkable()
    return self.walkable
end

---
-- Проверка, является ли тайл прозрачным
function Base:isTransparent()
    return self.transparent
end

---
-- Проверка, разведан ли тайл
function Base:isExplored()
    return self.explored
end

---
-- Проверка, затенен ли тайл
function Base:isShaded()
    return self.shaded
end

--- 
-- Получить тип тайла
function Base:getType()
    return self.tiletype
end

---
-- Сравнить тип тайла с эталонным
function Base:isType(tiletype)
    if tiletype == self.tiletype then
        return true
    else
        return false
    end
end

---
-- Получить сообщение при нахождении в тайле
function Base:getMsg()
    return self.standmsg
end

---
-- Проверка, есть ли существо в тайле
function Base:isCreature()
    if next (self.creature) then
        return true
    else
        return false
    end
end

---
-- Получить существо находящееся в тайле
function Base:getCreature()
    if self:isCreature() then
        return self.creature[1]
    else
        error("It is no creature on cell " .. tostring(self.ID), 0)
    end
end

---
-- Установить существо в тайл
function Base:setCreature(creature)
    if not self:isCreature() then
        table.insert(self.creature, creature)
    else
        error("In cell " .. tostring(self.ID) .. " alredy stay creature", 0)
    end
end

---
-- Удалить существо из тайла
function Base:removeCreature()
    local cr = self:getCreature()
    
    table.remove(self.creature)
    
    return cr
end

---
-- Проверка, есть ли в тайле объект
function Base:isObject()
    if next(self.object) then
        return true
    else
        return false
    end
end

---
-- Получить объект из тайла
function Base:getObject()
    if self:isObject() then
        return self.object[1]
    else
        error("It is no object on cell " .. tostring(self.ID), 0)
    end
end

---
-- Установить объект в тайл
function Base:setObject(object)
    if not self:isObject() then
        table.insert(self.object, object)
    else
        error("Cell " .. tostring(self.ID) .. " alredy hawe object", 0)
    end
end

---
-- Удалить объект из тайла
function Base:removeObject()
    local obj = self:getObject()
    
    table.remove(self.object)
    
    return obj
end

---
-- Пометить тайл как разведаный 
function Base:explore()
    self.explored = true
end

---
-- Пометить тайл как не разведаный
function Base:forget()
    self.explored = false
end

---
-- Пометить тайл как освещенный (видимый)
function Base:illuminate()
    self.shaded = false
end

---
-- Пометить тайл как затененный
function Base:obscure()
    self.shaded = true
end

---
-- Проверка, может ли существо встать в тайл
function Base:canCreature()
    if self.cancreature and not self:isCreature() then
        return true
    else
        return false
    end
end

---
-- Проверка, может ли объект встать в тайл
function Base:canObject()
    if self.canobject and not self:isObject() then
        return true
    else
        return false
    end
end

return Base
