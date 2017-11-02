-- stub state


local Signal   = require "hump.signal"
local vector   = require "hump.vector"

local Input    = require "inputhandler"
local HUD      = require "view.hud"


st_stub = {}

local input = {}
local UI = {}
local signal = Signal:new()


function st_stub:init()
    UI = HUD("res/content/keyrusMedium.ttf", 22, signal)
    UI:addLable({name = "title", pos = vector (100, 10)})
    UI:addLable({name = "subtitle", pos = vector (100, 36)})
    
    local inputhandlerinitdata = {
        signal = signal,
        kayConform = {
            {"return", "returnPrevious"}            
        } 
    }
    
    inputhandler = Input:new(inputhandlerinitdata)
    
    signal:register("returnPrevious", function () gamestate.switch(self.previousState) end)
end

function st_stub:enter(previous)
    self.previousState = previous

    -- просто, вывод сообщения на экран
    signal:emit(
        "hud",
        "title",
        "Данный функционал не поддерживается на текущий момент"
    )
    
    signal:emit(
        "hud",
        "subtitle",
        "Чтобы вернуться нажмите Enter"
    )
end

function st_stub:update(dt)
    inputhandler:handle()
end

function st_stub:draw()
    UI:draw()
end

