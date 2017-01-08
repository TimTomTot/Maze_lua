-- модуль отображения, viewer

local class    = require "hump.class"
local vector   = require "hump.vector"
local layer    = require "view.layer"
local cell     = require "world.cell"
local matrix   = require "utils.matrix"

local M = class {}

--конструктор
function M:init (signal)
   --карта, к которой привязано отображение
   self.world = nil

   --запомнить максимальные размеры карты
   --(после того, как будет задан новый объект отображения)
   self.MaxMap = nil

   --обработчик сигналов для отображения
   self.signal = signal

   --регистрация изменения позиции фрейма (абсолютного)
   self.signal:register ("setFramePos",
      function (i, j) self:setFramePos (i, j) end)

   --регистрация изменения позиции фрейма (относительного)
   self.signal:register ("moveFrame",
      function (i, j) self:moveFrame (i, j) end)

   --фрейм
   self.frame = matrix:New (16, 30)

   --позиция фрейма относительно карты
   self.framePos = vector (0, 0)

   --позиция отображения фрейма на экране
   self.drawPos = vector (0, 0)

   --отображение карты
   local mapData = {"content/fantasy-tileset_b.png",
      {{".", 4, 3},
      {"#", 2, 2},
      {">", 5, 1},
      {"+", 6, 2},
      {"-", 5, 3}}
   }

   --отображение объектов на карте
   local objectData = {"content/fantasy-tileset_b.png",
      {{">", 5, 1}} -- лестница
   }

   --отображение игрока
   local playerData = {"content/fantasy-tileset.png",
      {{"@", 0, 18}}
   }

   --отображение затененных тайлов
   local shadowsData = {"content/fantasy-tileset_bg.png",
      {{".", 4, 3},
      {"#", 2, 2},
      {">", 5, 1},
      {"+", 6, 2},
      {"-", 5, 3}}
   }

   --создать объект с данными для слоев отображения
   self.frameLayers = {}

   --карта
   table.insert(self.frameLayers,
      {name = "map",
      data = matrix:New (self.frame.N, self.frame.M),
      lay = layer (mapData)})

   ---[[
   --объекты
   table.insert(self.frameLayers,
      {name = "objects",
      data = matrix:New (self.frame.N, self.frame.M),
      lay = layer (objectData)})
   --]]

   --существа
   table.insert(self.frameLayers,
      {name = "creatures",
      data = matrix:New (self.frame.N, self.frame.M),
      lay = layer (playerData)})

   --тень
   table.insert(self.frameLayers,
      {name = "shadows",
      data = matrix:New (self.frame.N, self.frame.M),
      lay = layer (shadowsData)})
end --init

--функция настраивающая отображение на новый игровой уровень
function M:setViewer (world)
   --после генерации новой карты объект с ней передается в отображение.
   self.world = world

   --запомнить максимальные размеры карты
   self.MaxMap = vector (self.world:getMapSize ())
end

--отображение на экран
function M:draw ()
   --размерность отдельного тайла
   local tw, th = 32, 32

   --отображение идет на основе данных из наборов слоев отображения
   for _, val in ipairs(self.frameLayers) do
      --для каждого слоя
      for i, j, v in val.data:Iterate () do
         --пройтись по всем точкам из данных слоя и на основе того,
         --какие тайлы там сохранены, отобразить на экране нужные рисунки
         if v and v ~= 0 then
            --print (i, j, v, val.name)
            love.graphics.draw (val.lay.tileset,
               val.lay:getQuad (v),
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

   --теперь нужно обновить данные о слоях отображения, чтобы реже обращаться
   --к объекту карты - только при перемещении игрока, а не каждый тик
   self:updateViewer ()
end

--функция обновления данных о том, что нужно отображать на разных уровнях
function M:updateViewer ()
   --пройтись по всему фрейму и для каждой точки получить объект Cell
   --из карты. разобрать, что получилось из этого объекта и соответственно,
   --заполнить слои для отображения.
   for i, j, _ in self.frame:Iterate () do
      local curCell = self.world:getCell (
         i + self.framePos.x,
         j + self.framePos.y)

      --напишем, что отобразилось
      --print(curCell["visited"].tile)

      --print (unpack (curCell))
      if not curCell then
         error ("curCell = nil")
      end

      --если данная ячейка уже была видима, то определяются данные для
      --отображения
      if curCell["visited"].tile then
         for _, val in ipairs(self.frameLayers) do
            --для каждого уровня занести, что имеем
            --print (val.name)
            if curCell[val.name].tile then
               val.data:Set (i, j, curCell[val.name].tile)
            else
               val.data:Set (i, j, nil)
            end

            --отобразить, что получилось для слоя с затемнением
            --val.data:Write ()
         end
      else
         --если данная точка еще не была разведана
         for _, val in ipairs(self.frameLayers) do
            val.data:Set (i, j, nil)
         end
      end
   end

   --отобразить, что получилось для слоя с затемнением

end --updateViewer

return M
