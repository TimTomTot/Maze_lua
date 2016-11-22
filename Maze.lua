local utils       = require ("lua_utils.maputils")
local neig        = require ("lua_utils.neighborhood")
local room        = require ("Room")
local proto       = require ("proto")
local generator   = require ("Prim")

-------------Лабиринт--------------

local M = {}

--Функция, расширяющая протолабиринт в готовый для дальнейшего использования
local function Extend (protoMaze)
   --забацаем результирующий массив исходя из размеров протолабиринта
   --размер отдельной комнаты
   local size = 4
   
   local xlen, ylen = #protoMaze[1] * size + 1, #protoMaze * size + 1
   
   local buffer = {}
   utils.SetSize (buffer, xlen, ylen)
   
   --print (#buffer)
   --print (#buffer[1])
   
   --нарисуем для каждой конкретной комнаты стены в ней
   for i, j, val in utils.Iter (protoMaze) do
      --получим стены для данной ячейки
      local lWall, tWall = val:GetWall ()
      
      --определим из каой точки нужно рисовать стены
      local l0, t0 = (i - 1) * size + 1, (j - 1) * size + 1 
      
      --рисуем стену для верхней стены
      if tWall == 1 then
         for tmpY = t0, (t0 + size) do
            buffer[l0][tmpY] = 1
         end
      end
      
      --рисуем стену для левой стены
      if lWall == 1 then
         --print ("l0 = ",l0)
         --print ("t0 = ",t0)
         
         for tmpX = l0, (l0 + size) do
            buffer[tmpX][t0] = 1
         end
      end
   end
   
   --так же, проводим стены по периметру
   for l = 1, #buffer do
      buffer[l][#buffer[1]] = 1
   end
   
   for t = 1, #buffer[1] do
      buffer[#buffer][t] = 1
   end
   
   return buffer
end --Extend

--Функция генерации лабиринта заданого размера
function M.Generate (xlen, ylen)
	--сначала генерируется болванка с комнатами
	--для этого нужно понять, сколько комнат нужно и какого размера будут эти комнаты
   
   local protoMaze = proto:New (xlen, ylen)
	
   --print (#protoMaze)
   
	--затем болванка преобразуется по правилам алгоритма Прима
   generator:Generation (protoMaze)
	
	--В самом конце создается массив для результирующего лабиринта 
   local result = Extend (protoMaze)
   
	--и предстваление с комнатами преобразуется в понятное человеку
   return result
end

return M
