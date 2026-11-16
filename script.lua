--[[
	NeverloseUI v2 — тёмное «стеклянное» меню для Roblox (Luau)
	Стиль: сайдбар с категориями/подвкладками, карточки с заголовками, пресеты, поиск,
	окно профиля, колорпикер с HEX. Иконки рисуются фигурами (без шрифтовых символов).

	Использование:
		local UI = loadstring(game:HttpGet("...script.lua"))()
		local ui = UI.new({ Title = "MYMODE", Subtitle = "Roblox", Accent = Color3.fromRGB(72,108,247) })
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local Theme = {
	Window = Color3.fromRGB(13, 16, 23),
	Sidebar = Color3.fromRGB(12, 15, 21),
	Card = Color3.fromRGB(17, 21, 29),
	Box = Color3.fromRGB(25, 29, 40),
	Active = Color3.fromRGB(31, 36, 48),
	Stroke = Color3.fromRGB(32, 38, 51),
	Divider = Color3.fromRGB(27, 32, 43),
	Popup = Color3.fromRGB(15, 18, 26),
	Text = Color3.fromRGB(226, 230, 240),
	SubText = Color3.fromRGB(128, 137, 154),
	Off = Color3.fromRGB(52, 57, 69),
	OffKnob = Color3.fromRGB(122, 128, 142),
}

local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local MOUSE1 = Enum.UserInputType.MouseButton1
local TOUCH = Enum.UserInputType.Touch
local MOVE = Enum.UserInputType.MouseMovement
local WHITE = Color3.new(1, 1, 1)

---------------------------------------------------------------------
-- helpers
---------------------------------------------------------------------
local function create(class, props, children)
	local inst = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			inst[k] = v
		end
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	inst.Parent = parent
	return inst
end

local function tween(obj, t, props, style, dir)
	local tw = TweenService:Create(
		obj,
		TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local function apply(obj, props, animate, t)
	if animate == false then
		for k, v in pairs(props) do
			obj[k] = v
		end
	else
		tween(obj, t or 0.15, props)
	end
end

local function corner(parent, r)
	return create("UICorner", { CornerRadius = UDim.new(0, r), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function label(parent, str, size, color, font, xalign)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Text = str,
		TextSize = size or 13,
		TextColor3 = color or Theme.Text,
		Font = font or FONT,
		TextXAlignment = xalign or Enum.TextXAlignment.Left,
		Parent = parent,
	})
end

local function isPointer(input)
	return input.UserInputType == MOUSE1 or input.UserInputType == TOUCH
end

local function dragger(frame, callback)
	frame.InputBegan:Connect(function(input)
		if not isPointer(input) then
			return
		end
		callback(input.Position)
		local move = UserInputService.InputChanged:Connect(function(i)
			if i.UserInputType == MOVE or i.UserInputType == TOUCH then
				callback(i.Position)
			end
		end)
		local finish
		finish = UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == input.UserInputType then
				move:Disconnect()
				finish:Disconnect()
			end
		end)
	end)
end

local function decimalsOf(step)
	local frac = tostring(step):match("%.(%d+)")
	return frac and #frac or 0
end

local function hexOf(c, a)
	return string.format(
		"#%02X%02X%02X%02X",
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5),
		math.floor((a or 1) * 255 + 0.5)
	)
end

---------------------------------------------------------------------
-- иконки (рисуются фигурами, цвет меняется через tint)
---------------------------------------------------------------------
local function part(parent, x, y, w, h, o)
	o = o or {}
	local f = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		Rotation = o.rot or 0,
		BackgroundColor3 = WHITE,
		BackgroundTransparency = o.ring and 1 or 0,
		BorderSizePixel = 0,
		Parent = parent,
	})
	if o.round then
		corner(f, 100)
	elseif o.radius then
		corner(f, o.radius)
	elseif not o.ring and (w <= 2 or h <= 2) then
		corner(f, 1)
	end
	if o.ring then
		stroke(f, WHITE, o.thick or 1.5)
	end
	return f
end

local Icons = {}
Icons.dot = function(p)
	part(p, 9, 9, 5, 5, { round = true })
end
Icons.crosshair = function(p)
	part(p, 9, 9, 11, 11, { ring = true, round = true })
	part(p, 9, 2.5, 1.5, 4)
	part(p, 9, 15.5, 1.5, 4)
	part(p, 2.5, 9, 4, 1.5)
	part(p, 15.5, 9, 4, 1.5)
	part(p, 9, 9, 2, 2, { round = true })
end
Icons.mouse = function(p)
	part(p, 9, 9, 10, 15, { ring = true, radius = 5 })
	part(p, 9, 6, 1.5, 4)
end
Icons.image = function(p)
	part(p, 9, 9, 15, 12, { ring = true, radius = 3 })
	part(p, 6.5, 7, 3, 3, { round = true })
	part(p, 11.5, 11.5, 6, 1.5, { rot = -35 })
end
Icons.layers = function(p)
	part(p, 9, 4.5, 12, 3, { radius = 1.5 })
	part(p, 9, 9, 15, 3, { radius = 1.5 })
	part(p, 9, 13.5, 12, 3, { radius = 1.5 })
end
Icons.sliders = function(p)
	part(p, 9, 4, 14, 1.5)
	part(p, 9, 9, 14, 1.5)
	part(p, 9, 14, 14, 1.5)
	part(p, 6, 4, 4, 4, { round = true })
	part(p, 12, 9, 4, 4, { round = true })
	part(p, 7, 14, 4, 4, { round = true })
end
Icons.globe = function(p)
	part(p, 9, 9, 14, 14, { ring = true, round = true })
	part(p, 9, 9, 1.5, 14)
	part(p, 9, 9, 14, 1.5)
	part(p, 9, 9, 6, 14, { ring = true, round = true })
end
Icons.user = function(p)
	part(p, 9, 5.5, 6, 6, { round = true })
	part(p, 9, 13.5, 12, 6, { radius = 3 })
end
Icons.gear = function(p)
	part(p, 9, 9, 12, 12, { ring = true, round = true, thick = 2 })
	part(p, 9, 9, 4, 4, { round = true })
end
Icons.search = function(p)
	part(p, 8, 8, 10, 10, { ring = true, round = true })
	part(p, 14.5, 14.5, 6, 1.8, { rot = 45 })
end
Icons.save = function(p)
	part(p, 9, 9, 13, 13, { ring = true, radius = 3 })
	part(p, 9, 5.5, 7, 3.5)
	part(p, 9, 13, 6, 4, { radius = 1 })
end
Icons.plus = function(p)
	part(p, 9, 9, 12, 1.8)
	part(p, 9, 9, 1.8, 12)
end
Icons.trash = function(p)
	part(p, 9, 5, 13, 1.8)
	part(p, 9, 3.5, 4, 2)
	part(p, 9, 11.5, 10, 10, { ring = true, radius = 2 })
end
Icons.upload = function(p)
	part(p, 9, 10, 1.8, 10)
	part(p, 6.5, 5.5, 6.5, 1.8, { rot = -45 })
	part(p, 11.5, 5.5, 6.5, 1.8, { rot = 45 })
	part(p, 9, 15.5, 12, 1.8)
end
Icons.cloud = function(p)
	part(p, 6, 11, 8, 8, { round = true })
	part(p, 11, 8.5, 9, 9, { round = true })
	part(p, 10, 12, 12, 6, { radius = 3 })
end
Icons.dots = function(p)
	part(p, 4.5, 9, 3, 3, { round = true })
	part(p, 9, 9, 3, 3, { round = true })
	part(p, 13.5, 9, 3, 3, { round = true })
end
Icons.chevdown = function(p)
	part(p, 6.5, 9, 7, 1.8, { rot = 45 })
	part(p, 11.5, 9, 7, 1.8, { rot = -45 })
