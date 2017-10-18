-- Модуль с ячейкой карты

local class = require "hump.class"

local M = class {}

--генерация новой ячейки на основе данных о протоячейки
function M:init (data, extra)
   --имя
   --тайл
   --данные о объекте на ячейке
   --данные о существе на ячейке
   --флаги ячейки
   --функция выполняемая при наступании на ячейку
   --функция выполняемая при применении действия над ячейкой

   self.name = data.name
   self.tile = data.tile
   self.object = {}
   self.creature = {}

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

--проверка, есть ли в ячейке существо
function M:isCreature ()
   if next (self.creature) then
      return true
   else
      return false
   end
end

--проверка, есть ли предмет
function M:isObject()
   if next(self.object) then
      return true
   else
      return false
   end
end

return M
