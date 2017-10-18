-- пример переписывания модуля с состоянием начального меню
-- с использованием нового класса меню

local menu     = require "menu"
local signal   = require "hump.signal"
local input    = require "input"
local hud      = require "view.hud"
local vector   = require "hump.vector"

st_startMenu = {}

-- части состояния
local Signal = signal.new ()
local Input = {}
local UI = {}

local Menu = {}

function st_startMenu:init()
    UI = hud ("res/content/keyrusMedium.ttf", 22, Signal)
    UI:addLable({name = "title", pos = vector (100, 10)})

    Menu = menu({UI = UI, signal = Signal})

    Input = Menu.input

    -- задать, какие пункты меню отрисовывать и откуда начинать отрисовку
    local drawPos = vector(100, 100)
    local paragraphs = {
        {label = "Играть на случайной карте", action = function () gamestate.switch(st_gameMain, {map = MP_RND}) end},
        {label = "Играть на заданой карте", action = function () gamestate.switch(st_gameMain, {map = MP_MANUAL}) end},
        {label = "Выход", action = function () gamestate.switch(st_quitMenu) end}
    }

    Menu:addParagraphs(paragraphs, drawPos)
end

function st_startMenu:enter(previous)
    -- просто, вывод сообщения на экран
   Signal:emit (
      "hud",
      "title",
      "Maze  - пройди свой лабиринт")

   -- первый вызов пунктов меню
   Menu:update()
end

function st_startMenu:keypressed(key, isrepeat)
    Input:handle(key)
end

function st_startMenu:draw()
    UI:draw()
end
