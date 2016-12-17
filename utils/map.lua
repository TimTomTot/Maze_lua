--модуль карты,  производный от модуля матрицы,
--отличается наличием функции вызова тайла
--для дальнейшего парсинга

local matrix = require ("utils.matrix")

local M = {}

--наследование
setmetatable (M, {__index = matrix})

--задать функцию getTile можно и нужно извне модуля
function M:setTileGetter (func)
   self.getter = func
end

function M:getTile (i, j)
   return self.getter (self, i, j)
end

-------------------------------------
--[[           Тесты             ]]--
-------------------------------------

local function test_getter ()
   --создадим карту
   local testMap = M:New (2, 2)

   function same (map, x, y)
      local rez

      if map:Get (x, y) == 0 then
         rez = "#"
      end

      return rez or "@"
   end

   --создадим геттер
   testMap:setTileGetter (function (testMap, i, j) return same (testMap, i, j) end)

   --проверим
   print (testMap:getTile (1, 1))
end

return M
