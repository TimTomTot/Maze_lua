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

return M
