-- модуль с фабрикой для генерации объектов с ячейками карты
-- на основе данных из распарсенной карты-строки

local class = require "30log"

local Cell = require "world.cell_base"
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
    local initdata = {}
    
    if name == "wall" or name == "#" then
        initdata = {
            ID = newid,
            name = "wall",
            tile = "#",
            tiletype = "wall",
            walkable = false,
            transparent = false,
            explored = false,
            shaded = true,
            cancreature = false,
            canobject = false
        }
    elseif name == "floor" or name == "." then
        initdata = {
            ID = newid,
            name = "floor",
            tile = ".",
            tiletype = "floor",
            walkable = true,
            transparent = true,
            explored = false,
            shaded = true,
            cancreature = true,
            canobject = true
        }
    elseif name == "closedoor" or name == "+" then
        initdata = {
            ID = newid,
            name = "closedoor",
            tile = "+",
            tiletype = "door",
            walkable = true,
            transparent = false,
            explored = false,
            shaded = true,
            cancreature = false,
            canobject = false
        }
    elseif name == "opendoor" or name == "-" then
        initdata = {
            ID = newid,
            name = "opendoor",
            tile = "-",
            tiletype = "door",
            standmsg = "Здесь открытая дверь",
            walkable = true,
            transparent = true,
            explored = false,
            shaded = true,
            cancreature = true,
            canobject = false
        }
    elseif name == "stairs" or name == ">" then
        initdata = {
            ID = newid,
            name = "stairs",
            tile = ">",
            tiletype = "stairs",
            standmsg = "Здесь лестница на соседний этаж",
            walkable = true,
            transparent = true,
            explored = false,
            shaded = true,
            cancreature = true,
            canobject = false
        }
    else
        initdata = {
            ID = newid,
            name = "floor",
            tile = ".",
            walkable = true,
            transparent = true,
            explored = false,
            shaded = true,
            cancreature = true,
            canobject = true
        }
    end
    
    newcell = Cell:new(initdata)
    
    return newcell
end

return CellFactory