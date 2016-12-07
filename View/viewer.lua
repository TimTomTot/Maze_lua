--новый вариант отображения (viewer)

local class    = require "hump.class"
local vector   = require "hump.vector"
local matrix   = require "lua_utils.matrix"

local V = class {}

--конструктор
--задавть начальные установки нужно в виде:
--input.frameSize - размер фрейма - вектор
--input.framePos - начальная позиция фрейма - вектор
--input.mainMap - основной слой, от которого фрейм будет расчитывать перемещения
--этот слой ставится на 1 место в списке
--input.frameStart - позиция, от  которой рисуется фрейм на экране, вектор
function V:init (input)
   --задать фрейм
   self.frame = matrix:New (input.frameSize:unpack ())

   --задать начальную позицию для фрейма
   self.frame.pos = input.framePos

   --откуда отображать фрейм
   self.frame.start = input.frameStart

   --задать список слоев
   self.layerList = {}

   --добавить основной слой
   self:addLayer (input.mainMap, 1)
end

--добавление слоя для отображения на определенном месте
--чем меньше позиция тем ниже отрисовывается слой
function V:addLayer (layer, n)
   table.insert (self.layerList, n, layer)
end

--функция сдвига фрейма отображения
--относительно текущего
function V:move (shift)
   --local di, dj = relativePos:unpack ()

   --новая потенциальная позиция отображения
   local newPos = vector (self.frame.pos.x + shift.x, self.frame.pos.y + shift.y)

   --print("что мы имеем:")
   --print("newPos = ", newPos:unpack ())

   local di, dj = newPos:unpack ()

   --обработка ограничений
   if di < 0 then
      newPos.x = 0
   elseif dj < 0 then
      newPos.y = 0
   elseif di > self.layerList[1].map.M - self.frame.pos.x + 1 then
      newPos.x = self.layerList[1].map.M - self.frame.pos.x + 1
   elseif dj > self.layerList[1].map.N - self.frame.pos.y + 7 then
      newPos.y = self.layerList[1].map.N - self.frame.pos.y + 7
   end

   --задать позицию после внесения ограничений
   self.frame.pos = newPos
   --print("self.frame.pos = ", self.frame.pos:unpack ())
end

--функция отображения всего на экран
function V:show ()
   --позиция начала отображения
   local starti, startj = self.frame.start:unpack ()

   --позиция, откуда нужно рисовать фрейм
   local fi, fj = self.frame.pos:unpack ()

   --для каждого слоя карты
   for _, layer in ipairs (self.layerList) do
      --пройтись по всем ячейкам фрейма и отрисовать значения из него
      for i, j, _ in self.frame:Iterate () do
         --распарсить значения по этой точке
         if layer:parser (i + fi, j + fj) then
            love.graphics.draw (layer.tileset,
               layer:parser (i + fi, j + fj),
               j * layer.tileWidth - layer.tileWidth + startj,
               i * layer.tileHeight - layer.tileHeight + starti)
         end
      end
   end
end

return V
