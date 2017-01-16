--проверка работы игровых состояний
require "const"

require "states.menuState"
require "states.quitState"
require "states.gameplayState"

gamestate = require "hump.gamestate"

function love.load ()
   gamestate.registerEvents()
   gamestate.switch(st_startMenu)
end

function love.update (dt)
   -- body...
end

function love.draw ()
   -- body...
end
