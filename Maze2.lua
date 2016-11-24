--Обновленный лабиринт, с учетом всех шишек

local matrix   = require ("lua_utils.matrix")
local neig     = require ("lua_utils.neighborhood")
local room     = require ("Room")
local proto    = require ("Proto2")
local PrimGen  = require ("Prim2")

local M = {}

--расширение протолабиринта в конечную карту
function M:Extend (protoMaze)
   --значения для размера отдельной комнаты
   --local self.sizeI = 2
   --local self.sizeJ = 6
      
   --создание пустого массива для переноса
   local buffer = matrix:New (protoMaze.N * self.sizeI + 1, protoMaze.M * self.sizeJ + 1)
   
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
   
   return buffer
end

--генерировать лабиринт - главная функция свех ближайших модулей
function M:Generate (lenN, lenM)
   --на вход функции передается размер конечного лабиринта
   --исходя из него устанавливаются размеры комнат (вертикальные и горизонтальные)
   --определяем, четный или нечетный размер передается
   local modN, modM = math.fmod (lenN, 2), math.fmod (lenM, 2)
   
   --возможные размеры комнат
   local even = {2, 4, 6}
   local uneven = {3, 5, 7}
   
   --определяем подходящий размер комнат
   local tmp = 1
   
   while true do
      --если переданный размер - нечетный,
      if modN == 1 then
         --то размер стены должен выбираться из четного ряда
         self.sizeI = even[math.random (3)]
      else
         self.sizeI = uneven[math.random (3)]
      end
   
      if modM == 1 then
         --то размер стены должен выбираться из четного ряда
         self.sizeJ = even[math.random (3)]
      else
         self.sizeJ = uneven[math.random (3)]
      end
   
      --определяем, влезетут ли в заданый размер карты полученные комнаты
      if math.fmod (lenN - 1, self.sizeI) == 0 and math.fmod (lenM - 1, self.sizeJ) == 0 then
         break
      end
      
      print ("lenI = ", self.sizeI, " LenJ = ", self.sizeJ)
      
      tmp = tmp + 1
      
      if tmp > 10 then
         error ()         
      end
   end
   
   --теперь создадим из полученных данных размер для протолабиринта
   local mazeI, mazeJ = (lenN - 1) / self.sizeI, (lenM - 1) / self.sizeJ
     
   --сгенерировать протолабиринт
   local preMaze = proto:New (mazeI, mazeJ)
   
   --сгенерируем лабиринт
   PrimGen:Prim (preMaze)
   
   --расширить его в конечный лабиринт со стенами
   local resultMap = self:Extend (preMaze)
   
   --вернуть полученный результат
   return resultMap
end

-------------------------------------
--[[           Тесты             ]]--
-------------------------------------

--проверки
local function test_Maze ()
   math.randomseed (os.time ())
   
   local map = M:Generate (22, 21)
   
   map:Write ()
end

return M
