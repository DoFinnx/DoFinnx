--[[
	Лоудер Nocturne UI: загружает библиотеку (NLlib.lua) и собирает меню.

	Запуск в инжекторе (этот файл лежит на GitHub как script.lua):
	    loadstring(game:HttpGet("https://raw.githubusercontent.com/DoFinnx/DoFinnx/refs/heads/main/script.lua"))()

	Повторный запуск закрывает уже открытое меню и открывает новое.
	В Roblox Studio можно без ссылок: положите библиотеку как ModuleScript "Library"
	рядом с этим LocalScript — тогда сработает require.
]]

local LIBRARY_URL = "https://raw.githubusercontent.com/DoFinnx/DoFinnx/refs/heads/main/NLlib.lua"

-- Адрес вашего сервера присутствия (server/presence-server.js) для Synchronization,
-- например "https://nocturne-sync.onrender.com". Пусто — синхронизация не работает.
local SYNC_ENDPOINT = "https://nocturne-sync.onrender.com"

local function loadLibrary()
	local module = script and script.Parent and script.Parent:FindFirstChild("Library")
	if module and module:IsA("ModuleScript") then
		return require(module)
	end
	assert(loadstring, "loadstring недоступен: используйте вариант с ModuleScript")

	-- Скачиваем отдельно, чтобы при ошибке было видно, что именно пошло не так.
	-- ?t=<время> — в обход кэша GitHub, чтобы обновления библиотеки подхватывались сразу
	local separator = string.find(LIBRARY_URL, "?", 1, true) and "&" or "?"
	local ok, source = pcall(function()
		return game:HttpGet(LIBRARY_URL .. separator .. "t=" .. tostring(os.time()))
	end)
	if not ok or type(source) ~= "string" then
		error("[Nocturne UI] не удалось скачать библиотеку: " .. tostring(source), 0)
	end
	if source:sub(1, 3) == "\239\187\191" then
		source = source:sub(4) -- убираем BOM, если файл сохранён с ним
	end
	-- Защита от двойной вставки: всё после первого «return Library» отбрасываем.
	local _, finish = source:find("\nreturn Library", 1, true)
	if finish and #source > finish + 2 then
		warn("[Nocturne UI] после 'return Library' в файле есть лишний текст (" .. (#source - finish) .. " байт) — он пропущен. Замените файл на GitHub целиком.")
		source = source:sub(1, finish)
	end

	local chunk, compileError = loadstring(source, "=NocturneLibrary")
	if not chunk then
		error(
			"[Nocturne UI] Library.lua не компилируется: "
				.. tostring(compileError)
				.. "\nРазмер ответа: "
				.. #source
				.. " байт. Начало: "
				.. source:sub(1, 80),
			0
		)
	end

	local runOk, library = pcall(chunk)
	if not runOk then
		error("[Nocturne UI] ошибка при запуске библиотеки: " .. tostring(library), 0)
	end
	if type(library) ~= "table" then
		error("[Nocturne UI] библиотека вернула " .. typeof(library) .. " вместо таблицы", 0)
	end
	return library
end

local Library = loadLibrary()
print("[Nocturne UI] version " .. tostring(Library.Version))

-- Если скрипт запускают повторно, закрываем предыдущее меню, чтобы не было двух окон.
do
	local env = (type(getgenv) == "function" and getgenv()) or _G
	local previous = env.NocturneLibrary
	if previous and previous ~= Library and type(previous.Unload) == "function" then
		pcall(function()
			previous:Unload()
		end)
	end
	env.NocturneLibrary = Library
end

local WHITE = Color3.fromRGB(244, 245, 255)

-- Перевод подписей меню на русский (переключается в меню профиля -> Language).
-- Значения в выпадающих списках остаются как есть.
local RU = Library.Translations.Russian
for key, value in pairs({
	-- категории и вкладки
	Aimbot = "Аимбот",
	Common = "Общее",
	Rage = "Рейдж",
	Legit = "Легит",
	Visuals = "Визуалы",
	Inventory = "Инвентарь",
	Miscellaneous = "Разное",
	-- секции и панели
	Main = "Основное",
	Selection = "Выбор цели",
	Other = "Другое",
	["Anti-Aim"] = "Анти-аим",
	Target = "Цель",
	["Recoil Control"] = "Контроль отдачи",
	Triggerbot = "Триггербот",
	Players = "Игроки",
	World = "Мир",
	Effects = "Эффекты",
	View = "Вид",
	Weapon = "Оружие",
	Charm = "Брелок",
	Agents = "Агенты",
	Actions = "Действия",
	Windows = "Окна",
	Movement = "Движение",
	Menu = "Меню",
	Config = "Конфиг",
	["Rage Settings"] = "Настройки рейджа",
	["Scope Options"] = "Прицел",
	["Aim Assist"] = "Помощь в прицеливании",
	Options = "Параметры",
	Gloves = "Перчатки",
	-- элементы
	["Silent Aim"] = "Тихий аим",
	["Automatic Fire"] = "Автострельба",
	["Aim Through Walls"] = "Сквозь стены",
	["Field of View"] = "Поле зрения",
	Hitboxes = "Хитбоксы",
	Multipoint = "Мультиточки",
	["Hit Chance"] = "Шанс попадания",
	["Min Damage"] = "Мин. урон",
	["Quick Stop"] = "Быстрая остановка",
	["Quick Scope"] = "Быстрый прицел",
	History = "История",
	["Delay Shot"] = "Задержка выстрела",
	["Remove Recoil"] = "Без отдачи",
	["Remove Spread"] = "Без разброса",
	["Duck Peek Assist"] = "Duck Peek",
	["Quick Peek Assist"] = "Quick Peek",
	["Double Tap"] = "Double Tap",
	Pitch = "Наклон",
	Yaw = "Поворот",
	Freestanding = "Фристендинг",
	["Mouse Override"] = "Управление мышью",
	Mode = "Режим",
	Base = "База",
	Offset = "Смещение",
	Hotkey = "Клавиша",
	Color = "Цвет",
	Smoothing = "Сглаживание",
	["Visualize Target"] = "Показывать цель",
	["Visualize FOV"] = "Показывать FOV",
	["Visible Only"] = "Только видимые",
	["Ignore Smoke"] = "Игнорировать дым",
	["Ignore Flash"] = "Игнорировать вспышку",
	["Reaction Time"] = "Время реакции",
	Priority = "Приоритет",
	["Target Switch Delay"] = "Задержка смены цели",
	["Switch Delay"] = "Задержка смены",
	Standalone = "Отдельно",
	["Start Bullet"] = "С пули",
	Vertical = "Вертикаль",
	Horizontal = "Горизонталь",
	["Scoped Only"] = "Только в прицеле",
	Delay = "Задержка",
	["Burst Fire"] = "Очередь",
	Targets = "Цели",
	["ESP Items"] = "Элементы ESP",
	Flags = "Флаги",
	Glow = "Свечение",
	Chams = "Чамсы",
	["Max Distance"] = "Макс. дистанция",
	Bomb = "Бомба",
	Hostages = "Заложники",
	Grenades = "Гранаты",
	["Dropped Weapons"] = "Оружие на земле",
	Scoreboard = "Таблица счёта",
	["Bullet Tracer"] = "Трассеры",
	["Hit Marker"] = "Хитмаркер",
	["Grenade Trajectory"] = "Траектория гранат",
	Crosshairs = "Прицелы",
	["Perspective Options"] = "Перспектива",
	["Viewmodel Options"] = "Модель рук",
	["View Options"] = "Обзор",
	Removals = "Удаления",
	Duration = "Длительность",
	Enemies = "Враги",
	Teammates = "Союзники",
	["Local Player"] = "Вы",
	["Custom Skin"] = "Свой скин",
	Skin = "Скин",
	["Wear Value"] = "Износ",
	["StatTrak Value"] = "Счётчик StatTrak",
	Tint = "Оттенок",
	Model = "Модель",
	Variant = "Вариант",
	Template = "Шаблон",
	Terrorist = "Террорист",
	["Counter-Terrorist"] = "Спецназ",
	["Override Gloves"] = "Свои перчатки",
	["Override Music Kit"] = "Свой набор музыки",
	Copy = "Копировать",
	Paste = "Вставить",
	["Reset Position"] = "Сбросить позицию",
	Delete = "Удалить",
	Watermark = "Водяной знак",
	Items = "Пункты",
	["Additional Colors"] = "Доп. цвет",
	["Display Avatar"] = "Показывать аватар",
	["Right-Aligned"] = "По правому краю",
	["Dynamic Header"] = "Динамический заголовок",
	["Show Inactive Binds"] = "Показывать неактивные",
	["Auto Jump"] = "Автопрыжок",
	["Jump Bug"] = "Jump Bug",
	Slowdown = "Замедление",
	["Auto Strafe"] = "Автострейф",
	["Speed Limit"] = "Лимит скорости",
	["Menu Key"] = "Клавиша меню",
	["Show Notifications"] = "Уведомления",
	["Test Notification"] = "Тестовое уведомление",
	["Unload Menu"] = "Выгрузить меню",
	Profile = "Профиль",
	Save = "Сохранить",
	Load = "Загрузить",
	Reset = "Сбросить",
}) do
	RU[key] = value
end

local Window = Library:CreateWindow({
	Title = "Nocturne",
	Subtitle = "Universal",
	Logo = "NC",
	Footer = "Menu preview",
	Status = "Free preview", -- строка под именем в меню профиля
	SyncEndpoint = SYNC_ENDPOINT, -- Synchronization: видеть других пользователей скрипта
	-- OnRenew = function() end, OnChat = function() end, OnESPScale = function(scale) end
	ToggleKey = Enum.KeyCode.RightShift,
	Size = UDim2.fromOffset(780, 560),
})

----------------------------------------------------------------------
-- AIMBOT
----------------------------------------------------------------------
Window:AddCategory("Aimbot")

------------------------------- Rage ---------------------------------
local Rage = Window:AddTab({ Name = "Rage", Icon = "crosshair" })

local Main = Rage:AddSection({ Name = "Main", Side = "Left" })
local enabled = Main:AddToggle({ Name = "Enabled", Default = true, Flag = "rage_enabled" })
local rageSettings = enabled:AddSettings("Rage Settings")
rageSettings:AddToggle({ Name = "Visualize Target", Default = true })
rageSettings:AddSlider({ Name = "Smoothing", Min = 0, Max = 100, Default = 20, Suffix = "%" })

local silent = Main:AddToggle({ Name = "Silent Aim", Default = true })
local silentSettings = silent:AddSettings("Silent Aim")
silentSettings:AddDropdown({ Name = "Mode", Options = { "Default", "Strict" }, Default = "Default", Width = 110 })

Main:AddToggle({ Name = "Automatic Fire", Default = true })
Main:AddToggle({ Name = "Aim Through Walls", Default = true })
Main:AddSlider({ Name = "Field of View", Min = 0, Max = 180, Default = 180, Decimals = 1, Suffix = "°" })

local Selection = Rage:AddSection({ Name = "Selection", Side = "Left" })
Selection:AddDropdown({ Name = "Target", Options = { "Highest Damage", "Closest to Crosshair", "Lowest Health" } })
Selection:AddDropdown({
	Name = "Hitboxes",
	Multi = true,
	Options = { "Head", "Chest", "Stomach", "Arms", "Legs" },
	Default = { "Head", "Chest", "Stomach" },
})
Selection:AddDropdown({
	Name = "Multipoint",
	Multi = true,
	Options = { "Head", "Chest", "Stomach", "Arms", "Legs" },
	Default = { "Head", "Chest" },
})
Selection:AddSlider({ Name = "Hit Chance", Min = 0, Max = 100, Default = 50, Suffix = "%" })
Selection:AddSlider({ Name = "Min Damage", Min = 0, Max = 100, Default = 15 })
Selection:AddToggle({ Name = "Hit Chance Override", Default = false }):AddKeybind({ Default = Enum.KeyCode.Z })
Selection:AddToggle({ Name = "Min Damage Override", Default = false }):AddKeybind({ Default = Enum.KeyCode.B })
Selection:AddToggle({ Name = "Quick Stop", Default = true })

local quickScope = Selection:AddToggle({ Name = "Quick Scope", Default = true })
local scope = quickScope:AddSettings("Scope Options")
scope:AddToggle({ Name = "Override FOV", Default = true })
scope:AddSlider({ Name = "Scale (x1)", Min = 0, Max = 100, Default = 40, Suffix = "%" })
scope:AddSlider({ Name = "Scale (x2)", Min = 0, Max = 100, Default = 25, Suffix = "%" })
scope:AddDivider()
scope:AddToggle({ Name = "Instant Scope", Default = true })
scope:AddToggle({ Name = "Show Viewmodel", Default = false })

local Other = Rage:AddSection({ Name = "Other", Side = "Right" })
Other:AddDropdown({ Name = "History", Options = { "Off", "Low", "Medium", "High" }, Default = "High", Width = 120 })
Other:AddToggle({ Name = "Delay Shot", Default = true })
Other:AddToggle({ Name = "Remove Recoil", Default = true })
Other:AddToggle({ Name = "Remove Spread", Default = true })
Other:AddToggle({ Name = "Duck Peek Assist", Default = false }):AddKeybind({ Default = Enum.KeyCode.H, Mode = "Hold" })
local peek = Other:AddToggle({ Name = "Quick Peek Assist", Default = false })
peek:AddKeybind({ Default = Enum.KeyCode.X })
Other:AddToggle({ Name = "Double Tap", Default = true }):AddKeybind({ Default = Enum.KeyCode.N })

local AntiAim = Rage:AddSection({ Name = "Anti-Aim", Side = "Right" })
AntiAim:AddToggle({ Name = "Enabled", Default = true })

local pitch = AntiAim:AddSubmenu({ Name = "Pitch", Value = "Down" })
pitch:AddDropdown({
	Name = "Mode",
	Options = { "Disabled", "Down", "Up", "Zero" },
	Default = "Down",
	Width = 110,
	Callback = function(value)
		pitch:SetValue(value)
	end,
})

local yaw = AntiAim:AddSubmenu({ Name = "Yaw", Value = "Backward" })
yaw:AddDropdown({
	Name = "Base",
	Options = { "Backward", "Forward", "Left", "Right" },
	Default = "Backward",
	Width = 110,
	Callback = function(value)
		yaw:SetValue(value)
	end,
})
yaw:AddSlider({ Name = "Offset", Min = -180, Max = 180, Default = 0, Suffix = "°" })

local freestanding = AntiAim:AddSubmenu({ Name = "Freestanding" })
freestanding:AddToggle({ Name = "Freestanding", Default = true }):AddKeybind({ Default = Enum.KeyCode.T })
freestanding:AddSlider({ Name = "Offset", Min = 0, Max = 100, Default = 43 })
freestanding:AddToggle({ Name = "Override Pitch", Default = true })
freestanding:AddSlider({ Name = "Offset", Min = 0, Max = 100, Default = 70 })

local mouseOverride = AntiAim:AddSubmenu({ Name = "Mouse Override" })
mouseOverride:AddKeybind({ Name = "Hotkey", Default = Enum.KeyCode.W })
mouseOverride:AddDropdown({ Name = "Base", Options = { "Local View", "At Targets" }, Default = "Local View", Width = 110 })
mouseOverride:AddColorpicker({ Name = "Color", Default = Color3.fromRGB(185, 78, 155) })
mouseOverride:AddDropdown({ Name = "Style", Options = { "Fade-out", "Static", "Pulse" }, Default = "Fade-out", Width = 110 })

------------------------------- Legit --------------------------------
local Legit = Window:AddTab({ Name = "Legit", Icon = "target" })

local LegitMain = Legit:AddSection({ Name = "Main", Side = "Left" })
local legitEnabled = LegitMain:AddToggle({ Name = "Enabled", Default = true })
legitEnabled:AddKeybind({ Default = Enum.KeyCode.LeftAlt })
local legitSettings = legitEnabled:AddSettings("Aim Assist")
legitSettings:AddToggle({ Name = "Visualize FOV", Default = true }):AddColorpicker({ Default = WHITE })
legitSettings:AddToggle({ Name = "Visible Only", Default = true })
legitSettings:AddToggle({ Name = "Ignore Smoke", Default = false })
legitSettings:AddToggle({ Name = "Ignore Flash", Default = false })
LegitMain:AddSlider({ Name = "Field of View", Min = 0, Max = 30, Default = 4, Decimals = 1, Suffix = "°" })
LegitMain:AddSlider({ Name = "Smoothing", Min = 0, Max = 100, Default = 35, Suffix = "%" })
LegitMain:AddSlider({ Name = "Reaction Time", Min = 0, Max = 500, Default = 80, Suffix = " ms" })

local LegitTarget = Legit:AddSection({ Name = "Target", Side = "Left" })
LegitTarget:AddDropdown({ Name = "Priority", Options = { "Closest to Crosshair", "Lowest Health", "Distance" } })
LegitTarget:AddDropdown({
	Name = "Hitboxes",
	Multi = true,
	Options = { "Head", "Neck", "Chest", "Stomach" },
	Default = { "Head", "Chest" },
})
LegitTarget:AddToggle({ Name = "Target Switch Delay", Default = false })
LegitTarget:AddSlider({ Name = "Switch Delay", Min = 0, Max = 1000, Default = 250, Suffix = " ms" })

local Recoil = Legit:AddSection({ Name = "Recoil Control", Side = "Right" })
local rcs = Recoil:AddToggle({ Name = "Enabled", Default = true })
local rcsSettings = rcs:AddSettings("Recoil Control")
rcsSettings:AddToggle({ Name = "Standalone", Default = false })
rcsSettings:AddSlider({ Name = "Start Bullet", Min = 1, Max = 10, Default = 2 })
Recoil:AddSlider({ Name = "Vertical", Min = 0, Max = 100, Default = 80, Suffix = "%" })
Recoil:AddSlider({ Name = "Horizontal", Min = 0, Max = 100, Default = 65, Suffix = "%" })

local Trigger = Legit:AddSection({ Name = "Triggerbot", Side = "Right" })
local trigger = Trigger:AddToggle({ Name = "Enabled", Default = false })
trigger:AddKeybind({ Default = Enum.KeyCode.Q })
local triggerSettings = trigger:AddSettings("Triggerbot")
triggerSettings:AddDropdown({
	Name = "Hitboxes",
	Multi = true,
	Options = { "Head", "Chest", "Stomach", "Arms", "Legs" },
	Default = { "Head" },
	Width = 120,
})
triggerSettings:AddToggle({ Name = "Scoped Only", Default = true })
Trigger:AddSlider({ Name = "Hit Chance", Min = 0, Max = 100, Default = 70, Suffix = "%" })
Trigger:AddSlider({ Name = "Delay", Min = 0, Max = 500, Default = 60, Suffix = " ms" })
Trigger:AddToggle({ Name = "Burst Fire", Default = false })

----------------------------------------------------------------------
-- COMMON
----------------------------------------------------------------------
Window:AddCategory("Common")

------------------------------ Visuals -------------------------------
local Visuals = Window:AddTab({ Name = "Visuals", Icon = "eye" })

local PlayersSection = Visuals:AddSection({ Name = "Players", Side = "Left" })
PlayersSection:AddToggle({ Name = "Enabled", Default = true }):AddColorpicker({ Default = Color3.fromRGB(241, 108, 157) })
PlayersSection:AddDropdown({
	Name = "Targets",
	Multi = true,
	Options = { "Enemies", "Teammates", "Local Player" },
	Default = { "Enemies" },
})
local espItems = PlayersSection:AddSubmenu({ Name = "ESP Items" })
espItems:AddGroup():AddChips({
	Name = "Main",
	Options = { "Bounding Box", "Name", "Distance", "Health Bar", "Ammo Bar", "Skeleton" },
	Default = { "Bounding Box", "Name", "Health Bar" },
})
espItems:AddGroup():AddChips({
	Name = "Flags",
	Options = { "Unarmored", "Defuser", "Blind", "Scoped", "Reload", "Immunity", "Slowed", "Vulnerable", "Money", "Delay" },
	Default = { "Scoped", "Reload" },
})
espItems:AddGroup():AddChips({ Name = "Weapon", Options = { "Text", "Icon", "Readiness Bar" }, Default = { "Icon" } })

local glow = PlayersSection:AddToggle({ Name = "Glow", Default = true })
glow:AddColorpicker({ Default = Color3.fromRGB(100, 133, 247) })
glow:AddSettings("Glow"):AddGroup():AddDropdown({ Name = "Style", Options = { "Default", "Pulse", "Outline" }, Default = "Default" })
PlayersSection:AddSlider({ Name = "Max Distance", Min = 0, Max = 1000, Default = 500, Suffix = " m" })

local Models = Visuals:AddSection({ Name = "Models", Side = "Right" })
local enemyChams = Models:AddToggle({ Name = "Enemy Chams", Default = true })
enemyChams:AddColorpicker({ Default = Color3.fromRGB(241, 108, 157) })
local enemyChamsGroup = enemyChams:AddSettings("Enemy Chams"):AddGroup()
enemyChamsGroup:AddToggle({ Name = "Visible Only", Default = false })
enemyChamsGroup:AddLabel("Hidden Color"):AddColorpicker({ Default = Color3.fromRGB(100, 133, 247) })
Models:AddToggle({ Name = "Team Chams", Default = false }):AddColorpicker({ Default = Color3.fromRGB(88, 196, 128) })
Models:AddToggle({ Name = "Local Chams", Default = false }):AddColorpicker({ Default = Color3.fromRGB(245, 246, 255) })
Models:AddToggle({ Name = "Weapon Chams", Default = false }):AddColorpicker({ Default = Color3.fromRGB(240, 150, 70) })
Models:AddToggle({ Name = "Hand Chams", Default = false }):AddColorpicker({ Default = Color3.fromRGB(150, 110, 245) })
Models:AddDropdown({ Name = "Material", Options = { "Flat", "Glow", "Metallic", "Glass" }, Default = "Flat", Width = 120 })
Models:AddSlider({ Name = "Transparency", Min = 0, Max = 100, Default = 0, Suffix = "%" })

----------------------------- Inventory ------------------------------
-- Своя модель персонажа: внешний вид другого игрока Roblox ставится на персонажа ЛОКАЛЬНО.
-- С включённой Synchronization модель видят и другие пользователи скрипта (у себя, тоже локально),
-- а вы видите их модели. Обычные игроки видят настоящие аватары.
local Inventory = Window:AddTab({ Name = "Inventory", Icon = "shirt" })

do
	local PlayersService = game:GetService("Players")
	local localPlayer = PlayersService.LocalPlayer

	local ALL_PARTS = { "Accessories", "Clothing", "Body Colors", "Face" }
	local CLOTHING = { Shirt = true, Pants = true, ShirtGraphic = true }

	local function partsSet(list)
		local set = {}
		for _, part in ipairs(list or ALL_PARTS) do
			set[part] = true
		end
		return set
	end

	local function partsList(set)
		local list = {}
		for _, part in ipairs(ALL_PARTS) do
			if set[part] then
				table.insert(list, part)
			end
		end
		return list
	end

	local state = {
		parts = partsSet(ALL_PARTS),
		keepAfterRespawn = true,
		share = true, -- показывать свою модель другим пользователям скрипта
		showOthers = true, -- надевать модели других пользователей на их персонажей
		appearance = nil, -- своя загруженная модель
		targetId = nil,
		targetName = nil,
		snapshot = nil, -- исходный вид своего персонажа, для Reset
		busy = false,
	}
	local appearanceCache = {} -- [UserId аватара] = Model (false — загружается)
	local remote = {} -- [UserId игрока] = { character, key, snapshot }
	local firstSeen = setmetatable({}, { __mode = "k" }) -- когда впервые увидели персонажа

	local function notify(title, text)
		Window:Notify({ Title = title, Text = text, Duration = 4 })
	end

	local function trim(text)
		return (string.gsub(text or "", "^%s*(.-)%s*$", "%1"))
	end

	local function getFace(character)
		local head = character:FindFirstChild("Head")
		return head and (head:FindFirstChild("face") or head:FindFirstChildWhichIsA("Decal"))
	end

	-- Снимок исходного вида персонажа, чтобы потом вернуть как было.
	local function takeSnapshot(character)
		local snapshot = { character = character, items = {}, colors = {} }
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Accoutrement") or CLOTHING[child.ClassName] or child:IsA("BodyColors") then
				local archivable = child.Archivable
				child.Archivable = true
				local ok, copy = pcall(function()
					return child:Clone()
				end)
				child.Archivable = archivable
				if ok and copy then
					table.insert(snapshot.items, copy)
				end
			elseif child:IsA("BasePart") then
				snapshot.colors[child] = child.Color
			end
		end
		local face = getFace(character)
		snapshot.faceTexture = face and face.Texture
		return snapshot
	end

	local function removeKinds(character, parts)
		for _, child in ipairs(character:GetChildren()) do
			if (parts.Accessories and child:IsA("Accoutrement"))
				or (parts.Clothing and CLOTHING[child.ClassName])
				or (parts["Body Colors"] and child:IsA("BodyColors"))
			then
				child:Destroy()
			end
		end
	end

	local function stripWelds(accessory)
		local handle = accessory:FindFirstChild("Handle")
		if handle then
			for _, item in ipairs(handle:GetChildren()) do
				if item:IsA("JointInstance") or item:IsA("WeldConstraint") then
					item:Destroy()
				end
			end
		end
	end

	-- Ищем точку крепления только в частях тела (не внутри других аксессуаров).
	local function findBodyAttachment(character, attachmentName)
		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				local attachment = part:FindFirstChild(attachmentName)
				if attachment and attachment:IsA("Attachment") then
					return attachment
				end
			end
		end
		return nil
	end

	-- Humanoid:AddAccessory на клиенте не создаёт сварку, поэтому привариваем сами.
	local function addAccessory(character, accessory)
		stripWelds(accessory)
		local handle = accessory:FindFirstChild("Handle")
		if not (handle and handle:IsA("BasePart")) then
			accessory.Parent = character
			return
		end
		handle.Anchored = false
		handle.CanCollide = false
		pcall(function()
			handle.Massless = true
			handle.CanQuery = false
			handle.CanTouch = false
		end)

		local weld = Instance.new("Weld")
		weld.Name = "AccessoryWeld"
		weld.Part0 = handle

		local accessoryAttachment = handle:FindFirstChildOfClass("Attachment")
		local bodyAttachment = accessoryAttachment and findBodyAttachment(character, accessoryAttachment.Name)
		if bodyAttachment then
			weld.Part1 = bodyAttachment.Parent
			weld.C0 = accessoryAttachment.CFrame
			weld.C1 = bodyAttachment.CFrame
		else
			local head = character:FindFirstChild("Head")
			if not head then
				accessory.Parent = character
				return
			end
			local hatAttachment = head:FindFirstChild("HatAttachment")
			weld.Part1 = head
			weld.C0 = accessory.AttachmentPoint
			weld.C1 = hatAttachment and hatAttachment.CFrame or CFrame.new(0, head.Size.Y / 2, 0)
		end

		accessory.Parent = character
		weld.Parent = handle
	end

	local function applyAppearance(character, appearance, parts)
		removeKinds(character, parts)
		for _, item in ipairs(appearance:GetChildren()) do
			if item:IsA("Accoutrement") then
				if parts.Accessories then
					addAccessory(character, item:Clone())
				end
			elseif CLOTHING[item.ClassName] then
				if parts.Clothing then
					item:Clone().Parent = character
				end
			elseif item:IsA("BodyColors") then
				if parts["Body Colors"] then
					item:Clone().Parent = character
				end
			elseif item:IsA("Decal") then
				local face = getFace(character)
				if parts.Face and face then
					face.Texture = item.Texture
				end
			end
		end
	end

	local function restoreSnapshot(character, snapshot)
		removeKinds(character, partsSet(ALL_PARTS))
		for _, item in ipairs(snapshot.items) do
			local copy = item:Clone()
			if copy:IsA("Accoutrement") then
				addAccessory(character, copy)
			else
				copy.Parent = character
			end
		end
		for part, color in pairs(snapshot.colors) do
			if part.Parent == character then
				part.Color = color
			end
		end
		local face = getFace(character)
		if face and snapshot.faceTexture then
			face.Texture = snapshot.faceTexture
		end
	end

	-- Запасной путь для инжекторов: собрать внешний вид из HumanoidDescription через game:GetObjects.
	local function buildFromDescription(userId)
		local description = PlayersService:GetHumanoidDescriptionFromUserId(userId)
		local model = Instance.new("Model")
		local function load(assetId)
			if not assetId or assetId == 0 then
				return
			end
			local ok, objects = pcall(function()
				return game:GetObjects("rbxassetid://" .. tostring(assetId))
			end)
			if ok and objects and objects[1] then
				objects[1].Parent = model
			end
		end
		for _, accessory in ipairs(description:GetAccessories(true)) do
			load(accessory.AssetId)
		end
		load(description.Shirt)
		load(description.Pants)
		load(description.GraphicTShirt)
		load(description.Face)
		local colors = Instance.new("BodyColors")
		colors.HeadColor3 = description.HeadColor
		colors.TorsoColor3 = description.TorsoColor
		colors.LeftArmColor3 = description.LeftArmColor
		colors.RightArmColor3 = description.RightArmColor
		colors.LeftLegColor3 = description.LeftLegColor
		colors.RightLegColor3 = description.RightLegColor
		colors.Parent = model
		return model
	end

	local function fetchAppearance(userId)
		local ok, appearance = pcall(function()
			return PlayersService:GetCharacterAppearanceAsync(userId)
		end)
		if ok and appearance then
			return appearance
		end
		local fallbackOk, fallback = pcall(buildFromDescription, userId)
		if fallbackOk and fallback and #fallback:GetChildren() > 0 then
			return fallback
		end
		return nil
	end

	-- С кэшем: один и тот же аватар не скачиваем дважды.
	-- Если скачать не вышло, следующая попытка не раньше чем через 30 с.
	local failedAt = {}
	local function getAppearance(userId)
		local cached = appearanceCache[userId]
		if cached then
			return cached
		end
		if cached == false then
			repeat
				task.wait(0.1)
			until appearanceCache[userId] ~= false
			return appearanceCache[userId]
		end
		if failedAt[userId] and os.clock() - failedAt[userId] < 30 then
			return nil
		end
		appearanceCache[userId] = false
		local model = fetchAppearance(userId)
		appearanceCache[userId] = model
		failedAt[userId] = not model and os.clock() or nil
		return model
	end

	local function resolveUser(input)
		input = trim(input)
		if input == "" then
			return nil, nil
		end
		local id = tonumber(input)
		if id then
			local ok, name = pcall(function()
				return PlayersService:GetNameFromUserIdAsync(id)
			end)
			return id, ok and name or tostring(id)
		end
		local ok, result = pcall(function()
			return PlayersService:GetUserIdFromNameAsync(input)
		end)
		if ok and result then
			return result, input
		end
		return nil, nil
	end

	-- Сообщаем другим пользователям скрипта, какую модель мы надели.
	local function shareMyModel()
		if state.share and state.targetId then
			Library:SetSyncModel({ userId = state.targetId, parts = partsList(state.parts) })
		else
			Library:SetSyncModel(nil)
		end
	end

	------------------------------ своя модель ------------------------------
	local function applyToCurrent()
		local character = localPlayer.Character
		if not (character and state.appearance) then
			return false
		end
		if not (state.snapshot and state.snapshot.character == character) then
			state.snapshot = takeSnapshot(character)
		end
		applyAppearance(character, state.appearance, state.parts)
		return true
	end

	local function applyModel(input)
		if state.busy then
			return
		end
		state.busy = true
		task.spawn(function()
			local userId, name = resolveUser(input)
			if not userId then
				state.busy = false
				notify("Custom Model", "Player not found. Enter a Roblox username or user ID.")
				return
			end
			notify("Custom Model", "Loading avatar: " .. tostring(name))
			local appearance = getAppearance(userId)
			state.busy = false
			if not appearance then
				notify("Custom Model", "Could not load this avatar.")
				return
			end
			state.appearance = appearance
			state.targetId = userId
			state.targetName = name
			shareMyModel()
			if applyToCurrent() then
				notify("Custom Model", "Model applied: " .. tostring(name))
			else
				notify("Custom Model", "No character yet — the model will apply on spawn.")
			end
		end)
	end

	local function resetModel()
		state.appearance = nil
		state.targetId = nil
		state.targetName = nil
		shareMyModel()
		local character = localPlayer.Character
		local snapshot = state.snapshot
		if not (character and snapshot and snapshot.character == character) then
			notify("Custom Model", "Nothing to reset.")
			return
		end
		restoreSnapshot(character, snapshot)
		state.snapshot = nil
		notify("Custom Model", "Original appearance restored.")
	end

	-- После респавна игра ставит родной вид — при включённой опции накладываем модель снова.
	Window:_track(localPlayer.CharacterAdded:Connect(function(character)
		state.snapshot = nil
		if state.keepAfterRespawn and state.appearance then
			character:WaitForChild("Humanoid", 10)
			task.wait(1) -- даём игре загрузить родную одежду, чтобы снимок был полным
			if localPlayer.Character == character then
				applyToCurrent()
			end
		end
	end))

	------------------------ модели других пользователей ------------------------
	-- Модели приходят с сервера синхронизации (Library.SyncModels) и надеваются у вас локально.
	local function updateRemote(models)
		models = models or Library.SyncModels or {}

		-- снимаем модели, которые больше не нужны (пользователь сбросил её, ушёл или вы выключили показ)
		for id, entry in pairs(remote) do
			local player = PlayersService:GetPlayerByUserId(id)
			local character = player and player.Character
			local wanted = state.showOthers and models[id]
			if character ~= entry.character then
				remote[id] = nil -- новый персонаж после респавна: старая модель исчезла вместе с ним
			elseif not wanted then
				if entry.snapshot and character and character.Parent then
					restoreSnapshot(character, entry.snapshot)
				end
				remote[id] = nil
			end
		end

		if not state.showOthers then
			return
		end
		for id, info in pairs(models) do
			local player = PlayersService:GetPlayerByUserId(id)
			local character = player and player.Character
			if character and character:FindFirstChild("Head") then
				firstSeen[character] = firstSeen[character] or os.clock()
				local parts = partsSet(info.parts or ALL_PARTS)
				local key = tostring(info.userId) .. "|" .. table.concat(partsList(parts), ",")
				local entry = remote[id]
				-- ждём пару секунд после появления персонажа, чтобы игра успела надеть родной вид
				if (not entry or entry.key ~= key) and os.clock() - firstSeen[character] > 2 then
					local snapshot = entry and entry.snapshot or nil
					local token = { character = character, key = key, snapshot = snapshot }
					remote[id] = token
					task.spawn(function()
						local appearance = getAppearance(info.userId)
						if remote[id] ~= token or not appearance or player.Character ~= character then
							return
						end
						token.snapshot = token.snapshot or takeSnapshot(character)
						applyAppearance(character, appearance, parts)
					end)
				end
			end
		end
	end

	Library:OnSyncUsers(function(_, _, models)
		pcall(updateRemote, models)
	end)
	task.spawn(function()
		while Window.gui.Parent do
			task.wait(2)
			pcall(updateRemote)
		end
	end)

	------------------------------ интерфейс ------------------------------
	local ModelSection = Inventory:AddSection({ Name = "Custom Model", Side = "Left" })
	local userBox = ModelSection:AddTextbox({
		Name = "Player",
		Placeholder = "Username or ID",
		Width = 160,
		Callback = function(text, enterPressed)
			if enterPressed and trim(text) ~= "" then
				applyModel(text)
			end
		end,
	})
	ModelSection:AddButton({
		Name = "Apply Model",
		Callback = function()
			applyModel(userBox:Get())
		end,
	})
	ModelSection:AddButton({
		Name = "Use My Avatar",
		Callback = function()
			userBox:Set(localPlayer.Name, true)
			applyModel(tostring(localPlayer.UserId))
		end,
	})
	ModelSection:AddToggle({
		Name = "Keep After Respawn",
		Default = true,
		Callback = function(value)
			state.keepAfterRespawn = value
		end,
	})
	ModelSection:AddButton({ Name = "Reset", Danger = true, Callback = resetModel })

	local PartsSection = Inventory:AddSection({ Name = "Copy Parts", Side = "Right" })
	PartsSection:AddChecklist({
		Options = ALL_PARTS,
		Default = ALL_PARTS,
		Callback = function(selected)
			state.parts = partsSet(selected)
			if state.appearance then
				applyToCurrent()
				shareMyModel()
			end
		end,
	})

	local SyncSection = Inventory:AddSection({ Name = "Model Sync", Side = "Right" })
	SyncSection:AddToggle({
		Name = "Share My Model",
		Icon = "cast",
		Default = true,
		Callback = function(value)
			state.share = value
			shareMyModel()
		end,
	})
	SyncSection:AddToggle({
		Name = "Show Others' Models",
		Icon = "eye",
		Default = true,
		Callback = function(value)
			state.showOthers = value
			pcall(updateRemote)
		end,
	})
	SyncSection:AddParagraph({
		Text = "Works when Synchronization is on in the profile menu. Script users see each other's models; other players see real avatars.",
	})

	for key, value in pairs({
		["Custom Model"] = "Своя модель",
		Player = "Игрок",
		["Username or ID"] = "Ник или ID",
		["Apply Model"] = "Применить модель",
		["Use My Avatar"] = "Мой аватар",
		["Keep After Respawn"] = "Сохранять после респавна",
		["Copy Parts"] = "Что копировать",
		Accessories = "Аксессуары",
		Clothing = "Одежда",
		["Body Colors"] = "Цвет тела",
		Face = "Лицо",
		["Model Sync"] = "Синхронизация моделей",
		["Share My Model"] = "Показывать мою модель",
		["Show Others' Models"] = "Показывать модели других",
		["Player not found. Enter a Roblox username or user ID."] = "Игрок не найден. Введите ник или ID Roblox.",
		["Could not load this avatar."] = "Не удалось загрузить этот аватар.",
		["No character yet — the model will apply on spawn."] = "Персонажа пока нет — модель применится при появлении.",
		["Nothing to reset."] = "Нечего сбрасывать.",
		["Original appearance restored."] = "Исходный вид восстановлен.",
		["Works when Synchronization is on in the profile menu. Script users see each other's models; other players see real avatars."] = "Работает, когда в меню профиля включена Synchronization. Пользователи скрипта видят модели друг друга, остальные игроки — настоящие аватары.",
	}) do
		RU[key] = value
	end
end

--------------------------- Miscellaneous ----------------------------
-- Раскладка по референсу: VIEW / HUD / WORLD ESP / MISCELLANEOUS.
-- Всплывающие панели собраны из групп-карточек (panel:AddGroup()).
local Misc = Window:AddTab({ Name = "Miscellaneous", Icon = "gear" })

-- Рабочие экранные виджеты. Их можно перетаскивать мышью.
local WIDGET_ACCENT = Color3.fromRGB(100, 133, 247)
local WatermarkWidget = Window:CreateWatermark({
	Title = "NC",
	Items = { "Logo", "Latency", "Framerate", "Time", "Name" },
	Accent = Color3.fromRGB(242, 100, 120),
})
local HotkeyWidget = Window:CreateHotkeyList({ Position = UDim2.fromOffset(16, 260) })
local SpectatorWidget = Window:CreateSpectatorList({ Position = UDim2.fromOffset(16, 440) })
local EventLog = Window:CreateEventLog({ Position = UDim2.fromOffset(16, 56), Prefix = "[NC]", Visible = false })
-- Список других пользователей скрипта на сервере (заполняется, когда включена Synchronization).
local SyncWidget = Window:CreateSyncList({ Position = UDim2.fromOffset(16, 600) })
SyncWidget:SetDynamic(true)

-------------------------------- VIEW --------------------------------
local ViewSection = Misc:AddSection({ Name = "View", Side = "Left" })

local viewOptions = ViewSection:AddSubmenu({ Name = "View Options" })
local viewFov = viewOptions:AddGroup()
viewFov:AddToggle({ Name = "Override FOV", Default = true })
viewFov:AddSlider({ Name = "Value", Min = 60, Max = 130, Default = 100, Suffix = "°" })
local viewAspect = viewOptions:AddGroup()
viewAspect:AddToggle({ Name = "Override Aspect Ratio", Default = true })
viewAspect:AddDropdown({ Name = "Scaling", Options = { "Vertical", "Horizontal" }, Default = "Horizontal" })
viewAspect:AddSlider({ Name = "Value", Min = 50, Max = 200, Default = 80, Suffix = "%" })
viewOptions:AddGroup():AddToggle({ Name = "Disable Landing Bob", Default = false })

local scopeOptions = ViewSection:AddSubmenu({ Name = "Scope Options" })
local scopeFov = scopeOptions:AddGroup()
scopeFov:AddToggle({ Name = "Override FOV", Default = true })
scopeFov:AddSlider({ Name = "Scale (x1)", Min = 0, Max = 100, Default = 100, Suffix = "%" })
scopeFov:AddSlider({ Name = "Scale (x2)", Min = 0, Max = 100, Default = 100, Suffix = "%" })
local scopeOther = scopeOptions:AddGroup()
scopeOther:AddToggle({ Name = "Instant Scope", Default = false })
scopeOther:AddToggle({ Name = "Show Viewmodel", Default = true })

local viewmodel = ViewSection:AddSubmenu({ Name = "Viewmodel Options" })
local vmFov = viewmodel:AddGroup()
vmFov:AddToggle({ Name = "Override FOV", Default = false })
vmFov:AddSlider({ Name = "Value", Min = 40, Max = 120, Default = 68 })
local vmPosition = viewmodel:AddGroup()
vmPosition:AddToggle({ Name = "Override Position", Default = false })
vmPosition:AddSlider({ Name = "X", Min = -10, Max = 10, Default = 1, Decimals = 1 })
vmPosition:AddSlider({ Name = "Y", Min = -10, Max = 10, Default = 0, Decimals = 1 })
vmPosition:AddSlider({ Name = "Z", Min = -10, Max = 10, Default = -1, Decimals = 1 })
local vmAngles = viewmodel:AddGroup()
vmAngles:AddToggle({ Name = "Override Angles", Default = false })
vmAngles:AddSlider({ Name = "Pitch", Min = -90, Max = 90, Default = 0, Suffix = "°" })
vmAngles:AddSlider({ Name = "Yaw", Min = -90, Max = 90, Default = 0, Suffix = "°" })
vmAngles:AddSlider({ Name = "Roll", Min = -90, Max = 90, Default = 0, Suffix = "°" })
local vmModifiers = viewmodel:AddGroup()
vmModifiers:AddToggle({ Name = "Override Modifiers", Default = false })
vmModifiers:AddSlider({ Name = "Bobbing", Min = 0, Max = 100, Default = 100, Suffix = "%" })
vmModifiers:AddSlider({ Name = "Angles Sway", Min = 0, Max = 100, Default = 100, Suffix = "%" })
vmModifiers:AddSlider({ Name = "Velocity Sway", Min = 0, Max = 100, Default = 100, Suffix = "%" })
vmModifiers:AddSlider({ Name = "In Air Offset", Min = 0, Max = 100, Default = 100, Suffix = "%" })

local perspective = ViewSection:AddSubmenu({ Name = "Perspective Options" })
local perspectiveMain = perspective:AddGroup()
perspectiveMain:AddToggle({ Name = "Force Third Person", Default = false }):AddKeybind({ Default = Enum.KeyCode.V })
perspectiveMain:AddDropdown({
	Name = "Disablers",
	Multi = true,
	Options = { "Close To Wall", "Holding Grenade" },
	Default = { "Close To Wall" },
})
perspectiveMain:AddSlider({ Name = "Distance", Min = 30, Max = 200, Default = 70 })
perspective:AddGroup():AddDropdown({
	Name = "Disable Overhead",
	Multi = true,
	Options = { "Self", "Teammates", "Enemies" },
})

ViewSection:AddDropdown({
	Name = "Unlock Spectating",
	Multi = true,
	Options = { "Free Camera", "Any Player", "Enemies" },
	Width = 130,
})
ViewSection:AddDropdown({
	Name = "Visual Recoil",
	Multi = true,
	Options = { "No Shake", "No Recoil", "No Viewmodel Recoil" },
	Width = 130,
})

-------------------------------- HUD ---------------------------------
local Hud = Misc:AddSection({ Name = "HUD", Side = "Right" })
Hud:AddToggle({ Name = "Radar", Default = false })
Hud:AddToggle({ Name = "Preserve Killfeed", Default = false })
Hud:AddToggle({ Name = "Inaccuracy Overlay", Default = false }):AddColorpicker({ Default = Color3.fromRGB(120, 122, 136) })
Hud:AddDropdown({ Name = "Scope Overlay", Options = { "Default", "Lines", "None" }, Default = "Default", Width = 130 })

local scoreboard = Hud:AddSubmenu({ Name = "Scoreboard" })
local scoreboardMain = scoreboard:AddGroup()
scoreboardMain:AddToggle({ Name = "Reveal Money", Default = true })
scoreboardMain:AddDropdown({ Name = "Equipment", Options = { "Disabled", "Enemy Only", "Everyone" }, Default = "Enemy Only" })
scoreboard:AddGroup():AddChecklist({
	Options = { "Primary", "Secondary", "Knife", "Taser", "Grenades", "Bomb", "Defuse Kit", "Armor", "Other" },
	Default = { "Primary", "Secondary", "Grenades", "Bomb", "Defuse Kit" },
})

local crosshairs = Hud:AddSubmenu({ Name = "Crosshairs" })
local crosshairsGroup = crosshairs:AddGroup()
crosshairsGroup:AddToggle({ Name = "Default", Default = true })
crosshairsGroup:AddToggle({ Name = "While Scoped", Default = false })
crosshairsGroup:AddToggle({ Name = "Penetration", Default = false }):AddColorpicker({ Default = Color3.fromRGB(196, 84, 168) })

------------------------------ WORLD ESP -----------------------------
local WorldEsp = Misc:AddSection({ Name = "World ESP", Side = "Left" })

local bomb = WorldEsp:AddSubmenu({ Name = "Bomb" })
local bombEffects = bomb:AddGroup()
bombEffects:AddToggle({ Name = "Colorize Effects", Default = true }):AddColorpicker({ Default = Color3.fromRGB(198, 83, 161) })
bombEffects:AddToggle({ Name = "Bomb Indicator", Default = true }):AddColorpicker({ Default = Color3.fromRGB(223, 99, 139) })
bombEffects:AddToggle({ Name = "Defuse Indicator", Default = true }):AddColorpicker({ Default = Color3.fromRGB(214, 82, 108) })
bombEffects:AddToggle({ Name = "Defuser", Default = true }):AddColorpicker({ Default = Color3.fromRGB(222, 119, 154) })
local bombEsp = bomb:AddGroup()
bombEsp:AddToggle({ Name = "Enabled", Default = true }):AddColorpicker({ Default = Color3.fromRGB(158, 229, 161) })
bombEsp:AddLabel("Bomb Defused"):AddColorpicker({ Default = Color3.fromRGB(217, 231, 250) })
bombEsp:AddChips({
	Options = { "Icon", "Text", "Progress Bar", "Time Remaining", "Damage", "Distance", "Glow" },
	Default = { "Icon", "Progress Bar", "Time Remaining" },
})

local weapons = WorldEsp:AddSubmenu({ Name = "Weapons" })
local weaponsGroup = weapons:AddGroup()
weaponsGroup:AddToggle({ Name = "Colorize Effects", Default = true }):AddColorpicker({ Default = Color3.fromRGB(200, 88, 173) })
weaponsGroup:AddToggle({ Name = "Enabled", Default = true }):AddColorpicker({ Default = WHITE })
weapons:AddGroup():AddChips({ Options = { "Icon", "Text", "Ammo", "Distance", "Glow" }, Default = { "Icon", "Ammo" } })

local hostages = WorldEsp:AddSubmenu({ Name = "Hostages" })
hostages:AddGroup():AddToggle({ Name = "Rescue Indicator", Default = true }):AddColorpicker({ Default = Color3.fromRGB(190, 215, 243) })
local hostagesEsp = hostages:AddGroup()
hostagesEsp:AddToggle({ Name = "Enabled", Default = true }):AddColorpicker({ Default = Color3.fromRGB(241, 108, 157) })
hostagesEsp:AddChips({ Options = { "Bounding Box", "Progress Bar", "Text", "Distance", "Glow" }, Default = { "Text" } })

local grenades = WorldEsp:AddSubmenu({ Name = "Grenades" })
local grenadesFx = grenades:AddGroup()
grenadesFx:AddToggle({ Name = "Smoke Radius", Default = true }):AddColorpicker({ Default = Color3.fromRGB(91, 149, 237) })
grenadesFx:AddToggle({ Name = "Molotov Radius", Default = true }):AddColorpicker({ Default = Color3.fromRGB(203, 170, 107) })
grenadesFx:AddToggle({ Name = "Colorize Smoke", Default = false }):AddColorpicker({ Default = Color3.fromRGB(167, 170, 121) })
grenadesFx:AddToggle({ Name = "Colorize Molotov", Default = false }):AddColorpicker({ Default = Color3.fromRGB(228, 168, 52) })
grenadesFx:AddToggle({ Name = "Colorize Explosion", Default = false }):AddColorpicker({ Default = Color3.fromRGB(108, 152, 237) })
local grenadesEsp = grenades:AddGroup()
grenadesEsp:AddToggle({ Name = "Enabled", Default = true }):AddColorpicker({ Default = WHITE })
grenadesEsp:AddChips({
	Options = { "Icon", "Text", "Progress Bar", "Time Remaining", "Distance", "Glow", "Trajectory" },
	Default = { "Icon", "Time Remaining" },
})

local trajectory = WorldEsp:AddToggle({ Name = "Grenade Trajectory", Default = false })
local trajectoryGroup = trajectory:AddSettings("Grenade Trajectory"):AddGroup()
trajectoryGroup:AddLabel("Color"):AddColorpicker({ Default = Color3.fromRGB(239, 70, 123) })
trajectoryGroup:AddSlider({ Name = "Exponent", Min = 0, Max = 100, Default = 45 })
trajectoryGroup:AddToggle({ Name = "Thrown Grenades", Default = true })
trajectoryGroup:AddToggle({ Name = "Pin Pulled Only", Default = true })
WorldEsp:AddToggle({ Name = "Grenade Proximity Warnings", Default = false })

---------------------------- MISCELLANEOUS ---------------------------
local MiscSection = Misc:AddSection({ Name = "Miscellaneous", Side = "Right" })

-- Windows: рабочие виджеты + какие функции показывать в списке Hotkeys.
local windowsPanel = MiscSection:AddSubmenu({ Name = "Windows" })
local windowsMain = windowsPanel:AddGroup()

-- Свои настройки вида для каждого списка: Hotkeys и Spectators меняются независимо.
local function addListSettings(toggle, widget, title)
	local settings = toggle:AddSettings(title):AddGroup()
	settings:AddDropdown({
		Name = "Style",
		Options = { "Default", "Inverted", "Compact" },
		Default = "Default",
		Callback = function(style)
			widget:SetStyle(style)
		end,
	})
	settings:AddToggle({
		Name = "Right-Aligned",
		Default = false,
		Callback = function(value)
			widget:SetRightAligned(value)
		end,
	})
	settings:AddToggle({
		Name = "Dynamic Header",
		Default = true,
		Callback = function(value)
			widget:SetDynamic(value)
		end,
	})
	return settings
end

local watermark = windowsMain:AddToggle({
	Name = "Watermark",
	Icon = "watermark",
	Default = true,
	Callback = function(value)
		WatermarkWidget:SetVisible(value)
	end,
})
local watermarkSettings = watermark:AddSettings("Watermark"):AddGroup()
watermarkSettings:AddDropdown({
	Name = "Items",
	Multi = true,
	Options = { "Logo", "Latency", "Framerate", "Speed", "Memory", "KD Ratio", "Players", "Time", "Name" },
	Default = { "Logo", "Latency", "Framerate", "Time", "Name" },
	Callback = function(items)
		WatermarkWidget:SetItems(items)
	end,
})
watermarkSettings:AddLabel("Additional Colors"):AddColorpicker({
	Default = Color3.fromRGB(242, 100, 120),
	Callback = function(color)
		WatermarkWidget:SetAccent(color)
	end,
})
watermarkSettings:AddToggle({
	Name = "Display Avatar",
	Default = true,
	Callback = function(value)
		WatermarkWidget:SetAvatar(value)
	end,
})

local hotkeys = windowsMain:AddToggle({
	Name = "Hotkeys",
	Icon = "list",
	Default = true,
	Callback = function(value)
		HotkeyWidget:SetVisible(value)
	end,
})
addListSettings(hotkeys, HotkeyWidget, "Hotkeys"):AddToggle({
	Name = "Show Inactive Binds",
	Default = false,
	Callback = function(value)
		HotkeyWidget:SetShowAll(value)
	end,
})

local spectators = windowsMain:AddToggle({
	Name = "Spectators",
	Icon = "eye",
	Default = true,
	Callback = function(value)
		SpectatorWidget:SetVisible(value)
	end,
})
addListSettings(spectators, SpectatorWidget, "Spectators")

windowsMain:AddToggle({
	Name = "Log Events",
	Icon = "terminal",
	Default = false,
	Callback = function(value)
		EventLog:SetVisible(value)
	end,
})
-- Synchronization включается в меню профиля; здесь — как показывать найденных пользователей.
local scriptUsers = windowsMain:AddToggle({
	Name = "Script Users",
	Icon = "cast",
	Default = true,
	Callback = function(value)
		SyncWidget:SetVisible(value)
	end,
})
local scriptUsersSettings = addListSettings(scriptUsers, SyncWidget, "Script Users")
scriptUsersSettings:AddToggle({
	Name = "Overhead Tags",
	Default = true,
	Callback = function(value)
		Library.SyncTagsVisible = value
	end,
})
-- значок NC рядом с именем в списке игроков (Tab)
scriptUsersSettings:AddToggle({
	Name = "Player List Tags",
	Default = true,
	Callback = function(value)
		Library.PlayerListTagsVisible = value
		if Window._refreshPlayerListTags then
			pcall(Window._refreshPlayerListTags)
		end
	end,
})
Library:OnSyncUsers(function(_, joined)
	for _, id in ipairs(joined) do
		local player = game:GetService("Players"):GetPlayerByUserId(id)
		if player then
			EventLog:Push((Library.Settings.SafeMode and Library:Translate("Hidden") or player.DisplayName) .. " " .. Library:Translate("also uses this script"))
		end
	end
end)

local windowsBinds = windowsPanel:AddGroup()
windowsBinds:AddLabel("Color", { Icon = "palette" }):AddColorpicker({
	Default = WIDGET_ACCENT,
	Callback = function(color)
		HotkeyWidget:SetAccent(color)
		SpectatorWidget:SetAccent(color)
	end,
})
-- Каждая строка решает, показывать ли эту функцию в списке Hotkeys.
for _, item in ipairs({
	{ "Hit Chance Override", "crosshair" },
	{ "Min Damage Override", "keyboard", true },
	{ "Double Tap", "bullets", true },
	{ "Duck Peek Assist", "duck" },
	{ "Freestanding", "freestand" },
	{ "Slowdown", "triangle" },
	{ "Jump Bug", "jump" },
}) do
	local name, iconName, hasSettings = item[1], item[2], item[3]
	local row = windowsBinds:AddToggle({
		Name = name,
		Icon = iconName,
		Default = true,
		Callback = function(value)
			HotkeyWidget:SetHidden(name, not value)
		end,
	})
	if hasSettings then
		row:AddSettings(name):AddGroup():AddToggle({ Name = "Show Value", Default = true })
	end
end
HotkeyWidget:SetAccent(WIDGET_ACCENT)
SpectatorWidget:SetAccent(WIDGET_ACCENT)
HotkeyWidget:SetDynamic(true)
SpectatorWidget:SetDynamic(true)

local removals = MiscSection:AddSubmenu({ Name = "Removals" })
removals:AddGroup():AddChecklist({
	Options = {
		"Flashbang Effect",
		"Smoke Rendering",
		"First Person Legs",
		"Carried Hostage",
		"Post Processing",
		"Team Intro",
		"Water Effects",
		"Blood Effects",
		"Decals",
	},
	Default = { "Flashbang Effect" },
})
local ragdolls = removals:AddGroup()
ragdolls:AddDropdown({ Name = "Ragdolls", Options = { "Default", "Disabled", "Frozen" }, Default = "Default" })
ragdolls:AddSlider({ Name = "Gravity", Min = 0, Max = 100, Default = 60, Suffix = "%" })
ragdolls:AddSlider({ Name = "Friction", Min = 0, Max = 100, Default = 60, Suffix = "%" })

local ambience = MiscSection:AddSubmenu({ Name = "Ambience" })
local night = ambience:AddGroup()
night:AddToggle({ Name = "Night Mode", Default = false })
night:AddSlider({ Name = "Brightness", Min = 0, Max = 100, Default = 40, Suffix = "%" })
local fog = ambience:AddGroup()
fog:AddToggle({ Name = "Fog", Default = false }):AddColorpicker({ Default = Color3.fromRGB(150, 160, 190) })
fog:AddSlider({ Name = "Fog Distance", Min = 0, Max = 1000, Default = 400 })
local sky = ambience:AddGroup()
sky:AddDropdown({ Name = "Skybox", Options = { "Default", "Night", "Space", "Sunset" }, Default = "Default" })
sky:AddLabel("Ambient Color"):AddColorpicker({ Default = Color3.fromRGB(120, 120, 140) })

local hitMarker = MiscSection:AddSubmenu({ Name = "Hit Marker" })
for _, kind in ipairs({ "2D Marker", "3D Marker", "Damage Marker" }) do
	local group = hitMarker:AddGroup()
	group:AddToggle({ Name = kind, Default = kind ~= "3D Marker" }):AddColorpicker({ Default = WHITE })
	group:AddSlider({ Name = "Duration", Min = 0, Max = 5, Default = 1, Decimals = 1, Suffix = "s" })
end

local bulletTracers = MiscSection:AddSubmenu({ Name = "Bullet Tracers" })
for _, who in ipairs({ "Enemies", "Teammates", "Local Player" }) do
	local group = bulletTracers:AddGroup()
	group:AddToggle({ Name = who, Default = who ~= "Teammates" }):AddColorpicker({ Default = WHITE })
	group:AddSlider({ Name = "Duration", Min = 0, Max = 10, Default = 3, Decimals = 1, Suffix = "s" })
end

MiscSection:AddToggle({ Name = "Bullet Impacts", Default = false }):AddColorpicker({ Default = Color3.fromRGB(196, 110, 220) })

------------------------------ Settings ------------------------------
-- То, что раньше было в Miscellaneous: движение, меню, конфиги.
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "sliders" })

