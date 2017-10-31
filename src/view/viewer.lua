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
                    j * self.size - self.sizeZ
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

--ограничение для фрейма
function View:checkFrame ()
    --ограничения
    if self.framePos.x < 0 then
        self.framePos.x = 0
    end

    if self.framePos.y < 0 then
        self.framePos.y = 0
    end

    if self.framePos.x > self.MaxMap.x - self.frame:getWidht() then
        self.framePos.x = self.MaxMap.x - self.frame:getWidht()
    end

    if self.framePos.y > self.MaxMap.y - self.frame:getHeight() then
        self.framePos.y = self.MaxMap.y - self.frame:getHeight()
    end
end

--сдвиг фрейма отображения относительно текущей позиции
function View:moveFrame (di, dj)
    self.framePos.x = self.framePos.x + di
    self.framePos.y = self.framePos.y + dj

    --проверить ограничение
    self:checkFrame ()
end

--установка фрейма на определенное место карты (с точкой в середине)
function View:setFramePos (i, j)
    self.framePos.x = i - math.ceil(self.frame:getWidht() / 2)
    self.framePos.y = j - math.ceil(self.frame:getHeight() / 2)
    
    -- проверить ограничение
    self:checkFrame ()

    --теперь нужно обновить данные о слоях отображения, чтобы реже обращаться
    --к объекту карты - только при перемещении игрока, а не каждый тик
    self:updateViewer ()
end

--функция обновления данных о том, что нужно отображать на разных уровнях
function View:updateViewer ()
    --пройтись по всему фрейму и для каждой точки получить объект Cell
    --из карты. разобрать, что получилось из этого объекта и соответственно,
    --заполнить слои для отображения.
    for i, j, _ in self.frame:iterate () do
        local curCell = self.world:getCell (
            i + self.framePos.x,
            j + self.framePos.y)

        --напишем, что отобразилось
        --print(curCell["visited"].tile)

        --print (unpack (curCell))
        if not next(curCell) then
            error ("curCell = nil")
        end

        --если данная ячейка уже была видима, то определяются данные для
        --отображения
        if curCell["visited"].tile then
            for _, val in ipairs(self.frameLayers) do
                --для каждого уровня занести, что имеем
                --print (val.name)
                if curCell[val.name].tile then
                    val.data:set (i, j, curCell[val.name].tile)
                else
                    val.data:set (i, j, nil)
                end

                --отобразить, что получилось для слоя с затемнением
                --val.data:Write ()
            end
        else
            --если данная точка еще не была разведана
            for _, val in ipairs(self.frameLayers) do
                val.data:set (i, j, nil)
            end
        end
    end

    --отобразить, что получилось для слоя с затемнением

end --updateViewer

return View