end
Icons.chevright = function(p)
	part(p, 9, 6.5, 7, 1.8, { rot = 45 })
	part(p, 9, 11.5, 7, 1.8, { rot = -45 })
end

local function tint(container, c)
	if container:IsA("ImageLabel") then
		container.ImageColor3 = c
		return
	end
	for _, d in ipairs(container:GetDescendants()) do
		if d:IsA("UIStroke") then
			d.Color = c
		elseif d:IsA("Frame") and d.BackgroundTransparency == 0 then
			d.BackgroundColor3 = c
		end
	end
end

local function icon(parent, name, color)
	if type(name) == "string" and name:sub(1, 6) == "rbxass" then
		return create("ImageLabel", {
			BackgroundTransparency = 1,
			Image = name,
			ImageColor3 = color or Theme.SubText,
			Size = UDim2.fromOffset(18, 18),
			Parent = parent,
		})
	end
	local box = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(18, 18),
		Parent = parent,
	})
	;(Icons[name] or Icons.dot)(box)
	tint(box, color or Theme.SubText)
	return box
end

local function placeIcon(ic, anchorX, posX, offX)
	ic.AnchorPoint = Vector2.new(anchorX, 0.5)
	ic.Position = UDim2.new(posX, offX, 0.5, 0)
end

---------------------------------------------------------------------
-- классы
---------------------------------------------------------------------
local Library = {}
Library.__index = Library

local Tab = {}
Tab.__index = Tab

local Group = {}
Group.__index = Group

---------------------------------------------------------------------
-- окно
---------------------------------------------------------------------
function Library.new(opts)
	opts = opts or {}
	local self = setmetatable({}, Library)

	self.Accent = opts.Accent or Color3.fromRGB(72, 108, 247)
	self.Flags = {}
	self.ToggleKey = opts.ToggleKey or Enum.KeyCode.Insert
	self.Visible = false
	self.Presets = {}
	self.PresetName = nil
	self._ready = false
	self._allTabs = {}
	self._accentFns = {}
	self._conns = {}
	self._ctrls = {}
	self._shadows = {}
	self._order = 0
	self._cfgFile = opts.ConfigFile or "NeverloseUI_presets.json"

	local title = opts.Title or "NEVERLOSE"
	local size = opts.Size or Vector2.new(750, 580)
	self.Size = size

	-- подгоняем масштаб под экран, чтобы окно не вылезало
	local fit = 1
	local cam = workspace.CurrentCamera
	if cam then
		local vp = cam.ViewportSize
		fit = math.min(vp.X / (size.X + 30), vp.Y / (size.Y + 60))
	end
	self.Scale = math.max(0.5, math.min(opts.Scale or 1, fit))

	local parent = opts.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
	local old = parent:FindFirstChild("NeverloseUI")
	if old then
		old:Destroy()
	end
	local oldBlur = Lighting:FindFirstChild("NeverloseBlur")
	if oldBlur then
		oldBlur:Destroy()
	end

	self.Gui = create("ScreenGui", {
		Name = "NeverloseUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
		Parent = parent,
	})
	self.Root = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1 / self.Scale, 1 / self.Scale),
		Parent = self.Gui,
	})
	self.UIScale = create("UIScale", { Scale = self.Scale, Parent = self.Root })

	-- Holder: тень + окно (двигаем вместе)
	self.Holder = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		BackgroundTransparency = 1,
		Parent = self.Root,
	})
	self.Pop = create("UIScale", { Scale = 0.95, Parent = self.Holder })
	for i = 1, 5 do
		local sh = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 8),
			Size = UDim2.new(1, i * 8, 1, i * 8),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 1,
			Parent = self.Holder,
		})
		corner(sh, 16 + i * 5)
		table.insert(self._shadows, { frame = sh, base = 0.93 })
	end

	self.Main = create("CanvasGroup", {
		Name = "Main",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Window,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 2,
		Parent = self.Holder,
	})
	corner(self.Main, 16)
	stroke(self.Main, Theme.Stroke, 1, 0.2)

	---------------------------------------------------------------- сайдбар
	local SIDE_W = 158
	local side = create("Frame", {
		Size = UDim2.new(0, SIDE_W, 1, 0),
		BackgroundColor3 = Theme.Sidebar,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = self.Main,
	})
	create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Parent = side,
	})

	local logoArea = create("Frame", {
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundTransparency = 1,
		Parent = side,
	})
	local logoText = opts.Logo or string.upper(string.sub(title, 1, 2))
	local logo = label(logoArea, logoText, 17, WHITE, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
	logo.Position = UDim2.fromOffset(14, 14)
	logo.Size = UDim2.fromOffset(34, 34)
	local tl = label(logoArea, title, 14, WHITE, FONT_BOLD)
	tl.Position = UDim2.fromOffset(54, 15)
	tl.Size = UDim2.new(1, -60, 0, 18)
	tl.TextTruncate = Enum.TextTruncate.AtEnd
	local sl = label(logoArea, opts.Subtitle or "", 10, Theme.SubText)
	sl.Position = UDim2.fromOffset(54, 33)
	sl.Size = UDim2.new(1, -60, 0, 14)
	sl.TextTruncate = Enum.TextTruncate.AtEnd
	create("Frame", {
		Position = UDim2.new(0, 14, 1, 0),
		Size = UDim2.new(1, -28, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Parent = logoArea,
	})

	-- список вкладок (ScrollingFrame, чтобы ничего не уезжало)
	self.Nav = create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 66),
		Size = UDim2.new(1, -1, 1, -66 - 62),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = side,
	})
	create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = self.Nav,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Nav,
	})

	-- карточка пользователя
	create("Frame", {
		Position = UDim2.new(0, 14, 1, -62),
		Size = UDim2.new(1, -28, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Parent = side,
	})
	local userBtn = create("TextButton", {
		Position = UDim2.new(0, 10, 1, -52),
		Size = UDim2.new(1, -20, 0, 42),
		BackgroundColor3 = Theme.Active,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = side,
	})
	corner(userBtn, 8)
	local lp = Players.LocalPlayer
	local avatar = create("ImageLabel", {
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Theme.Box,
		BorderSizePixel = 0,
		Parent = userBtn,
	})
	corner(avatar, 15)
	task.spawn(function()
		local ok, img = pcall(function()
			return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and img then
			avatar.Image = img
		end
	end)
	local un = label(userBtn, lp.DisplayName, 13, WHITE, FONT_BOLD)
	un.Position = UDim2.fromOffset(44, 5)
	un.Size = UDim2.new(1, -72, 0, 16)
	un.TextTruncate = Enum.TextTruncate.AtEnd
	local ui = label(userBtn, opts.UserInfo or "@" .. lp.Name, 11, Theme.SubText)
	ui.Position = UDim2.fromOffset(44, 21)
	ui.Size = UDim2.new(1, -72, 0, 14)
	ui.TextTruncate = Enum.TextTruncate.AtEnd
	local uc = icon(userBtn, "chevright", Theme.SubText)
	placeIcon(uc, 1, 1, -4)
	userBtn.MouseEnter:Connect(function()
		tween(userBtn, 0.12, { BackgroundTransparency = 0.5 })
	end)
	userBtn.MouseLeave:Connect(function()
		tween(userBtn, 0.12, { BackgroundTransparency = 1 })
	end)
	userBtn.MouseButton1Click:Connect(function()
		self:_openSettings(userBtn)
	end)

	---------------------------------------------------------------- контент
	local content = create("Frame", {
		Position = UDim2.fromOffset(SIDE_W, 0),
		Size = UDim2.new(1, -SIDE_W, 1, 0),
		BackgroundTransparency = 1,
		Parent = self.Main,
	})
	local topbar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
		Parent = content,
	})
	create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Parent = topbar,
	})
	self.Pages = create("Frame", {
		Position = UDim2.fromOffset(0, 55),
		Size = UDim2.new(1, 0, 1, -55),
		BackgroundTransparency = 1,
		Parent = content,
	})

	self.TopLeft = create("Frame", {
		Size = UDim2.new(1, -70, 1, 0),
		BackgroundTransparency = 1,
		Parent = topbar,
	})
	create("UIPadding", { PaddingLeft = UDim.new(0, 14), Parent = self.TopLeft })
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.TopLeft,
	})

	-- кнопка пресетов
	local presetBtn = create("TextButton", {
		Size = UDim2.fromOffset(150, 30),
		BackgroundColor3 = Theme.Box,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = 0,
		Parent = self.TopLeft,
	})
	corner(presetBtn, 8)
	stroke(presetBtn, Theme.Stroke, 1, 0.4)
	local psave = icon(presetBtn, "save", WHITE)
	placeIcon(psave, 0, 0, 9)
	create("Frame", {
		Position = UDim2.fromOffset(34, 6),
		Size = UDim2.new(0, 1, 1, -12),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = presetBtn,
	})
	self._presetLabel = label(presetBtn, "No preset", 12, Theme.Text)
	self._presetLabel.Position = UDim2.fromOffset(44, 0)
	self._presetLabel.Size = UDim2.new(1, -70, 1, 0)
	self._presetLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local pch = icon(presetBtn, "chevdown", Theme.SubText)
	placeIcon(pch, 1, 1, -4)
	presetBtn.MouseButton1Click:Connect(function()
		self:_openPresets(presetBtn)
	end)

	-- поиск
	local searchBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Theme.Active,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = topbar,
	})
	corner(searchBtn, 8)
	local sic = icon(searchBtn, "search", WHITE)
	placeIcon(sic, 0.5, 0.5, 0)
	local searchBox = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -52, 0.5, 0),
		Size = UDim2.fromOffset(170, 28),
		BackgroundColor3 = Theme.Box,
		Visible = false,
		Parent = topbar,
	})
	corner(searchBox, 8)
	local searchInput = create("TextBox", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Search",
		PlaceholderColor3 = Theme.SubText,
		TextColor3 = Theme.Text,
		TextSize = 12,
		Font = FONT,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = searchBox,
	})
	searchBtn.MouseButton1Click:Connect(function()
		searchBox.Visible = not searchBox.Visible
		if searchBox.Visible then
			searchInput:CaptureFocus()
		else
			searchInput.Text = ""
		end
	end)
	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		self:_applySearch(searchInput.Text)
	end)

	-- перетаскивание за верхнюю панель и логотип
	local function makeDraggable(handle)
		handle.InputBegan:Connect(function(input)
			if not isPointer(input) then
				return
			end
			local startMouse = input.Position
			local startPos = self.Holder.Position
			local move = UserInputService.InputChanged:Connect(function(i)
				if i.UserInputType == MOVE or i.UserInputType == TOUCH then
					local d = (i.Position - startMouse) / self.Scale
					self.Holder.Position =
						UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				end
			end)
			local finish
			finish = UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == input.UserInputType then
					move:Disconnect()
					finish:Disconnect()
				end
			end)
		end)
	end
	makeDraggable(topbar)
	makeDraggable(logoArea)

	---------------------------------------------------------------- оверлей
	self.Overlay = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 100,
		Parent = self.Root,
	})
	local catcher = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 1,
		Parent = self.Overlay,
	})
	catcher.MouseButton1Click:Connect(function()
		self:_closePopup()
	end)

	if opts.Blur ~= false then
		self.BlurSize = opts.BlurSize or 12
		self.Blur = create("BlurEffect", { Size = 0, Name = "NeverloseBlur", Parent = Lighting })
	end

	self:_connect(UserInputService.InputBegan, function(input, gp)
		if not gp and self._ready and input.KeyCode == self.ToggleKey then
			self:SetVisible(not self.Visible)
		end
	end)

	self:_readPresets()

	-- стартовая анимация
	if opts.Intro == false then
		self._ready = true
		self:SetVisible(true)
	else
		task.spawn(function()
			local splash = create("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(500, 70),
				BackgroundTransparency = 1,
				Text = title,
				TextSize = 44,
				Font = Enum.Font.GothamBlack,
				TextColor3 = WHITE,
				TextTransparency = 1,
				Parent = self.Root,
			})
			local line = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 36),
				Size = UDim2.fromOffset(0, 2),
				BackgroundColor3 = self.Accent,
				BorderSizePixel = 0,
				Parent = self.Root,
			})
			tween(splash, 0.5, { TextTransparency = 0 })
			tween(line, 0.7, { Size = UDim2.fromOffset(190, 2) }, Enum.EasingStyle.Quart)
			task.wait(1.1)
			tween(splash, 0.35, { TextTransparency = 1 })
			tween(line, 0.35, { BackgroundTransparency = 1 })
			task.wait(0.4)
			splash:Destroy()
			line:Destroy()
			self._ready = true
			self:SetVisible(true)
		end)
	end

	return self
