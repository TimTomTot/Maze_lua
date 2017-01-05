-- модуль для работы с матрицами
-- еще одна попытка исправить пробемы с maputils

------------------------------------------------
--Самое главное! M:New (N, M)
--N - размер по вертикали (по Оу) - i
--M - размер по горизонтали (по Ох) - j

--итератор обходит массив слева направо сверху вниз

local M = {}

--создать массив
function M:New (N, M)
   local o = {}

   --размеры матрицы
   o.N = N
   o.M = M

   for i = 1, N do
      for j = 1, M do
         o[(i - 1) * M + j] = 0
      end
   end

   setmetatable (o, self)
	self.__index = self

   return o
end

--итератор по всем элементам массива
function M:Iterate ()
   local i, j = 1, 0

   return function ()
      if j < self.M then
         j = j + 1
      else
         if i < self.N then
            i = i + 1
            j = 1
         else
            return nil
         end
      end

      return i, j, self[(i - 1) * self.M + j]
   end
end

--доступ к элементам
function M:Set (i, j, val)
   self[(i - 1) * self.M + j] = val
end

function M:Get (i, j)
   return self[(i - 1) * self.M + j]
end

--проверка выхода за границы массива
function M:IsInside (i, j)
   local rez = true

   if i < 1 or i > self.N or j < 1 or j > self.M then
      rez = false
   end

   return rez
end

--отрисовка на экране
function M:Write ()
   for i = 1, self.N do
      io.write ("\n")

      for j = 1, self.M do
         io.write ("" .. tostring (self[(i - 1) * self.M + j]))
      end
   end

   io.write ("\n")
end

-------------------------------------
--[[           Тесты             ]]--
-------------------------------------

local function test_Write ()
   --создадим новую матрицу
   local testA = M:New (4, 6)

   print ("N = ", testA.N, " M = ", testA.M)

   --проверка итератора (факультативная)
   local tmp = 1

   for i, j, _ in testA:Iterate () do
      --testA[(i - 1) * testA.M + j] = tmp
      testA:Set(i, j, tmp)
      tmp = tmp + 1
   end

   --нарисуем ее
   testA:Write ()

   testA = nil
end

--проверка отрисовки через итератор
local function test_WriteIter ()
   local testA = M:New (4, 6)

   for i, j, val in testA:Iterate () do
      if j == 1 then
         io.write ("\n")
      end

      io.write ("  " .. tostring (val))
   end

   testA = nil
end

--проверка итератора
local function test_Iterate ()
   --если нужно обойти вектор, а не матрицу,
   local testB = M:New (1, 2)
   local rez = {}

   for i, j, _ in testB:Iterate () do
      table.insert (rez, {i, j})
   end

   assert (rez[1][1] == 1 and rez[1][2] == 1 and
      rez[2][1] == 1 and rez[2][2] == 2,
      "Итератор неверно проходит по вектору!" ..
      "\n rez[1] = " .. tostring (rez[1][1]) .. " " .. tostring (rez[1][2]) .. " and " ..
      "rez[2] = " .. tostring (rez[2][1]) .. " " .. tostring (rez[2][2]))

   testB = nil
   rez = nil

   --обход квадратной матрицы
   local testC = M:New (2, 2)
   local rez1 = {}

   for i, j, _ in testC:Iterate () do
      table.insert (rez1, {i, j})
   end



   testC = nil
   rez1 = nil
end

return M
