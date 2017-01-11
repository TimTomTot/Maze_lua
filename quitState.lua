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
         {"return", "quitGame"}
      }}
   )

   quitUI = hud ("content/keyrusMedium.ttf", 22, quitSignal)

   --надписи на экране
   quitUI:addLable ({name = "mainTile", pos = vector(340, 10)})
   quitUI:addLable ({name = "secondTile", pos = vector(260, 30)})

   --задать обработку нажатия клавиши
   quitSignal:register("quitGame",
      function () love.event.quit() end)
end

function st_quitMenu:enter (previous)
   --отобразить приглашение к выходу из игры
   quitSignal:emit(
      "hud",
      "mainTile",
      "Игра окончена")

   quitSignal:emit(
      "hud",
      "secondTile",
      "- для выхода нажмите Enter -")
end

function st_quitMenu:keypressed (key, isrepeat)
   quitInput:handle(key)
end

function st_quitMenu:draw ()
   quitUI:draw()
end
