--еще один вариант модуля world, без лифней сложности

local class    = require "hump.class"
local matrix   = require "utils.matrix"
local cell     = require "cell"

local M = class {}

--конструктор
function M:init ()
   --инициализация карты уровня
   self.lavel = {}

   --имена для слоев карты для передачи их в cell
   self.mapNane = "map"
   self.characterName = "creatures"

   --уровень представляет из себя массив типа matrix,
   --в каждой точке которого находится таблица с объектами, наполняющими уровень
end

--добавление карты уровня
function M:addMap (inputMap)
   --подгоняем размер уровня под размер переданой карты
   self.lavel = matrix:New (inputMap.N, inputMap.M)

   --переносим данные
   for i, j, _ in self.lavel:Iterate () do
      --структура данных для каждой ячейки
      local cellData = {
         --слой с картой
         map = {val = inputMap:Get (i, j),
            tile = inputMap:getTile (i, j)},

         --слой с игровыми персонажами
         creatures = {}
      }
      self.lavel:Set (i, j, cellData)
   end
end

--проверка, свободна ли эта ячейка
function M:isEmpty (i, j)
   local rez = true

   if self.lavel:Get (i, j).map.val == 1 then
      rez = false
   end

   return rez
end

--добавление существа на карту для отслеживания
-- данные в виде:
-- id существа
-- тайл существа
-- куда на карте его поместить
function M:addCreature (cre, i, j)
   self.lavel:Get (i, j).creatures.id = cre.id
   self.lavel:Get (i, j).creatures.tile = cre.tile
end

--сдвинуть существо
function M:moveCreature (iold, jold, inew, jnew)
   --задать данные по новому адреу, используя готовые из старого.
   self.lavel:Get (inew, jnew).creatures.id, self.lavel:Get (inew, jnew).creatures.tile =
      self.lavel:Get (iold, jold).creatures.id, self.lavel:Get (iold, jold).creatures.tile

   --обнулить данные по старому адресу
   self.lavel:Get (iold, jold).creatures = {}
end

--вернуть cell
function M:getCell (i, j)
   --создаются данные для объекта cell
   local cellData = {}

   --про карту
   table.insert (cellData, {self.mapNane, self.lavel:Get (i, j).map.tile})

   --если есть данные о существе, то вернуть их
   if self.lavel:Get (i, j).creatures.tile then
      table.insert (cellData, {self.characterName, self.lavel:Get (i, j).creatures.tile})
   else
      table.insert (cellData, {self.characterName, nil})
   end

   --передаются в него
   local outputCell = cell (cellData)

   return outputCell
end

--получить данные о размере карты
function M:getMapSize ()
   return self.lavel.N, self.lavel.M
end

return M
