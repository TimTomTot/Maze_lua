-- Модуль, предоставляющий унифицированный класс для отображения всех видов меню
--[[

Для работы ему нужно передать объект UI, уже созданый.

Модуль сам создает объект обработчика пользовательского ввода и управляет им

Как пользоваться:
1. Создать объект UI
2. Создать объект сигнала
3. Инициализировать этими объектами меню
4. Инициализировать пункты меню, передав в объект, откуда они будут отображаться (в виде вектора) и такую структуру:
    {
        {label = "Пункт 1", action = function() ...... end},
        {label = "Пункт 2", action = function() ...... end}
    }
5. забрать из объекта обработчик нажатий на кнопки menu.input и использовать его как штатный обработчик входа.
6. при использовании меню в отдельном игровом состоянии, нужно обеспечить, чобы при входе в состояние
   вызывалась функция обновления меню  menu:update()

--]]

local class    = require "hump.class"
local input    = require "inputhandler"
local hud      = require "view.hud"
local vector   = require "hump.vector"

local M = class {}

-- для инициализации нужно передать на вход объекты UI и обработчика сигналов
function M:init(data)
    self.interfase = data.UI
    self.signal = data.signal

    -- пункты меню
    self.menu = {}

    -- создание и настройка обработчика пользовательского ввода
    local inputData = {
        signal = self.signal,
        kayConform = {
            {"up", "upMenu"},
            {"down", "downMenu"},
            {"return", "activateMenu"}
        }
    }

    self.input = input:new(inputData)

    -- регистрация обработки нажатия на клавиши
    self.signal:register(
        "upMenu",
        function()
            for i, v in ipairs(self.menu) do
                if v.selected and i ~= 1 then
                    v.selected = false
                    self.menu[i - 1].selected = true
                    break
                end
            end

            self:update()
        end
    )

    self.signal:register(
        "downMenu",
        function()
            for i, v in ipairs(self.menu) do
                if v.selected and i ~= #self.menu then
                    v.selected = false
                    self.menu[i + 1].selected = true
                    break
                end
            end

            self:update()
        end
    )

    self.signal:register(
        "activateMenu",
        function()
            for _, v in ipairs(self.menu) do
                if v.selected then
                    v.action()
                    break
                end
            end
        end
    )
end

-- функция добавления пунктов меню
-- все пункты описывваются как элементы таблицы в виде:
-- что должно быть написано в этом пункте
-- что происходит при выборе этого пункта (функция)
-- одновременно с созданием пунктов меню происходит их привязка к лейблам отображения на экране
function M:addParagraphs(data, firstPosition)
    -- сохраним позицию отображения для конкретного лейбла
    local curPos = vector(firstPosition.x, firstPosition.y)

    for _, val in ipairs(data) do
        local paragraphData = {
            name = #self.menu,
            label = val.label,
            action = val.action,
        }

        --только первая запись заносится как выбранная
        if #self.menu == 0 then
            paragraphData.selected = true
        else
            paragraphData.selected = false
        end

        table.insert(self.menu, paragraphData)

        -- привязка к лейблу
        self.interfase:addLable({name = paragraphData.name, pos = curPos})

        --curPos.y = curPos.y + 20
        curPos = curPos + vector(0, 20)

        -- print(tostring(curPos.y))
    end
end

-- функция обновления меню
-- просто меняет положения маркера выбранного пункта в соответствии с тем, какой сейчас активен
function M:update()
    -- print (self.menu)

    for _, v in ipairs(self.menu) do
        local pref

        if v.selected then
            pref = "--- "
        else
            pref = "    "
        end

        self.signal:emit(
            "hud",
            v.name,
            pref .. v.label
        )
    end
end

return M
