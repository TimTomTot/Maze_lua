--Добавление функций от love2d

--игровые константы
require "const"

local maze     = require "Maze.Maze"
local viewer   = require "view.viewer"
local world    = require "world.world"
local signal   = require "hump.signal"
local vector   = require "hump.vector"
local input    = require "inputhandler"
local player   = require "player"
local hud      = require "view.hud"
local LayerFactory = require "view.layerfactory"

--подготовка генератора случайных чисел
math.randomseed(os.time())
--math.randomseed (15)

--таблица с состоянием игры
st_gameMain = {}

--мир игры
local GameWorld = {}

--объект отображения
local Viewer = {}

--обработчик сигналов пользовательского ввода
local inputSignal = signal.new()

--обработчик сигналов для отображения
local viewSignal = signal.new()

--пользовательский ввод
local inputHandler = {}

--игрок
local Hero = {}

--пользовательский интерфейс
local ui = {}

function st_gameMain:init()
    --карта генерируется на основе строки:
    self.someMap = [[
########################################
#......................................#
#.....|...|............................#
#...........................>..........#
#...............................|......#
###################+####################
#........#......#.....#.......#........#
#........#......#.....#.......#........#
#........#......#.....#.......+........#
#........#......#.....#.......#..|||...#
#........#......+.....#.......#..|||...#
#........#......#.....#.......#..|||...#
#..|.....#......#.....#.......#..|||...#
#........#......#.....#.......#..|||...#
#........+..|...#.....+.......#........#
#........#......#.....#.......#........#
#........#......#.....#.......#........#
###################+####################
#...||.................................#
#......................................#
#......................................#
#..........................|...........#
########################################
]]
    --настоить отбражение
    local Width, Height = 30, 16

    GameWorld = world:new({W = Width, H = Height})
    
    GameWorld:parseMap(self.someMap)
    
    local viewinit = {
        file = "res/content/maintileset.png",
        mapW = Width,
        mapH = Height
    } 

    Viewer = viewer:new(viewinit)

    local Layers = LayerFactory:new({W = Width, H = Height})
    
    local maplayer = Layers:generateLayer("map")
    local itemlayer = Layers:generateLayer("items")
    local creaturelayer = Layers:generateLayer("creatures")
    local shadowlayer = Layers:generateLayer("shadow")

    Viewer:addLayer(maplayer:getLayer())
    Viewer:addLayer(itemlayer:getLayer())
    Viewer:addLayer(creaturelayer:getLayer())
    Viewer:addLayer(shadowlayer:getLayer())
    
    --настроить пользовательский ввод
    local inputData = {
        signal = viewSignal,
        kayConform = {
            {"up", "moveUp"},
            {"down", "moveDown"},
            {"right", "moveRight"},
            {"left", "moveLeft"},
            {".", "downSteer"},
            {"o", "openDoor"},
            {"c", "closeDoor"},
            {"g", "catchUp"},
            {"i", "openInventory"},
            {"escape", "quitGame"}
        }
    }
   
    inputHandler = input:new(inputData)

    --связать пользовательский ввод со смещением изображения
    viewSignal:register("moveRight", function () Hero:step(1, 0) end)
    viewSignal:register("moveLeft", function () Hero:step(-1, 0) end)
    viewSignal:register("moveDown", function () Hero:step(0, 1) end)
    viewSignal:register("moveUp", function () Hero:step(0, -1) end)

    viewSignal:register(
        "openInventory",
        function () gamestate.switch(st_inventoryState, Hero) end
    )

    viewSignal:register(
        "quitGame",
        function () gamestate.switch(st_quitMenu) end
    )

    ---[[
    --регестрация функции генерации новой карты
    viewSignal:register(
        "generateMap",
        function ()
            GameWorld:parseMap(self.someMap)
            -- Viewer:setViewer(GameWorld)
            Hero:setToMap()
        end
    )
    --]]
    
    -- обновление изображения 
    viewSignal:register(
        "updateWorld",
        function ()
            -- связь слоя отображения с картой
            local mainlayers = GameWorld:getFrameView()
            
            maplayer:updateLayer(mainlayers)
            itemlayer:updateLayer(mainlayers)
            
            creaturelayer:updateLayer(GameWorld:getCreatureViev())
            
            shadowlayer:updateLayer(GameWorld:getShadowView())
        end
    )
    
    viewSignal:register(
        "setFramePos",
        function (x, y)
            GameWorld:setFramePos(x, y)
        end
    )

    --создать игрока
    Hero = player:new(
        {id = 1,
        tile = "@",
        world = GameWorld,
        signalView = viewSignal,
        R = 5}
    )

    --установить игрока на карту
    Hero:setToMap()

    --загрузка пользовательского интерфейса
    ui = hud("res/content/keyrusMedium.ttf", 22, viewSignal)

    --создать лейбл для отображения fps
    ui:addLable({name = "fps", pos = vector(10, 10)})
end

function st_gameMain:enter(previous, extra)
    --если в это состояние переходить из состояния меню, то загружается карта
    if previous == st_startMenu then
        --GameWorld:parseMap (self.someMap)
        --Hero:setToMap ()

        local currentMap
        local message

        if extra.map == MP_RND then
            currentMap = maze:maptostring(maze:Generate(30, 60))
            message = "Ты вошел в случайный лабиринт"
        elseif extra.map == MP_MANUAL then
            currentMap = self.someMap
            message = "Ты вошел в известный лабиринт"
        end

        GameWorld:parseMap(currentMap)
        Hero:setToMap()

        -- пустое сообщение - для очистки экрана
        viewSignal:emit(
            "hud",
            "message",
            " "
        )

        viewSignal:emit(
            "hud",
            "message",
            message
        )
    end

    viewSignal:emit("updateWorld")
end

--обработка нажатия кнопок
function st_gameMain:keypressed(key, isrepeat)
   
end

function st_gameMain:update(dt)
    --обновлять данные о fps
    viewSignal:emit(
        "hud",
        "fps",
        "FPS: " .. tostring(love.timer.getFPS())
    )
    
    inputHandler:handle()
end

function st_gameMain:draw()
    Viewer:draw()
    ui:draw()
end
