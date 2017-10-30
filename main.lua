
package.path = package.path .. ";lib/?/init.lua;lib/?.lua;src/?.lua"


require "const"

require "states.menuState"
require "states.quitState"
require "states.gameplayState"

gamestate = require "hump.gamestate"


function love.load()
   	gamestate.registerEvents()
   	gamestate.switch(st_startMenu)
end

function love.update(dt)
   	if dt < 1 / 60 then
   		love.timer.sleep(1 / 60 - dt)
   	end
end

function love.draw()
   	-- body...
end
