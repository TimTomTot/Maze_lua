--генерация по алгоритму Прима
--с учетом старых ошибок

local matrix   = require ("lua_utils.matrix")
local neig     = require ("lua_utils.neighborhood")
local room     = require ("Room")
local proto    = require ("Proto2")

local M = {}

--возможные признаки для дифференциации комнат во время генерации
local Type = {Inside = 1, Outside = 2, Border = 3}

--структура, хранащая все локации с признаком Border и методы доступа к ними
local BorderList = {}

--добавляем новую комнату в список
function BorderList:Add (i, j)
   table.insert (self, {i, j})
end

--получаем случайную комнату из списка
function BorderList:GetRnd ()
   local i = math.random (1, #self)

   local result = self[i]

   table.remove (self, i)

   return result[1], result[2]
end

--установить признак на границе для соседей клетки
function M:SetBorderNeihg (protoMaze, i, j)
   --пройтись по всем соседям
   for di, dj in neig:Iter () do
      --если не выпал за границу, и сосед имеет статус Снаружи,
      if protoMaze:IsInside (i + di, j + dj) and protoMaze:Get (i + di, j + dj) == Type.Outside then
         --то добавляем соседа в список на границе
         protoMaze:Set (i + di, j + dj, Type.Border)
         BorderList:Add (i + di, j + dj)
      end
   end
end

--основная функция - генерация лабиринта
function M:Prim (protoMaze)
   --вначале создается вспомогательный массив с размерами прротолабиринта
   local utilArr = matrix:New (protoMaze.N, protoMaze.M)
   
   --вначале весь вспомогательный массив заполен признаками Снаружи
   for i, j, _ in utilArr:Iterate () do
      utilArr:Set (i, j, Type.Outside)
   end
   
   --для случайной локации ставится признак внутри
   local ri, rj = math.random (utilArr.N), math.random (utilArr.M)
   utilArr:Set (ri, rj, Type.Inside)
   
   --установить для всех ее соседей признак на границе
   self:SetBorderNeihg (utilArr, ri, rj)
   
   --пока остались локации с атрибутом На границе
   while #BorderList > 0 do
      --выбираем случайную граничную комнату
      local tmpi, tmpj = BorderList:GetRnd ()
      
      --ставим ей атрибут внутри
      utilArr:Set (tmpi, tmpj, Type.Inside)
      
      --для всех соседних с ней локация с атрибутом снаружи
      --ставим атрибут на границе
      self:SetBorderNeihg (utilArr, tmpi, tmpj)
      
      --выбираем случайную локацию с атрибутом внутри рядом с текущей
      --и ломаем стену между ними.
      while true do
         local rndDir = math.random (4)
         
         --случайное смещение
         local di, dj = neig:GetDir (rndDir)
         
         if utilArr:IsInside (tmpi + di, tmpj + dj) and utilArr:Get (tmpi + di, tmpj + dj) == Type.Inside then
            protoMaze:BreakWall (tmpi, tmpj, di, dj)
            break
         end
      end
      
   end
end

-------------------------------------
--[[           Тесты             ]]--
-------------------------------------

return M
