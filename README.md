# Civil-County
Це гра розроблена на роблокс платформі використовуючи Lua та Luau. 

## Збірка та Запуск
To build the place from scratch, use:

```bash
rojo build -o "Civil-County.rbxlx"
```

Next, open `Civil-County.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).

## Documentation

- Зберігання данних користувачів `Profile`
	- Зберігання тимчасової інформації про ігрову сесію `SessionData`
		- Зберігання інформації про команду ігрока
		- Зберігання інформації про бонус до наступної зароботної плати за виконнання завдань в команді
	- Зберігання постіної інформації в хмарній базі данних `PersistentData`
		- Зберігання балансу ігрової валюти ігрока на хмарній базі данних (Roblox DataStore Service)
		- Безпечні методи змінення балансу ігрока (додавання, віднімання)
		- Відображення публічного списоку балансів ігроків (ledeaderstats), які знаходяться на одному сервері 
- Фракції з поділом на окремі команди
	- Виплата регулярної заробітної плати
	- Система бонусів до заробітної плати за виконнання завдань фракції
	- Видача службових предметів (наприклад зброя, наручники)
	- Безпечні методи прийняття на роботу та звільнення з роботи
	- Публічний список який ігрок в якій команді (ledeaderstats)
- Надсилання системних повідомлень
	- Відправлення системного повідомлення до вибраного гравця про отримання заробітної плати
	- Відправлення системного повідомлення до всіх учасників вибраної команди
	- Відправлення системного повідомлення до всіх гравців на сервері
- Сервіс реалізації створення префіксального дерева з папки з обʼєктами та пошук
	- Методи створення та видалення префіксального дерева з папки з обʼєктами
	- Автоматично оновлює trie при додаванні або видаленні обʼєктів з привʼязанної папки
	- Виповнює пошук елементів по префіксу по раніше створеному префіксальному дереву
- Додати коментарі у форматі Doxygen/JavaDoc до основних класів і методів
	- Використати теги `@brief`, `@param`, `@return`, `@throws`, `@example`

## API Docs — Doxygen/JavaDoc‑style comments (Lua/Luau)

> Нижче — зразки коментарів у форматі Doxygen/JavaDoc для основних сервісів. Вони сумісні з LuaDoc/EmmyLua та більшістю генераторів документації (Doxygen з фільтром для Lua, LDoc, Sumneko/EmmyLua у VS Code).

### Profile / SessionData / PersistentData
```lua
--- @class Profile
--- @brief Профіль гравця: об'єднує тимчасові (SessionData) та постійні (PersistentData) дані.
--- @field player Player # Роблокс-гравець, власник профілю
--- @field session SessionData # Тимчасові дані активної сесії
--- @field persistent PersistentData # Постійні дані з DataStore
local Profile = {}

--- Створює профіль для гравця.
-- @param player Player Гравець, для якого створюється профіль
-- @return Profile Новий екземпляр профілю
-- @example
-- local profile = Profile.new(player)
function Profile.new(player) end

--- @brief Поточний баланс ігрової валюти.
-- @return number Баланс у валюті гри
function Profile:GetBalance() end

