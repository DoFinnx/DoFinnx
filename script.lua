--[[
	NeverloseUI — меню в стиле Neverlose V4 для Roblox (Luau)
	Тип: ModuleScript (подключать из LocalScript через require)

	Компоненты: Tab / Section / Group, Toggle, Slider (int/float + ввод с клавиатуры),
	Combo (одиночный и мульти), ColorPicker (SV + Hue + Alpha + HEX), Keybind, Button, Label.
	Плюс: общий акцент-цвет, стартовая анимация, перетаскивание, масштаб (DPI),
	размытие фона (BlurEffect) и скрытие/показ по клавише.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Theme = {
	Window = Color3.fromRGB(10, 14, 19),
	Top = Color3.fromRGB(13, 18, 24),
	Sidebar = Color3.fromRGB(12, 16, 21),
	Group = Color3.fromRGB(17, 23, 30),
	Item = Color3.fromRGB(26, 34, 43),
	Popup = Color3.fromRGB(14, 19, 25),
	Stroke = Color3.fromRGB(33, 43, 54),
	Text = Color3.fromRGB(214, 222, 231),
	SubText = Color3.fromRGB(116, 130, 146),
}

local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local MOUSE1 = Enum.UserInputType.MouseButton1
local TOUCH = Enum.UserInputType.Touch
local MOVE = Enum.UserInputType.MouseMovement

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

-- перетаскивание по элементу: callback(Vector3 позиция курсора)
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

	self.Accent = opts.Accent or Color3.fromRGB(3, 169, 244)
	self.Flags = {}
	self.Scale = opts.Scale or 1
	self.ToggleKey = opts.ToggleKey or Enum.KeyCode.Insert
	self.Visible = false
	self._ready = false
	self._tabs = {}
	self._accentFns = {}
	self._conns = {}
	self._order = 0

	local title = opts.Title or "NEVERLOSE"
	local size = opts.Size or Vector2.new(780, 520)

	self.Gui = create("ScreenGui", {
		Name = "NeverloseUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	-- Root компенсирует UIScale, чтобы занимать ровно весь экран
	self.Root = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1 / self.Scale, 1 / self.Scale),
		Parent = self.Gui,
	})
	self.UIScale = create("UIScale", { Scale = self.Scale, Parent = self.Root })

	-- главное окно
	self.Main = create("CanvasGroup", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Visible = false,
		Parent = self.Root,
	})
	corner(self.Main, 10)
	stroke(self.Main, Theme.Stroke, 1)
	self.Pop = create("UIScale", { Scale = 0.94, Parent = self.Main })

	-- верхняя панель (за неё таскаем окно)
	local top = create("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = Theme.Top,
		BorderSizePixel = 0,
		Parent = self.Main,
	})
	create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = top,
	})
	local logo = label(top, title, 18, self.Accent, Enum.Font.GothamBlack)
	logo.Position = UDim2.fromOffset(18, 0)
	logo.Size = UDim2.new(0, 150, 1, 0)
	self:_onAccent(function(c)
		logo.TextColor3 = c
	end)
	local sub = label(top, opts.Subtitle or "", 12, Theme.SubText, FONT, Enum.TextXAlignment.Right)
	sub.Position = UDim2.new(0, 180, 0, 0)
	sub.Size = UDim2.new(1, -198, 1, 0)

	dragger_window = nil
	top.InputBegan:Connect(function(input)
		if not isPointer(input) then
			return
		end
		local startMouse = input.Position
		local startPos = self.Main.Position
		local move = UserInputService.InputChanged:Connect(function(i)
			if i.UserInputType == MOVE or i.UserInputType == TOUCH then
				local d = (i.Position - startMouse) / self.Scale
				self.Main.Position =
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

	-- сайдбар и страницы
	self.Sidebar = create("Frame", {
		Position = UDim2.fromOffset(0, 46),
		Size = UDim2.new(0, 176, 1, -46),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = self.Main,
	})
	create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = self.Sidebar,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Sidebar,
	})
	create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = self.Sidebar,
	})

	self.Pages = create("Frame", {
		Position = UDim2.fromOffset(176, 46),
		Size = UDim2.new(1, -176, 1, -46),
		BackgroundTransparency = 1,
		Parent = self.Main,
	})

	-- оверлей для выпадающих списков / колорпикера
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

	-- размытие фона (аналог GPU gaussian blur)
	if opts.Blur ~= false then
		self.BlurSize = opts.BlurSize or 12
		self.Blur = create("BlurEffect", { Size = 0, Name = "NeverloseBlur", Parent = Lighting })
	end

	-- клавиша показа/скрытия
	self:_connect(UserInputService.InputBegan, function(input, gp)
		if not gp and self._ready and input.KeyCode == self.ToggleKey then
			self:SetVisible(not self.Visible)
		end
	end)

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
				TextSize = 46,
				Font = Enum.Font.GothamBlack,
				TextColor3 = self.Accent,
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

