-- модуль с отображением данных на экране (пользовательский интерфейс)

local class = require "hump.class"

local M = class {}

--конструктор
function M:init (font, pt)
   --настройка шрифта для отображения
   self.font = love.graphics.newFont (font, pt)
end

--отрисовка hud на экране
function M:draw ()
   --установить фрифт, которым все надписи будут отображаться
   love.graphics.setFont (self.font)

   --для примера, просто проверка того, что система работает
   love.graphics.print ("Test! Проверка!", 10, 10)
end

return M