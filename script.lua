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

-- Все вкладки создаём сразу: так их порядок в сайдбаре не зависит от порядка блоков ниже.
local Tabs = {}
do
	for _, item in ipairs({
		{ category = "Aimbot" },
		{ "Rage", "crosshair" },
		{ "Legit", "target" },
		{ category = "Common" },
		{ "Visuals", "eye" },
		{ "Inventory", "shirt" },
		{ "Miscellaneous", "gear" },
		{ "Settings", "sliders" },
		{ category = "Extras" },
		{ "Camera", "monitor" },
		{ "Graphics", "palette" },
		{ "Character", "user" },
		{ "HUD", "list" },
		{ "Audio", "bars" },
		{ "Social", "globe" },
		{ "Tools", "terminal" },
		{ "Shortcuts", "keyboard" },
	}) do
		if item.category then
			Window:AddCategory(item.category)
		else
			Tabs[item[1]] = Window:AddTab({ Name = item[1], Icon = item[2] })
		end
	end
end

----------------------------------------------------------------------
-- AIMBOT
----------------------------------------------------------------------

------------------------------- Rage ---------------------------------
local Rage = Tabs["Rage"]

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
local Legit = Tabs["Legit"]

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

------------------------------ Visuals -------------------------------
-- Вкладка Visuals собирается ближе к концу файла (блок VISUALS): ей нужны Util и связь с сервером игры.

----------------------------- Inventory ------------------------------
-- Своя модель персонажа: внешний вид другого игрока Roblox ставится на персонажа ЛОКАЛЬНО.
-- С включённой Synchronization модель видят и другие пользователи скрипта (у себя, тоже локально),
-- а вы видите их модели. Обычные игроки видят настоящие аватары.
local Inventory = Tabs["Inventory"]

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
local Misc = Tabs["Miscellaneous"]

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

-------------------------------- VIEW / HUD / WORLD ---------------------
-- Рабочие локальные функции: меняется только то, что видите вы.
-- Всё, что меню меняет, запоминается и возвращается при выключении и при Unload.
do
	local RunService = game:GetService("RunService")
	local Lighting = game:GetService("Lighting")
	local StarterGui = game:GetService("StarterGui")
	local localPlayer = game:GetService("Players").LocalPlayer

	local function camera()
		return workspace.CurrentCamera
	end

	-- исходные значения свойств Lighting, которые мы трогали: [свойство] = значение
	local savedLighting = {}
	local function setLighting(prop, value)
		if savedLighting[prop] == nil then
			savedLighting[prop] = Lighting[prop]
		end
		if Lighting[prop] ~= value then
			Lighting[prop] = value
		end
	end
	local function restoreLighting(prop)
		if savedLighting[prop] ~= nil then
			pcall(function()
				Lighting[prop] = savedLighting[prop]
			end)
			savedLighting[prop] = nil
		end
	end

	------------------------------ камера ------------------------------
	local view = {
		fov = false,
		fovValue = 90,
		fovSaved = nil,
		stretch = false,
		stretchScale = 0.75,
		third = false,
		thirdDistance = 12,
		thirdSaved = nil,
		zoom = false, -- пока зажата клавиша зума
		zoomFov = 25,
		zoomSaved = nil,
	}

	-- Зум по удержанию клавиши (как в OptiFine).
	local function setZoom(active)
		local cam = camera()
		if active and not view.zoom then
			view.zoomSavedFov = cam and cam.FieldOfView
		elseif not active and view.zoom and not view.fov and cam and view.zoomSavedFov then
			cam.FieldOfView = view.zoomSavedFov
		end
		view.zoom = active
	end

	-- Цветокоррекция: свой ColorCorrectionEffect в камере.
	local color = {
		enabled = false,
		brightness = 0,
		contrast = 0.1,
		saturation = 0.2,
		tint = Color3.new(1, 1, 1),
		effect = nil,
	}
	local function applyColor()
		local cam = camera()
		if color.enabled and cam then
			if not color.effect or color.effect.Parent ~= cam then
				if color.effect then
					color.effect:Destroy()
				end
				color.effect = Instance.new("ColorCorrectionEffect")
				color.effect.Name = "NocturneColor"
				color.effect.Parent = cam
			end
			color.effect.Brightness = color.brightness
			color.effect.Contrast = color.contrast
			color.effect.Saturation = color.saturation
			color.effect.TintColor = color.tint
			color.effect.Enabled = true
		elseif color.effect then
			color.effect:Destroy()
			color.effect = nil
		end
	end

	local RENDER_NAME = "NocturneView_" .. tostring(math.random(1, 1e6))
	RunService:BindToRenderStep(RENDER_NAME, Enum.RenderPriority.Camera.Value + 1, function()
		local cam = camera()
		if not cam then
			return
		end
		if view.zoom then
			cam.FieldOfView = view.zoomFov
		elseif view.fov then
			cam.FieldOfView = view.fovValue
		end
		-- «растянутый экран»: сжимаем картинку по вертикали
		if view.stretch then
			local s = view.stretchScale
			cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, s, 0, 0, 0, 1)
		end
	end)

	local function setFov(enabled)
		local cam = camera()
		if enabled and not view.fov and cam then
			view.fovSaved = cam.FieldOfView
		elseif not enabled and view.fov and cam and view.fovSaved then
			cam.FieldOfView = view.fovSaved
			view.fovSaved = nil
		end
		view.fov = enabled
	end

	local function applyThirdPerson()
		if view.third then
			if not view.thirdSaved then
				view.thirdSaved = {
					mode = localPlayer.CameraMode,
					min = localPlayer.CameraMinZoomDistance,
					max = localPlayer.CameraMaxZoomDistance,
				}
			end
			localPlayer.CameraMode = Enum.CameraMode.Classic
			-- сначала максимум, потом минимум: минимум не может быть больше максимума
			localPlayer.CameraMaxZoomDistance = math.max(view.thirdDistance, view.thirdSaved.max)
			localPlayer.CameraMinZoomDistance = view.thirdDistance
		elseif view.thirdSaved then
			localPlayer.CameraMinZoomDistance = view.thirdSaved.min
			localPlayer.CameraMaxZoomDistance = view.thirdSaved.max
			localPlayer.CameraMode = view.thirdSaved.mode
			view.thirdSaved = nil
		end
	end

	------------------------------ прицел ------------------------------
	local cross = {
		enabled = false,
		color = Color3.fromRGB(120, 255, 140),
		style = "Cross",
		size = 8,
		gap = 4,
		thickness = 2,
		outline = true,
		dot = false,
	}
	local crossFrame = Instance.new("Frame")
	crossFrame.Name = "NocturneCrosshair"
	crossFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	crossFrame.Position = UDim2.fromScale(0.5, 0.5)
	crossFrame.Size = UDim2.fromOffset(0, 0)
	crossFrame.BackgroundTransparency = 1
	crossFrame.Visible = false
	crossFrame.Parent = Window.widgetLayer

	local function crossPart(x, y, w, h, round)
		local part = Instance.new("Frame")
		part.AnchorPoint = Vector2.new(0.5, 0.5)
		part.Position = UDim2.fromOffset(x, y)
		part.Size = UDim2.fromOffset(w, h)
		part.BackgroundColor3 = cross.color
		part.BorderSizePixel = 0
		if round then
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(1, 0)
			c.Parent = part
		end
		if cross.outline then
			local outline = Instance.new("UIStroke")
			outline.Color = Color3.new(0, 0, 0)
			outline.Thickness = 1
			outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			outline.Parent = part
		end
		part.Parent = crossFrame
		return part
	end

	local function rebuildCrosshair()
		crossFrame:ClearAllChildren()
		crossFrame.Visible = cross.enabled
		if not cross.enabled then
			return
		end
		local size, gap, thick = cross.size, cross.gap, cross.thickness
		local offset = gap + size / 2
		if cross.style == "Cross" or cross.style == "T-Shape" then
			if cross.style == "Cross" then
				crossPart(0, -offset, thick, size)
			end
			crossPart(0, offset, thick, size)
			crossPart(-offset, 0, size, thick)
			crossPart(offset, 0, size, thick)
		elseif cross.style == "Circle" then
			local ring = Instance.new("Frame")
			ring.AnchorPoint = Vector2.new(0.5, 0.5)
			ring.Size = UDim2.fromOffset(gap * 2 + size, gap * 2 + size)
			ring.BackgroundTransparency = 1
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(1, 0)
			c.Parent = ring
			local line = Instance.new("UIStroke")
			line.Color = cross.color
			line.Thickness = thick
			line.Parent = ring
			ring.Parent = crossFrame
		end
		if cross.dot or cross.style == "Dot" then
			crossPart(0, 0, thick + 2, thick + 2, true)
		end
	end

	--------------------------- интерфейс Roblox ---------------------------
	local CORE_GUI = {
		Chat = Enum.CoreGuiType.Chat,
		["Player List"] = Enum.CoreGuiType.PlayerList,
		Backpack = Enum.CoreGuiType.Backpack,
		Health = Enum.CoreGuiType.Health,
		Emotes = Enum.CoreGuiType.EmotesMenu,
	}
	local coreOriginal = {}
	for name, kind in pairs(CORE_GUI) do
		local ok, enabled = pcall(function()
			return StarterGui:GetCoreGuiEnabled(kind)
		end)
		coreOriginal[name] = not ok or enabled
	end
	local hiddenCore = {}
	local function applyCoreGui()
		for name, kind in pairs(CORE_GUI) do
			pcall(function()
				StarterGui:SetCoreGuiEnabled(kind, coreOriginal[name] and not hiddenCore[name])
			end)
		end
	end

	------------------------------ атмосфера ------------------------------
	local amb = {
		time = false,
		timeValue = 14,
		bright = false,
		brightValue = 2,
		ambient = false,
		ambientColor = Color3.fromRGB(140, 140, 160),
		fog = false,
		fogColor = Color3.fromRGB(150, 160, 190),
		fogDistance = 500,
	}
	local savedAtmosphere = nil -- { object, density, color }

	local function applyAmbience()
		if amb.time then
			setLighting("ClockTime", amb.timeValue)
		else
			restoreLighting("ClockTime")
		end
		if amb.bright then
			setLighting("Brightness", amb.brightValue)
		else
			restoreLighting("Brightness")
		end
		if amb.ambient then
			setLighting("Ambient", amb.ambientColor)
			setLighting("OutdoorAmbient", amb.ambientColor)
		else
			restoreLighting("Ambient")
			restoreLighting("OutdoorAmbient")
		end
		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
		if amb.fog then
			setLighting("FogColor", amb.fogColor)
			setLighting("FogStart", 0)
			setLighting("FogEnd", amb.fogDistance)
			-- если в игре есть Atmosphere, обычный туман не работает — настраиваем её
			if atmosphere then
				if not savedAtmosphere or savedAtmosphere.object ~= atmosphere then
					savedAtmosphere = { object = atmosphere, density = atmosphere.Density, color = atmosphere.Color }
				end
				atmosphere.Color = amb.fogColor
				atmosphere.Density = math.clamp(150 / amb.fogDistance, 0, 1)
			end
		else
			restoreLighting("FogColor")
			restoreLighting("FogStart")
			restoreLighting("FogEnd")
			if savedAtmosphere then
				if savedAtmosphere.object.Parent then
					savedAtmosphere.object.Density = savedAtmosphere.density
					savedAtmosphere.object.Color = savedAtmosphere.color
				end
				savedAtmosphere = nil
			end
		end
	end

	------------------------------ удаления ------------------------------
	local removals = { ["Post Processing"] = false, Shadows = false, ["Decals & Textures"] = false, ["Simple Materials"] = false }
	local changedMaterials = setmetatable({}, { __mode = "k" }) -- деталь -> { material, reflectance }
	local materialConnection = nil
	local disabledEffects = setmetatable({}, { __mode = "k" }) -- эффект -> было включено
	local hiddenDecals = setmetatable({}, { __mode = "k" }) -- декаль -> исходная прозрачность
	local decalConnection = nil

	local function isCharacterPart(item)
		local model = item:FindFirstAncestorWhichIsA("Model")
		return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
	end

	local function hideDecal(item)
		if (item:IsA("Decal") or item:IsA("Texture")) and hiddenDecals[item] == nil and not isCharacterPart(item) then
			hiddenDecals[item] = item.Transparency
			item.Transparency = 1
		end
	end

	local function applyRemovals()
		-- постобработка: Bloom, Blur, ColorCorrection, SunRays, DepthOfField
		if removals["Post Processing"] then
			for _, parent in ipairs({ Lighting, camera() }) do
				if parent then
					for _, effect in ipairs(parent:GetChildren()) do
						-- свои эффекты меню (имена «Nocturne…») не трогаем
						if effect:IsA("PostEffect") and effect.Enabled and string.sub(effect.Name, 1, 8) ~= "Nocturne" then
							disabledEffects[effect] = true
							effect.Enabled = false
						end
					end
				end
			end
		else
			for effect in pairs(disabledEffects) do
				if effect.Parent then
					effect.Enabled = true
				end
				disabledEffects[effect] = nil
			end
		end

		if removals.Shadows then
			setLighting("GlobalShadows", false)
		else
			restoreLighting("GlobalShadows")
		end

		if removals["Decals & Textures"] then
			if not decalConnection then
				for _, item in ipairs(workspace:GetDescendants()) do
					hideDecal(item)
				end
				decalConnection = workspace.DescendantAdded:Connect(hideDecal)
			end
		elseif decalConnection then
			decalConnection:Disconnect()
			decalConnection = nil
			for item, transparency in pairs(hiddenDecals) do
				if item.Parent then
					item.Transparency = transparency
				end
				hiddenDecals[item] = nil
			end
		end

		-- «картошка»: все детали мира из простого пластика без отражений (больше FPS)
		local function simplify(item)
			if item:IsA("BasePart") and changedMaterials[item] == nil and not isCharacterPart(item) then
				changedMaterials[item] = { item.Material, item.Reflectance }
				item.Material = Enum.Material.SmoothPlastic
				item.Reflectance = 0
			end
		end
		if removals["Simple Materials"] then
			if not materialConnection then
				for _, item in ipairs(workspace:GetDescendants()) do
					simplify(item)
				end
				materialConnection = workspace.DescendantAdded:Connect(simplify)
			end
		elseif materialConnection then
			materialConnection:Disconnect()
			materialConnection = nil
			for item, original in pairs(changedMaterials) do
				if item.Parent then
					item.Material = original[1]
					item.Reflectance = original[2]
				end
				changedMaterials[item] = nil
			end
		end
	end

	--------------------------- киношный режим ---------------------------
	-- Прячет весь интерфейс игры и Roblox (для скриншотов и видео). Меню остаётся.
	local cinematic = { enabled = false, hidden = {} }
	local function applyCinematic()
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		if cinematic.enabled then
			if playerGui then
				for _, gui in ipairs(playerGui:GetChildren()) do
					if gui:IsA("ScreenGui") and gui.Enabled and gui ~= Window.gui then
						cinematic.hidden[gui] = true
						gui.Enabled = false
					end
				end
			end
			pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
			end)
		elseif next(cinematic.hidden) ~= nil or cinematic.wasOn then
			for gui in pairs(cinematic.hidden) do
				if gui.Parent then
					gui.Enabled = true
				end
			end
			cinematic.hidden = {}
			cinematic.wasOn = false
			pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
			end)
			applyCoreGui()
		end
		if cinematic.enabled then
			cinematic.wasOn = true
		end
	end

	------------------------------ вейпоинты ------------------------------
	-- Метки в мире с названием и расстоянием (видны только вам). Без телепорта.
	local waypoints = { list = {}, visible = true, color = Color3.fromRGB(100, 133, 247) }
	local waypointFolder = Instance.new("Folder")
	waypointFolder.Name = "NocturneWaypoints"
	waypointFolder.Parent = Window.gui.Parent

	local function rootPart()
		local character = localPlayer.Character
		return character and character:FindFirstChild("HumanoidRootPart")
	end

	local function addWaypoint(name, position)
		local root = rootPart()
		if not (position or root) then
			return false
		end
		local attachment = Instance.new("Attachment")
		attachment.Name = "NocturneWaypoint"
		attachment.Position = position or root.Position
		attachment.Parent = workspace.Terrain

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.fromOffset(160, 40)
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.AlwaysOnTop = true
		billboard.LightInfluence = 0
		billboard.Adornee = attachment
		billboard.Enabled = waypoints.visible
		billboard.Parent = waypointFolder

		local dot = Instance.new("Frame")
		dot.AnchorPoint = Vector2.new(0.5, 1)
		dot.Position = UDim2.fromScale(0.5, 1)
		dot.Size = UDim2.fromOffset(10, 10)
		dot.BackgroundColor3 = waypoints.color
		dot.Parent = billboard
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = dot

		local text = Instance.new("TextLabel")
		text.BackgroundTransparency = 1
		text.Size = UDim2.new(1, 0, 1, -12)
		text.Font = Enum.Font.GothamBold
		text.TextSize = 13
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextStrokeTransparency = 0.5
		text.Text = name
		text.Parent = billboard

		table.insert(waypoints.list, { name = name, attachment = attachment, billboard = billboard, text = text, dot = dot })
		return true
	end
	-- для мини-карты (HUD) и общих меток пользователей скрипта (Social)
	Library.X = Library.X or {}
	Library.X.waypoints = waypoints
	Library.X.addWaypoint = addWaypoint

	local function clearWaypoints()
		for _, waypoint in ipairs(waypoints.list) do
			waypoint.attachment:Destroy()
			waypoint.billboard:Destroy()
		end
		waypoints.list = {}
	end

	local function updateWaypoints()
		local root = rootPart()
		for _, waypoint in ipairs(waypoints.list) do
			waypoint.billboard.Enabled = waypoints.visible
			waypoint.dot.BackgroundColor3 = waypoints.color
			if root then
				local distance = (waypoint.attachment.WorldPosition - root.Position).Magnitude
				waypoint.text.Text = string.format("%s  ·  %d", waypoint.name, math.floor(distance + 0.5))
			end
		end
	end

	-- Игры часто сами переставляют свет и камеру, поэтому регулярно применяем настройки заново.
	task.spawn(function()
		while Window.gui.Parent do
			pcall(applyAmbience)
			pcall(applyRemovals)
			pcall(applyColor)
			if cinematic.enabled then
				pcall(applyCinematic) -- новые окна игры тоже прячем
			end
			pcall(updateWaypoints)
			if view.third then
				pcall(applyThirdPerson)
			end
			task.wait(0.5)
		end
	end)

	-- При Unload всё возвращаем как было.
	Window:_track({
		Disconnect = function()
			pcall(function()
				RunService:UnbindFromRenderStep(RENDER_NAME)
			end)
			setZoom(false)
			setFov(false)
			view.stretch = false
			color.enabled = false
			pcall(applyColor)
			cinematic.enabled = false
			pcall(applyCinematic)
			clearWaypoints()
			waypointFolder:Destroy()
			view.third = false
			pcall(applyThirdPerson)
			if view.zoomSaved then
				localPlayer.CameraMaxZoomDistance = view.zoomSaved
				view.zoomSaved = nil
			end
			cross.enabled = false
			crossFrame:Destroy()
			hiddenCore = {}
			applyCoreGui()
			for key in pairs(amb) do
				if type(amb[key]) == "boolean" then
					amb[key] = false
				end
			end
			pcall(applyAmbience)
			for key in pairs(removals) do
				removals[key] = false
			end
			pcall(applyRemovals)
		end,
	})

	-------------------------------- VIEW --------------------------------
	local ViewSection = Misc:AddSection({ Name = "View", Side = "Left" })

	local viewOptions = ViewSection:AddSubmenu({ Name = "View Options" })
	local viewFov = viewOptions:AddGroup()
	viewFov:AddToggle({ Name = "Override FOV", Default = false, Callback = setFov })
	viewFov:AddSlider({
		Name = "Value",
		Min = 30,
		Max = 120,
		Default = 90,
		Suffix = "°",
		Callback = function(value)
			view.fovValue = value
		end,
	})
	local viewStretch = viewOptions:AddGroup()
	viewStretch:AddToggle({
		Name = "Stretch Screen",
		Default = false,
		Callback = function(value)
			view.stretch = value
		end,
	})
	viewStretch:AddSlider({
		Name = "Vertical Scale",
		Min = 50,
		Max = 100,
		Default = 75,
		Suffix = "%",
		Callback = function(value)
			view.stretchScale = value / 100
		end,
	})

	local perspective = ViewSection:AddSubmenu({ Name = "Perspective Options" })
	local perspectiveMain = perspective:AddGroup()
	perspectiveMain:AddToggle({
		Name = "Force Third Person",
		Default = false,
		Callback = function(value)
			view.third = value
			pcall(applyThirdPerson)
		end,
	}):AddKeybind({ Default = Enum.KeyCode.V })
	perspectiveMain:AddSlider({
		Name = "Distance",
		Min = 4,
		Max = 40,
		Default = 12,
		Callback = function(value)
			view.thirdDistance = value
			if view.third then
				pcall(applyThirdPerson)
			end
		end,
	})

	-- Зум: держите клавишу (по умолчанию G) — камера приближается.
	local zoom = ViewSection:AddToggle({
		Name = "Zoom",
		Icon = "crosshair",
		Default = false,
		Callback = setZoom,
	})
	zoom:AddKeybind({ Default = Enum.KeyCode.G, Mode = "Hold" })
	zoom:AddSettings("Zoom"):AddGroup():AddSlider({
		Name = "Zoom FOV",
		Min = 5,
		Max = 60,
		Default = 25,
		Suffix = "°",
		Callback = function(value)
			view.zoomFov = value
		end,
	})

	local colorPanel = ViewSection:AddSubmenu({ Name = "Color Correction", Icon = "palette" })
	local colorMain = colorPanel:AddGroup()
	colorMain:AddToggle({
		Name = "Enabled",
		Default = false,
		Callback = function(value)
			color.enabled = value
			applyColor()
		end,
	}):AddColorpicker({
		Name = "Tint",
		Default = color.tint,
		Callback = function(value)
			color.tint = value
			applyColor()
		end,
	})
	for _, setting in ipairs({
		{ "Brightness", "brightness", -50, 50, 0 },
		{ "Contrast", "contrast", -100, 100, 10 },
		{ "Saturation", "saturation", -100, 100, 20 },
	}) do
		colorMain:AddSlider({
			Name = setting[1],
			Min = setting[3],
			Max = setting[4],
			Default = setting[5],
			Suffix = "%",
			Callback = function(value)
				color[setting[2]] = value / 100
				applyColor()
			end,
		})
	end

	ViewSection:AddToggle({
		Name = "Unlock Zoom",
		Icon = "scale",
		Default = false,
		Callback = function(value)
			-- разрешить отдалять камеру дальше лимита игры
			if value then
				view.zoomSaved = view.zoomSaved or localPlayer.CameraMaxZoomDistance
				localPlayer.CameraMaxZoomDistance = 400
			elseif view.zoomSaved then
				localPlayer.CameraMaxZoomDistance = view.zoomSaved
				view.zoomSaved = nil
			end
		end,
	})

	-------------------------------- HUD ---------------------------------
	local Hud = Misc:AddSection({ Name = "HUD", Side = "Right" })
	local crosshair = Hud:AddToggle({
		Name = "Custom Crosshair",
		Default = false,
		Callback = function(value)
			cross.enabled = value
			rebuildCrosshair()
		end,
	})
	crosshair:AddColorpicker({
		Default = cross.color,
		Callback = function(color)
			cross.color = color
			rebuildCrosshair()
		end,
	})
	local crossSettings = crosshair:AddSettings("Crosshair")
	local crossShape = crossSettings:AddGroup()
	crossShape:AddDropdown({
		Name = "Style",
		Options = { "Cross", "T-Shape", "Circle", "Dot" },
		Default = "Cross",
		Callback = function(style)
			cross.style = style
			rebuildCrosshair()
		end,
	})
	crossShape:AddSlider({
		Name = "Size",
		Min = 2,
		Max = 30,
		Default = 8,
		Callback = function(value)
			cross.size = value
			rebuildCrosshair()
		end,
	})
	crossShape:AddSlider({
		Name = "Gap",
		Min = 0,
		Max = 20,
		Default = 4,
		Callback = function(value)
			cross.gap = value
			rebuildCrosshair()
		end,
	})
	crossShape:AddSlider({
		Name = "Thickness",
		Min = 1,
		Max = 6,
		Default = 2,
		Callback = function(value)
			cross.thickness = value
			rebuildCrosshair()
		end,
	})
	local crossExtra = crossSettings:AddGroup()
	crossExtra:AddToggle({
		Name = "Outline",
		Default = true,
		Callback = function(value)
			cross.outline = value
			rebuildCrosshair()
		end,
	})
	crossExtra:AddToggle({
		Name = "Center Dot",
		Default = false,
		Callback = function(value)
			cross.dot = value
			rebuildCrosshair()
		end,
	})

	Hud:AddToggle({
		Name = "Cinematic Mode",
		Icon = "monitor",
		Default = false,
		Callback = function(value)
			cinematic.enabled = value
			applyCinematic()
		end,
	}):AddKeybind({ Default = Enum.KeyCode.F7 })

	Hud:AddDropdown({
		Name = "Hide Roblox UI",
		Multi = true,
		Options = { "Chat", "Player List", "Backpack", "Health", "Emotes" },
		Width = 130,
		Callback = function(selected)
			hiddenCore = {}
			for _, name in ipairs(selected) do
				hiddenCore[name] = true
			end
			applyCoreGui()
		end,
	})

	-------------------------------- WORLD -------------------------------
	local WorldSection = Misc:AddSection({ Name = "World", Side = "Left" })

	local ambience = WorldSection:AddSubmenu({ Name = "Ambience", Icon = "palette" })
	local ambTime = ambience:AddGroup()
	ambTime:AddToggle({
		Name = "Time of Day",
		Default = false,
		Callback = function(value)
			amb.time = value
			applyAmbience()
		end,
	})
	ambTime:AddSlider({
		Name = "Hour",
		Min = 0,
		Max = 24,
		Default = 14,
		Decimals = 1,
		Callback = function(value)
			amb.timeValue = value
		end,
	})
	local ambLight = ambience:AddGroup()
	ambLight:AddToggle({
		Name = "Brightness",
		Default = false,
		Callback = function(value)
			amb.bright = value
			applyAmbience()
		end,
	})
	ambLight:AddSlider({
		Name = "Value",
		Min = 0,
		Max = 10,
		Default = 2,
		Decimals = 1,
		Callback = function(value)
			amb.brightValue = value
		end,
	})
	ambLight:AddToggle({
		Name = "Ambient Color",
		Default = false,
		Callback = function(value)
			amb.ambient = value
			applyAmbience()
		end,
	}):AddColorpicker({
		Default = amb.ambientColor,
		Callback = function(color)
			amb.ambientColor = color
		end,
	})
	local ambFog = ambience:AddGroup()
	ambFog:AddToggle({
		Name = "Fog",
		Default = false,
		Callback = function(value)
			amb.fog = value
			applyAmbience()
		end,
	}):AddColorpicker({
		Default = amb.fogColor,
		Callback = function(color)
			amb.fogColor = color
		end,
	})
	ambFog:AddSlider({
		Name = "Fog Distance",
		Min = 50,
		Max = 2000,
		Default = 500,
		Callback = function(value)
			amb.fogDistance = value
		end,
	})

	local removalsPanel = WorldSection:AddSubmenu({ Name = "Removals", Icon = "info" })
	removalsPanel:AddGroup():AddChecklist({
		Options = { "Post Processing", "Shadows", "Decals & Textures", "Simple Materials" },
		Callback = function(selected)
			for key in pairs(removals) do
				removals[key] = false
			end
			for _, name in ipairs(selected) do
				removals[name] = true
			end
			applyRemovals()
		end,
	})

	local waypointPanel = WorldSection:AddSubmenu({ Name = "Waypoints", Icon = "crosshair" })
	local waypointMain = waypointPanel:AddGroup()
	waypointMain:AddToggle({
		Name = "Show Waypoints",
		Default = true,
		Callback = function(value)
			waypoints.visible = value
		end,
	}):AddColorpicker({
		Default = waypoints.color,
		Callback = function(value)
			waypoints.color = value
		end,
	})
	local waypointName = waypointMain:AddTextbox({ Name = "Name", Placeholder = "Waypoint", Width = 120 })
	local waypointActions = waypointPanel:AddGroup()
	waypointActions:AddButton({
		Name = "Add Here",
		Callback = function()
			local name = waypointName:Get()
			if name == "" then
				name = "Waypoint " .. (#waypoints.list + 1)
			end
			if addWaypoint(name) then
				Window:Notify({ Title = "Waypoints", Text = "Waypoint added: " .. name, Duration = 3 })
			end
		end,
	})
	waypointActions:AddButton({ Name = "Clear All", Danger = true, Callback = clearWaypoints })
end

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

-- Производительность и сервер.
do
	local localPlayer = game:GetService("Players").LocalPlayer

	local performance = MiscSection:AddSubmenu({ Name = "Performance", Icon = "monitor" })
	local fpsGroup = performance:AddGroup()
	local fpsState = { enabled = false, value = 144 }
	-- setfpscap есть только у инжекторов
	local function applyFpsCap()
		if type(setfpscap) ~= "function" then
			return false
		end
		pcall(setfpscap, fpsState.enabled and fpsState.value or 60)
		return true
	end
	fpsGroup:AddToggle({
		Name = "FPS Cap",
		Default = false,
		Callback = function(value)
			fpsState.enabled = value
			if not applyFpsCap() and value then
				Window:Notify({ Title = "Performance", Text = "This executor has no setfpscap.", Duration = 3 })
			end
		end,
	})
	fpsGroup:AddSlider({
		Name = "Max FPS",
		Min = 30,
		Max = 360,
		Default = 144,
		Callback = function(value)
			fpsState.value = value
			if fpsState.enabled then
				applyFpsCap()
			end
		end,
	})

	-- Anti-AFK: Roblox кикает через 20 минут бездействия; при сигнале простоя «шевелим» ввод.
	local antiAfk = false
	Window:_track(localPlayer.Idled:Connect(function()
		if not antiAfk then
			return
		end
		pcall(function()
			local virtualUser = game:GetService("VirtualUser")
			virtualUser:CaptureController()
			virtualUser:ClickButton2(Vector2.new())
		end)
	end))
	performance:AddGroup():AddToggle({
		Name = "Anti-AFK",
		Default = false,
		Callback = function(value)
			antiAfk = value
		end,
	})

	Window:_track({
		Disconnect = function()
			if fpsState.enabled then
				fpsState.enabled = false
				applyFpsCap()
			end
		end,
	})

end

for key, value in pairs({
	World = "Мир",
	["Stretch Screen"] = "Растянуть экран",
	["Vertical Scale"] = "Масштаб по вертикали",
	["Unlock Zoom"] = "Снять лимит отдаления",
	["Custom Crosshair"] = "Свой прицел",
	Crosshair = "Прицел",
	Size = "Размер",
	Gap = "Отступ",
	Thickness = "Толщина",
	Outline = "Обводка",
	["Center Dot"] = "Точка в центре",
	["Hide Roblox UI"] = "Скрыть интерфейс Roblox",
	["Time of Day"] = "Время суток",
	Hour = "Час",
	["Ambient Color"] = "Цвет окружения",
	Shadows = "Тени",
	["Decals & Textures"] = "Декали и текстуры",
	Performance = "Производительность",
	["FPS Cap"] = "Ограничение FPS",
	["Max FPS"] = "Макс. FPS",
	["Anti-AFK"] = "Анти-АФК",
	Server = "Сервер",
	["Rejoin Server"] = "Перезайти на сервер",
	["Copy Server ID"] = "Скопировать ID сервера",
	["Rejoining..."] = "Перезаход...",
	["Rejoin failed."] = "Не удалось перезайти.",
	["Server ID copied."] = "ID сервера скопирован.",
	["This executor has no setfpscap."] = "У инжектора нет setfpscap.",
	["This executor has no setclipboard."] = "У инжектора нет setclipboard.",
	Zoom = "Зум",
	["Zoom FOV"] = "FOV зума",
	["Color Correction"] = "Цветокоррекция",
	Contrast = "Контраст",
	Saturation = "Насыщенность",
	["Cinematic Mode"] = "Киношный режим",
	["Simple Materials"] = "Простые материалы",
	Waypoints = "Метки",
	["Show Waypoints"] = "Показывать метки",
	["Add Here"] = "Поставить здесь",
	["Clear All"] = "Удалить все",
	Waypoint = "Метка",
	["Server Hop"] = "Другой сервер",
	["Join Smallest Server"] = "Самый пустой сервер",
	["Auto Rejoin"] = "Автоперезаход",
	["Copy Game Link"] = "Скопировать ссылку на игру",
	["Searching for a server..."] = "Ищу сервер...",
	["Could not get the server list."] = "Не удалось получить список серверов.",
	["No other servers found."] = "Других серверов не найдено.",
	["Game link copied."] = "Ссылка скопирована.",
}) do
	RU[key] = value
end

------------------------------ Settings ------------------------------
-- То, что раньше было в Miscellaneous: движение, меню, конфиги.
local SettingsTab = Tabs["Settings"]

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

-- Экспорт/импорт настроек строкой — чтобы поделиться с другом.
do
	local HttpService = game:GetService("HttpService")
	Config:AddButton({
		Name = "Copy Config",
		Callback = function()
			if type(setclipboard) ~= "function" then
				Window:Notify({ Title = "Config", Text = "This executor has no setclipboard.", Duration = 3 })
				return
			end
			pcall(setclipboard, HttpService:JSONEncode(Library:GetConfig()))
			Window:Notify({ Title = "Config", Text = "Config copied to clipboard.", Duration = 3 })
		end,
	})
	local importBox = Config:AddTextbox({ Name = "Import", Placeholder = "Paste config", Width = 150 })
	Config:AddButton({
		Name = "Apply Imported",
		Callback = function()
			local ok, data = pcall(function()
				return HttpService:JSONDecode(importBox:Get())
			end)
			if ok and type(data) == "table" then
				Library:ApplyConfig(data)
				Window:Notify({ Title = "Config", Text = "Config imported.", Duration = 3 })
			else
				Window:Notify({ Title = "Config", Text = "This is not a valid config.", Duration = 3 })
			end
		end,
	})
	for key, value in pairs({
		["Copy Config"] = "Скопировать конфиг",
		Import = "Импорт",
		["Paste config"] = "Вставьте конфиг",
		["Apply Imported"] = "Применить импорт",
		["Config copied to clipboard."] = "Конфиг скопирован.",
		["Config imported."] = "Конфиг импортирован.",
		["This is not a valid config."] = "Это не конфиг.",
	}) do
		RU[key] = value
	end
end

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

----------------------------------------------------------------------
-- EXTRAS: вкладки Camera, Graphics, Character, HUD, Audio, Social, Tools.
-- Всё локальное (видите только вы), кроме явных отправок в чат и событий синхронизации.
-- При выключении и Unload всё возвращается как было.
----------------------------------------------------------------------

-- Общие помощники для блоков Extras.
local Util = {}
do
	local RunService = game:GetService("RunService")
	local HttpService = game:GetService("HttpService")
	Util.player = game:GetService("Players").LocalPlayer
	Util.SCRIPT_URL = "https://raw.githubusercontent.com/DoFinnx/DoFinnx/refs/heads/main/script.lua"

	function Util.notify(title, text, duration)
		Window:Notify({ Title = title, Text = text, Duration = duration or 3 })
	end
	function Util.char()
		return Util.player.Character
	end
	function Util.root()
		local char = Util.char()
		return char and char:FindFirstChild("HumanoidRootPart")
	end
	function Util.humanoid()
		local char = Util.char()
		return char and char:FindFirstChildOfClass("Humanoid")
	end
	function Util.camera()
		return workspace.CurrentCamera
	end
	function Util.alive()
		return Window.gui.Parent ~= nil
	end
	-- функция выполнится при Unload
	function Util.onUnload(fn)
		Window:_track({
			Disconnect = function()
				pcall(fn)
			end,
		})
	end
	function Util.track(connection)
		return Window:_track(connection)
	end
	-- цикл, который сам остановится при Unload
	function Util.loop(interval, fn)
		task.spawn(function()
			while Util.alive() do
				pcall(fn)
				task.wait(interval)
			end
		end)
	end
	function Util.render(priority, fn)
		local name = "Nocturne_" .. HttpService:GenerateGUID(false)
		RunService:BindToRenderStep(name, priority, fn)
		Util.onUnload(function()
			RunService:UnbindFromRenderStep(name)
		end)
	end
	function Util.clock(seconds)
		seconds = math.max(0, math.floor(seconds))
		local h, m, s = math.floor(seconds / 3600), math.floor(seconds % 3600 / 60), seconds % 60
		if h > 0 then
			return string.format("%d:%02d:%02d", h, m, s)
		end
		return string.format("%02d:%02d", m, s)
	end
	function Util.clip(text)
		if type(setclipboard) == "function" then
			pcall(setclipboard, text)
			return true
		end
		Util.notify("Clipboard", "This executor has no setclipboard.")
		return false
	end
	function Util.tr(dictionary)
		for key, value in pairs(dictionary) do
			RU[key] = value
		end
	end
	function Util.json(value)
		return HttpService:JSONEncode(value)
	end
	function Util.unjson(text)
		local ok, value = pcall(function()
			return HttpService:JSONDecode(text)
		end)
		return ok and value or nil
	end
	-- чтение/запись маленьких файлов инжектора (если есть writefile/readfile)
	function Util.readFile(name, default)
		if type(isfile) ~= "function" or type(readfile) ~= "function" then
			return default
		end
		local ok, data = pcall(function()
			return isfile(name) and Util.unjson(readfile(name)) or nil
		end)
		return ok and data or default
	end
	function Util.writeFile(name, value)
		if type(writefile) == "function" then
			pcall(writefile, name, Util.json(value))
			return true
		end
		return false
	end
	-- Запоминаем исходное значение свойства и меняем его; Util.restore(префикс) возвращает.
	local saved = {}
	function Util.set(key, object, prop, value)
		if saved[key] == nil then
			saved[key] = { object = object, prop = prop, value = object[prop] }
		end
		if object[prop] ~= value then
			object[prop] = value
		end
	end
	function Util.restore(prefix)
		for key, entry in pairs(saved) do
			if string.sub(key, 1, #prefix) == prefix then
				pcall(function()
					entry.object[entry.prop] = entry.value
				end)
				saved[key] = nil
			end
		end
	end
	Util.onUnload(function()
		Util.restore("")
	end)
	-- найти элемент меню по части пути конфига (например ">Removals" или "Toggle:Simple Water")
	function Util.findElement(pattern, kind)
		for key, element in pairs(Library.Elements) do
			if string.find(key, pattern, 1, true) and (not kind or element.Type == kind) then
				return element, key
			end
		end
		return nil
	end
	function Util.frame(props)
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		for key, value in pairs(props) do
			frame[key] = value
		end
		return frame
	end
	function Util.text(props)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.TextColor3 = Color3.fromRGB(226, 227, 233)
		label.TextSize = 13
		for key, value in pairs(props) do
			label[key] = value
		end
		return label
	end
	function Util.round(instance, radius)
		local c = Instance.new("UICorner")
		c.CornerRadius = radius or UDim.new(1, 0)
		c.Parent = instance
		return c
	end
	-- Эффект в камере/Lighting, который создаём сами (имя «Nocturne…», чтобы Removals его не трогал).
	local owned = {}
	function Util.effect(name, className, parent, enabled)
		local effect = owned[name]
		if enabled and parent then
			if not effect or effect.Parent ~= parent then
				if effect then
					effect:Destroy()
				end
				effect = Instance.new(className)
				effect.Name = "Nocturne" .. name
				effect.Parent = parent
				owned[name] = effect
			end
			return effect
		elseif effect then
			effect:Destroy()
			owned[name] = nil
		end
		return nil
	end
	Util.onUnload(function()
		for _, effect in pairs(owned) do
			effect:Destroy()
		end
	end)
	-- Плашка-виджет со строками текста (как Hotkeys/Spectators), entriesFn() -> { "строка", ... }
	function Util.textWidget(name, title, position, iconName, entriesFn)
		local widget = Window:_listWidget(name, title, position, iconName)
		widget.Visible = false
		function widget:_update(state)
			local ok, lines = pcall(entriesFn)
			local entries = {}
			for _, line in ipairs(ok and lines or {}) do
				table.insert(entries, { Name = tostring(line), Icon = "none" })
			end
			self:SetEntries(entries, state)
		end
		return widget
	end
	-- частицы над/вокруг камеры (погода, светлячки, лепестки)
	function Util.cameraEmitter(name)
		local part = Instance.new("Part")
		part.Name = "Nocturne" .. name
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = Vector3.new(60, 20, 60)
		part.Parent = workspace.CurrentCamera
		local emitter = Instance.new("ParticleEmitter")
		emitter.Enabled = false
		emitter.Parent = part
		Util.track(RunService.RenderStepped:Connect(function()
			local cam = workspace.CurrentCamera
			if cam and emitter.Enabled then
				-- высоту над камерой задаёт атрибут OffsetY (для дождя и снега выше)
				part.CFrame = CFrame.new(cam.CFrame.Position + Vector3.new(0, part:GetAttribute("OffsetY") or 4, 0))
			end
		end))
		Util.onUnload(function()
			part:Destroy()
		end)
		return emitter
	end
end

------------------------------ CAMERA (1–10) ------------------------------
do
	local UserInputService = game:GetService("UserInputService")
	local CameraTab = Tabs["Camera"]

	local cam = {
		smooth = false,
		smoothness = 0.5,
		tiltLeft = false,
		tiltRight = false,
		tiltAngle = 12,
		tilt = 0,
		lockFov = false,
		lockedFov = nil,
		orbit = false,
		orbitMode = "Orbit",
		orbitSpeed = 20,
		orbitDistance = 14,
		orbitAngle = 0,
		lockHeight = false,
		height = 6,
		mirror = false,
		fisheye = false,
	}
	local smoothedRotation = nil

	Util.render(Enum.RenderPriority.Camera.Value + 3, function(dt)
		local camera = Util.camera()
		if not camera then
			return
		end
		local root = Util.root()

		-- 4–5: облёт персонажа (обычный или «дрон» — выше, дальше и с покачиванием)
		if cam.orbit and root then
			camera.CameraType = Enum.CameraType.Scriptable
			cam.orbitAngle += dt * math.rad(cam.orbitSpeed)
			local drone = cam.orbitMode == "Drone"
			local distance = drone and cam.orbitDistance * 1.8 or cam.orbitDistance
			local height = drone and 12 + math.sin(os.clock()) * 1.5 or 3
			local offset = Vector3.new(math.cos(cam.orbitAngle) * distance, height, math.sin(cam.orbitAngle) * distance)
			camera.CFrame = CFrame.lookAt(root.Position + offset, root.Position + Vector3.new(0, 1.5, 0))
		end

		-- 1: плавный поворот камеры
		if cam.smooth and not cam.orbit then
			local rotation = camera.CFrame - camera.CFrame.Position
			if not smoothedRotation then
				smoothedRotation = rotation
			end
			local alpha = 1 - math.exp(-dt * (2 + (1 - cam.smoothness) * 28))
			smoothedRotation = smoothedRotation:Lerp(rotation, alpha)
			camera.CFrame = CFrame.new(camera.CFrame.Position) * smoothedRotation
		else
			smoothedRotation = nil
		end

		-- 6: камера на постоянной высоте над персонажем
		if cam.lockHeight and root and not cam.orbit then
			local delta = (root.Position.Y + cam.height) - camera.CFrame.Position.Y
			camera.CFrame = camera.CFrame + Vector3.new(0, delta, 0)
		end

		-- 2: наклон
		local target = (cam.tiltLeft and -cam.tiltAngle or 0) + (cam.tiltRight and cam.tiltAngle or 0)
		cam.tilt += (target - cam.tilt) * math.clamp(dt * 10, 0, 1)
		if math.abs(cam.tilt) > 0.01 then
			camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, math.rad(cam.tilt))
		end

		-- 7: зеркальная картинка
		if cam.mirror then
			camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, 1)
		end

		-- «рыбий глаз» (свой FOV задаётся в Miscellaneous → View Options)
		if cam.fisheye then
			camera.FieldOfView = 120
		end
	end)

	local function stopOrbit()
		local camera = Util.camera()
		if camera then
			camera.CameraType = Enum.CameraType.Custom
		end
	end

	-- 8: виньетка для «рыбьего глаза»
	local fisheyeFrame = Util.frame({ Name = "NocturneFisheye", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, Parent = Window.widgetLayer })
	for _, rotation in ipairs({ 0, 90, 180, 270 }) do
		local edge = Util.frame({ BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), Parent = fisheyeFrame })
		local gradient = Instance.new("UIGradient")
		gradient.Rotation = rotation
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.35),
			NumberSequenceKeypoint.new(0.25, 1),
			NumberSequenceKeypoint.new(1, 1),
		})
		gradient.Parent = edge
	end

	-- 9: закладки ракурсов относительно персонажа
	local bookmarks = {}
	local viewingBookmark = false
	local function saveBookmark(slot)
		local camera, root = Util.camera(), Util.root()
		if camera and root then
			bookmarks[slot] = root.CFrame:ToObjectSpace(camera.CFrame)
			Util.notify("Camera", Library:Translate("Saved view") .. " " .. slot)
		end
	end
	local function viewBookmark(slot)
		local camera, root = Util.camera(), Util.root()
		if not (camera and root and bookmarks[slot]) then
			Util.notify("Camera", "No saved view in this slot.")
			return
		end
		viewingBookmark = true
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = root.CFrame:ToWorldSpace(bookmarks[slot])
	end

	-- 10: фото-режим — прячем меню и плашки, делаем снимок средствами Roblox
	local function takePhoto()
		local main, widgets = Window.main, Window.widgetLayer
		local wasMain, wasWidgets = main.Visible, widgets.Visible
		main.Visible, widgets.Visible = false, false
		Window:_closeAll()
		task.wait(0.15)
		local ok = pcall(function()
			game:GetService("CaptureService"):CaptureScreenshot(function() end)
		end)
		task.wait(0.4)
		main.Visible, widgets.Visible = wasMain, wasWidgets
		Util.notify("Camera", ok and "Screenshot saved to Roblox captures." or "Screenshots are not available here — use Print Screen.")
	end

	Util.onUnload(function()
		stopOrbit()
	end)

	-------------------------------- интерфейс --------------------------------
	local Motion = CameraTab:AddSection({ Name = "Motion", Side = "Left" })
	Motion:AddToggle({
		Name = "Smooth Camera",
		Default = false,
		Callback = function(v)
			cam.smooth = v
		end,
	}):AddSettings("Smooth Camera"):AddGroup():AddSlider({
		Name = "Smoothness",
		Min = 0,
		Max = 95,
		Default = 50,
		Suffix = "%",
		Callback = function(v)
			cam.smoothness = v / 100
		end,
	})
	Motion:AddToggle({
		Name = "Tilt Left",
		Default = false,
		Callback = function(v)
			cam.tiltLeft = v
		end,
	}):AddKeybind({ Default = Enum.KeyCode.Comma, Mode = "Hold" })
	Motion:AddToggle({
		Name = "Tilt Right",
		Default = false,
		Callback = function(v)
			cam.tiltRight = v
		end,
	}):AddKeybind({ Default = Enum.KeyCode.Period, Mode = "Hold" })
	Motion:AddSlider({
		Name = "Tilt Angle",
		Min = 2,
		Max = 30,
		Default = 12,
		Suffix = "°",
		Callback = function(v)
			cam.tiltAngle = v
		end,
	})
	Motion:AddToggle({
		Name = "Lock Height",
		Default = false,
		Callback = function(v)
			cam.lockHeight = v
		end,
	}):AddSettings("Lock Height"):AddGroup():AddSlider({
		Name = "Height",
		Min = 1,
		Max = 30,
		Default = 6,
		Callback = function(v)
			cam.height = v
		end,
	})

	local Lens = CameraTab:AddSection({ Name = "Lens", Side = "Left" })
	Lens:AddToggle({
		Name = "Fisheye",
		Default = false,
		Callback = function(v)
			cam.fisheye = v
			fisheyeFrame.Visible = v
			if not v then
				local camera = Util.camera()
				if camera then
					camera.FieldOfView = 70
				end
			end
		end,
	})
	Lens:AddToggle({
		Name = "Mirror View",
		Default = false,
		Callback = function(v)
			cam.mirror = v
		end,
	})

	local Cinematic = CameraTab:AddSection({ Name = "Cinematic", Side = "Right" })
	local orbitToggle = Cinematic:AddToggle({
		Name = "Orbit Camera",
		Icon = "globe",
		Default = false,
		Callback = function(v)
			cam.orbit = v
			if not v then
				stopOrbit()
			end
		end,
	})
	local orbitSettings = orbitToggle:AddSettings("Orbit Camera"):AddGroup()
	orbitSettings:AddDropdown({
		Name = "Mode",
		Options = { "Orbit", "Drone" },
		Default = "Orbit",
		Callback = function(v)
			cam.orbitMode = v
		end,
	})
	orbitSettings:AddSlider({
		Name = "Speed",
		Min = 2,
		Max = 90,
		Default = 20,
		Suffix = "°/s",
		Callback = function(v)
			cam.orbitSpeed = v
		end,
	})
	orbitSettings:AddSlider({
		Name = "Distance",
		Min = 5,
		Max = 40,
		Default = 14,
		Callback = function(v)
			cam.orbitDistance = v
		end,
	})
	Cinematic:AddButton({ Name = "Photo Mode", Callback = function()
		task.spawn(takePhoto)
	end })

	local Views = CameraTab:AddSection({ Name = "Saved Views", Side = "Right" })
	for slot = 1, 3 do
		Views:AddButton({ Name = Library:Translate("Save View") .. " " .. slot, Callback = function()
			saveBookmark(slot)
		end })
		Views:AddButton({ Name = Library:Translate("Go to View") .. " " .. slot, Callback = function()
			viewBookmark(slot)
		end })
	end
	Views:AddButton({ Name = "Return Camera", Callback = function()
		viewingBookmark = false
		if not cam.orbit then
			stopOrbit()
		end
	end })

	-- выйти из закладки при движении персонажа
	Util.track(UserInputService.InputBegan:Connect(function(input, processed)
		if viewingBookmark and not processed and input.KeyCode == Enum.KeyCode.W then
			viewingBookmark = false
			stopOrbit()
		end
	end))

	Util.tr({
		Extras = "Дополнительно",
		Camera = "Камера",
		Motion = "Движение",
		["Smooth Camera"] = "Плавная камера",
		Smoothness = "Плавность",
		["Tilt Left"] = "Наклон влево",
		["Tilt Right"] = "Наклон вправо",
		["Tilt Angle"] = "Угол наклона",
		["Lock Height"] = "Фиксировать высоту",
		Height = "Высота",
		Lens = "Объектив",
		["Lock FOV"] = "Зафиксировать FOV",
		Fisheye = "Рыбий глаз",
		["Mirror View"] = "Зеркальная картинка",
		Cinematic = "Кино",
		["Orbit Camera"] = "Облёт камерой",
		Speed = "Скорость",
		["Photo Mode"] = "Фото-режим",
		["Saved Views"] = "Сохранённые ракурсы",
		["Save View"] = "Сохранить ракурс",
		["Go to View"] = "Перейти к ракурсу",
		["Return Camera"] = "Вернуть камеру",
		["Saved view"] = "Ракурс сохранён",
		["No saved view in this slot."] = "В этом слоте нет ракурса.",
		["Screenshot saved to Roblox captures."] = "Скриншот сохранён в снимки Roblox.",
		["Screenshots are not available here — use Print Screen."] = "Снимки тут недоступны — используйте Print Screen.",
	})
