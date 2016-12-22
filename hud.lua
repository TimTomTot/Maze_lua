-- модуль с отображением данных на экране (пользовательский интерфейс)

local class    = require "hump.class"
local vector   = require "hump.vector"
local signal   = require "hump.signal"

local M = class {}

--конструктор
--шрифт
--размер шрифта
--обработчик сигналов
function M:init (font, pt, sign)
   --настройка шрифта для отображения
   self.font = love.graphics.newFont (font, pt)

   --cписок всех надписей на экране
   self.lables = {}

   --сохранить ссылку на обработчик сигналов
   self.signal = sign

   --регистрация изменения данных для лейбла
   self.signal:register (
      "hud",
      function (labelName, string)
         --пройтись по всем лейблам,
         for _, v in ipairs(self.lables) do
            --если имя переданное совпадает с именем лейбла
            if labelName == v.name then
               --поменять отображаемое значение для него
               v.value = string
               break
            end
         end
      end
   ) --регистрация данных
end

--добавление надписи для отображения
--данные передаются в виде:
-- name - имя лейбла
-- pos - позиция для отображения лейбла
function M:addLable (data)
   table.insert(self.lables,
      {name = data.name,      --имя
      pos = data.pos,         --позиция
      value = nil}            --данные для отображения
   )
end

--отрисовка hud на экране
function M:draw ()
   --установить фрифт, которым все надписи будут отображаться
   love.graphics.setFont (self.font)
   --сохранить изначальный цвет
   local r, g, b, a = love.graphics.getColor ()

   love.graphics.setColor (255, 0, 0)
   --для примера, просто проверка того, что система работает
   --love.graphics.print ("Test! Проверка!", 10, 10)

   --отображение всех актуальных лейблов
   for _, val in ipairs(self.lables) do
      if val.value then
         love.graphics.print (val.value, val.pos.x, val.pos.y)
      end
   end

   love.graphics.setColor (r, g, b, a)
end

return M
