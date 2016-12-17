--Добавление функций от love2d

local maze     = require "Maze.Maze"
local matrix   = require "utils.matrix"
local vector   = require "hump.vector"
local layer    = require "view.layer"
local viewer   = require "view.viewer"
local world    = require "world"

--подготовка генератора случайных чисел
math.randomseed (os.time ())

--мир игры
local GameWorld = world ()

--объект отображения
local Viewer = {}

function love.load ()
   --создать карту и запомнить ее на игровом мире
   local newMap = maze:Generate (60, 90)
   GameWorld:addMap (newMap)

   --настоить отбражение
   Viewer = viewer (GameWorld)
end

function love.update (dt)

end

function love.draw ()
   Viewer:draw ()
end
