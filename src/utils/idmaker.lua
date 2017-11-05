-- idmaker.lua


local class = require "30log"


local ID = 1


local Maker = class("IDMaker")

function Maker:init()

end

function Maker:getID()
    local resID = ID
    
    ID = ID + 1
    
    return resID
end



return Maker