end

------------------------------ GRAPHICS (11–36) ------------------------------
do
	local Lighting = game:GetService("Lighting")
	local RunService = game:GetService("RunService")
	local GraphicsTab = Tabs["Graphics"]

	local g = {
		filter = "None",
		vision = "None",
		blackWhite = false,
		exposure = 0,
		exposureOn = false,
		shadowSoftness = 0.2,
		envLight = 1,
		toneOn = false,
		grain = false,
		chromatic = false,
		letterbox = false,
		letterboxSize = 0.1,
		retro = false,
		sunSize = 21,
		moonSize = 11,
		stars = 3000,
		skyOn = false,
		rainbowSky = false,
		storm = false,
		aurora = false,
		haze = false,
		hazeAmount = 2,
		ambientParticles = "None",
	}

	local FILTERS = {
		Cyberpunk = { tint = Color3.fromRGB(255, 170, 255), saturation = 0.45, contrast = 0.2, brightness = 0 },
		Vintage = { tint = Color3.fromRGB(255, 230, 190), saturation = -0.4, contrast = -0.05, brightness = 0.03 },
		Anime = { tint = Color3.fromRGB(245, 245, 255), saturation = 0.6, contrast = 0.1, brightness = 0.04 },
		Horror = { tint = Color3.fromRGB(200, 215, 200), saturation = -0.6, contrast = 0.3, brightness = -0.08 },
		Winter = { tint = Color3.fromRGB(205, 230, 255), saturation = -0.2, contrast = 0.05, brightness = 0.04 },
		Desert = { tint = Color3.fromRGB(255, 215, 160), saturation = 0.15, contrast = 0.1, brightness = 0.02 },
		Warm = { tint = Color3.fromRGB(255, 225, 190), saturation = 0.1, contrast = 0.05, brightness = 0 },
		Cold = { tint = Color3.fromRGB(195, 220, 255), saturation = -0.05, contrast = 0.08, brightness = 0 },
		Noir = { tint = Color3.new(1, 1, 1), saturation = -1, contrast = 0.35, brightness = -0.03 },
		Sepia = { tint = Color3.fromRGB(255, 220, 170), saturation = -0.75, contrast = 0.1, brightness = 0.02 },
		Vivid = { tint = Color3.new(1, 1, 1), saturation = 0.5, contrast = 0.15, brightness = 0 },
		Dreamy = { tint = Color3.fromRGB(240, 215, 255), saturation = 0.15, contrast = -0.1, brightness = 0.05 },
	}
	local VISIONS = {
		["Night Vision"] = { tint = Color3.fromRGB(120, 255, 120), saturation = -1, contrast = 0.2, brightness = 0.25 },
		Thermal = { tint = Color3.fromRGB(255, 150, 60), saturation = -1, contrast = 0.6, brightness = 0.05 },
	}

	local function applyColor(name, preset)
		local camera = Util.camera()
		local effect = Util.effect(name, "ColorCorrectionEffect", camera, preset ~= nil)
		if effect and preset then
			effect.TintColor = preset.tint
			effect.Saturation = preset.saturation
			effect.Contrast = preset.contrast
			effect.Brightness = preset.brightness
		end
	end

	-- 13: зерно плёнки
	local grainFrame = Util.frame({ Name = "NocturneGrain", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, Parent = Window.widgetLayer })
	local grainDots = {}
	for i = 1, 80 do
		grainDots[i] = Util.frame({ BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.85, Size = UDim2.fromOffset(2, 2), Parent = grainFrame })
	end
	-- 14: цветные края («хроматическая аберрация»)
	local chromaFrame = Util.frame({ Name = "NocturneChroma", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, Parent = Window.widgetLayer })
	for _, side in ipairs({ { 0, Color3.fromRGB(255, 40, 60) }, { 180, Color3.fromRGB(40, 120, 255) } }) do
		local edge = Util.frame({ BackgroundColor3 = side[2], Size = UDim2.fromScale(1, 1), Parent = chromaFrame })
		local gradient = Instance.new("UIGradient")
		gradient.Rotation = side[1]
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.82),
			NumberSequenceKeypoint.new(0.12, 1),
			NumberSequenceKeypoint.new(1, 1),
		})
		gradient.Parent = edge
	end
	-- 15: кинополосы
	local barTop = Util.frame({ Name = "NocturneLetterbox", BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 0.1), Visible = false, Parent = Window.widgetLayer })
	local barBottom = Util.frame({ Name = "NocturneLetterbox", BackgroundColor3 = Color3.new(0, 0, 0), AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.fromScale(1, 0.1), Visible = false, Parent = Window.widgetLayer })
	-- 17: «ретро»: полосы развёртки
	local retroFrame = Util.frame({ Name = "NocturneRetro", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, Parent = Window.widgetLayer })
	for i = 0, 179 do
		Util.frame({ BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.78, Position = UDim2.fromScale(0, i / 180), Size = UDim2.new(1, 0, 0, 1), Parent = retroFrame })
	end

	Util.track(RunService.RenderStepped:Connect(function()
		if grainFrame.Visible then
			for _, dot in ipairs(grainDots) do
				dot.Position = UDim2.fromScale(math.random(), math.random())
				dot.BackgroundTransparency = 0.7 + math.random() * 0.25
			end
		end
	end))

	-- 22: гроза — вспышки молний
	local stormFlashUntil = 0
	local nextStrike = 0

	-- 25: частицы вокруг камеры
	local ambientEmitter = Util.cameraEmitter("Ambient")
	local AMBIENT = {
		Fireflies = { color = Color3.fromRGB(255, 240, 120), size = 0.25, rate = 30, speed = 1, light = 1, life = 4 },
		Petals = { color = Color3.fromRGB(255, 170, 200), size = 0.35, rate = 40, speed = 3, light = 0.2, life = 7 },
		Leaves = { color = Color3.fromRGB(230, 140, 60), size = 0.45, rate = 35, speed = 3, light = 0, life = 7 },
		Embers = { color = Color3.fromRGB(255, 110, 40), size = 0.18, rate = 60, speed = 4, light = 1, life = 3 },
		-- погода (раньше была отдельным списком в Misc)
		Snow = { color = Color3.new(1, 1, 1), size = 0.25, rate = 250, speed = 9, light = 0.4, life = 9, weather = true, spread = 25, gravity = -1, offset = 30 },
		Rain = { color = Color3.fromRGB(170, 190, 220), size = 0.07, rate = 700, speed = 90, light = 0.2, life = 1.1, weather = true, spread = 3, gravity = 0, offset = 30, streak = true },
	}
	local function applyAmbient()
		local preset = AMBIENT[g.ambientParticles]
		ambientEmitter.Enabled = preset ~= nil
		if preset then
			ambientEmitter.Color = ColorSequence.new(preset.color)
			ambientEmitter.Size = NumberSequence.new(preset.size)
			ambientEmitter.Rate = preset.rate
			ambientEmitter.Speed = NumberRange.new(preset.speed * 0.6, preset.speed)
			ambientEmitter.LightEmission = preset.light
			ambientEmitter.Lifetime = NumberRange.new(preset.life * 0.6, preset.life)
			ambientEmitter.Parent:SetAttribute("OffsetY", preset.offset or 4)
			if preset.weather then
				-- падает сверху вниз
				ambientEmitter.EmissionDirection = Enum.NormalId.Bottom
				ambientEmitter.SpreadAngle = Vector2.new(preset.spread, preset.spread)
				ambientEmitter.Acceleration = Vector3.new(0, preset.gravity, 0)
				ambientEmitter.RotSpeed = NumberRange.new(0, 0)
			else
				ambientEmitter.EmissionDirection = Enum.NormalId.Top
				ambientEmitter.SpreadAngle = Vector2.new(180, 180)
				ambientEmitter.Acceleration = Vector3.new(0, preset.speed > 2 and -0.6 or 0.2, 0)
				ambientEmitter.RotSpeed = NumberRange.new(-60, 60)
			end
			pcall(function()
				-- дождь вытягиваем в штрихи
				ambientEmitter.Squash = NumberSequence.new(preset.streak and -3 or 0)
				ambientEmitter.Orientation = preset.streak and Enum.ParticleOrientation.VelocityParallel or Enum.ParticleOrientation.FacingCamera
			end)
		end
	end

	local function getSky()
		local sky = Lighting:FindFirstChildOfClass("Sky")
		if not sky then
			sky = Util.effect("GraphicsSky", "Sky", Lighting, true)
		end
		return sky
	end
	local function getAtmosphere()
		return Lighting:FindFirstChildOfClass("Atmosphere") or Util.effect("GraphicsAtmosphere", "Atmosphere", Lighting, true)
	end

	local function applyAll()
		local camera = Util.camera()
		-- 11 / 16 / 18: фильтры, режимы видения, чёрно-белый
		applyColor("GraphicsFilter", FILTERS[g.filter])
		applyColor("GraphicsVision", VISIONS[g.vision])
		applyColor("GraphicsBW", g.blackWhite and { tint = Color3.new(1, 1, 1), saturation = -1, contrast = 0.1, brightness = 0 } or nil)
		applyColor("GraphicsRetro", g.retro and { tint = Color3.fromRGB(255, 240, 220), saturation = -0.3, contrast = 0.45, brightness = 0 } or nil)
		grainFrame.Visible = g.grain or g.vision == "Night Vision"
		retroFrame.Visible = g.retro
		chromaFrame.Visible = g.chromatic
		barTop.Visible, barBottom.Visible = g.letterbox, g.letterbox
		barTop.Size = UDim2.fromScale(1, g.letterboxSize)
		barBottom.Size = UDim2.fromScale(1, g.letterboxSize)

		-- 12 / 19: экспозиция, мягкость теней, свет окружения
		if g.toneOn then
			Util.set("gfx.Exposure", Lighting, "ExposureCompensation", g.exposure)
			Util.set("gfx.ShadowSoftness", Lighting, "ShadowSoftness", g.shadowSoftness)
			Util.set("gfx.EnvDiffuse", Lighting, "EnvironmentDiffuseScale", g.envLight)
			Util.set("gfx.EnvSpecular", Lighting, "EnvironmentSpecularScale", g.envLight)
		else
			Util.restore("gfx.")
		end

		-- 20: солнце, луна, звёзды
		if g.skyOn then
			local sky = getSky()
			Util.set("sky.SunSize", sky, "SunAngularSize", g.sunSize)
			Util.set("sky.MoonSize", sky, "MoonAngularSize", g.moonSize)
			Util.set("sky.Stars", sky, "StarCount", g.stars)
		else
			Util.restore("sky.")
		end

		-- 21 / 23 / 24: радужное небо, северное сияние, дымка
		if g.rainbowSky or g.aurora or g.haze then
			local atmosphere = getAtmosphere()
			if g.rainbowSky then
				Util.set("atm.Color", atmosphere, "Color", Color3.fromHSV((os.clock() / 10) % 1, 0.6, 1))
				Util.set("atm.Density", atmosphere, "Density", 0.3)
			elseif g.aurora then
				local t = os.clock() / 4
				Util.set("atm.Color", atmosphere, "Color", Color3.fromHSV(0.35 + math.sin(t) * 0.12, 0.8, 0.9))
				Util.set("atm.Decay", atmosphere, "Decay", Color3.fromRGB(80, 20, 140))
				Util.set("atm.Density", atmosphere, "Density", 0.3)
				Util.set("atm.Glare", atmosphere, "Glare", 3)
				Util.set("aur.Clock", Lighting, "ClockTime", 0)
				Util.set("aur.Stars", getSky(), "StarCount", 5000)
			end
			if g.haze then
				Util.set("atm.Haze", atmosphere, "Haze", g.hazeAmount)
				Util.set("atm.Offset", atmosphere, "Offset", 0.4)
			end
		else
			Util.restore("atm.")
		end
		if not g.aurora then
			Util.restore("aur.")
		end

		-- 22: гроза
		if g.storm then
			Util.set("storm.Brightness", Lighting, "Brightness", 0.6)
			Util.set("storm.Clock", Lighting, "ClockTime", 19.5)
			local now = os.clock()
			if now > nextStrike then
				nextStrike = now + math.random(4, 12)
				stormFlashUntil = now + 0.12
			end
			local flash = Util.effect("Lightning", "ColorCorrectionEffect", camera, now < stormFlashUntil)
			if flash then
				flash.Brightness = 0.6
				flash.TintColor = Color3.fromRGB(220, 230, 255)
			end
		else
			Util.restore("storm.")
			Util.effect("Lightning", "ColorCorrectionEffect", camera, false)
		end
	end

	-- молнии должны мелькать быстро, поэтому общий цикл частый
	Util.loop(0.05, applyAll)

	-------------------------------- интерфейс --------------------------------
	local Color = GraphicsTab:AddSection({ Name = "Color", Side = "Left" })
	Color:AddDropdown({
		Name = "Filter",
		Options = { "None", "Warm", "Cold", "Vivid", "Dreamy", "Noir", "Sepia", "Cyberpunk", "Vintage", "Anime", "Horror", "Winter", "Desert" },
		Default = "None",
		Width = 130,
		Callback = function(v)
			g.filter = v
		end,
	})
	Color:AddDropdown({
		Name = "Vision Mode",
		Options = { "None", "Night Vision", "Thermal" },
		Default = "None",
		Width = 130,
		Callback = function(v)
			g.vision = v
		end,
	})
	Color:AddToggle({
		Name = "Black & White",
		Default = false,
		Callback = function(v)
			g.blackWhite = v
		end,
	}):AddKeybind({ Default = Enum.KeyCode.F8 })
	local tone = Color:AddToggle({
		Name = "Tone & Shadows",
		Default = false,
		Callback = function(v)
			g.toneOn = v
		end,
	})
	local toneGroup = tone:AddSettings("Tone & Shadows"):AddGroup()
	toneGroup:AddSlider({ Name = "Exposure", Min = -30, Max = 30, Default = 0, Decimals = 0, Callback = function(v)
		g.exposure = v / 10
	end })
	toneGroup:AddSlider({ Name = "Shadow Softness", Min = 0, Max = 100, Default = 20, Suffix = "%", Callback = function(v)
		g.shadowSoftness = v / 100
	end })
	toneGroup:AddSlider({ Name = "Environment Light", Min = 0, Max = 100, Default = 100, Suffix = "%", Callback = function(v)
		g.envLight = v / 100
	end })

	local Overlays = GraphicsTab:AddSection({ Name = "Overlays", Side = "Left" })
	Overlays:AddToggle({ Name = "Film Grain", Default = false, Callback = function(v)
		g.grain = v
	end })
	Overlays:AddToggle({ Name = "Chromatic Edges", Default = false, Callback = function(v)
		g.chromatic = v
	end })
	Overlays:AddToggle({ Name = "Letterbox", Default = false, Callback = function(v)
		g.letterbox = v
	end }):AddSettings("Letterbox"):AddGroup():AddSlider({ Name = "Size", Min = 3, Max = 25, Default = 10, Suffix = "%", Callback = function(v)
		g.letterboxSize = v / 100
	end })
	Overlays:AddToggle({ Name = "Retro", Default = false, Callback = function(v)
		g.retro = v
	end })

	local SkySection = GraphicsTab:AddSection({ Name = "Sky", Side = "Right" })
	local skyToggle = SkySection:AddToggle({ Name = "Custom Sun & Stars", Default = false, Callback = function(v)
		g.skyOn = v
	end })
	local skyGroup = skyToggle:AddSettings("Custom Sun & Stars"):AddGroup()
	skyGroup:AddSlider({ Name = "Sun Size", Min = 1, Max = 60, Default = 21, Callback = function(v)
		g.sunSize = v
	end })
	skyGroup:AddSlider({ Name = "Moon Size", Min = 1, Max = 60, Default = 11, Callback = function(v)
		g.moonSize = v
	end })
	skyGroup:AddSlider({ Name = "Stars", Min = 0, Max = 10000, Default = 3000, Callback = function(v)
		g.stars = v
	end })
	SkySection:AddToggle({ Name = "Rainbow Sky", Default = false, Callback = function(v)
		g.rainbowSky = v
	end })
	SkySection:AddToggle({ Name = "Aurora", Default = false, Callback = function(v)
		g.aurora = v
	end })
	SkySection:AddToggle({ Name = "Thunderstorm", Default = false, Callback = function(v)
		g.storm = v
	end })
	SkySection:AddToggle({ Name = "Morning Haze", Default = false, Callback = function(v)
		g.haze = v
	end }):AddSettings("Morning Haze"):AddGroup():AddSlider({ Name = "Amount", Min = 0, Max = 10, Default = 2, Callback = function(v)
		g.hazeAmount = v
	end })
	SkySection:AddDropdown({
		Name = "Weather & Particles",
		Options = { "None", "Snow", "Rain", "Fireflies", "Petals", "Leaves", "Embers" },
		Default = "None",
		Width = 130,
		Callback = function(v)
			g.ambientParticles = v
			applyAmbient()
		end,
	})

	-------------------- мир и производительность (26–36) --------------------
	local perf = { hideDistant = false, distance = 400, pauseAnims = false, grayWorld = false, hideTrails = false, autoPotato = false, grid = false }
	local worldParts = setmetatable({}, { __mode = "k" }) -- кэш деталей мира (без персонажей)
	local function isCharacterPart(item)
		local model = item:FindFirstAncestorWhichIsA("Model")
		return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
	end
	local function cachePart(item)
		if item:IsA("BasePart") and not isCharacterPart(item) and not string.find(item.Name, "^Nocturne") then
			worldParts[item] = true
		end
	end
	task.spawn(function()
		for index, item in ipairs(workspace:GetDescendants()) do
			cachePart(item)
			if index % 5000 == 0 then
				task.wait()
			end
		end
	end)
	Util.track(workspace.DescendantAdded:Connect(cachePart))

	local hiddenDistant = setmetatable({}, { __mode = "k" })
	local grayed = setmetatable({}, { __mode = "k" })
	local hiddenTrails = setmetatable({}, { __mode = "k" })
	local pausedTracks = setmetatable({}, { __mode = "k" })

	local function applyWorld()
		local camera = Util.camera()
		local origin = camera and camera.CFrame.Position
		-- проходим по деталям только когда это нужно (на больших картах это тяжело)
		local needParts = perf.hideDistant or perf.grayWorld or next(hiddenDistant) ~= nil
		-- 27: скрывать далёкие детали (меньше рисовать — больше FPS)
		for part in pairs(needParts and worldParts or {}) do
			if part.Parent then
				local far = perf.hideDistant and origin and (part.Position - origin).Magnitude > perf.distance
				if far and not hiddenDistant[part] then
					hiddenDistant[part] = true
					part.LocalTransparencyModifier = 1
				elseif not far and hiddenDistant[part] then
					hiddenDistant[part] = nil
					part.LocalTransparencyModifier = 0
				end
				-- 29: серый мир
				if perf.grayWorld and grayed[part] == nil then
					grayed[part] = part.Color
					part.Color = Color3.fromRGB(140, 140, 145)
				end
			end
		end
		if not perf.grayWorld then
			for part, color in pairs(grayed) do
				if part.Parent then
					part.Color = color
				end
				grayed[part] = nil
			end
		end
		-- 30: следы и лучи (Trail, Beam)
		if perf.hideTrails then
			for _, item in ipairs(workspace:GetDescendants()) do
				if (item:IsA("Trail") or item:IsA("Beam")) and not string.find(item.Name, "^Nocturne") then
					if item.Enabled and not hiddenTrails[item] then
						hiddenTrails[item] = true
						item.Enabled = false
					end
				end
			end
		end
		if not perf.hideTrails then
			for item in pairs(hiddenTrails) do
				if item.Parent then
					item.Enabled = true
				end
				hiddenTrails[item] = nil
			end
		end
		-- 28: пауза анимаций мира (не персонажей)
		if perf.pauseAnims then
			for _, animator in ipairs(workspace:GetDescendants()) do
				if animator:IsA("Animator") and not isCharacterPart(animator) then
					for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
						if not pausedTracks[track] then
							pausedTracks[track] = track.Speed
							track:AdjustSpeed(0)
						end
					end
				end
			end
		else
			for track, speed in pairs(pausedTracks) do
				pcall(function()
					track:AdjustSpeed(speed)
				end)
				pausedTracks[track] = nil
			end
		end
	end
	Util.loop(1, applyWorld)

	-- 26: «картошка 2.0» — включает существующие удаления и простую воду одним переключателем
	local function setPotato(enabled)
		local removals = Util.findElement(">Removals", "Checklist")
		if removals then
			removals:Set(enabled and { "Post Processing", "Shadows", "Decals & Textures", "Simple Materials" } or {})
		end
		local water = Util.findElement("Toggle:Simple Water", "Toggle")
		if water then
			water:Set(enabled)
		end
		perf.hideTrails = enabled
	end

	-- 31: авто-экономия при низком FPS
	local lowSince, potatoAuto = nil, false
	local frames, lastCount = 0, os.clock()
	Util.track(RunService.RenderStepped:Connect(function()
		frames += 1
	end))
	Util.loop(1, function()
		local now = os.clock()
		local fps = frames / math.max(now - lastCount, 0.001)
		frames, lastCount = 0, now
		if not perf.autoPotato then
			lowSince = nil
			return
		end
		if fps < perf.fpsThreshold then
			lowSince = lowSince or now
			if not potatoAuto and now - lowSince > 5 then
				potatoAuto = true
				setPotato(true)
				Util.notify("Performance", "Low FPS — economy mode turned on.")
			end
		else
			lowSince = nil
		end
	end)
	perf.fpsThreshold = 30

	-- 33: сетка на земле вокруг персонажа
	local gridFolder = Instance.new("Folder")
	gridFolder.Name = "NocturneGrid"
	gridFolder.Parent = workspace.CurrentCamera
	local gridLines = {}
	local GRID_STEP, GRID_COUNT = 4, 12
	local function buildGrid()
		gridFolder:ClearAllChildren()
		gridLines = {}
		if not perf.grid then
			return
		end
		for i = -GRID_COUNT, GRID_COUNT do
			for axis = 1, 2 do
				local line = Instance.new("Part")
				line.Name = "NocturneGridLine"
				line.Anchored, line.CanCollide, line.CanQuery, line.CanTouch = true, false, false, false
				line.Material = Enum.Material.Neon
				line.Color = Color3.fromRGB(100, 133, 247)
				line.Transparency = 0.6
				line.Size = axis == 1 and Vector3.new(GRID_STEP * GRID_COUNT * 2, 0.05, 0.05) or Vector3.new(0.05, 0.05, GRID_STEP * GRID_COUNT * 2)
				line.Parent = gridFolder
				table.insert(gridLines, { part = line, axis = axis, index = i })
			end
		end
	end
	Util.loop(0.1, function()
		local root = Util.root()
		if not (perf.grid and root) then
			return
		end
		local base = Vector3.new(
			math.floor(root.Position.X / GRID_STEP + 0.5) * GRID_STEP,
			root.Position.Y - 3,
			math.floor(root.Position.Z / GRID_STEP + 0.5) * GRID_STEP
		)
		for _, line in ipairs(gridLines) do
			local offset = line.index * GRID_STEP
			line.part.Position = line.axis == 1 and base + Vector3.new(0, 0, offset) or base + Vector3.new(offset, 0, 0)
		end
	end)
	Util.onUnload(function()
		gridFolder:Destroy()
		perf.hideDistant, perf.grayWorld, perf.hideTrails, perf.pauseAnims = false, false, false, false
		applyWorld()
	end)

	local World = GraphicsTab:AddSection({ Name = "World & FPS", Side = "Right" })
	World:AddToggle({ Name = "Potato Mode", Icon = "chip", Default = false, Callback = setPotato })
	World:AddToggle({ Name = "Auto Economy", Default = false, Callback = function(v)
		perf.autoPotato = v
		potatoAuto = false
	end }):AddSettings("Auto Economy"):AddGroup():AddSlider({ Name = "FPS Below", Min = 10, Max = 60, Default = 30, Callback = function(v)
		perf.fpsThreshold = v
	end })
	World:AddToggle({ Name = "Hide Distant Parts", Default = false, Callback = function(v)
		perf.hideDistant = v
		applyWorld()
	end }):AddSettings("Hide Distant Parts"):AddGroup():AddSlider({ Name = "Distance", Min = 100, Max = 2000, Default = 400, Callback = function(v)
		perf.distance = v
	end })
	World:AddToggle({ Name = "Pause World Animations", Default = false, Callback = function(v)
		perf.pauseAnims = v
		applyWorld()
	end })
	World:AddToggle({ Name = "Gray World", Default = false, Callback = function(v)
		perf.grayWorld = v
		applyWorld()
	end })
	World:AddToggle({ Name = "Hide Trails & Beams", Default = false, Callback = function(v)
		perf.hideTrails = v
		applyWorld()
	end })
	World:AddToggle({ Name = "Ground Grid", Default = false, Callback = function(v)
		perf.grid = v
		buildGrid()
	end })

	Util.tr({
		Graphics = "Графика",
		Color = "Цвет",
		["Vision Mode"] = "Режим видения",
		["Black & White"] = "Чёрно-белый",
		["Tone & Shadows"] = "Тон и тени",
		Exposure = "Экспозиция",
		["Shadow Softness"] = "Мягкость теней",
		["Environment Light"] = "Свет окружения",
		Overlays = "Оверлеи",
		["Film Grain"] = "Зерно плёнки",
		["Chromatic Edges"] = "Цветные края",
		Letterbox = "Кинополосы",
		Retro = "Ретро",
		Sky = "Небо",
		["Custom Sun & Stars"] = "Солнце, луна и звёзды",
		["Sun Size"] = "Размер солнца",
		["Moon Size"] = "Размер луны",
		Stars = "Звёзды",
		["Rainbow Sky"] = "Радужное небо",
		Aurora = "Северное сияние",
		Thunderstorm = "Гроза",
		["Morning Haze"] = "Утренняя дымка",
		Amount = "Сила",
		["Ambient Particles"] = "Частицы вокруг",
		["World & FPS"] = "Мир и FPS",
		["Potato Mode"] = "Режим картошки",
		["Auto Economy"] = "Авто-экономия",
		["FPS Below"] = "FPS ниже",
		["Hide Distant Parts"] = "Скрывать дальние детали",
		["Pause World Animations"] = "Пауза анимаций мира",
		["Gray World"] = "Серый мир",
		["Hide Trails & Beams"] = "Скрыть следы и лучи",
		["Ground Grid"] = "Сетка на земле",
		["Low FPS — economy mode turned on."] = "Низкий FPS — включён режим экономии.",
	})
