--Добавление функций от love2d

local maze     = require "Maze.Maze"
local viewer   = require "view.viewer"
local world    = require "world"
local signal   = require "hump.signal"
local input    = require "input"
local player   = require "player"

--подготовка генератора случайных чисел
math.randomseed (os.time ())

--мир игры
local GameWorld = world ()

--объект отображения
local Viewer = {}

--обработчик сигналов пользовательского ввода
local inputSignal = signal.new ()

--обработчик сигналов для отображения
local viewSignal = signal.new ()

--пользовательский ввод
local inputHandler = {}

--игрок
local Hero = {}

function love.load ()
   --создать карту и запомнить ее на игровом мире
   local newMap = maze:Generate (60, 90)
   GameWorld:addMap (newMap)

   --настоить отбражение
   Viewer = viewer (GameWorld, viewSignal)

   --настроить пользовательский ввод
   local inputData = {signal = inputSignal,
      delay = 4,
      kayConform = {{"up", "moveUp"},
      {"down", "moveDown"},
      {"right", "moveRight"},
      {"left", "moveLeft"}}
   }
   inputHandler = input (inputData)

   --связать пользовательский ввод со смещением изображения
   inputSignal:register ("moveRight", function () Hero:step (0, 1) end)
   inputSignal:register ("moveLeft", function () Hero:step (0, -1) end)
   inputSignal:register ("moveDown", function () Hero:step (1, 0) end)
   inputSignal:register ("moveUp", function () Hero:step (-1, 0) end)

   --создать игрока
   Hero = player ({id = 1,
      tile = "@",
      world = GameWorld,
      signalView = viewSignal})

   --установить игрока на карту
   Hero:setToMap ()
end

function love.update (dt)
   inputHandler:handle ()
end

function love.draw ()
   Viewer:draw ()
end
