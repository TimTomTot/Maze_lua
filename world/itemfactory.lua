-- модуль с предметами на карте

local class = require "hump.class"

local M = class {}

function M:init()
   self.itemList = {}

   self:addItems()
end

function M:addItems()
   -- body...
end

function M:newItem(name)
   -- body...
end
