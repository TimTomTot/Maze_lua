-- Фабрика по созданию слоев для отображения на экране


local class = require "30log"
local Layer = require "view.layer_base"


local Factory = class("LayerFactory")

function Factory:init(data)
    self.W = data.W
    self.H = data.H
end

function Factory:generateLayer(name)
    local initdata = nil
    
    if name == "map" then        
        initdata = {
            name = "map",
            W = self.W,
            H = self.H,
            avalibleTiles = {
                ".",
                "#",
                "-",
                "+",
                ">"
            },
            defaultTile = "."
        }
    elseif name == "items" then
        initdata = {
            name = "items",
            W = self.W,
            H = self.H,
            avalibleTiles = {
                "|"
            }
        }
    elseif name == "creatures" then
        initdata = {
            name = "creatures",
            W = self.W,
            H = self.H,
            avalibleTiles = {
                "@"
            }
        }
    elseif name == "shadow" then
        initdata = {
            name = "shadow",
            W = self.W,
            H = self.H,
            avalibleTiles = {
                "*"
            }
        }
    else
        error("Unknown layer name " .. name .. "!!", 0)
    end
    
    local newlayer = Layer:new(initdata)
    
    return newlayer
end

return Factory

