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

--[[----------------Модульные тесты------------------]]--

--проверка правильности создания нового протолабиринта
local function test_New ()
   local xlen, ylen = 10, 2
   
   print ("\nСоздадим новый лабиринт с размером " .. tostring (xlen) .. 
      " на " .. tostring (ylen))
   
   local testMaze = M:New (xlen, ylen)
   
   assert ((#testMaze ~= xlen) and (#testMaze[1] ~= ylen),
      "Размер лабиринта не равен заданному! \n" 
      .. "X должен быть " .. tostring (xlen) .. " по факту " .. tostring (#testMaze) .. "\n" 
      .. "Y должен быть " .. tostring (ylen) .. " по факту " .. tostring (#testMaze[1]) .. "\n")
end

return M
