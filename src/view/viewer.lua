-- модуль отображения, viewer

local class    = require "30log"
local vector   = require "hump.vector"
local layer    = require "view.layer"
local cell     = require "world.cell"
local matrix   = require "utils.matrix"


local View = class("View")

--конструктор
function View:init(signal)
    --карта, к которой привязано отображение
    self.world = nil

    --запомнить максимальные размеры карты
    --(после того, как будет задан новый объект отображения)
    self.MaxMap = nil

    --обработчик сигналов для отображения
    self.signal = signal

    --регистрация изменения позиции фрейма (абсолютного)
    self.signal:register ("setFramePos",
        function (i, j) self:setFramePos (i, j) end)

    --регистрация изменения позиции фрейма (относительного)
    self.signal:register ("moveFrame",
        function (i, j) self:moveFrame (i, j) end)

    --фрейм
    self.frame = matrix:new (30, 16)

    --позиция фрейма относительно карты
    self.framePos = vector (0, 0)

    --позиция отображения фрейма на экране
    self.drawPos = vector (0, 0)

    --отображение карты
    local mapData = {"res/content/fantasy-tileset_b.png",
        {{".", 4, 3},
        {"#", 2, 2},
        {">", 5, 1},
        {"+", 6, 2},
        {"-", 5, 3}}
    }

    --отображение объектов на карте
    local objectData = {"res/content/fantasy-tileset.png",
        {{"|", 0, 5}} -- лестница
    }

    --отображение игрока
    local playerData = {"res/content/fantasy-tileset.png",
        {{"@", 0, 18}}
    }

    --отображение затененных тайлов
    local shadowsData = {"res/content/fantasy-tileset_bg.png",
        {{".", 4, 3},
        {"#", 2, 2},
        {">", 5, 1},
        {"+", 6, 2},
        {"-", 5, 3}}
    }

    --отображение затененых предметов
    local shadowsItem = {"res/content/fantasy-tileset_bg.png",
        {{"|", 0, 5}}
    }

    --создать объект с данными для слоев отображения
    self.frameLayers = {}

    --карта
    table.insert(self.frameLayers,
        {name = "map",
        data = matrix:new (self.frame:getWidht(), self.frame:getHeight()),
        lay = layer (mapData)})

    ---[[
    --объекты
    table.insert(self.frameLayers,
        {name = "objects",
        data = matrix:new (self.frame:getWidht(), self.frame:getHeight()),
        lay = layer (objectData)})
    --]]

    --существа
    table.insert(self.frameLayers,
        {name = "creatures",
        data = matrix:new (self.frame:getWidht(), self.frame:getHeight()),
        lay = layer (playerData)})

    --тень
    table.insert(self.frameLayers,
        {name = "shadows",
        data = matrix:new (self.frame:getWidht(), self.frame:getHeight()),
        lay = layer (shadowsData)})

    --затененые объекты
    table.insert(self.frameLayers,
        {name = "shadowsObjects",
        data = matrix:new(self.frame:getWidht(), self.frame:getHeight()),
        lay = layer(shadowsItem)}
    )
end --init

--функция настраивающая отображение на новый игровой уровень
function View:setViewer (world)
    --после генерации новой карты объект с ней передается в отображение.
    self.world = world

    --запомнить максимальные размеры карты
    self.MaxMap = vector (self.world:getMapSize ())
end

--отображение на экран
function View:draw ()
    --размерность отдельного тайла
    local tw, th = 32, 32

    --отображение идет на основе данных из наборов слоев отображения
    for _, val in ipairs(self.frameLayers) do
        --для каждого слоя
        for i, j, v in val.data:iterate () do
            --пройтись по всем точкам из данных слоя и на основе того,
            --какие тайлы там сохранены, отобразить на экране нужные рисунки
            if v and v ~= 0 then
                if not val.lay:getQuad(v) then
                    error("i = " .. tostring(i) .. " j = " .. tostring(j), 0)
                end

                --print (i, j, v, val.name)
                love.graphics.draw (val.lay.tileset,
                    val.lay:getQuad (v),
                    j * tw - tw + self.drawPos.y,
                    i * th - th + self.drawPos.x)
            end
        end
    end
end --draw

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
        if not curCell then
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
