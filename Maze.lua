local Room = require "Room" --комнаты для лабиринта
local Conf = require "MazeConfig" --конфигурационный файл лабиринта 

-------------Лабиринт--------------
--Лабиринт будет из себя представлять прямоугольную таблицу комнат
local M = {}

--Парсер лабиринта из заданого входного файла
function M:Load (fileName_)
	local fileIn = io.open (fileName_, "r")
	
	--прочитать размерность лабиринта 
	self.colums, self.rows = fileIn:read ("*number", "*number")
	
	--прочитать данные для каждой комнаты лабиринта в соответствии с 
	--полученным ранее размером
	for i = 1, self.rows do
		self[i] = {}
		
		for j = 1, self.colums do
			self[i][j] = Room:New (fileIn:read ("*number", "*number"))
		end
	end
end

--сохранение лабиринта в файл
function M:Save ()
	--создадим файл для записи
	--имя для файла
	local FileName = tostring (os.date ("%H_%M_%S")) .. "_maze_save.txt"
		
	local OutputFile = io.open (FileName, "w")
	
	--записать размерность лабиринта
	OutputFile:write (tostring (self.colums) .. " " .. tostring (self.rows) .. "\n")
	
	--записать данные для каждой комнаты
	for i = 1, self.rows do
		for j = 1, self.colums do
			local l, t = self[i][j]:GetWall ()
			OutputFile:write (tostring (l) .. " " .. tostring (t) .. "\n")
		end
	end
end

--вывод лабиринта в файл
function M:Show ()
	--вариант такой, сразу создать по размерам будущего лабиринта 
	--поле (двумерный массив)
	--потом проходиться по структуре лабиринта и для каждой комнаты
	--писать в пустой массив стены и пустоты
	
	--а потом получившейся буфер распечатать в файл
			
	--размер представления лабиринта на экране
	local w, h = self.rows * Conf.roomSize + 1, self.colums * Conf.roomSize + 1
	
	--подготовка буфера 
	local buffer = {}
	
	for i = 1, w do
		buffer[i] = {}
		
		for j = 1, h do
			buffer[i][j] = Conf.empty 
		end
	end
	
	--внесение данных в буфер в соответствии с тем, 
	--что же записано в конкретной комнате лабиринта
	for l = 1, self.rows do
		for t = 1, self.colums do
			if debugMode then
				print ("l: " .. tostring (l) .. " t: " .. tostring (t))
			end
			
			local lWall, tWall = self[l][t]:GetWall ()
	
			local l0, t0 = (l - 1) * Conf.roomSize + 1, (t - 1) * Conf.roomSize + 1
	
			if tWall == 1 then
				for itX = l0, l0 + (Conf.roomSize - 1) do
					buffer[itX][t0] = Conf.wall
				end
			end
	
			if lWall == 1 then
				for itY = t0, t0 + (Conf.roomSize - 1) do
					buffer[l0][itY] = Conf.wall
				end
			end			
		end
	end	 
	
	--по правому и нижнему краю лабиринта необходимо проложить стены
	for i = 1, w do
		buffer[i][h] = Conf.wall
	end
	
	for j = 1, h do
		buffer[w][j] = Conf.wall
	end
	
	--определяем, куда выводить лабиринт
	if Conf.targetFile then
		--имя для файла
		local FileName = tostring (os.date ("%d_%m_%y_%H_%M")) .. "_maze.txt"
		
		OutputFile = io.open (FileName, "w")
	end
	
	--выводим полученый результат в файл
	for i = 1, w do
		for j = 1, h do
			--нарисовать
			if Conf.targetFile then
				OutputFile:write (buffer[i][j])
			end
			
			if Conf.targetScreen then
				io.write (buffer[i][j])
			end
		end
		
		if Conf.targetFile then
			OutputFile:write ("\n")
		end
		
		if Conf.targetScreen then
			io.write ("\n")
		end
	end --вывод лабиринта в файл	
	
end --Maze:Show

--создание нового лабиринта - по принципу инстанцирования в ООП
function M:New ()
	local m = {}
	
	setmetatable (m, self)
	
	self.__index = self
	
	return m
end

--есть ли проход между двумя локациями
--передается координата текущел локации и смещение к локации, в которую надо пройти
function M:IsGo (x_, y_, dx_, dy_)
		
	local left, top
	local rez
	
	if dx_ == -1 then
		left, top =  self[x_][y_]:GetWall ()
		
		if left == 0 then 
			rez = true
		else 
			rez = false
		end
	elseif dx_ == 1 then
		left, top =  self[x_ + 1][y_]:GetWall ()
		
		if left == 0 then 
			rez = true
		else 
			rez = false
		end
	elseif dy_ == -1 then
		left, top =  self[x_][y_]:GetWall ()
		
		if top == 0 then 
			rez = true
		else 
			rez = false
		end
	elseif dy_ == 1 then
		left, top =  self[x_][y_ + 1]:GetWall ()
		
		if top == 0 then 
			rez = true
		else 
			rez = false
		end
	end
	
	return rez
end

--создание лабиринта-болванки для дальнейфей генерации
function M:SetClearMaze (height_, width_)
	self.colums, self.rows = width_, height_ 
	
	print ("self.colums: " .. tostring (self.colums) .. " self.rows: " .. tostring (self.rows))
	
	for i = 1, self.rows do
		self[i] = {}
		
		for j = 1, self.colums do
			self[i][j] = Room:New (1, 1)
		end
	end
end

--функция сносит стену между двумя локациями в лабиринте
function M:BreakWall (x_, y_, dx_, dy_)
	--print ("X: " .. tostring (x_ + dx_) .. " Y: " .. tostring (y_ + dy_))

	local left, top
		
	if dx_ == -1 then
		left, top =  self[x_][y_]:GetWall ()
		self[x_][y_]:SetWalls (0, top)
		
	elseif dx_ == 1 then
		left, top =  self[x_ + 1][y_]:GetWall ()
		self[x_ + 1][y_]:SetWalls (0, top)
		
	elseif dy_ == -1 then
		left, top =  self[x_][y_]:GetWall ()
		self[x_][y_]:SetWalls (left, 0)
				
	elseif dy_ == 1 then
		left, top =  self[x_][y_ + 1]:GetWall ()
		self[x_][y_ + 1]:SetWalls (left, 0)
	
	end	
end

return M