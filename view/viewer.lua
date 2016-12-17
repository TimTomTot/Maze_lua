-- модуль отображения, viewer

local class    = require "hump.class"
local vector   = require "hump.vector"
local layer    = require "view.layer"
local cell     = require "cell"
local matrix   = require "utils.matrix"

local M = class {}

--конструктор
function M:init (world)
   --карта, к которой привязано отображение
   self.world = world

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

return M
