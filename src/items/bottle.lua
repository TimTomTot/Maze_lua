-- бутылочка - тестовый объект на карте

local class = require "30log"

local Item = require "items.item"

local Bottle = Item:extend("Bottle")

function Bottle:init(data)
    self.ID = data.ID
    self.name = "bottle"
    self.menuname = "Бутылочка"
    self.description = "Это простая тестовая бутылочка."
    self.actiondescription = "Ты выпиваешь бутылочку"
    self.dropdescription = "Ты выбрасываешь бутылочку"
    self.tile = "|"
    self.catchUpMessage = "Ты подбираешь бутылочку"
end

function Bottle:stand(creature)
    creature.signal:emit(
        "hud",
        "message",
        "Здесь лежит бутылочка"
    )
end

return Bottle