local Movement = SettingsTab:AddSection({ Name = "Movement", Side = "Left" })
Movement:AddToggle({ Name = "Auto Jump", Default = true })
Movement:AddToggle({ Name = "Jump Bug", Default = false }):AddKeybind({ Default = Enum.KeyCode.C })
Movement:AddToggle({ Name = "Slowdown", Default = false }):AddKeybind({ Default = Enum.KeyCode.LeftShift, Mode = "Hold" })
local strafe = Movement:AddToggle({ Name = "Auto Strafe", Default = false })
strafe:AddSettings("Auto Strafe"):AddGroup():AddSlider({ Name = "Smoothing", Min = 0, Max = 100, Default = 60, Suffix = "%" })
Movement:AddSlider({ Name = "Speed Limit", Min = 0, Max = 300, Default = 250 })

local MenuSection = SettingsTab:AddSection({ Name = "Menu", Side = "Right" })
MenuSection:AddKeybind({
	Name = "Menu Key",
	Default = Window.ToggleKey,
	Changed = function(key)
		if key then
			Window.ToggleKey = key
		end
	end,
})
-- Язык, масштаб, стиль и т.д. — в меню профиля (клик по карточке игрока внизу сайдбара).
MenuSection:AddToggle({
	Name = "Show Notifications",
	Default = true,
	Callback = function(value)
		Library.NotificationsEnabled = value
	end,
})
MenuSection:AddButton({
	Name = "Test Notification",
	Callback = function()
		Window:Notify({ Title = "Nocturne", Text = "This is a notification preview.", Duration = 3 })
	end,
})
MenuSection:AddButton({
	Name = "Unload Menu",
	Danger = true,
	Callback = function()
		Library:Unload()
	end,
})

