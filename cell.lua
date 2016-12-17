-- Модуль с ячейкой 

--ячейка содержит данные о том, что находится в данной точке карты.
-- в виде таблицы (словаря), ключем к которой будет название слоя, а данными - какой тайл стоит на этом слое
-- данные в ячейку передаются в виде простой таблицы:
-- {{"map", "#"},
--  {"creatures", "@"}}

local class = require "hump.class"

local M = class {}

function M:init (data)
   for _, val in ipairs (data) do
      self[val[1]] = {tile = val[2]}
   end
end

return M
