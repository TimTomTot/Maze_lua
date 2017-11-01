-- модуль отображения, viewer

local class    = require "30log"
local vector   = require "hump.vector"
local layer    = require "view.layer"
local cell     = require "world.cell"
local matrix   = require "utils.matrix"


--[[
    В конечном итоге, какие должны быть слои и в какой последовательности:
    - карта
    - предметы
    - существа
    - тень
--]]


local View = class("View")

--конструктор
function View:init(data)
    self.tileset = love.graphics.newImage(data.file)
    
    if not self.tileset then
        error("No image file!", 0)
    end
    
    self.tilesetW = self.tileset:getWidth()
    self.tilesetH = self.tileset:getHeight()    
    
    self.size = data.tilesize or 32
    self.mapW = data.mapW
    self.mapH = data.mapH
    
    self.tiles = {}
    
    self:__prepareTileMap__()
    
    self.layer = {}
end 

function View:addLayer(data)
    local layer = {
        name = data.name,
        map = data.map
    }
    
    if data.num then
        self.layer[data.num] = layer
    else
        table.insert(self.layer,layer)
    end
end

--отображение на экран
function View:draw ()
    for _, val in ipairs(self.layer) do
        for i, j, v in val.map:iterate() do
            if v ~= val.map.empty and self.tiles[v] then
                love.graphics.draw(
                    self.tileset,
                    self.tiles[v],
                    i * self.size - self.size,
                    j * self.size - self.size
                )   
            end    
        end
    end 
end

function View:__addTile__(name, x, y)
    self.tiles[name] = love.graphics.newQuad(
        x * self.size - self.size,
        y * self.size - self.size,
        self.size,
        self.size,
        self.tilesetW,
        self.tilesetH
    )
end

function View:__prepareTileMap__()
    self:__addTile__("@", 1, 1)

    self:__addTile__(".", 1, 4)
    self:__addTile__("-", 2, 4)
    self:__addTile__("+", 3, 4)
    self:__addTile__(">", 4, 4)
    self:__addTile__("#", 5, 4)

    self:__addTile__("|", 1, 3)

    self:__addTile__("*", 1, 10)
end

return View
