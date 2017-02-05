-- модуль с предметами на карте

local class = require "hump.class"

local M = class {}

function M:init()
   self.itemList = {}

   self:addItems()
end

function M:addItems()
   -- бутылочка (пробный предмет)
   local bottleData = {
      name = "bottle",
      tile = "|"
   }

   table.insert(self.itemList, bottleData)
end

function M:newItem(name)
   local protoitem = nil

   for _, val in ipairs(self.itemList) do
      if name == val.name or val.tile then
         protoitem = val
         break
      end
   end

   --создать на основе протообъекта настоящий объект и вернуть его
   local resItem = {
      name = protoitem.name,
      tile = protoitem.tile
   }

   return resItem
end

return M
