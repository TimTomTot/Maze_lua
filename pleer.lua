--Игрок

local class    = require "hump.class"
local vector   = require "hump.vector"

local P = class {}

--конструктор
function P:init (ID)
   self.ID = ID
end

--задать позицию для игрока
function P:setPos (pos)
   --позиция на карте - вектор
   self.position = pos
end

return P
