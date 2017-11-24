---
-- Модуль представляющий карту игрового мира
--
-- Позволяет получать лоступ к отдельным ячейкам на карте, а так же определять
-- возможность пройти из одной ячейки в другую и видимость между ячейками
-- @module Map


local class = require "30log"
local matrix = require "utils.matrix"


local Map = class("Map")

---
-- Конструктор
function Map:init()
    self.map = nil
end

---
-- Установить размер карты
--
-- @param x размер по горизонтали
-- @param y размер по вертикали
function Map:setSize(x, y)
    self.map = matrix:new(x, y)
end

---
-- Получить размер карты
--
-- @return размер карты по горизонтали
-- @return размер карты по вертикали
function Map:getSize()
    return self.map:getWidht(), self.map:getHeight()
end

---
-- Установить ячейку в указанную точку на карте
--
-- @param x X-координата
-- @param y Y-координата
-- @param cell ячейка, которую нужно установить
function Map:setCell(x, y, cell)
    self.map:set(x, y, cell)
end

---
-- Получить ячейку по указанным координатам
--
-- в случае, если по указанным координатам нет объект ячейки,
-- вызывается исключение
-- @param x X-координата
-- @param y Y-координата
-- @return объект ячейки
function Map:getCell(x, y)
    if not self.map:isEmpty(x, y) then
        return self.map:get(x, y)
    else
        error("No cell in position " .. tostring(x) .. ":" .. tostring(y), 0)
    end    
end

---
-- Проверка, возможно ли пройти между указанными точками
--
-- На данный момент проверка работает только с соседними точками на карте
-- @param srcX X-координата точки отправления
-- @param srcY Y-координата точки отправления
-- @param distX X-координата точки назначения
-- @param distY Y-координата точки назначения
-- @return true если возможно пройти между точками, иначе false
-- @return список объектов cell вдоль маршрута для прохода между точками отправления и назначения (без точки src)
function Map:isWalkableBetween(srcX, srcY, distX, distY)

end

---
-- Проверка, просматриваема ли точка dist из точки src
--
-- @param srcX X-координата точки отправления
-- @param srcY Y-координата точки отправления
-- @param distX X-координата точки назначения
-- @param distY Y-координата точки назначения
-- @return true если между точками есть прямая видимость, иначе false
-- @return список объектов cell видимых вдоль луча зрения от точки src до точки dist (без точки src)
function Map:isVisibleBetween(srcX, srcY, distX, distY)

end

---
-- Получить список всех соседних точек для заданой точки
--
-- @param x X-координата
-- @param y Y-координата
-- @param diags нужно ли рассматривать соседей по диагонали. Если нужно - должно быть установлено в true. По 
-- умолчанию false
-- @return список объектов cell, являющихся соседями заданой точки
function Map:getNeighbors(x, y, diags)    
    local xshift
    local yshift
    
    if diags then
        xshift = {1, -1, 0,  0, -1,  1, -1, 1}
        yshift = {0,  0, 1, -1, -1, -1,  1, 1}
    else
        xshift = {1, -1, 0,  0}
        yshift = {0,  0, 1, -1}
    end
    
    local resultlist = {}
    
    local iter = 1
    
    while true do
        local curx = x + xshift[iter]
        local cury = y + yshift[iter]
        
        if self.map:isInRange(curx, cury) then
            table.insert(resultlist, self.map:get(curx, cury))
        end
    
        iter = iter + 1
        
        if iter > #xshift then
            break
        end
    end
    
    return resultlist
end

---
-- Проверка, что прямоугольник полностью вписывается в границы карты
-- 
-- @param left Х-координата левого края прямоугольника
-- @param right Х-координата правого края прямоугольника
-- @param top Y-координата верхнего края прямоугольника
-- @param bottom Y-координата нижнего края прямоугольника
-- @return true если прямоугольник вписывается в размеры карты, иначе false
function Map:checkRectangle(left, right, top, bottom)

end

---
-- Получить список всех ячеек внутри прямоугольника
--
-- Если размеры прямоугольника не заданы - то возвращается список всех ячеек на карте
-- @param left Х-координата левого края прямоугольника, по умолчанию 1
-- @param right Х-координата правого края прямоугольника, по умолчанию размер карты по горизонтали
-- @param top Y-координата верхнего края прямоугольника, по умолчанию 1
-- @param bottom Y-координата нижнего края прямоугольника, по умолчанию размер карты по вертикали
-- @return список объектов cell, попадающих внутрь заданного прямоугольника
function Map:getCellList(left, right, top, bottom)

end

return Map

