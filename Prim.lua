--Генерация по алгоритму Прима

local proto    = require ("proto")
local utils    = require ("lua_utils.maputils")
local neig     = require ("lua_utils.neighborhood")

local M = {}

--возможные признаки для дифференциации комнат во время генерации
local Type = {Inside = 1, Outside = 2, Border = 3}

--структура, хранащая все локации с признаком Border и методы доступа к ними
local BorderList = {}

--добавляем новую комнату в список
function BorderList:Add (i, j)
   table.insert (self, {i, j})
end

--получаем случайную комнату из списка
function BorderList:GetRnd ()
   local i = math.random (1, #self)

   local result = self[i]

   table.remove (self, i)

   return result[1], result[2]
end

--вспомогательная функция - проверка, не вышли ли мы за границы массива при обходе соседей
function IsInsite (Buffer, i, j)
   local rez = true

   if i < 1 or j < 1 or i > #Buffer[1] or j > #Buffer then
      rez = false
   end

   return rez
end

--добавить всех соседей в список с признаком Border (на границе)
function M.SetNeighborsBordre (Buffer, i, j)
   --получается, что есть такие значения Buffer , которые не хотят срабатывать
   --utils.WriteMap (Buffer)

   --пройтись по всем соседям
   for direction = 1, 4  do
      --получим смещение из начальной точки
      local tmpi, tmpj = neig:GetDir (direction)

      local di, dj = i + tmpi, j + tmpj

      --проверим, что мы не вышли за границы массива
      local check = IsInsite (Buffer, di, dj)

      --если все ОК, то добавляем комнату в список BorderList
      --if check and Buffer[di][dj] == Type.Outside then
      if check then
         --предупреждение выхода за границы
         assert (di <= #Buffer[1] and dj <= #Buffer
            and di >= 1 and dj >= 1,
            "Выход за границы массива! \n" ..
            "di = " .. tostring (di) ..
            " dj = " .. tostring (dj) .. "\n" ..
            "Массив: " .. tostring (#Buffer[1]) .. "x" ..
            tostring (#Buffer))

         --print (Buffer[6][4])

         --print (di, dj)
         --попробуем еще одно утверждение
         assert (Buffer[dj][di] ~= nil,
            "Недопустимое значение!")

         if Buffer[dj][di] == Type.Outside then

            Buffer[dj][di] = Type.Border

            BorderList:Add (di, dj)
         end
      end

   end
end -- добавление соседей в список на границе

--Работа этого алгоритма идет с протолабиринтами
function M:Generation (protoMaze)
   --подготовить специальный массив с признаками для всех комнат протолабиринтами
   local statusArray = {}
   utils.SetSize (statusArray, #protoMaze[1], #protoMaze)

   --вначале все комнаты имеют признак снаружи
   for i, j, _ in utils.Iter (statusArray) do
      statusArray[i][j] = Type.Outside
   end

   --для случайной комнаты ставим признак внутри
   local rndJ, rndI = math.random (1, #protoMaze[1]), math.random (1, #protoMaze)

   statusArray[rndI][rndJ] = Type.Inside

   self.SetNeighborsBordre (statusArray, rndI, rndJ)

   --пока есть хоья бы одна локация с атрибутом на границе
   while #BorderList > 0 do
      --выбираем случайную граничную комнату
      local curI, curJ = BorderList:GetRnd ()

      --ставим ей атрибут внутри
      statusArray[curJ][curI] = Type.Inside

      --для всех соседних с ней локация с атрибутом снаружи
      --ставим атрибут на границе
      self.SetNeighborsBordre (statusArray, curI, curJ)

      --выбираем случайную локацию с атрибутом внутри рядом с текущей
      --и ломаем стену между ними.
      while true do
         --выбрать смещение
         local dir = math.random (1, 4)

         --проверить, что по этому смещению мы не выпадаем за границы массива
         local di, dj = neig:GetDir (dir)

         --если все хорошо, то ломаем стену между текущей локацией и локацией со смещением
         if IsInsite (statusArray, curI + di, curJ + dj) == true and statusArray[curJ + dj][curI + di] then

            protoMaze:BreakWall (curJ, curI, neig:GetDir (dir))
            break
         end
      end
   end
end

-------------------------------------------------
--[[                 Тесты                   ]]--
-------------------------------------------------

--Попробуем забацать самые сложные тесты - для функции генерации
local function test_Generation ()
   --что должен делать эттот код?
   --преобразовывать протолабиринт на вхлде

   -- 1 проверка, что размер протолабиринта не меняется
   local tmpx, tmpy = 1, 12
   local testA = proto:New (tmpx, tmpy)

   --пропускаем через генератор
   M:Generation (testA)

   assert (tmpx == #testA[1] and tmpy == #testA,
      "Генератор изменил размеры протолабиринта!")

   testA = nil
end

local function test_SetNeighborsBordre ()
   --1 проверка, что все соседи задаются для массива, в котором границы не мешают
   --тестовый массив
   local testArray = {}
   utils.SetSize (testArray, 3, 3)

   for i, j, _ in utils.Iter (testArray) do
      testArray[i][j] = Type.Outside
   end

   --отрисуем
   --utils.WriteMap (testArray)

   --зададим соседей
   M.SetNeighborsBordre (testArray, 2, 2)

   --проверка
   assert (testArray[1][2] == Type.Border
      and testArray[2][1] == Type.Border
      and testArray[2][3] == Type.Border
      and testArray[3][2] == Type.Border,
      "Неверно задались соседи!")

   --отрисуем
   --utils.WriteMap (testArray)

   --подчистим
   testArray = nil
--[[
   --2 проверка, когда соседей меньше четырех
   --тестовый массив
   local testArray = {}
   utils.SetSize (testArray, 3, 3)

   for i, j, _ in utils.Iter (testArray) do
      testArray[i][j] = Type.Outside
   end

   --отрисуем
   utils.WriteMap (testArray)

   --зададим соседей
   M.SetNeighborsBordre (testArray, 3, 3)


   --проверка
   assert (testArray[1][2] == Type.Border
      and testArray[2][1] == Type.Border
      and testArray[2][3] == Type.Border
      and testArray[3][2] == Type.Border,
      "Неверно задались соседи!")


   --отрисуем
   utils.WriteMap (testArray)

   --подчистим
   testArray = nil
]]--
end

--проверка выхода за границы
local function test_IsInsite ()
   --создадим тестовый массив
   local testArr = {}
   local ini, inj = 6, 2

   utils.SetSize (testArr, ini, inj)

   --проверяем, что создался массив нужного размера
   assert (ini == #testArr[1] and inj == #testArr,
      "Неверно определен размер, перепутан х и у")

   --utils.WriteMap (testArr)

   --проверяем, что точка на границе, когда она на границе
   assert (IsInsite (testArr, 6, 2) == true,
      "точка не определяется как попавшая в границы")

   assert (IsInsite (testArr, 0, 6) == false,
      "точка не в границе, но определяется как в границе")

   testArr = {}
end

return M