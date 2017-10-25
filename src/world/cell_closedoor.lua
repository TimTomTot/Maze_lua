-- closedoor.lua


local BaseCell = require "world.cell_base"


local CloseDoor = BaseCell:extend("CloseDoorCell")

function CloseDoor:init(data)
    self.ID = data.ID
    self.x = data.x or nil
    self.y = data.y or nil 
    self.name = "closedoor"
    self.tile = "+"
    self.walkable = false
    self.transparent = false
    self.explored = false
    self.shaded = true
    
    self.creature = {}
    self.object = {}
    
    self.cancreature = false
    self.canobject = false
end

return CloseDoor