--- @brief Безпечно змінює баланс.
-- @param delta number Сума зміни (може бути від'ємною)
-- @throws "InsufficientFunds" Якщо спроба зняти більше, ніж доступно
-- @return number Нове значення балансу
-- @example
-- profile:AdjustBalance(+100)   -- нарахувати 100
-- profile:AdjustBalance(-50)    -- списати 50
function Profile:AdjustBalance(delta) end

--- @class SessionData
--- @brief Тимчасові дані сесії: команда гравця, бонуси тощо.
--- @field team string|nil Поточна команда (наприклад, "Police")
--- @field salaryBonus number|nil Коефіцієнт/бонус до зарплати
local SessionData = {}

--- Встановлює команду гравця.
-- @param team string Ідентифікатор команди
-- @example
-- session:SetTeam("Police")
function SessionData:SetTeam(team) end

--- @class PersistentData
--- @brief Постійні дані, що зберігаються у DataStore (баланс тощо).
--- @field cash number Поточний баланс
local PersistentData = {}

--- Завантажує дані з DataStore.
-- @param userId number Roblox UserId
-- @return PersistentData Дані користувача
-- @throws "DataStoreError" У разі помилки доступу до хмари
function PersistentData.Load(userId) end

--- Зберігає дані у DataStore.
-- @param userId number Roblox UserId
-- @param data PersistentData Дані для збереження
-- @throws "DataStoreError" У разі помилки доступу до хмари
function PersistentData.Save(userId, data) end
```

### FactionService (фракції, зарплата, кадрові операції)
```lua
--- @class FactionService
--- @brief Керує фракціями/командами, нарахуванням зарплати та кадрами.
local FactionService = {}

--- Приймає гравця на роботу у фракцію.
-- @param player Player Об'єкт гравця
-- @param faction string Назва фракції ("Police", "EMS", тощо)
-- @throws "AlreadyEmployed" Якщо гравець уже в іншій фракції
-- @return boolean true, якщо успішно
-- @example
-- FactionService:Hire(player, "Police")
function FactionService:Hire(player, faction) end

--- Звільняє гравця з фракції.
-- @param player Player Об'єкт гравця
-- @return boolean true, якщо успішно
function FactionService:Fire(player) end

--- Нараховує зарплату всім членам фракції з урахуванням бонусів.
-- @param faction string Назва фракції
-- @return number Кількість успішних виплат
-- @example
-- local paid = FactionService:Payroll("Police")
function FactionService:Payroll(faction) end
```

### NotificationService (системні повідомлення)
```lua
--- @class NotificationService
--- @brief Відправка системних повідомлень гравцю, команді або всьому серверу.
local NotificationService = {}

--- Надсилає повідомлення конкретному гравцю.
-- @param player Player Отримувач
-- @param text string Текст повідомлення
-- @example
-- NotificationService:ToPlayer(player, "Вам нараховано зарплату: $250")
function NotificationService:ToPlayer(player, text) end

--- Надсилає повідомлення всім у команді.
-- @param team string Ідентифікатор команди
-- @param text string Текст повідомлення
function NotificationService:ToTeam(team, text) end


--- Широкомовне повідомлення всім гравцям на сервері.
-- @param text string Текст повідомлення
function NotificationService:Broadcast(text) end
```

### AutocompleteSearchService (префіксальне дерево / trie)
```lua
--- @class AutocompleteSearchService
--- @brief Створює та підтримує trie з вмісту папки; виконує пошук за префіксом.
local AutocompleteSearchService = {}

--- Ініціалізує trie із вмісту папки.
-- @param name string Унікальне ім'я дерева
-- @param folder Instance Папка з об'єктами (їхні імена індексуються)
-- @return boolean true, якщо ініціалізація виконана
-- @throws "AlreadyExists" Якщо дерево з таким ім'ям уже існує
-- @example
-- local ok = AutocompleteSearchService.InitTree("Fruits", workspace.Fruits)
function AutocompleteSearchService.InitTree(name, folder) end

--- Видаляє раніше створене trie.
-- @param name string Ім'я дерева
-- @return boolean true, якщо видалено
function AutocompleteSearchService.RemoveTree(name) end

--- Пошук елементів за префіксом у вказаному trie.
-- @param name string Ім'я дерева
-- @param prefix string Пошуковий префікс (регістрозалежність визначається реалізацією)
-- @param limit number|nil Необов'язковий ліміт кількості результатів
-- @return Instance[] Список знайдених об'єктів
-- @example
-- local results = AutocompleteSearchService.Query("Fruits", "Ap", 10)
function AutocompleteSearchService.Query(name, prefix, limit) end
```

### Приклад наскрізного сценарію
```lua
-- @example Нарахування зарплати з повідомленням
local profile = Profile.new(player)
profile:AdjustBalance(+250)
NotificationService:ToPlayer(player, "Вам нараховано зарплату: $250")
```