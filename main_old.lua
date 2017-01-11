--Добавление функций от love2d

--игровые константы
require "const"

local maze     = require "Maze.Maze"
local viewer   = require "view.viewer"
local world    = require "world.world"
local signal   = require "hump.signal"
local vector   = require "hump.vector"
local input    = require "input"
local player   = require "player"
local hud      = require "view.hud"

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
   --карта генерируется на основе строки:
   local someMap = [[
########################################
#......................................#
#......................................#
#...........................>..........#
#......................................#
###################+####################
#........#......#.....#.......#........#
#........#......#.....#.......#........#
#........#......#.....#.......+........#
#........#......#.....#.......#........#
#........#......+.....#.......#........#
#........#......#.....#.......#........#
#........#......#.....#.......#........#
#........#......#.....#.......#........#
#........+......#.....+.......#........#
#........#......#.....#.......#........#
#........#......#.....#.......#........#
###################+####################
#......................................#
#......................................#
#......................................#
#......................................#
########################################
]]

   GameWorld:parseMap (someMap)

   --настоить отбражение
   Viewer = viewer (viewSignal)
   Viewer:setViewer (GameWorld)

   --настроить пользовательский ввод
   local inputData = {signal = viewSignal,
      kayConform = {
         {"up", "moveUp"},
         {"down", "moveDown"},
         {"right", "moveRight"},
         {"left", "moveLeft"},
         {".", "downSteer"},
         {"o", "openDoor"},
         {"c", "closeDoor"}
      }
   }
   inputHandler = input (inputData)

   --связать пользовательский ввод со смещением изображения
   viewSignal:register ("moveRight", function () Hero:step (0, 1) end)
   viewSignal:register ("moveLeft", function () Hero:step (0, -1) end)
   viewSignal:register ("moveDown", function () Hero:step (1, 0) end)
   viewSignal:register ("moveUp", function () Hero:step (-1, 0) end)

   ---[[
   --регестрация функции генерации новой карты
   viewSignal:register ("generateMap",
      function ()
         GameWorld:parseMap (someMap)
         Hero:setToMap ()
      end)
   --]]

   --создать игрока
   Hero = player ({id = 1,
      tile = "@",
      world = GameWorld,
      signalView = viewSignal,
      R = 5})

   --установить игрока на карту
   Hero:setToMap ()

   --загрузка пользовательского интерфейса
   ui = hud ("content/keyrusMedium.ttf", 22, viewSignal)

   --создать лейбл для отображения fps
   ui:addLable ({name = "fps", pos = vector (10, 10)})
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

function love.quit ()
   -- body...
end