end

function Library:_connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._conns, c)
	return c
end

function Library:_next()
	self._order += 1
	return self._order
end

function Library:_onAccent(fn)
	table.insert(self._accentFns, fn)
	fn(self.Accent)
end

function Library:SetAccent(color)
	self.Accent = color
	for _, fn in ipairs(self._accentFns) do
		fn(color)
	end
end

function Library:SetScale(scale)
	scale = math.max(0.5, scale)
	self.Scale = scale
	self.UIScale.Scale = scale
	self.Root.Size = UDim2.fromScale(1 / scale, 1 / scale)
end

function Library:SetVisible(v)
	self.Visible = v
	if v then
		self.Main.Visible = true
	end
	tween(self.Main, 0.2, { GroupTransparency = v and 0 or 1 })
	tween(self.Pop, 0.2, { Scale = v and 1 or 0.96 })
	for _, s in ipairs(self._shadows) do
		tween(s.frame, 0.2, { BackgroundTransparency = v and s.base or 1 })
	end
	if self.Blur then
		tween(self.Blur, 0.25, { Size = v and self.BlurSize or 0 })
	end
	if not v then
		self:_closePopup()
		task.delay(0.2, function()
			if not self.Visible then
				self.Main.Visible = false
			end
		end)
	end
end

function Library:Destroy()
	for _, c in ipairs(self._conns) do
		c:Disconnect()
	end
	if self.Blur then
		self.Blur:Destroy()
	end
	self.Gui:Destroy()
end

---------------------------------------------------------------------
-- попапы
---------------------------------------------------------------------
function Library:_closePopup()
	if self._popupFrame then
		self._popupFrame:Destroy()
		self._popupFrame = nil
	end
	self.Overlay.Visible = false
end

-- opts: { above = bool, right = bool }
function Library:_popup(anchor, width, height, build, opts)
	opts = opts or {}
	self:_closePopup()
	local aPos = (anchor.AbsolutePosition - self.Root.AbsolutePosition) / self.Scale
	local aSize = anchor.AbsoluteSize / self.Scale
	local rootSize = self.Root.AbsoluteSize / self.Scale

	local x = opts.right and (aPos.X + aSize.X - width) or aPos.X
	local y = opts.above and (aPos.Y - height - 6) or (aPos.Y + aSize.Y + 6)
	x = math.clamp(x, 4, math.max(4, rootSize.X - width - 4))
	if y + height > rootSize.Y - 4 then
		y = aPos.Y - height - 6
	end
	y = math.max(4, y)

	local holder = create("Frame", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(width, height),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = self.Overlay,
	})
	for i = 1, 4 do
		local sh = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 4),
			Size = UDim2.new(1, i * 6, 1, i * 6),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.92,
			BorderSizePixel = 0,
			ZIndex = 1,
			Parent = holder,
		})
		corner(sh, 12 + i * 4)
	end
	local frame = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Popup,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 2,
		Parent = holder,
	})
	corner(frame, 12)
	stroke(frame, Theme.Stroke, 1, 0.1)
	self._popupFrame = holder
	self.Overlay.Visible = true
	build(frame)
	return frame
