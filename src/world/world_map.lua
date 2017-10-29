--[[ 
карта. 
хранит данные о карте уровня, какие ячейки проходимы а какие нет, а так же перечень всех особых объектов 
на карте: дверей, лестниц.
Карта является составной частью модуля world
--]] 


local class = require "30log"
local Grid = require "jumper.grid"

local CellFactory = require "world.cellfactory"


local Map = class("Map")

function Map:init(data)
    if type(data.map) ~= "string" then
        error("Map data is not string", 0)
    end
    
    self.map = Grid(data.map)
    self.strmap = data.map
    
    self.stairslist = {}
    self.doorlist = {}

    self.cellfactory = CellFactory:new()

    self:__parseStrMap__(self.strmap)
end

--[[
    Переданная карта парсится и на основе того, что в ней занесено,
    создается карта в коечном массиве Grid
--]]
function Map:__parseStrMap__(strmap)
    local rowIndex, columnIndex = 1, 1

    for row in strmap:gmatch ("[^\n]+") do
        columnIndex = 1

        for character in row:gmatch (".") do
            local newcell = self.cellfactory:generateCell(character)

            local node = self.map:getNodeAt(columnIndex, rowIndex)

            node.data = newcell

            if newcell.name == "stairs" then
                table.insert(self.stairslist, newcell)
            end

            if newcell.name == "closedoor" or newcell.name == "opendoor" then
                table.insert(self.doorlist, newcell)
            end

            columnIndex = columnIndex + 1
        end
        rowIndex = rowIndex + 1
    end
end


function Map:getWidht()
    return self.map:getWidth()
end

function Map:getHeight()
    return self.map:getHeight()
end

function Map:getStairsList()
    return self.stairslist
end

function Map:getDoorList()
    return self.doorlist
end

return Map
