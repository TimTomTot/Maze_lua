--Обновленный лабиринт, с учетом всех шишек

local matrix   = require ("utils.matrix")
local neig     = require ("utils.neighborhood")
local room     = require "Maze.Room"
local proto    = require ("Maze.Proto")
local PrimGen  = require ("Maze.Generator")
local map      = require "utils.map"

local M = {}

--расширение протолабиринта в конечную карту
function M:Extend (protoMaze)
   --значения для размера отдельной комнаты
   --local self.sizeI = 2
   --local self.sizeJ = 6

   --создание пустого массива для переноса
   local buffer = map:New (protoMaze.N * self.sizeI + 1, protoMaze.M * self.sizeJ + 1)

   --пройтись по всему протолабиринту и отрисовать каждую его комнату
   for i, j, val in protoMaze:Iterate () do
      --получаем данные о стенах в комнате
      local left, top = val:GetWall ()

      --из какой точки нужно отрисовывать стены
      local i0, j0 = (i - 1) * self.sizeI + 1, (j - 1) * self.sizeJ + 1

      --для верхней стены
      if top == 1 then
         for tmpj = j0, j0 + self.sizeJ do
            buffer:Set (i0, tmpj, 1)
         end
      end

      --для левой стены
      if left == 1 then
         for tmpi = i0, i0 + self.sizeI do
            buffer:Set (tmpi, j0, 1)
         end
      end
   end

   --проход по правому и по нижнему краю, для завершения формирования карты
   for tmpi = 1, buffer.N do
      buffer:Set (tmpi, buffer.M, 1)
   end

   for tmpj = 1, buffer.M do
      buffer:Set (buffer.N, tmpj, 1)
   end

   --под конец, нужно задать переменные для парсинга
   function getter (buf, x, y)
      local rez
      local val = buf:Get (x, y)

      if val == 0 then
         rez = "."
      elseif val == 1 then
         rez = "#"
      end

      return rez
   end

   buffer:setTileGetter (function (buffer, i, j) return getter (buffer, i, j) end)

   return buffer
end

--генерировать лабиринт - главная функция свех ближайших модулей
function M:Generate (lenN, lenM)
   --теперь в функцию передается максимальный размер массива.
   --если он меньше самого большого размера комнаты,
   --то размер принудительно увеличивается

   --возможные размеры комнат
   local roomSize = {2, 3, 4, 5, 6, 7}

   if lenN < #roomSize then
      lenN = #roomSize
   end

   if lenM < #roomSize then
      lenM = #roomSize
   end

   --размеры отдельных комнат
   self.sizeI = roomSize[math.random (#roomSize)]
   self.sizeJ = roomSize[math.random (#roomSize)]

   --определяем размеры исходного протолабиринта исходя из полученых размеров конечной карты
   --вначале размеры единичные
   mazeI, mazeJ = 1, 1

   --сначала для размерв по вертикали
   while true do
      if (mazeI + 1) * self.sizeI > lenN then
         break
      else
         mazeI = mazeI + 1
      end
   end

   --потом по горизонтали
   while true do
      if (mazeJ + 1) * self.sizeJ > lenM then
         break
      else
         mazeJ = mazeJ + 1
      end
   end

   --сгенерировать протолабиринт
   local preMaze = proto:New (mazeI, mazeJ)

   --сгенерируем лабиринт
   PrimGen:Prim (preMaze)

   --расширить его в конечный лабиринт со стенами
   local resultMap = self:Extend (preMaze)

   --вернуть полученный результат
   return resultMap
end

--парсер - для отображения лабиринтов в консоль
--работает с конечным лабиринтом
function M:Parse (map)
   for i, j, val in map:Iterate () do
      if j == 1 then
         io.write ("\n")
      end

      if type (val) == "number" then
         local ch

         if val == 0 then        --пол
            ch = "."
         elseif val == 1 then    --стена
            ch = "#"
         end

         io.write (ch)
      else
         error ("Парсер попал на нечисловое значение!")
      end
   end

   io.write ("\n")
end

-------------------------------------
--[[           Тесты             ]]--
-------------------------------------

--проверки
local function test_Maze ()
   math.randomseed (os.time ())

   local map = M:Generate (20, 60)

   --map:Write ()
   M:Parse (map)
end

return M
