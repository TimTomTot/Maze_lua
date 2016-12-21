--модуль определения пользовательского ввода

local class    = require "hump.class"
local signal   = require "hump.signal"

local M = class {}

--конструктор
--данные как всегда передаются таблицей
-- signal       - обработчик сигналов с которым работает inputHandler
-- kayConform   - таблица с соответствием кнопки и вызываемого по ее нажатию события
function M:init (input)
   --задать обработчик
   self.signal = input.signal
   
   self.signelTable = input.kayConform
   
   --разрешить повторение нажатия кнопок
   love.keyboard.setKeyRepeat (true)
end

--ловля пользовательского ввода и посылка сигналов в систему
function M:handle (key)
   for _, val in ipairs (self.signelTable) do   
      if key == val[1] then
         self.signal:emit (val[2])
      end
   end
end

return M
