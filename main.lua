--Добавление функций от love2d

local maze     = require "Maze.Maze"
local matrix   = require "lua_utils.matrix"
local vector   = require "hump.vector"
local layer    = require "View.layer"
local viewer   = require "View.viewer"
local input    = require "input"
local signal   = require "hump.signal"

--подготовка генератора случайных чисел
math.randomseed (os.time ())

--сгенерированная карта
local genericMap = {}

--слой с картой
local mapLayer = {}

--объект отображения
local Viewer = {}

--j,hаботчик пользовательского ввода
local inputHandler = {}

--обработчик сигналов
local inputSignal = {}

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

   --обработчик сигналов
   inputSignal = signal.new ()

   --информация для обработчика ввода
   local inputInfo = {}
   inputInfo.delay = 3
   inputInfo.signal = inputSignal
   inputInfo.kayConform = {
      {"up", "upMove"},
      {"down", "downMove"},
      {"right", "rightMove"},
      {"left", "leftMove"}
   }

   inputHandler = input (inputInfo)

   --задание функций для обработки сигналов
   inputSignal:register ("downMove", function ()   Viewer:move (vector (1, 0)) end)
   inputSignal:register ("upMove", function ()   Viewer:move (vector (-1, 0)) end)
   inputSignal:register ("rightMove", function ()   Viewer:move (vector (0, 1)) end)
   inputSignal:register ("leftMove", function ()   Viewer:move (vector (0, -1)) end)
end

function love.update (dt)
   inputHandler:handle ()
end

function love.draw ()
   Viewer:show ()
end