end

-- выпадающий список
function Library:_listPopup(anchor, items, isSel, onPick, keepOpen)
	local lib = self
	local h = math.min(#items * 28 + 10, 200)
	local w = math.max(anchor.AbsoluteSize.X / self.Scale, 110)
	self:_popup(anchor, w, h, function(frame)
		local sc = create("ScrollingFrame", {
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.new(1, -8, 1, -8),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = frame,
		})
		create("UIListLayout", { Padding = UDim.new(0, 2), Parent = sc })
		local buttons = {}
		local function paint()
			for it, b in pairs(buttons) do
				local sel = isSel(it)
				b.TextColor3 = sel and lib.Accent or Theme.Text
				b.BackgroundTransparency = sel and 0.4 or 1
			end
		end
		for _, it in ipairs(items) do
			local b = create("TextButton", {
				Size = UDim2.new(1, -4, 0, 26),
				BackgroundColor3 = Theme.Box,
				BackgroundTransparency = 1,
				Text = "  " .. tostring(it),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 12,
				Font = FONT,
				AutoButtonColor = false,
				Parent = sc,
			})
			corner(b, 6)
			buttons[it] = b
			b.MouseButton1Click:Connect(function()
				onPick(it)
				paint()
				if not keepOpen then
					lib:_closePopup()
				end
			end)
		end
		paint()
	end, { right = true })
end

---------------------------------------------------------------------
-- колорпикер (попап)
---------------------------------------------------------------------
-- st: { h, s, v, a, name, changed = function() }
function Library:_openColor(anchor, st)
	self:_popup(anchor, 250, 296, function(frame)
		local function col()
			return Color3.fromHSV(st.h, st.s, st.v)
		end

		local chip = create("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(96, 26),
			BackgroundColor3 = Theme.Box,
			BorderSizePixel = 0,
			Parent = frame,
		})
		corner(chip, 8)
		local chipDot = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = col(),
			BorderSizePixel = 0,
			Parent = chip,
		})
		corner(chipDot, 6)
		local chipName = label(chip, st.name or "Color", 12, Theme.Text)
		chipName.Position = UDim2.fromOffset(28, 0)
		chipName.Size = UDim2.new(1, -32, 1, 0)
		chipName.TextTruncate = Enum.TextTruncate.AtEnd

		-- SV поле
		local sv = create("Frame", {
			Position = UDim2.fromOffset(12, 48),
			Size = UDim2.fromOffset(226, 150),
			BackgroundColor3 = Color3.fromHSV(st.h, 1, 1),
			BorderSizePixel = 0,
			Parent = frame,
		})
		corner(sv, 8)
		local white = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
			Parent = sv,
		})
		corner(white, 8)
		create("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
		local black = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Parent = sv,
		})
		corner(black, 8)
		create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
		local cursor = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = col(),
			BorderSizePixel = 0,
			Parent = sv,
		})
		corner(cursor, 7)
		stroke(cursor, WHITE, 2)

		-- Hue
		local hueTrack = create("Frame", {
			Position = UDim2.fromOffset(12, 206),
			Size = UDim2.fromOffset(226, 10),
			BackgroundTransparency = 1,
			Parent = frame,
		})
		local hueBar = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
			Parent = hueTrack,
		})
		corner(hueBar, 5)
		local seq = {}
		for i = 0, 6 do
			table.insert(seq, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i == 6 and 0 or i / 6, 1, 1)))
		end
		create("UIGradient", { Color = ColorSequence.new(seq), Parent = hueBar })
		local hueKnob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = Color3.fromHSV(st.h, 1, 1),
			BorderSizePixel = 0,
			Parent = hueTrack,
		})
		corner(hueKnob, 7)
		stroke(hueKnob, WHITE, 2)

		-- Alpha
		local alphaTrack = create("Frame", {
			Position = UDim2.fromOffset(12, 224),
			Size = UDim2.fromOffset(226, 10),
			BackgroundTransparency = 1,
			Parent = frame,
		})
		local alphaCanvas = create("CanvasGroup", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(72, 76, 88),
			BorderSizePixel = 0,
			Parent = alphaTrack,
		})
		corner(alphaCanvas, 5)
		for c = 0, 45 do
			for r = 0, 1 do
				if (c + r) % 2 == 0 then
					create("Frame", {
						Position = UDim2.fromOffset(c * 5, r * 5),
						Size = UDim2.fromOffset(5, 5),
						BackgroundColor3 = Color3.fromRGB(48, 52, 62),
						BorderSizePixel = 0,
						Parent = alphaCanvas,
					})
				end
			end
		end
		local alphaOverlay = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = col(),
			BorderSizePixel = 0,
			Parent = alphaCanvas,
		})
		create("UIGradient", { Transparency = NumberSequence.new(1, 0), Parent = alphaOverlay })
		local alphaKnob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = col(),
			BorderSizePixel = 0,
			Parent = alphaTrack,
		})
		corner(alphaKnob, 7)
		stroke(alphaKnob, WHITE, 2)

		create("Frame", {
			Position = UDim2.fromOffset(12, 246),
			Size = UDim2.fromOffset(226, 1),
			BackgroundColor3 = Theme.Divider,
			BorderSizePixel = 0,
			Parent = frame,
		})

		-- HEX
		local hl = label(frame, "HEX", 12, Theme.SubText, FONT_BOLD)
		hl.Position = UDim2.fromOffset(12, 254)
		hl.Size = UDim2.fromOffset(44, 28)
		local hexField = create("Frame", {
			Position = UDim2.fromOffset(58, 254),
			Size = UDim2.fromOffset(180, 28),
			BackgroundColor3 = Theme.Box,
			BorderSizePixel = 0,
			Parent = frame,
		})
		corner(hexField, 8)
		local hexDot = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = col(),
			BorderSizePixel = 0,
			Parent = hexField,
		})
		corner(hexDot, 7)
		local hexBox = create("TextBox", {
			Position = UDim2.fromOffset(30, 0),
			Size = UDim2.new(1, -36, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			TextColor3 = Theme.Text,
			TextSize = 12,
			Font = FONT,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = hexField,
		})

		local function refresh(fire)
			local c = col()
			local hc = Color3.fromHSV(st.h, 1, 1)
			sv.BackgroundColor3 = hc
			cursor.Position = UDim2.fromScale(st.s, 1 - st.v)
			cursor.BackgroundColor3 = c
			hueKnob.Position = UDim2.fromScale(st.h, 0.5)
			hueKnob.BackgroundColor3 = hc
			alphaOverlay.BackgroundColor3 = c
			alphaKnob.Position = UDim2.fromScale(st.a, 0.5)
			alphaKnob.BackgroundColor3 = c
			chipDot.BackgroundColor3 = c
			hexDot.BackgroundColor3 = c
			hexBox.Text = hexOf(c, st.a)
			if fire and st.changed then
				st.changed()
			end
		end

		dragger(sv, function(pos)
			st.s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
			st.v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
			refresh(true)
		end)
		dragger(hueTrack, function(pos)
			st.h = math.clamp((pos.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 0.999)
			refresh(true)
		end)
		dragger(alphaTrack, function(pos)
			st.a = math.clamp((pos.X - alphaTrack.AbsolutePosition.X) / alphaTrack.AbsoluteSize.X, 0, 1)
			refresh(true)
		end)
		hexBox.FocusLost:Connect(function()
			local t = hexBox.Text:gsub("[^%x]", "")
			if #t == 6 or #t == 8 then
				local r = tonumber(t:sub(1, 2), 16)
				local g = tonumber(t:sub(3, 4), 16)
				local b = tonumber(t:sub(5, 6), 16)
				st.h, st.s, st.v = Color3.toHSV(Color3.fromRGB(r, g, b))
				if #t == 8 then
					st.a = tonumber(t:sub(7, 8), 16) / 255
				end
			end
			refresh(true)
		end)
		refresh(false)
	end, { right = true })
end

---------------------------------------------------------------------
-- пресеты
---------------------------------------------------------------------
function Library:_snapshot()
	local snap = {}
	for flag, c in pairs(self._ctrls) do
		snap[flag] = c.Save()
	end
	return snap
end

function Library:_applySnapshot(snap)
	for flag, v in pairs(snap) do
		local c = self._ctrls[flag]
		if c then
			pcall(c.Load, v)
		end
	end
end

function Library:_writePresets()
	if writefile then
		pcall(function()
			writefile(self._cfgFile, HttpService:JSONEncode({ presets = self.Presets, current = self.PresetName }))
		end)
	end
end

function Library:_readPresets()
	if readfile and isfile then
		pcall(function()
			if isfile(self._cfgFile) then
				local data = HttpService:JSONDecode(readfile(self._cfgFile))
				self.Presets = data.presets or {}
				self.PresetName = data.current
				if self.PresetName then
					self._presetLabel.Text = self.PresetName
				end
			end
		end)
	end
end

function Library:SavePreset(name)
	self.Presets[name] = self:_snapshot()
	self.PresetName = name
	self._presetLabel.Text = name
	self:_writePresets()
end

function Library:LoadPreset(name)
	local snap = self.Presets[name]
	if snap then
		self:_applySnapshot(snap)
		self.PresetName = name
		self._presetLabel.Text = name
		self:_writePresets()
	end
end

function Library:DeletePreset(name)
	self.Presets[name] = nil
	if self.PresetName == name then
		self.PresetName = nil
		self._presetLabel.Text = "No preset"
	end
	self:_writePresets()
end

function Library:_openPresets(anchor)
	local lib = self
	self:_popup(anchor, 300, 250, function(frame)
		-- шапка
		local head = create("Frame", {
			Position = UDim2.fromOffset(8, 8),
			Size = UDim2.new(1, -16, 0, 30),
			BackgroundTransparency = 1,
			Parent = frame,
		})
		local chip = create("Frame", {
			Size = UDim2.fromOffset(92, 30),
			BackgroundColor3 = Theme.Box,
			BorderSizePixel = 0,
			Parent = head,
		})
		corner(chip, 8)
		local cic = icon(chip, "cloud", lib.Accent)
		placeIcon(cic, 0, 0, 8)
		local cl = label(chip, "Presets", 12, lib.Accent, FONT_BOLD)
		cl.Position = UDim2.fromOffset(32, 0)
		cl.Size = UDim2.new(1, -34, 1, 0)

		local listFrame
		local query = ""
		local function render()
			for _, c in ipairs(listFrame:GetChildren()) do
				if c:IsA("Frame") then
					c:Destroy()
				end
			end
			local names = {}
			for n in pairs(lib.Presets) do
				if query == "" or n:lower():find(query, 1, true) then
					table.insert(names, n)
				end
			end
			table.sort(names)
			for _, n in ipairs(names) do
				local item = create("Frame", {
					Size = UDim2.new(1, -4, 0, 34),
					BackgroundColor3 = Theme.Box,
					BorderSizePixel = 0,
					Parent = listFrame,
				})
				corner(item, 8)
				if lib.PresetName == n then
					stroke(item, lib.Accent, 1, 0.3)
				end
				local nb = create("TextButton", {
					Size = UDim2.new(1, -44, 1, 0),
					BackgroundTransparency = 1,
					Text = "  " .. n,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = Theme.Text,
					TextSize = 12,
					Font = FONT,
					AutoButtonColor = false,
					Parent = item,
				})
				nb.MouseButton1Click:Connect(function()
					lib:LoadPreset(n)
					render()
				end)
				local sb = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.fromOffset(26, 26),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					Parent = item,
				})
				local sbi = icon(sb, "save", Theme.SubText)
				placeIcon(sbi, 0.5, 0.5, 0)
				sb.MouseButton1Click:Connect(function()
					lib:SavePreset(n)
					render()
				end)
			end
		end

		local function headBtn(iconName, offX, cb)
			local b = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, offX, 0.5, 0),
				Size = UDim2.fromOffset(28, 28),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = head,
			})
			local i = icon(b, iconName, Theme.SubText)
			placeIcon(i, 0.5, 0.5, 0)
			b.MouseEnter:Connect(function()
				tint(i, lib.Accent)
			end)
			b.MouseLeave:Connect(function()
				tint(i, Theme.SubText)
			end)
			b.MouseButton1Click:Connect(cb)
		end
		headBtn("plus", 0, function()
			local n = 1
			while lib.Presets["Preset " .. n] do
				n += 1
			end
			lib:SavePreset("Preset " .. n)
			render()
		end)
		headBtn("trash", -30, function()
			if lib.PresetName then
				lib:DeletePreset(lib.PresetName)
				render()
			end
		end)
		headBtn("upload", -60, function()
			if setclipboard and lib.PresetName then
				pcall(function()
					setclipboard(HttpService:JSONEncode(lib.Presets[lib.PresetName]))
				end)
			end
		end)

		-- поиск
		local sbox = create("Frame", {
			Position = UDim2.fromOffset(8, 46),
			Size = UDim2.new(1, -16, 0, 32),
			BackgroundColor3 = Theme.Box,
			BorderSizePixel = 0,
			Parent = frame,
		})
		corner(sbox, 8)
		local si = icon(sbox, "search", Theme.SubText)
		placeIcon(si, 0, 0, 8)
		local input = create("TextBox", {
			Position = UDim2.fromOffset(34, 0),
			Size = UDim2.new(1, -42, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = "Search",
			PlaceholderColor3 = Theme.SubText,
			TextColor3 = Theme.Text,
			TextSize = 12,
			Font = FONT,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = sbox,
		})
		input:GetPropertyChangedSignal("Text"):Connect(function()
			query = input.Text:lower()
			render()
		end)

		listFrame = create("ScrollingFrame", {
			Position = UDim2.fromOffset(8, 88),
			Size = UDim2.new(1, -16, 1, -96),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = frame,
		})
		create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = listFrame })
		render()
	end)
