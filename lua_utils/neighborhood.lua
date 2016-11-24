--модуль, с утилитой для манипуляций с соседними клетками в прямоугольном массиве

--чтобы работать с этим модулем необходимо делать вызовы типа
-- M:GetDir (M.UP)

local M = {}

--подмассив для собственных нужд
local Directions = {1, 2, 3, 4}

--переменные для направлений
local neiborsX = { -1,  1,  0,  0} 
local neiborsY = {  0,  0,  1, -1}

--константы для направлений
M.UP     = Directions[1]
M.DOWN   = Directions[2]
M.RIGHT  = Directions[3]
M.LEFT   = Directions[4]

function M:GetDir (dir)
   --возвращаемые значения
   return neiborsX[dir], neiborsY[dir]
end

--итератор для обхода всех соседей определенной ячейки на карте
--дурацкий итератор, нужно переделать!
function M:Iter ()
   local i = 0
   
   return function ()
      i = i + 1
      return neiborsX[i], neiborsY[i]
   end
end

return M
