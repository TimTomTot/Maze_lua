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

    ---[[
    --регистрация действия с перемещением на лестнице
    self.signal:register(
        "downSteer",
        function ()
            --для точки, на которой стоит игрок вызывается функция action
            local rez = self.world.lavel:get(self.pos.x, self.pos.y).action(self, AC_DOWNSTAIRS)

            --если action не задан, то выдается сообщение о том, что лестницы нет
            if not rez then
                self.signal:emit(
                    "hud",
                    "message",
                    "Здесь нет лестницы!"
                )
            end
        end
    )
    --]]

    -- действие поднятия предмета с пола
    self.signal:register(
        "catchUp",
        function ()
            local curcell = self.world.lavel:get(self.pos.x, self.pos.y)
            local rez = self.world.lavel:get(self.pos.x, self.pos.y).action(self, AC_PICKUP, curcell)

            if not rez then
                self.signal:emit(
                    "hud",
                    "message",
                    "Здесь нечего поднимать!"
                )
            end
        end
    )

    --регистрация действия с открытием двери
    self.signal:register(
        "openDoor",
        function ()
            --функция по очереди вызывается для всех точек, соседних с позицией
            --игрока
            local rez

            for i = 1, 4 do
                local di, dj = neig:GetDir(i)

                local curCell = self.world.lavel:get(
                    self.pos.x + di,
                    self.pos.y + dj
                )

                rez = curCell.action(
                    self,
                    AC_OPENDOOR,
                    curCell
                )

                if rez then
                    self.world:solveFOV(
                        self.pos.x,
                        self.pos.y,
                        self.fovR
                    )

                    self.signal:emit("setFramePos", self.pos.x, self.pos.y)
                    self.signal:emit("updateWorld")
                    
                    break
                end
            end

            if not rez then
                self.signal:emit(
                    "hud",
                    "message",
                    "Вокруг нет дверей, которые можно открыть!"
                )
            end
        end
    )

      --регистрация действия с закрытием двери
    self.signal:register(
        "closeDoor",
        function ()
            --функция по очереди вызывается для всех точек, соседних с позицией
            --игрока
            local rez

            for i = 1, 4 do
                local di, dj = neig:GetDir(i)

                local curCell = self.world.lavel:get(self.pos.x + di, self.pos.y + dj)

                rez = curCell.action(
                    self,
                    AC_CLOSEDOOR,
                    curCell
                )

                if rez then
                    self.world:solveFOV(
                        self.pos.x,
                        self.pos.y,
                        self.fovR
                    )

                    self.signal:emit("setFramePos", self.pos.x, self.pos.y)
                    self.signal:emit("updateWorld")
                    
                    break
                end
            end

            if not rez then
                self.signal:emit(
                    "hud",
                    "message",
                    "Вокруг нет дверей, которые можно закрыть!"
                )                
            end
        end
    )
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

            ---[[
            --первоначальный расчет поля зрения
            self.world:solveFOV(
                self.pos.x,
                self.pos.y,
                self.fovR
            )
            --]]

            --установить отображение на игроке
            self.signal:emit("setFramePos", rndPosI, rndPosJ)

            break
        end
    end
    
    self.signal:emit("updateWorld")
end

--перемещение игрока (отностельно текущей позиции)
function M:step(di, dj)
    --проверить, свободна ли эта позиция на карте
    if self.world:isEmpty(self.pos.x + di, self.pos.y + dj) then
        --если свободна, то переместить в нее игрока
        self.world:moveCreature(
            self.pos.x,
            self.pos.y,
            self.pos.x + di,
            self.pos.y + dj
        )

        self.pos = self.pos + vector(di, dj)

        --выполнить функцию, предусмотренную картой для этой точки
        -- local curCell = self.world.lavel:get(self.pos.x, self.pos.y)

        -- curCell.stand(self, curCell)
      
        --[[
        if curCell:isObject() then
            curCell.object:stand(self)
        end
        --]]

        ---[[
        --расчитать поле зрения
        self.world:solveFOV(
            self.pos.x,
            self.pos.y,
            self.fovR
        )
        --]]
        
        --и оповестить об этом объект отображения
        self.signal:emit("setFramePos", self.pos.x, self.pos.y)
        self.signal:emit("updateWorld")
    else
        --сообщение о том, что дальше продвинуться невозможно
        self.signal:emit("hud", "message", "Здесь не пройти!")
    end
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

function M:dropItem(itemid)
    local xshift = {0, 1, -1, 0,  0}
    local yshift = {0, 0,  0, 1, -1}

    local iter = 1

    while true do
        local curcell = self.world.lavel:get(self.pos.x + xshift[iter], self.pos.y + yshift[iter])

        if curcell.name == "floor" and not curcell:isObject() then
            local item = self.inventory:removeItem(itemid)

            self.world.lavel:get(self.pos.x + xshift[iter], self.pos.y + yshift[iter]).object = item

            return true
        end 

        iter = iter + 1

        if iter > #xshift then
            return false
        end
    end
end

function M:getInventory()
    return self.inventory
end

return M