end

---------------------------------------------------------------------
-- окно профиля / настройки меню
---------------------------------------------------------------------
function Library:_openSettings(anchor)
	local lib = self
	self:_popup(anchor, 250, 232, function(frame)
				local av = create("ImageLabel", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(36, 36),
			BackgroundColor3 = Theme.Box,
			ImageColor3 = Color3.new(1, 1, 1), -- ВАЖНО: делает картинку видимой
			BorderSizePixel = 0,
			Image = "",
			Parent = frame,
		})
		corner(av, 18)

		task.spawn(function()
			local ok, img = pcall(function()
				return Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			end)
			if ok and img then
				av.Image = img
			end
		end)
		local n = label(frame, lp.DisplayName, 13, WHITE, FONT_BOLD)
		n.Position = UDim2.fromOffset(56, 14)
		n.Size = UDim2.new(1, -68, 0, 16)
		local k = label(frame, "Toggle key: " .. lib.ToggleKey.Name, 11, lib.Accent)
		k.Position = UDim2.fromOffset(56, 31)
		k.Size = UDim2.new(1, -68, 0, 14)
		create("Frame", {
			Position = UDim2.fromOffset(12, 58),
			Size = UDim2.new(1, -24, 0, 1),
			BackgroundColor3 = Theme.Divider,
			BorderSizePixel = 0,
			Parent = frame,
		})

		local function prow(y, iconName, text)
			local b = create("TextButton", {
				Position = UDim2.fromOffset(8, y),
				Size = UDim2.new(1, -16, 0, 34),
				BackgroundColor3 = Theme.Active,
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = frame,
			})
			corner(b, 8)
			local ic = icon(b, iconName, Theme.SubText)
			placeIcon(ic, 0, 0, 8)
			local l = label(b, text, 13, Theme.Text)
			l.Position = UDim2.fromOffset(36, 0)
			l.Size = UDim2.new(1, -120, 1, 0)
			b.MouseEnter:Connect(function()
				tween(b, 0.1, { BackgroundTransparency = 0.5 })
			end)
			b.MouseLeave:Connect(function()
				tween(b, 0.1, { BackgroundTransparency = 1 })
			end)
			return b
		end

		-- масштаб
		local scales = { 0.75, 0.9, 1, 1.15, 1.25, 1.5 }
		local sBtn = prow(66, "sliders", "Menu Scale")
		local sVal = label(sBtn, "", 12, Theme.SubText, FONT, Enum.TextXAlignment.Right)
		sVal.Position = UDim2.new(1, -34, 0, 0)
		sVal.Size = UDim2.new(0, 60, 1, 0)
		local sch = icon(sBtn, "chevright", Theme.SubText)
		placeIcon(sch, 1, 1, -4)
		local function showScale()
			sVal.Text = string.format("%d%%", math.floor(lib.Scale * 100 + 0.5))
		end
		showScale()
		sBtn.MouseButton1Click:Connect(function()
			local nextS = scales[1]
			for _, s in ipairs(scales) do
				if s > lib.Scale + 0.001 then
					nextS = s
					break
				end
			end
			lib:SetScale(nextS)
			showScale()
		end)

		-- акцент-цвет
		local aBtn = prow(100, "gear", "Style")
		local aSw = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = lib.Accent,
			BorderSizePixel = 0,
			Parent = aBtn,
		})
		corner(aSw, 5)
		aBtn.MouseButton1Click:Connect(function()
			local st = { name = "Accent", a = 1 }
			st.h, st.s, st.v = Color3.toHSV(lib.Accent)
			function st.changed()
				lib:SetAccent(Color3.fromHSV(st.h, st.s, st.v))
			end
			lib:_openColor(aBtn, st)
		end)

		-- блюр
		local bBtn = prow(134, "layers", "Background Blur")
		local pill = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(34, 20),
			BackgroundColor3 = Theme.Off,
			BorderSizePixel = 0,
			Parent = bBtn,
		})
		corner(pill, 10)
		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = Theme.OffKnob,
			BorderSizePixel = 0,
			Parent = pill,
		})
		corner(knob, 8)
		local function paintBlur()
			local on = lib.Blur ~= nil and lib.BlurSize > 0
			pill.BackgroundColor3 = on and lib.Accent or Theme.Off
			knob.BackgroundColor3 = on and WHITE or Theme.OffKnob
			knob.Position = on and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		end
		paintBlur()
		bBtn.MouseButton1Click:Connect(function()
			if lib.Blur then
				lib.BlurSize = (lib.BlurSize > 0) and 0 or 12
				tween(lib.Blur, 0.2, { Size = lib.BlurSize })
				paintBlur()
			end
		end)

		-- выгрузить
		local uBtn = prow(168, "trash", "Unload Menu")
		uBtn.MouseButton1Click:Connect(function()
			lib:Destroy()
		end)
	end, { above = true })
