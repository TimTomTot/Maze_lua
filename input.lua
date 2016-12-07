--модуль определения пользовательского ввода

local class    = require "hump.class"
local signal   = require "hump.signal"

local M = class {}

--конструктор
--данные как всегда передаются таблицей
-- signal       - обработчик сигналов с которым работает inputHandler
-- delay        - задержка перед следующей обработкой нажатия кнопки
-- kayConform   - таблица с соответствием кнопки и вызываемого по ее нажатию события
function M:init (input)
   --задать обработчик
   self.signal = input.signal

   --задать задержку обработчика
   self.delay = input.delay
   self.currDelay = self.delay

   self.signelTable = input.kayConform
end

--ловля пользовательского ввода и посылка сигналов в систему
function M:handle ()
   if self.currDelay == 0 then
      for _, val in ipairs(self.signelTable) do
         --обработка пользовательского ввода на самом простом уровне
         if love.keyboard.isDown (val[1]) then
            self.signal:emit (val[2])
            break
         end
      end

      self.currDelay = self.delay
   else
      self.currDelay = self.currDelay - 1
   end
end

return M
