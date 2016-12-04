--Добавление функций от love2d

local maze     = require "Maze.Maze"
local matrix   = require "lua_utils.matrix"
local vector   = require "hump.vector"
local layer    = require "View.layer"
local viewer   = require "View.viewer"

--подготовка генератора случайных чисел
math.randomseed (os.time ())

--сгенерированная карта
local genericMap = {}

--слой с картой
local mapLayer = {}

--объект отображения
local Viewer = {}

function love.load ()
   --создать карту
   genericMap = maze:Generate (60, 90)

   --данные для заполнения слоя с картой
   local mapInfo = {}
   mapInfo.tileset = "fantasy-tileset_b.png"
   mapInfo.tileSize = vector (32, 32)
   mapInfo.map = genericMap
   mapInfo.tileInfo = {
      {"#", 2, 2},   --стена
      {".", 4, 3}    --пол
   }

   --задать данные для слоя
   mapLayer = layer (mapInfo)

   --данные для отображенрия
   local viewInfo = {}
   viewInfo.frameSize = vector (16, 30)
   viewInfo.framePos = vector (0, 0)
   viewInfo.frameStart = vector (0, 0)
   viewInfo.mainMap = mapLayer

   Viewer = viewer (viewInfo)
end

function love.update (dt)

end

function love.draw ()
   Viewer:show ()
end