end

---------------------------------------------------------------------
-- поиск по элементам
---------------------------------------------------------------------
function Library:_applySearch(q)
	q = (q or ""):lower()
	for _, tab in ipairs(self._allTabs) do
		for _, g in ipairs(tab._groups) do
			local any = false
			local titleMatch = q == "" or g.Title:lower():find(q, 1, true) ~= nil
			for _, row in ipairs(g._rows) do
				local m = titleMatch or row.Name:lower():find(q, 1, true) ~= nil
				row.Frame.Visible = m
				any = any or m
			end
			g.Holder.Visible = any
		end
	end
end

---------------------------------------------------------------------
-- верхний выпадающий список (рядом с пресетами)
---------------------------------------------------------------------
function Library:TopDropdown(items, default, callback)
	local lib = self
	local value = default or items[1]
	local b = create("TextButton", {
		Size = UDim2.fromOffset(92, 30),
		BackgroundColor3 = Theme.Box,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = #self.TopLeft:GetChildren(),
		Parent = self.TopLeft,
	})
	corner(b, 8)
	stroke(b, Theme.Stroke, 1, 0.4)
	local t = label(b, tostring(value), 12, Theme.Text)
	t.Position = UDim2.fromOffset(12, 0)
	t.Size = UDim2.new(1, -34, 1, 0)
	t.TextTruncate = Enum.TextTruncate.AtEnd
	local ch = icon(b, "chevdown", Theme.SubText)
	placeIcon(ch, 1, 1, -4)

	local api = {}
	function api:Get()
		return value
	end
	function api:Set(v)
		value = v
		t.Text = tostring(v)
		if callback then
			task.spawn(callback, v)
		end
	end
	b.MouseButton1Click:Connect(function()
		lib:_listPopup(b, items, function(it)
			return it == value
		end, function(it)
			api:Set(it)
		end, false)
	end)
	return api
end

---------------------------------------------------------------------
-- вкладки
---------------------------------------------------------------------
function Library:Category(name)
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		LayoutOrder = self:_next(),
		Parent = self.Nav,
	})
	local l = label(holder, string.upper(name), 10, Theme.SubText, FONT_BOLD)
	l.Position = UDim2.fromOffset(8, 4)
	l.Size = UDim2.new(1, -8, 1, -4)
	return l
end
Library.Section = Library.Category

local function makeTab(lib, name, icn, parent)
	local tab = setmetatable({
		Lib = lib,
		Name = name,
		Parent = parent,
		IsChild = parent ~= nil,
		Children = {},
		_groups = {},
		_active = false,
	}, Tab)

	local indent = parent and 16 or 0
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		LayoutOrder = lib:_next(),
		Visible = (parent == nil),
		Parent = lib.Nav,
	})
	local btn = create("TextButton", {
		Position = UDim2.fromOffset(indent, 0),
		Size = UDim2.new(1, -indent, 1, 0),
		BackgroundColor3 = Theme.Active,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = holder,
	})
	corner(btn, 8)
	local ic = icon(btn, icn or "dot", Theme.SubText)
	placeIcon(ic, 0, 0, 9)
	local text = label(btn, name, 13, Theme.SubText)
	text.Position = UDim2.fromOffset(36, 0)
	text.Size = UDim2.new(1, -40, 1, 0)
	text.TextTruncate = Enum.TextTruncate.AtEnd
	tab.Holder = holder

	function tab:_style(animate)
		local on = self._active
		apply(btn, { BackgroundTransparency = on and 0 or 1 }, animate)
		apply(text, { TextColor3 = on and WHITE or Theme.SubText }, animate)
		tint(ic, on and lib.Accent or Theme.SubText)
	end
	lib:_onAccent(function()
		tab:_style(false)
	end)

	-- страница
	local page = create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Stroke,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = lib.Pages,
	})
	create("UIPadding", {
		PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 14),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		Parent = page,
	})
	local function column(pos)
		local col = create("Frame", {
			Position = pos,
			Size = UDim2.new(0.5, -7, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = page,
		})
		create("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder, Parent = col })
		return col
	end
	tab.Page = page
	tab._left = column(UDim2.new(0, 0, 0, 0))
	tab._right = column(UDim2.new(0.5, 7, 0, 0))

	btn.MouseButton1Click:Connect(function()
		lib:_select(tab)
	end)
	btn.MouseEnter:Connect(function()
		if not tab._active then
			tween(btn, 0.12, { BackgroundTransparency = 0.6 })
		end
	end)
	btn.MouseLeave:Connect(function()
		if not tab._active then
			tween(btn, 0.12, { BackgroundTransparency = 1 })
		end
	end)

	table.insert(lib._allTabs, tab)
	if parent then
		table.insert(parent.Children, tab)
		if lib._active == parent then
			lib:_select(tab)
		end
	end
	if #lib._allTabs == 1 then
		lib:_select(tab)
	end
	return tab
end

function Library:Tab(name, icn)
	return makeTab(self, name, icn, nil)
end

function Tab:SubTab(name, icn)
	return makeTab(self.Lib, name, icn, self)
end

function Library:_select(tab)
	self:_closePopup()
	if #tab.Children > 0 then
		tab = tab.Children[1]
	end
	self._active = tab
	for _, t in ipairs(self._allTabs) do
		local on = (t == tab) or (tab.Parent == t)
		t._active = on
		t.Page.Visible = (t == tab)
		if t.IsChild then
			t.Holder.Visible = (t == tab) or (tab.Parent == t.Parent)
		end
		t:_style()
	end
end

function Tab:Group(name, side)
	local lib = self.Lib
	local col = (side == "right") and self._right or self._left
	local g = setmetatable({ Lib = lib, Title = name, _order = 0, _rows = {} }, Group)

	g.Holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = #col:GetChildren(),
		Parent = col,
	})
	create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = g.Holder })
	local head = label(g.Holder, string.upper(name), 10, Theme.SubText, FONT_BOLD)
	head.Size = UDim2.new(1, 0, 0, 14)
	head.LayoutOrder = 0
	create("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = head })

	g.Frame = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Parent = g.Holder,
	})
	corner(g.Frame, 10)
	stroke(g.Frame, Theme.Stroke, 1, 0.2)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = g.Frame })

	table.insert(self._groups, g)
	return g
