-- inventory_test.lua

--  lua -e'package.path = package.path .. ";../lib/?/init.lua;../lib/?.lua;../src/?.lua"' ../lib/testy.lua ./creatures/inventory_test.lua


local Inventory = require "inventory"


local function test_CheckInventoryAddAndRemove()
	local tInv = Inventory:new()

	tInv:addItem("Item")

	local tItem = tInv:removeItem(1)

	assert(is_eq(tItem, "Item"))

	local tNilItem = tInv:removeItem(1)

	assert(is_nil(tNilItem)) 
end

local function test_CheckInventoryLen()
	local tInv = Inventory:new()

	assert(is_eq(tInv:getLen(), 0))

	tInv:addItem("NewItem")

	assert(is_eq(tInv:getLen(), 1))	

	tInv:removeItem(1)

	assert(is_eq(tInv:getLen(), 0))
end

local function test_CheckGetItem()
	local tInv = Inventory:new()

	tInv:addItem("NewOne")
	tInv:addItem("NewTwo")
	tInv:addItem("NewThree")

	assert(is_eq(tInv:getItem(2), "NewTwo"))
	assert(is_eq(tInv:getLen(), 3))
end

local function test_CheckIteration()
	local tInv = Inventory:new()

	tInv:addItem("NewOne")
	tInv:addItem("NewTwo")
	tInv:addItem("NewThree")

	local tIterationKiper = {}

	for val in tInv:iterate() do
		table.insert(tIterationKiper, val)
	end

	assert(is_eq(tIterationKiper[1], "NewOne"))
	assert(is_eq(tIterationKiper[2], "NewTwo"))
	assert(is_eq(tIterationKiper[3], "NewThree"))
end 

