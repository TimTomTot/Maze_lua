--Добавление функций от love2d

local maze     = require "Maze.Maze"
local viewer   = require "view.viewer"
local world    = require "world"
local signal   = require "hump.signal"
local vector   = require "hump.vector"
local input    = require "input"
local player   = require "player"
local hud      = require "hud"

--подготовка генератора случайных чисел
math.randomseed (os.time ())
--math.randomseed (15)

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

--пользовательский интерфейс
local ui = {}

function love.load ()
   --создать карту и запомнить ее на игровом мире
   local newMap = maze:Generate (60, 90)
   GameWorld:addMap (newMap)

   --настоить отбражение
   Viewer = viewer (GameWorld, viewSignal)

   --настроить пользовательский ввод
   local inputData = {signal = inputSignal,
      kayConform = {{"up", "moveUp"},
         {"down", "moveDown"},
         {"right", "moveRight"},
         {"left", "moveLeft"}
      }
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
      signalView = viewSignal,
      R = 5})

   --установить игрока на карту
   Hero:setToMap ()

   --загрузка пользовательского интерфейса
   ui = hud ("neuropol_medium.ttf", 13, viewSignal)

   --создать лейбл для отображения fps
   ui:addLable ({name = "fps", pos = vector (10, 10)})

   --лейбл для отображения основных игровых сообщений
   ui:addLable ({name = "message", pos = vector (180, 10)})
end

--обработка нажатия кнопок
function love.keypressed (key, isrepeat)
   inputHandler:handle (key)
end

function love.update (dt)
   --обновлять данные о fps
   viewSignal:emit (
      "hud",
      "fps",
      "FPS: " .. tostring (love.timer.getFPS ()))
end

function love.draw ()
   Viewer:draw ()
   ui:draw ()
end
