--переделка модуля proto.lua с учетом нового модуля обработки матриц

--всего необходимо реализовать несколько методов:
-- -создание протолабиринта
-- -проверка, можно ли проходить из одной соседней локации в другую
-- -сломать стену между смежными локациями
-- -ну, и методы доступа

local matrix   = require ("lua_utils.matrix")
local room     = require ("Room")
local neig     = require ("lua_utils.neighborhood")

local M = {}

--сила прототипного ООП - это наследование
setmetatable (M, {__index = matrix})

--создать новый протолабиринт
function M:New (N, M)
   --создадим матрицу нужного размера
   local o = matrix:New (N, M)
      
   --заполним ее как протолабиринт со всеми изолированными комнатами
   for i, j, _ in o:Iterate () do
      o:Set (i, j, room:New (1, 1))
   end
   
   --инстанцируем полученное значение
   setmetatable (o, self)
      
	self.__index = self
	
	return o
end

--функция для отрисовки протолабиринта на экран, для проверок всех типов
function M:Write ()
   io.write ("\n")
   
   for i, j, val in self:Iterate () do
      if j == 1 then
         io.write ("\n")
      end
      
      local left, top = val:GetWall () 
      
      if left == 1 and top == 1 then
         io.write ("P")
      elseif left == 1 and top == 0 then
         io.write ("l")
      elseif left == 0 and top == 1 then
         io.write ("T")
      elseif left == 0 and top == 0 then
         io.write (".")
      end
   end
end

--проверка, что между двумя локациями есть проход
--только для смежных локаций
function M:IsGo (i, j, di, dj)
   --получим значение
   local curRoom, left, top
   local rez = false
   
   --когда нужно проверить стену между верхним или левым соследом
   --сосед сверху
   if di < 0 then
      curRoom = self:Get (i, j)
      left, top = curRoom:GetWall ()
      
      if top == 0 then
         rez = true
      end
      
      return rez
   elseif dj < 0 then -- сосед слева
      curRoom = self:Get (i, j)
      left, top = curRoom:GetWall ()
      
      if left == 0 then
         rez = true
      end
      
      return rez
   elseif di > 0 then --сосед снизу
      curRoom = self:Get (i + di, j)
      left, top = curRoom:GetWall ()
      
      if top == 0 then
         rez = true
      end
      
      return rez
   elseif dj > 0 then --сосед справа
      curRoom = self:Get (i, j + dj)
      left, top = curRoom:GetWall ()
      
      if left == 0 then
         rez = true
      end
      
      return rez
   end
end

--сломать стену
function M:BreakWall (i, j, di, dj)
   local l, t
   if di < 0 then -- сломать стену сверху
      l, t = self:Get (i, j):GetWall ()
      self:Get (i, j):SetWall (l, 0)
   elseif dj < 0 then --сломать стену слева
      l, t = self:Get (i, j):GetWall ()
      self:Get (i, j):SetWall (0, t)
   elseif dj > 0 then --сломать стену справа
      l, t = self:Get (i, j + dj):GetWall ()
      self:Get (i, j + dj):SetWall (0, t)
   elseif di > 0 then   --сломать стену снизу
      l, t = self:Get (i + di, j):GetWall ()
      self:Get (i + di, j):SetWall (l, 0)
   end
end

-------------------------------------
--[[           Тесты             ]]--
-------------------------------------

--размерность протолабиринта
local function test_ProtoLen ()
   --создадим лабиринт и проверим его размеры
   local lenN, lenM = 10, 12   
   local protoA = M:New (lenN, lenM)
   
   assert (protoA.N == lenN and protoA.M == lenM, 
      "Неверно заданы размеры протолабиринта!" ..
      "\nproto:N = " .. tostring (protoA.N) .. " proto:M = " .. tostring (protoA.M))
   
   protoA = nil
end

--проверка возможности прохода
local function test_IsGo ()
   local testA = M:New (3, 3)
   
   --print ("IsGo?", testA:IsGo (2, 2, -1, 0))
   
   --testA:Get (2,2):SetWall (1, 0)
   
   --попробуем нарисовать протолабиринт на экране   
   testA:Write ()
   
   --сломать стену
   for di, dj in neig:Iter () do
      testA:BreakWall (2, 2, di, dj)
      testA:Write ()
   end
end

return M