function Library:_popup(anchor, width, height, build)
	self:_closePopup()
	local pos = (anchor.AbsolutePosition - self.Root.AbsolutePosition) / self.Scale
	local x, y = pos.X, pos.Y + anchor.AbsoluteSize.Y / self.Scale + 4
	local rootSize = self.Root.AbsoluteSize / self.Scale
	x = math.clamp(x, 4, math.max(4, rootSize.X - width - 4))
	if y + height > rootSize.Y - 4 then
		y = pos.Y - height - 4
	end

	local frame = create("Frame", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = Theme.Popup,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 2,
		Parent = self.Overlay,
	})
	corner(frame, 8)
	stroke(frame, Theme.Stroke, 1)
	-- мягкая тень из слоёв
	for i = 1, 3 do
		local sh = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, i * 6, 1, i * 6),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.5 + i * 0.15,
			BorderSizePixel = 0,
			ZIndex = 1,
			Parent = frame,
		})
		corner(sh, 8 + i * 3)
	end
	self._popupFrame = frame
	self.Overlay.Visible = true
	build(frame)
	return frame
end

---------------------------------------------------------------------
-- вкладки
---------------------------------------------------------------------
function Library:Section(name)
	local l = label(self.Sidebar, string.upper(name), 10, Theme.SubText, FONT_BOLD)
	l.Size = UDim2.new(1, 0, 0, 22)
	l.LayoutOrder = self:_next()
	return l
end

function Library:Tab(name, icon)
	local lib = self
	local tab = setmetatable({ Lib = lib, Name = name, _active = false }, Tab)

	local btn = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = Theme.Item,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = lib:_next(),
		Parent = lib.Sidebar,
	})
	corner(btn, 6)
	local bar = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(3, 16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = btn,
	})
	corner(bar, 2)

	local iconObj
	if icon and icon:sub(1, 6) == "rbxass" then
		iconObj = create("ImageLabel", {
			BackgroundTransparency = 1,
			Image = icon,
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.fromOffset(18, 18),
			Parent = btn,
		})
	else
		iconObj = label(btn, icon or "•", 15, Theme.SubText, FONT_BOLD, Enum.TextXAlignment.Center)
		iconObj.Position = UDim2.fromOffset(10, 0)
		iconObj.Size = UDim2.new(0, 22, 1, 0)
	end
	local text = label(btn, name, 13, Theme.SubText)
	text.Position = UDim2.fromOffset(40, 0)
	text.Size = UDim2.new(1, -44, 1, 0)

	function tab:_style(animate)
		local on = self._active
		local c = on and lib.Accent or Theme.SubText
		apply(btn, { BackgroundTransparency = on and 0.35 or 1 }, animate)
		apply(bar, { BackgroundTransparency = on and 0 or 1, BackgroundColor3 = lib.Accent }, animate)
		apply(text, { TextColor3 = on and Theme.Text or Theme.SubText }, animate)
		if iconObj:IsA("TextLabel") then
			apply(iconObj, { TextColor3 = c }, animate)
		else
			apply(iconObj, { ImageColor3 = c }, animate)
		end
	end
	lib:_onAccent(function()
		tab:_style(false)
	end)

	-- страница с двумя колонками
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
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = page,
	})
	local function column(pos)
		local col = create("Frame", {
			Position = pos,
			Size = UDim2.new(0.5, -6, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = page,
		})
		create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = col })
		return col
	end
	tab.Page = page
	tab._left = column(UDim2.new(0, 0, 0, 0))
	tab._right = column(UDim2.new(0.5, 6, 0, 0))

	btn.MouseButton1Click:Connect(function()
		lib:_select(tab)
	end)
	btn.MouseEnter:Connect(function()
		if not tab._active then
			tween(btn, 0.12, { BackgroundTransparency = 0.7 })
		end
	end)
	btn.MouseLeave:Connect(function()
		if not tab._active then
			tween(btn, 0.12, { BackgroundTransparency = 1 })
		end
	end)

	table.insert(lib._tabs, tab)
	if #lib._tabs == 1 then
		lib:_select(tab)
	end
	return tab
