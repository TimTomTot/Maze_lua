--Игрок

local class    = require "hump.class"
local vector   = require "hump.vector"
local neig     = require "utils.neighborhood"
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

   ---[[
   --регистрация действия с перемещением на лестнице
   self.signal:register ("downSteer",
      function ()
         --для точки, на которой стоит игрок вызывается функция action
         local rez = self.world.lavel:Get(self.pos.x, self.pos.y).action (self,
            AC_DOWNSTAIRS)

         --если action не задан, то выдается сообщение о том, что лестницы нет
         if not rez then
            self.signal:emit ("hud",
               "message",
               "Здесь нет лестницы!")
         end
      end)
   --]]

   --регистрация действия с открытием двери
   self.signal:register ("openDoor",
      function ()
         --функция по очереди вызывается для всех точек, соседних с позицией
         --игрока
         local rez

         for i = 1, 4 do
            local di, dj = neig:GetDir (i)

            local curCell = self.world.lavel:Get (self.pos.x + di,
               self.pos.y + dj)

            rez = curCell.action (self,
               AC_OPENDOOR,
               curCell)

            if rez then
               self.world:solveFOV (self.pos.x,
                  self.pos.y,
                  self.fovR)

               self.signal:emit ("setFramePos", self.pos.x, self.pos.y)

               break
            end
         end

         if not rez then
            self.signal:emit ("hud",
               "message",
               "Вокруг нет дверей, которые можно открыть!")
         end
      end)

      --регистрация действия с закрытием двери
      self.signal:register ("closeDoor",
         function ()
            --функция по очереди вызывается для всех точек, соседних с позицией
            --игрока
            local rez

            for i = 1, 4 do
               local di, dj = neig:GetDir (i)

               local curCell = self.world.lavel:Get (self.pos.x + di,
                  self.pos.y + dj)

               rez = curCell.action (self,
                  AC_CLOSEDOOR,
                  curCell)

               if rez then
                  self.world:solveFOV (self.pos.x,
                     self.pos.y,
                     self.fovR)

                  self.signal:emit ("setFramePos", self.pos.x, self.pos.y)

                  break
               end
            end

            if not rez then
               self.signal:emit ("hud",
                  "message",
                  "Вокруг нет дверей, которые можно закрыть!")
            end
         end)
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

      --выполнить функцию, предусмотренную картой для этой точки
      local curCell = self.world.lavel:Get(self.pos.x, self.pos.y)

      curCell.stand (self, curCell)

      --расчитать поле зрения
      self.world:solveFOV (self.pos.x,
         self.pos.y,
         self.fovR)

      --и оповестить об этом объект отображения
      self.signal:emit ("setFramePos", self.pos.x, self.pos.y)
   else
      --сообщение о том, что дальше продвинуться невозможно
      self.signal:emit ("hud", "message", "Здесь не пройти!")
   end
end

return M
