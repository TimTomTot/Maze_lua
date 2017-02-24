-- базовый класс представляющий предметы

local class = require "30log"

local Item = class("Abstract Item")

function Item:init(data)
    self.name = data.name or nil
    self.tile = data.tile or nil
end

return Item