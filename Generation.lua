--Алгоритмы генерации лабиринтов
Maze = require "Maze"
require "Solve"

--создадим структуру равную количеству комнат в лабиринте
local Type = {Inside = 1, Outside = 2, Border = 3}

--Нужно создать дополнительную структуру для хранения всех локаций с признаком Border
local BorderList = {}

--перечисление возможных соседей
local neiborsX = {1,  0, -1, 0}
local neiborsY = {0, -1,  0, 1}

--Предполагается, что при каждом добавлени локации  список будет обновляться
local function AddBorder (x_, y_)
	--занести данные о этой локации в список BorderList
	--BorderList:insert ({x_, y_})
	table.insert (BorderList, {x_, y_})
end

--при смене атрибута для локации она удаляется из списка
local function DelBorder (x_, y_)
	--ищем данный элемент в списке
	for i = 1, #BorderList do
		if BorderList[i][1] == x_ and BorderList[i][2] == y_ then
			BorderList:remove (i)
		end
	end
	--и удаляем его 
end

--вернуть случайную локацию из списка BorderList
local function RndBorder ()
	local rezNum = math.random (1, #BorderList)
	
	local rez = BorderList[rezNum]
	
	--BorderList:remove (rezNum)
	table.remove (BorderList, rezNum)
	
	return rez[1], rez[2]
end

--вспомогательная функция - устанавливаент некоторый атрибут для всех соседей локации
local function SetNeiborsBorder (Stryct_, x_, y_)
	--установить всем возможным соседям переданное значение, если это разрешено
	for i = 1, 4 do
		--проверка ограничения на выход за границы массива
		local check = true
	
		if x_ + neiborsX[i] < 1 or x_ + neiborsX[i] > Stryct_.N or y_ + neiborsY[i] < 1 or y_ + neiborsY[i] > Stryct_.M then
			check = false
		end
		
		if check and Stryct_[x_ + neiborsX[i]][y_ + neiborsY[i]] == Type.Outside then
			Stryct_[x_ + neiborsX[i]][y_ + neiborsY[i]] = Type.Border
			
			AddBorder (x_ + neiborsX[i], y_ + neiborsY[i])
		end
	end	
end

--вернуть случайную локацию соседнюю с текущей, где  атрибут  - Внутри
local function GetNeiborLocate (Stryct_, x_, y_)
	local finde = false
	
	while not finde do
		local rnd = math.random (1, 4)
	
		--если существует
		local check = true
	
		if x_ + neiborsX[rnd] < 1 or x_ + neiborsX[rnd] > Stryct_.N or y_ + neiborsY[rnd] < 1 or y_ + neiborsY[rnd] > Stryct_.M then
			check = false
		end
		
		if check and Stryct_[x_ + neiborsX[rnd]][y_ + neiborsY[rnd]] == Type.Inside then
						
			finde = true
			return neiborsX[rnd], neiborsY[rnd]
		end
	
	end
end

--вспомогательная функция, ищет и возвращает количество элеменов с атрибутом На границе
local function GetBorderNum (Stryct_)
	local num = 0
	
	for i = 1, Stryct_.N do
		for j = 1, Stryct_.M do
			if Stryct_[i][j] == Type.Border then
				num = num + 1
			end
		end
	end
		
	return num
end

--Алгоритм Прима
function PrimGeneration (Maze_, height_, width_)
	--в начале готовится болванка - лабиринт со всами построенными стенами
	Maze_:SetClearMaze (height_, width_)
			
	local AtrStruct = {}
	AtrStruct.N = height_
	AtrStruct.M = width_
	
	for i = 1, height_ do
		AtrStruct[i] = {}
		
		for j = 1, width_ do
			AtrStruct[i][j] = Type.Outside
		end
	end
	
	--для случайной локации ставим атрибут Внутри, для всех ее соседей - На границе
	local rndI, rndJ = math.random (1, height_), math.random (1, width_)
	AtrStruct[rndI][rndJ] = Type.Inside
	
	SetNeiborsBorder (AtrStruct, rndI, rndJ)
	
	--print ("AtrStruct.N: " .. tostring (AtrStruct.N) .. " AtrStruct.M: " .. tostring (AtrStruct.M))
	
	--пока атрибут хотя бы одной локации равен на границе
	while #BorderList > 0 do
		--выбираем случайную локацию, атрибут которой На границе
		local rndX, rndY = RndBorder ()
		
		--print ("rndX: " .. tostring (rndX) .. " rndY: " .. tostring (rndY) )
		
		--присваеваем ей атрибут Внутри
		AtrStruct[rndX][rndY] = Type.Inside
		
		--для всех соседних с ней локаций, атрибут которых Снаружи
		--поставим На границе
		SetNeiborsBorder (AtrStruct, rndX, rndY)
		
		--выберем случайную локацию Внутри на границе с текущей 
		local shiftX, shiftY = GetNeiborLocate (AtrStruct, rndX, rndY)
		
		--и сломаем между ними стену
		Maze_:BreakWall (rndX, rndY, shiftX, shiftY)
	end
end --PrimGeneration