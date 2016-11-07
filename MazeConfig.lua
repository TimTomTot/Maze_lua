--конфигурационный файл для лабиринта
local MazeConfig = {}

--размер одной комнаты в лабиринте при печати
MazeConfig.roomSize = 3

--куда выводить полученный лабиринт - на экран, или в файл
MazeConfig.targetScreen = true
MazeConfig.targetFile = true

--тайлсет для отображения
MazeConfig.wall = "#" 		--стены
MazeConfig.empty = "."		--полы
MazeConfig.unknown = "?"	--неизвестные тайлы

return MazeConfig