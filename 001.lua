--проверка работоспособности

local maze = require ("Maze")
local utils    = require ("lua_utils.maputils")

math.randomseed (os.time ())

--создадим тестовый лабиринт
local test_maze = maze.Generate (6, 5)

--нарисуем его
utils.WriteMap (test_maze)
