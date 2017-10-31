-- map layer


local class = require "30log"

local matrix = require "utils.matrix"


local LayerBase = class("LayerBase")

function LayerBase:init(data)
    self.W = data.W
    self.H = data.H
    
    self.layer = matrix:new(self.W, self.H)
    
    self.name = data.name    
    self.avalibleTiles = data.avalibleTiles
    self.defaultTile = data.defaultTile or self.layer.empty
end

function LayerBase:getLayer()
    return {
        name = self.name,
        map = self.layer
    }
end

--[[
    В функцию нужно передать матрицу, в ячейках которой будут тайлы, которые нужно отобразить
--]]
function LayerBase:updateLayer(mapMatrix)
    for i, j, _ in self.layer:iterate() do
        local curtile = nil
    
        if self:__isAvalibleTile__(mapMatrix:get(i,j)) then
            curtile = mapMatrix:get(i,j)
        else
            if mapMatrix:get(i,j) ~= mapMatrix.empty then
                curtile = self.defaultTile
            else
                curtile = mapMatrix.empty
            end
        end
        
        self.layer:set(i, j, curtile)
    end
end

function LayerBase:__isAvalibleTile__(tile)
    for _, avalibleTile in ipairs(self.avalibleTiles) do
        if tile == avalibleTile then
            return true
        end
    end
    
    return false
end

return LayerBase

 