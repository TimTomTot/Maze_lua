-- wall.lua


local BaseCell = require "world.cell_base"


local Wall = BaseCell:extend("WallCell")

function Wall:init(data)
    self.ID = data.ID
    self.x = data.x or nil
    self.y = data.y or nil
    self.name = "wall"
    self.tile = "#"
    self.walkable = false
    self.transparent = false
    self.explored = false
    self.shaded = true
    
    self.creature = {}
    self.object = {}
    
    self.cancreature = false
    self.canobject = false
end

return Wall

