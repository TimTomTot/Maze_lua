--[[ 
карта. 
хранит данные о карте уровня, какие ячейки проходимы а какие нет, а так же перечень всех особых объектов 
на карте: дверей, лестниц.
Карта является составной частью модуля world
--]] 


local class = require "30log"
local Grid = require "jumper.grid"


local Map = class("Map")

function Map:init(data)
    if type(data.map) ~= "string" then
        error("Map data is not string", 0)
    end
    
    self.map = Grid(data.map)
    
    self.stearslist = {}
    self.doorlist = {}
end

function Map:getWidht()
    return self.map:getWidth()
end

function Map:getHeight()
    return self.map:getHeight()
end

function Map:__parseCellInMap__(cell)

end

return Map
