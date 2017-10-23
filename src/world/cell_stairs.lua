-- stairs.lua


local BaseCell = require "world.cell_base"


local Stairs = BaseCell:extend("StairsCell")

function Stairs:init(data)
    self.ID = data.ID
    self.x = data.x
    self.y = data.y
    self.name = "stairs"
    self.tile = ">"
    self.walkable = true
    self.transparent = true
    self.explored = false
    self.shaded = true
    
    self.creature = {}
    self.object = {}
    
    self.cancreature = true
    self.canobject = false
end

return Stairs