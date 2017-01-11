--проверка работы игровых состояний
require "menuState"
require "quitState"

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