end

------------------------------ CHARACTER (37–50) ------------------------------
-- Всё видно только вам, кроме анимаций своего персонажа (37–38): анимации, которые играет
-- ваш клиент на своём персонаже, Roblox показывает и другим — как обычные эмоции.
do
	local RunService = game:GetService("RunService")
	local SoundService = game:GetService("SoundService")
	local CharacterTab = Tabs["Character"]

	local function torso(char)
		return char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
	end
	local function weldTo(part, base, offset)
		part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch, part.Massless = false, false, false, false, true
		local weld = Instance.new("Weld")
		weld.Part0 = base
		weld.Part1 = part
		weld.C0 = offset
		weld.Parent = part
		return weld
	end

	------------------------------ 37: анимации ------------------------------
	local ANIM_SLOTS = {
		{ "Idle", "idle", { "Animation1", "Animation2" } },
		{ "Walk", "walk", { "WalkAnim" } },
		{ "Run", "run", { "RunAnim" } },
		{ "Jump", "jump", { "JumpAnim" } },
		{ "Fall", "fall", { "FallAnim" } },
	}
	local customAnims = {} -- слот -> id
	local originalAnims = setmetatable({}, { __mode = "k" }) -- Animation -> исходный id
	local function applyAnimations()
		local char = Util.char()
		local animate = char and char:FindFirstChild("Animate")
		if not animate then
			return
		end
		for _, slot in ipairs(ANIM_SLOTS) do
			local folder = animate:FindFirstChild(slot[2])
			for _, animName in ipairs(slot[3]) do
				local anim = folder and folder:FindFirstChild(animName)
				if anim and anim:IsA("Animation") then
					local id = customAnims[slot[1]]
					if id then
						originalAnims[anim] = originalAnims[anim] or anim.AnimationId
						anim.AnimationId = "rbxassetid://" .. id
					elseif originalAnims[anim] then
						anim.AnimationId = originalAnims[anim]
						originalAnims[anim] = nil
					end
				end
			end
		end
		-- перезапустить текущие анимации, чтобы новые подхватились
		local humanoid = Util.humanoid()
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				track:Stop(0)
			end
		end
	end
	Util.track(Util.player.CharacterAdded:Connect(function()
		task.wait(1)
		if next(customAnims) then
			pcall(applyAnimations)
		end
	end))

	------------------------------ 38: эмоции ------------------------------
	local emote = { id = nil, loop = true, share = true, track = nil }
	local remoteTracks = {}
	local function playEmoteOn(humanoid, id, loop)
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			return nil
		end
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://" .. id
		local ok, track = pcall(function()
			return animator:LoadAnimation(animation)
		end)
		if ok and track then
			track.Looped = loop
			track.Priority = Enum.AnimationPriority.Action
			track:Play()
			return track
		end
		return nil
	end
	local function playEmote(id)
		id = tonumber(string.match(tostring(id or ""), "%d+"))
		if not id then
			Util.notify("Emotes", "Enter an animation ID.")
			return
		end
		if emote.track then
			emote.track:Stop()
		end
		emote.track = playEmoteOn(Util.humanoid(), id, emote.loop)
		if not emote.track then
			Util.notify("Emotes", "Could not play this animation.")
		elseif emote.share then
			-- 115: другие пользователи скрипта увидят эмоцию у себя
			Library:SendSyncEvent("emote", { id = id, loop = emote.loop })
		end
	end
	local function stopEmote()
		if emote.track then
			emote.track:Stop()
			emote.track = nil
		end
		if emote.share then
			Library:SendSyncEvent("emote", { stop = true })
		end
	end
	Library:OnSyncEvent(function(event)
		if event.type ~= "emote" then
			return
		end
		local player = game:GetService("Players"):GetPlayerByUserId(tonumber(event.from) or 0)
		local humanoid = player and player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if remoteTracks[event.from] then
			remoteTracks[event.from]:Stop()
			remoteTracks[event.from] = nil
		end
		if humanoid and event.data and event.data.id and not event.data.stop then
			remoteTracks[event.from] = playEmoteOn(humanoid, event.data.id, event.data.loop ~= false)
		end
	end)

	------------------------------ 40/50: цвет и материал тела ------------------------------
	local look = { colorOn = false, color = Color3.fromRGB(100, 133, 247), material = "Default", tone = "None" }
	local savedLook = setmetatable({}, { __mode = "k" }) -- деталь -> { Color, Material }
	local function applyLook()
		local char = Util.char()
		if not char then
			return
		end
		local active = look.colorOn or look.material ~= "Default" or look.tone ~= "None"
		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				if active then
					savedLook[part] = savedLook[part] or { part.Color, part.Material }
					local base = savedLook[part][1]
					local color = look.colorOn and look.color or base
					if look.tone == "Dark" then
						color = color:Lerp(Color3.new(0, 0, 0), 0.6)
					elseif look.tone == "Light" then
						color = color:Lerp(Color3.new(1, 1, 1), 0.5)
					end
					part.Color = color
					part.Material = look.material ~= "Default" and Enum.Material[look.material] or savedLook[part][2]
				elseif savedLook[part] then
					part.Color, part.Material = savedLook[part][1], savedLook[part][2]
					savedLook[part] = nil
				end
			end
		end
		-- BodyColors игры перекрашивает тело — пока стиль включён, прячем его эффект
		local bodyColors = char:FindFirstChildOfClass("BodyColors")
		if bodyColors and active then
			bodyColors.Parent = nil
			look.removedBodyColors = { object = bodyColors, char = char }
		elseif not active and look.removedBodyColors then
			if look.removedBodyColors.char == char then
				look.removedBodyColors.object.Parent = char
			end
			look.removedBodyColors = nil
		end
	end

	------------------------- 41–49: эффекты и аксессуары -------------------------
	local fx = {
		aura = "None",
		auraColor = Color3.fromRGB(150, 110, 245),
		rainbow = false,
		wings = false,
		wingsColor = Color3.fromRGB(245, 246, 255),
		tail = false,
		eyes = false,
		eyesColor = Color3.fromRGB(255, 60, 80),
		shadow = false,
		footsteps = false,
		footstepSound = false,
		landingShake = false,
		headFollow = false,
	}
	local built = {} -- имя -> { char, objects... }
	local function clearBuilt(name)
		local entry = built[name]
		if entry then
			for _, object in ipairs(entry.objects) do
				object:Destroy()
			end
			built[name] = nil
		end
	end
	local function ensureBuilt(name, enabled, builder)
		local char = Util.char()
		local entry = built[name]
		if not enabled or not char then
			clearBuilt(name)
			return nil
		end
		if entry and entry.char == char and entry.objects[1] and entry.objects[1].Parent then
			return entry
		end
		clearBuilt(name)
		local ok, objects = pcall(builder, char)
		if ok and objects then
			built[name] = { char = char, objects = objects }
			return built[name]
		end
		return nil
	end

	local AURAS = {
		Sparkle = { rate = 25, speed = 1, size = 0.25, light = 1, life = 1.5 },
		Fire = { rate = 60, speed = 3, size = 0.6, light = 1, life = 0.8, color = Color3.fromRGB(255, 120, 40) },
		Ice = { rate = 40, speed = 1, size = 0.35, light = 0.6, life = 1.6, color = Color3.fromRGB(150, 220, 255) },
		Electric = { rate = 80, speed = 8, size = 0.12, light = 1, life = 0.25, color = Color3.fromRGB(120, 200, 255) },
		Shadow = { rate = 40, speed = 1.5, size = 0.8, light = 0, life = 1.4, color = Color3.fromRGB(20, 10, 30) },
	}

	local function buildAura(char)
		local root = char:FindFirstChild("HumanoidRootPart")
		local attachment = Instance.new("Attachment")
		attachment.Name = "NocturneAura"
		attachment.Parent = root
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "NocturneAura"
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Parent = attachment
		return { attachment, emitter }
	end

	local function buildWings(char)
		local base = torso(char)
		local objects = {}
		for side = -1, 1, 2 do
			local wing = Instance.new("Part")
			wing.Name = "NocturneWing"
			wing.Size = Vector3.new(0.1, 2.6, 3.4)
			wing.Material = Enum.Material.Neon
			wing.Transparency = 0.25
			wing.Color = fx.wingsColor
			wing.Parent = char
			local weld = weldTo(wing, base, CFrame.new(side * 0.9, 0.6, 0.9) * CFrame.Angles(0, math.rad(side * 35), math.rad(side * 15)))
			weld:SetAttribute("Side", side)
			table.insert(objects, wing)
		end
		return objects
	end

	local function buildTail(char)
		local base = char:FindFirstChild("LowerTorso") or torso(char)
		local objects = {}
		local previous = base
		for i = 1, 5 do
			local segment = Instance.new("Part")
			segment.Name = "NocturneTail"
			segment.Shape = Enum.PartType.Ball
			segment.Size = Vector3.new(1, 1, 1) * (0.45 - i * 0.05)
			segment.Color = fx.wingsColor
			segment.Material = Enum.Material.SmoothPlastic
			segment.Parent = char
			weldTo(segment, previous, previous == base and CFrame.new(0, -0.3, 0.6) or CFrame.new(0, -0.05, 0.35))
			previous = segment
			table.insert(objects, segment)
		end
		return objects
	end

	local function buildEyes(char)
		local head = char:FindFirstChild("Head")
		local objects = {}
		for side = -1, 1, 2 do
			local eye = Instance.new("Part")
			eye.Name = "NocturneEye"
			eye.Shape = Enum.PartType.Ball
			eye.Size = Vector3.new(0.16, 0.16, 0.16)
			eye.Material = Enum.Material.Neon
			eye.Color = fx.eyesColor
			eye.Parent = char
			weldTo(eye, head, CFrame.new(side * 0.17, 0.12, -0.56))
			table.insert(objects, eye)
		end
		local light = Instance.new("PointLight")
		light.Name = "NocturneEyeLight"
		light.Range = 6
		light.Brightness = 1.5
		light.Color = fx.eyesColor
		light.Parent = head
		table.insert(objects, light)
		return objects
	end

	local function buildShadow(char)
		local disc = Instance.new("Part")
		disc.Name = "NocturneShadow"
		disc.Shape = Enum.PartType.Cylinder
		disc.Size = Vector3.new(0.05, 4, 4)
		disc.Color = Color3.new(0, 0, 0)
		disc.Transparency = 0.55
		disc.Material = Enum.Material.SmoothPlastic
		disc.Anchored, disc.CanCollide, disc.CanQuery, disc.CanTouch = true, false, false, false
		disc.Parent = workspace.CurrentCamera
		return { disc }
	end

	local rainbowHighlight = nil
	local neckSaved = nil -- { motor, C0 }
	local function neckMotor(char)
		local head = char:FindFirstChild("Head")
		local neck = head and head:FindFirstChild("Neck")
		if not neck then
			local t = char:FindFirstChild("Torso")
			neck = t and t:FindFirstChild("Neck")
		end
		return neck and neck:IsA("Motor6D") and neck or nil
	end

	local function applyFx()
		local char = Util.char()
		-- 41/42: аура и стихии
		local aura = ensureBuilt("aura", fx.aura ~= "None", buildAura)
		if aura then
			local preset = AURAS[fx.aura]
			local emitter = aura.objects[2]
			emitter.Rate = preset.rate
			emitter.Speed = NumberRange.new(preset.speed * 0.5, preset.speed)
			emitter.Size = NumberSequence.new(preset.size, 0)
			emitter.LightEmission = preset.light
			emitter.Lifetime = NumberRange.new(preset.life * 0.6, preset.life)
			emitter.Color = ColorSequence.new(preset.color or fx.auraColor)
		end
		-- радужное свечение теперь в Character → Body → Self Highlight → Rainbow
		-- 44: крылья и хвост
		local wings = ensureBuilt("wings", fx.wings, buildWings)
		if wings then
			for _, wing in ipairs(wings.objects) do
				wing.Color = fx.wingsColor
				local weld = wing:FindFirstChildOfClass("Weld")
				local side = weld and weld:GetAttribute("Side") or 1
				if weld then
					local flap = math.sin(os.clock() * 3) * 12
					weld.C0 = CFrame.new(side * 0.9, 0.6, 0.9) * CFrame.Angles(0, math.rad(side * (35 + flap)), math.rad(side * 15))
				end
			end
		end
		local tail = ensureBuilt("tail", fx.tail, buildTail)
		if tail then
			for index, segment in ipairs(tail.objects) do
				segment.Color = fx.wingsColor
				local weld = segment:FindFirstChildOfClass("Weld")
				if weld and index > 1 then
					weld.C0 = CFrame.new(0, -0.05, 0.35) * CFrame.Angles(0, math.sin(os.clock() * 4 + index) * 0.35, 0)
				end
			end
		end
		-- 45: светящиеся глаза
		local eyes = ensureBuilt("eyes", fx.eyes, buildEyes)
		if eyes then
			for _, object in ipairs(eyes.objects) do
				object.Color = fx.eyesColor
			end
		end
		-- 46: своя тень
		local shadow = ensureBuilt("shadow", fx.shadow, buildShadow)
		local root = Util.root()
		if shadow and root then
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { char, workspace.CurrentCamera }
			local hit = workspace:Raycast(root.Position, Vector3.new(0, -50, 0), params)
			local disc = shadow.objects[1]
			disc.Transparency = hit and 0.55 or 1
			if hit then
				disc.CFrame = CFrame.new(hit.Position + Vector3.new(0, 0.03, 0)) * CFrame.Angles(0, 0, math.rad(90))
			end
		end
		-- 49: голова следит за курсором
		if char then
			local neck = neckMotor(char)
			if fx.headFollow and neck and root then
				if not neckSaved or neckSaved.motor ~= neck then
					neckSaved = { motor = neck, c0 = neck.C0 }
				end
				local camera = Util.camera()
				local relative = root.CFrame:VectorToObjectSpace(camera.CFrame.LookVector)
				local yaw = math.clamp(math.atan2(-relative.X, -relative.Z), -1.1, 1.1) * 0.6
				local pitch = math.clamp(math.asin(math.clamp(relative.Y, -1, 1)), -0.8, 0.8) * 0.6
				if neck.Parent and neck.Parent.Name == "Torso" then
					neck.C0 = neckSaved.c0 * CFrame.Angles(-pitch, 0, -yaw) -- R6: оси повёрнуты
				else
					neck.C0 = neckSaved.c0 * CFrame.Angles(pitch, yaw, 0)
				end
			elseif neckSaved then
				if neckSaved.motor.Parent then
					neckSaved.motor.C0 = neckSaved.c0
				end
				neckSaved = nil
			end
		end
	end
	Util.track(RunService.RenderStepped:Connect(function()
		pcall(applyFx)
	end))

	-- 47: шаги — частицы под ногами и звук
	local stepEmitterPart = nil
	local stepSound = Instance.new("Sound")
	stepSound.SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
	stepSound.Volume = 0.4
	Util.loop(0.32, function()
		if not fx.footsteps and not fx.footstepSound then
			return
		end
		local humanoid, root = Util.humanoid(), Util.root()
		if not (humanoid and root) or humanoid.MoveDirection.Magnitude < 0.1 or humanoid.FloorMaterial == Enum.Material.Air then
			return
		end
		if fx.footsteps then
			if not stepEmitterPart or not stepEmitterPart.Parent then
				stepEmitterPart = Instance.new("Part")
				stepEmitterPart.Name = "NocturneSteps"
				stepEmitterPart.Anchored, stepEmitterPart.CanCollide, stepEmitterPart.CanQuery = true, false, false
				stepEmitterPart.Transparency = 1
				stepEmitterPart.Size = Vector3.new(1, 0.2, 1)
				stepEmitterPart.Parent = workspace.CurrentCamera
				local emitter = Instance.new("ParticleEmitter")
				emitter.Enabled = false
				emitter.Rate = 0
				emitter.Speed = NumberRange.new(2, 4)
				emitter.Lifetime = NumberRange.new(0.4, 0.7)
				emitter.Size = NumberSequence.new(0.35, 0)
				emitter.SpreadAngle = Vector2.new(60, 60)
				emitter.EmissionDirection = Enum.NormalId.Top
				emitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 210))
				emitter.Parent = stepEmitterPart
			end
			stepEmitterPart.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.8, 0))
			stepEmitterPart:FindFirstChildOfClass("ParticleEmitter"):Emit(6)
		end
		if fx.footstepSound then
			pcall(function()
				SoundService:PlayLocalSound(stepSound)
			end)
		end
	end)

	-- 48: тряска камеры при приземлении
	local shakeUntil = 0
	Util.loop(1, function()
		local humanoid = Util.humanoid()
		if humanoid and not humanoid:GetAttribute("NocturneLandHook") then
			humanoid:SetAttribute("NocturneLandHook", true)
			Util.track(humanoid.StateChanged:Connect(function(_, new)
				if fx.landingShake and new == Enum.HumanoidStateType.Landed then
					shakeUntil = os.clock() + 0.25
				end
			end))
		end
	end)
	Util.render(Enum.RenderPriority.Camera.Value + 4, function()
		local camera = Util.camera()
		if camera and os.clock() < shakeUntil then
			local s = (shakeUntil - os.clock()) * 1.2
			camera.CFrame = camera.CFrame * CFrame.new((math.random() - 0.5) * s, (math.random() - 0.5) * s, 0)
		end
	end)

	Util.loop(0.5, applyLook)
	Util.onUnload(function()
		look.colorOn, look.material, look.tone = false, "Default", "None"
		applyLook()
		for key in pairs(fx) do
			if type(fx[key]) == "boolean" then
				fx[key] = false
			end
		end
		fx.aura = "None"
		applyFx()
		for name in pairs(built) do
			clearBuilt(name)
		end
		customAnims = {}
		applyAnimations()
		if emote.track then
			emote.track:Stop()
		end
		if stepEmitterPart then
			stepEmitterPart:Destroy()
		end
	end)

	-------------------------------- интерфейс --------------------------------
	local Anims = CharacterTab:AddSection({ Name = "Animations", Side = "Left" })
	local animBoxes = {}
	for _, slot in ipairs(ANIM_SLOTS) do
		animBoxes[slot[1]] = Anims:AddTextbox({ Name = slot[1] .. " ID", Placeholder = "rbxassetid", Width = 120 })
	end
	Anims:AddButton({ Name = "Apply Animations", Callback = function()
		customAnims = {}
		for name, box in pairs(animBoxes) do
			local id = tonumber(string.match(box:Get(), "%d+"))
			if id then
				customAnims[name] = id
			end
		end
		applyAnimations()
		Util.notify("Animations", next(customAnims) and "Animations applied." or "Enter at least one animation ID.")
	end })
	Anims:AddButton({ Name = "Reset Animations", Danger = true, Callback = function()
		customAnims = {}
		applyAnimations()
	end })

	local Emotes = CharacterTab:AddSection({ Name = "Emotes", Side = "Left" })
	local emoteBox = Emotes:AddTextbox({ Name = "Emote ID", Placeholder = "rbxassetid", Width = 120 })
	Emotes:AddToggle({ Name = "Loop", Default = true, Callback = function(v)
		emote.loop = v
	end })
	Emotes:AddToggle({ Name = "Share with Script Users", Icon = "cast", Default = true, Callback = function(v)
		emote.share = v
	end })
	Emotes:AddButton({ Name = "Play Emote", Callback = function()
		playEmote(emoteBox:Get())
	end })
	Emotes:AddButton({ Name = "Stop Emote", Callback = stopEmote })

	local Look = CharacterTab:AddSection({ Name = "Look", Side = "Right" })
	Look:AddToggle({ Name = "Body Color", Default = false, Callback = function(v)
		look.colorOn = v
		applyLook()
	end }):AddColorpicker({ Default = look.color, Callback = function(v)
		look.color = v
	end })
	Look:AddDropdown({ Name = "Material", Options = { "Default", "Neon", "ForceField", "Glass", "Metal", "SmoothPlastic", "Ice" }, Default = "Default", Width = 130, Callback = function(v)
		look.material = v
		applyLook()
	end })
	Look:AddDropdown({ Name = "Tone", Options = { "None", "Dark", "Light" }, Default = "None", Width = 130, Callback = function(v)
		look.tone = v
		applyLook()
	end })

	local Effects = CharacterTab:AddSection({ Name = "Body Effects", Side = "Right" })
	Effects:AddDropdown({ Name = "Aura", Options = { "None", "Sparkle", "Fire", "Ice", "Electric", "Shadow" }, Default = "None", Width = 130, Callback = function(v)
		fx.aura = v
	end }):AddColorpicker({ Default = fx.auraColor, Callback = function(v)
		fx.auraColor = v
	end })
	Effects:AddToggle({ Name = "Wings", Default = false, Callback = function(v)
		fx.wings = v
	end }):AddColorpicker({ Default = fx.wingsColor, Callback = function(v)
		fx.wingsColor = v
	end })
	Effects:AddToggle({ Name = "Tail", Default = false, Callback = function(v)
		fx.tail = v
	end })
	Effects:AddToggle({ Name = "Glowing Eyes", Default = false, Callback = function(v)
		fx.eyes = v
	end }):AddColorpicker({ Default = fx.eyesColor, Callback = function(v)
		fx.eyesColor = v
	end })
	Effects:AddToggle({ Name = "Custom Shadow", Default = false, Callback = function(v)
		fx.shadow = v
	end })
	Effects:AddToggle({ Name = "Footstep Particles", Default = false, Callback = function(v)
		fx.footsteps = v
	end })
	Effects:AddToggle({ Name = "Footstep Sounds", Default = false, Callback = function(v)
		fx.footstepSound = v
	end })
	Effects:AddToggle({ Name = "Landing Shake", Default = false, Callback = function(v)
		fx.landingShake = v
	end })
	Effects:AddToggle({ Name = "Head Follows Camera", Default = false, Callback = function(v)
		fx.headFollow = v
	end })

	Util.tr({
		Animations = "Анимации",
		["Idle ID"] = "ID ожидания",
		["Walk ID"] = "ID ходьбы",
		["Run ID"] = "ID бега",
		["Jump ID"] = "ID прыжка",
		["Fall ID"] = "ID падения",
		["Apply Animations"] = "Применить анимации",
		["Reset Animations"] = "Сбросить анимации",
		Emotes = "Эмоции",
		["Emote ID"] = "ID эмоции",
		Loop = "Повтор",
		["Share with Script Users"] = "Показывать пользователям скрипта",
		["Play Emote"] = "Играть эмоцию",
		["Stop Emote"] = "Остановить эмоцию",
		Look = "Внешний вид",
		["Body Color"] = "Цвет тела",
		Tone = "Тон",
		["Rainbow Glow"] = "Радужное свечение",
		["Body Effects"] = "Эффекты тела",
		Aura = "Аура",
		Wings = "Крылья",
		Tail = "Хвост",
		["Glowing Eyes"] = "Светящиеся глаза",
		["Custom Shadow"] = "Своя тень",
		["Footstep Particles"] = "Частицы шагов",
		["Footstep Sounds"] = "Звук шагов",
		["Landing Shake"] = "Тряска при приземлении",
		["Head Follows Camera"] = "Голова за камерой",
		["Enter an animation ID."] = "Введите ID анимации.",
		["Could not play this animation."] = "Не удалось проиграть анимацию.",
		["Animations applied."] = "Анимации применены.",
		["Enter at least one animation ID."] = "Введите хотя бы один ID анимации.",
	})
