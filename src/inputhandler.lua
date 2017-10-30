--модуль определения пользовательского ввода

local Class    = require "30log"
local Signal   = require "hump.signal"
local Input = require "boipushy.Input"


local InputHandler = Class("InputHandler")

function InputHandler:init(data)
    self.input = Input()
    
    self.signal = data.signal
    self.repeatdelay = data.delay or 0.1
   
    self.signelTable = data.kayConform
    
    for _, val in ipairs(self.signelTable) do
        self.input:bind(val[1], val[2])
    end
end

--ловля пользовательского ввода и посылка сигналов в систему
function InputHandler:handle()
    for _, val in ipairs(self.signelTable) do   
        if self.input:pressRepeat(val[2], self.repeatdelay)  then
            self.signal:emit(val[2])
        end
    end
end

return InputHandler
