--Весь мир игры
--сам должен создавать карты, сам ими манипулировать и сам отображать

local class          = require "hump.class"
local vector         = require "hump.vector"
local maze           = require "Maze.Maze"
local pleerCharacter = require "pleer"
local matrix         = require "lua_utils.matrix"

local W  = class {}

--переменная для задания ID
local nextID = 1

function W:init ()
   -- создать персонажа
   self.pleer = pleerCharacter (nextID)
   nextID = nextID + 1
end

--Сгенерировать карту уровня
function W:GenerateLevel (maxN, maxM)
   --карта сохраняется как слой проходимости, где 0 - можно пройти, 1 - нет
   self.passabilityLayer = maze:Generate (maxN, maxM)
   self.N = self.passabilityLayer.N
   self.M = self.passabilityLayer.M

   --создать уровень для размещения существ
   self.creachersLayer = matrix:New (self.N, self.M)

   --поместить игрока на карту
   while true do
      -- выбрать случайную точку на карте,
      local tmpi, tmpj = math.random(self.N), math.random(self.M)

      --если в ней проходимый тайл, то
      if self.passabilityLayer:Get (tmpi, tmpj) == 0 then
         --помещаем в нее игрока
         self.pleer:setPos (vector(tmpi, tmpj))
         self.creachersLayer:Set (tmpi, tmpj, self.pleer.ID)
         break
      end
   end
end

return W
