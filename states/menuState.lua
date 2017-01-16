--Это модуль, описывающий игровое состояние с начальным, вступительным меню
--игровое состояние - это глобальный объект (сделано так, чтобы
--упростить манипуляции с состояниями)

local signal   = require "hump.signal"
local input    = require "input"
local hud      = require "view.hud"
local vector   = require "hump.vector"

st_startMenu = {}

--для работы в стартовом меню нужны такие объекты
--объект обработки сигналов
local menuSignal = signal.new ()

--пользовательский ввод
local menuInput = {}

--пользовательский интерфейс
local menuUI = {}

--собственно - объект меню
local mainMenu = {}

--отображение пунктов меню на экране
function mainMenu:showMenu (sign)
   for _, v in ipairs(self) do
      local pref

      if v.selected then
         pref = "--- "
      else
         pref = "    "
      end

      sign:emit (
         "hud",
         v.name,
         pref .. v.lable)
   end
end

--функция, вызываемая при первом обращении к состоянию меню
function st_startMenu:init ()
   --задаем кнопки, нажатия на которые будет обрабатывать input
   local inputData = {
      signal = menuSignal,
      kayConform = {
         {"up", "upMenu"},
         {"down", "downMenu"},
         {"return", "activateMenu"}
      }
   }

   menuInput = input (inputData)

   --задаем объект пользовательского интерфейса
   menuUI = hud ("content/keyrusMedium.ttf", 22, menuSignal)

   --название игры
   menuUI:addLable({name = "title", pos = vector (100, 10)})

   --пункты меню
   menuUI:addLable({name = "gameMenu", pos = vector (100, 100)})
   menuUI:addLable({name = "quitMenu", pos = vector (100, 120)})

   --задаем данные для меню
   --данные в виде - лэйбл - что отображается в этом пункте меню
   --признак того, что меню выбрано
   --функция, которая вызывается, когда текущий пункт принимается
   local gameMenuData = {
      name = "gameMenu",
      lable = "Играть",
      selected = true,
      action = function () gamestate.switch(st_gameMain) end
   }

   table.insert(mainMenu, gameMenuData)

   local quitMenuData = {
      name = "quitMenu",
      lable = "Выход",
      selected = false,
      action = function () gamestate.switch(st_quitMenu) end
   }

   table.insert(mainMenu, quitMenuData)

   --регистрация функций перемещения по меню
   menuSignal:register("upMenu",
      function ()
         for i, v in ipairs(mainMenu) do
            if v.selected and i ~= 1 then
               v.selected = false
               mainMenu[i - 1].selected = true

               break
            end
         end

         mainMenu:showMenu(menuSignal)
      end)

   menuSignal:register("downMenu",
      function ()
         for i, v in ipairs(mainMenu) do
            if v.selected and i ~= #mainMenu then
               v.selected = false
               mainMenu[i + 1].selected = true

               break
            end
         end

         mainMenu:showMenu(menuSignal)
      end)

   menuSignal:register("activateMenu",
      function ()
         for _, v in ipairs(mainMenu) do
            if v.selected then
               v.action ()

               break
            end
         end
      end)
end

--функция, вызываемая при каждом заходе в состояние
function st_startMenu:enter (previous)
   --просто, вывод сообщения на экран
   menuSignal:emit (
      "hud",
      "title",
      "Maze  - пройди свой лабиринт")

   --первый вызов пунктов меню
   mainMenu:showMenu (menuSignal)
end

--обработка нажатия на клавишу
function st_startMenu:keypressed (key, isrepeat)
   menuInput:handle(key)
end

--отрисовка состояния
function st_startMenu:draw ()
   menuUI:draw()
end
