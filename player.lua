--Игрок

local class    = require "hump.class"
local vector   = require "hump.vector"
--local matrix   = require "utils.matrix"

local M = class {}

--конструктор
function M:init (data)
   self.ID = data.id
   self.tile = data.tile
   self.world = data.world
   self.signal = data.signalView

   --радиус обзора
   self.fovR = data.R

   --[[
   --регистрация действия с перемещением на лестнице
   self.signal:register ("downSteer",
      function ()
         --print ("!")
         if self.world:isSometsing (self.pos.x, self.pos.y) and
            self.world.lavel:Get (self.pos.x, self.pos.y).odjects.tile == ">" then
            --дать команду на генерацию нового уровня
            self.signal:emit ("generateMap")
            --вывести сообщение об этом
            self.signal:emit ("hud", "message", "Ты перешел на новый уровень!")
         else
            self.signal:emit ("hud", "message", "Здесь нет лестницы")
         end
      end)
   --]]
end

--установить игрока на карту мира
function M:setToMap ()
   --получить размер карты для дальнейших поисков позиции
   local mapN, mapM = self.world:getMapSize ()

   --print ("N ", mapN, " M " , mapM)

   while true do
      local rndPosI, rndPosJ = math.random(mapN), math.random(mapM)

      --на ней просто разместить игрока
      if self.world:isEmpty (rndPosI, rndPosJ) then
         self.world:addCreature ({id = self.id, tile = self.tile},
            rndPosI,
            rndPosJ)

         --сохранить текущую позицию
         self.pos = vector (rndPosI, rndPosJ)

         --первоначальный расчет поля зрения
         self.world:solveFOV (self.pos.x,
            self.pos.y,
            self.fovR)

         --установить отображение на игроке
         self.signal:emit ("setFramePos", rndPosI, rndPosJ)

         break
      end
   end
end

--перемещение игрока (отностельно текущей позиции)
function M:step (di, dj)
   --проверить, свободна ли эта позиция на карте
   if self.world:isEmpty (self.pos.x + di, self.pos.y + dj) then
      --если свободна, то переместить в нее игрока
      self.world:moveCreature (self.pos.x,
         self.pos.y,
         self.pos.x + di,
         self.pos.y + dj)

      self.pos = self.pos + vector (di, dj)

      --расчитать поле зрения
      self.world:solveFOV (self.pos.x,
         self.pos.y,
         self.fovR)

      --[[
      --если игрок стоит на токе, где что -то находится,
      --то об этом выводится сообщение
      if self.world:isSometsing (self.pos.x, self.pos.y) then
         self.signal:emit ("hud",
            "message",
            self.world:getMessage (self.pos.x, self.pos.y))
      end
      --]]

      --и оповестить об этом объект отображения
      self.signal:emit ("setFramePos", self.pos.x, self.pos.y)

      --выполнить функцию, предусмотренную картой для этой точки
      --self.world:Get(self.pos.x, self.pos.y).stand (self)
   else
      --сообщение о том, что дальше продвинуться невозможно
      self.signal:emit ("hud", "message", "Здесь не пройти!")
   end
end

return M
