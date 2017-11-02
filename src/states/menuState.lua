-- пример переписывания модуля с состоянием начального меню
-- с использованием нового класса меню

local menu     = require "menu"
local signal   = require "hump.signal"
local input    = require "inputhandler"
local hud      = require "view.hud"
local vector   = require "hump.vector"

st_startMenu = {}

-- части состояния
local Signal = signal.new()
local Input = {}
local UI = {}

local Menu = {}

function st_startMenu:init()
    UI = hud("res/content/keyrusMedium.ttf", 22, Signal)
    UI:addLable({name = "title", pos = vector (100, 10)})

    Menu = menu:new({
        x = 100, 
        y = 100,
        font = "res/content/keyrusMedium.ttf", 
        pt = 22
    })
    
    Menu:addItem({
        text = "Играть на случайной карте",
        enterAction = function ()
            -- gamestate.switch(st_gameMain, {map = MP_RND})
            gamestate.switch(st_stub)
        end
    })
    
    Menu:addItem({
        text = "Играть на заданой карте",
        enterAction = function ()
            gamestate.switch(st_gameMain, {map = MP_MANUAL})
        end
    })
    
    Menu:addItem({
        text = "Выход",
        enterAction = function ()
            gamestate.switch(st_quitMenu)
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

function st_startMenu:enter(previous)
    -- просто, вывод сообщения на экран
    Signal:emit(
        "hud",
        "title",
        "Maze  - пройди свой лабиринт"
    )

    -- первый вызов пунктов меню
    Menu:update()
end

function st_startMenu:keypressed(key, isrepeat)
    
end

function st_startMenu:update(dt)
    Input:handle()
    Menu:update()
end

function st_startMenu:draw()
    UI:draw()
    Menu:draw()
end
