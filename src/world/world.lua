--[[
	Новый вариант модуля world
	Теперь это только контейнер, который дает доступ к субмодулям,
	содержащим все необходимые данные
--]]


local class = require "30log"


local World = class("World")

function World:init(data)
	-- body
end

return World

