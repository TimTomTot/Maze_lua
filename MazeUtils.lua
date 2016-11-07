--Лабиринты по заветам мозгового

-------------Лабиринт--------------
Maze = require "Maze"
require "Solve"
require "Generation"

-----точка входа-----
math.randomseed (os.time ())

--создадим новый лабиринт
SomeMaze = Maze:New ()

--загрузить в память тестовый лабиринт
--SomeMaze:Load (arg[1])

--создать лабиринт болванку
--SomeMaze:SetClearMaze (14, 5)

--создать случайный лабиринт
PrimGeneration (SomeMaze, 8, 24)

--и вывести его в файл
SomeMaze:Show ()

--и сохранить в другом файле
--SomeMaze:Save ()
