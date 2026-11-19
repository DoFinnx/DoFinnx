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
-- Раскладка по референсу: слева настройки для выбранной цели (Enemies / Teammates),
-- справа превью вашего персонажа и кнопка панели ESP Items. Только интерфейс.
local Visuals = Window:AddTab({ Name = "Visuals", Icon = "eye" })

do
	local MODEL_STYLES = { "Disabled", "Flat", "Textured", "Glow", "Metallic", "Wireframe" }

	-- Набор секций для одной цели. Возвращает секции, чтобы показывать/прятать их.
	local function buildTarget(label, colors)
		local main = Visuals:AddSection({ Name = label, Side = "Left" })
		main:AddToggle({ Name = "Enabled", Default = false })
		main:AddToggle({ Name = "Offscreen Arrow", Default = false }):AddColorpicker({ Default = colors.arrow })
		main:AddToggle({ Name = "Sounds", Default = false }):AddColorpicker({ Default = colors.sounds })

		local model = Visuals:AddSection({ Name = label .. " Model", Side = "Left" })
		for _, row in ipairs({
			{ "Player", colors.player },
			{ "Behind Walls", colors.walls },
			{ "On Shot", colors.shot },
			{ "History", colors.history },
			{ "Ragdolls", colors.ragdolls },
		}) do
			model:AddDropdown({ Name = row[1], Options = MODEL_STYLES, Default = "Disabled", Width = 130 })
				:AddColorpicker({ Default = row[2] })
		end
		model:AddToggle({ Name = "Soul Particles", Default = false }):AddColorpicker({ Default = colors.soul })
		model:AddToggle({ Name = "Glow", Default = false }):AddColorpicker({ Default = colors.glow })
		return { main, model }
	end

	local targets = {
		Enemies = buildTarget("Enemy", {
			arrow = Color3.fromRGB(255, 255, 255),
			sounds = Color3.fromRGB(236, 96, 140),
			player = Color3.fromRGB(150, 160, 255),
			walls = Color3.fromRGB(90, 230, 240),
			shot = Color3.fromRGB(200, 225, 215),
			history = Color3.fromRGB(170, 170, 175),
			ragdolls = Color3.fromRGB(150, 145, 175),
			soul = Color3.fromRGB(100, 110, 255),
			glow = Color3.fromRGB(200, 190, 245),
		}),
		Teammates = buildTarget("Teammate", {
			arrow = Color3.fromRGB(255, 255, 255),
			sounds = Color3.fromRGB(96, 200, 140),
			player = Color3.fromRGB(120, 220, 160),
			walls = Color3.fromRGB(90, 200, 120),
			shot = Color3.fromRGB(200, 225, 215),
			history = Color3.fromRGB(170, 170, 175),
			ragdolls = Color3.fromRGB(150, 175, 160),
			soul = Color3.fromRGB(100, 220, 160),
			glow = Color3.fromRGB(180, 240, 200),
		}),
	}

	-- Панели ESP Items: своя у каждой цели, открываются кнопкой-списком в превью.
	local function buildEspPanel(title)
		local panel = Visuals:CreatePanel(title)
		panel:AddGroup():AddChips({
			Name = "Main",
			Options = { "Bounding Box", "Name", "Distance", "Health Bar", "Ammo Bar", "Skeleton" },
		})
		panel:AddGroup():AddChips({
			Name = "Flags",
			Options = {
				"Unarmored", "Defuser", "Blind", "Scoped", "Reload", "Immunity", "Slowed", "Vulnerable",
				"Bomb", "Hostage", "Defuse", "Pin Pulled", "Money", "Order Priority", "Delay",
			},
		})
		panel:AddGroup():AddChips({
			Name = "Weapon",
			Options = { "Text", "Icon", "Readiness Bar", "Bomb", "Defuser", "Taser" },
		})
		return panel
	end
	local espPanels = {
		Enemies = buildEspPanel("ESP Items"),
		Teammates = buildEspPanel("ESP Items "),
	}

	local currentMode = "Enemies"
	local function showTarget(mode)
		currentMode = mode
		Window:_closeAll()
		for name, sections in pairs(targets) do
			for _, section in ipairs(sections) do
				section.frame.Visible = name == mode
			end
		end
	end

	Visuals:AddPreview({
		Side = "Right",
		Height = 470,
		Modes = {
			{ Name = "Enemies", Icon = "user" },
			{ Name = "Teammates", Icon = "userMinus" },
		},
		Default = "Enemies",
		Callback = showTarget,
		Buttons = {
			{
				Icon = "list",
				Callback = function(button)
					Window:TogglePanel(espPanels[currentMode], button)
				end,
			},
		},
	})
	showTarget("Enemies")

	for key, value in pairs({
		Enemy = "Враг",
		["Enemy Model"] = "Модель врага",
		Teammate = "Союзник",
		["Teammate Model"] = "Модель союзника",
		["Offscreen Arrow"] = "Стрелка за экраном",
		Sounds = "Звуки",
		["Behind Walls"] = "За стенами",
		["On Shot"] = "При выстреле",
		["Soul Particles"] = "Частицы души",
		Enemies = "Враги",
		Teammates = "Союзники",
		["ESP Items "] = "Элементы ESP",
		Hostage = "Заложник",
		Defuse = "Разминирование",
		["Pin Pulled"] = "Чека выдернута",
		["Order Priority"] = "Приоритет",
		Taser = "Тейзер",
	}) do
		RU[key] = value
	end
end

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
	}

	local RENDER_NAME = "NocturneView_" .. tostring(math.random(1, 1e6))
	RunService:BindToRenderStep(RENDER_NAME, Enum.RenderPriority.Camera.Value + 1, function()
		local cam = camera()
		if not cam then
			return
		end
		if view.fov then
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
	local removals = { ["Post Processing"] = false, Shadows = false, ["Decals & Textures"] = false }
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
						if effect:IsA("PostEffect") and effect.Enabled then
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
	end

	-- Игры часто сами переставляют свет и камеру, поэтому регулярно применяем настройки заново.
	task.spawn(function()
		while Window.gui.Parent do
			pcall(applyAmbience)
			pcall(applyRemovals)
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
			setFov(false)
			view.stretch = false
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
		Options = { "Post Processing", "Shadows", "Decals & Textures" },
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

	local serverPanel = MiscSection:AddSubmenu({ Name = "Server", Icon = "globe" })
	local serverGroup = serverPanel:AddGroup()
	serverGroup:AddButton({
		Name = "Rejoin Server",
		Callback = function()
			local TeleportService = game:GetService("TeleportService")
			Window:Notify({ Title = "Server", Text = "Rejoining...", Duration = 3 })
			local ok = pcall(function()
				if game.JobId ~= "" then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
				else
					TeleportService:Teleport(game.PlaceId, localPlayer)
				end
			end)
			if not ok then
				Window:Notify({ Title = "Server", Text = "Rejoin failed.", Duration = 3 })
			end
		end,
	})
	serverGroup:AddButton({
		Name = "Copy Server ID",
		Callback = function()
			if type(setclipboard) == "function" then
				pcall(setclipboard, game.JobId)
				Window:Notify({ Title = "Server", Text = "Server ID copied.", Duration = 3 })
			else
				Window:Notify({ Title = "Server", Text = "This executor has no setclipboard.", Duration = 3 })
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
}) do
	RU[key] = value
end

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
