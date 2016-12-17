-- модуль отображения, viewer

local class    = require "hump.class"
local vector   = require "hump.vector"
local layer    = require "view.layer"
local cell     = require "cell"
local matrix   = require "utils.matrix"

local M = class {}

--конструктор
function M:init (world, signal)
   --карта, к которой привязано отображение
   self.world = world

   --обработчик сигналов для отображения
   self.signal = signal

   --регистрация изменения позиции фрейма (абсолютного)
   self.signal:register ("setFramePos",
      function (i, j) self:setFramePos (i, j) end)

   --регистрация изменения позиции фрейма (относительного)
   self.signal:register ("moveFrame",
      function (i, j) self:moveFrame (i, j) end)

   --запомнить максимальные размеры карты
   self.MaxMap = vector (self.world:getMapSize ())

   --print(self.world)

   --фрейм
   self.frame = matrix:New (16, 30)

   --позиция фрейма относительно карты
   self.framePos = vector (0, 0)

   --позиция отображения фрейма на экране
   self.drawPos = vector (0, 0)

   --список слоев для отображения
   self.layerList = {}

   --отображение карты
   local mapData = {"fantasy-tileset_b.png",
      {{".", 4, 3},
      {"#", 2, 2}}
   }

   table.insert(self.layerList, {name = "map", data = layer (mapData)})

   --отображение игрока
   local playerData = {"fantasy-tileset.png",
      {{"@", 0, 18}}
   }

   table.insert(self.layerList, {name = "creatures", data = layer (playerData)})
end --init

--отображение на экран
function M:draw ()
   --размерность отдельного тайла
   local tw, th = 32, 32

   --пройтись по всем ячейкам в фрейме
   for i, j, val in self.frame:Iterate () do
      --для каждой точки получить cell из соответствующей точки карты
      local curCell = self.world:getCell (i + self.framePos.x,
         j + self.framePos.y)

      --пройтись по всем уровням заданым в viewer
      for _, val in ipairs (self.layerList) do
         --если для этого уровня есть тайл,
         if curCell[val.name].tile then
            love.graphics.draw (val.data.tileset,
               val.data:getQuad (curCell[val.name].tile),
               j * tw - tw + self.drawPos.y,
               i * th - th + self.drawPos.x)
         end
      end
   end
end --draw

--ограничение для фрейма
function M:checkFrame ()
   --ограничения
   if self.framePos.x < 0 then
      self.framePos.x = 0
   end

   if self.framePos.y < 0 then
      self.framePos.y = 0
   end

   if self.framePos.x > self.MaxMap.x - self.frame.N then
      self.framePos.x = self.MaxMap.x - self.frame.N
   end

   if self.framePos.y > self.MaxMap.y - self.frame.M then
      self.framePos.y = self.MaxMap.y - self.frame.M
   end
end

--сдвиг фрейма отображения относительно текущей позиции
function M:moveFrame (di, dj)
   self.framePos.x = self.framePos.x + di
   self.framePos.y = self.framePos.y + dj

   --проверить ограничение
   self:checkFrame ()
end

--установка фрейма на определенное место карты (с точкой в середине)
function M:setFramePos (i, j)
   self.framePos.x = i - math.ceil(self.frame.N / 2)
   self.framePos.y = j - math.ceil(self.frame.M / 2)

   -- проверить ограничение
   self:checkFrame ()
end

return M
