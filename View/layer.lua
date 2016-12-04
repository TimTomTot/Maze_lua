--отдельный слой для Viewer

--[[
Пример с таблицей tileInfo

Info = {
   {"#", 1, 1},   --тайл со стеной, данные, из какой части тайлсета он вырезается он вырезается
   {".", 1, 2}    --тайл с полом, данные, из какой части тайлсета он вырезается он вырезается
   }
]]--

local class    = require "hump.class"
local vector   = require "hump.vector"

local L = class {}

--конструктор
--как правильно передавать параметры в слой
--tileset   - адрес тайлсета из которого будут нарезаться картинки
--tileInfo  - таблица с данными для вырезания и парсинга карт
--map       - слой в объекте World, из которого будут парситься значения
--tileSize  - вектор с размерами отдельных тайлов
function L:init (input)
   self.tileset = love.graphics.newImage (input.tileset)
   self.tileWidth, self.tileHeight = input.tileSize:unpack ()

   self.map = input.map

   --список тайлов
   self.quads = {}

   for i, val in ipairs (input.tileInfo) do
      --что парсить
      table.insert (self.quads, {sign = val[1]})

      self.quads[i].tile = love.graphics.newQuad (self.tileWidth * val[2],
         self.tileHeight * val[3],
         self.tileWidth,
         self.tileHeight,
         self.tileset:getWidth (),
         self.tileset:getHeight ())
   end
end

--парсер.
--получает на вход данные из какого места целевой карты парсить,
--возвращает тайлсет и тайл, который нужно нарисовать
--если возвращается 0, то не нужно в этой точке рисовать тайлы
function L:parser (i, j)
   --метод getTile должен быть у всех слоев игрового мира
   local tile = self.map:getTile (i, j)

   --какой тайл возвращать
   local rez

   --поиск, что нужно вернуть по полученному тайлу
   for _, val in ipairs (self.quads) do
      if val.sign == tile then
         rez = val.tile
         break
      end
   end

   return rez
end

-----------------------------------------------------------------
--                         Пример                              --
-----------------------------------------------------------------
--[[
--создание структуры данных для инициализации слоя для существ
local creachersLayer = {}
creachersLayer.tileset = "fantasy-tileset_b.png"
creachersLayer.tileSize = vector (32, 32)
creachersLayer.map = World.creachersLayer
creachersLayer.info = {{"@", 0, 18}} -- игрок
]]--

return L
