--еще один вариант модуля world, без лифней сложности

local class    = require "hump.class"
local matrix   = require "utils.matrix"
--local cell     = require "cell"
local brez     = require "utils.brez"
local cellfactory = require "cellfactory"

local M = class {}

--конструктор
function M:init ()
   --инициализация карты уровня
   self.lavel = {}

   --названия слоев для заполнения таблицы с тайлами
   self.names = {
      "map",
      "objects",
      "creatures",
      "shadows",
      "visited"
   }

   --фабрика для генерации ячеек карты
   self.factory = cellfactory ()

   --уровень представляет из себя массив типа matrix,
   --в каждой точке которого находится таблица с объектами, наполняющими уровень
end

--функция парсинга карты мира из строкаи
function M:parseMap (str)
   --получить размеры карты из строки
   local N = math.floor (#str / #(str:match("[^\n]+")))
   local M = #(str:match ("[^\n]+"))

   --задать размеры для карты уровня
   self.lavel = matrix:New (N, M)

   --пройтись по всей входной строке и
   --исходя из того, какие точки в ней находятся,
   --создать соответствующие ячейки на карте уровня
   local rowIndex, columnIndex = 1, 1

   for row in str:gmatch ("[^\n]+") do
      columnIndex = 1

      for character in row:gmatch (".") do
         --создать затемненную ячейку
         self.lavel:Set (
            rowIndex,
            columnIndex,
            self.factory:newCell (character, {darkened = true}))

         columnIndex = columnIndex + 1
      end
      rowIndex = rowIndex + 1
   end
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

         --слой с игровыми объектами
         odjects = {present = false},

         --слой с игровыми персонажами
         creatures = {},

         --слой с затемнением
         --в начале всегда затемнено
         visible = "shadow",

         --слой со свединиями о посещении
         --в начале все точки считаются не посещенными
         visited = false
      }
      self.lavel:Set (i, j, cellData)
   end
end

--проверка, свободна ли данная ячейка
function M:isEmpty (i, j)
   --сначала задаем предположение, что свободна
   local rez = true

   --если она непроходима или в ней существо
   --то счиаем ее занятой
   local curCell = self.lavel:Get (i, j)

   if curCell.flag[LV_SOLID] or curCell:isCreature () then
      rez = false
   end

   return rez
end


--добавление существа на карту
function M:addCreature (cre, i, j)
   self.lavel:Get(i, j).creature = {
      id = cre.id,
      tile = cre.tile
   }
end

--сдвиг существа по указаным координатам
function M:moveCreature (iold, jold, inew, jnew)
   local creatureData = self.lavel:Get(iold, jold).creature

   --установить данные для новой точки
   self.lavel:Get(inew, jnew).creature = {
      id = creatureData.id,
      tile = creatureData.tile
   }

   --обнулить старую точку
   self.lavel:Get(iold, jold).creature = {}
end

--новая реализация передачи данных о тайлах
function M:getCell (i, j)
   --собираем все возможные данные в одну таблицу
   local data = {}

   --что там, по этим координатам
   --print(i, j, self.lavel:Get(i, j).tile)

   --карта
   table.insert(data,
      {self.names[1], self.lavel:Get(i, j).tile})

   --объекты
   table.insert(data,
      {self.names[2], nil})

   --существо
   table.insert(data,
      {self.names[3], self.lavel:Get(i, j).creature.tile or nil})

   --затенение
   if self.lavel:Get(i, j).flag[LV_DARKENED] then
      --print ("(", i, ";", j, ")", "darkned")
      table.insert(data,
         {self.names[4], self.lavel:Get(i, j).tile})
   else
      --print ("(", i, ";", j, ")", "undarkned")
      table.insert(data,
         {self.names[4], nil})
   end

   --разведана ячейка или нет
   if not self.lavel:Get(i, j).flag[LV_EXPLORED] then
      table.insert(data,
         {self.names[5], nil})
   else
      table.insert(data,
         {self.names[5], "*"})
   end

   --возвращаем таблицу с тайлами
   local outputCell = {}

   for i, v in ipairs(data) do
      --print ("i = ", i, " name = ", self.names[i])
      outputCell[v[1]] = {tile = v[2]}
   end

   return outputCell
end

--получить данные о размере карты
function M:getMapSize ()
   --print ("N = ", self.lavel.N, " M = ", self.lavel.M)

   return self.lavel.N, self.lavel.M
end

--расчет поля видимости
function M:solveFOV (i, j, R)
   --предварительно обновить карту теней
   self:fillShadow ()

   --убрать тень в точке с игроком
   self.lavel:Get(i, j).flag[LV_DARKENED] = false
   self.lavel:Get(i, j).flag[LV_EXPLORED] = true

   ---[[
   --создать список точек, до которых необходимо проложить видимость
   local viewPointList = {}

   --функция для добавления точек в список
   local addToList = function (x, y)
      table.insert(viewPointList, {x, y})
   end

   --расчитать из текущей позиции круг радиусом как поле видимости
   --все найденные точки при этом занести в список
   brez:Circle (addToList, i, j, R)

   local addVisible = {}

   addVisible.empty = true

   --функция, добавляющая точку на карте в разряд видимых
   addVisible.funct = function (x, y)
      if addVisible.empty then
         self.lavel:Get(x, y).flag[LV_DARKENED] = false
         self.lavel:Get(x, y).flag[LV_EXPLORED] = true
      end

      --проверка на выход за границы
      if self.lavel:IsInside (x, y) then
         --[[
         if self.lavel:Get(x, y).name == "closeDoor" then
            print(self.lavel:Get(x, y).flag[LV_OPAQUE])
         end
         --]]

         if self.lavel:Get(x, y).flag[LV_OPAQUE] then
            addVisible.empty = false
         end
      end
   end

   --для каждой точки из списка проложить в нее линию обзора
   for _, val in ipairs(viewPointList) do
      addVisible.empty = true

      brez:Line (addVisible.funct, i, j, val[1], val[2])
   end
   --]]
end --solveFOV

--вспомогательная функция, обновляющая карту видимости
function M:fillShadow ()
   --просто залить всю карту тенями
   for i, j, val in self.lavel:Iterate () do
      val.flag[LV_DARKENED] = true
   end


end

return M
