-- map_test.lua

local luaunit = require "luaunit.luaunit"
local Map = require "world.map"


TestMap = {}

    function TestMap:setUp()
        self.tM = Map:new()
    end
    
    function TestMap:tearDown()
        self.tM = nil
    end

    function TestMap:testCheckMapSize()
        self.tM:setSize(10, 5)
        
        local x, y = self.tM:getSize()
        
        luaunit.assertIsNumber(x)
        luaunit.assertIsNumber(y)
        
        luaunit.assertEquals(x, 10)
        luaunit.assertEquals(y, 5)
    end
    
    function TestMap:testSetCellCorrect()
        self.tM:setSize(4, 2)
        
        local tCell = {
            a = 1,
            b = 2
        }
        
        self.tM:setCell(3, 1, tCell)
        
        local res = self.tM:getCell(3, 1)
        
        luaunit.assertIsTable(res)
        luaunit.assertEquals(res.a, 1)
        luaunit.assertEquals(res.b, 2)
    end
    
    function TestMap:testSetCellIncorrect()
        self.tM:setSize(4, 2)
        
        local tCell = {
            a = 1,
            b = 2
        }
        
        self.tM:setCell(1, 2, tCell)
        
        luaunit.assertErrorMsgContains("No cell in position", self.tM.getCell, self.tM, 1, 1)
        luaunit.assertErrorMsgContains("Out of range", self.tM.getCell, self.tM, 0, 0)
    end
    
    function TestMap:testCheckNeighbors()
        self.tM:setSize(3, 3)
        
        for i = 1, 3 do
            for j = 1, 3 do
                self.tM:setCell(i, j, {a = i, b = j})
            end
        end
        
        local nList = self.tM:getNeighbors(2, 2)
        
        luaunit.assertIsTable(nList)
        luaunit.assertEquals(#nList, 4)
        
        for _, val in ipairs(nList) do
            luaunit.assertIsTable(val)
            luaunit.assertIsNumber(val.a    )
            luaunit.assertIsNumber(val.b)
        end
        
        local nListPart = self.tM:getNeighbors(1, 1)
        
        luaunit.assertIsTable(nListPart)
        luaunit.assertEquals(#nListPart, 2)
    end
    
   
    
    
    