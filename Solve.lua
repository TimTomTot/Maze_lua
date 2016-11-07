--Модуль с алгоритмами для решения лабиринта
Maze = require "Maze"

--служебная функция, нужна для прохода по всем значениям в двумерном массиве
local function MatrixIteration (row_, colum_, func_)
	for i = 1, row_ do
		for j = 1, colum_ do
			func_ (i, j)
		end
	end
end

--набор коэффициентов для поиска соседей
local neiborsX = {1, 0 , -1, 0}
local neiborsY = {0, -1 , 0, 1}

local function WaveSolve (Maze_, mark_, stopP_)
	--print (tostring (stopP_.X))
	--print (tostring (stopP_.Y))
	
	--найдем все локации, помеченные 1
	local iter = 1
	
	--признак того, есть ли решение
	local Solve = false
	
	repeat
		local noSolve = true
		
		--для каждой из них для каждой соседней проверим выполнение условий:
		for x = 1, Maze_.rows do
			for y = 1, Maze_.colums do
				--найти все локации, с которыми мы сейчас работаем
				if mark_[x][y] == iter then
					--проверить для каждого соседа этой локации выполнение условия,
					for i = 1, 4 do
						--что в ней 0 и между ними нет стены
						--тут должно быть проведено ограничение на стены лабиринта
						local someX, someY = x + neiborsX[i], y + neiborsY[i]
						
						local check = true 
						
						if someX < 1 or someX > Maze_.rows or someY < 1 or someY > Maze_.colums then
							check = false
							--print ("99")
						end
												
						
						if check and mark_[someX][someY] == 0 and Maze_:IsGo (x, y, neiborsX[i], neiborsY[i]) then
							noSolve = false
								
							mark_[someX][someY] = iter + 1	
							
							--проверяем, не является ли эта локация финишной
							if someX == stopP_.X and  someY == stopP_.Y then
								--print ("55")
								
								Solve = true
								return Solve
							end
						end
					end
				end
			end
		end
		
		iter = iter + 1
				
		if DebugMod then
			io.write ("\n")
			print ("Iteration: " .. tostring (iter - 1))
			io.write ("\n")
		
			for i = 1, Maze_.rows do
				for j = 1, Maze_.colums do
					io.write (mark_[i][j])
				end
					
			io.write ("\n")
			end
		end
		
	until noSolve --продолжаем, пока решение не будет найдено
	
	return Solve
end

--алгоритм волновой трассировки
function WaveTracing (Maze_, startPoint_, stopPoint_)
	--по размерам лабиринта создадим массив для решения	
	--занесем во все точки массива нули
	local Treck = {}
	
	for i = 1, Maze_.rows do
		Treck[i] = {}
	
		for j = 1, Maze_.colums do
			Treck[i][j] = 0
		end
	end
	
	--выберем локацию начала обхода и конца обхода
	Treck[startPoint_.X][startPoint_.Y] = 1
	
	--пробуем решить лабиринт
	if WaveSolve (Maze_, Treck, stopPoint_) then
		--для пробы, выведем на экран, что получилось
		io.write ("\n")
		
		for i = 1, Maze_.rows do
			for j = 1, Maze_.colums do
				io.write (Treck[i][j])
			end
		
			io.write ("\n")
		end
		
		return true
	else
		return false
	end
	
end
