--Функции для работы со списком и тесты для их проверки

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

--[[          Тесты          ]]--

--проверка добавления данных
local function test_Add ()
   --1 проверяем, что после добавления значение размера списка увеличелось на 1
   --сохраним начальный размер списка
   local listLen = #BorderList
   
   --добавим значение в таблицу и сравним что получилось
   BorderList:Add (1, 1)
   
   --проверяем, что после добавления значение размера списка увеличелось на 1
   assert (#BorderList == listLen + 1,
      "Не добавились значения в список!")
   
   --удалить за собой добавленное
   BorderList[1] = nil
   
   --2 проверяем, что добавилось именно то, что должно было
   local i, j = 10, 20
   
   BorderList:Add (i, j)
   
   assert (BorderList[1][1] == i and BorderList[1][2] == j,
      "Добавились не те значения!")
      
   BorderList[1] = nil   
end

--проверка возвращения данных
local function test_GetRnd ()
   --1 проверяем, что после получения одного значения размер массива уменьшается на 10
   BorderList:Add (1, 1)
   
   local listLen = #BorderList
   
   BorderList:GetRnd ()
   
   assert (#BorderList == listLen - 1,
      "После получения данных из массива его размер не уменьшился")
      
   --подчистка на всякий случай
   BorderList[1] = nil
   
   --2 проверка, что возвращаются те значения, какие нужно
   BorderList:Add (1, 1)
   BorderList:Add (2, 2)
   BorderList:Add (3, 3)
   
   math.randomseed (1)
   
   local i, j = BorderList:GetRnd ()
   
   --проверяем, что вернулось (всегда одно и то же с данным посевом для генератора случайных чисел)
   assert (i == 2 and j == 2,
      "Вернулись не те значения!")
      
   --удалить за собой
   for t = #BorderList, 1 do
      BorderList[t] = nil
   end
end
