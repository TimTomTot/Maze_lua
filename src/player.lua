--Игрок

local class    = require "30log"
local vector   = require "hump.vector"
local neig     = require "utils.neighborhood"
local Inventory = require "inventory"

local M = class("Player")

--конструктор
function M:init(data)
    self.ID = data.id
    self.tile = data.tile
    self.world = data.world
    self.signal = data.signalView

    self.inventory = Inventory:new()
    self.maxinventory = data.maxinventory or 12

    --радиус обзора
    self.fovR = data.R
end

--установить игрока на карту мира
function M:setToMap()
    --получить размер карты для дальнейших поисков позиции
    local mapN, mapM = self.world:getMapSize()

    --print ("N ", mapN, " M " , mapM)

    while true do
        local rndPosI, rndPosJ = math.random(mapN), math.random(mapM)

        --на ней просто разместить игрока
        if self.world:isEmpty (rndPosI, rndPosJ) then
            self.world:addCreature(
                {id = self.id, tile = self.tile},
                rndPosI,
                rndPosJ
            )

            --сохранить текущую позицию
            self.pos = vector(rndPosI, rndPosJ)

            --первоначальный расчет поля зрения
            self.world:solveFOV(
                self.pos.x,
                self.pos.y,
                self.fovR
            )

            --установить отображение на игроке
            self.signal:emit("setFramePos", rndPosI, rndPosJ)

            break
        end
    end
    
    self.signal:emit("updateWorld")
end

--перемещение игрока (отностельно текущей позиции)
function M:step(di, dj)
    self.world:moveCreature(
        self,
        self.pos.x + di,
        self.pos.y + dj
    )
end

function M:getPosition()
    return self.pos.x, self.pos.y
end

function M:setPosition(x, y)
    self.pos.x, self.pos.y = x, y
end

function M:getFovR()
    return self.fovR
end

function M:addToInventory(obj)
    self.inventory:addItem(obj)
end

function M:canCatchUp()
    if self.inventory:getLen() >= self.maxinventory then
        self.signal:emit("hud", "message", "В инвентаре больше нет места!")
        return false
    else
        return true
    end
end

function M:getInventory()
    return self.inventory
end

return M
