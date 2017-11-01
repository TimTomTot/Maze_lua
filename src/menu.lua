-- menu.lua

--[[
    Простой модуль меню
    
    Для работы в него нужно последовательно передать пункты меню с названием (text),
    действием, которое будет вызываться при выборе этого пункта - selectAction
    и действием при активации пункта enterAction
    
    действия задаются в виде функций - колбеков
--]]


local class = require "30log"
local suit = require "SUIT"


local Menu = class("Menu")

function Menu:init(data)
    self.posx = data.x
    self.posy = data.y
    self.font = love.graphics.newFont (data.font, data.pt)
    self.color = data.color or {bg = {225, 0, 0}}
    
    self.width = data.w or 600
    self.height = data.h or 16
    
    self.selectPrefix = data.selectPrefix     or "--- "
    self.unselectPrefix = data.unselectPrefix or "    " 

    self.suit = suit.new()
    
    self.menu = {}
end

function Menu:addItem(item)
	  table.insert(self.menu, item)
	 
    if #self.menu == 1 then
        self.menu[#self.menu].selected = true
        
        self:__selectAction__(#self.menu)
    else
        self.menu[#self.menu].selected = false
    end
end

function Menu:update()
    self.suit.layout:reset(self.posx, self.posy - self.height)   
    
    -- пустой лейбл для удобства 
    self.suit:Label(
        " ", 
        {align = "left", font = self.font}, 
        self.suit.layout:row(self.width, self.height)
    )
    
    local prefix
    
    for _, val in ipairs(self.menu) do
        if val.selected then
            prefix = self.selectPrefix
        else 
            prefix = self.unselectPrefix
        end
        
        self.suit:Label(
            prefix .. val.text,
            {align = "left", font = self.font, color = self.color},
            self.suit.layout:row() 
        )    
    end
end

function Menu:up()
    for i, val in ipairs(self.menu) do
        if val.selected and i > 1 then
            self.menu[i - 1].selected = true
            self.menu[i].selected = false
            
            self:__selectAction__(i - 1)
            
            break
        end
    end
end

function Menu:down()
    for i, val in ipairs(self.menu) do
        if val.selected and i < #self.menu then
            self.menu[i + 1].selected = true
            self.menu[i].selected = false
            
            self:__selectAction__(i + 1)
            
            break
        end
    end
end

function Menu:enter(...)
    for i, val in ipairs(self.menu) do
        if val.selected then
            self:__enterAction__(i, arg)    
        end
    end
end

function Menu:setSelect(position)
    for _, val in ipairs(self.menu) do
        val.selected = false
    end	
    
    self.menu[position].selected = true
    self:__selectAction__(position)
end

function Menu:draw()
    self.suit:draw()	
end

function Menu:__selectAction__(parag)
    if self.menu[parag].selectAction then
        self.menu[parag].selectAction()
    end
end

function Menu:__enterAction__(parag, ...)
    if self.menu[parag].enterAction then
        self.menu[parag].enterAction(arg)
    end
end

return Menu