end

function Library:_select(tab)
	self:_closePopup()
	for _, t in ipairs(self._tabs) do
		t._active = (t == tab)
		t.Page.Visible = t._active
		t:_style()
	end
end

function Tab:Group(name, side)
	local lib = self.Lib
	local col = (side == "right") and self._right or self._left
	local g = setmetatable({ Lib = lib, _order = 0 }, Group)

	g.Frame = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Group,
		BorderSizePixel = 0,
		LayoutOrder = #col:GetChildren(),
		Parent = col,
	})
	corner(g.Frame, 8)
	stroke(g.Frame, Theme.Stroke, 1)
	create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = g.Frame,
	})
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = g.Frame })

	local title = label(g.Frame, name, 13, Theme.Text, FONT_BOLD)
	title.Size = UDim2.new(1, 0, 0, 18)
	title.LayoutOrder = 0
	return g
end

---------------------------------------------------------------------
-- компоненты
---------------------------------------------------------------------
function Group:_row(height)
	self._order += 1
	return create("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		LayoutOrder = self._order,
		Parent = self.Frame,
	})
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
	local r = self:_row(18)
	local l = label(r, text, 12, Theme.SubText)
	l.Size = UDim2.fromScale(1, 1)
	return l
end

function Group:Button(o)
	local r = self:_row(28)
	local b = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Item,
		Text = o.Name or "Button",
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = FONT,
		AutoButtonColor = false,
		Parent = r,
	})
	corner(b, 6)
	b.MouseEnter:Connect(function()
		tween(b, 0.12, { BackgroundColor3 = Theme.Stroke })
	end)
	b.MouseLeave:Connect(function()
		tween(b, 0.12, { BackgroundColor3 = Theme.Item })
	end)
	b.MouseButton1Click:Connect(function()
		if o.Callback then
			task.spawn(o.Callback)
		end
	end)
	return b
end

-- Toggle: { Name, Flag, Default, Callback }
function Group:Toggle(o)
	local lib = self.Lib
	local r = self:_row(26)
	local l = label(r, o.Name or "Toggle", 13)
	l.Size = UDim2.new(1, -50, 1, 0)

	local pill = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(34, 18),
		BackgroundColor3 = Theme.Item,
		Text = "",
		AutoButtonColor = false,
		Parent = r,
	})
	corner(pill, 9)
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Theme.SubText,
		BorderSizePixel = 0,
		Parent = pill,
	})
	corner(knob, 6)

	local api = {}
	local state = o.Default == true
	local function render(animate)
		apply(pill, { BackgroundColor3 = state and lib.Accent or Theme.Item }, animate)
		apply(knob, {
			Position = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = state and Color3.new(1, 1, 1) or Theme.SubText,
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

	pill.MouseButton1Click:Connect(function()
		api:Set(not state)
	end)
	if o.Flag then
		lib.Flags[o.Flag] = state
	end
	return api
end

-- Slider: { Name, Min, Max, Default, Step, Suffix, Flag, Callback }  (Step=1 → int, 0.1 → float)
function Group:Slider(o)
	local lib = self.Lib
	local min, max = o.Min or 0, o.Max or 100
	local step = o.Step or 1
	local dec = decimalsOf(step)
	local suffix = o.Suffix or ""

	local r = self:_row(40)
	local l = label(r, o.Name or "Slider", 13)
	l.Size = UDim2.new(1, -70, 0, 18)

	local box = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(64, 18),
		BackgroundTransparency = 1,
		TextColor3 = Theme.SubText,
		TextSize = 12,
		Font = FONT,
		TextXAlignment = Enum.TextXAlignment.Right,
		ClearTextOnFocus = false,
		Text = "",
		Parent = r,
	})

	local hit = create("Frame", {
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Parent = r,
	})
	local bar = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = Theme.Item,
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
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = bar,
	})
	corner(knob, 5)
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

