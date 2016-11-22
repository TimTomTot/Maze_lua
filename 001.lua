--проверка работоспособности

local maze = require ("Maze")
local utils    = require ("lua_utils.maputils")

math.randomseed (11)

--создадим тестовый лабиринт
local test_maze = maze.Generate (3, 3)

--нарисуем его
utils.WriteMap (test_maze)