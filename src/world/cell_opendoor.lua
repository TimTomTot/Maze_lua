-- opendoor.lua


local BaseCell = require "world.cell_base"


local OpenDoor = BaseCell:extend("OpenDoorCell")

function OpenDoor:init(data)
    self.ID = data.ID
    self.x = data.x
    self.y = data.y
    self.name = "opendoor"
    self.tile = "-"
    self.walkable = true
    self.transparent = true
    self.explored = false
    self.shaded = true
    
    self.creature = {}
    self.object = {}
    
    self.cancreature = true
    self.canobject = false
end

return OpenDoor