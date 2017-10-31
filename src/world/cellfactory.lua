--модуль с фабрикой для генерации объектов с ячейками карты

local class    = require "hump.class"
local cell     = require "world.cell"

local M = class {}

--конструктор
function M:init()
    --инициализация списка со всеми возможными ячейками
    self.cellList = {}

    self:addCells()
end

--функция добавления видов ячеек
function M:addCells()
    --каждая протоячейка может содержать такие данные:
    --имя
    --тайл
    --флаги
    --действия при наступании
    --действие при применении спец. экшена

    --стена
    local wallData = {
        name = "wall",
        tile = "#",
        flag = {}
    }
    wallData.flag[LV_SOLID] = true
    wallData.flag[LV_OPAQUE] = true

    table.insert(self.cellList, wallData)

    --пол
    local floorData = {
        name = "floor",
        tile = ".",
        flag = {}
    }
    --floorData.flag[LV_TRANSPARENT] = true

    table.insert(self.cellList, floorData)

    --лестница
    local stairsData = {
        name = "stairs",
        tile = ">",
        flag = {},
        stand = function (creature, thisCell) --что происходит при наступании на лестницу
            --когда игрок наступает на лестницу
            creature.signal:emit(
                "hud",
                "message",
                "Это лестница на соседний этаж"
            )

            --return thisCell
        end,
        --что происходит при выполнении дейстия
        action = function (creature, action)
            --если действие - переход по лестнице
            if action == AC_DOWNSTAIRS then
                creature.signal:emit("generateMap")
                creature.signal:emit(
                    "hud",
                    "message",
                    "Ты перешел на новый этаж!"
                )

                return true
            end

            return false
        end
    }
    --stairsData.flag[LV_TRANSPARENT] = true

    table.insert(self.cellList, stairsData)

    --открытая дверь
    local openDoorData = {
        name = "openDoor",
        tile = "-",
        flag = {},
        stand = function (creature, thisCell)
            --сообщаем, что игрок находится на открытой дверью
            creature.signal:emit(
                "hud",
                "message",
                "Это открытая дверь"
            )

            --return thisCell
        end,
        action = function (creature, action, thisCell)
            if action == AC_CLOSEDOOR then
                thisCell.name = self.cellList[5].name
                thisCell.tile = self.cellList[5].tile
                thisCell.stand = self.cellList[5].stand
                thisCell.action = self.cellList[5].action
                thisCell.flag[LV_OPAQUE] = true

                --вывести сообщение о открытии двери
                creature.signal:emit(
                    "hud",
                    "message",
                    "Ты закрываешь дверь"
                )

                return true
            end

            return false
        end
    }
    openDoorData.flag[LV_SOLID] = false

    table.insert(self.cellList, openDoorData)

    --закрытая дверь
    local closeDoorData = {
        name = "closeDoor",
        tile = "+",
        flag = {},
        stand = function (creature, thisCell)
            thisCell.name = openDoorData.name
            thisCell.tile = openDoorData.tile
            thisCell.stand = openDoorData.stand
            thisCell.action = openDoorData.action
            thisCell.flag[LV_OPAQUE] = false
            --thisCell.flag[LV_DARKENED] = false
            --thisCell.flag[LV_EXPLORED] = true

            --вывести сообщение о открытии двери
            creature.signal:emit(
                "hud",
                "message",
                "Ты открываешь дверь"
            )

            --return thisCell
        end,
        action = function (creature, action, thisCell)
            if action == AC_OPENDOOR then
                self.cellList[5].stand(creature, thisCell)

                return true
            end

            return false
        end
    }
    closeDoorData.flag[LV_SOLID] = false
    closeDoorData.flag[LV_OPAQUE] = true

    table.insert(self.cellList, closeDoorData)
end

--генерация новой ячейки по имени или по тайлу
function M:newCell(name, extra)
    --определить по имени (или по тайлу) есть ли такая протоячейка
    local protCell = nil

    --дополнительные данные - тайл для рисовки не частей карты
    local outputTile = nil

    for _, v in ipairs(self.cellList) do
        --print (name)

        if name == v.name or name == v.tile then
            protCell = v
            break
        end
    end

    -- если не найдена ни одна ячейка, то задается просто пол
    if not protCell then
        protCell = self.cellList[2]

        outputTile = name
    end

    return cell(protCell, extra), outputTile
end

return M
