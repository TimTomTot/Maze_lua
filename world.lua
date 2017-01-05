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

   --[[
   --имена для слоев карты для передачи их в cell
   self.mapNane = "map"
   self.characterName = "creatures"
   self.shadowsName = "shadows"
   self.visitedName = "visited"
   self.objectsName = "odjects"
   --]]

   --названия слоев для заполнения таблицы с тайлами
   self.names = {
      "map",
      "objects",
      "creatures",
      "shadows",
      "visited"
   }

   --print (unpack(self.names))

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

   --print("Исходные данные: N =", N, "M = ", M)

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

         --[[
         --проверим еще раз, что же случилось с флагом
         print("Ячейка ", character,
            self.lavel:Get(columnIndex, rowIndex).flag[LV_SOLID],
            self.lavel:Get(columnIndex, rowIndex).flag[LV_TRANSPARENT])
         --]]

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

--[[
--проверка, свободна ли эта ячейка
function M:isEmpty (i, j, spec)
   --модификатор spec задается для поиска свободных участков только не занятых другими объектами
   local rez = true
   local point = self.lavel:Get (i, j)

   if not spec then
      if point.map.val == 1 then
         rez = false
      end
   elseif spec == "object" then
      if point.map.val == 1 or point.objects then
         rez = false
      end
   end

   return rez
end
]]--

--проверка, свободна ли данная ячейка
function M:isEmpty (i, j)
   --сначала задаем предположение, что свободна
   local rez = true

   --если она непроходима или в ней существо
   --то счиаем ее занятой
   local curCell = self.lavel:Get (i, j)

   --print (i, j, curCell, curCell.name, curCell.flag[LV_SOLID], curCell:isCreature ())

   --[[
   if curCell.name == "floor" then
      print(curCell.flag[LV_SOLID])
   end
   --]]

   if curCell.flag[LV_SOLID] or curCell:isCreature () then
      rez = false
   end

   --print(rez)

   return rez
end

--[[
--добавление существа на карту для отслеживания
-- данные в виде:
-- id существа
-- тайл существа
-- куда на карте его поместить
function M:addCreature (cre, i, j)
   self.lavel:Get (i, j).creatures.id = cre.id
   self.lavel:Get (i, j).creatures.tile = cre.tile
end
]]--

--добавление существа на карту
function M:addCreature (cre, i, j)
   self.lavel:Get(i, j).creature = {
      id = cre.id,
      tile = cre.tile
   }
end

--[[

В этой реализации не нужны объекты на карте

--функция добавления объекта на карту,
--во многом аналогичная функции добавления существа
--message - сообщение, которое отображается, когда игрок наступает на точку
function M:addObject (obj, i, j)
   self.lavel:Get (i, j).odjects.present = true
   self.lavel:Get (i, j).odjects.id = obj.id
   self.lavel:Get (i, j).odjects.tile = obj.tile
   self.lavel:Get (i, j).odjects.message = obj.message
end
--]]

--[[
--сдвинуть существо
function M:moveCreature (iold, jold, inew, jnew)
   --задать данные по новому адреу, используя готовые из старого.
   self.lavel:Get (inew, jnew).creatures.id, self.lavel:Get (inew, jnew).creatures.tile =
      self.lavel:Get (iold, jold).creatures.id, self.lavel:Get (iold, jold).creatures.tile

   --обнулить данные по старому адресу
   self.lavel:Get (iold, jold).creatures = {}
end
]]--

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

--[=[
--вернуть cell
function M:getCell (i, j)
   --создаются данные для объекта cell
   local cellData = {}

   --про карту
   table.insert (cellData, {self.mapNane, self.lavel:Get (i, j).map.tile})

   --если на данной точке есть объект
   if self.lavel:Get (i, j).odjects.tile then
      table.insert (cellData, {self.objectsName, self.lavel:Get (i, j).odjects.tile})
   else
      table.insert (cellData, {self.objectsName, nil})
   end

   --если есть данные о существе, то вернуть их
   if self.lavel:Get (i, j).creatures.tile then
      table.insert (cellData, {self.characterName, self.lavel:Get (i, j).creatures.tile})
   else
      table.insert (cellData, {self.characterName, nil})
   end

   --данные о затенении этого участка
   --если участок затемнен, то передаем, что нужно отрисовать
   if self.lavel:Get (i, j).visible == "shadow" then
      local tile

      if self.lavel:Get (i, j).odjects.tile then
         tile = self.lavel:Get (i, j).odjects.tile
      else
         tile = self.lavel:Get (i, j).map.tile
      end
      table.insert(cellData, {self.shadowsName, tile})
   else
      table.insert(cellData, {self.shadowsName, nil})
   end

   --данные о посещении этого участка
   if self.lavel:Get (i, j).visited then
      table.insert(cellData, {self.visitedName, "*"})
   else
      table.insert(cellData, {self.visitedName, nil})
   end

   --передаются в него
   --local outputCell = cell (cellData)

   --реализация без объекта cell
   local outputCell = {}

   for _, v in ipairs(cellData) do
      outputCell[v[1]] = {tile = v[2]}
   end

   return outputCell
end
]=]

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

--[[
--расчитать видимую зону
--на вход передаются - точка от которой нужно считать
--радиус обзора
function M:solveFOV (i, j, R)
   --предварительно обновить карту теней
   self:fillShadow ()

   --убрать тень в точке с игроком
   self.lavel:Get (i, j).visible = "visible"
   if not self.lavel:Get (i, j).visited then
      self.lavel:Get (i, j).visited = true
   end

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
         self.lavel:Get (x, y).visible = "visible"
         if not self.lavel:Get (x, y).visited then
            self.lavel:Get (x, y).visited = true
         end
      end

      --проверка на выход за границы
      if self.lavel:IsInside (x, y) then
            if self.lavel:Get(x, y).map.val == 1 then
               addVisible.empty = false
            end
      end
   end

   --для каждой точки из списка проложить в нее линию обзора
   for _, val in ipairs(viewPointList) do
      addVisible.empty = true

      brez:Line (addVisible.funct, i, j, val[1], val[2])
   end

end
--]]

--расчет поля видимости
function M:solveFOV (i, j, R)
   --предварительно обновить карту теней
   self:fillShadow ()

   --убрать тень в точке с игроком
   self.lavel:Get(i, j).flag[LV_DARKENED] = false
   self.lavel:Get(i, j).flag[LV_EXPLORED] = true

   --[[
   --нарисуем текущую ситуацию
   for i, j, v in self.lavel:Iterate () do
      if j == 1 then
         io.write ("\n")
      end

      local ch

      if v.flag[LV_DARKENED] then
         ch = "#"
      else
         ch = "."
      end

      io.write (ch)
   end

   io.write ("\n")
   --]]

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
            if self.lavel:Get(x, y).flag[LV_SOLID] then
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

--[[

Эти функции в текущей реализации не нужны

--функция, возвращающая true, если по указаной точке на карте есть что-то
--кроме просто элеменов карты
function M:isSometsing (i, j)
   local rez = false

   local point = self.lavel:Get (i, j)

   if point.odjects.present then
      rez = true

      --return point.objects
   end

   return rez
end

--вернуть сообщение о том, что есть в этой точке
function M:getMessage (i, j)
   if self.lavel:Get (i, j).odjects.message then
      return self.lavel:Get (i, j).odjects.message
   end
end
--]]

return M
