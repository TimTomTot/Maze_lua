-- Модуль с ячейкой карты

--[[
    Этот модуль нуждается в переработке
    Атрибуты для ячеек будут создаваться во впемя генерации в класса cellfactory
    
    Отдельная ячейка имеет такие атрибуты:
    - название
    - тайл
    - существо
    - предмет
    - проходима
    - прозрачна
    - разведана
    - затенена    
--]]

local class = require "30log"


local Cell = class("Cell")


function Cell:init(data)
   self.name = data.name
   self.tile = data.tile
   
   self.object = {}
   self.creature = {}

   self.iswalkable = data.iswalkable
   self.istransparent = data.istransparent
   self.isexplored = data.isexplored
   self.iadarcked = data.isdarcked
   
   --добавление уникальных данных для каждой ячейки
   if next (data.flag) then
      self.flag = {}

      for _, v in ipairs(data.flag) do
         table.insert(self.flag, v)
      end
   else
      self.flag = {}
   end

   --self.flag = data.flag or {}
   self.stand = data.stand or function (creature, thisCell) end
   self.action = data.action or function (creature, action) return false end

   --обработка дополнительтных данных при генерации ячейки
   --ячейка затемнена
   if extra and extra.darkened then
      --print ("!")
      self.flag[LV_DARKENED] = true

      if not self.flag[LV_OPAQUE] then
         self.flag[LV_OPAQUE] = false
      end
      --self.flag[LV_EXPLORED] = false
   end
end

function Cell:isCreature ()
   if next (self.creature) then
      return true
   else
      return false
   end
end

function Cell:isObject()
   if next(self.object) then
      return true
   else
      return false
   end
end

return Cell
