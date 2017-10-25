-- floor.lua


local BaseCell = require "world.cell_base"


local Floor = BaseCell:extend("FloorCell")

function Floor:init(data)
    self.ID = data.ID
    self.x = data.x or nil
    self.y = data.y or nil
    self.name = "floor"
    self.tile = "."
    self.walkable = true
    self.transparent = true
    self.explored = false
    self.shaded = true
    
    self.creature = {}
    self.object = {}
    
    self.cancreature = true
    self.canobject = true
end

return Floor

