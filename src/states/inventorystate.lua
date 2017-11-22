-- inventorystate.lua


local Menu     = require "menu"
local Signal   = require "hump.signal"
local Input    = require "inputhandler"
local HUD      = require "view.hud"
local vector   = require "hump.vector"


st_inventoryState = {}

function st_inventoryState:init()
	self.signal = Signal:new()

	self.UI = HUD("res/content/keyrusMedium.ttf", 22, self.signal)
	self.UI:addLable({name = "title", pos = vector (100, 10)})
	self.UI:addLable({name = "statedescription", pos = vector (100, love.graphics.getHeight() - 40)})
	self.UI:addLable({name = "itemdescription", pos = vector (100, love.graphics.getHeight() - 56)})
	self.UI:addLable({name = "inventorymessage", pos = vector (100, love.graphics.getHeight() - 72)})

	self.menu = Menu:new({
		x = 100, 
        y = 40,
        font = "res/content/keyrusMedium.ttf", 
        pt = 22
	})

	local inputhandlerinitdata = {
        signal = self.signal,
        kayConform = {
            {"escape", "returnPrevious"},
            {"up", "menuUp"},
            {"down", "menuDown"},
            {"return", "menuActivate"},
            {"backspace", "menuDrop"}            
        } 
    }

	self.input = Input:new(inputhandlerinitdata)

	self.signal:register(
		"returnPrevious", 
		function () gamestate.switch(self.previousState) end
	)

	self.signal:register("menuUp", function () self.menu:up() end)
    self.signal:register("menuDown", function () self.menu:down() end)
    self.signal:register("menuActivate", function () self.menu:enter("activate") end)
    self.signal:register("menuDrop", function () self.menu:enter("drop") end)
end

function st_inventoryState:enter(previous, player)
	-- assert(player.tile == "@", " Player = " .. tostring(player))

	self.previousState = previous
	self.inventoryholder = player

	self.signal:emit(
        "hud",
        "title",
        "Инвентарь"
    )

    self.signal:emit(
        "hud",
        "statedescription",
        "ESC - выйти, enter - использовать предмет, backspase - выбросить предмет"
    )

    self.signal:emit(
        "hud",
        "inventorymessage",
        " "
    )

    self.inventory = self.inventoryholder:getInventory()

    self:__updateMenu__()
end

function st_inventoryState:update(dt)
	self.input:handle()
	self.menu:update()
end

function st_inventoryState:draw()
	self.UI:draw()
	self.menu:draw()
end

function st_inventoryState:__updateMenu__()
	self.menu:removeAll()

    if self.inventory:getLen() > 0 then
	    for item in self.inventory:iterate() do
	    	self.menu:addItem({
	        	text = item.menuname,
	        	selectAction = function ()
            		self.signal:emit(
        				"hud",
        				"itemdescription",
        				item.description
    				)
        		end,
	        	enterAction = function (actiontype)
	        		if actiontype == "activate" then
	        			self.inventory:removeItem(item.ID)

	        			self.signal:emit(
        					"hud",
        					"inventorymessage",
        					item.actiondescription
    					)
    				elseif actiontype == "drop" then
    					-- дать команду на выбрасывание предмета на карту
    					local world = self.inventoryholder.world
                        local res = world:dropItem(item, self.inventoryholder:getPosition())

    					if res then
    						self.inventory:removeItem(item.ID)

	        				self.signal:emit(
        						"hud",
        						"inventorymessage",
        						item.dropdescription
    						)
    					else
    						self.signal:emit(
        						"hud",
        						"inventorymessage",
        						"Некуда выбросить предмет!"
    						)
	        			end
	        		end

	            	self:__updateMenu__()
	        	end
	    	})
	    end

	    self.menu:setSelect(1)
	end
end

