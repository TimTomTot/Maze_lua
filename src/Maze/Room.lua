--Модуль с описанием комнаты в лабиринте
--Комната в лабиринте - описывается наличием/отсутствием лавой и верхней стены
local R = {}

--установить стены
function R:SetWall (leftWall_, topWall_)
	self.leftWall = leftWall_
	self.topWall = topWall_
end 

--получиить данные о стенах 
function R:GetWall ()
	return self.leftWall, self.topWall
end

--похоже, тут не обойтись без классов. Или обойтись?
--создание новой комнаты
--для упрощения реализации объединим создание комнаты с установкой в ней стен
function R:New (leftWall_, topWall_)
	--создадим таблицу
	local o = {}
	
	--установим для нее метатаблицу от Room
	setmetatable (o, self)
	self.__index = self -- не понятная строчка, но без нее ничего не работает
	
	--по умолчанию устанавливаем наличие обоих стен в комнате
	local lWall, tWall = leftWall_ or 1, topWall_ or 1 
	
	o:SetWall (lWall, tWall)
	
	return o
end

return R