-- Combo: { Name, Items = {..}, Default, Multi, Flag, Callback }
-- Single → строка, Multi → таблица { [item] = true }
function Group:Combo(o)
	local lib = self.Lib
	local items = o.Items or {}
	local multi = o.Multi == true

	local r = self:_row(26)
	local l = label(r, o.Name or "Combo", 13)
	l.Size = UDim2.new(1, -140, 1, 0)

	local btn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(130, 22),
		BackgroundColor3 = Theme.Item,
		Text = "",
		AutoButtonColor = false,
		Parent = r,
	})
	corner(btn, 5)
	local shown = label(btn, "", 12, Theme.Text)
	shown.Position = UDim2.fromOffset(8, 0)
	shown.Size = UDim2.new(1, -24, 1, 0)
	shown.TextTruncate = Enum.TextTruncate.AtEnd
	local arrow = label(btn, "▾", 12, Theme.SubText, FONT_BOLD, Enum.TextXAlignment.Center)
	arrow.AnchorPoint = Vector2.new(1, 0)
	arrow.Position = UDim2.fromScale(1, 0)
	arrow.Size = UDim2.new(0, 20, 1, 0)

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
					table.insert(t, it)
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

	btn.MouseButton1Click:Connect(function()
		local h = math.min(#items * 26 + 10, 182)
		lib:_popup(btn, btn.AbsoluteSize.X / lib.Scale, h, function(frame)
			local sc = create("ScrollingFrame", {
				Size = UDim2.new(1, -8, 1, -8),
				Position = UDim2.fromOffset(4, 4),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 2,
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ZIndex = 3,
				Parent = frame,
			})
			create("UIListLayout", { Padding = UDim.new(0, 2), Parent = sc })
			local buttons = {}
			local function paint()
				for it, b in pairs(buttons) do
					local sel = multi and value[it] or (not multi and value == it)
					b.TextColor3 = sel and lib.Accent or Theme.Text
					b.BackgroundTransparency = sel and 0.6 or 1
				end
			end
			for _, it in ipairs(items) do
				local b = create("TextButton", {
					Size = UDim2.new(1, -4, 0, 24),
					BackgroundColor3 = Theme.Item,
					BackgroundTransparency = 1,
					Text = "  " .. it,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 12,
					Font = FONT,
					AutoButtonColor = false,
					ZIndex = 3,
					Parent = sc,
				})
				corner(b, 5)
				buttons[it] = b
				b.MouseButton1Click:Connect(function()
					if multi then
						local nv = table.clone(value)
						nv[it] = (not nv[it]) or nil
						api:Set(nv)
						paint()
					else
						api:Set(it)
						lib:_closePopup()
					end
				end)
			end
			paint()
		end)
	end)

	if o.Flag then
		lib.Flags[o.Flag] = value
	end
	return api
end

-- Keybind: { Name, Default = Enum.KeyCode, Flag, Callback(key), OnPress() }
function Group:Keybind(o)
	local lib = self.Lib
	local r = self:_row(26)
	local l = label(r, o.Name or "Keybind", 13)
	l.Size = UDim2.new(1, -80, 1, 0)
	local btn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(72, 22),
		BackgroundColor3 = Theme.Item,
		TextColor3 = Theme.Text,
		TextSize = 12,
		Font = FONT,
		AutoButtonColor = false,
		Text = "",
		Parent = r,
	})
	corner(btn, 5)

	local key = o.Default
	local listening = false
	local api = {}
	local function show()
		btn.Text = listening and "..." or (key and key.Name or "None")
	end
	show()
	function api:Get()
		return key
	end

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
	local r = self:_row(26)
	local l = label(r, o.Name or "Color", 13)
	l.Size = UDim2.new(1, -50, 1, 0)

	local swatch = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(30, 16),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = r,
	})
	corner(swatch, 5)
	stroke(swatch, Theme.Stroke, 1)

	local h, s, v = Color3.toHSV(o.Default or Color3.new(1, 0, 0))
	local a = o.Alpha or 1
	local ui = {}
	local api = {}

	local function color()
		return Color3.fromHSV(h, s, v)
	end
	local function refresh(silent)
		local c = color()
		swatch.BackgroundColor3 = c
		swatch.BackgroundTransparency = 1 - a
		if ui.sv then
			ui.sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			ui.cursor.Position = UDim2.fromScale(s, 1 - v)
			ui.hueKnob.Position = UDim2.fromScale(h, 0.5)
			ui.alphaBar.BackgroundColor3 = c
			ui.alphaKnob.Position = UDim2.fromScale(a, 0.5)
			ui.hex.Text = "#" .. c:ToHex():upper() .. string.format("   α %d%%", math.floor(a * 100 + 0.5))
		end
		if lib.Flags and o.Flag then
			lib.Flags[o.Flag] = { Color = c, Alpha = a }
		end
		if not silent and o.Callback then
			task.spawn(o.Callback, c, a)
		end
	end
	function api:Get()
		return color(), a
	end
	function api:Set(c, alpha)
		h, s, v = Color3.toHSV(c)
		a = alpha or a
		refresh()
	end

	swatch.MouseButton1Click:Connect(function()
		lib:_popup(swatch, 200, 214, function(frame)
			local sv = create("Frame", {
				Position = UDim2.fromOffset(10, 10),
				Size = UDim2.fromOffset(180, 130),
				BackgroundColor3 = Color3.fromHSV(h, 1, 1),
				BorderSizePixel = 0,
				ZIndex = 3,
				Parent = frame,
			})
			corner(sv, 6)
			local white = create("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				ZIndex = 3,
				Parent = sv,
			})
			corner(white, 6)
			create("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
			local black = create("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				ZIndex = 4,
				Parent = sv,
			})
			corner(black, 6)
			create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
			local cursor = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(10, 10),
				BackgroundTransparency = 1,
				ZIndex = 5,
				Parent = sv,
			})
			corner(cursor, 5)
			stroke(cursor, Color3.new(1, 1, 1), 2)

			local hueBar = create("Frame", {
				Position = UDim2.fromOffset(10, 150),
				Size = UDim2.fromOffset(180, 10),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				ZIndex = 3,
				Parent = frame,
			})
			corner(hueBar, 5)
			create("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
					ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
					ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
					ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
					ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
					ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1)),
				}),
				Parent = hueBar,
			})
			local hueKnob = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(6, 14),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				ZIndex = 5,
				Parent = hueBar,
			})
			corner(hueKnob, 3)
			stroke(hueKnob, Color3.new(0, 0, 0), 1, 0.5)

			local alphaBack = create("Frame", {
				Position = UDim2.fromOffset(10, 168),
				Size = UDim2.fromOffset(180, 10),
				BackgroundColor3 = Color3.fromRGB(70, 78, 88),
				BorderSizePixel = 0,
				ZIndex = 3,
				Parent = frame,
			})
			corner(alphaBack, 5)
			local alphaBar = create("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = color(),
				BorderSizePixel = 0,
				ZIndex = 4,
				Parent = alphaBack,
			})
			corner(alphaBar, 5)
			create("UIGradient", { Transparency = NumberSequence.new(1, 0), Parent = alphaBar })
			local alphaKnob = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(6, 14),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				ZIndex = 5,
				Parent = alphaBack,
			})
			corner(alphaKnob, 3)
			stroke(alphaKnob, Color3.new(0, 0, 0), 1, 0.5)

			local hex = label(frame, "", 12, Theme.SubText, FONT, Enum.TextXAlignment.Center)
			hex.Position = UDim2.fromOffset(10, 186)
			hex.Size = UDim2.fromOffset(180, 20)
			hex.ZIndex = 3

			ui = {
				sv = sv,
				cursor = cursor,
				hueKnob = hueKnob,
				alphaBar = alphaBar,
				alphaKnob = alphaKnob,
				hex = hex,
			}

			dragger(sv, function(pos)
				s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
				v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
				refresh()
			end)
			dragger(hueBar, function(pos)
				h = math.clamp((pos.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 0.999)
				refresh()
			end)
			dragger(alphaBack, function(pos)
				a = math.clamp((pos.X - alphaBack.AbsolutePosition.X) / alphaBack.AbsoluteSize.X, 0, 1)
				refresh()
			end)
			refresh(true)
		end)
	end)

	refresh(true)
	return api
end

return Library
