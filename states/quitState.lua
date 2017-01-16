--сосояние игры с финальной заставкой

local signal   = require "hump.signal"
local input    = require "input"
local hud      = require "view.hud"
local vector   = require "hump.vector"

st_quitMenu = {}

--модули, необходимые для работы в этом состоянии
local quitSignal = signal.new()
local quitInput = {}
local qoitUi = {}

function st_quitMenu:init ()
   quitInput = input(
      {signal = quitSignal,
      kayConform = {
         {"return", "quitGame"},
         {"escape", "returnState"}
      }}
   )

   quitUI = hud ("content/keyrusMedium.ttf", 22, quitSignal)

   --надписи на экране
   quitUI:addLable ({name = "mainTile", pos = vector(100, 10)})
   quitUI:addLable ({name = "2Tile", pos = vector(100, 130)})
   quitUI:addLable ({name = "3Tile", pos = vector(100, 150)})

   --задать обработку нажатия клавиши
   quitSignal:register("quitGame",
      function () love.event.quit() end)

   quitSignal:register("returnState",
      function () gamestate.switch(self.previousState) end)
end

function st_quitMenu:enter (previous)
   self.previousState = previous

   --отобразить приглашение к выходу из игры
   quitSignal:emit(
      "hud",
      "mainTile",
      "Выйти из игры?")

   quitSignal:emit(
      "hud",
      "2Tile",
      "- для выхода нажмите Enter -")

   quitSignal:emit(
      "hud",
      "3Tile",
      "- чтобы вернуться нажмите Esc -")
end

function st_quitMenu:keypressed (key, isrepeat)
   quitInput:handle(key)
end

function st_quitMenu:draw ()
   quitUI:draw()
end