end

------------------------------ HUD (34–36, 51–65) ------------------------------
do
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local SoundService = game:GetService("SoundService")
	local Stats = game:GetService("Stats")
	local Lighting = game:GetService("Lighting")
	local HudTab = Tabs["HUD"]

	local ping = Instance.new("Sound")
	ping.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	ping.Volume = 0.6
	local function beep()
		pcall(function()
			SoundService:PlayLocalSound(ping)
		end)
	end

	-- общий счётчик FPS для виджетов
	local fps, frames, lastCount = 60, 0, os.clock()
	Util.track(RunService.RenderStepped:Connect(function()
		frames += 1
		local now = os.clock()
		if now - lastCount >= 0.25 then
			fps = frames / (now - lastCount)
			frames, lastCount = 0, now
		end
	end))

	-- 51: часы, дата, память
	local clockWidget = Util.textWidget("ClockWidget", "Clock", UDim2.fromOffset(16, 160), "clock", function()
		local memory = 0
		pcall(function()
			memory = Stats:GetTotalMemoryUsageMb()
		end)
		return { os.date("%H:%M:%S"), os.date("%d.%m.%Y, %A"), string.format("RAM: %d MB", memory) }
	end)

	-- 54 + 34: прыжки, дистанция, высота над землёй
	local stats = { jumps = 0, distance = 0, lastPos = nil }
	Util.loop(0.2, function()
		local root = Util.root()
		if root then
			if stats.lastPos then
				local delta = root.Position - stats.lastPos
				local flat = Vector3.new(delta.X, 0, delta.Z).Magnitude
				if flat < 50 then
					stats.distance += flat
				end
			end
			stats.lastPos = root.Position
		end
		local humanoid = Util.humanoid()
		if humanoid and not humanoid:GetAttribute("NocturneJumpHook") then
			humanoid:SetAttribute("NocturneJumpHook", true)
			Util.track(humanoid.StateChanged:Connect(function(_, new)
				if new == Enum.HumanoidStateType.Jumping then
					stats.jumps += 1
				end
			end))
		end
	end)
	local function heightAboveGround()
		local root, char = Util.root(), Util.char()
		if not root then
			return nil
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { char, workspace.CurrentCamera }
		local hit = workspace:Raycast(root.Position, Vector3.new(0, -500, 0), params)
		return hit and math.max(0, (root.Position - hit.Position).Magnitude - 3) or nil
	end
	local movementWidget = Util.textWidget("MovementStats", "Movement", UDim2.fromOffset(16, 330), "jump", function()
		local height = heightAboveGround()
		local root = Util.root()
		local velocity = root and root.AssemblyLinearVelocity or Vector3.zero
		local position = root and root.Position or Vector3.zero
		return {
			Library:Translate("Speed") .. ": " .. math.floor(Vector3.new(velocity.X, 0, velocity.Z).Magnitude + 0.5) .. " st/s",
			string.format("XYZ: %d, %d, %d", math.floor(position.X), math.floor(position.Y), math.floor(position.Z)),
			Library:Translate("Height") .. ": " .. (height and string.format("%.1f st", height) or "—"),
			Library:Translate("Jumps") .. ": " .. stats.jumps,
			Library:Translate("Distance") .. ": " .. math.floor(stats.distance) .. " st",
		}
	end)

	-- 55: значения leaderstats (убийства, смерти, деньги — что есть в игре)
	local leaderWidget = Util.textWidget("LeaderStats", "Stats", UDim2.fromOffset(16, 460), "crosshair", function()
		local lines = {}
		local leaderstats = Util.player:FindFirstChild("leaderstats")
		for _, value in ipairs(leaderstats and leaderstats:GetChildren() or {}) do
			if value:IsA("ValueBase") then
				table.insert(lines, value.Name .. ": " .. tostring(value.Value))
			end
		end
		if #lines == 0 then
			table.insert(lines, Library:Translate("No leaderstats in this game"))
		end
		return lines
	end)

	-- 56: заметки на экране
	local notesText = ""
	local notesWidget = Util.textWidget("Notes", "Notes", UDim2.fromOffset(240, 160), "list", function()
		local lines = {}
		for line in string.gmatch(notesText, "[^;]+") do
			table.insert(lines, line)
		end
		return lines
	end)

	-- 57: секундомер с кругами
	local stopwatch = { running = false, elapsed = 0, startedAt = 0, laps = {} }
	local function stopwatchTime()
		return stopwatch.elapsed + (stopwatch.running and os.clock() - stopwatch.startedAt or 0)
	end
	local stopwatchWidget = Util.textWidget("Stopwatch", "Stopwatch", UDim2.fromOffset(240, 300), "clock", function()
		local lines = { string.format("%s.%d", Util.clock(stopwatchTime()), math.floor(stopwatchTime() * 10) % 10) }
		for index = #stopwatch.laps, math.max(1, #stopwatch.laps - 3), -1 do
			table.insert(lines, Library:Translate("Lap") .. " " .. index .. ": " .. Util.clock(stopwatch.laps[index]))
		end
		return lines
	end)

	-- 58: обратный отсчёт со звуком
	local countdown = { endsAt = nil, label = "" }
	local countdownWidget = Util.textWidget("Countdown", "Countdown", UDim2.fromOffset(240, 440), "clock", function()
		if not countdown.endsAt then
			return { "—" }
		end
		return { (countdown.label ~= "" and countdown.label .. ": " or "") .. Util.clock(countdown.endsAt - os.clock()) }
	end)
	local function startCountdown(seconds, label)
		countdown.endsAt = os.clock() + seconds
		countdown.label = label or ""
		countdownWidget:SetVisible(true)
		local myEnd = countdown.endsAt
		task.delay(seconds, function()
			if countdown.endsAt == myEnd then
				countdown.endsAt = nil
				beep()
				task.delay(0.3, beep)
				Util.notify("Countdown", (label ~= "" and label .. " — " or "") .. Library:Translate("Time is up!"), 5)
			end
		end)
	end
	Library.X = Library.X or {}
	Library.X.startCountdown = startCountdown -- для общего таймера пользователей скрипта (117)

	-- 59: друзья онлайн
	local friendLines = {}
	local friendsWidget = Util.textWidget("FriendsOnline", "Friends Online", UDim2.fromOffset(460, 160), "user", function()
		return #friendLines > 0 and friendLines or { Library:Translate("Nobody online") }
	end)
	Util.loop(30, function()
		if not friendsWidget.Visible then
			return
		end
		local ok, list = pcall(function()
			return Util.player:GetFriendsOnline(20)
		end)
		if ok and type(list) == "table" then
			friendLines = {}
			for _, friend in ipairs(list) do
				table.insert(friendLines, tostring(friend.DisplayName or friend.UserName) .. (friend.LastLocation and (" · " .. friend.LastLocation) or ""))
			end
		end
	end)

	-- 52: график FPS и пинга
	local graph = Util.frame({ Name = "NocturneGraph", BackgroundColor3 = Color3.fromRGB(13, 14, 19), BackgroundTransparency = 0.25, Position = UDim2.new(1, -230, 0, 60), Size = UDim2.fromOffset(210, 90), Visible = false, Parent = Window.widgetLayer })
	Util.round(graph, UDim.new(0, 8))
	Window:_draggable(graph)
	Window:_widgetScaleTarget(graph)
	local graphTitle = Util.text({ Position = UDim2.fromOffset(8, 4), Size = UDim2.new(1, -16, 0, 14), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = graph })
	local fpsBars, pingBars = {}, {}
	for i = 1, 40 do
		fpsBars[i] = Util.frame({ AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromRGB(100, 220, 140), Position = UDim2.new(0, 5 + (i - 1) * 5, 1, -6), Size = UDim2.fromOffset(3, 1), Parent = graph })
		pingBars[i] = Util.frame({ AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromRGB(240, 170, 80), BackgroundTransparency = 0.4, Position = UDim2.new(0, 6 + (i - 1) * 5, 1, -6), Size = UDim2.fromOffset(2, 1), Parent = graph })
	end
	local fpsHistory, pingHistory = {}, {}
	Util.loop(0.25, function()
		if not graph.Visible then
			return
		end
		local pingMs = 0
		pcall(function()
			pingMs = Util.player:GetNetworkPing() * 1000
		end)
		table.insert(fpsHistory, fps)
		table.insert(pingHistory, pingMs)
		if #fpsHistory > 40 then
			table.remove(fpsHistory, 1)
			table.remove(pingHistory, 1)
		end
		for i = 1, 40 do
			local f, p = fpsHistory[i] or 0, pingHistory[i] or 0
			fpsBars[i].Size = UDim2.fromOffset(3, math.clamp(f / 144, 0, 1) * 62)
			pingBars[i].Size = UDim2.fromOffset(2, math.clamp(p / 300, 0, 1) * 62)
		end
		graphTitle.Text = string.format("FPS %d   ·   Ping %d ms", math.floor(fps + 0.5), math.floor(pingMs + 0.5))
	end)

	-- 53: спидометр со шкалой
	local speedo = Util.frame({ Name = "NocturneSpeedometer", BackgroundColor3 = Color3.fromRGB(13, 14, 19), BackgroundTransparency = 0.25, Position = UDim2.new(0.5, -90, 1, -110), Size = UDim2.fromOffset(180, 54), Visible = false, Parent = Window.widgetLayer })
	Util.round(speedo, UDim.new(0, 8))
	Window:_draggable(speedo)
	Window:_widgetScaleTarget(speedo)
	local speedText = Util.text({ Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -20, 0, 26), TextSize = 22, Parent = speedo })
	local speedTrack = Util.frame({ BackgroundColor3 = Color3.fromRGB(40, 42, 53), Position = UDim2.new(0, 10, 1, -16), Size = UDim2.new(1, -20, 0, 6), Parent = speedo })
	Util.round(speedTrack)
	local speedFill = Util.frame({ BackgroundColor3 = Library.Theme.Accent, Size = UDim2.fromScale(0, 1), Parent = speedTrack })
	Util.round(speedFill)
	Util.track(RunService.RenderStepped:Connect(function()
		if not speedo.Visible then
			return
		end
		local root = Util.root()
		local v = root and root.AssemblyLinearVelocity or Vector3.zero
		local speed = Vector3.new(v.X, 0, v.Z).Magnitude
		speedText.Text = string.format("%d st/s", math.floor(speed + 0.5))
		speedFill.Size = UDim2.fromScale(math.clamp(speed / 50, 0, 1), 1)
		speedFill.BackgroundColor3 = Library.Theme.Accent
	end))

	-- 35: компас
	local compass = Util.frame({ Name = "NocturneCompass", BackgroundColor3 = Color3.fromRGB(13, 14, 19), BackgroundTransparency = 0.35, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12), Size = UDim2.fromOffset(360, 28), ClipsDescendants = true, Visible = false, Parent = Window.widgetLayer })
	Util.round(compass, UDim.new(0, 8))
	local compassMarks = {}
	for index, mark in ipairs({ "N", "NE", "E", "SE", "S", "SW", "W", "NW" }) do
		compassMarks[index] = { label = Util.text({ Text = mark, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(30, 20), TextSize = #mark == 1 and 15 or 11, TextColor3 = #mark == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 152, 165), Parent = compass }), angle = (index - 1) * 45 }
	end
	Util.round(Util.frame({ BackgroundColor3 = Library.Theme.Accent, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.fromOffset(2, 8), Parent = compass }), UDim.new(0, 1))
	Util.track(RunService.RenderStepped:Connect(function()
		if not compass.Visible then
			return
		end
		local look = Util.camera().CFrame.LookVector
		local heading = math.deg(math.atan2(look.X, -look.Z)) % 360
		for _, mark in ipairs(compassMarks) do
			local diff = ((mark.angle - heading + 540) % 360) - 180
			mark.label.Visible = math.abs(diff) < 100
			mark.label.Position = UDim2.new(0.5, diff * 1.8, 0.5, 0)
		end
	end))

	-- 36: мини-карта меток (вейпоинты и направление, без других игроков)
	local minimap = Util.frame({ Name = "NocturneMinimap", BackgroundColor3 = Color3.fromRGB(13, 14, 19), BackgroundTransparency = 0.25, Position = UDim2.new(1, -170, 1, -400), Size = UDim2.fromOffset(150, 150), Visible = false, Parent = Window.widgetLayer })
	Util.round(minimap)
	Window:_draggable(minimap)
	Window:_widgetScaleTarget(minimap)
	local arrow = Util.text({ Text = "▲", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(20, 20), TextSize = 16, TextColor3 = Library.Theme.Accent, Parent = minimap })
	Util.text({ Text = "N", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 2), Size = UDim2.fromOffset(20, 14), TextSize = 11, Parent = minimap })
	local mapDots = {}
	local MAP_RANGE = 300
	Util.loop(0.1, function()
		if not minimap.Visible then
			return
		end
		local root = Util.root()
		local look = Util.camera().CFrame.LookVector
		arrow.Rotation = math.deg(math.atan2(look.X, -look.Z))
		local list = Library.X and Library.X.waypoints and Library.X.waypoints.list or {}
		for index, waypoint in ipairs(list) do
			local dot = mapDots[index]
			if not dot then
				dot = Util.frame({ AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(7, 7), Parent = minimap })
				Util.round(dot)
				mapDots[index] = dot
			end
			if root then
				local offset = waypoint.attachment.WorldPosition - root.Position
				local x, z = offset.X / MAP_RANGE, offset.Z / MAP_RANGE
				local length = math.sqrt(x * x + z * z)
				if length > 0.95 then
					x, z = x / length * 0.95, z / length * 0.95
				end
				dot.Position = UDim2.fromScale(0.5 + x / 2, 0.5 + z / 2)
				dot.BackgroundColor3 = Library.X.waypoints.color
				dot.Visible = true
			end
		end
		for index = #list + 1, #mapDots do
			mapDots[index].Visible = false
		end
	end)

	-- 60: свой курсор
	local cursor = { on = false, id = nil }
	local function applyCursor()
		pcall(function()
			UserInputService.MouseIcon = cursor.on and cursor.id and ("rbxassetid://" .. cursor.id) or ""
		end)
	end

	-- 61: маркер на свои клики
	local clickMarker = { on = false, sound = false }
	Util.track(UserInputService.InputBegan:Connect(function(input, processed)
		if not clickMarker.on or processed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		local position = UserInputService:GetMouseLocation()
		local mark = Util.text({ Text = "✕", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(position.X, position.Y), Size = UDim2.fromOffset(24, 24), TextSize = 18, TextColor3 = Library.Theme.Accent, Parent = Window.widgetLayer })
		game:GetService("TweenService"):Create(mark, TweenInfo.new(0.35), { TextTransparency = 1, Size = UDim2.fromOffset(36, 36) }):Play()
		task.delay(0.4, function()
			mark:Destroy()
		end)
		if clickMarker.sound then
			beep()
		end
	end))

	-- 62: темы меню и радужная рамка
	-- цвет и пресеты акцента — в меню профиля (Style); здесь только радужный режим
	local rainbowMenu = false
	Util.loop(0.15, function()
		if rainbowMenu then
			Library:SetAccent(Color3.fromHSV((os.clock() / 8) % 1, 0.6, 0.97))
		end
	end)
	local menuStroke = Window.main:FindFirstChildOfClass("UIStroke")
	local rainbowBorder = false
	Util.track(RunService.RenderStepped:Connect(function()
		if rainbowBorder and menuStroke then
			menuStroke.Color = Color3.fromHSV((os.clock() / 3) % 1, 0.7, 1)
			menuStroke.Transparency = 0
		end
	end))

	-- 63: прозрачность меню и размытие фона
	local menuLook = { transparency = 0, blur = false }
	local savedTransparency = setmetatable({}, { __mode = "k" })
	local function applyMenuLook()
		for _, frame in ipairs({ Window.main, Window.main:FindFirstChild("Sidebar") }) do
			if frame then
				savedTransparency[frame] = savedTransparency[frame] or frame.BackgroundTransparency
				frame.BackgroundTransparency = math.max(savedTransparency[frame], menuLook.transparency)
			end
		end
		Util.effect("MenuBlur", "BlurEffect", Lighting, menuLook.blur and Window.Visible)
	end
	Util.loop(0.3, applyMenuLook)

	-- 64: шрифт меню
	local savedFonts = setmetatable({}, { __mode = "k" })
	local function applyFont(fontName)
		for _, item in ipairs(Window.gui:GetDescendants()) do
			if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then
				if fontName == "Default" then
					if savedFonts[item] then
						item.Font = savedFonts[item]
						savedFonts[item] = nil
					end
				else
					savedFonts[item] = savedFonts[item] or item.Font
					pcall(function()
						item.Font = Enum.Font[fontName]
					end)
				end
			end
		end
	end

	Util.onUnload(function()
		cursor.on = false
		applyCursor()
		applyFont("Default")
		menuLook.blur = false
		for frame, value in pairs(savedTransparency) do
			frame.BackgroundTransparency = value
		end
		for _, object in ipairs({ graph, speedo, compass, minimap }) do
			object:Destroy()
		end
	end)

	-------------------------------- интерфейс --------------------------------
	local Widgets = HudTab:AddSection({ Name = "Widgets", Side = "Left" })
	for _, item in ipairs({
		{ "Clock & Date", clockWidget, "clock" },
		{ "Movement Stats", movementWidget, "jump" },
		{ "Leaderstats", leaderWidget, "crosshair" },
		{ "Friends Online", friendsWidget, "user" },
	}) do
		Widgets:AddToggle({ Name = item[1], Icon = item[3], Default = false, Callback = function(v)
			item[2]:SetVisible(v)
		end })
	end
	Widgets:AddToggle({ Name = "FPS & Ping Graph", Icon = "bars", Default = false, Callback = function(v)
		graph.Visible = v
	end })
	Widgets:AddToggle({ Name = "Speedometer", Icon = "speed", Default = false, Callback = function(v)
		speedo.Visible = v
	end })
	Widgets:AddToggle({ Name = "Compass", Icon = "globe", Default = false, Callback = function(v)
		compass.Visible = v
	end })
	Widgets:AddToggle({ Name = "Waypoint Minimap", Icon = "crosshair", Default = false, Callback = function(v)
		minimap.Visible = v
	end })
	Widgets:AddButton({ Name = "Reset Movement Stats", Callback = function()
		stats.jumps, stats.distance = 0, 0
	end })

	local Notes = HudTab:AddSection({ Name = "Notes", Side = "Left" })
	local notesBox = Notes:AddTextbox({ Name = "Text", Placeholder = "line 1; line 2", Width = 160, Callback = function(text)
		notesText = text
	end })
	Notes:AddToggle({ Name = "Show Notes", Default = false, Callback = function(v)
		notesText = notesBox:Get()
		notesWidget:SetVisible(v)
	end })

	local Timers = HudTab:AddSection({ Name = "Timers", Side = "Right" })
	Timers:AddToggle({ Name = "Stopwatch", Icon = "clock", Default = false, Callback = function(v)
		stopwatchWidget:SetVisible(v)
	end })
	Timers:AddButton({ Name = "Start / Pause", Callback = function()
		if stopwatch.running then
			stopwatch.elapsed = stopwatchTime()
			stopwatch.running = false
		else
			stopwatch.startedAt = os.clock()
			stopwatch.running = true
		end
	end })
	Timers:AddButton({ Name = "Lap", Callback = function()
		table.insert(stopwatch.laps, stopwatchTime())
	end })
	Timers:AddButton({ Name = "Reset Stopwatch", Danger = true, Callback = function()
		stopwatch.running, stopwatch.elapsed, stopwatch.laps = false, 0, {}
	end })
	local countdownBox = Timers:AddTextbox({ Name = "Countdown (sec)", Placeholder = "60", Width = 90 })
	Timers:AddButton({ Name = "Start Countdown", Callback = function()
		local seconds = tonumber(countdownBox:Get())
		if not seconds or seconds <= 0 then
			Util.notify("Countdown", "Enter the number of seconds.")
			return
		end
		startCountdown(seconds, "")
	end })

	local Cursor = HudTab:AddSection({ Name = "Cursor & Clicks", Side = "Right" })
	local cursorBox = Cursor:AddTextbox({ Name = "Cursor Image ID", Placeholder = "rbxassetid", Width = 120 })
	Cursor:AddToggle({ Name = "Custom Cursor", Default = false, Callback = function(v)
		cursor.on = v
		cursor.id = tonumber(string.match(cursorBox:Get(), "%d+"))
		if v and not cursor.id then
			Util.notify("Cursor", "Enter an image ID first.")
		end
		applyCursor()
	end })
	Cursor:AddToggle({ Name = "Click Marker", Default = false, Callback = function(v)
		clickMarker.on = v
	end })
	Cursor:AddToggle({ Name = "Click Sound", Default = false, Callback = function(v)
		clickMarker.sound = v
	end })

	local MenuLook = HudTab:AddSection({ Name = "Menu Look", Side = "Right" })
	MenuLook:AddToggle({ Name = "Rainbow Accent", Default = false, Callback = function(v)
		rainbowMenu = v
	end })
	MenuLook:AddToggle({ Name = "Rainbow Border", Default = false, Callback = function(v)
		rainbowBorder = v
		if not v and menuStroke then
			menuStroke.Color = Library.Theme.Stroke
			menuStroke.Transparency = 0.3
		end
	end })
	MenuLook:AddSlider({ Name = "Menu Transparency", Min = 0, Max = 60, Default = 0, Suffix = "%", Callback = function(v)
		menuLook.transparency = v / 100
		applyMenuLook()
	end })
	MenuLook:AddToggle({ Name = "Blur Behind Menu", Default = false, Callback = function(v)
		menuLook.blur = v
		applyMenuLook()
	end })
	MenuLook:AddDropdown({ Name = "Font", Options = { "Default", "SourceSans", "Arial", "Ubuntu", "Code", "Highway" }, Default = "Default", Width = 120, Callback = applyFont })

	Util.tr({
		HUD = "Интерфейс",
		Widgets = "Плашки",
		Clock = "Часы",
		["Clock & Date"] = "Часы и дата",
		Movement = "Движение",
		["Movement Stats"] = "Статистика движения",
		Jumps = "Прыжки",
		Stats = "Статистика",
		Leaderstats = "Статистика игры",
		["No leaderstats in this game"] = "В этой игре нет статистики",
		["Friends Online"] = "Друзья онлайн",
		["Nobody online"] = "Никого нет онлайн",
		["FPS & Ping Graph"] = "График FPS и пинга",
		Speedometer = "Спидометр",
		Compass = "Компас",
		["Waypoint Minimap"] = "Мини-карта меток",
		["Reset Movement Stats"] = "Сбросить статистику",
		Notes = "Заметки",
		["Show Notes"] = "Показывать заметки",
		Timers = "Таймеры",
		Stopwatch = "Секундомер",
		["Start / Pause"] = "Старт / пауза",
		Lap = "Круг",
		["Reset Stopwatch"] = "Сбросить секундомер",
		Countdown = "Обратный отсчёт",
		["Countdown (sec)"] = "Отсчёт (сек)",
		["Start Countdown"] = "Запустить отсчёт",
		["Time is up!"] = "Время вышло!",
		["Enter the number of seconds."] = "Введите число секунд.",
		["Cursor & Clicks"] = "Курсор и клики",
		["Cursor Image ID"] = "ID картинки курсора",
		["Custom Cursor"] = "Свой курсор",
		["Click Marker"] = "Маркер клика",
		["Click Sound"] = "Звук клика",
		["Enter an image ID first."] = "Сначала введите ID картинки.",
		["Menu Look"] = "Вид меню",
		Theme = "Тема",
		["Rainbow Accent"] = "Радужный акцент",
		["Rainbow Border"] = "Радужная рамка",
		["Menu Transparency"] = "Прозрачность меню",
		["Blur Behind Menu"] = "Размытие за меню",
		Font = "Шрифт",
		["Compact Mode"] = "Компактный режим",
	})
end

------------------------------ AUDIO (66–72) ------------------------------
do
	local SoundService = game:GetService("SoundService")
	local RunService = game:GetService("RunService")
	local AudioTab = Tabs["Audio"]

	local audio = {
		eq = false,
		low = 0,
		mid = 0,
		high = 0,
		musicScale = 1,
		effectsScale = 1,
		splitVolume = false,
		silence = false,
		reverb = "NoReverb",
	}
	local tracked = setmetatable({}, { __mode = "k" }) -- звук -> исходная громкость
	local equalizers = setmetatable({}, { __mode = "k" })

	local function isOurs(sound)
		return string.find(sound.Name, "^Nocturne") ~= nil
	end
	-- «Музыка» — длинные зацикленные звуки, остальное — эффекты (определяем приблизительно)
	local function isMusic(sound)
		return sound.Looped and (sound.TimeLength == 0 or sound.TimeLength > 25)
	end

	local function applySound(sound)
		if not sound:IsA("Sound") or isOurs(sound) then
			return
		end
		local active = audio.splitVolume or audio.silence
		if active then
			if tracked[sound] == nil then
				tracked[sound] = sound.Volume
			end
			local scale = audio.silence and 0 or (isMusic(sound) and audio.musicScale or audio.effectsScale)
			sound.Volume = tracked[sound] * scale
		elseif tracked[sound] ~= nil then
			sound.Volume = tracked[sound]
			tracked[sound] = nil
		end
		-- 66: эквалайзер на каждом звуке игры
		local eq = equalizers[sound]
		if audio.eq then
			if not eq or eq.Parent ~= sound then
				eq = Instance.new("EqualizerSoundEffect")
				eq.Name = "NocturneEQ"
				eq.Parent = sound
				equalizers[sound] = eq
			end
			eq.LowGain, eq.MidGain, eq.HighGain = audio.low, audio.mid, audio.high
		elseif eq then
			eq:Destroy()
			equalizers[sound] = nil
		end
	end

	local function applyAllSounds()
		for _, root in ipairs({ workspace, SoundService }) do
			for _, item in ipairs(root:GetDescendants()) do
				if item:IsA("Sound") then
					applySound(item)
				end
			end
		end
		-- 70: реверберация
		pcall(function()
			Util.set("audio.Reverb", SoundService, "AmbientReverb", Enum.ReverbType[audio.reverb])
		end)
	end
	for _, root in ipairs({ workspace, SoundService }) do
		Util.track(root.DescendantAdded:Connect(function(item)
			if item:IsA("Sound") and (audio.eq or audio.splitVolume or audio.silence) then
				task.defer(applySound, item)
			end
		end))
	end
	Util.loop(3, function()
		if audio.eq or audio.splitVolume or audio.silence or next(tracked) or next(equalizers) then
			applyAllSounds()
		end
	end)

	-- 67–68: плейлист и визуализатор
	local player = Instance.new("Sound")
	player.Name = "NocturnePlaylist"
	player.Volume = 0.5
	player.Parent = SoundService
	local playlist = { ids = {}, index = 1, shuffle = false }
	local function playIndex(index)
		if #playlist.ids == 0 then
			Util.notify("Playlist", "The playlist is empty.")
			return
		end
		playlist.index = ((index - 1) % #playlist.ids) + 1
		player.SoundId = "rbxassetid://" .. playlist.ids[playlist.index]
		player.TimePosition = 0
		player:Play()
		Util.notify("Playlist", Library:Translate("Track") .. " " .. playlist.index .. " / " .. #playlist.ids, 2)
	end
	local function nextTrack()
		if playlist.shuffle and #playlist.ids > 1 then
			local index = playlist.index
			while index == playlist.index do
				index = math.random(1, #playlist.ids)
			end
			playIndex(index)
		else
			playIndex(playlist.index + 1)
		end
	end
	Util.track(player.Ended:Connect(nextTrack))
	Library.X = Library.X or {}
	Library.X.playShared = function(id, position) -- 114: общий трек пользователей скрипта
		player.SoundId = "rbxassetid://" .. id
		player.TimePosition = position or 0
		player:Play()
	end
	Library.X.currentTrack = function()
		local id = tonumber(string.match(player.SoundId, "%d+"))
		return player.IsPlaying and id or nil, player.TimePosition
	end

	local visualizer = Util.frame({ Name = "NocturneVisualizer", BackgroundColor3 = Color3.fromRGB(13, 14, 19), BackgroundTransparency = 0.3, Position = UDim2.new(0.5, -110, 1, -180), Size = UDim2.fromOffset(220, 60), Visible = false, Parent = Window.widgetLayer })
	Util.round(visualizer, UDim.new(0, 8))
	Window:_draggable(visualizer)
	local bars = {}
	for i = 1, 24 do
		bars[i] = Util.frame({ AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Library.Theme.Accent, Position = UDim2.new(0, 6 + (i - 1) * 8.8, 1, -6), Size = UDim2.fromOffset(6, 2), Parent = visualizer })
		Util.round(bars[i], UDim.new(0, 2))
	end
	Util.track(RunService.RenderStepped:Connect(function()
		if not visualizer.Visible then
			return
		end
		local loudness = player.IsPlaying and player.PlaybackLoudness / 600 or 0
		for i, bar in ipairs(bars) do
			local wave = 0.5 + 0.5 * math.sin(os.clock() * (6 + i) + i)
			bar.Size = UDim2.fromOffset(6, 2 + math.clamp(loudness * wave, 0, 1) * 46)
			bar.BackgroundColor3 = Library.Theme.Accent
		end
	end))

	-- 72: звук уведомлений меню
	local notifySound = Instance.new("Sound")
	notifySound.Name = "NocturneNotifySound"
	notifySound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	notifySound.Volume = 0.5
	local notifySoundOn = false
	local originalNotify = Window.Notify
	Window.Notify = function(self, opts)
		if notifySoundOn then
			pcall(function()
				SoundService:PlayLocalSound(notifySound)
			end)
		end
		return originalNotify(self, opts)
	end

	Util.onUnload(function()
		audio.eq, audio.splitVolume, audio.silence = false, false, false
		applyAllSounds()
		player:Destroy()
		visualizer:Destroy()
		Window.Notify = nil
	end)

	-------------------------------- интерфейс --------------------------------
	local Mixer = AudioTab:AddSection({ Name = "Mixer", Side = "Left" })
	local split = Mixer:AddToggle({ Name = "Separate Volumes", Default = false, Callback = function(v)
		audio.splitVolume = v
		applyAllSounds()
	end })
	local splitGroup = split:AddSettings("Separate Volumes"):AddGroup()
	splitGroup:AddSlider({ Name = "Music", Min = 0, Max = 100, Default = 100, Suffix = "%", Callback = function(v)
		audio.musicScale = v / 100
	end })
	splitGroup:AddSlider({ Name = "Effects", Min = 0, Max = 100, Default = 100, Suffix = "%", Callback = function(v)
		audio.effectsScale = v / 100
	end })
	Mixer:AddToggle({ Name = "Silence Game", Default = false, Callback = function(v)
		audio.silence = v
		applyAllSounds()
	end }):AddKeybind({ Default = Enum.KeyCode.F6 })
	local eqToggle = Mixer:AddToggle({ Name = "Equalizer", Default = false, Callback = function(v)
		audio.eq = v
		applyAllSounds()
	end })
	local eqGroup = eqToggle:AddSettings("Equalizer"):AddGroup()
	for _, band in ipairs({ { "Bass", "low" }, { "Mids", "mid" }, { "Treble", "high" } }) do
		eqGroup:AddSlider({ Name = band[1], Min = -20, Max = 10, Default = 0, Suffix = " dB", Callback = function(v)
			audio[band[2]] = v
		end })
	end
	Mixer:AddDropdown({ Name = "Reverb", Options = { "NoReverb", "Room", "Hallway", "Cave", "Arena", "Hangar", "UnderWater", "Auditorium" }, Default = "NoReverb", Width = 130, Callback = function(v)
		audio.reverb = v
		applyAllSounds()
	end })
	Mixer:AddToggle({ Name = "Notification Sound", Default = false, Callback = function(v)
		notifySoundOn = v
	end })

	local Playlist = AudioTab:AddSection({ Name = "Playlist", Side = "Right" })
	local idsBox = Playlist:AddTextbox({ Name = "Track IDs", Placeholder = "id1, id2, id3", Width = 160, Callback = function(text)
		playlist.ids = {}
		for id in string.gmatch(text, "%d+") do
			table.insert(playlist.ids, id)
		end
	end })
	Playlist:AddButton({ Name = "Play", Callback = function()
		playlist.ids = {}
		for id in string.gmatch(idsBox:Get(), "%d+") do
			table.insert(playlist.ids, id)
		end
		playIndex(playlist.index)
	end })
	Playlist:AddButton({ Name = "Next", Callback = nextTrack })
	Playlist:AddButton({ Name = "Previous", Callback = function()
		playIndex(playlist.index - 1)
	end })
	Playlist:AddButton({ Name = "Stop", Callback = function()
		player:Stop()
	end })
	Playlist:AddToggle({ Name = "Shuffle", Default = false, Callback = function(v)
		playlist.shuffle = v
	end })
	Playlist:AddSlider({ Name = "Volume", Min = 0, Max = 100, Default = 50, Suffix = "%", Callback = function(v)
		player.Volume = v / 100
	end })
	Playlist:AddToggle({ Name = "Visualizer", Icon = "bars", Default = false, Callback = function(v)
		visualizer.Visible = v
	end })

	Util.tr({
		Audio = "Звук",
		Mixer = "Микшер",
		["Separate Volumes"] = "Раздельная громкость",
		Effects = "Эффекты",
		["Silence Game"] = "Тишина в игре",
		Equalizer = "Эквалайзер",
		Bass = "Басы",
		Mids = "Средние",
		Treble = "Высокие",
		Reverb = "Реверберация",
		["Notification Sound"] = "Звук уведомлений",
		Playlist = "Плейлист",
		["Track IDs"] = "ID треков",
		Next = "Следующий",
		Previous = "Предыдущий",
		Shuffle = "Перемешать",
		Visualizer = "Визуализатор",
		Track = "Трек",
		["The playlist is empty."] = "Плейлист пуст.",
	})
end

------------------------------ SOCIAL (74–90, 111–120) ------------------------------
do
	local TeleportService = game:GetService("TeleportService")
	local PlayersService = game:GetService("Players")
	local SocialTab = Tabs["Social"]
	local localPlayer = Util.player

	local function jobId()
		return game.JobId ~= "" and game.JobId or "studio"
	end

	-- отправка сообщения в обычный чат (по вашему действию)
	local lastSent = 0
	local function sendChat(text)
		if text == "" or os.clock() - lastSent < 1.5 then
			return false
		end
		lastSent = os.clock()
		local ok = pcall(function()
			local TextChatService = game:GetService("TextChatService")
			if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
				TextChatService.TextChannels.RBXGeneral:SendAsync(text)
			else
				game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
			end
		end)
		return ok
	end

	------------------------------ 74–80: чат ------------------------------
	local chat = { filterWords = {}, highlightName = false, autoReply = false, replyText = "", saveHistory = false, history = {} }
	local filterInstalled = false
	local function installChatCallback()
		local TextChatService = game:GetService("TextChatService")
		if TextChatService.ChatVersion ~= Enum.ChatVersion.TextChatService then
			return
		end
		local needed = #chat.filterWords > 0 or chat.highlightName
		if needed and not filterInstalled then
			filterInstalled = true
			TextChatService.OnIncomingMessage = function(message)
				local properties = Instance.new("TextChatMessageProperties")
				local text = string.lower(message.Text or "")
				for _, word in ipairs(chat.filterWords) do
					if word ~= "" and string.find(text, word, 1, true) then
						properties.Text = "<i>" .. Library:Translate("[hidden by filter]") .. "</i>"
						return properties
					end
				end
				if chat.highlightName then
					local me = string.lower(localPlayer.Name)
					local myDisplay = string.lower(localPlayer.DisplayName)
					if string.find(text, me, 1, true) or string.find(text, myDisplay, 1, true) then
						properties.PrefixText = '<font color="#FFD166">★</font> ' .. (message.PrefixText or "")
					end
				end
				return properties
			end
		elseif not needed and filterInstalled then
			filterInstalled = false
			TextChatService.OnIncomingMessage = nil
		end
	end
	Util.onUnload(function()
		chat.filterWords, chat.highlightName = {}, false
		pcall(installChatCallback)
	end)

	local lastReply = 0
	pcall(function()
		local TextChatService = game:GetService("TextChatService")
		Util.track(TextChatService.MessageReceived:Connect(function(message)
			local source = message.TextSource
			local name = source and source.Name or "?"
			local line = os.date("[%H:%M] ") .. name .. ": " .. tostring(message.Text)
			table.insert(chat.history, line)
			if #chat.history > 200 then
				table.remove(chat.history, 1)
			end
			-- 78: история в файл
			if chat.saveHistory and type(appendfile) == "function" then
				pcall(appendfile, "nocturne_chat.txt", line .. "\n")
			end
			-- 79: автоответ, если упомянули ваш ник (не чаще раза в 15 секунд)
			if chat.autoReply and chat.replyText ~= "" and source and source.UserId ~= localPlayer.UserId then
				local text = string.lower(message.Text or "")
				if (string.find(text, string.lower(localPlayer.Name), 1, true) or string.find(text, string.lower(localPlayer.DisplayName), 1, true))
					and os.clock() - lastReply > 15
				then
					lastReply = os.clock()
					task.delay(1, function()
						sendChat(chat.replyText)
					end)
				end
			end
		end))
	end)

	local Chat = SocialTab:AddSection({ Name = "Chat Tools", Side = "Left" })
	local phraseBoxes = {}
	for slot = 1, 3 do
		phraseBoxes[slot] = Chat:AddTextbox({ Name = Library:Translate("Phrase") .. " " .. slot, Placeholder = "gg", Width = 140 })
		Chat:AddButton({ Name = Library:Translate("Send Phrase") .. " " .. slot, Callback = function()
			if not sendChat(phraseBoxes[slot]:Get()) then
				Util.notify("Chat", "Could not send the message.")
			end
		end })
	end
	Chat:AddTextbox({ Name = "Hide Words", Placeholder = "word1, word2", Width = 140, Callback = function(text)
		chat.filterWords = {}
		for word in string.gmatch(string.lower(text), "[^,]+") do
			table.insert(chat.filterWords, (string.gsub(word, "^%s*(.-)%s*$", "%1")))
		end
		pcall(installChatCallback)
	end })
	Chat:AddToggle({ Name = "Highlight My Name", Default = false, Callback = function(v)
		chat.highlightName = v
		pcall(installChatCallback)
	end })
	Chat:AddButton({ Name = "Copy Last Messages", Callback = function()
		local from = math.max(1, #chat.history - 19)
		Util.clip(table.concat(chat.history, "\n", from))
	end })
	Chat:AddToggle({ Name = "Save Chat to File", Default = false, Callback = function(v)
		chat.saveHistory = v
		if v and type(appendfile) ~= "function" then
			Util.notify("Chat", "This executor has no appendfile.")
		end
	end })
	local replyBox = Chat:AddTextbox({ Name = "Auto Reply Text", Placeholder = "brb", Width = 140, Callback = function(text)
		chat.replyText = text
	end })
	Chat:AddToggle({ Name = "Auto Reply on Mention", Default = false, Callback = function(v)
		chat.autoReply = v
		chat.replyText = replyBox:Get()
	end })
	-- 80: напоминание
	local reminderText = Chat:AddTextbox({ Name = "Reminder", Placeholder = "text", Width = 140 })
	local reminderMinutes = Chat:AddTextbox({ Name = "In Minutes", Placeholder = "5", Width = 80 })
	Chat:AddButton({ Name = "Set Reminder", Callback = function()
		local minutes = tonumber(reminderMinutes:Get())
		local text = reminderText:Get()
		if not minutes then
			Util.notify("Reminder", "Enter the number of minutes.")
			return
		end
		task.delay(minutes * 60, function()
			if Util.alive() then
				Util.notify("Reminder", text ~= "" and text or "⏰", 8)
			end
		end)
		Util.notify("Reminder", Library:Translate("Reminder set") .. ": " .. minutes .. " min")
	end })

	------------------------------ 81–90: сервера ------------------------------
	local FAV_FILE = "nocturne_favorites.json"
	local favorites = Util.readFile(FAV_FILE, { friends = {}, places = {}, servers = {}, private = {}, playtime = {} })
	favorites.friends = favorites.friends or {}
	favorites.places = favorites.places or {}
	favorites.servers = favorites.servers or {}
	favorites.private = favorites.private or {}
	favorites.playtime = favorites.playtime or {}
	local function saveFavorites()
		if not Util.writeFile(FAV_FILE, favorites) then
			Util.notify("Favorites", "Saving needs writefile (executor).")
		end
	end

	-- 83: история серверов
	table.insert(favorites.servers, 1, { placeId = game.PlaceId, jobId = game.JobId, at = os.time() })
	while #favorites.servers > 10 do
		table.remove(favorites.servers)
	end
	-- 88: время в каждой игре
	local placeKey = tostring(game.PlaceId)
	Util.loop(30, function()
		favorites.playtime[placeKey] = (favorites.playtime[placeKey] or 0) + 30
		Util.writeFile(FAV_FILE, favorites)
	end)

	local placeNames = {}
	local function placeName(placeId)
		if placeNames[placeId] then
			return placeNames[placeId]
		end
		local ok, info = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(placeId)
		end)
		placeNames[placeId] = ok and info and info.Name or tostring(placeId)
		return placeNames[placeId]
	end

	local Servers = SocialTab:AddSection({ Name = "Servers", Side = "Right" })
	-- перезайти, случайный сервер, автоперезаход (раньше были в Misc → Server)
	Servers:AddButton({ Name = "Rejoin Server", Callback = function()
		Util.notify("Server", "Rejoining...")
		local ok = pcall(function()
			if game.JobId ~= "" then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
			else
				TeleportService:Teleport(game.PlaceId, localPlayer)
			end
		end)
		if not ok then
			Util.notify("Server", "Rejoin failed.")
		end
	end })
	Servers:AddButton({ Name = "Server Hop", Callback = function()
		task.spawn(function()
			local ok, body = pcall(function()
				return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
			end)
			local data = ok and Util.unjson(body)
			local list = {}
			for _, server in ipairs(data and data.data or {}) do
				if server.id ~= game.JobId and (server.playing or 0) < (server.maxPlayers or 0) then
					table.insert(list, server)
				end
			end
			if #list == 0 then
				Util.notify("Server", "No other servers found.")
				return
			end
			local pick = list[math.random(1, #list)]
			pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, localPlayer)
			end)
		end)
	end })
	local autoRejoin = false
	Util.track(game:GetService("GuiService").ErrorMessageChanged:Connect(function(message)
		if autoRejoin and message ~= "" then
			task.wait(2)
			pcall(function()
				TeleportService:Teleport(game.PlaceId, localPlayer)
			end)
		end
	end))
	Servers:AddToggle({ Name = "Auto Rejoin", Default = false, Callback = function(v)
		autoRejoin = v
	end })
	-- 84: фильтр серверов
	Servers:AddDropdown({ Name = "Server Filter", Options = { "Lowest Ping", "Most Players", "Least Players" }, Default = "Lowest Ping", Width = 130, Flag = "nocturne_server_filter" })
	Servers:AddButton({ Name = "Join Filtered Server", Callback = function()
		task.spawn(function()
			local ok, body = pcall(function()
				return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
			end)
			local data = ok and Util.unjson(body)
			local list = {}
			for _, server in ipairs(data and data.data or {}) do
				if server.id ~= game.JobId and (server.playing or 0) < (server.maxPlayers or 0) then
					table.insert(list, server)
				end
			end
			if #list == 0 then
				Util.notify("Server", "No other servers found.")
				return
			end
			local mode = Library.Flags.nocturne_server_filter
			table.sort(list, function(a, b)
				if mode == "Most Players" then
					return a.playing > b.playing
				elseif mode == "Least Players" then
					return a.playing < b.playing
				end
				return (a.ping or 9999) < (b.ping or 9999)
			end)
			pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, list[1].id, localPlayer)
			end)
		end)
	end })
	-- 85: повторять попытку, если сервер полон
	local retryFull = false
	local lastTeleport = nil
	Util.track(TeleportService.TeleportInitFailed:Connect(function(player, result, _, placeId, options)
		if retryFull and player == localPlayer and result == Enum.TeleportResult.GameFull then
			Util.notify("Server", "Server is full — retrying in 10 s.")
			task.delay(10, function()
				if retryFull and lastTeleport then
					pcall(lastTeleport)
				end
			end)
		end
	end))
	Servers:AddToggle({ Name = "Retry When Full", Default = false, Callback = function(v)
		retryFull = v
	end })
	-- ссылки и вход по ID — отдельная секция, чтобы «Сервера» не разрастались
	local Links = SocialTab:AddSection({ Name = "Links", Side = "Left" })
	Links:AddButton({ Name = "Copy Server Link", Callback = function()
		if Util.clip("roblox://experiences/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId) then
			Util.notify("Server", "Server link copied.")
		end
	end })
	Links:AddButton({ Name = "Copy Game Link", Callback = function()
		if Util.clip("https://www.roblox.com/games/" .. game.PlaceId) then
			Util.notify("Server", "Game link copied.")
		end
	end })
	local placeBox = Links:AddTextbox({ Name = "Place ID", Placeholder = "123456", Width = 120 })
	Links:AddButton({ Name = "Join Place", Callback = function()
		local placeId = tonumber(string.match(placeBox:Get(), "%d+"))
		if not placeId then
			Util.notify("Server", "Enter a place ID.")
			return
		end
		pcall(function()
			TeleportService:Teleport(placeId, localPlayer)
		end)
	end })
	-- 83: история
	local historyDropdown = Servers:AddDropdown({ Name = "Server History", Options = {}, AllowNone = true, Width = 150 })
	local historyMap = {}
	local function refreshHistory()
		historyMap = {}
		local options = {}
		for index, entry in ipairs(favorites.servers) do
			local caption = index .. ". " .. os.date("%d.%m %H:%M", entry.at or 0) .. " · " .. tostring(entry.placeId)
			historyMap[caption] = entry
			table.insert(options, caption)
		end
		historyDropdown:Refresh(options)
	end
	refreshHistory()
	Servers:AddButton({ Name = "Return to Server", Callback = function()
		local entry = historyMap[historyDropdown:Get() or ""]
		if not entry then
			Util.notify("Server", "Pick a server from the history.")
			return
		end
		lastTeleport = function()
			TeleportService:TeleportToPlaceInstance(entry.placeId, entry.jobId, localPlayer)
		end
		pcall(lastTeleport)
	end })
	-- 87: приватные сервера — храним ссылки
	local privateBox = Links:AddTextbox({ Name = "Private Link", Placeholder = "https://...", Width = 150 })
	Links:AddButton({ Name = "Save Private Link", Callback = function()
		local link = privateBox:Get()
		if link ~= "" then
			table.insert(favorites.private, link)
			saveFavorites()
			Util.notify("Server", "Link saved.")
		end
	end })
	Links:AddButton({ Name = "Copy Saved Links", Callback = function()
		Util.clip(table.concat(favorites.private, "\n"))
	end })
	-- 88: время в этой игре
	local playtimeLabel = Servers:AddLabel("Time in this game")
	Util.loop(5, function()
		playtimeLabel:Set(Library:Translate("Time in this game") .. ": " .. Util.clock(favorites.playtime[placeKey] or 0))
	end)

	local Favorites = SocialTab:AddSection({ Name = "Favorites", Side = "Right" })
	-- 82: избранные места
	local placesDropdown = Favorites:AddDropdown({ Name = "Favorite Places", Options = {}, AllowNone = true, Width = 150 })
	local placeMap = {}
	local function refreshPlaces()
		placeMap = {}
		local options = {}
		for _, placeId in ipairs(favorites.places) do
			local caption = placeName(placeId)
			placeMap[caption] = placeId
			table.insert(options, caption)
		end
		placesDropdown:Refresh(options)
	end
	task.spawn(refreshPlaces)
	Favorites:AddButton({ Name = "Add This Game", Callback = function()
		if not table.find(favorites.places, game.PlaceId) then
			table.insert(favorites.places, game.PlaceId)
			saveFavorites()
		end
		task.spawn(refreshPlaces)
	end })
	Favorites:AddButton({ Name = "Join Favorite Place", Callback = function()
		local placeId = placeMap[placesDropdown:Get() or ""]
		if placeId then
			pcall(function()
				TeleportService:Teleport(placeId, localPlayer)
			end)
		end
	end })
	-- 81: избранные друзья
	local friendsDropdown = Favorites:AddDropdown({ Name = "Favorite Friends", Options = {}, AllowNone = true, Width = 150 })
	local onlineMap = {}
	local function refreshFriends()
		task.spawn(function()
			local ok, list = pcall(function()
				return localPlayer:GetFriendsOnline(50)
			end)
			onlineMap = {}
			local options = {}
			for _, friend in ipairs(ok and list or {}) do
				local favorite = table.find(favorites.friends, friend.VisitorId) ~= nil
				local caption = (favorite and "★ " or "") .. tostring(friend.DisplayName or friend.UserName)
				onlineMap[caption] = friend
				table.insert(options, favorite and 1 or #options + 1, caption)
			end
			friendsDropdown:Refresh(options)
		end)
	end
	Favorites:AddButton({ Name = "Refresh Friends", Callback = refreshFriends })
	Favorites:AddButton({ Name = "Toggle Favorite", Callback = function()
		local friend = onlineMap[friendsDropdown:Get() or ""]
		if not friend then
			return
		end
		local index = table.find(favorites.friends, friend.VisitorId)
		if index then
			table.remove(favorites.friends, index)
		else
			table.insert(favorites.friends, friend.VisitorId)
		end
		saveFavorites()
		refreshFriends()
	end })
	Favorites:AddButton({ Name = "Join Friend", Callback = function()
		local friend = onlineMap[friendsDropdown:Get() or ""]
		if friend and friend.PlaceId and friend.GameId then
			pcall(function()
				TeleportService:TeleportToPlaceInstance(friend.PlaceId, friend.GameId, localPlayer)
			end)
		else
			Util.notify("Friends", "Pick a friend who is in a game.")
		end
	end })

	-- 89–90: автозапуск после телепорта и профиль на каждую игру
	local Auto = SocialTab:AddSection({ Name = "Auto Launch", Side = "Left" })
	local queueFunction = (syn and syn.queue_on_teleport) or queue_on_teleport or queueonteleport
	local autoRelaunch = false
	Util.track(localPlayer.OnTeleport:Connect(function(state)
		if autoRelaunch and state == Enum.TeleportState.Started and type(queueFunction) == "function" then
			pcall(queueFunction, 'loadstring(game:HttpGet("' .. Util.SCRIPT_URL .. '"))()')
		end
	end))
	Auto:AddToggle({ Name = "Relaunch After Teleport", Default = false, Callback = function(v)
		autoRelaunch = v
		if v and type(queueFunction) ~= "function" then
			Util.notify("Auto Launch", "This executor has no queue_on_teleport.")
		end
	end })
	local perGame = Auto:AddToggle({ Name = "Profile per Game", Default = false })
	Auto:AddButton({ Name = "Save Profile for This Game", Callback = function()
		local ok = Library:SaveConfig("place_" .. game.PlaceId)
		Util.notify("Config", ok and "Saved for this game." or "Saving needs writefile (executor).")
	end })
	task.delay(2, function()
		if perGame:Get() and Library:LoadConfig("place_" .. game.PlaceId) then
			Util.notify("Config", "Loaded the profile for this game.")
		end
	end)

	------------------------------ 111–120: синхронизация ------------------------------
	-- Работает при включённой Synchronization (меню профиля) и новом server/presence-server.js.
	local Group = SocialTab:AddSection({ Name = "Script Users", Side = "Left" })
	local onlineLabel = Group:AddLabel("Online")

	-- 112: чат пользователей скрипта
	local groupChat = {}
	local chatWidget = Util.textWidget("ScriptChat", "Script Chat", UDim2.fromOffset(460, 330), "cast", function()
		local from = math.max(1, #groupChat - 7)
		local lines = {}
		for index = from, #groupChat do
			table.insert(lines, groupChat[index])
		end
		return #lines > 0 and lines or { "—" }
	end)
	local function pushGroupLine(name, text)
		table.insert(groupChat, name .. ": " .. text)
		if #groupChat > 50 then
			table.remove(groupChat, 1)
		end
	end
	local groupBox = Group:AddTextbox({ Name = "Message", Placeholder = "hi", Width = 140 })
	Group:AddButton({ Name = "Send to Script Users", Callback = function()
		local text = groupBox:Get()
		if text == "" then
			return
		end
		if Library:SendSyncEvent("chat", { text = text }) then
			pushGroupLine(localPlayer.DisplayName, text)
			groupBox:Set("", true)
		else
			Util.notify("Synchronization", "Turn on Synchronization in the profile menu.")
		end
	end })
	Group:AddToggle({ Name = "Script Chat Window", Icon = "cast", Default = false, Callback = function(v)
		chatWidget:SetVisible(v)
	end })

	-- 116–117: общие метки и таймер
	Group:AddButton({ Name = "Share Waypoint Here", Callback = function()
		local root = Util.root()
		if root and Library:SendSyncEvent("waypoint", { x = root.Position.X, y = root.Position.Y, z = root.Position.Z, name = localPlayer.DisplayName }) then
			if Library.X and Library.X.addWaypoint then
				Library.X.addWaypoint(localPlayer.DisplayName, root.Position)
			end
			Util.notify("Synchronization", "Waypoint shared.")
		end
	end })
	local timerBox = Group:AddTextbox({ Name = "Group Timer (sec)", Placeholder = "60", Width = 90 })
	Group:AddButton({ Name = "Start Group Timer", Callback = function()
		local seconds = tonumber(timerBox:Get())
		if seconds and seconds > 0 and Library:SendSyncEvent("timer", { seconds = seconds, label = localPlayer.DisplayName }) then
			if Library.X and Library.X.startCountdown then
				Library.X.startCountdown(seconds, localPlayer.DisplayName)
			end
		end
	end })
	-- 114: общий трек
	local acceptMusic = true
	Group:AddButton({ Name = "Share Current Track", Callback = function()
		local id, position = nil, 0
		if Library.X and Library.X.currentTrack then
			id, position = Library.X.currentTrack()
		end
		if not id then
			Util.notify("Synchronization", "Start a track in Audio → Playlist first.")
			return
		end
		Library:SendSyncEvent("music", { id = id, position = position })
	end })
	Group:AddToggle({ Name = "Accept Shared Music", Default = true, Callback = function(v)
		acceptMusic = v
	end })

	-- приём событий
	Library:OnSyncEvent(function(event)
		local player = PlayersService:GetPlayerByUserId(tonumber(event.from) or 0)
		local name = player and player.DisplayName or tostring(event.from)
		local data = event.data or {}
		if event.type == "chat" and data.text then
			pushGroupLine(name, data.text)
			Util.notify("Script Chat", name .. ": " .. data.text)
		elseif event.type == "waypoint" and data.x and Library.X and Library.X.addWaypoint then
			Library.X.addWaypoint(data.name or name, Vector3.new(data.x, data.y, data.z))
			Util.notify("Synchronization", name .. " " .. Library:Translate("shared a waypoint"))
		elseif event.type == "timer" and data.seconds and Library.X and Library.X.startCountdown then
			Library.X.startCountdown(data.seconds, data.label or name)
		elseif event.type == "music" and data.id and acceptMusic and Library.X and Library.X.playShared then
			Library.X.playShared(data.id, data.position)
			Util.notify("Synchronization", name .. " " .. Library:Translate("shared a track"))
		end
	end)

	-- 113: обмен конфигами по коду
	local Share = SocialTab:AddSection({ Name = "Config Share", Side = "Right" })
	Share:AddButton({ Name = "Share My Config", Callback = function()
		task.spawn(function()
			local data, err = Library:SyncRequest("/config", { userId = localPlayer.UserId, jobId = jobId(), config = Util.json(Library:GetConfig()) })
			if data and data.code then
				Util.clip(data.code)
				Util.notify("Config", Library:Translate("Code") .. ": " .. data.code .. " (" .. Library:Translate("copied") .. ")", 8)
			else
				Util.notify("Config", Library:Translate("Not connected") .. ": " .. tostring(err))
			end
		end)
	end })
	local codeBox = Share:AddTextbox({ Name = "Config Code", Placeholder = "ABC123", Width = 110 })
	Share:AddButton({ Name = "Load by Code", Callback = function()
		task.spawn(function()
			local data, err = Library:SyncRequest("/config/get", { userId = localPlayer.UserId, jobId = jobId(), code = codeBox:Get() })
			local config = data and data.config and Util.unjson(data.config)
			if config then
				Library:ApplyConfig(config)
				Util.notify("Config", "Config imported.")
			else
				Util.notify("Config", Library:Translate("Code not found") .. (err and (": " .. tostring(err)) or ""))
			end
		end)
	end })

	-- 118–119: рейтинг и общий онлайн
	local names = {}
	local function nameOf(userId)
		if names[userId] then
			return names[userId]
		end
		names[userId] = tostring(userId)
		task.spawn(function()
			local ok, name = pcall(function()
				return PlayersService:GetNameFromUserIdAsync(userId)
			end)
			if ok then
				names[userId] = name
			end
		end)
		return names[userId]
	end
	local rankingWidget = Util.textWidget("ScriptRanking", "Top Playtime", UDim2.fromOffset(460, 480), "crosshair", function()
		local lines = {}
		for index, entry in ipairs(Library.SyncInfo.ranking or {}) do
			table.insert(lines, index .. ". " .. (Library.Settings.SafeMode and Library:Translate("Hidden") or nameOf(entry.userId)) .. " — " .. Util.clock(entry.seconds or 0))
		end
		return #lines > 0 and lines or { "—" }
	end)
	Group:AddToggle({ Name = "Playtime Ranking", Icon = "crosshair", Default = false, Callback = function(v)
		rankingWidget:SetVisible(v)
	end })

	-- 120: приглашения
	local lastInvite = nil
	Library:OnSyncData(function(data)
		onlineLabel:Set(Library:Translate("Script users online") .. ": " .. tostring(data.online or 0))
		for _, invite in ipairs(data.invites or {}) do
			lastInvite = invite
			Util.notify("Invite", nameOf(invite.from) .. " " .. Library:Translate("invites you — press Accept Invite"), 10)
		end
	end)
	local inviteDropdown = Group:AddDropdown({ Name = "Invite Friend", Options = {}, AllowNone = true, Width = 150 })
	local inviteMap = {}
	Group:AddButton({ Name = "Refresh Friend List", Callback = function()
		task.spawn(function()
			local ok, list = pcall(function()
				return localPlayer:GetFriendsOnline(50)
			end)
			inviteMap = {}
			local options = {}
			for _, friend in ipairs(ok and list or {}) do
				local caption = tostring(friend.DisplayName or friend.UserName)
				inviteMap[caption] = friend.VisitorId
				table.insert(options, caption)
			end
			inviteDropdown:Refresh(options)
		end)
	end })
	Group:AddButton({ Name = "Send Invite", Callback = function()
		local target = inviteMap[inviteDropdown:Get() or ""]
		if not target then
			Util.notify("Invite", "Pick a friend.")
			return
		end
		task.spawn(function()
			local data, err = Library:SyncRequest("/invite", { userId = localPlayer.UserId, jobId = jobId(), placeId = game.PlaceId, target = target })
			Util.notify("Invite", data and "Invite sent (they need this script with Synchronization)." or (Library:Translate("Not connected") .. ": " .. tostring(err)))
		end)
	end })
	Group:AddButton({ Name = "Accept Invite", Callback = function()
		if not lastInvite then
			Util.notify("Invite", "No invites yet.")
			return
		end
		pcall(function()
			TeleportService:TeleportToPlaceInstance(lastInvite.placeId, lastInvite.jobId, localPlayer)
		end)
	end })

	Util.tr({
		Social = "Общение",
		Links = "Ссылки",
		["Join Place"] = "Зайти в место",
		["Place ID"] = "ID места",
		["Enter a place ID."] = "Введите ID места.",
		["Weather & Particles"] = "Погода и частицы",
		["Chat Tools"] = "Чат",
		Phrase = "Фраза",
		["Send Phrase"] = "Отправить фразу",
		["Hide Words"] = "Скрывать слова",
		["Highlight My Name"] = "Подсвечивать мой ник",
		["Copy Last Messages"] = "Скопировать последние сообщения",
		["Save Chat to File"] = "Сохранять чат в файл",
		["Auto Reply Text"] = "Текст автоответа",
		["Auto Reply on Mention"] = "Автоответ на упоминание",
		Reminder = "Напоминание",
		["In Minutes"] = "Через минут",
		["Set Reminder"] = "Поставить напоминание",
		["Reminder set"] = "Напоминание поставлено",
		["Enter the number of minutes."] = "Введите число минут.",
		["[hidden by filter]"] = "[скрыто фильтром]",
		Servers = "Сервера",
		["Server Filter"] = "Фильтр серверов",
		["Join Filtered Server"] = "Зайти на подходящий",
		["Retry When Full"] = "Повторять, если полон",
		["Copy Server Link"] = "Скопировать ссылку на сервер",
		["Server History"] = "История серверов",
		["Return to Server"] = "Вернуться на сервер",
		["Private Link"] = "Ссылка приват-сервера",
		["Save Private Link"] = "Сохранить ссылку",
		["Copy Saved Links"] = "Скопировать ссылки",
		["Time in this game"] = "Время в этой игре",
		Favorites = "Избранное",
		["Favorite Places"] = "Избранные игры",
		["Add This Game"] = "Добавить эту игру",
		["Join Favorite Place"] = "Зайти в игру",
		["Favorite Friends"] = "Избранные друзья",
		["Toggle Favorite"] = "В избранное / убрать",
		["Auto Launch"] = "Автозапуск",
		["Relaunch After Teleport"] = "Запускать после телепорта",
		["Profile per Game"] = "Профиль на каждую игру",
		["Save Profile for This Game"] = "Сохранить профиль для игры",
		["Script Users"] = "Пользователи скрипта",
		Online = "Онлайн",
		["Script users online"] = "Пользователей скрипта онлайн",
		["Send to Script Users"] = "Отправить пользователям скрипта",
		["Script Chat Window"] = "Окно чата скрипта",
		["Script Chat"] = "Чат скрипта",
		["Share Waypoint Here"] = "Поделиться меткой здесь",
		["Group Timer (sec)"] = "Общий таймер (сек)",
		["Start Group Timer"] = "Запустить общий таймер",
		["Share Current Track"] = "Поделиться треком",
		["Accept Shared Music"] = "Принимать музыку",
		["shared a waypoint"] = "поделился меткой",
		["shared a track"] = "включил трек для всех",
		["Config Share"] = "Обмен конфигами",
		["Share My Config"] = "Поделиться конфигом",
		["Config Code"] = "Код конфига",
		["Load by Code"] = "Загрузить по коду",
		Code = "Код",
		copied = "скопирован",
		["Code not found"] = "Код не найден",
		["Top Playtime"] = "Топ по времени",
		["Playtime Ranking"] = "Рейтинг по времени",
		["Invite Friend"] = "Пригласить друга",
		["Refresh Friend List"] = "Обновить друзей",
		["Send Invite"] = "Отправить приглашение",
		["Accept Invite"] = "Принять приглашение",
		["invites you — press Accept Invite"] = "зовёт вас — нажмите «Принять приглашение»",
	})
end

------------------------------ TOOLS (91–99) ------------------------------
-- Инструменты только для просмотра: ничего в игре не вызывают и не меняют.
do
	local RunService = game:GetService("RunService")
	local LogService = game:GetService("LogService")
	local Stats = game:GetService("Stats")
	local ToolsTab = Tabs["Tools"]

	------------------------- 91/92/94: просмотрщик объектов -------------------------
	local explorer = Util.frame({ Name = "NocturneExplorer", BackgroundColor3 = Color3.fromRGB(20, 21, 27), Position = UDim2.new(0.5, -170, 0.5, -200), Size = UDim2.fromOffset(340, 400), Visible = false, Parent = Window.widgetLayer })
	Util.round(explorer, UDim.new(0, 10))
	local explorerStroke = Instance.new("UIStroke")
	explorerStroke.Color = Color3.fromRGB(48, 48, 54)
	explorerStroke.Parent = explorer
	Window:_draggable(explorer)
	local pathLabel = Util.text({ Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -110, 0, 20), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = explorer })
	local function smallButton(text, x)
		local button = Instance.new("TextButton")
		button.Text = text
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 11
		button.TextColor3 = Color3.fromRGB(226, 227, 233)
		button.BackgroundColor3 = Color3.fromRGB(36, 37, 46)
		button.AutoButtonColor = true
		button.AnchorPoint = Vector2.new(1, 0)
		button.Position = UDim2.new(1, x, 0, 6)
		button.Size = UDim2.fromOffset(44, 20)
		button.Parent = explorer
		Util.round(button, UDim.new(0, 5))
		return button
	end
	local upButton = smallButton("Up", -56)
	local closeButton = smallButton("×", -8)
	local list = Instance.new("ScrollingFrame")
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.Position = UDim2.fromOffset(6, 32)
	list.Size = UDim2.new(1, -12, 1, -150)
	list.CanvasSize = UDim2.new()
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollBarThickness = 3
	list.Parent = explorer
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 1)
	layout.Parent = list
	local propsLabel = Util.text({ Position = UDim2.new(0, 10, 1, -112), Size = UDim2.new(1, -20, 0, 104), TextSize = 11, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Parent = explorer })

	local current, selected = game, nil
	local function describe(item)
		local lines = { "Class: " .. item.ClassName, "Path: " .. item:GetFullName() }
		pcall(function()
			if item:IsA("BasePart") then
				table.insert(lines, string.format("Position: %.1f, %.1f, %.1f", item.Position.X, item.Position.Y, item.Position.Z))
				table.insert(lines, string.format("Size: %.1f, %.1f, %.1f", item.Size.X, item.Size.Y, item.Size.Z))
				table.insert(lines, "Anchored: " .. tostring(item.Anchored) .. "  Transparency: " .. item.Transparency)
			elseif item:IsA("ValueBase") then
				table.insert(lines, "Value: " .. tostring(item.Value))
			elseif item:IsA("Sound") then
				table.insert(lines, "SoundId: " .. item.SoundId)
			end
			table.insert(lines, "Children: " .. #item:GetChildren())
		end)
		return table.concat(lines, "\n")
	end
	local function showItems(items, title)
		for _, child in ipairs(list:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		pathLabel.Text = title
		for index, item in ipairs(items) do
			if index > 300 then
				break
			end
			local button = Instance.new("TextButton")
			button.BackgroundColor3 = Color3.fromRGB(28, 29, 36)
			button.BackgroundTransparency = 0.2
			button.AutoButtonColor = true
			button.Size = UDim2.new(1, -4, 0, 20)
			button.Font = Enum.Font.Gotham
			button.TextSize = 12
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.TextColor3 = Color3.fromRGB(210, 212, 222)
			button.Text = "  " .. item.Name .. "  ·  " .. item.ClassName
			button.LayoutOrder = index
			button.Parent = list
			button.MouseButton1Click:Connect(function()
				if selected == item then
					-- второй клик — войти внутрь
					current = item
					showItems(item:GetChildren(), item:GetFullName())
				else
					selected = item
					propsLabel.Text = describe(item)
				end
			end)
		end
	end
	local function openItem(item)
		current, selected = item, nil
		propsLabel.Text = ""
		showItems(item:GetChildren(), item == game and "game" or item:GetFullName())
	end
	upButton.MouseButton1Click:Connect(function()
		if current ~= game and current.Parent then
			openItem(current.Parent)
		end
	end)
	closeButton.MouseButton1Click:Connect(function()
		explorer.Visible = false
	end)

	local function collect(className)
		local found = {}
		for _, item in ipairs(game:GetDescendants()) do
			local ok, match = pcall(function()
				return item:IsA(className)
			end)
			if ok and match then
				table.insert(found, item)
			end
		end
		return found
	end

	------------------------------ 95/96: рулетка ------------------------------
	local measure = { a = nil, b = nil }
	local beamA = Instance.new("Attachment")
	local beamB = Instance.new("Attachment")
	beamA.Parent, beamB.Parent = workspace.Terrain, workspace.Terrain
	local beam = Instance.new("Beam")
	beam.Name = "NocturneRuler"
	beam.Attachment0, beam.Attachment1 = beamA, beamB
	beam.Width0, beam.Width1 = 0.25, 0.25
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.Color = ColorSequence.new(Color3.fromRGB(100, 133, 247))
	beam.Enabled = false
	beam.Parent = workspace.Terrain
	local function reportMeasure()
		if not (measure.a and measure.b) then
			return
		end
		local delta = measure.b - measure.a
		local flat = Vector3.new(delta.X, 0, delta.Z).Magnitude
		local slope = math.deg(math.atan2(delta.Y, math.max(flat, 0.001)))
		Util.notify("Ruler", string.format("%s: %.1f st · %s: %.1f · %s: %.1f°",
			Library:Translate("Distance"), delta.Magnitude, Library:Translate("Height"), delta.Y, Library:Translate("Slope"), slope), 8)
		beamA.Position, beamB.Position = measure.a, measure.b
		beam.Enabled = true
	end

	------------------------------ 98: консоль ------------------------------
	local consoleLines = {}
	Util.track(LogService.MessageOut:Connect(function(message, kind)
		local prefix = kind == Enum.MessageType.MessageError and "[E] " or kind == Enum.MessageType.MessageWarning and "[W] " or ""
		table.insert(consoleLines, os.date("%H:%M:%S ") .. prefix .. message)
		if #consoleLines > 200 then
			table.remove(consoleLines, 1)
		end
	end))
	local consoleWidget = Util.textWidget("Console", "Console", UDim2.fromOffset(460, 160), "terminal", function()
		local lines = {}
		for index = math.max(1, #consoleLines - 9), #consoleLines do
			table.insert(lines, string.sub(consoleLines[index], 1, 70))
		end
		return #lines > 0 and lines or { "—" }
	end)

	------------------------------ 99: профилировщик ------------------------------
	local frameTime, frameCount, fpsValue, lastTick = 0, 0, 0, os.clock()
	Util.track(RunService.RenderStepped:Connect(function(dt)
		frameTime = dt
		frameCount += 1
		local now = os.clock()
		if now - lastTick >= 0.5 then
			fpsValue = frameCount / (now - lastTick)
			frameCount, lastTick = 0, now
		end
	end))
	local profilerWidget = Util.textWidget("Profiler", "Profiler", UDim2.fromOffset(460, 360), "chip", function()
		local memory, menuMemory = 0, #Window.gui:GetDescendants()
		pcall(function()
			memory = Stats:GetTotalMemoryUsageMb()
		end)
		return {
			string.format("FPS: %d  ·  %.1f ms", math.floor(fpsValue + 0.5), frameTime * 1000),
			string.format("RAM: %d MB", memory),
			"Menu objects: " .. menuMemory,
			"Menu connections: " .. #Window._connections,
			"Instances in game: " .. tostring(#workspace:GetDescendants()),
		}
	end)

	Util.onUnload(function()
		explorer:Destroy()
		beam:Destroy()
		beamA:Destroy()
		beamB:Destroy()
	end)

	-------------------------------- интерфейс --------------------------------
	local Explorer = ToolsTab:AddSection({ Name = "Explorer", Side = "Left" })
	Explorer:AddButton({ Name = "Open Explorer", Callback = function()
		explorer.Visible = true
		openItem(current or game)
	end })
	Explorer:AddButton({ Name = "Copy Selected Path", Callback = function()
		if selected and Util.clip(selected:GetFullName()) then
			Util.notify("Explorer", "Path copied.")
		end
	end })
	Explorer:AddButton({ Name = "List Remotes", Callback = function()
		explorer.Visible = true
		local remotes = collect("RemoteEvent")
		for _, item in ipairs(collect("RemoteFunction")) do
			table.insert(remotes, item)
		end
		showItems(remotes, Library:Translate("Remotes") .. ": " .. #remotes)
	end })
	Explorer:AddButton({ Name = "List Sounds", Callback = function()
		explorer.Visible = true
		local sounds = collect("Sound")
		showItems(sounds, Library:Translate("Sounds") .. ": " .. #sounds)
	end })

	local Ruler = ToolsTab:AddSection({ Name = "Ruler", Side = "Left" })
	Ruler:AddButton({ Name = "Set Point A (here)", Callback = function()
		local root = Util.root()
		if root then
			measure.a = root.Position
			reportMeasure()
		end
	end })
	Ruler:AddButton({ Name = "Set Point B (here)", Callback = function()
		local root = Util.root()
		if root then
			measure.b = root.Position
			reportMeasure()
		end
	end })
	Ruler:AddButton({ Name = "Clear Ruler", Callback = function()
		measure.a, measure.b = nil, nil
		beam.Enabled = false
	end })

	local Debug = ToolsTab:AddSection({ Name = "Debug", Side = "Right" })
	Debug:AddToggle({ Name = "Console Window", Icon = "terminal", Default = false, Callback = function(v)
		consoleWidget:SetVisible(v)
	end })
	Debug:AddButton({ Name = "Copy Console", Callback = function()
		Util.clip(table.concat(consoleLines, "\n"))
	end })
	Debug:AddToggle({ Name = "Profiler", Icon = "chip", Default = false, Callback = function(v)
		profilerWidget:SetVisible(v)
	end })

	Util.tr({
		Tools = "Инструменты",
		Explorer = "Обозреватель",
		["Open Explorer"] = "Открыть обозреватель",
		["Copy Selected Path"] = "Скопировать путь",
		["List Remotes"] = "Список Remote",
		["List Sounds"] = "Список звуков",
		Remotes = "Remote",
		Sounds = "Звуки",
		["Path copied."] = "Путь скопирован.",
		Ruler = "Рулетка",
		["Set Point A (here)"] = "Точка A (здесь)",
		["Set Point B (here)"] = "Точка B (здесь)",
		["Clear Ruler"] = "Убрать рулетку",
		Slope = "Наклон",
		Debug = "Отладка",
		Console = "Консоль",
		["Console Window"] = "Окно консоли",
		["Copy Console"] = "Скопировать консоль",
		Profiler = "Профилировщик",
	})
end

------------------------- МЕНЮ: профили, поиск, бинды (101–110) -------------------------
do
	local UserInputService = game:GetService("UserInputService")
	local MenuTab = Tabs["Shortcuts"]

	-- найти переключатель по имени (как он подписан в меню)
	local function findToggle(name)
		name = string.lower(name or "")
		for _, element in pairs(Library.Elements) do
			if element.Type == "Toggle" and string.lower(tostring(element.Name)) == name then
				return element
			end
		end
		return nil
	end

	-- 105: закреплённые переключатели
	local PIN_FILE = "nocturne_pins.json"
	local pins = Util.readFile(PIN_FILE, {})
	local Pinned = MenuTab:AddSection({ Name = "Pinned", Side = "Left" })
	local pinBox = Pinned:AddTextbox({ Name = "Toggle Name", Placeholder = "Zoom", Width = 140 })
	local function addPinButton(name)
		Pinned:AddButton({ Name = "★ " .. name, Callback = function()
			local toggle = findToggle(name)
			if toggle then
				toggle:Set(not toggle.Value)
				Util.notify("Favorites", name .. ": " .. (toggle.Value and "ON" or "OFF"), 2)
			else
				Util.notify("Favorites", "Toggle not found.")
			end
		end })
	end
	Pinned:AddButton({ Name = "Pin Toggle", Callback = function()
		local name = pinBox:Get()
		if not findToggle(name) then
			Util.notify("Favorites", "Toggle not found.")
			return
		end
		table.insert(pins, name)
		Util.writeFile(PIN_FILE, pins)
		addPinButton(name)
	end })
	Pinned:AddButton({ Name = "Clear Pins", Danger = true, Callback = function()
		pins = {}
		Util.writeFile(PIN_FILE, pins)
		Util.notify("Favorites", "Pins cleared — they disappear after reloading the menu.")
	end })
	for _, name in ipairs(pins) do
		addPinButton(name)
	end

	-- 106: поиск по всем вкладкам
	local Search = MenuTab:AddSection({ Name = "Global Search", Side = "Left" })
	local searchBox = Search:AddTextbox({ Name = "Find Setting", Placeholder = "fog", Width = 140 })
	local results = {}
	Search:AddButton({ Name = "Find", Callback = function()
		local query = string.lower(searchBox:Get())
		results = {}
		if query == "" then
			return
		end
		for key, element in pairs(Library.Elements) do
			local name = tostring(element.Name or "")
			if string.find(string.lower(name), query, 1, true) or string.find(string.lower(Library:Translate(name)), query, 1, true) then
				table.insert(results, { key = key, name = name })
			end
		end
		table.sort(results, function(a, b)
			return a.key < b.key
		end)
		local lines = {}
		for index = 1, math.min(6, #results) do
			table.insert(lines, (string.gsub(results[index].key, "[/>#]", " › ")))
		end
		Util.notify("Search", #results .. " " .. Library:Translate("found") .. (#lines > 0 and ("\n" .. table.concat(lines, "\n")) or ""), 8)
	end })
	Search:AddButton({ Name = "Go to First Result", Callback = function()
		local first = results[1]
		if not first then
			Util.notify("Search", "Nothing found yet.")
			return
		end
		local tabName = string.match(first.key, "^[^/>]+")
		for _, tab in ipairs(Window.Tabs) do
			if tab.Name == tabName then
				Window:SelectTab(tab)
				Window.searchBox.Text = Library:Translate(first.name)
				break
			end
		end
	end })

	-- 101–104: профили
	local Profiles = MenuTab:AddSection({ Name = "Profiles", Side = "Right" })
	for index, profile in ipairs({ "Default", "Legit", "Rage" }) do
		Profiles:AddKeybind({ Name = Library:Translate("Load") .. " " .. profile, Default = ({ Enum.KeyCode.F1, Enum.KeyCode.F2, Enum.KeyCode.F3 })[index], Callback = function()
			local ok = Library:LoadConfig(profile)
			Util.notify("Config", ok and (Library:Translate("Loaded") .. ": " .. profile) or (Library:Translate("No saved profile") .. ": " .. profile))
		end })
	end
	local autosave = { on = false, minutes = 5 }
	Profiles:AddToggle({ Name = "Autosave", Default = false, Callback = function(v)
		autosave.on = v
	end }):AddSettings("Autosave"):AddGroup():AddSlider({ Name = "Every (min)", Min = 1, Max = 30, Default = 5, Callback = function(v)
		autosave.minutes = v
	end })
	local lastAutosave = os.clock()
	Util.loop(10, function()
		if autosave.on and os.clock() - lastAutosave >= autosave.minutes * 60 then
			lastAutosave = os.clock()
			Library:SaveConfig("autosave")
		end
	end)
	local compareDropdown = Profiles:AddDropdown({ Name = "Compare With", Options = { "Default", "Legit", "Rage", "Custom", "autosave" }, Default = "Default", Width = 120 })
	Profiles:AddButton({ Name = "Compare", Callback = function()
		local saved = Util.readFile("nocturne_" .. compareDropdown:Get() .. ".json", nil)
		if not saved then
			Util.notify("Config", "No saved profile with this name.")
			return
		end
		local current = Library:GetConfig()
		local changed = {}
		for key, value in pairs(current) do
			if Util.json({ value }) ~= Util.json({ saved[key] }) then
				table.insert(changed, string.match(key, "[^:]+$") or key)
			end
		end
		Util.notify("Config", #changed .. " " .. Library:Translate("differences") .. (#changed > 0 and (": " .. table.concat(changed, ", ", 1, math.min(6, #changed))) or ""), 8)
	end })
	local tabNames = {}
	for _, tab in ipairs(Window.Tabs) do
		table.insert(tabNames, tab.Name)
	end
	local resetDropdown = Profiles:AddDropdown({ Name = "Reset Tab", Options = tabNames, Default = tabNames[1], Width = 120 })
	Profiles:AddButton({ Name = "Reset Selected Tab", Danger = true, Callback = function()
		local name = resetDropdown:Get()
		Library:ResetConfig(name .. "/")
		Library:ResetConfig(name .. ">")
		Util.notify("Config", Library:Translate("Tab reset") .. ": " .. Library:Translate(name))
	end })

	-- 107–108: бинды на любые переключатели и макросы
	local Binds = MenuTab:AddSection({ Name = "Custom Binds", Side = "Right" })
	for slot = 1, 3 do
		local nameBox = Binds:AddTextbox({ Name = Library:Translate("Toggle") .. " " .. slot, Placeholder = "Fog", Width = 120 })
		Binds:AddKeybind({ Name = Library:Translate("Key") .. " " .. slot, Callback = function()
			local toggle = findToggle(nameBox:Get())
			if toggle then
				toggle:Set(not toggle.Value)
			end
		end })
	end
	local macroBox = Binds:AddTextbox({ Name = "Macro", Placeholder = "Zoom=on; Fog=off", Width = 150 })
	Binds:AddKeybind({ Name = "Macro Key", Callback = function()
		local applied = 0
		for name, state in string.gmatch(macroBox:Get(), "([^=;]+)=([^;]+)") do
			local toggle = findToggle((string.gsub(name, "^%s*(.-)%s*$", "%1")))
			if toggle then
				toggle:Set(string.lower((string.gsub(state, "%s", ""))) == "on")
				applied += 1
			end
		end
		Util.notify("Macro", Library:Translate("Applied") .. ": " .. applied, 2)
	end })

	-- 109: мгновенно спрятать меню и все плашки
	local panicHidden = false
	Binds:AddKeybind({ Name = "Panic Hide", Default = Enum.KeyCode.End, Callback = function()
		panicHidden = not panicHidden
		Window:_closeAll()
		Window.main.Visible = not panicHidden and Window.Visible
		Window.widgetLayer.Visible = not panicHidden
	end })

	Util.tr({
		Favorites = "Избранное",
		Pinned = "Закреплённые",
		["Toggle Name"] = "Имя переключателя",
		["Pin Toggle"] = "Закрепить",
		["Clear Pins"] = "Убрать все",
		["Toggle not found."] = "Переключатель не найден.",
		["Pins cleared — they disappear after reloading the menu."] = "Закрепления удалены — исчезнут после перезапуска меню.",
		["Global Search"] = "Поиск по меню",
		["Find Setting"] = "Найти настройку",
		Find = "Найти",
		found = "найдено",
		["Go to First Result"] = "Перейти к первому",
		["Nothing found yet."] = "Пока ничего не найдено.",
		Profiles = "Профили",
		Loaded = "Загружен",
		["No saved profile"] = "Нет сохранённого профиля",
		Autosave = "Автосохранение",
		["Every (min)"] = "Каждые (мин)",
		["Compare With"] = "Сравнить с",
		Compare = "Сравнить",
		differences = "отличий",
		["No saved profile with this name."] = "Нет сохранённого профиля с этим именем.",
		["Reset Tab"] = "Сбросить вкладку",
		["Reset Selected Tab"] = "Сбросить выбранную",
		["Tab reset"] = "Вкладка сброшена",
		["Custom Binds"] = "Свои бинды",
		Toggle = "Переключатель",
		Key = "Клавиша",
		Macro = "Макрос",
		["Macro Key"] = "Клавиша макроса",
		Applied = "Применено",
		["Panic Hide"] = "Спрятать всё",
	})

	-- 110: подсказки к функциям (показываются при наведении на строку)
	for name, tip in pairs({
		["Smooth Camera"] = "Smooths camera rotation for recordings.",
		["Orbit Camera"] = "Camera flies around your character. Turn off to get control back.",
		["Photo Mode"] = "Hides the menu and takes a Roblox screenshot.",
		["Potato Mode"] = "Turns on all FPS removals and simple water at once.",
		["Auto Economy"] = "Turns on Potato Mode when FPS stays low for 5 seconds.",
		["Hide Distant Parts"] = "Hides far parts on your screen to raise FPS.",
		["Relaunch After Teleport"] = "Runs this script again after you join another server (executor).",
		["Profile per Game"] = "Loads the profile saved for this game on start.",
		["Share Waypoint Here"] = "Script users on this server get a waypoint at your position.",
		["Panic Hide"] = "Instantly hides the menu and every widget. Press again to show.",
		["Auto Reply on Mention"] = "Replies with your text when someone writes your name (max once per 15 s).",
		["Hide Words"] = "Hides chat messages with these words (new chat only).",
	}) do
		Library.Tooltips[name] = tip
	end
	Util.tr({
		["Smooths camera rotation for recordings."] = "Сглаживает поворот камеры для записи.",
		["Camera flies around your character. Turn off to get control back."] = "Камера облетает персонажа. Выключите, чтобы вернуть управление.",
		["Hides the menu and takes a Roblox screenshot."] = "Прячет меню и делает снимок Roblox.",
		["Turns on all FPS removals and simple water at once."] = "Включает все удаления ради FPS и простую воду.",
		["Turns on Potato Mode when FPS stays low for 5 seconds."] = "Включает режим картошки, если FPS низкий 5 секунд.",
		["Hides far parts on your screen to raise FPS."] = "Прячет дальние детали ради FPS.",
		["Runs this script again after you join another server (executor)."] = "Запускает скрипт снова после перехода на другой сервер.",
		["Loads the profile saved for this game on start."] = "При запуске загружает профиль этой игры.",
		["Script users on this server get a waypoint at your position."] = "Пользователи скрипта на сервере получат метку в вашей точке.",
		["Instantly hides the menu and every widget. Press again to show."] = "Мгновенно прячет меню и все плашки. Нажмите ещё раз, чтобы показать.",
		["Replies with your text when someone writes your name (max once per 15 s)."] = "Отвечает вашим текстом, когда пишут ваш ник (не чаще раза в 15 с).",
		["Hides chat messages with these words (new chat only)."] = "Скрывает сообщения с этими словами (только новый чат).",
	})
end

------------------------- EXTRAS: перенесено из Misc -------------------------
-- Персонаж, камера, сессия, атмосфера, постэффекты, оверлеи и видимость.
-- Раньше эти секции были во вкладке Miscellaneous; дубли с вкладками Extras убраны.
do
	local RunService = game:GetService("RunService")
	local Lighting = game:GetService("Lighting")
	local UserInputService = game:GetService("UserInputService")
	local PlayersService = game:GetService("Players")
	local localPlayer = Util.player

	------------------------------ тело (Character) ------------------------------
	local body = {
		showInFirstPerson = false,
		transparency = false,
		transparencyValue = 0.5,
		highlight = false,
		highlightRainbow = false,
		highlightColor = Color3.fromRGB(100, 133, 247),
		trail = false,
		trailColor = Color3.fromRGB(240, 100, 160),
		hideAccessories = false,
		bob = false,
		bobStrength = 1,
	}
	local highlightObject, trailObjects = nil, nil
	local bobTime = 0

	local function isAccessoryPart(part)
		return part:FindFirstAncestorWhichIsA("Accoutrement") ~= nil
	end

	Util.render(Enum.RenderPriority.Camera.Value + 2, function(dt)
		local char = Util.char()
		local cam = Util.camera()
		if not (char and cam) then
			return
		end
		local head = char:FindFirstChild("Head")
		local firstPerson = head and (cam.CFrame.Position - head.Position).Magnitude < 1.5

		if body.transparency or body.hideAccessories or (body.showInFirstPerson and firstPerson) then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					local accessory = isAccessoryPart(part)
					if body.hideAccessories and accessory then
						part.LocalTransparencyModifier = 1
					elseif body.showInFirstPerson and firstPerson then
						-- тело видно, голова и аксессуары скрыты, чтобы не мешали обзору
						part.LocalTransparencyModifier = (part.Name == "Head" or accessory) and 1 or 0
					elseif body.transparency then
						part.LocalTransparencyModifier = body.transparencyValue
					end
				end
			end
		end

		-- покачивание камеры при ходьбе
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if body.bob and humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
			bobTime += dt * 9
			local s = body.bobStrength
			cam.CFrame = cam.CFrame
				* CFrame.new(math.sin(bobTime) * 0.06 * s, math.abs(math.cos(bobTime)) * 0.09 * s, 0)
				* CFrame.Angles(0, 0, math.sin(bobTime) * 0.006 * s)
		end

		-- радужная подсветка меняет цвет плавно, каждый кадр
		if highlightObject and body.highlightRainbow then
			local color = Color3.fromHSV((os.clock() / 4) % 1, 0.8, 1)
			highlightObject.FillColor, highlightObject.OutlineColor = color, color
		end
	end)

	local function updateCharacterEffects()
		local char = Util.char()
		if body.highlight and char then
			if not highlightObject or highlightObject.Parent ~= char then
				if highlightObject then
					highlightObject:Destroy()
				end
				highlightObject = Instance.new("Highlight")
				highlightObject.Name = "NocturneHighlight"
				highlightObject.DepthMode = Enum.HighlightDepthMode.Occluded
				highlightObject.Parent = char
			end
			if not body.highlightRainbow then
				highlightObject.FillColor = body.highlightColor
				highlightObject.OutlineColor = body.highlightColor
			end
			highlightObject.FillTransparency = 0.75
			highlightObject.OutlineTransparency = 0
		elseif highlightObject then
			highlightObject:Destroy()
			highlightObject = nil
		end

		local root = Util.root()
		if body.trail and root then
			if not trailObjects or trailObjects.trail.Parent ~= root then
				if trailObjects then
					trailObjects.trail:Destroy()
					trailObjects.a0:Destroy()
					trailObjects.a1:Destroy()
				end
				local a0 = Instance.new("Attachment")
				a0.Position = Vector3.new(0, 1, 0)
				a0.Parent = root
				local a1 = Instance.new("Attachment")
				a1.Position = Vector3.new(0, -1, 0)
				a1.Parent = root
				local trail = Instance.new("Trail")
				trail.Name = "NocturneTrail"
				trail.Attachment0 = a0
				trail.Attachment1 = a1
				trail.Lifetime = 0.6
				trail.LightEmission = 0.6
				trail.Transparency = NumberSequence.new(0.2, 1)
				trail.Parent = root
				trailObjects = { trail = trail, a0 = a0, a1 = a1 }
			end
			trailObjects.trail.Color = ColorSequence.new(body.trailColor)
		elseif trailObjects then
			trailObjects.trail:Destroy()
			trailObjects.a0:Destroy()
			trailObjects.a1:Destroy()
			trailObjects = nil
		end
	end
	Util.loop(0.5, updateCharacterEffects)

	------------------------------ сессия (HUD) ------------------------------
	local sessionStart = os.clock()
	local lastInput = os.clock()
	Util.track(UserInputService.InputBegan:Connect(function()
		lastInput = os.clock()
	end))
	Util.track(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			lastInput = os.clock()
		end
	end))
	local sessionItems = { ["Session Time"] = true, ["AFK Timer"] = true }
	local sessionWidget = Util.textWidget("Session", "Session", UDim2.fromOffset(16, 120), "clock", function()
		local lines = {}
		if sessionItems["Session Time"] then
			table.insert(lines, Library:Translate("Session Time") .. ":  " .. Util.clock(os.clock() - sessionStart))
		end
		if sessionItems["AFK Timer"] then
			-- Roblox кикает после 20 минут без действий
			table.insert(lines, Library:Translate("AFK Kick In") .. ":  " .. Util.clock(1200 - (os.clock() - lastInput)))
		end
		return lines
	end)

	local friendAlerts = false
	Util.track(PlayersService.PlayerAdded:Connect(function(player)
		if not friendAlerts then
			return
		end
		local ok, isFriend = pcall(function()
			return localPlayer:IsFriendsWith(player.UserId)
		end)
		if ok and isFriend then
			Util.notify("Friends", player.DisplayName .. " " .. Library:Translate("joined the server"))
		end
	end))

	------------------------------ оверлей клавиш (HUD) ------------------------------
	local keystrokes = Util.frame({ Name = "NocturneKeystrokes", BackgroundTransparency = 1, Position = UDim2.new(1, -190, 1, -260), Size = UDim2.fromOffset(170, 180), Visible = false, Parent = Window.widgetLayer })
	Window:_draggable(keystrokes)
	Window:_widgetScaleTarget(keystrokes)
	local keyViews, clicks = {}, {}
	local function keyBox(name, text, x, y, w, h)
		local box = Util.frame({ Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundColor3 = Color3.fromRGB(13, 14, 19), BackgroundTransparency = 0.35, Parent = keystrokes })
		Util.round(box, UDim.new(0, 8))
		local label = Util.text({ Size = UDim2.fromScale(1, 1), TextSize = 14, Text = text, Parent = box })
		keyViews[name] = { box = box, label = label }
		return label
	end
	keyBox("W", "W", 60, 0, 50, 50)
	keyBox("A", "A", 5, 55, 50, 50)
	keyBox("S", "S", 60, 55, 50, 50)
	keyBox("D", "D", 115, 55, 50, 50)
	keyBox("Space", "SPACE", 5, 110, 160, 30)
	local lmbLabel = keyBox("LMB", "LMB", 5, 145, 78, 34)
	keyBox("RMB", "RMB", 87, 145, 78, 34)
	local function isDown(name)
		if name == "LMB" then
			return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		elseif name == "RMB" then
			return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		end
		return UserInputService:IsKeyDown(Enum.KeyCode[name])
	end
	Util.track(UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			table.insert(clicks, os.clock())
		end
	end))
	Util.track(RunService.RenderStepped:Connect(function()
		if not keystrokes.Visible then
			return
		end
		for name, view in pairs(keyViews) do
			local down = isDown(name)
			view.box.BackgroundColor3 = down and Library.Theme.Accent or Color3.fromRGB(13, 14, 19)
			view.box.BackgroundTransparency = down and 0.1 or 0.35
		end
		local now = os.clock()
		while clicks[1] and now - clicks[1] > 1 do
			table.remove(clicks, 1)
		end
		lmbLabel.Text = #clicks > 0 and (#clicks .. " CPS") or "LMB"
	end))

	------------------------------ инфо о сервере (HUD) ------------------------------
	local placeName = nil
	task.spawn(function()
		local ok, info = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		end)
		placeName = ok and info and info.Name or nil
	end)
	local serverWidget = Util.textWidget("ServerInfo", "Server Info", UDim2.fromOffset(16, 300), "globe", function()
		local lines = {}
		if placeName then
			table.insert(lines, placeName)
		end
		table.insert(lines, Library:Translate("Players") .. ":  " .. #PlayersService:GetPlayers() .. " / " .. PlayersService.MaxPlayers)
		table.insert(lines, Library:Translate("Server Uptime") .. ":  " .. Util.clock(workspace.DistributedGameTime))
		local ok, ping = pcall(function()
			return localPlayer:GetNetworkPing()
		end)
		if ok and type(ping) == "number" then
			table.insert(lines, "Ping:  " .. math.floor(ping * 1000 + 0.5) .. " ms")
		end
		return lines
	end)

	------------------------------ атмосфера (Graphics) ------------------------------
	-- Пресеты неба без картинок-ассетов: время суток, атмосфера, звёзды, свет окружения.
	local SKY_PRESETS = {
		Sunset = { time = 17.9, ambient = Color3.fromRGB(150, 110, 100), stars = 0, atmosphere = { Color = Color3.fromRGB(255, 170, 110), Decay = Color3.fromRGB(120, 60, 90), Density = 0.32, Haze = 2.2, Glare = 1.5, Offset = 0.1 } },
		["Golden Hour"] = { time = 6.4, ambient = Color3.fromRGB(170, 140, 100), stars = 0, atmosphere = { Color = Color3.fromRGB(255, 210, 140), Decay = Color3.fromRGB(150, 110, 70), Density = 0.28, Haze = 1.8, Glare = 1, Offset = 0.15 } },
		Night = { time = 0, ambient = Color3.fromRGB(60, 70, 110), stars = 4000, atmosphere = { Color = Color3.fromRGB(40, 50, 90), Decay = Color3.fromRGB(20, 20, 40), Density = 0.3, Haze = 1, Glare = 0, Offset = 0 } },
		Space = { time = 0, ambient = Color3.fromRGB(80, 80, 120), stars = 10000, atmosphere = { Color = Color3.fromRGB(10, 10, 20), Decay = Color3.fromRGB(0, 0, 0), Density = 0, Haze = 0, Glare = 0, Offset = 0 } },
		Neon = { time = 0, ambient = Color3.fromRGB(140, 80, 200), stars = 3000, atmosphere = { Color = Color3.fromRGB(200, 80, 255), Decay = Color3.fromRGB(60, 20, 120), Density = 0.35, Haze = 2.5, Glare = 2, Offset = 0.2 } },
		["Foggy Morning"] = { time = 7, ambient = Color3.fromRGB(160, 165, 175), stars = 0, atmosphere = { Color = Color3.fromRGB(200, 210, 225), Decay = Color3.fromRGB(150, 160, 180), Density = 0.45, Haze = 3, Glare = 0.3, Offset = 0 } },
	}
	local world = { sky = "Default", simpleWater = false, clouds = false, cover = 0.6, density = 0.6, cloudColor = Color3.new(1, 1, 1), timeLapse = false, timeSpeed = 10 }

	local function applySky()
		local preset = SKY_PRESETS[world.sky]
		if not preset then
			Util.restore("skyp.")
			Util.effect("PresetAtmosphere", "Atmosphere", Lighting, false)
			Util.effect("PresetSky", "Sky", Lighting, false)
			return
		end
		Util.set("skyp.Clock", Lighting, "ClockTime", preset.time)
		Util.set("skyp.Ambient", Lighting, "Ambient", preset.ambient)
		Util.set("skyp.Outdoor", Lighting, "OutdoorAmbient", preset.ambient)
		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Util.effect("PresetAtmosphere", "Atmosphere", Lighting, true)
		for prop, value in pairs(preset.atmosphere) do
			Util.set("skyp.atm." .. prop, atmosphere, prop, value)
		end
		local sky = Lighting:FindFirstChildOfClass("Sky") or Util.effect("PresetSky", "Sky", Lighting, true)
		Util.set("skyp.Stars", sky, "StarCount", preset.stars)
	end

	local function applyWater()
		local terrain = workspace.Terrain
		if world.simpleWater then
			Util.set("water.Wave", terrain, "WaterWaveSize", 0)
			Util.set("water.Speed", terrain, "WaterWaveSpeed", 0)
			Util.set("water.Reflect", terrain, "WaterReflectance", 0)
			Util.set("water.Transparency", terrain, "WaterTransparency", 0.6)
		else
			Util.restore("water.")
		end
	end

	local function applyClouds()
		local terrain = workspace.Terrain
		if world.clouds then
			local clouds = terrain:FindFirstChildOfClass("Clouds") or Util.effect("Clouds", "Clouds", terrain, true)
			Util.set("clouds.Enabled", clouds, "Enabled", true)
			Util.set("clouds.Cover", clouds, "Cover", world.cover)
			Util.set("clouds.Density", clouds, "Density", world.density)
			Util.set("clouds.Color", clouds, "Color", world.cloudColor)
		else
			Util.restore("clouds.")
			Util.effect("Clouds", "Clouds", terrain, false)
		end
	end

	-- ускоренная смена дня и ночи: «часов в минуту»
	Util.track(RunService.Heartbeat:Connect(function(dt)
		if world.timeLapse then
			Lighting.ClockTime = (Lighting.ClockTime + dt * world.timeSpeed / 60) % 24
		end
	end))

	------------------------------ постэффекты (Graphics) ------------------------------
	local fx = { bloom = false, bloomIntensity = 1, sunRays = false, dof = false, dofFocus = 30, motionBlur = false, motionStrength = 1, vignette = false, vignetteStrength = 0.5 }
	local function applyEffects()
		local cam = Util.camera()
		local bloom = Util.effect("Bloom", "BloomEffect", Lighting, fx.bloom)
		if bloom then
			bloom.Intensity, bloom.Size, bloom.Threshold = fx.bloomIntensity, 30, 0.9
		end
		local rays = Util.effect("SunRays", "SunRaysEffect", Lighting, fx.sunRays)
		if rays then
			rays.Intensity, rays.Spread = 0.12, 0.8
		end
		local dof = Util.effect("DepthOfField", "DepthOfFieldEffect", Lighting, fx.dof)
		if dof then
			dof.FocusDistance, dof.InFocusRadius, dof.FarIntensity, dof.NearIntensity = fx.dofFocus, 20, 0.6, 0.3
		end
		Util.effect("MotionBlur", "BlurEffect", cam, fx.motionBlur)
	end
	local lastLook = nil
	Util.track(RunService.RenderStepped:Connect(function(dt)
		local cam = Util.camera()
		local blur = cam and cam:FindFirstChild("NocturneMotionBlur")
		if not blur then
			lastLook = nil
			return
		end
		local look = cam.CFrame.LookVector
		if lastLook then
			local angle = math.acos(math.clamp(look:Dot(lastLook), -1, 1))
			local target = math.clamp(angle / math.max(dt, 1 / 240) * 2.2 * fx.motionStrength, 0, 14)
			blur.Size = blur.Size + (target - blur.Size) * math.clamp(dt * 12, 0, 1)
		end
		lastLook = look
	end))

	local vignetteFrame = Util.frame({ Name = "NocturneVignette", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 0, Parent = Window.widgetLayer })
	local vignetteEdges = {}
	for _, side in ipairs({
		{ UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.35), 90 },
		{ UDim2.fromScale(0, 0.65), UDim2.fromScale(1, 0.35), 270 },
		{ UDim2.fromScale(0, 0), UDim2.fromScale(0.3, 1), 0 },
		{ UDim2.fromScale(0.7, 0), UDim2.fromScale(0.3, 1), 180 },
	}) do
		local edge = Util.frame({ BackgroundColor3 = Color3.new(0, 0, 0), Position = side[1], Size = side[2], Parent = vignetteFrame })
		local gradient = Instance.new("UIGradient")
		gradient.Rotation = side[3]
		gradient.Parent = edge
		table.insert(vignetteEdges, gradient)
	end
	local function applyVignette()
		vignetteFrame.Visible = fx.vignette
		for _, gradient in ipairs(vignetteEdges) do
			gradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1 - fx.vignetteStrength * 0.8),
				NumberSequenceKeypoint.new(1, 1),
			})
		end
	end

	------------------------------ видимость (Graphics) ------------------------------
	local visibility = { hideNames = false, hideOthers = false }
	local savedNameDisplay = setmetatable({}, { __mode = "k" })
	local function applyVisibility()
		for _, player in ipairs(PlayersService:GetPlayers()) do
			local char = player.Character
			if char and player ~= localPlayer then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid then
					if visibility.hideNames then
						if savedNameDisplay[humanoid] == nil then
							savedNameDisplay[humanoid] = humanoid.DisplayDistanceType
						end
						humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					elseif savedNameDisplay[humanoid] ~= nil then
						humanoid.DisplayDistanceType = savedNameDisplay[humanoid]
						savedNameDisplay[humanoid] = nil
					end
				end
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") or part:IsA("Decal") then
						part.LocalTransparencyModifier = visibility.hideOthers and 1 or 0
					end
				end
			end
		end
	end

	Util.loop(0.5, function()
		pcall(applySky)
		pcall(applyWater)
		pcall(applyClouds)
		pcall(applyEffects)
		pcall(applyVisibility)
	end)

	Util.onUnload(function()
		for key, value in pairs(body) do
			if type(value) == "boolean" then
				body[key] = false
			end
		end
		updateCharacterEffects()
		local char = Util.char()
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 0
				end
			end
		end
		world.sky, world.simpleWater, world.clouds, world.timeLapse = "Default", false, false, false
		applySky()
		applyClouds()
		visibility.hideNames, visibility.hideOthers = false, false
		applyVisibility()
		keystrokes:Destroy()
	end)

	-------------------------------- интерфейс --------------------------------
	-- Character → Body
	local Body = Tabs.Character:AddSection({ Name = "Body", Side = "Left" })
	Body:AddToggle({ Name = "Body in First Person", Icon = "user", Default = false, Callback = function(v)
		body.showInFirstPerson = v
	end })
	Body:AddToggle({ Name = "Self Transparency", Default = false, Callback = function(v)
		body.transparency = v
	end }):AddSettings("Self Transparency"):AddGroup():AddSlider({ Name = "Value", Min = 0, Max = 90, Default = 50, Suffix = "%", Callback = function(v)
		body.transparencyValue = v / 100
	end })
	local highlight = Body:AddToggle({ Name = "Self Highlight", Default = false, Callback = function(v)
		body.highlight = v
		updateCharacterEffects()
	end })
	highlight:AddColorpicker({ Default = body.highlightColor, Callback = function(v)
		body.highlightColor = v
	end })
	highlight:AddSettings("Self Highlight"):AddGroup():AddToggle({ Name = "Rainbow", Default = false, Callback = function(v)
		body.highlightRainbow = v
	end })
	Body:AddToggle({ Name = "Trail", Default = false, Callback = function(v)
		body.trail = v
		updateCharacterEffects()
	end }):AddColorpicker({ Default = body.trailColor, Callback = function(v)
		body.trailColor = v
	end })
	Body:AddToggle({ Name = "Hide My Accessories", Default = false, Callback = function(v)
		body.hideAccessories = v
	end })

	-- Camera → Feel
	local Feel = Tabs.Camera:AddSection({ Name = "Feel", Side = "Left" })
	Feel:AddToggle({ Name = "Camera Bob", Default = false, Callback = function(v)
		body.bob = v
	end }):AddSettings("Camera Bob"):AddGroup():AddSlider({ Name = "Strength", Min = 10, Max = 300, Default = 100, Suffix = "%", Callback = function(v)
		body.bobStrength = v / 100
	end })

	-- HUD → Session & Overlays
	local Session = Tabs.HUD:AddSection({ Name = "Session", Side = "Left" })
	local sessionToggle = Session:AddToggle({ Name = "Session Panel", Icon = "clock", Default = false, Callback = function(v)
		sessionWidget:SetVisible(v)
	end })
	sessionToggle:AddSettings("Session Panel"):AddGroup():AddChecklist({
		Options = { "Session Time", "AFK Timer" },
		Default = { "Session Time", "AFK Timer" },
		Callback = function(selected)
			sessionItems = {}
			for _, name in ipairs(selected) do
				sessionItems[name] = true
			end
		end,
	})
	Session:AddToggle({ Name = "Server Info", Icon = "globe", Default = false, Callback = function(v)
		serverWidget:SetVisible(v)
	end })
	Session:AddToggle({ Name = "Keystrokes", Icon = "keyboard", Default = false, Callback = function(v)
		keystrokes.Visible = v
	end })
	Session:AddToggle({ Name = "Friend Alerts", Icon = "user", Default = false, Callback = function(v)
		friendAlerts = v
	end })

	-- Graphics → Atmosphere
	local Atmosphere = Tabs.Graphics:AddSection({ Name = "Atmosphere", Side = "Left" })
	Atmosphere:AddDropdown({
		Name = "Sky Preset",
		Options = { "Default", "Sunset", "Golden Hour", "Night", "Space", "Neon", "Foggy Morning" },
		Default = "Default",
		Width = 130,
		Callback = function(v)
			world.sky = v
			applySky()
		end,
	})
	local clouds = Atmosphere:AddToggle({ Name = "Clouds", Default = false, Callback = function(v)
		world.clouds = v
		applyClouds()
	end })
	clouds:AddColorpicker({ Default = world.cloudColor, Callback = function(v)
		world.cloudColor = v
	end })
	local cloudsGroup = clouds:AddSettings("Clouds"):AddGroup()
	cloudsGroup:AddSlider({ Name = "Cover", Min = 0, Max = 100, Default = 60, Suffix = "%", Callback = function(v)
		world.cover = v / 100
	end })
	cloudsGroup:AddSlider({ Name = "Density", Min = 0, Max = 100, Default = 60, Suffix = "%", Callback = function(v)
		world.density = v / 100
	end })
	Atmosphere:AddToggle({ Name = "Time Lapse", Default = false, Callback = function(v)
		world.timeLapse = v
	end }):AddSettings("Time Lapse"):AddGroup():AddSlider({ Name = "Hours per Minute", Min = 1, Max = 120, Default = 10, Callback = function(v)
		world.timeSpeed = v
	end })
	Atmosphere:AddToggle({ Name = "Simple Water", Default = false, Callback = function(v)
		world.simpleWater = v
		applyWater()
	end })

	-- Graphics → Post Effects
	local Post = Tabs.Graphics:AddSection({ Name = "Post Effects", Side = "Left" })
	local bloom = Post:AddToggle({ Name = "Bloom", Default = false, Callback = function(v)
		fx.bloom = v
		applyEffects()
	end })
	bloom:AddSettings("Bloom"):AddGroup():AddSlider({ Name = "Intensity", Min = 10, Max = 300, Default = 100, Suffix = "%", Callback = function(v)
		fx.bloomIntensity = v / 100
		applyEffects()
	end })
	Post:AddToggle({ Name = "Sun Rays", Default = false, Callback = function(v)
		fx.sunRays = v
		applyEffects()
	end })
	Post:AddToggle({ Name = "Depth of Field", Default = false, Callback = function(v)
		fx.dof = v
		applyEffects()
	end }):AddSettings("Depth of Field"):AddGroup():AddSlider({ Name = "Focus Distance", Min = 5, Max = 200, Default = 30, Callback = function(v)
		fx.dofFocus = v
		applyEffects()
	end })
	Post:AddToggle({ Name = "Motion Blur", Default = false, Callback = function(v)
		fx.motionBlur = v
		applyEffects()
	end }):AddSettings("Motion Blur"):AddGroup():AddSlider({ Name = "Strength", Min = 10, Max = 300, Default = 100, Suffix = "%", Callback = function(v)
		fx.motionStrength = v / 100
	end })
	Post:AddToggle({ Name = "Vignette", Default = false, Callback = function(v)
		fx.vignette = v
		applyVignette()
	end }):AddSettings("Vignette"):AddGroup():AddSlider({ Name = "Strength", Min = 10, Max = 100, Default = 50, Suffix = "%", Callback = function(v)
		fx.vignetteStrength = v / 100
		applyVignette()
	end })

	-- Graphics → Visibility
	local Visibility = Tabs.Graphics:AddSection({ Name = "Visibility", Side = "Right" })
	Visibility:AddToggle({ Name = "Hide Name Tags", Default = false, Callback = function(v)
		visibility.hideNames = v
		applyVisibility()
	end })
	Visibility:AddToggle({ Name = "Hide Other Players", Icon = "eye", Default = false, Callback = function(v)
		visibility.hideOthers = v
		applyVisibility()
	end })

	Util.tr({
		Body = "Тело",
		["Body in First Person"] = "Тело от первого лица",
		["Self Transparency"] = "Прозрачность себя",
		["Self Highlight"] = "Подсветка себя",
		Rainbow = "Радужная",
		Trail = "След",
		["Hide My Accessories"] = "Скрыть свои аксессуары",
		Feel = "Ощущения",
		["Camera Bob"] = "Покачивание камеры",
		Strength = "Сила",
		Session = "Сессия",
		["Session Panel"] = "Панель сессии",
		["Session Time"] = "Время в игре",
		["AFK Timer"] = "Таймер АФК",
		["AFK Kick In"] = "Кик за АФК через",
		["Server Info"] = "Инфо о сервере",
		["Server Uptime"] = "Сервер работает",
		Keystrokes = "Нажатия клавиш",
		["Friend Alerts"] = "Уведомления о друзьях",
		Friends = "Друзья",
		["joined the server"] = "зашёл на сервер",
		Atmosphere = "Атмосфера",
		["Sky Preset"] = "Небо",
		Clouds = "Облака",
		Cover = "Покрытие",
		Density = "Плотность",
		["Time Lapse"] = "Ускоренное время",
		["Hours per Minute"] = "Часов в минуту",
		["Simple Water"] = "Простая вода",
		["Post Effects"] = "Постэффекты",
		Bloom = "Свечение (Bloom)",
		Intensity = "Интенсивность",
		["Sun Rays"] = "Солнечные лучи",
		["Depth of Field"] = "Глубина резкости",
		["Focus Distance"] = "Дистанция фокуса",
		["Motion Blur"] = "Размытие в движении",
		Vignette = "Виньетка",
		Visibility = "Видимость",
		["Hide Name Tags"] = "Скрыть ники над головами",
		["Hide Other Players"] = "Скрыть других игроков",
		Shortcuts = "Быстрый доступ",
	})
end

------------------- СВЯЗЬ С СЕРВЕРОМ ВАШЕЙ ИГРЫ (Auto Parry, Visuals) -------------------
-- Ваш AutoParry.server.lua создаёт ReplicatedStorage.AutoParryRemote и сам решает,
-- кому доступны Auto Parry и Visuals (по умолчанию — только админам).
-- В других играх этого Remote нет, поэтому обе функции там не работают.
local GameLink = { state = nil }
do
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local listeners = {}
	local remote

	local function bind(found)
		if remote or not found or not found:IsA("RemoteEvent") then
			return
		end
		remote = found
		Util.track(remote.OnClientEvent:Connect(function(state)
			if type(state) ~= "table" then
				return
			end
			GameLink.state = state
			for _, fn in ipairs(listeners) do
				task.spawn(pcall, fn, state)
			end
		end))
		remote:FireServer({ action = "state" }) -- подтянуть настоящее состояние с сервера
	end

	function GameLink.remote()
		bind(ReplicatedStorage:FindFirstChild("AutoParryRemote"))
		return remote
	end
	-- отправить запрос серверу игры; false — в этой игре нет серверного скрипта
	function GameLink.send(request)
		local found = GameLink.remote()
		if found then
			found:FireServer(request)
		end
		return found ~= nil
	end
	function GameLink.attribute(name, default)
		local found = GameLink.remote()
		local value = found and found:GetAttribute(name)
		if value == nil then
			return default
		end
		return value
	end
	-- fn(state) вызывается на каждый ответ сервера (и сразу, если ответ уже был)
	function GameLink.onState(fn)
		table.insert(listeners, fn)
		if GameLink.state then
			task.spawn(pcall, fn, GameLink.state)
		end
	end

	-- сервер мог ещё не создать Remote к моменту запуска меню
	Util.track(ReplicatedStorage.ChildAdded:Connect(function(child)
		if child.Name == "AutoParryRemote" then
			bind(child)
		end
	end))
	GameLink.remote()
end

------------------------- VISUALS (для вашего режима) -------------------------
-- Визуалы для вашей игры: мяч, его цель, игроки, зона отбивания, предупреждение.
-- Работают, только если сервер вашей игры разрешил вам Visuals (CONFIG.VISUALS_ACCESS,
-- по умолчанию только админам). Всё рисуется локально — видите только вы. Unload убирает всё.
do
	local Players = game:GetService("Players")
	local SoundService = game:GetService("SoundService")
	local localPlayer = Players.LocalPlayer
	local VisualsTab = Tabs["Visuals"]
	local WHITE = Color3.new(1, 1, 1)

	local cfg = {
		ballHighlight = false,
		ballColor = Color3.fromRGB(255, 120, 60),
		ballInfo = false,
		directionLine = false,
		lineColor = Color3.fromRGB(255, 220, 90),
		targetHighlight = false,
		targetColor = Color3.fromRGB(255, 70, 90),
		playerHighlight = false,
		playerColor = Color3.fromRGB(150, 160, 255),
		playerNames = false,
		playerDistance = true,
		range = false,
		rangeStyle = "Ring",
		rangeColor = Color3.fromRGB(120, 200, 255),
		dangerColor = Color3.fromRGB(255, 70, 90),
		alert = false,
		alertSound = false,
	}

	-- всё нарисованное лежит здесь
	local folder = Instance.new("Folder")
	folder.Name = "NocturneModeVisuals"
	folder.Parent = Window.gui.Parent

	-- надпись «мяч летит в вас» по центру сверху
	local alertGui = Instance.new("ScreenGui")
	alertGui.Name = "NocturneModeAlert"
	alertGui.IgnoreGuiInset = true
	alertGui.ResetOnSpawn = false
	alertGui.DisplayOrder = 50
	alertGui.Parent = Window.gui.Parent
	local alertLabel = Instance.new("TextLabel")
	alertLabel.AnchorPoint = Vector2.new(0.5, 0)
	alertLabel.Position = UDim2.new(0.5, 0, 0, 90)
	alertLabel.Size = UDim2.fromOffset(440, 36)
	alertLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	alertLabel.BackgroundTransparency = 0.3
	alertLabel.Font = Enum.Font.GothamBold
	alertLabel.TextSize = 18
	alertLabel.Visible = false
	alertLabel.Parent = alertGui
	local alertCorner = Instance.new("UICorner")
	alertCorner.CornerRadius = UDim.new(0, 8)
	alertCorner.Parent = alertLabel
	local alertStroke = Instance.new("UIStroke")
	alertStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	alertStroke.Thickness = 1.5
	alertStroke.Parent = alertLabel

	local alertSound = Instance.new("Sound")
	alertSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	alertSound.Volume = 0.6
	alertSound.Parent = SoundService

	Util.onUnload(function()
		folder:Destroy()
		alertGui:Destroy()
		alertSound:Destroy()
	end)

	------------------------------ доступ ------------------------------
	local function allowed()
		local state = GameLink.state
		return state ~= nil and state.visuals == true
	end

	local function statusText()
		if not GameLink.remote() then
			return "This game has no AutoParry server script."
		end
		local state = GameLink.state
		if not state then
			return "Waiting for the game server..."
		elseif state.visualsAccess == nil then
			return "Update AutoParry.server.lua in your game."
		elseif state.visuals == true then
			return "Active: the server allowed Visuals."
		elseif state.visualsAccess == "off" then
			return "The server turned Visuals off."
		end
		return "Visuals are for admins only."
	end

	------------------------------ мячи ------------------------------
	-- Папку и атрибут цели берём у сервера (CONFIG.BALLS_FOLDER / CONFIG.TARGET_ATTRIBUTE).
	local function getBalls()
		local container = workspace:FindFirstChild(tostring(GameLink.attribute("BallsFolder", "Balls")))
		return container and container:GetChildren() or {}
	end

	local function ballTarget(ball)
		local value = ball:GetAttribute(tostring(GameLink.attribute("TargetAttribute", "Target")))
		if typeof(value) == "string" then
			return Players:FindFirstChild(value)
		elseif typeof(value) == "number" then
			return Players:GetPlayerByUserId(value)
		end
		return nil
	end

	local function ballMotion(ball)
		if ball:IsA("BasePart") then
			return ball.Position, ball.AssemblyLinearVelocity
		elseif ball:IsA("Model") then
			local primary = ball.PrimaryPart
			return ball:GetPivot().Position, primary and primary.AssemblyLinearVelocity or Vector3.zero
		end
		return nil, nil
	end

	local function ballPart(ball)
		if ball:IsA("BasePart") then
			return ball
		end
		return ball.PrimaryPart or ball:FindFirstChildWhichIsA("BasePart", true)
	end

	------------------------------ объекты ------------------------------
	local function newHighlight(adornee, onTop)
		local highlight = Instance.new("Highlight")
		highlight.Adornee = adornee
		highlight.FillTransparency = 0.65
		highlight.OutlineTransparency = 0
		highlight.DepthMode = onTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
		highlight.Parent = folder
		return highlight
	end

	local function newTag(adornee, offset, onTop)
		local billboard = Instance.new("BillboardGui")
		billboard.Adornee = adornee
		billboard.Size = UDim2.fromOffset(220, 36)
		billboard.StudsOffset = offset
		billboard.AlwaysOnTop = onTop
		billboard.LightInfluence = 0
		billboard.MaxDistance = 400
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 13
		label.TextColor3 = WHITE
		label.TextStrokeTransparency = 0.35
		label.Parent = billboard
		billboard.Parent = folder
		return billboard, label
	end

	-- Adornee = Terrain: CFrame адорнмента задаём прямо в мировых координатах
	local function newAdornment(className)
		local adornment = Instance.new(className)
		adornment.Adornee = workspace.Terrain
		adornment.Parent = folder
		return adornment
	end

	local function drop(objects, key)
		local object = objects[key]
		if object then
			object:Destroy()
			objects[key] = nil
		end
	end

	local function dropAll(objects)
		for key in pairs(objects) do
			drop(objects, key)
		end
	end

	local ballObjects = {} -- [мяч] = { highlight, tag, label, line }
	local playerObjects = {} -- [игрок] = { highlight, tag, label }
	local rangeRing, rangeSphere, ringHollow
	local wasThreat = false

	local function clearAll()
		for ball, objects in pairs(ballObjects) do
			dropAll(objects)
			ballObjects[ball] = nil
		end
		for player, objects in pairs(playerObjects) do
			dropAll(objects)
			playerObjects[player] = nil
		end
		if rangeRing then
			rangeRing.Visible = false
		end
		if rangeSphere then
			rangeSphere.Visible = false
		end
		alertLabel.Visible = false
		wasThreat = false
	end

	------------------------------ кадр ------------------------------
	-- Мячи: подсветка, подпись (цель, скорость, расстояние), линия направления.
	-- Возвращает, кого мячи сейчас преследуют, и ближайший мяч, летящий в вас.
	local function updateBalls(myPos)
		local targeted, threat, seen = {}, nil, {}
		for _, ball in ipairs(getBalls()) do
			local position, velocity = ballMotion(ball)
			if position then
				seen[ball] = true
				local target = ballTarget(ball)
				if target then
					targeted[target] = true
				end
				local distance = myPos and (position - myPos).Magnitude
				if target == localPlayer and distance and (not threat or distance < threat.distance) then
					threat = { distance = distance, speed = velocity.Magnitude }
				end
				local objects = ballObjects[ball]
				if not objects then
					objects = {}
					ballObjects[ball] = objects
				end

				if cfg.ballHighlight then
					objects.highlight = objects.highlight or newHighlight(ball, true)
					objects.highlight.FillColor = cfg.ballColor
					objects.highlight.OutlineColor = cfg.ballColor
				else
					drop(objects, "highlight")
				end

				local part = cfg.ballInfo and ballPart(ball)
				if part then
					if not objects.tag or objects.tag.Adornee ~= part then
						drop(objects, "tag")
						objects.tag, objects.label = newTag(part, Vector3.new(0, 3, 0), true)
					end
					local text = (target and target.DisplayName or Library:Translate("No target")) .. "\n"
						.. math.floor(velocity.Magnitude + 0.5) .. " " .. Library:Translate("studs/s")
					if distance then
						text ..= "  ·  " .. math.floor(distance + 0.5) .. " " .. Library:Translate("studs")
					end
					objects.label.Text = text
					objects.label.TextColor3 = target == localPlayer and cfg.dangerColor or WHITE
				else
					drop(objects, "tag")
					objects.label = nil
				end

				if cfg.directionLine and velocity.Magnitude > 1 then
					objects.line = objects.line or newAdornment("CylinderHandleAdornment")
					local finish = position + velocity * 0.5 -- куда мяч долетит за полсекунды
					objects.line.Radius = 0.12
					objects.line.Height = (finish - position).Magnitude
					objects.line.CFrame = CFrame.lookAt((position + finish) / 2, finish)
					objects.line.Color3 = cfg.lineColor
					objects.line.AlwaysOnTop = true
					objects.line.Transparency = 0.25
				else
					drop(objects, "line")
				end
			end
		end
		for ball, objects in pairs(ballObjects) do
			if not seen[ball] then
				dropAll(objects)
				ballObjects[ball] = nil
			end
		end
		return targeted, threat
	end

	-- Игроки: подсветка цели мяча, подсветка остальных, ники с расстоянием.
	local function updatePlayers(myPos, targeted)
		local seen = {}
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local head = character and character:FindFirstChild("Head")
			local isTarget = targeted[player] == true
			local markTarget = cfg.targetHighlight and isTarget
			local wantHighlight = character ~= nil and (markTarget or (cfg.playerHighlight and player ~= localPlayer))
			local wantTag = head ~= nil and cfg.playerNames and player ~= localPlayer
			if wantHighlight or wantTag then
				seen[player] = true
				local objects = playerObjects[player]
				if not objects then
					objects = {}
					playerObjects[player] = objects
				end

				if wantHighlight then
					if objects.highlight and objects.highlight.Adornee ~= character then
						drop(objects, "highlight")
					end
					objects.highlight = objects.highlight or newHighlight(character, false)
					local color = markTarget and cfg.targetColor or cfg.playerColor
					objects.highlight.FillColor = color
					objects.highlight.OutlineColor = color
				else
					drop(objects, "highlight")
				end

				if wantTag then
					if not objects.tag or objects.tag.Adornee ~= head then
						drop(objects, "tag")
						objects.tag, objects.label = newTag(head, Vector3.new(0, 2.2, 0), false)
					end
					local text = Library.Settings.SafeMode and Library:Translate("Hidden") or player.DisplayName
					if cfg.playerDistance and myPos then
						text ..= "  [" .. math.floor((head.Position - myPos).Magnitude + 0.5) .. "]"
					end
					objects.label.Text = text
					objects.label.TextColor3 = isTarget and cfg.targetColor or WHITE
				else
					drop(objects, "tag")
					objects.label = nil
				end
			end
		end
		for player, objects in pairs(playerObjects) do
			if not seen[player] then
				dropAll(objects)
				playerObjects[player] = nil
			end
		end
	end

	-- Зона отбивания вокруг вас: радиус = ваша Parry Distance с сервера.
	-- Красная, когда мяч летит в вас.
	local function updateRange(root, threat)
		local show = cfg.range and root ~= nil
		local radius = GameLink.state and tonumber(GameLink.state.distance) or 5
		local color = threat and cfg.dangerColor or cfg.rangeColor

		if show and cfg.rangeStyle == "Sphere" then
			rangeSphere = rangeSphere or newAdornment("SphereHandleAdornment")
			rangeSphere.Radius = radius
			rangeSphere.CFrame = CFrame.new(root.Position)
			rangeSphere.Color3 = color
			rangeSphere.Transparency = 0.85
			rangeSphere.Visible = true
		elseif rangeSphere then
			rangeSphere.Visible = false
		end

		if show and cfg.rangeStyle ~= "Sphere" then
			if not rangeRing then
				rangeRing = newAdornment("CylinderHandleAdornment")
				rangeRing.Height = 0.15
				-- полое кольцо, если клиент поддерживает InnerRadius; иначе полупрозрачный диск
				ringHollow = pcall(function()
					rangeRing.InnerRadius = 0
				end)
			end
			local humanoid = Util.humanoid()
			local legs = 3 -- R6: от центра HumanoidRootPart до земли
			if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
				legs = humanoid.HipHeight + root.Size.Y / 2
			end
			rangeRing.Radius = radius
			if ringHollow then
				rangeRing.InnerRadius = math.max(0, radius - 0.35)
			end
			rangeRing.Transparency = ringHollow and 0.15 or 0.75
			rangeRing.CFrame = CFrame.new(root.Position - Vector3.new(0, legs - 0.1, 0)) * CFrame.Angles(math.rad(90), 0, 0)
			rangeRing.Color3 = color
			rangeRing.Visible = true
		elseif rangeRing then
			rangeRing.Visible = false
		end
	end

	-- Предупреждение и звук, когда мяч выбрал вас целью.
	local function updateAlert(threat)
		if cfg.alert and threat then
			alertLabel.Text = Library:Translate("Ball is coming to you") .. "  ·  "
				.. math.floor(threat.distance + 0.5) .. " " .. Library:Translate("studs")
			alertLabel.TextColor3 = cfg.dangerColor
			alertStroke.Color = cfg.dangerColor
			alertLabel.BackgroundTransparency = 0.3 + 0.15 * math.sin(os.clock() * 10)
			alertLabel.Visible = true
		else
			alertLabel.Visible = false
		end
		if cfg.alertSound and threat and not wasThreat then
			alertSound:Play()
		end
		wasThreat = threat ~= nil
	end

	local function anyEnabled()
		return cfg.ballHighlight or cfg.ballInfo or cfg.directionLine or cfg.targetHighlight
			or cfg.playerHighlight or cfg.playerNames or cfg.range or cfg.alert or cfg.alertSound
	end

	local cleared, reported = true, false
	Util.render(Enum.RenderPriority.Camera.Value + 1, function()
		if not (allowed() and anyEnabled()) then
			if not cleared then
				clearAll()
				cleared = true
			end
			return
		end
		cleared = false
		local ok, err = pcall(function()
			local root = Util.root()
			local myPos = root and root.Position
			local targeted, threat = updateBalls(myPos)
			updatePlayers(myPos, targeted)
			updateRange(root, threat)
			updateAlert(threat)
		end)
		if not ok and not reported then
			reported = true -- одна ошибка в консоль, а не по строке на кадр
			warn("[Nocturne] Visuals: " .. tostring(err))
		end
	end)

	------------------------------ интерфейс ------------------------------
	local status
	local warned = false
	local function refreshStatus()
		if status then
			status:Set(Library:Translate(statusText()))
		end
	end
	local function onToggle(key)
		return function(v)
			cfg[key] = v
			if v and not allowed() and not warned then
				warned = true -- одно уведомление, а не на каждый переключатель
				Util.notify("Visuals", statusText())
			end
		end
	end
	local function onColor(key)
		return function(color)
			cfg[key] = color
		end
	end

	local BallSection = VisualsTab:AddSection({ Name = "Ball", Side = "Left" })
	BallSection:AddToggle({ Name = "Ball Highlight", Icon = "eye", Default = false, Callback = onToggle("ballHighlight") })
		:AddColorpicker({ Default = cfg.ballColor, Callback = onColor("ballColor") })
	BallSection:AddToggle({ Name = "Ball Info", Icon = "list", Default = false, Callback = onToggle("ballInfo") })
	BallSection:AddToggle({ Name = "Direction Line", Icon = "crosshair", Default = false, Callback = onToggle("directionLine") })
		:AddColorpicker({ Default = cfg.lineColor, Callback = onColor("lineColor") })

	local PlayerSection = VisualsTab:AddSection({ Name = "Players", Side = "Left" })
	PlayerSection:AddToggle({ Name = "Ball Target", Icon = "target", Default = false, Callback = onToggle("targetHighlight") })
		:AddColorpicker({ Default = cfg.targetColor, Callback = onColor("targetColor") })
	PlayerSection:AddToggle({ Name = "Player Highlight", Icon = "user", Default = false, Callback = onToggle("playerHighlight") })
		:AddColorpicker({ Default = cfg.playerColor, Callback = onColor("playerColor") })
	PlayerSection:AddToggle({ Name = "Player Names", Icon = "user", Default = false, Callback = onToggle("playerNames") })
	PlayerSection:AddCheckbox({ Name = "Show Distance", Default = true, Callback = function(v)
		cfg.playerDistance = v
	end })

	local RangeSection = VisualsTab:AddSection({ Name = "Parry Range", Side = "Right" })
	RangeSection:AddToggle({ Name = "Show Range", Icon = "crosshair", Default = false, Callback = onToggle("range") })
		:AddColorpicker({ Default = cfg.rangeColor, Callback = onColor("rangeColor") })
	RangeSection:AddDropdown({ Name = "Range Style", Options = { "Ring", "Sphere" }, Default = "Ring", Width = 110, Callback = function(v)
		cfg.rangeStyle = v
	end })
	RangeSection:AddColorpicker({ Name = "Danger Color", Default = cfg.dangerColor, Callback = onColor("dangerColor") })
	RangeSection:AddLabel("Radius = Parry Distance (Miscellaneous).")

	local AlertSection = VisualsTab:AddSection({ Name = "Target Alert", Side = "Right" })
	AlertSection:AddToggle({ Name = "Alert Text", Icon = "eye", Default = false, Callback = onToggle("alert") })
	AlertSection:AddToggle({ Name = "Alert Sound", Icon = "bars", Default = false, Callback = onToggle("alertSound") })

	local StatusSection = VisualsTab:AddSection({ Name = "Status", Side = "Right" })
	status = StatusSection:AddLabel(statusText())
	GameLink.onState(refreshStatus)
	table.insert(Library._languageListeners, refreshStatus) -- после смены языка вернуть живой текст

	Util.tr({
		Ball = "Мяч",
		["Ball Highlight"] = "Подсветка мяча",
		["Ball Info"] = "Инфо о мяче",
		["Direction Line"] = "Линия направления",
		Players = "Игроки",
		["Ball Target"] = "Цель мяча",
		["Player Highlight"] = "Подсветка игроков",
		["Player Names"] = "Ники игроков",
		["Show Distance"] = "Показывать расстояние",
		["Parry Range"] = "Зона отбивания",
		["Show Range"] = "Показать зону",
		["Range Style"] = "Вид зоны",
		Ring = "Кольцо",
		Sphere = "Сфера",
		["Danger Color"] = "Цвет опасности",
		["Radius = Parry Distance (Miscellaneous)."] = "Радиус = Дистанция отбивания (Miscellaneous).",
		["Target Alert"] = "Предупреждение",
		["Alert Text"] = "Надпись",
		["Alert Sound"] = "Звук",
		Status = "Статус",
		["No target"] = "Без цели",
		["studs/s"] = "ст/с",
		studs = "ст",
		["Ball is coming to you"] = "Мяч летит в вас",
		["This game has no AutoParry server script."] = "В этой игре нет серверного скрипта AutoParry.",
		["Waiting for the game server..."] = "Ждём ответа сервера игры...",
		["Update AutoParry.server.lua in your game."] = "Обновите AutoParry.server.lua в своей игре.",
		["Active: the server allowed Visuals."] = "Работает: сервер разрешил Visuals.",
		["The server turned Visuals off."] = "Сервер выключил Visuals.",
		["Visuals are for admins only."] = "Visuals только для админов.",
	})
end

------------------------- AUTO PARRY (для вашей игры) -------------------------
-- Отбивает сервер вашей игры; меню только включает/выключает и задаёт дистанцию.
-- По умолчанию выключено. Доступ решает сервер (по умолчанию — только админы).
do
	local section = Tabs["Miscellaneous"]:AddSection({ Name = "Auto Parry", Side = "Left" })
	local toggle, slider
	local pendingDistance = 0

	toggle = section:AddToggle({ Name = "Auto Parry", Icon = "crosshair", Default = false, Callback = function(v)
		if not GameLink.send({ action = "set", value = v }) and v then
			Util.notify("Auto Parry", "This game has no AutoParry server script.")
			task.defer(function()
				toggle:Set(false, true)
			end)
		end
	end })
	toggle:AddKeybind({}) -- клавиши по умолчанию нет: P уже занята кнопкой в самой игре

	slider = section:AddSlider({ Name = "Parry Distance", Min = 1, Max = 20, Default = 5, Suffix = " studs", Callback = function(v)
		-- шлём не на каждый шаг ползунка, а через 0.3 с после последнего изменения
		pendingDistance += 1
		local token = pendingDistance
		task.delay(0.3, function()
			if token == pendingDistance then
				GameLink.send({ action = "distance", value = v })
			end
		end)
	end })

	section:AddLabel("Works only in a game with the AutoParry server script.")

	-- сервер присылает настоящее состояние: держим меню в согласии с ним
	GameLink.onState(function(state)
		if state.owner == false and toggle.Value then
			Util.notify("Auto Parry", state.access == "admins" and "Auto Parry is for admins only."
				or "Auto Parry is not available to you in this game.")
		end
		local on = state.enabled == true
		if toggle.Value ~= on then
			toggle:Set(on, true)
		end
		if type(state.distance) == "number" and slider.Value ~= state.distance then
			slider:Set(state.distance, true)
		end
	end)

	Util.tr({
		["Auto Parry"] = "Авто-отбивание",
		["Parry Distance"] = "Дистанция отбивания",
		[" studs"] = " стадов",
		["Auto Parry is not available to you in this game."] = "Авто-отбивание недоступно вам в этой игре.",
		["Auto Parry is for admins only."] = "Авто-отбивание только для админов.",
		["Works only in a game with the AutoParry server script."] = "Работает только в игре с серверным скриптом AutoParry.",
	})
end

-- переприменить язык: подписи новых вкладок тоже переведутся
Library:SetLanguage(Library.Settings.Language)

Window:Notify({
	Title = "Nocturne",
	Text = "Menu loaded. Press " .. Window.ToggleKey.Name .. " to hide or show it.",
	Duration = 5,
})
