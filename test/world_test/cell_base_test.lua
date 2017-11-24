-- cell_base.lua


local luaunit = require "luaunit.luaunit"
local Cell = require "world.cell_base"


TestInitCell = {}

	function TestInitCell:testCorrectInit()
		local initdata = {}

		local tC = Cell:new(initdata)

		luaunit.assertIsTable(tC)
		-- luaunit.assertTrue(tC:instanceOf(Cell))
	end


TestCellPosition = {}
	
	function TestCellPosition:setUp()
		local initdata = {}

		self.tC = Cell:new(initdata) 
	end

	function TestCellPosition:tearDown()
		self.tC = nil
	end

	function TestCellPosition:testDefaultPosition()
		luaunit.assertIsNil(self.tC:getX())
		luaunit.assertIsNil(self.tC:getY())

		local x, y = self.tC:getPosition()

		luaunit.assertIsNil(x)
		luaunit.assertIsNil(y)		
	end

	function TestCellPosition:testSetPosition()
		self.tC:setPosition(10, 20)

		luaunit.assertEquals(self.tC:getX(), 10)
		luaunit.assertEquals(self.tC:getY(), 20)

		local x, y = self.tC:getPosition()

		luaunit.assertEquals(x, 10)
		luaunit.assertEquals(y, 20) 
	end

