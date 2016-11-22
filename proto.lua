--протолабиринт - состоит из набора комнат

--комнаты
local room = require ("Room")
local utils = require ("lua_utils.maputils")

local M = {}

--создать новый протолабиринт
--по принципу инстанцирования в ООП
function M:New (xlen, ylen)
	local m = {}
   
   --устанавливаем размер для протолабиринта
   utils.SetSize (m, xlen, ylen)
   
   --создадим нужное количество комнат
   for i, j, _ in utils.Iter (m) do
      m[i][j] = room:New (1, 1)
   end
	
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
      left, top =  self[x_][y_ + 1]:GetWall ()
		      
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
		left, top =  self[x_ + 1][y_]:GetWall ()
		
		if top == 0 then 
			rez = true
		else 
			rez = false
		end
	end
	
	return rez
end --IsGo

--функция сносит стену между двумя локациями в лабиринте
function M:BreakWall (x_, y_, dx_, dy_)
	--print ("X: " .. tostring (x_ + dx_) .. " Y: " .. tostring (y_ + dy_))

	local left, top
		
	if dx_ == -1 then
		left, top =  self[x_][y_]:GetWall ()
		self[x_][y_]:SetWalls (0, top)
		
	elseif dx_ == 1 then
		left, top =  self[x_][y_ + 1]:GetWall ()
		self[x_][y_ + 1]:SetWalls (0, top)
		
	elseif dy_ == -1 then
		left, top =  self[x_][y_]:GetWall ()
		self[x_][y_]:SetWalls (left, 0)
				
	elseif dy_ == 1 then
      --print ("x_ + 1", x_ + 1)
      --print ("y_", y_)
		left, top =  self[x_ + 1][y_]:GetWall ()
		self[x_ + 1][y_]:SetWalls (left, 0)
	
	end	
end --BreakWall

--[[----------------Модульные тесты------------------]]--

--проверка правильности создания нового протолабиринта
local function test_New ()
   local xlen, ylen = 10, 2
   
   --print ("\nСоздадим новый лабиринт с размером " .. tostring (xlen) .. 
   --   " на " .. tostring (ylen))
   
   local testMaze = M:New (xlen, ylen)
   
   assert ((#testMaze == ylen) and (#testMaze[1] == xlen),
      "Размер лабиринта не равен заданному! \n" 
      .. "Y должен быть " .. tostring (ylen) .. " по факту " .. tostring (#testMaze) .. "\n" 
      .. "X должен быть " .. tostring (xlen) .. " по факту " .. tostring (#testMaze[1]) .. "\n")
end

--проверка функции возможности пройти из одной комнаты в другую
local function test_IsGo ()
   --подготовить тестовый лабиринт для проверки
   local maze1 = M:New (4, 4)
   maze1[1][2]:SetWalls (0, 1)
   maze1[2][3]:SetWalls (0, 1)
   maze1[2][2]:SetWalls (1, 0)
   maze1[3][1]:SetWalls (1, 0)
   
   --проверка слева
   --проверить, что между комнатами с проходом есть проход
   assert (maze1:IsGo (1, 2, -1, 0) == true,
      "Слева. Не находится проход между комнатами, когда он есть")
   
   --проверить, что между комнатами без прохода нет прохода
   assert (maze1:IsGo (1, 3, -1, 0) == false,
      "Слева. Находится проход между комнатами, где его нет")
   
   --проверка справа
   assert (maze1:IsGo (1, 1 , 1, 0) == true,
      "Cправа. Не находится проход между комнатами, когда он есть")
   
   --print (maze1:IsGo (1, 1 , 1, 0))
   --print (maze1[1][2]:GetWall ())
      
   assert (maze1:IsGo (2, 1, 1, 0) == false,
      "Справа. Находится проход между комнатами, где его нет")                        
   
   --проверка сверху
   assert (maze1:IsGo (2, 2, 0, -1) == true,
      "Сверху. Не находится проход между комнатами, когда он есть")
   
   assert (maze1:IsGo (2, 1, 0, -1) == false,
      "Сверху. Находится проход между комнатами, где его нет")
   
   --проверка снизу
   assert (maze1:IsGo (2, 1, 0, 1) == true,
      "Снизу. Не находится проход между комнатами, когда он есть")
   
   assert (maze1:IsGo (2, 2, 0, 1) == false,
      "Снизу. Находится проход между комнатами, где его нет")
end

local function test_BreakWall ()
   --проласываем стены в тестовых лабиринтах, потом проверяем, 
   --что сломали там, где нужно
   
   --ломаем стену направо
   local maze1 = M:New (3, 3)
   maze1:BreakWall (2, 2, 1, 0)
   local rezL1, rezT1 = maze1[2][3]:GetWall ()
   
   assert (rezL1 == 0,
      "Стена направо не сломалась!")
   maze1 = nil   
   
   --ломаем стену налево
   local maze2 = M:New (3, 3)
   maze2:BreakWall (2, 2, -1, 0)
   local rezL2, rezT2 = maze2[2][2]:GetWall ()
   
   assert (rezL2 == 0,
      "Стена налево не сломалась!")
   maze2 = nil
      
   --ломаем стену вверх
   local maze3 = M:New (3, 3)
   maze3:BreakWall (2, 2, 0, -1)
   local rezL3, rezT3 = maze3[2][2]:GetWall ()
   
   assert (rezT3 == 0,
      "Стена вверх не сломалась!")
   maze3 = nil
   
   --ломаем стену вниз
   local maze4 = M:New (3, 3)
   maze4:BreakWall (2, 2, 0, 1)
   local rezL4, rezT4 = maze4[3][2]:GetWall ()
   
   assert (rezT4 == 0,
      "Стена вниз не сломалась!")
   maze4 = nil
end

return M
