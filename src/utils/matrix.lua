-- прямоугольная матрица

local class = require "30log"

local Matrix = class("Matrix")

function Matrix:init(x, y)
    if type(x) ~= "number" or type(y) ~= "number" then
        error("matrix len is nil!", 0)
    end

    self.empty = "None"
    
    self.width, self.height = x, y
    self.values = {}

    for j = 1, self.height do
        for i = 1, self.width do
            self.values[(i - 1) * self.width + j] = self.empty
        end
    end
end

function Matrix:getWidht()
    return self.width
end

function Matrix:getHeight()
    return self.height
end

function Matrix:get(x, y)
    return self.values[(x - 1) * self.width + y]
end

function Matrix:set(x, y, value)
    if not self:isInRange(x, y) then
        error("insert out of range!", 0)
    end

    self.values[(x - 1) * self.width + y] = value or self.empty
end

function Matrix:isInRange(x, y)
    if x < 1 or x > self.width or
    y < 1 or y > self.height then
        return false
    else
        return true
    end
end

function Matrix:isEmpty(x, y)
    if self:get(x, y) == self.empty then
        return true
    end
    
    return false
end

function Matrix:iterate()
    local i, j = 0, 1

    return function ()
        if i < self.width then
            i = i + 1
        else
            if j < self.height  then
                j = j + 1
                i = 1
            else
                return nil
            end
        end

        return i, j, self.values[(i - 1) * self.width + j]
    end
end

return Matrix
