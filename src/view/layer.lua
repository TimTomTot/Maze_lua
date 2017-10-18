-- модуль layer
local class = require "hump.class"

local M = class {}

--конструктор
-- данные передаются в виде:
-- {tileset, {{"#", 2, 2}, {".", 3, 4}}}
function M:init (data)
   self.tileset = love.graphics.newImage(data[1])

   --размер тайлов
   local tw, th = 32, 32

   --список квадов
   self.quad = {}

   for _, val in ipairs(data[2]) do
      self.quad[val[1]] = love.graphics.newQuad (tw * val[2],
         th * val[3],
         tw,
         th,
         self.tileset:getWidth (),
         self.tileset:getHeight ())
   end
end

--получение квада на основе конкретного тайла
function M:getQuad (tile)
   return self.quad[tile]
end

return M
