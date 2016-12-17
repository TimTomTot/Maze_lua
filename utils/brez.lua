--Алгоритм Брезенхема - самый первый вариант

local matrix   = require ("utils.matrix")

local M = {}

--Алгоритм Брезенхема из моей любимой (и проверенной) книжки про PIC24
function M:Line (funct, i0, j0, i1, j1)
   --получить значение для перестановок
   local steep = math.abs (j1 - j0) > math.abs (i1 - i0)

   --перестановки начала линии
   if steep then
      i0, j0 = j0, i0
      i1, j1 = j1, i1
   end

   local deltai
   local deltaj

   local inc

   --перестановки концов
   if i0 > i1 then
      --i0, i1 = i1, i0
      --j0, j1 = j1, j0

      deltai = i0 - i1
      deltaj = math.abs (j0 - j1)
      inc = -1
   else
      deltai = i1 - i0
      deltaj = math.abs (j1 - j0)
      inc = 1
   end

   local err = 0

   local tmpj = j0

   local jstep

   if j0 < j1 then
      jstep = 1
   else
      jstep = -1
   end

   for tmpi = i0, i1, inc do
      if steep then
         funct (tmpj, tmpi)
      else
         funct (tmpi, tmpj)
      end

      err = err + deltaj

      if (err * 2) >= deltai then
         tmpj = tmpj + jstep
         err = err - deltai
      end
   end
end


--генерация окружности по Брезенхему
function M:Circle (funct, i0, j0, R)
   local tmpi, tmpj = 0, R
   local delta = 2 - 2 * R
   local err = 0

   while tmpj >= 0 do
      funct (i0 + tmpi, j0 - tmpj, 1)
      funct (i0 - tmpi, j0 - tmpj, 1)
      funct (i0 + tmpi, j0 + tmpj, 1)
      funct (i0 - tmpi, j0 + tmpj, 1)

      err = 2 * (delta + tmpj) - 1

      if delta < 0 and err <= 0 then
         tmpi = tmpi + 1
         delta = delta + 2 * tmpi + 1
      else
         err = 2 * (delta - tmpi) - 1

         if delta > 0 and err > 0 then
            tmpj = tmpj - 1
            delta = delta + 1 - 2 * tmpj
         else
            tmpi = tmpi + 1
            delta = delta + 2 * (tmpi - tmpj)
            tmpj = tmpj - 1
         end
      end
   end
end

-------------------------------------
--[[           Тесты             ]]--
-------------------------------------

--[[
local function test_Brez ()
   local li, lj = 10, 10

   for ti = 1, li do
      local map = matrix:New (li, lj)

      --сохранить функцию в переменную
      local fun = map.Set

      --M:Line2 (map, 5, 5, ti, lj)
      M:Line3 (map, fun, 5, 5, ti, lj)

      map:Write ()

      map = nil
   end
end
]]--

--[[
--проверка по кругу
local function test_circle ()
   local li, lj = 10, 10

   os.execute ("cls")

   for ti = 1, li do
      local map = matrix:New (li, lj)

      --сохранить функцию в переменную
      local fun = map.Set

      --M:Line2 (map, 5, 5, ti, lj)
      M:Line3 (map, fun, 5, 5, ti, lj)

      map:Write ()

      io.read ()
      os.execute ("cls")

      map = nil
   end
end
]]--

local function test_circle ()
   local li, lj = 24, 34
   os.execute ("cls")

   for r = 1, 9 do
      local map = matrix:New (li, lj)

      --сохранить функцию в переменную
      --local fun = map.Set

      map:Set (math.floor (li / 2), lj / 2, 1)

      M:Circle (map, map.Set, math.floor (li / 2), lj / 2, r)

      --map:Write ()

      print ("R = ", r)

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

      io.read ()
      os.execute ("cls")

      map = nil
   end
end

return M
