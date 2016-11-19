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
   
   --проверка слева
   --проверить, что между комнатами с проходом есть проход
   assert (maze1:IsGo (1, 2, -1, 0) == true,
      "Не находится проход между комнатами, когда он есть")
   
   --проверить, что между комнатами без прохода нет прохода
   assert (maze1:IsGo (1, 3, -1, 0) == false,
      "Находится проход между комнатами, где его нет")
end

return M
