---
-- Модуль содержит функции по работе с миром игры.
-- Представлят из себя класс 30log
-- @module World

local class          = require "30log"
local matrix         = require "utils.matrix"
local brez           = require "utils.brez"
local cellfactory    = require "world.cellfactory"
local itemfactory    = require "items.itemsfactory"
local vector   = require "hump.vector"

local M = class("World")

---
-- Конструктор.
-- @param data таблица с входными параметрами:
-- @param data.W размер мира по горизонтали
-- @param data.H размер мира по вертикали
-- @param data.signal объект, реализующий паттерн Наблюдтель
function M:init(data)
    --инициализация карты уровня
    self.lavel = {}

    --фабрика для генерации ячеек карты
    self.factory = cellfactory ()

    --фабрика для генерации предметов на карте
    self.items = itemfactory:new()

    -- все, связанное с фреймом отображения
    self.frameWidth = data.W
    self.frameHeight = data.H
    
    self.frame = matrix:new(self.frameWidth, self.frameHeight)
    self.shadowframe = matrix:new(self.frameWidth, self.frameHeight)
    self.creatureframe = matrix:new(self.frameWidth, self.frameHeight)
    
    self.framePos = vector(0, 0)
    
    self.signal = data.signal

    -- список всех лестниц на карте
    self.stairslist = {}
end

