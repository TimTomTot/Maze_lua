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

   --созранить данные для вызова сигналов в понятном и удобочитаемом виде
   self.kaySignal = {}

   for _, val in ipairs (input.kayConform) do
      table.insert (self.kaySignal, {kay = input.kayConform[1], identifire = input.kayConform[2]})
   end
end

--ловля пользовательского ввода и посылка сигналов в систему
function M:handle ()
   for _, val in ipairs (self.kaySignal) do
      if love.keyboard.isDown (val.kay) then
         print (tostring (val.kay))
         self.signal:emit (val.identifire)
         --break
      end
   end

   --[[
   --обработка ввода производится только по истечению периода задержки
   if self.currDelay == 0 then
      --обработка
      for _, val in ipairs (self.kaySignal) do
         if love.keyboard.isDown (val.kay) then
            self.signal:emit (val.identifire)
            break
         end
      end

      --перезапуск счетчика задержки
      self.currDelay = self.delay
   else
      self.currDelay = self.currDelay - 1
   end
   ]]--
end

return M
