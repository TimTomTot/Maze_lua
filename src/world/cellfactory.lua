-- модуль с фабрикой для генерации объектов с ячейками карты
-- на основе данных из распарсенной карты-строки

local class = require "30log"

local Wall = require "world.cell_wall"
local Floor = require "world.cell_floor"
local CloseDoor = require "world.cell_closedoor"
local OpenDoor = require "world.cell_opendoor"
local Stairs = require "world.cell_stairs"

local IDMaker = require "utils.idmaker"


local CellFactory = class("CellFactory")

-- конструктор
function CellFactory:init(data)
    self.idmaker = IDMaker:new()
end

-- генерация новой ячейки по имени или по тайлу
-- если имя(тайл) нельзя распознать, то генерируется ячейка пола
function CellFactory:generateCell(name)
    local newid = self.idmaker:getID()
    
    local newcell = nil
    
    if name == "wall" or name == "#" then
        newcell = Wall:new({ID = newid})
    elseif name == "floor" or name == "." then
        newcell = Floor:new({ID = newid})
    elseif name == "closedoor" or name == "+" then
        newcell = CloseDoor:new({ID = newid})
    elseif name == "opendoor" or name == "-" then
        newcell = OpenDoor:new({ID = newid})
    elseif name == "stairs" or name == ">" then
        newcell = Stairs:new({ID = newid})
    else
        newcell = Wall:new({ID = newid})
    end
    
    return newcell
end

return CellFactory