local Config = SettingsTab:AddSection({ Name = "Config", Side = "Right" })
-- Конфиги: всё состояние меню в файл nocturne_<профиль>.json (нужен writefile/readfile инжектора).
local profileDropdown = Config:AddDropdown({
	Name = "Profile",
	Options = { "Default", "Legit", "Rage", "Custom" },
	Default = "Default",
	Width = 120,
})
Config:AddButton({
	Name = "Save",
	Callback = function()
		local name = profileDropdown:Get()
		local ok, err = Library:SaveConfig(name)
		Window:Notify({
			Title = "Config",
			Text = ok and ("Saved: " .. name) or ("Save failed: " .. tostring(err)),
			Duration = 3,
		})
	end,
})
Config:AddButton({
	Name = "Load",
	Callback = function()
		local name = profileDropdown:Get()
		local ok, err = Library:LoadConfig(name)
		profileDropdown:Set(name, true) -- в файле мог сохраниться другой профиль
		Window:Notify({
			Title = "Config",
			Text = ok and ("Loaded: " .. name) or ("Load failed: " .. tostring(err)),
			Duration = 3,
		})
	end,
})
Config:AddButton({
	Name = "Reset",
	Danger = true,
	Callback = function()
		local name = profileDropdown:Get()
		Library:ResetConfig()
		profileDropdown:Set(name, true)
		Window:Notify({ Title = "Config", Text = "All settings reset to defaults.", Duration = 3 })
	end,
})

