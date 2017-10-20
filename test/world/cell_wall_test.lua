-- модульные тесты для cell_wall
-- lua -e'package.path = package.path .. ";../lib/?/init.lua;../lib/?.lua;../src/?.lua"' ../lib/testy.lua ./world/cell_wall_test.lua


local Wall = require "world.cell_wall"


local tWall = {}

function SetUp()
    local initdata = {
        ID = 1
    }
    
    tWall = Wall:new(initdata)
end

function TearDown()
    tWall = nil
end


local function test_CreateWall()
    SetUp()
    
    assert(tWall:instanceOf(Wall))
    
    TearDown()
end

local function test_InitPropertyCheck()
    SetUp()
    
    assert(is(tWall.ID, 1))
    assert(is(tWall.name, "wall"))
    assert(is(tWall.tile, "#"))
    assert(is_false(tWall:isWalkable()))
    assert(is_false(tWall:isTransparent()))
    assert(is_false(tWall:isExplored()))
    assert(is_true(tWall:isShaded()))
    assert(is_false(tWall:isCreature()))
    assert(is_false(tWall:isObject()))
    
    TearDown()
end

local function test_CheckExploration()
    SetUp()
    
    assert(is_false(tWall:isExplored()))
    
    tWall:explore()
    
    assert(is_true(tWall:isExplored()))
    
    tWall:forget()
    
    assert(is_false(tWall:isExplored()))
    
    TearDown()
end

local function test_CheckShadoved()
    SetUp()
    
    assert(is_true(tWall:isShaded()))
    
    tWall:illuminate()
    
    assert(is_false(tWall:isShaded()))
    
    tWall:obscure()
    
    assert(is_true(tWall:isShaded()))
    
    TearDown()
end

local function test_CheckCreature()
    SetUp()
    
    assert(is_false(tWall:isCreature()))
    
    local tCreature = "Creature"
    
    tWall:setCreature(tCreature)
    
    assert(is_true(tWall:isCreature()))
    
    local resCreature = tWall:getCreature()
    
    assert(is(resCreature, tCreature))
    
    local newresCteature = tWall:removeCreature()
    
    assert(is(newresCteature, tCreature))
    assert(is_false(tWall:isCreature()))
    
    TearDown()
end

local function test_CheckCreatureFail()
    SetUp()
    
    assert(is_false(tWall:isCreature()))
    
    assert(
        raises(
            "It is no creature on cell " .. tostring(tWall.ID),
            tWall.getCreature,
            tWall
        )
    )
    
    assert(
        raises(
            "It is no creature on cell " .. tostring(tWall.ID),
            tWall.removeCreature,
            tWall
        )
    )
    
    TearDown()
end
