--сосояние игры с финальной заставкой

local menu     = require "menu"
local signal   = require "hump.signal"
local input    = require "input"
local hud      = require "view.hud"
local vector   = require "hump.vector"

st_quitMenu = {}

--модули, необходимые для работы в этом состоянии
local Signal = signal.new()
local Input = {}
local Ui = {}

local Menu = {}

function st_quitMenu:init ()
   UI = hud ("res/content/keyrusMedium.ttf", 22, Signal)
   UI:addLable({name = "title", pos = vector (100, 10)})

   Menu = menu({UI = UI, signal = Signal})

   Input = Menu.input

   -- задать, какие пункты меню отрисовывать и откуда начинать отрисовку
   local drawPos = vector(100, 100)
   local paragraphs = {
      {label = "Вернуться назад", action = function () gamestate.switch(self.previousState) end},
      {label = "Главное меню", action = function () gamestate.switch(st_startMenu) end},
      {label = "Выход", action = function () love.event.quit() end}
   }

   Menu:addParagraphs(paragraphs, drawPos)
end

function st_quitMenu:enter (previous)
   self.previousState = previous

   -- просто, вывод сообщения на экран
   Signal:emit (
      "hud",
      "title",
      "Закончить игру?")

   -- первый вызов пунктов меню
   Menu:update()
end

function st_quitMenu:keypressed (key, isrepeat)
   Input:handle(key)
end

function st_quitMenu:draw ()
   UI:draw()
end