-- Переводы для новых подписей.
for key, value in pairs({
	Settings = "Настройки",
	Models = "Модели",
	["Enemy Chams"] = "Чамсы врагов",
	["Team Chams"] = "Чамсы союзников",
	["Local Chams"] = "Свои чамсы",
	["Weapon Chams"] = "Чамсы оружия",
	["Hand Chams"] = "Чамсы рук",
	["Hidden Color"] = "Цвет за стеной",
	Material = "Материал",
	Transparency = "Прозрачность",
	HUD = "Интерфейс",
	["World ESP"] = "ESP мира",
	["Override FOV"] = "Свой FOV",
	Value = "Значение",
	["Override Aspect Ratio"] = "Своё соотношение сторон",
	Scaling = "Масштабирование",
	["Disable Landing Bob"] = "Без тряски при приземлении",
	["Scale (x1)"] = "Масштаб (x1)",
	["Scale (x2)"] = "Масштаб (x2)",
	["Instant Scope"] = "Мгновенный прицел",
	["Show Viewmodel"] = "Показывать руки",
	["Override Position"] = "Своя позиция",
	["Override Angles"] = "Свои углы",
	["Override Modifiers"] = "Свои модификаторы",
	Bobbing = "Покачивание",
	["Angles Sway"] = "Раскачивание",
	["Velocity Sway"] = "Инерция",
	["In Air Offset"] = "Смещение в прыжке",
	["Force Third Person"] = "Вид от третьего лица",
	Disablers = "Отключать",
	Distance = "Дистанция",
	["Disable Overhead"] = "Скрыть над головой",
	["Unlock Spectating"] = "Свободное наблюдение",
	["Visual Recoil"] = "Визуальная отдача",
	Radar = "Радар",
	["Preserve Killfeed"] = "Сохранять килфид",
	["Inaccuracy Overlay"] = "Индикатор разброса",
	["Scope Overlay"] = "Оверлей прицела",
	["Reveal Money"] = "Показывать деньги",
	Equipment = "Снаряжение",
	Default = "По умолчанию",
	["While Scoped"] = "В прицеле",
	Penetration = "Пробитие",
	["Colorize Effects"] = "Цвет эффектов",
	["Bomb Indicator"] = "Индикатор бомбы",
	["Defuse Indicator"] = "Индикатор разминирования",
	Defuser = "Дефузер",
	["Bomb Defused"] = "Бомба обезврежена",
	Weapons = "Оружие",
	["Rescue Indicator"] = "Индикатор спасения",
	["Smoke Radius"] = "Радиус дыма",
	["Molotov Radius"] = "Радиус молотова",
	["Colorize Smoke"] = "Цвет дыма",
	["Colorize Molotov"] = "Цвет молотова",
	["Colorize Explosion"] = "Цвет взрыва",
	Exponent = "Экспонента",
	["Thrown Grenades"] = "Брошенные гранаты",
	["Pin Pulled Only"] = "Только с выдернутой чекой",
	["Grenade Proximity Warnings"] = "Предупреждение о гранатах",
	["Log Events"] = "Журнал событий",
	["Hit Chance Override"] = "Свой шанс попадания",
	["Min Damage Override"] = "Свой мин. урон",
	["Show Value"] = "Показывать значение",
	Ragdolls = "Рэгдоллы",
	Gravity = "Гравитация",
	Friction = "Трение",
	Ambience = "Атмосфера",
	["Night Mode"] = "Ночной режим",
	Brightness = "Яркость",
	Fog = "Туман",
	["Fog Distance"] = "Дальность тумана",
	Skybox = "Небо",
	["Ambient Color"] = "Цвет окружения",
	["Bullet Tracers"] = "Трассеры",
	["Bullet Impacts"] = "Следы попаданий",
	["2D Marker"] = "2D маркер",
	["3D Marker"] = "3D маркер",
	["Damage Marker"] = "Маркер урона",
	Primary = "Основное",
	Secondary = "Пистолет",
	Knife = "Нож",
	Taser = "Тейзер",
	Armor = "Броня",
	["Flashbang Effect"] = "Эффект флешки",
	["Smoke Rendering"] = "Отрисовка дыма",
	["First Person Legs"] = "Ноги от первого лица",
	["Carried Hostage"] = "Переносимый заложник",
	["Post Processing"] = "Постобработка",
	["Team Intro"] = "Заставка команды",
	["Water Effects"] = "Эффекты воды",
	["Blood Effects"] = "Эффекты крови",
	Decals = "Декали",
}) do
	RU[key] = value
end
-- переприменить язык: подписи, созданные до добавления ключей, тоже переведутся
Library:SetLanguage(Library.Settings.Language)

for key, value in pairs({
	Config = "Конфиг",
	["All settings reset to defaults."] = "Все настройки сброшены.",
	["Overhead Tags"] = "Значки над головой",
	["Player List Tags"] = "Значки в списке игроков",
}) do
	RU[key] = value
end

Window:Notify({
	Title = "Nocturne",
	Text = "Menu loaded. Press " .. Window.ToggleKey.Name .. " to hide or show it.",
	Duration = 5,
})
