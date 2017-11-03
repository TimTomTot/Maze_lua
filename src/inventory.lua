-- inventory.lua


local class = require "30log"


local Inventory = class("Inventory")

function Inventory:init(data)
	self.itemlist = {}
end

function Inventory:addItem(inputitem)
	table.insert(self.itemlist, inputitem)
end

function Inventory:removeItem(number)
	return table.remove(self.itemlist, number)
end

function Inventory:getLen()
	return #self.itemlist
end

function Inventory:getItem(number)
	return self.itemlist[number]
end

function Inventory:iterate()
	local i = 0

	return function ()
		if i < #self.itemlist then
			i = i + 1
		else
			return nil
		end

		return self.itemlist[i]
	end
end

return Inventory