end

---------------------------------------------------------------------
-- строки и компоненты
---------------------------------------------------------------------
function Group:_row(name, height)
	self._order += 1
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, height or 37),
		BackgroundTransparency = 1,
		LayoutOrder = self._order,
		Parent = self.Frame,
	})
	local div = create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, 0),
		Size = UDim2.new(1, -24, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Visible = false,
		Parent = row,
	})
	if self._lastDiv then
		self._lastDiv.Visible = true
	end
	self._lastDiv = div
	table.insert(self._rows, { Frame = row, Name = name or "" })
	return row
end

local function rowLabel(row, text, reserve)
	local l = label(row, text, 13, Theme.Text)
	l.Position = UDim2.fromOffset(12, 0)
	l.Size = UDim2.new(1, -(24 + (reserve or 0)), 1, 0)
	l.TextTruncate = Enum.TextTruncate.AtEnd
	return l
end

local function boxButton(parent, w, h)
	local b = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(w, h),
		BackgroundColor3 = Theme.Box,
		Text = "",
		AutoButtonColor = false,
		Parent = parent,
	})
	corner(b, 6)
	return b
end

local function register(lib, flag, save, load)
	if flag then
		lib._ctrls[flag] = { Save = save, Load = load }
	end
end

local function fire(lib, flag, value, cb)
	if flag then
		lib.Flags[flag] = value
	end
	if cb then
		task.spawn(cb, value)
	end
end

function Group:Label(text)
	local r = self:_row(text, 30)
	local l = label(r, text, 12, Theme.SubText)
	l.Position = UDim2.fromOffset(12, 0)
	l.Size = UDim2.new(1, -24, 1, 0)
	return l
end

function Group:Button(o)
	local r = self:_row(o.Name, 41)
	local b = create("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -24, 0, 27),
		BackgroundColor3 = Theme.Box,
		Text = o.Name or "Button",
		TextColor3 = Theme.Text,
		TextSize = 12,
		Font = FONT,
		AutoButtonColor = false,
		Parent = r,
	})
	corner(b, 7)
	b.MouseEnter:Connect(function()
		tween(b, 0.12, { BackgroundColor3 = Theme.Active })
	end)
	b.MouseLeave:Connect(function()
		tween(b, 0.12, { BackgroundColor3 = Theme.Box })
	end)
	b.MouseButton1Click:Connect(function()
		if o.Callback then
			task.spawn(o.Callback)
		end
	end)
	return b
end

-- Строка-переход (со стрелкой ">"): { Name, Callback }
function Group:Submenu(o)
	local lib = self.Lib
	local r = self:_row(o.Name)
	rowLabel(r, o.Name or "Submenu", 30)
	local ch = icon(r, "chevright", Theme.SubText)
	placeIcon(ch, 1, 1, -10)
	local hit = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = r,
	})
	hit.MouseEnter:Connect(function()
		tint(ch, lib.Accent)
	end)
	hit.MouseLeave:Connect(function()
		tint(ch, Theme.SubText)
	end)
	hit.MouseButton1Click:Connect(function()
		if o.Callback then
			task.spawn(o.Callback)
		end
	end)
	return hit
end

-- цветной свотч (используется и в Toggle:AddColor, и в Group:ColorPicker)
local function makeColor(lib, row, o, xoff)
	local sw = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, xoff, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = row,
	})
	corner(sw, 6)
	stroke(sw, WHITE, 1, 0.85)

	local st = { name = o.Name or "Color", a = o.Alpha or 1 }
	st.h, st.s, st.v = Color3.toHSV(o.Default or Color3.fromRGB(255, 63, 87))

	local api = {}
	local function color()
		return Color3.fromHSV(st.h, st.s, st.v)
	end
	local function paint()
		sw.BackgroundColor3 = color()
		sw.BackgroundTransparency = math.min(1 - st.a, 0.8)
	end
	function st.changed()
		paint()
		local c = color()
		if o.Flag then
			lib.Flags[o.Flag] = { Color = c, Alpha = st.a }
		end
		if o.Callback then
			task.spawn(o.Callback, c, st.a)
		end
	end
	function api:Get()
		return color(), st.a
	end
	function api:Set(c, alpha)
		st.h, st.s, st.v = Color3.toHSV(c)
		st.a = alpha or st.a
		st.changed()
	end
	register(lib, o.Flag, function()
		local c = color()
		return {
			t = "c",
			r = math.floor(c.R * 255 + 0.5),
			g = math.floor(c.G * 255 + 0.5),
			b = math.floor(c.B * 255 + 0.5),
			a = st.a,
		}
	end, function(v)
		api:Set(Color3.fromRGB(v.r, v.g, v.b), v.a)
	end)

	sw.MouseButton1Click:Connect(function()
		lib:_openColor(sw, st)
	end)
	paint()
	if o.Flag then
		lib.Flags[o.Flag] = { Color = color(), Alpha = st.a }
	end
	return api
end

-- Toggle: { Name, Flag, Default, Callback }   +  toggle:AddColor({ Name, Default, Alpha, Flag, Callback })
function Group:Toggle(o)
	local lib = self.Lib
	local r = self:_row(o.Name)
	rowLabel(r, o.Name or "Toggle", 70)

	local pill = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(34, 20),
		BackgroundColor3 = Theme.Off,
		Text = "",
		AutoButtonColor = false,
		Parent = r,
	})
	corner(pill, 10)
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Theme.OffKnob,
		BorderSizePixel = 0,
		Parent = pill,
	})
	corner(knob, 8)

	local api = { _n = 0 }
	local state = o.Default == true
	local function render(animate)
		apply(pill, { BackgroundColor3 = state and lib.Accent or Theme.Off }, animate)
		apply(knob, {
			Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			BackgroundColor3 = state and WHITE or Theme.OffKnob,
		}, animate)
	end
	lib:_onAccent(function()
		render(false)
	end)

	function api:Set(v, silent)
		state = v and true or false
		render(true)
		if silent then
			if o.Flag then
				lib.Flags[o.Flag] = state
			end
		else
			fire(lib, o.Flag, state, o.Callback)
		end
	end
	function api:Get()
		return state
	end
	function api:AddColor(co)
		self._n += 1
		return makeColor(lib, r, co, -(12 + 34 + 10) - (self._n - 1) * 24)
	end
	register(lib, o.Flag, function()
		return state
	end, function(v)
		api:Set(v)
	end)

	pill.MouseButton1Click:Connect(function()
		api:Set(not state)
	end)
	if o.Flag then
		lib.Flags[o.Flag] = state
	end
	return api
