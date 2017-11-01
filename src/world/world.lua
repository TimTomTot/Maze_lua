--еще один вариант модуля world, без лифней сложности

local class          = require "30log"
local matrix         = require "utils.matrix"
local brez           = require "utils.brez"
local cellfactory    = require "world.cellfactory"
local itemfactory    = require "items.itemsfactory"
local vector   = require "hump.vector"

local M = class("World")

--конструктор
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
end

--функция парсинга карты мира из строкаи
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
            local tile, item = self.factory:newCell(character, {darkened = true})

            if tile == nil then
                error("tile on " .. tostring(columnIndex) .. " " .. tostring(rowIndex) .. " is nil!!!", 0)
            end
         
            self.lavel:set(
                columnIndex,
                rowIndex,
                tile
            )

            -- если в точке есть не только элементы карты
            if item then
                -- устанавливаем на это место нужный объект
                local newItem = self.items:newitem(character)

                self.lavel:get(columnIndex, rowIndex).object = newItem
            end

            columnIndex = columnIndex + 1
        end
        rowIndex = rowIndex + 1
    end
end

--добавление карты уровня
function M:addMap(inputMap)
    --подгоняем размер уровня под размер переданой карты
    self.lavel = matrix:new(inputMap.N, inputMap.M)

    --переносим данные
    for i, j, _ in self.lavel:iterate () do
        --структура данных для каждой ячейки
        local cellData = {
            --слой с картой
            map = {
                val = inputMap:Get(i, j),
                tile = inputMap:getTile (i, j)
            },

            --слой с игровыми объектами
            odjects = {present = false},

            --слой с игровыми персонажами
            creatures = {},

            --слой с затемнением
            --в начале всегда затемнено
            visible = "shadow",

            --слой со свединиями о посещении
            --в начале все точки считаются не посещенными
            visited = false
        }
        self.lavel:set (i, j, cellData)
    end
end

--проверка, свободна ли данная ячейка
function M:isEmpty(i, j)
    --сначала задаем предположение, что свободна
    local rez = true

    --если она непроходима или в ней существо
    --то счиаем ее занятой
    local curCell = self.lavel:get(i, j)

    if curCell.flag[LV_SOLID] or curCell:isCreature() then
        rez = false
    end

    return rez
end


--добавление существа на карту
function M:addCreature(cre, i, j)
    self.lavel:get(i, j).creature = {
        id = cre.id,
        tile = cre.tile
    }
   
    self:setFramePos(i, j)
end

--сдвиг существа по указаным координатам
function M:moveCreature(iold, jold, inew, jnew)
    local creatureData = self.lavel:get(iold, jold).creature

    --установить данные для новой точки
    self.lavel:get(inew, jnew).creature = {
        id = creatureData.id,
        tile = creatureData.tile
    }

    --обнулить старую точку
    self.lavel:get(iold, jold).creature = {}
end

--получить данные о размере карты
function M:getMapSize ()
    return self.lavel:getWidht(), self.lavel:getHeight()
end

--расчет поля видимости
function M:solveFOV(i, j, R)
    --предварительно обновить карту теней
    self:fillShadow ()

    --убрать тень в точке с игроком
    self.lavel:get(i, j).flag[LV_DARKENED] = false
    self.lavel:get(i, j).flag[LV_EXPLORED] = true

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
            self.lavel:get(x, y).flag[LV_DARKENED] = false
            self.lavel:get(x, y).flag[LV_EXPLORED] = true
        end

        --проверка на выход за границы
        if self.lavel:isInRange(x, y) then
            if self.lavel:get(x, y).flag[LV_OPAQUE] then
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
        val.flag[LV_DARKENED] = true
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
            
        if curtile.flag[LV_EXPLORED] then
            self.frame:set(i, j, curtile.tile)
            
            if curtile:isObject() then
                self.frame:set(i, j, curtile.object.tile)
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
        
        if curtile.flag[LV_EXPLORED] and curtile:isCreature() then
            self.creatureframe:set(i, j, curtile.creature.tile)
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
        
        if curtile.flag[LV_EXPLORED] and curtile.flag[LV_DARKENED] then
            self.shadowframe:set(i, j, "*")
        else
            self.shadowframe:set(i, j, self.shadowframe.empty)
        end
    end
    
    return self.shadowframe
end

return M
