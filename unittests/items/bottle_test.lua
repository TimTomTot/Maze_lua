-- модульные тесты для bottle

local Bottle = require "items.bottle"

local function test_init()
    local bt = Bottle:new()
    
    assert(is("bottle", bt.name))
    assert(is("|"), bt.tile)
end

local function test_stand()
    local bt = Bottle:new()
    
    local creature_stub = {}
    
    local signal = {}
    
    function signal:emit(to, what, msg)
        if to == "hud" and what == "message" then
            self.msg = msg
        end
    end
    
    creature_stub.signal = signal
    
    -- в этой точке вызывается проверяемый метод
    bt:stand(creature_stub)
    
    assert(is(creature_stub.signal.msg, "Здесь лежит бутылочка"))
end