end

-- Slider: { Name, Min, Max, Default, Step, Suffix, Flag, Callback }   (Step=1 → int, 0.1 → float)
function Group:Slider(o)
	local lib = self.Lib
	local min, max = o.Min or 0, o.Max or 100
	local step = o.Step or 1
	local dec = decimalsOf(step)
	local suffix = o.Suffix or ""

	local r = self:_row(o.Name)
	rowLabel(r, o.Name or "Slider", 160)

	local box = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(48, 22),
		BackgroundColor3 = Theme.Box,
		TextColor3 = Theme.SubText,
		TextSize = 12,
		Font = FONT,
		ClearTextOnFocus = false,
		Text = "",
		Parent = r,
	})
	corner(box, 6)

	local hit = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -68, 0.5, 0),
		Size = UDim2.fromOffset(88, 20),
		BackgroundTransparency = 1,
		Parent = r,
	})
	local bar = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5, 0),
		Size = UDim2.new(1, -12, 0, 3),
		BackgroundColor3 = Theme.Off,
		BorderSizePixel = 0,
		Parent = hit,
	})
	corner(bar, 2)
	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = lib.Accent,
		BorderSizePixel = 0,
		Parent = bar,
	})
	corner(fill, 2)
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Parent = bar,
	})
	corner(knob, 6)
	lib:_onAccent(function(c)
		fill.BackgroundColor3 = c
	end)

	local value = o.Default or min
	local api = {}
	local function snap(v)
		v = math.clamp(v, min, max)
		v = math.floor((v - min) / step + 0.5) * step + min
		return tonumber(string.format("%." .. dec .. "f", math.clamp(v, min, max)))
	end
	local function render()
		local ratio = (max == min) and 0 or (value - min) / (max - min)
		tween(fill, 0.08, { Size = UDim2.fromScale(ratio, 1) })
		tween(knob, 0.08, { Position = UDim2.fromScale(ratio, 0.5) })
		box.Text = string.format("%." .. dec .. "f", value) .. suffix
	end

	function api:Set(v, silent)
		v = snap(v)
		local changed = v ~= value
		value = v
		render()
		if silent then
			if o.Flag then
				lib.Flags[o.Flag] = value
			end
		elseif changed then
			fire(lib, o.Flag, value, o.Callback)
		end
	end
	function api:Get()
		return value
	end
	register(lib, o.Flag, function()
		return value
	end, function(v)
		api:Set(v)
	end)

	dragger(hit, function(pos)
		local ratio = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		api:Set(min + ratio * (max - min))
	end)
	box.Focused:Connect(function()
		box.Text = string.format("%." .. dec .. "f", value)
		box.TextColor3 = Theme.Text
	end)
	box.FocusLost:Connect(function()
		box.TextColor3 = Theme.SubText
		local n = tonumber(box.Text:match("-?%d+%.?%d*"))
		if n then
			api:Set(n)
		else
			render()
		end
	end)

	value = snap(value)
	render()
	if o.Flag then
		lib.Flags[o.Flag] = value
	end
	return api
end

-- Combo: { Name, Items, Default, Multi, Flag, Callback }   Single → строка, Multi → { [item] = true }
function Group:Combo(o)
	local lib = self.Lib
	local items = o.Items or {}
	local multi = o.Multi == true

	local r = self:_row(o.Name)
	rowLabel(r, o.Name or "Combo", 146)

	local btn = boxButton(r, 134, 24)
	local shown = label(btn, "", 12, Theme.Text)
	shown.Position = UDim2.fromOffset(10, 0)
	shown.Size = UDim2.new(1, -30, 1, 0)
	shown.TextTruncate = Enum.TextTruncate.AtEnd
	local ch = icon(btn, "chevdown", Theme.SubText)
	placeIcon(ch, 1, 1, -3)

	local value
	if multi then
		value = {}
		for _, k in ipairs(o.Default or {}) do
			value[k] = true
		end
	else
		value = o.Default or items[1]
	end

	local function display()
		if multi then
			local t = {}
			for _, it in ipairs(items) do
				if value[it] then
					table.insert(t, tostring(it))
				end
			end
			shown.Text = #t > 0 and table.concat(t, ", ") or "None"
		else
			shown.Text = tostring(value)
		end
	end
	display()

	local api = {}
	function api:Get()
		return value
	end
	function api:Set(v, silent)
		value = v
		display()
		if not silent then
			fire(lib, o.Flag, value, o.Callback)
		elseif o.Flag then
			lib.Flags[o.Flag] = value
		end
	end
	register(lib, o.Flag, function()
		if multi then
			local list = {}
			for _, it in ipairs(items) do
				if value[it] then
					table.insert(list, it)
				end
			end
			return { t = "m", v = list }
		end
		return value
	end, function(v)
		if multi and type(v) == "table" then
			local set = {}
			for _, it in ipairs(v.v or {}) do
				set[it] = true
			end
			api:Set(set)
		elseif not multi then
			api:Set(v)
		end
	end)

	btn.MouseButton1Click:Connect(function()
		lib:_listPopup(btn, items, function(it)
			if multi then
				return value[it] == true
			end
			return value == it
		end, function(it)
			if multi then
				local nv = table.clone(value)
				nv[it] = (not nv[it]) or nil
				api:Set(nv)
			else
				api:Set(it)
			end
		end, multi)
	end)

	if o.Flag then
		lib.Flags[o.Flag] = value
	end
	return api
end

-- Keybind: { Name, Default = Enum.KeyCode, Flag, Callback(key), OnPress() }
function Group:Keybind(o)
	local lib = self.Lib
	local r = self:_row(o.Name)
	rowLabel(r, o.Name or "Keybind", 100)
	local btn = boxButton(r, 84, 24)
	local txt = label(btn, "", 12, Theme.Text, FONT, Enum.TextXAlignment.Center)
	txt.Size = UDim2.fromScale(1, 1)

	local key = o.Default
	local listening = false
	local api = {}
	local function show()
		txt.Text = listening and "..." or (key and key.Name or "None")
	end
	show()
	function api:Get()
		return key
	end
	register(lib, o.Flag, function()
		return { t = "k", n = key and key.Name or nil }
	end, function(v)
		key = v.n and Enum.KeyCode[v.n] or nil
		show()
		fire(lib, o.Flag, key, o.Callback)
	end)

	btn.MouseButton1Click:Connect(function()
		listening = true
		show()
	end)
	lib:_connect(UserInputService.InputBegan, function(input, gp)
		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				key = (input.KeyCode ~= Enum.KeyCode.Escape) and input.KeyCode or nil
				show()
				fire(lib, o.Flag, key, o.Callback)
			end
			return
		end
		if key and not gp and input.KeyCode == key and o.OnPress then
			task.spawn(o.OnPress)
		end
	end)
	if o.Flag then
		lib.Flags[o.Flag] = key
	end
	return api
end

-- ColorPicker: { Name, Default = Color3, Alpha = 0..1, Flag, Callback(color, alpha) }
function Group:ColorPicker(o)
	local lib = self.Lib
	local r = self:_row(o.Name)
	rowLabel(r, o.Name or "Color", 50)
	return makeColor(lib, r, o, -12)
end

return Library
