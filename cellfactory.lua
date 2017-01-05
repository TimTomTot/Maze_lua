--модуль с фабрикой для генерации объектов с ячейками карты

local class = require "hump.class"
local cell = require "cell"

local M = class {}

--конструктор
function M:init ()
   --инициализация списка со всеми возможными ячейками
   self.cellList = {}

   self:addCells ()
end

--функция добавления видов ячеек
function M:addCells ()
   --каждая протоячейка может содержать такие данные:
   --имя
   --тайл
   --флаги
   --действия при наступании
   --действие при применении спец. экшена

   --стена
   local wallData = {
      name = "wall",
      tile = "#",
      flag = {}
   }
   wallData.flag[LV_SOLID] = true

   table.insert(self.cellList, wallData)

   --пол
   local floorData = {
      name = "floor",
      tile = ".",
      flag = {}
   }
   floorData.flag[LV_TRANSPARENT] = true

   table.insert(self.cellList, floorData)

   --лестница
   local stairsData = {
      name = "stairs",
      tile = ">",
      flag = {},
      stand = function (creature) --что происходит при наступании на лестницу
         --когда игрок наступает на лестницу
         creature.signal:emit (
            "hud",
            "message",
            "Это лестница на соседний этаж")
      end,
      --что происходит при выполнении дейстия
      action = function (creature, action)
         --если действие - переход по лестнице
         if action == "downstairs" then
            creature.signal:emit ("generateMap")
            creature.signal:emit (
               "hud",
               "message",
               "Ты перешел на новый этаж!")
         end
      end
   }
   stairsData.flag[LV_TRANSPARENT] = true

   table.insert(self.cellList, stairsData)

   --[[
   --проверим, что получилось с флагами для протоячеек
   for _, val in ipairs(self.cellList) do
      print (val.name,
         val.flag[LV_SOLID],
         val.flag[LV_TRANSPARENT])
   end
   --]]
end

--генерация новой ячейки по имени или по тайлу
function M:newCell (name, extra)
   --определить по имени (или по тайлу) есть ли такая протоячейка
   local protCell = nil

   for _, v in ipairs(self.cellList) do
      --print (name)

      if name == v.name or name == v.tile then
         protCell = v
         break
      end
   end

   --если есть, то на основе ее сгенерировать новую ячейку и вернуть ее
   if protCell then

      --[[
      --проверим, что же хранится в флгах ячейки
      if protCell.name == "floor" then
         print(protCell.flag[LV_SOLID],
            protCell.flag[LV_TRANSPARENT])
      end
      --]]

      local someCell = cell (protCell, extra)

      --[[
      --проверим, что же хранится в флгах ячейки
      if someCell.name == "floor" then
         print(someCell.flag[LV_SOLID],
            someCell.flag[LV_TRANSPARENT])
      end
      --]]

      return someCell
   else
      error ("Нет протоячейки для переданных данных: "
         .. name)
   end
end

return M
