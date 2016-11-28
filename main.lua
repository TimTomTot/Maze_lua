--Добавление функций от love2d

local maze     = require "Maze.Maze"
local matrix   = require "lua_utils.matrix"

--подготовка генератора случайных чисел
math.randomseed (os.time ())

-- константы, облегчающие жизнь
local tileWidth  = 32 -- ширина тайла
local tileHeight = 32 -- высота тайла

--матрица для отображения на экране
local viewN, viewM = 20, 30
local windowView = matrix:New (viewN, viewM)

--лабиринт
local bigMaze = maze:Generate (viewN * 3, viewM * 3)

--функция переносящая часть лабиринта на зону отображения
function SetShow (maze, window, i0, j0)
   -- для всех точек окна перенести точки из лабиринта
   for i, j, _ in window:Iterate () do
      window:Set (i, j, maze:Get (i + i0 - 1, j + j0 - 1))
   end
end

--позиции для отображения
local posi, posj = 1, 1

function love.load ()
   -- загрузка изображения
	tileset = love.graphics.newImage ("fantasy-tileset_b.png")

	-- создание из изображения отдельных тайлов
	-- стена
	wallTile = love.graphics.newQuad (tileWidth * 2,
		tileHeight * 2,
		tileWidth,
		tileHeight,
		tileset:getWidth (),
		tileset:getHeight ())

	--пол
	floorTile = love.graphics.newQuad (tileWidth * 4,
		tileHeight * 3,
		tileWidth,
		tileHeight,
		tileset:getWidth (),
		tileset:getHeight ())

   --первое отображение
   SetShow (bigMaze, windowView, posi, posj)
end

function love.update (dt)
   -- если зафиксировано нажатие на стрелки,
   --то перемещаем точку отображения и перерасчитываем,
   --что нужно отрисовывать

   --признак того, что нужно менять отображение
   local ischanget = false

   if love.keyboard.isDown ("up") then
      ischanget = true
      posi = posi - 1
   end

   if love.keyboard.isDown ("down") then
      ischanget = true
      posi = posi + 1
   end

   if love.keyboard.isDown ("right") then
      ischanget = true
      posj = posj + 1
   end

   if love.keyboard.isDown ("left") then
      ischanget = true
      posj = posj - 1
   end

   if ischanget then
      --проверка и ограничение аргументов
      if posi < 1 then
         posi = 1
      elseif posi > bigMaze.N - viewN + 1 then
         posi = bigMaze.N - viewN + 1
      elseif posj < 1 then
         posj = 1
      elseif posj > bigMaze.M - viewM + 1 then
         posj = bigMaze.M - viewM + 1
      end

      ischanget = false
      SetShow (bigMaze, windowView, posi, posj)
   end
end

function love.draw ()
   --  отображение на экране
   for i, j, val in windowView:Iterate () do
      local currTile

      -- определить, что рисовать
      if val == 1 then
         currTile = wallTile
      elseif val == 0 then
         currTile = floorTile
      end

      --нарисовать
      love.graphics.draw (tileset,
         currTile,
         j * tileHeight - tileHeight,
         i * tileWidth - tileWidth)
   end
end
