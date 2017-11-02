--сосояние игры с финальной заставкой

local menu     = require "menu"
local signal   = require "hump.signal"
local input    = require "inputhandler"
local hud      = require "view.hud"
local vector   = require "hump.vector"

st_quitMenu = {}

--модули, необходимые для работы в этом состоянии
local Signal = signal.new()
local Input = {}
local UI = {}

local Menu = {}

function st_quitMenu:init()
    UI = hud("res/content/keyrusMedium.ttf", 22, Signal)
    UI:addLable({name = "title", pos = vector(100, 10)})

    Menu = menu:new({
        x = 100, 
        y = 100,
        font = "res/content/keyrusMedium.ttf", 
        pt = 22
    })
    
    Menu:addItem({
        text = "Вернуться назад",
        enterAction = function ()
            gamestate.switch(self.previousState)
        end
    })
    
    Menu:addItem({
        text = "Главное меню",
        enterAction = function ()
            gamestate.switch(st_startMenu)
        end
    })
    
    Menu:addItem({
        text = "Выход",
        enterAction = function ()
            love.event.quit()
        end
    })

    Menu:setSelect(1)
    
    local inputhandlerinitdata = {
        signal = Signal,
        kayConform = {
            {"up", "menuUp"},
            {"down", "menuDown"},
            {"return", "menuActivate"}            
        } 
    }
    
    Input = input:new(inputhandlerinitdata)
    
    Signal:register("menuUp", function () Menu:up() end)
    Signal:register("menuDown", function () Menu:down() end)
    Signal:register("menuActivate", function () Menu:enter() end)
end

function st_quitMenu:enter(previous)
    self.previousState = previous

    -- просто, вывод сообщения на экран
    Signal:emit(
        "hud",
        "title",
        "Закончить игру?"
    )

    -- первый вызов пунктов меню
    Menu:update()
end

function st_quitMenu:keypressed(key, isrepeat)
   
end

function st_quitMenu:update(dt)
    Input:handle()
    Menu:update()
end

function st_quitMenu:draw()
    UI:draw()
    Menu:draw()
end