---
-- Создание карты мира из входной строки.
-- Входная строка разбирается в соответствии с тем, данные о каких тайлах занесены в 
-- объект cellfactory. Если переданная строка не является прямоугольной, метод вызывает ошибку
-- полученная карта сохраняется во внутреннем поле объекта World
-- @param str входная строка, содержащая карту игрового мира
function M:parseMap(str)
    --получить размеры карты из строки
    local N = #(str:match("[^\n]+"))
    local M = math.floor(#str / #(str:match("[^\n]+")))
   
    --задать размеры для карты уровня
    self.lavel = matrix:new(N, M)

    --пройтись по всей входной строке и
    --исходя из того, какие точки в ней находятся,
    --создать соответствующие ячейки на карте уровня
    local rowIndex, columnIndex = 1, 1

    for row in str:gmatch("[^\n]+") do
        columnIndex = 1

        for character in row:gmatch(".") do
            --создать ячейку
            local tile = self.factory:generateCell(character)

            if tile == nil then
                error("tile on " .. tostring(columnIndex) .. " " .. tostring(rowIndex) .. " is nil!!!", 0)
            end
         
            self.lavel:set(
                columnIndex,
                rowIndex,
                tile
            )
            
            tile:setPosition(columnIndex, rowIndex)

            -- если в точке есть не только элементы карты
            local newItem = self.items:newitem(character)
            
            if newItem and not tile:isObject() then
                tile:setObject(newItem)
            end

            self:tryAddStairs(tile)

            columnIndex = columnIndex + 1
        end
        rowIndex = rowIndex + 1
    end
end

---
-- Получение даннх о размере карты
-- @return размер по горизонтали, размер по вертикали 
function M:getMapSize ()
    return self.lavel:getWidht(), self.lavel:getHeight()
end

---
-- Проверка, является ли место по задынным координатам свободным.
-- Другими словами, может ли на нем размещаться игровой агент
-- @param i - х координата 
-- @param j - у координата
-- @return true если позиция свободна, false если занята
function M:isEmpty(i, j)
    local curcell = self.lavel:get(i,j)
    
    return curcell:canCreature()
end


---
-- Установка существа на карту
-- @param cre существо
-- @param i - х координата
-- @param j - у координата
function M:addCreature(cre, i, j)
    local curcell = self.lavel:get(i, j)
    
    curcell:setCreature({
        id = cre.id,
        tile = cre.tile
    })
   
    self:setFramePos(i, j)
end

--сдвиг существа по указаным координатам
function M:moveCreature(creature, inew, jnew)
    local creX, creY = creature:getPosition()
    
    local curcell = self.lavel:get(creX, creY)
    local newcell = self.lavel:get(inew, jnew)
    
    if newcell:isWalkable() then
        if newcell:canCreature() then
            self:creatureStep(creature, inew, jnew)
            self:publishTileMessage(inew, jnew)
        else
            if newcell:isType("door") then
                local x, y = newcell:getPosition()

                self:openDoor(x, y)

                self:creatureStep(creature, x, y)
            end
        end
    else
        self.signal:emit("hud", "message", "Здесь не пройти!")
    end
end

-- переставить существо на новую точку
-- TODO переименовать и произвести рефакторинг
function M:creatureStep(creature, toX, toY)
    local fromcell = self.lavel:get(creature:getPosition())

    assert(creature ~= nil)

    creature:setPosition(toX, toY)
    local newcell = self.lavel:get(toX, toY)
    newcell:setCreature(fromcell:removeCreature())

    self:solveFOV(toX, toY, creature:getFovR())

    self.signal:emit("setFramePos", toX, toY)
    self.signal:emit("updateWorld")
end

--расчет поля видимости
function M:solveFOV(i, j, R)
    --предварительно обновить карту теней
    self:fillShadow ()

    --убрать тень в точке с игроком
    self.lavel:get(i, j):illuminate()
    self.lavel:get(i, j):explore()

    ---[[
    --создать список точек, до которых необходимо проложить видимость
    local viewPointList = {}

    --функция для добавления точек в список
    local addToList = function (x, y)
        table.insert(viewPointList, {x, y})
    end

    --расчитать из текущей позиции круг радиусом как поле видимости
    --все найденные точки при этом занести в список
    brez:Circle (addToList, i, j, R)

    local addVisible = {}

    addVisible.empty = true

    --функция, добавляющая точку на карте в разряд видимых
    addVisible.funct = function (x, y)
        if addVisible.empty then
            self.lavel:get(x, y):illuminate() 
            self.lavel:get(x, y):explore() 
        end

        --проверка на выход за границы
        if self.lavel:isInRange(x, y) then
            if not self.lavel:get(x, y):isTransparent() then
                addVisible.empty = false
            end
        end
    end

    --для каждой точки из списка проложить в нее линию обзора
    for _, val in ipairs(viewPointList) do
        addVisible.empty = true

        brez:Line (addVisible.funct, i, j, val[1], val[2])
    end
    --]]
end --solveFOV

--вспомогательная функция, обновляющая карту видимости
function M:fillShadow()
    --просто залить всю карту тенями
    for i, j, val in self.lavel:iterate () do
        val:obscure()
    end
end

--ограничение для фрейма
function M:checkFrame()
    --ограничения
    if self.framePos.x < 0 then
        self.framePos.x = 0
    end

    if self.framePos.y < 0 then
        self.framePos.y = 0
    end

    if self.framePos.x > self.lavel:getWidht() - self.frame:getWidht() then
        self.framePos.x = self.lavel:getWidht() - self.frame:getWidht()
    end

    if self.framePos.y > self.lavel:getHeight() - self.frame:getHeight() then
        self.framePos.y = self.lavel:getHeight() - self.frame:getHeight()
    end
end

--сдвиг фрейма отображения относительно текущей позиции
function M:moveFrame(di, dj)
    self.framePos.x = self.framePos.x + di
    self.framePos.y = self.framePos.y + dj

    --проверить ограничение
    self:checkFrame()
end

--установка фрейма на определенное место карты (с точкой в середине)
function M:setFramePos(i, j)
    self.framePos.x = i - math.ceil(self.frame:getWidht() / 2)
    self.framePos.y = j - math.ceil(self.frame:getHeight() / 2)
    
    -- проверить ограничение
    self:checkFrame()
end

function M:getFrameView()
    for i, j, val in self.frame:iterate() do
        local curtile = self.lavel:get(
            i + self.framePos.x,
            j + self.framePos.y
        )           
            
        if curtile:isExplored() then
            self.frame:set(i, j, curtile.tile)
            
            if curtile:isObject() then
                local obj = curtile:getObject()
                self.frame:set(i, j, obj.tile)
            end
        else
            self.frame:set(i, j, self.frame.empty)
        end
    end
    
    return self.frame
end

function M:getCreatureViev()
    for i, j, val in self.creatureframe:iterate() do
        local curtile = self.lavel:get(
            i + self.framePos.x,
            j + self.framePos.y
        )           
        
        if curtile:isExplored() and curtile:isCreature() then
            local crea = curtile:getCreature()
            self.creatureframe:set(i, j, crea.tile)
        else
            self.creatureframe:set(i, j, self.shadowframe.empty)
        end
    end
    
    return self.creatureframe
end

function M:getShadowView()
    for i, j, val in self.shadowframe:iterate() do
        local curtile = self.lavel:get(
            i + self.framePos.x,
            j + self.framePos.y
        )
        
        if curtile:isExplored() and curtile:isShaded() then
            self.shadowframe:set(i, j, "*")
        else
            self.shadowframe:set(i, j, self.shadowframe.empty)
        end
    end
    
    return self.shadowframe
end

-- добавление лестниц из карты
function M:tryAddStairs(tile)
    if tile:isType("stairs") then
        table.insert(self.stairslist, tile)
    end
end

function M:checkStairs(posx, poxy)
    local curcell = self.lavel:get(posx, poxy)

    return curcell:isType("stairs")
end

function M:publishTileMessage(posx, posy)
    local curcell = self.lavel:get(posx, posy)
    
    local msg = curcell:getMsg()
    
    if msg then
        self.signal:emit("hud", "message", msg)
    else
        if curcell:isObject() then
            self.signal:emit("hud", "message", curcell:getObject():getMsg())
        end
    end
end

function M:catchUp(cre)
    local posx, posy = cre:getPosition()
    local curcell = self.lavel:get(posx, posy)
    
    if curcell:isObject() then
        if cre:canCatchUp() then
            local object = curcell:removeObject()
        
            assert(cre.tile == "@")
            assert(object)
        
        
            cre:addToInventory(object)
        

            self.signal:emit("hud", "message", object.catchUpMessage)
        end

        return true
    end
    
    return false
end

function M:dropItem(item, posx, posy)
    local xshift = {0, 1, -1, 0,  0, -1,  1, -1, 1}
    local yshift = {0, 0,  0, 1, -1, -1, -1,  1, 1}
    
    local iter = 1

    while true do
        local curcell = self.lavel:get(posx + xshift[iter], posy + yshift[iter])

        if curcell:canObject() then
            curcell:setObject(item)

            return true
        end 

        iter = iter + 1

        if iter > #xshift then
            return false
        end
    end
end

-- пока ограничение на то, что по соседству может быть только 1 дверь
-- TODO если больше 1 двери - сделать выбор, какую дверь открывать
function M:checkNeighborDoors(posx, posy, celltype)
    local xshift = {1, -1, 0,  0}
    local yshift = {0,  0, 1, -1}

    local iter = 1

    while true do
        local curcell = self.lavel:get(posx + xshift[iter], posy + yshift[iter])

        if curcell:isType("door") and curcell:getName() == celltype then
            return true, posx + xshift[iter], posy + yshift[iter]  
        end        

        iter = iter + 1

        if iter > #xshift  then
            return false
        end
    end
end

function M:openDoor(posx, posy)
    self.lavel:set(
        posx,
        posy,
        self.factory:generateCell("opendoor")
    )

    local curcell = self.lavel:get(posx, posy)
    curcell:setPosition(posx, posy)

    self.signal:emit("hud", "message", "Ты открываешь дверь")
end

function M:closeDoor(posx, posy)
    self.lavel:set(
        posx,
        posy,
        self.factory:generateCell("closedoor")
    )

    local curcell = self.lavel:get(posx, posy)
    curcell:setPosition(posx, posy)

    self.signal:emit("hud", "message", "Ты закрываешь дверь")
end

return M
