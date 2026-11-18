--[[
	Nocturne UI — библиотека меню для Roblox (Luau).
	Стиль перенесён из макета «Neverlose menu.fig» в масштабе 1×.
	Только интерфейс: элементы вызывают переданные Callback, своих игровых функций нет.

	Работает и как ModuleScript (require), и через loadstring (файл возвращает таблицу библиотеки).
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

local Library = {
	Version = "1.4.0",
	Flags = {},
	Windows = {},
	Keybinds = {},
	-- Можно переопределить под конкретную игру: function() return { Player, ... } end
	GetSpectators = nil,
}

-- Токены из макета (дубли цветов сведены в один).
local Theme = {
	Window = Color3.fromRGB(16, 17, 22),
	Sidebar = Color3.fromRGB(20, 21, 27),
	Panel = Color3.fromRGB(29, 29, 34),
	Stroke = Color3.fromRGB(48, 48, 54),
	Divider = Color3.fromRGB(34, 35, 42),
	Accent = Color3.fromRGB(100, 133, 247),
	Thumb = Color3.fromRGB(245, 246, 255),
	TrackOff = Color3.fromRGB(51, 53, 61),
	ThumbOff = Color3.fromRGB(146, 148, 155),
	SliderTrack = Color3.fromRGB(40, 42, 53),
	Field = Color3.fromRGB(27, 28, 35),
	FieldHover = Color3.fromRGB(36, 37, 46),
	Chip = Color3.fromRGB(36, 36, 49),
	ChipStroke = Color3.fromRGB(81, 85, 117),
	NavActive = Color3.fromRGB(41, 41, 50),
	Text = Color3.fromRGB(184, 185, 195),
	TextStrong = Color3.fromRGB(212, 215, 227),
	Title = Color3.fromRGB(226, 227, 233),
	Muted = Color3.fromRGB(120, 122, 136), -- светлее, чем #5E606D в макете, ради контраста
	Icon = Color3.fromRGB(169, 171, 183),
	Danger = Color3.fromRGB(214, 112, 122),
	Logo = Color3.fromRGB(184, 233, 255),
}
Library.Theme = Theme

-- Шкала шрифта вместо 20 размеров из макета.
local FONT = Enum.Font.Gotham
local FONT_MEDIUM = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local TEXT_XS, TEXT_SM, TEXT_MD, TEXT_LG = 10, 12, 13, 14

local ROW_HEIGHT = 30
local PANEL_WIDTH = 250

----------------------------------------------------------------------
-- Утилиты
----------------------------------------------------------------------

local function create(className, props, children)
	local inst = Instance.new(className)
	local parent
	for key, value in pairs(props or {}) do
		if key == "Parent" then
			parent = value
		else
			inst[key] = value
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function merge(base, extra)
	for key, value in pairs(extra or {}) do
		base[key] = value
	end
	return base
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color, transparency, thickness)
	return create("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(left, top, right, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left),
		PaddingTop = UDim.new(0, top or left),
		PaddingRight = UDim.new(0, right or left),
		PaddingBottom = UDim.new(0, bottom or top or left),
	})
end

local function listLayout(gap, direction, vAlign)
	return create("UIListLayout", {
		Padding = UDim.new(0, gap or 0),
		FillDirection = direction or Enum.FillDirection.Vertical,
		VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

local function tween(object, duration, props)
	local t = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function label(props)
	return create("TextLabel", merge({
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = FONT,
		TextSize = TEXT_MD,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = "",
	}, props))
end

local function hitbox(props)
	return create("TextButton", merge({
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromScale(1, 1),
	}, props))
end

local function chevron(props)
	return label(merge({
		Text = "›",
		Font = FONT_MEDIUM,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromOffset(12, 12),
	}, props))
end

local function divider(props)
	return create("Frame", merge({
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
	}, props))
end

-- Иконка: "rbxassetid://..." или число -> картинка, иначе короткий текст-глиф.
local function icon(spec, size, color)
	size = size or 14
	if type(spec) == "number" or (type(spec) == "string" and (spec:find("rbxasset") or spec:match("^%d+$"))) then
		local image = tostring(spec)
		if image:match("^%d+$") then
			image = "rbxassetid://" .. image
		end
		return create("ImageLabel", {
			BackgroundTransparency = 1,
			Image = image,
			ImageColor3 = color or Theme.Icon,
			Size = UDim2.fromOffset(size, size),
		})
	end
	return label({
		Text = spec or "•",
		Font = FONT_BOLD,
		TextSize = size - 2,
		TextColor3 = color or Theme.Icon,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromOffset(size, size),
	})
end

local function safeCall(callback, ...)
	if type(callback) == "function" then
		task.spawn(callback, ...)
	end
end

local function setFlag(flag, value)
	if flag then
		Library.Flags[flag] = value
	end
end

local function pointIn(gui, point)
	local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
	return point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

local function isPointer(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function textWidth(text, size, font)
	return TextService:GetTextSize(text, size, font, Vector2.new(10000, 100)).X
end

local function getGuiParent()
	local ok, hidden = pcall(function()
		return gethui and gethui()
	end)
	if ok and hidden then
		return hidden
	end
	local canUseCore = pcall(function()
		local probe = Instance.new("Folder")
		probe.Parent = CoreGui
		probe:Destroy()
	end)
	if canUseCore then
		return CoreGui
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- Невидимая кнопка-подложка: не даёт кликам проходить сквозь панель.
local function sink(parent)
	return hitbox({ Name = "Sink", Parent = parent })
end

----------------------------------------------------------------------
-- Container: общие методы для секций вкладок и всплывающих панелей
----------------------------------------------------------------------

local Container = {}
Container.__index = Container

function Container:_nextOrder()
	self._order += 1
	return self._order
end

function Container:_track(connection)
	table.insert(self.window._connections, connection)
	return connection
end

-- Строка: подпись слева, справа контейнер для контролов (acc).
function Container:_row(name, height, labelOffset)
	labelOffset = labelOffset or 0
	local row = create("Frame", {
		Name = name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height or ROW_HEIGHT),
		LayoutOrder = self:_nextOrder(),
		Parent = self.holder,
	})
	local text = label({
		Text = name,
		Position = UDim2.fromOffset(labelOffset, 0),
		Size = UDim2.new(1, -labelOffset, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})
	local acc = create("Frame", {
		Name = "Controls",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 2,
		Parent = row,
	}, { listLayout(8, Enum.FillDirection.Horizontal, Enum.VerticalAlignment.Center) })

	local function fit()
		text.Size = UDim2.new(1, -(labelOffset + acc.AbsoluteSize.X + 10), 1, 0)
	end
	self:_track(acc:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit))
	fit()

	if self.tab then
		table.insert(self.tab.rows, { frame = row, name = string.lower(name) })
	end
	return row, text, acc
end

-- Добавки, которые можно повесить справа на любую строку.
function Container:_attachAddons(element, acc)
	local container = self
	local count = 0
	local function nextOrder()
		count += 1
		return count
	end
	function element:AddColorpicker(opts)
		return container:_colorpicker(acc, opts or {}, nextOrder())
	end
	function element:AddKeybind(opts)
		local target = element.Type == "Toggle" and element or nil
		return container:_keybind(acc, opts or {}, nextOrder(), target)
	end
	function element:AddSettings(title)
		return container:_settings(acc, title or element.Name, nextOrder())
	end
	return element
end

function Container:AddToggle(opts)
	opts = opts or {}
	local name = opts.Name or "Toggle"
	local row, text, acc = self:_row(name)
	local toggle = { Type = "Toggle", Name = name, Value = opts.Default == true }

	local track = create("Frame", {
		Size = UDim2.fromOffset(30, 17),
		BackgroundColor3 = Theme.TrackOff,
		LayoutOrder = 1000,
		Parent = acc,
	}, { corner(9) })
	local thumb = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(13, 13),
		BackgroundColor3 = Theme.ThumbOff,
		Parent = track,
	}, { corner(7) })

	local function render(duration)
		local on = toggle.Value
		tween(track, duration, { BackgroundColor3 = on and Theme.Accent or Theme.TrackOff })
		tween(thumb, duration, {
			Position = on and UDim2.new(0, 15, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			BackgroundColor3 = on and Theme.Thumb or Theme.ThumbOff,
		})
		tween(text, duration, { TextColor3 = on and Theme.TextStrong or Theme.Text })
	end

	function toggle:Set(value, silent)
		self.Value = value and true or false
		render(0.18)
		setFlag(opts.Flag, self.Value)
		if not silent then
			safeCall(opts.Callback, self.Value)
		end
	end

	function toggle:Get()
		return self.Value
	end

	hitbox({ Parent = row }).MouseButton1Click:Connect(function()
		toggle:Set(not toggle.Value)
	end)

	render(0)
	setFlag(opts.Flag, toggle.Value)
	return self:_attachAddons(toggle, acc)
end

function Container:AddCheckbox(opts)
	opts = opts or {}
	local name = opts.Name or "Checkbox"
	local row, text, _ = self:_row(name, 26, 24)
	local checkbox = { Type = "Checkbox", Name = name, Value = opts.Default == true }

	local box = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Theme.Field,
		Parent = row,
	}, { corner(4) })
	local boxStroke = stroke(Theme.ChipStroke, 0.3, 1)
	boxStroke.Parent = box
	local mark = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = Theme.Thumb,
		BackgroundTransparency = 1,
		Parent = box,
	}, { corner(2) })

	local function render(duration)
		local on = checkbox.Value
		tween(box, duration, { BackgroundColor3 = on and Theme.Accent or Theme.Field })
		tween(boxStroke, duration, { Color = on and Theme.Accent or Theme.ChipStroke })
		tween(mark, duration, { BackgroundTransparency = on and 0 or 1 })
		tween(text, duration, { TextColor3 = on and Theme.TextStrong or Theme.Text })
	end

	function checkbox:Set(value, silent)
		self.Value = value and true or false
		render(0.15)
		setFlag(opts.Flag, self.Value)
		if not silent then
			safeCall(opts.Callback, self.Value)
		end
	end

	function checkbox:Get()
		return self.Value
	end

	hitbox({ Parent = row }).MouseButton1Click:Connect(function()
		checkbox:Set(not checkbox.Value)
	end)

	render(0)
	setFlag(opts.Flag, checkbox.Value)
	return checkbox
end

function Container:AddSlider(opts)
	opts = opts or {}
	local name = opts.Name or "Slider"
	local min, max = opts.Min or 0, opts.Max or 100
	local decimals = opts.Decimals or 0
	local step = opts.Step or (1 / 10 ^ decimals)
	local suffix = opts.Suffix or ""
	local _, _, acc = self:_row(name)
	local slider = { Type = "Slider", Name = name, Value = min }

	local track = create("Frame", {
		Size = UDim2.fromOffset(opts.Width or 96, 4),
		BackgroundColor3 = Theme.SliderTrack,
		LayoutOrder = 1000,
		Parent = acc,
	}, { corner(2) })
	local hit = hitbox({
		Position = UDim2.new(0, -6, 0.5, -10),
		Size = UDim2.new(1, 12, 0, 20),
		Parent = track,
	})
	local fill = create("Frame", {
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 1),
		Parent = track,
	}, { corner(2) })
	local handle = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(11, 11),
		BackgroundColor3 = Theme.Thumb,
		Parent = track,
	}, { corner(6) })
	-- Значение справа: кнопка с числом, по клику на её месте появляется поле ввода.
	local valueHolder = create("Frame", {
		Name = "Value",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(opts.ValueWidth or 48, 20),
		LayoutOrder = 1001,
		Parent = acc,
	})
	local valueButton = create("TextButton", {
		Name = "Display",
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = FONT,
		TextSize = TEXT_SM,
		TextColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = valueHolder,
	}, { corner(4), padding(4, 0, 4, 0) })
	local valueBox = create("TextBox", {
		Name = "Input",
		Visible = false,
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		Font = FONT,
		TextSize = TEXT_SM,
		TextColor3 = Theme.TextStrong,
		TextXAlignment = Enum.TextXAlignment.Right,
		ClearTextOnFocus = false,
		TextEditable = true,
		Text = "",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = valueHolder,
	}, { corner(4), padding(4, 0, 4, 0), stroke(Theme.Accent, 0.4, 1) })

	local function formatValue(value)
		return string.format("%." .. decimals .. "f", value)
	end

	function slider:Set(value, silent)
		value = math.clamp(value, min, max)
		value = min + math.floor((value - min) / step + 0.5) * step
		value = math.clamp(value, min, max)
		local changed = value ~= self.Value
		self.Value = value
		local alpha = (max > min) and (value - min) / (max - min) or 0
		fill.Size = UDim2.fromScale(alpha, 1)
		handle.Position = UDim2.fromScale(alpha, 0.5)
		valueButton.Text = formatValue(value) .. suffix
		setFlag(opts.Flag, value)
		if changed and not silent then
			safeCall(opts.Callback, value)
		end
	end

	function slider:Get()
		return self.Value
	end

	valueButton.MouseEnter:Connect(function()
		tween(valueButton, 0.12, { TextColor3 = Theme.TextStrong, BackgroundTransparency = 0.4 })
	end)
	valueButton.MouseLeave:Connect(function()
		tween(valueButton, 0.12, { TextColor3 = Theme.Muted, BackgroundTransparency = 1 })
	end)

	local function startEditing()
		valueBox.Text = formatValue(slider.Value) -- только число, без суффикса
		valueButton.Visible = false
		valueBox.Visible = true
		valueBox:CaptureFocus()
		valueBox.CursorPosition = #valueBox.Text + 1
		valueBox.SelectionStart = 1
	end

	local function stopEditing(apply)
		if not valueBox.Visible then
			return
		end
		if apply then
			local cleaned = string.gsub(string.gsub(valueBox.Text, ",", "."), "[^%d%.%-]", "")
			local number = tonumber(cleaned)
			if number then
				slider:Set(number)
			end
		end
		valueBox.Visible = false
		valueButton.Visible = true
		valueButton.Text = formatValue(slider.Value) .. suffix
		valueButton.TextColor3 = Theme.Muted
		valueButton.BackgroundTransparency = 1
	end

	valueButton.MouseButton1Click:Connect(startEditing)
	valueBox.FocusLost:Connect(function()
		stopEditing(true)
	end)

	local dragging = false
	local function updateFromX(x)
		local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		slider:Set(min + (max - min) * alpha)
	end

	hit.InputBegan:Connect(function(input)
		if isPointer(input) then
			dragging = true
			tween(handle, 0.12, { Size = UDim2.fromOffset(13, 13) })
			updateFromX(input.Position.X)
		end
	end)
	self:_track(UserInputService.InputChanged:Connect(function(input)
		if dragging and isMove(input) then
			updateFromX(input.Position.X)
		end
	end))
	self:_track(UserInputService.InputEnded:Connect(function(input)
		if dragging and isPointer(input) then
			dragging = false
			tween(handle, 0.12, { Size = UDim2.fromOffset(11, 11) })
		end
	end))

	slider.Value = nil
	slider:Set(opts.Default or min, true)
	return slider
end

function Container:AddDropdown(opts)
	opts = opts or {}
	local name = opts.Name or "Dropdown"
	local multi = opts.Multi == true
	local window = self.window
	local _, _, acc = self:_row(name)
	local dropdown = { Type = "Dropdown", Name = name, Options = opts.Options or {} }

	local field = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(opts.Width or 140, 24),
		BackgroundColor3 = Theme.Field,
		LayoutOrder = 1000,
		Parent = acc,
	}, { corner(6) })
	local valueLabel = label({
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.new(1, -30, 1, 0),
		TextSize = TEXT_SM,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = field,
	})
	local arrow = chevron({
		Rotation = 90,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		TextColor3 = Theme.Muted,
		Parent = field,
	})

	field.MouseEnter:Connect(function()
		tween(field, 0.12, { BackgroundColor3 = Theme.FieldHover })
	end)
	field.MouseLeave:Connect(function()
		tween(field, 0.12, { BackgroundColor3 = Theme.Field })
	end)

	local list = create("Frame", {
		Name = "DropdownList",
		Visible = false,
		BackgroundColor3 = Theme.Field,
		Size = UDim2.fromOffset(160, 10),
		Parent = window.popupLayer,
	}, { corner(6), stroke(Theme.Stroke, 0.2, 1) })
	sink(list)
	local scroller = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.ChipStroke,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = list,
	}, { padding(4), listLayout(0) })

	local optionButtons = {}
	local listHeight = 10

	local function listWidth()
		return math.max(field.AbsoluteSize.X, 140)
	end

	local function isSelected(option)
		if multi then
			return dropdown.Value[option] == true
		end
		return dropdown.Value == option
	end

	local function selectedList()
		local result = {}
		for _, option in ipairs(dropdown.Options) do
			if dropdown.Value[option] then
				table.insert(result, option)
			end
		end
		return result
	end

	local function render()
		if multi then
			local selected = selectedList()
			valueLabel.Text = #selected > 0 and table.concat(selected, ", ") or "None"
		else
			valueLabel.Text = dropdown.Value ~= nil and tostring(dropdown.Value) or "None"
		end
		for option, buttonLabel in pairs(optionButtons) do
			buttonLabel.TextColor3 = isSelected(option) and Theme.Accent or Theme.Text
		end
	end

	local function fire()
		local value = multi and selectedList() or dropdown.Value
		setFlag(opts.Flag, value)
		safeCall(opts.Callback, value)
	end

	local function rebuild()
		for _, child in ipairs(scroller:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		optionButtons = {}
		for index, option in ipairs(dropdown.Options) do
			local optionButton = create("TextButton", {
				Text = "",
				AutoButtonColor = false,
				BackgroundColor3 = Theme.FieldHover,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 24),
				LayoutOrder = index,
				Parent = scroller,
			}, { corner(4) })
			optionButtons[option] = label({
				Text = tostring(option),
				TextSize = TEXT_SM,
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(1, -16, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = optionButton,
			})
			optionButton.MouseEnter:Connect(function()
				tween(optionButton, 0.1, { BackgroundTransparency = 0 })
			end)
			optionButton.MouseLeave:Connect(function()
				tween(optionButton, 0.1, { BackgroundTransparency = 1 })
			end)
			optionButton.MouseButton1Click:Connect(function()
				if multi then
					dropdown.Value[option] = not dropdown.Value[option] or nil
				else
					dropdown.Value = option
					window:_closePopup(list)
				end
				render()
				fire()
			end)
		end
		listHeight = math.min(#dropdown.Options * 24 + 8, opts.MaxHeight or 200)
		if not window:_isOpen(list) then
			list.Size = UDim2.fromOffset(listWidth(), listHeight)
		end
		render()
	end

	function dropdown:Set(value, silent)
		if multi then
			self.Value = {}
			for _, option in ipairs(type(value) == "table" and value or { value }) do
				self.Value[option] = true
			end
		else
			self.Value = value
		end
		render()
		if silent then
			setFlag(opts.Flag, multi and selectedList() or self.Value)
		else
			fire()
		end
	end

	function dropdown:Get()
		return multi and selectedList() or self.Value
	end

	function dropdown:Refresh(options, keepValue)
		self.Options = options or {}
		if not keepValue then
			self.Value = multi and {} or self.Options[1]
		end
		rebuild()
	end

	field.MouseButton1Click:Connect(function()
		if window:_isOpen(list) then
			window:_closePopup(list)
			return
		end
		list.Size = UDim2.fromOffset(listWidth(), listHeight)
		tween(arrow, 0.15, { Rotation = 270 })
		window:_openPopup(list, field, "below", function()
			tween(arrow, 0.15, { Rotation = 90 })
		end, true)
		-- пункты появляются по очереди
		for _, child in ipairs(scroller:GetChildren()) do
			if child:IsA("TextButton") then
				local optionLabel = child:FindFirstChildOfClass("TextLabel")
				if optionLabel then
					optionLabel.TextTransparency = 1
					optionLabel.Position = UDim2.fromOffset(14, 0)
					task.delay(0.02 * (child.LayoutOrder - 1), function()
						tween(optionLabel, 0.18, { TextTransparency = 0, Position = UDim2.fromOffset(8, 0) })
					end)
				end
			end
		end
	end)

	if multi then
		dropdown.Value = {}
		for _, option in ipairs(opts.Default or {}) do
			dropdown.Value[option] = true
		end
	else
		dropdown.Value = opts.Default
		if dropdown.Value == nil then
			dropdown.Value = dropdown.Options[1]
		end
	end
	rebuild()
	setFlag(opts.Flag, dropdown:Get())
	return dropdown
end

-- Группа чипов с множественным выбором (ESP Items, Bomb, Hostages в макете).
function Container:AddChips(opts)
	opts = opts or {}
	local chips = { Type = "Chips", Name = opts.Name, Options = opts.Options or {}, Value = {} }

	if opts.Name then
		local header = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			LayoutOrder = self:_nextOrder(),
			Parent = self.holder,
		})
		label({ Text = opts.Name, TextSize = TEXT_SM, TextColor3 = Theme.TextStrong, Font = FONT_MEDIUM, Size = UDim2.fromScale(1, 1), Parent = header })
	end

	local box = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		LayoutOrder = self:_nextOrder(),
		Parent = self.holder,
	})
	local spacer = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 6),
		LayoutOrder = self:_nextOrder(),
		Parent = self.holder,
	})
	if self.tab then
		local searchName = string.lower((opts.Name or "") .. " " .. table.concat(chips.Options, " "))
		table.insert(self.tab.rows, { frame = box, name = searchName, extra = spacer })
	end

	local views = {}

	local function layoutChips()
		local width = box.AbsoluteSize.X
		local x, y = 0, 0
		for _, view in ipairs(views) do
			local w = view.button.Size.X.Offset
			if x > 0 and x + w > width then
				x = 0
				y += 30
			end
			view.button.Position = UDim2.fromOffset(x, y)
			x += w + 6
		end
		local height = y + 24
		if box.Size.Y.Offset ~= height then
			box.Size = UDim2.new(1, 0, 0, height)
		end
	end

	local function render(duration)
		for _, view in ipairs(views) do
			local on = chips.Value[view.option] == true
			tween(view.button, duration, {
				BackgroundColor3 = on and Theme.Accent or Theme.Chip,
				BackgroundTransparency = on and 0.78 or 0,
			})
			tween(view.stroke, duration, { Color = on and Theme.Accent or Theme.ChipStroke, Transparency = on and 0.2 or 0.45 })
			tween(view.text, duration, { TextColor3 = on and Theme.TextStrong or Theme.Text })
		end
	end

	local function selectedList()
		local result = {}
		for _, option in ipairs(chips.Options) do
			if chips.Value[option] then
				table.insert(result, option)
			end
		end
		return result
	end

	for _, option in ipairs(chips.Options) do
		local text = tostring(option)
		local chipButton = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.fromOffset(textWidth(text, TEXT_SM, FONT) + 20, 24),
			BackgroundColor3 = Theme.Chip,
			Parent = box,
		}, { corner(5) })
		local chipStroke = stroke(Theme.ChipStroke, 0.45, 1)
		chipStroke.Parent = chipButton
		local chipText = label({
			Text = text,
			TextSize = TEXT_SM,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
			Parent = chipButton,
		})
		table.insert(views, { option = option, button = chipButton, stroke = chipStroke, text = chipText })
		chipButton.MouseButton1Click:Connect(function()
			chips.Value[option] = not chips.Value[option] or nil
			render(0.15)
			local value = selectedList()
			setFlag(opts.Flag, value)
			safeCall(opts.Callback, value)
		end)
	end

	function chips:Set(list, silent)
		self.Value = {}
		for _, option in ipairs(list or {}) do
			self.Value[option] = true
		end
		render(0.15)
		local value = selectedList()
		setFlag(opts.Flag, value)
		if not silent then
			safeCall(opts.Callback, value)
		end
	end

	function chips:Get()
		return selectedList()
	end

	self:_track(box:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutChips))
	layoutChips()
	chips:Set(opts.Default or {}, true)
	return chips
end

function Container:AddButton(opts)
	opts = opts or {}
	local name = opts.Name or "Button"
	local row = create("Frame", {
		Name = name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		LayoutOrder = self:_nextOrder(),
		Parent = self.holder,
	})
	local buttonFrame = create("TextButton", {
		Text = name,
		Font = FONT_MEDIUM,
		TextSize = TEXT_SM,
		TextColor3 = opts.Danger and Theme.Danger or Theme.TextStrong,
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = Theme.Field,
		Parent = row,
	}, { corner(6), stroke(Theme.Stroke, 0.3, 1) })

	buttonFrame.MouseEnter:Connect(function()
		tween(buttonFrame, 0.12, { BackgroundColor3 = Theme.FieldHover })
	end)
	buttonFrame.MouseLeave:Connect(function()
		tween(buttonFrame, 0.12, { BackgroundColor3 = Theme.Field })
	end)
	buttonFrame.MouseButton1Click:Connect(function()
		tween(buttonFrame, 0.08, { BackgroundColor3 = Theme.NavActive })
		task.delay(0.1, function()
			tween(buttonFrame, 0.15, { BackgroundColor3 = Theme.Field })
		end)
		safeCall(opts.Callback)
	end)

	if self.tab then
		table.insert(self.tab.rows, { frame = row, name = string.lower(name) })
	end

	local buttonObject = { Type = "Button", Name = name }
	function buttonObject:SetText(text)
		buttonFrame.Text = text
	end
	return buttonObject
end

-- Строка со стрелкой «›», открывает всплывающую панель (Pitch, Yaw, Freestanding…).
function Container:AddSubmenu(opts)
	opts = opts or {}
	local name = opts.Name or "Submenu"
	local window = self.window
	local row, _, acc = self:_row(name)
	local panel = window:_panel(opts.Title or name)

	local valueText
	if opts.Value then
		valueText = label({
			Text = opts.Value,
			TextSize = TEXT_SM,
			TextColor3 = Theme.Muted,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 16),
			LayoutOrder = 999,
			Parent = acc,
		})
	end
	local arrow = chevron({ TextColor3 = Theme.Text, LayoutOrder = 1000, Parent = acc })

	hitbox({ Parent = row }).MouseButton1Click:Connect(function()
		if window:_isOpen(panel.frame) then
			window:_closePopup(panel.frame)
			return
		end
		tween(arrow, 0.15, { TextColor3 = Theme.Accent, Rotation = 90 })
		panel.frame.Size = panel.fullSize
		window:_openPopup(panel.frame, row, "attach", function()
			tween(arrow, 0.15, { TextColor3 = Theme.Text, Rotation = 0 })
		end, true)
	end)

	function panel:SetValue(text)
		if valueText then
			valueText.Text = text
		end
	end
	return panel
end

function Container:AddLabel(text, opts)
	opts = opts or {}
	local row, textLabel, acc = self:_row(text, opts.Height)
	if opts.Color then
		textLabel.TextColor3 = opts.Color
	end
	local labelObject = { Type = "Label", Name = text }
	function labelObject:Set(newText)
		textLabel.Text = newText
		self.Name = newText
	end
	labelObject.Instance = row
	return self:_attachAddons(labelObject, acc)
end

function Container:AddParagraph(opts)
	opts = opts or {}
	local frame = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self:_nextOrder(),
		Parent = self.holder,
	}, { padding(0, 4, 0, 6), listLayout(3) })
	if opts.Title then
		label({ Text = opts.Title, Font = FONT_MEDIUM, TextColor3 = Theme.TextStrong, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1, Parent = frame })
	end
	local body = label({
		Text = opts.Text or "",
		TextSize = TEXT_SM,
		TextColor3 = Theme.Muted,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = frame,
	})
	local paragraph = { Type = "Paragraph" }
	function paragraph:Set(text)
		body.Text = text
	end
	return paragraph
end

function Container:AddDivider()
	local holder = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 13),
		LayoutOrder = self:_nextOrder(),
		Parent = self.holder,
	})
	divider({ AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Parent = holder })
end

function Container:AddKeybind(opts)
	opts = opts or {}
	local _, _, acc = self:_row(opts.Name or "Keybind")
	return self:_keybind(acc, opts, 1000)
end

function Container:AddColorpicker(opts)
	opts = opts or {}
	local _, _, acc = self:_row(opts.Name or "Color")
	return self:_colorpicker(acc, opts, 1000)
end

-- Кнопка «···» с всплывающей панелью настроек.
function Container:_settings(acc, title, order)
	local window = self.window
	local panel = window:_panel(title)
	local dots = create("TextButton", {
		Text = "···",
		Font = FONT_BOLD,
		TextSize = 14,
		TextColor3 = Theme.Muted,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(18, 18),
		LayoutOrder = order,
		Parent = acc,
	})
	dots.MouseEnter:Connect(function()
		tween(dots, 0.12, { TextColor3 = Theme.TextStrong })
	end)
	dots.MouseLeave:Connect(function()
		if not window:_isOpen(panel.frame) then
			tween(dots, 0.12, { TextColor3 = Theme.Muted })
		end
	end)
	dots.MouseButton1Click:Connect(function()
		if window:_isOpen(panel.frame) then
			window:_closePopup(panel.frame)
			return
		end
		dots.TextColor3 = Theme.Accent
		panel.frame.Size = panel.fullSize
		window:_openPopup(panel.frame, dots, "attach", function()
			tween(dots, 0.12, { TextColor3 = Theme.Muted })
		end, true)
	end)
	return panel
end

-- target: переключатель, к которому привязана клавиша (для toggle:AddKeybind).
-- Режимы: "Toggle" — нажатие переключает, "Hold" — включено, пока клавиша зажата.
-- ПКМ по полю клавиши меняет режим.
function Container:_keybind(acc, opts, order, target)
	local keybind = {
		Type = "Keybind",
		Name = opts.Name or (target and target.Name) or "Keybind",
		Value = opts.Default,
		Mode = opts.Mode or "Toggle",
		Target = target,
		Window = self.window,
		Listening = false,
	}
	table.insert(Library.Keybinds, keybind)
	local field = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Field,
		Size = UDim2.fromOffset(0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = order,
		Parent = acc,
	}, { corner(5), padding(8, 0, 8, 0) })
	local keyLabel = label({
		TextSize = TEXT_XS,
		Font = FONT_MEDIUM,
		TextColor3 = Theme.Muted,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		Parent = field,
	})

	local function render()
		if keybind.Listening then
			keyLabel.Text = "..."
			keyLabel.TextColor3 = Theme.Accent
		else
			local text = keybind.Value and keybind.Value.Name or "None"
			if target and keybind.Value and keybind.Mode == "Hold" then
				text = text .. " · hold"
			end
			keyLabel.Text = text
			keyLabel.TextColor3 = Theme.Muted
		end
	end

	function keybind:SetMode(mode)
		self.Mode = mode == "Hold" and "Hold" or "Toggle"
		render()
	end

	function keybind:IsActive()
		return self.Target ~= nil and self.Target.Value == true
	end

	function keybind:Set(key, silent)
		self.Value = key
		self.Listening = false
		Library._listening = false
		render()
		setFlag(opts.Flag, key)
		if not silent then
			safeCall(opts.Changed, key)
		end
	end

	function keybind:Get()
		return self.Value
	end

	field.MouseButton1Click:Connect(function()
		keybind.Listening = true
		Library._listening = true
		render()
	end)
	if target then
		field.MouseButton2Click:Connect(function()
			keybind:SetMode(keybind.Mode == "Toggle" and "Hold" or "Toggle")
		end)
	end

	self:_track(UserInputService.InputBegan:Connect(function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if keybind.Listening then
			if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
				keybind:Set(nil)
			else
				keybind:Set(input.KeyCode)
			end
			return
		end
		if not processed and keybind.Value and input.KeyCode == keybind.Value then
			if target then
				if keybind.Mode == "Hold" then
					target:Set(true)
				else
					target:Set(not target.Value)
				end
			end
			safeCall(opts.Callback, keybind.Value)
		end
	end))
	self:_track(UserInputService.InputEnded:Connect(function(input)
		if target and keybind.Mode == "Hold" and keybind.Value and input.KeyCode == keybind.Value then
			target:Set(false)
		end
	end))

	render()
	setFlag(opts.Flag, keybind.Value)
	return keybind
end

function Container:_colorpicker(acc, opts, order)
	local window = self.window
	local colorpicker = { Type = "Colorpicker", Value = opts.Default or Theme.Accent }
	local hue, sat, val = colorpicker.Value:ToHSV()

	local swatch = create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = colorpicker.Value,
		LayoutOrder = order,
		Parent = acc,
	}, { corner(4), stroke(Color3.new(1, 1, 1), 0.85, 1) })

	local popup = create("Frame", {
		Name = "Colorpicker",
		Visible = false,
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.fromOffset(200, 202),
		Parent = window.popupLayer,
	}, { corner(10), stroke(Theme.Stroke, 0.3, 1) })
	sink(popup)

	local svBox = create("Frame", {
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.fromOffset(176, 120),
		BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
		Parent = popup,
	}, { corner(6) })
	create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = svBox,
	}, { corner(6), create("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
	create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		Parent = svBox,
	}, { corner(6), create("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90 }) })
	local svCursor = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = svBox,
	}, { corner(5), stroke(Color3.new(1, 1, 1), 0, 1.5) })
	local svHit = hitbox({ ZIndex = 4, Parent = svBox })

	local hueKeypoints = {}
	for i = 0, 6 do
		table.insert(hueKeypoints, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, 1, 1)))
	end
	local hueBar = create("Frame", {
		Position = UDim2.fromOffset(12, 142),
		Size = UDim2.fromOffset(176, 10),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = popup,
	}, { corner(5), create("UIGradient", { Color = ColorSequence.new(hueKeypoints) }) })
	local hueCursor = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(4, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 3,
		Parent = hueBar,
	}, { corner(2) })
	local hueHit = hitbox({ Position = UDim2.fromOffset(0, -4), Size = UDim2.new(1, 0, 1, 8), ZIndex = 4, Parent = hueBar })

	local hexBox = create("TextBox", {
		Position = UDim2.fromOffset(12, 164),
		Size = UDim2.fromOffset(176, 26),
		BackgroundColor3 = Theme.Field,
		Font = FONT_MEDIUM,
		TextSize = TEXT_SM,
		TextColor3 = Theme.TextStrong,
		ClearTextOnFocus = false,
		Text = "",
		Parent = popup,
	}, { corner(6) })

	local function render(silent)
		colorpicker.Value = Color3.fromHSV(hue, sat, val)
		swatch.BackgroundColor3 = colorpicker.Value
		svBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		svCursor.Position = UDim2.fromScale(sat, 1 - val)
		hueCursor.Position = UDim2.fromScale(hue, 0.5)
		hexBox.Text = "#" .. string.upper(colorpicker.Value:ToHex())
		setFlag(opts.Flag, colorpicker.Value)
		if not silent then
			safeCall(opts.Callback, colorpicker.Value)
		end
	end

	function colorpicker:Set(color, silent)
		hue, sat, val = color:ToHSV()
		render(silent)
	end

	function colorpicker:Get()
		return self.Value
	end

	local dragTarget
	local function update(input)
		if dragTarget == "sv" then
			local pos, size = svBox.AbsolutePosition, svBox.AbsoluteSize
			sat = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
			val = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
			render()
		elseif dragTarget == "hue" then
			local pos, size = hueBar.AbsolutePosition, hueBar.AbsoluteSize
			hue = math.clamp((input.Position.X - pos.X) / size.X, 0, 0.999)
			render()
		end
	end

	svHit.InputBegan:Connect(function(input)
		if isPointer(input) then
			dragTarget = "sv"
			update(input)
		end
	end)
	hueHit.InputBegan:Connect(function(input)
		if isPointer(input) then
			dragTarget = "hue"
			update(input)
		end
	end)
	self:_track(UserInputService.InputChanged:Connect(function(input)
		if dragTarget and isMove(input) then
			update(input)
		end
	end))
	self:_track(UserInputService.InputEnded:Connect(function(input)
		if isPointer(input) then
			dragTarget = nil
		end
	end))

	hexBox.FocusLost:Connect(function()
		local ok, color = pcall(Color3.fromHex, (hexBox.Text:gsub("#", "")))
		if ok and color then
			colorpicker:Set(color)
		else
			render(true)
		end
	end)

	swatch.MouseButton1Click:Connect(function()
		if window:_isOpen(popup) then
			window:_closePopup(popup)
		else
			popup.Size = UDim2.fromOffset(200, 202)
			window:_openPopup(popup, swatch, "below", nil, true)
		end
	end)

	render(true)
	return colorpicker
end

----------------------------------------------------------------------
-- Tab
----------------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Tab:AddSection(opts)
	if type(opts) == "string" then
		opts = { Name = opts }
	end
	opts = opts or {}
	local side = opts.Side
	if side ~= "Left" and side ~= "Right" then
		side = (#self.sections % 2 == 0) and "Left" or "Right"
	end
	local column = side == "Left" and self.left or self.right
	local columnCount = column:GetAttribute("Sections") or 0
	column:SetAttribute("Sections", columnCount + 1)

	local frame = create("Frame", {
		Name = opts.Name or "Section",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = columnCount + 1,
		Parent = column,
	}, { listLayout(0) })

	if columnCount > 0 then
		local gap = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 17), LayoutOrder = 0, Parent = frame })
		divider({ Position = UDim2.fromOffset(0, 8), Parent = gap })
	end
	if opts.Name then
		label({
			Text = string.upper(opts.Name),
			Font = FONT_MEDIUM,
			TextSize = TEXT_XS,
			TextColor3 = Theme.Muted,
			Size = UDim2.new(1, 0, 0, 24),
			LayoutOrder = 1,
			Parent = frame,
		})
	end
	local holder = create("Frame", {
		Name = "Items",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Parent = frame,
	}, { listLayout(0) })

	local section = setmetatable({ window = self.window, tab = self, holder = holder, frame = frame, _order = 0 }, Container)
	table.insert(self.sections, section)
	return section
end

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------

local Window = {}
Window.__index = Window

function Window:_track(connection)
	table.insert(self._connections, connection)
	return connection
end

-- Всплывающая панель в стиле боковых панелей макета.
function Window:_panel(title)
	local frame = create("Frame", {
		Name = title,
		Visible = false,
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.fromOffset(PANEL_WIDTH, 60),
		Parent = self.popupLayer,
	}, { corner(10), stroke(Theme.Stroke, 0.3, 1) })
	sink(frame)
	label({
		Text = title,
		Font = FONT_BOLD,
		TextSize = TEXT_MD,
		TextColor3 = Theme.Title,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -28, 0, 38),
		Parent = frame,
	})
	local holder = create("Frame", {
		Name = "Items",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 36),
		Size = UDim2.new(1, -28, 0, 0),
		Parent = frame,
	})
	local layout = listLayout(0)
	layout.Parent = holder

	local panel = setmetatable({ window = self, holder = holder, frame = frame, _order = 0 }, Container)

	-- fullSize хранится отдельно: после анимации закрытия frame.Size по высоте равен 0.
	local function resize()
		local height = layout.AbsoluteContentSize.Y
		holder.Size = UDim2.new(1, -28, 0, height)
		panel.fullSize = UDim2.fromOffset(PANEL_WIDTH, 36 + height + 10)
		frame.Size = panel.fullSize
	end
	self:_track(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize))
	resize()

	return panel
end

function Window:_isOpen(frame)
	for _, popup in ipairs(self._popups) do
		if popup.frame == frame then
			return true
		end
	end
	return false
end

-- Закрывает frame и всё, что открыто поверх него.
function Window:_closePopup(frame)
	if not self:_isOpen(frame) then
		return
	end
	for i = #self._popups, 1, -1 do
		local popup = self._popups[i]
		table.remove(self._popups, i)
		self:_hidePopup(popup)
		if popup.onClose then
			popup.onClose()
		end
		if popup.frame == frame then
			break
		end
	end
end

function Window:_closeAll()
	while #self._popups > 0 do
		self:_closePopup(self._popups[1].frame)
	end
end

-- Считает позицию в абсолютных координатах и переводит её в offset слоя popupLayer.
-- Возвращает true, если панель пришлось открыть вверх.
function Window:_place(frame, anchor, mode, frameSize)
	local layerPos, layerSize = self.popupLayer.AbsolutePosition, self.popupLayer.AbsoluteSize
	frameSize = frameSize or frame.AbsoluteSize
	local anchorPos, anchorSize = anchor.AbsolutePosition, anchor.AbsoluteSize
	local minX, minY = layerPos.X + 8, layerPos.Y + 8
	local maxX, maxY = layerPos.X + layerSize.X - 8, layerPos.Y + layerSize.Y - 8
	local x, y
	local flipped = false

	if mode == "side" then
		local host = self.main
		for _, popup in ipairs(self._popups) do
			if popup.frame ~= frame and anchor:IsDescendantOf(popup.frame) then
				host = popup.frame
			end
		end
		x = host.AbsolutePosition.X + host.AbsoluteSize.X + 10
		if x + frameSize.X > maxX then
			x = host.AbsolutePosition.X - frameSize.X - 10
		end
		y = anchorPos.Y - 12
	elseif mode == "attach" then
		-- под строкой, к которой относится anchor (строка лежит прямо в контейнере "Items")
		local row = anchor
		while row.Parent and row.Parent.Name ~= "Items" do
			row = row.Parent
		end
		if not row.Parent then
			row = anchor
		end
		local rowPos, rowSize = row.AbsolutePosition, row.AbsoluteSize
		x = rowPos.X + rowSize.X - frameSize.X
		y = rowPos.Y + rowSize.Y + 4
		if y + frameSize.Y > maxY then
			y = rowPos.Y - frameSize.Y - 4
			flipped = true
		end
	else
		x = anchorPos.X + anchorSize.X - frameSize.X
		y = anchorPos.Y + anchorSize.Y + 6
		if y + frameSize.Y > maxY then
			y = anchorPos.Y - frameSize.Y - 6
			flipped = true
		end
	end

	x = math.clamp(x, minX, math.max(minX, maxX - frameSize.X))
	y = math.clamp(y, minY, math.max(minY, maxY - frameSize.Y))
	frame.Position = UDim2.fromOffset(x - layerPos.X, y - layerPos.Y)
	return flipped
end

local POPUP_ANIM_IN, POPUP_ANIM_OUT = 0.2, 0.14

-- animate = true: панель раскрывается по высоте (вниз или вверх) с фейдом обводки.
function Window:_openPopup(frame, anchor, mode, onClose, animate)
	local entry = { frame = frame, anchor = anchor, onClose = onClose, animate = animate }
	table.insert(self._popups, entry)
	frame.Parent = nil
	frame.Parent = self.popupLayer -- поверх остальных всплывающих окон
	frame:SetAttribute("PopupToken", (frame:GetAttribute("PopupToken") or 0) + 1)
	frame.Visible = true

	if animate then
		-- перед открытием вызывающий код выставляет frame.Size в полный размер
		local target = Vector2.new(frame.Size.X.Offset, frame.Size.Y.Offset)
		frame:SetAttribute("TargetSize", target)
		frame.ClipsDescendants = true
		local flipped = self:_place(frame, anchor, mode, target)
		local finalPosition = frame.Position
		entry.flipped = flipped
		entry.finalPosition = finalPosition
		frame.Size = UDim2.fromOffset(target.X, 0)
		frame.Position = flipped and finalPosition + UDim2.fromOffset(0, target.Y) or finalPosition
		local frameStroke = frame:FindFirstChildOfClass("UIStroke")
		if frameStroke then
			frameStroke.Transparency = 1
			tween(frameStroke, POPUP_ANIM_IN, { Transparency = 0.2 })
		end
		tween(frame, POPUP_ANIM_IN, { Size = UDim2.fromOffset(target.X, target.Y), Position = finalPosition })
		return
	end

	self:_place(frame, anchor, mode)
	task.defer(function()
		if self:_isOpen(frame) then
			self:_place(frame, anchor, mode)
		end
	end)
end

function Window:_hidePopup(entry)
	local frame = entry.frame
	if not entry.animate then
		frame.Visible = false
		return
	end
	local token = frame:GetAttribute("PopupToken")
	local target = frame:GetAttribute("TargetSize") or Vector2.new(frame.Size.X.Offset, frame.Size.Y.Offset)
	local closedPosition = entry.flipped and entry.finalPosition + UDim2.fromOffset(0, target.Y) or entry.finalPosition
	local frameStroke = frame:FindFirstChildOfClass("UIStroke")
	if frameStroke then
		tween(frameStroke, POPUP_ANIM_OUT, { Transparency = 1 })
	end
	tween(frame, POPUP_ANIM_OUT, { Size = UDim2.fromOffset(target.X, 0), Position = closedPosition })
	task.delay(POPUP_ANIM_OUT, function()
		-- если за это время панель открыли снова, не прячем её
		if frame:GetAttribute("PopupToken") == token and not self:_isOpen(frame) then
			frame.Visible = false
		end
	end)
end

function Window:AddCategory(name)
	self._navOrder += 1
	label({
		Text = string.upper(name),
		Font = FONT_MEDIUM,
		TextSize = TEXT_XS,
		TextColor3 = Theme.Muted,
		Size = UDim2.new(1, 0, 0, self._navOrder == 1 and 24 or 34),
		TextYAlignment = Enum.TextYAlignment.Bottom,
		LayoutOrder = self._navOrder,
		Parent = self.nav,
	})
end

function Window:AddTab(opts)
	if type(opts) == "string" then
		opts = { Name = opts }
	end
	opts = opts or {}
	local name = opts.Name or "Tab"
	self._navOrder += 1

	local tab = setmetatable({ window = self, Name = name, Icon = opts.Icon, rows = {}, sections = {} }, Tab)

	local navButton = create("TextButton", {
		Name = name,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.NavActive,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
		LayoutOrder = self._navOrder,
		Parent = self.nav,
	}, { corner(8) })
	local navIcon = icon(opts.Icon or string.sub(name, 1, 1), 14)
	navIcon.AnchorPoint = Vector2.new(0, 0.5)
	navIcon.Position = UDim2.new(0, 10, 0.5, 0)
	navIcon.Parent = navButton
	local navText = label({
		Text = name,
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Parent = navButton,
	})
	tab._nav = { button = navButton, icon = navIcon, text = navText }

	navButton.MouseEnter:Connect(function()
		if self.CurrentTab ~= tab then
			tween(navButton, 0.12, { BackgroundTransparency = 0.6 })
		end
	end)
	navButton.MouseLeave:Connect(function()
		if self.CurrentTab ~= tab then
			tween(navButton, 0.12, { BackgroundTransparency = 1 })
		end
	end)
	navButton.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	local page = create("ScrollingFrame", {
		Name = name,
		Visible = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Stroke,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = self.content,
	})
	tab.left = create("Frame", {
		Name = "Left",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = page,
	}, { padding(18, 12, 18, 18), listLayout(0) })
	tab.right = create("Frame", {
		Name = "Right",
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.new(0.5, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = page,
	}, { padding(18, 12, 18, 18), listLayout(0) })
	-- Вертикальный разделитель колонок (в макете он был сломан: 0.5×0.5).
	tab._divider = divider({
		Visible = false,
		Position = UDim2.new(0.5, 0, 0, 16),
		Size = UDim2.new(0, 1, 1, -32),
		Parent = self.content,
	})
	tab.page = page
	-- привязанные панели не должны «висеть в воздухе» при прокрутке страницы
	self:_track(page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if #self._popups > 0 then
			self:_closeAll()
		end
	end))

	table.insert(self.Tabs, tab)
	if not self.CurrentTab then
		self:SelectTab(tab)
	end
	return tab
end

function Window:SelectTab(tab)
	self:_closeAll()
	for _, other in ipairs(self.Tabs) do
		local active = other == tab
		other.page.Visible = active
		other._divider.Visible = active
		tween(other._nav.button, 0.15, { BackgroundTransparency = active and 0 or 1 })
		tween(other._nav.text, 0.15, { TextColor3 = active and Theme.TextStrong or Theme.Text })
		if other._nav.icon:IsA("ImageLabel") then
			tween(other._nav.icon, 0.15, { ImageColor3 = active and Theme.Accent or Theme.Icon })
		else
			tween(other._nav.icon, 0.15, { TextColor3 = active and Theme.Accent or Theme.Icon })
		end
	end
	self.CurrentTab = tab
	self.toolbarTitle.Text = tab.Name
	if self.searchBox.Text ~= "" then
		self.searchBox.Text = ""
	end
	self:_filter("")
end

function Window:_filter(query)
	local tab = self.CurrentTab
	if not tab then
		return
	end
	query = string.lower(query or "")
	for _, entry in ipairs(tab.rows) do
		local visible = query == "" or string.find(entry.name, query, 1, true) ~= nil
		entry.frame.Visible = visible
		if entry.extra then
			entry.extra.Visible = visible
		end
	end
end

function Window:SetVisible(visible)
	self.Visible = visible
	if not visible then
		self:_closeAll()
	end
	self.main.Visible = visible
end

function Window:Toggle()
	self:SetVisible(not self.Visible)
end

function Window:Notify(opts)
	opts = opts or {}
	local holder = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(280, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.notifyLayer,
	})
	local card = create("Frame", {
		BackgroundColor3 = Theme.Panel,
		Position = UDim2.fromOffset(300, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = holder,
	}, { corner(8), stroke(Theme.Accent, 0.6, 1), padding(14, 12, 14, 12), listLayout(4) })
	label({
		Text = opts.Title or "Notification",
		Font = FONT_BOLD,
		TextSize = TEXT_MD,
		TextColor3 = Theme.Title,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 1,
		Parent = card,
	})
	if opts.Text then
		label({
			Text = opts.Text,
			TextSize = TEXT_SM,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
			Parent = card,
		})
	end
	tween(card, 0.35, { Position = UDim2.fromOffset(0, 0) })
	task.delay(opts.Duration or 4, function()
		tween(card, 0.3, { Position = UDim2.fromOffset(300, 0) })
		task.wait(0.3)
		holder:Destroy()
	end)
end

----------------------------------------------------------------------
-- Экранные виджеты: Watermark, Hotkeys, Spectators
-- Живут в отдельном слое и остаются на экране, когда меню скрыто.
----------------------------------------------------------------------

local function hex(color)
	return "#" .. color:ToHex()
end

local function getPing()
	local ok, ping = pcall(function()
		return LocalPlayer:GetNetworkPing()
	end)
	if ok and type(ping) == "number" then
		return math.floor(ping * 1000 + 0.5)
	end
	return nil
end

local function getMemory()
	local ok, memory = pcall(function()
		return Stats:GetTotalMemoryUsageMb()
	end)
	if ok and type(memory) == "number" then
		return math.floor(memory + 0.5)
	end
	return nil
end

local function getSpeed()
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	local velocity = root.AssemblyLinearVelocity
	return math.floor(Vector3.new(velocity.X, 0, velocity.Z).Magnitude + 0.5)
end

local function getKD()
	local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end
	local function find(names)
		for _, name in ipairs(names) do
			local value = leaderstats:FindFirstChild(name)
			if value and (value:IsA("IntValue") or value:IsA("NumberValue")) then
				return value.Value
			end
		end
		return nil
	end
	local kills = find({ "Kills", "KOs", "Kill" })
	local deaths = find({ "Deaths", "Wipeouts", "Death" })
	if not kills or not deaths then
		return nil
	end
	return string.format("%.2f", kills / math.max(deaths, 1))
end

-- По умолчанию «наблюдатели» — игроки без живого персонажа (умершие / ещё не заспавнившиеся).
-- В Roblox нет общего способа узнать, на кого смотрит камера другого игрока,
-- поэтому для конкретной игры задайте Library.GetSpectators.
local function defaultSpectators()
	local result = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then
				table.insert(result, player)
			end
		end
	end
	return result
end

function Window:_draggable(frame)
	local dragStart, startPosition
	frame.InputBegan:Connect(function(input)
		if isPointer(input) then
			dragStart = input.Position
			startPosition = frame.Position
		end
	end)
	self:_track(UserInputService.InputChanged:Connect(function(input)
		if dragStart and isMove(input) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end))
	self:_track(UserInputService.InputEnded:Connect(function(input)
		if isPointer(input) then
			dragStart = nil
		end
	end))
end

function Window:_startWidgetLoop()
	if self._widgetLoop then
		return
	end
	self._widgetLoop = true
	local frames, fps, last = 0, 0, os.clock()
	self:_track(RunService.RenderStepped:Connect(function()
		frames += 1
	end))
	task.spawn(function()
		while self.gui and self.gui.Parent do
			local now = os.clock()
			if now - last >= 0.5 then
				fps = math.floor(frames / (now - last) + 0.5)
				frames = 0
				last = now
			end
			local info = { fps = fps, menuOpen = self.Visible }
			for _, widget in ipairs(self._widgets) do
				local ok, err = pcall(widget._update, widget, info)
				if not ok then
					warn("[Nocturne UI] widget error: " .. tostring(err))
				end
			end
			task.wait(0.25)
		end
	end)
end

-- Цвета виджетов (по референсам: тёмная капсула, светло-серый текст, иконки цветом акцента).
local WIDGET_BG = Color3.fromRGB(13, 14, 19)
local WIDGET_TEXT = Color3.fromRGB(200, 202, 214)

----------------------------------------------------------------------
-- Мини-иконки 12×12 из примитивов (без картинок-ассетов).
-- Части, помеченные атрибутом "IconPart", перекрашиваются в акцент.
----------------------------------------------------------------------

local function iconPart(parent, x, y, w, h, radius, color)
	local part = create("Frame", {
		BackgroundColor3 = color or Theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		Parent = parent,
	})
	if radius and radius > 0 then
		corner(radius).Parent = part
	end
	if not color then
		part:SetAttribute("IconPart", true)
	end
	return part
end

local function iconRing(parent, x, y, w, h, thickness, radius)
	local ring = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		Parent = parent,
	}, { corner(radius or math.floor(math.min(w, h) / 2)) })
	local ringStroke = stroke(Theme.Accent, 0, thickness or 1.5)
	ringStroke:SetAttribute("IconPart", true)
	ringStroke.Parent = ring
	return ring
end

local IconDrawers = {
	-- пинг: столбики сигнала
	bars = function(f)
		iconPart(f, 0, 7, 3, 4, 1)
		iconPart(f, 4.5, 4, 3, 7, 1)
		iconPart(f, 9, 1, 3, 10, 1)
	end,
	-- FPS: монитор
	monitor = function(f)
		iconRing(f, 0.5, 0.5, 11, 8, 1.5, 2)
		iconPart(f, 3.5, 10, 5, 1.5, 1)
	end,
	-- время: часы
	clock = function(f)
		iconRing(f, 0.5, 0.5, 11, 11, 1.5)
		iconPart(f, 5.25, 3, 1.5, 3.5, 1)
		iconPart(f, 5.25, 5.25, 3, 1.5, 1)
	end,
	-- имя / игроки: человечек
	user = function(f)
		iconPart(f, 3.5, 0, 5, 5, 3)
		iconPart(f, 1, 6.5, 10, 5.5, 3)
	end,
	-- память: чип
	chip = function(f)
		iconRing(f, 1.5, 1.5, 9, 9, 1.5, 2)
		iconPart(f, 4.5, 4.5, 3, 3, 1)
	end,
	-- K/D: прицел
	crosshair = function(f)
		iconRing(f, 1.5, 1.5, 9, 9, 1.5)
		iconPart(f, 5, 5, 2, 2, 1)
		iconPart(f, 5.25, -0.5, 1.5, 3, 0)
		iconPart(f, 5.25, 9.5, 1.5, 3, 0)
		iconPart(f, -0.5, 5.25, 3, 1.5, 0)
		iconPart(f, 9.5, 5.25, 3, 1.5, 0)
	end,
	-- скорость: две стрелки
	speed = function(f)
		-- две «›» из повёрнутых палочек
		for _, x in ipairs({ 1, 6 }) do
			iconPart(f, x + 1.25, 1, 1.6, 5, 1).Rotation = -45
			iconPart(f, x + 1.25, 5, 1.6, 5, 1).Rotation = 45
		end
	end,
	-- шапка Hotkeys: список
	list = function(f)
		for i, y in ipairs({ 1, 5, 9 }) do
			iconPart(f, 0, y, 2.5, 2.5, 1)
			iconPart(f, 4, y, i == 2 and 6 or 8, 2.5, 1)
		end
	end,
	-- шапка Spectators: глаз
	eye = function(f)
		iconRing(f, 0, 2, 12, 8, 1.5, 4)
		iconPart(f, 4, 4, 4, 4, 2)
	end,
}

local function drawIcon(name, parent, order)
	local frame = create("Frame", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(12, 12),
		LayoutOrder = order or 0,
		Parent = parent,
	})
	local drawer = IconDrawers[name]
	if drawer then
		drawer(frame)
	end
	return frame
end

local function paintIcons(root, color)
	for _, item in ipairs(root:GetDescendants()) do
		if item:GetAttribute("IconPart") then
			if item:IsA("UIStroke") then
				item.Color = color
			elseif item:IsA("GuiObject") then
				item.BackgroundColor3 = color
			end
		end
	end
end

-- Мини-переключатель для строк Hotkeys: залитый (toggle), контурный (hold), тусклый (выкл).
local function drawSwitch(parent, order, kind)
	local holder = create("Frame", {
		Name = "Switch",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(20, 14),
		LayoutOrder = order,
		Parent = parent,
	})
	local pill = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(20, 11),
		BackgroundColor3 = Theme.Title,
		BackgroundTransparency = kind == "toggle" and 0 or 1,
		Parent = holder,
	}, { corner(6) })
	if kind ~= "toggle" then
		stroke(kind == "off" and Theme.Muted or Theme.Title, 0, 1.4).Parent = pill
	end
	local knobOn = kind ~= "off"
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, knobOn and 14.5 or 5.5, 0.5, 0),
		Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = kind == "toggle" and WIDGET_BG or (kind == "off" and Theme.Muted or WIDGET_TEXT),
		Parent = pill,
	}, { corner(3) })
	return holder
end

----------------------------------------------------------------------
-- Watermark: капсула «NC  [иконка] 24 MS  [иконка] 60 FPS ... (аватар)»
----------------------------------------------------------------------

local WATERMARK_ITEMS = {
	Name = { icon = "user" },
	Framerate = { icon = "monitor" },
	Latency = { icon = "bars" },
	Speed = { icon = "speed" },
	Memory = { icon = "chip" },
	["KD Ratio"] = { icon = "crosshair" },
	Players = { icon = "user" },
	Time = { icon = "clock" },
}

function Window:CreateWatermark(opts)
	opts = opts or {}
	local watermark = {
		Visible = opts.Visible ~= false,
		Items = opts.Items or { "Logo", "Latency", "Framerate", "Time", "Name" },
		Avatar = opts.Avatar ~= false,
		Accent = opts.Accent or Theme.Accent,
		Title = opts.Title or "NC",
	}

	local frame = create("Frame", {
		Name = "Watermark",
		BackgroundColor3 = WIDGET_BG,
		BackgroundTransparency = 0.08,
		AnchorPoint = Vector2.new(1, 0),
		Position = opts.Position or UDim2.new(1, -16, 0, 16),
		Size = UDim2.fromOffset(0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		Visible = false,
		Parent = self.widgetLayer,
	}, {
		corner(15),
		stroke(Theme.Stroke, 0.55, 1),
		padding(14, 0, 5, 0),
		listLayout(14, Enum.FillDirection.Horizontal, Enum.VerticalAlignment.Center),
	})

	local logo = label({
		Text = watermark.Title,
		Font = FONT_BOLD,
		TextSize = TEXT_MD,
		TextColor3 = WIDGET_TEXT,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 18),
		LayoutOrder = 0,
		Parent = frame,
	})

	local groups = {}
	for item, info in pairs(WATERMARK_ITEMS) do
		local group = create("Frame", {
			Name = item,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(0, 18),
			AutomaticSize = Enum.AutomaticSize.X,
			Visible = false,
			Parent = frame,
		}, { listLayout(6, Enum.FillDirection.Horizontal, Enum.VerticalAlignment.Center) })
		drawIcon(info.icon, group, 1)
		local text = label({
			Font = FONT_BOLD,
			TextSize = TEXT_SM - 1,
			TextColor3 = WIDGET_TEXT,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 18),
			LayoutOrder = 2,
			Parent = group,
		})
		groups[item] = { frame = group, text = text }
	end

	local avatar = create("ImageLabel", {
		BackgroundColor3 = Theme.NavActive,
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=48&h=48",
		Size = UDim2.fromOffset(22, 22),
		LayoutOrder = 1000,
		Parent = frame,
	}, { corner(11) })
	local avatarStroke = stroke(watermark.Accent, 0.35, 1.5)
	avatarStroke.Parent = avatar

	self:_draggable(frame)

	local function valueFor(item, state)
		if item == "Name" then
			return LocalPlayer.Name
		elseif item == "Framerate" then
			return tostring(state.fps) .. " FPS"
		elseif item == "Latency" then
			local ping = getPing()
			return ping and (ping .. " MS") or nil
		elseif item == "Speed" then
			local speed = getSpeed()
			return speed and (speed .. " ST/S") or nil
		elseif item == "Memory" then
			local memory = getMemory()
			return memory and (memory .. " MB") or nil
		elseif item == "KD Ratio" then
			local kd = getKD()
			return kd and (kd .. " KD") or nil
		elseif item == "Players" then
			return #Players:GetPlayers() .. " PLAYERS"
		elseif item == "Time" then
			return os.date("%H:%M:%S")
		end
		return nil
	end

	function watermark:_update(state)
		local anyShown = false
		for item, group in pairs(groups) do
			group.frame.Visible = false
		end
		for index, item in ipairs(self.Items) do
			local group = groups[item]
			if group then
				local value = valueFor(item, state)
				if value then
					group.text.Text = value
					group.frame.LayoutOrder = index
					group.frame.Visible = true
					anyShown = true
				end
			end
		end
		logo.Visible = table.find(self.Items, "Logo") ~= nil
		avatar.Visible = self.Avatar
		frame.Visible = self.Visible and (anyShown or logo.Visible or avatar.Visible)
	end

	function watermark:SetVisible(visible)
		self.Visible = visible
	end
	function watermark:SetItems(items)
		self.Items = items or {}
	end
	function watermark:SetAvatar(enabled)
		self.Avatar = enabled
	end
	function watermark:SetAccent(color)
		self.Accent = color
		avatarStroke.Color = color
		paintIcons(frame, color)
	end
	watermark.Frame = frame

	watermark:SetAccent(watermark.Accent)
	table.insert(self._widgets, watermark)
	self:_startWidgetLoop()
	return watermark
end

----------------------------------------------------------------------
-- Список (Hotkeys / Spectators): шапка «иконка + заголовок», строки «значок + имя».
----------------------------------------------------------------------

function Window:_listWidget(name, title, position, headerIcon)
	local widget = {
		Visible = true,
		Style = "Default",
		RightAligned = false,
		Dynamic = false,
		Accent = Theme.Accent,
		Entries = {},
		_signature = nil,
	}

	-- Без рамки: только мягкое затемнение, уходящее в прозрачность (как на референсе).
	local frame = create("Frame", {
		Name = name,
		BackgroundColor3 = WIDGET_BG,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Position = position,
		Size = UDim2.fromOffset(240, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.widgetLayer,
	}, { corner(8) })
	local fade = create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.55, 0.35),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = frame,
	})

	local header = create("Frame", {
		Name = "Header",
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
		Parent = frame,
	}, { corner(8), padding(14, 0, 14, 0) })
	local headerLayout = listLayout(12, Enum.FillDirection.Horizontal, Enum.VerticalAlignment.Center)
	headerLayout.Parent = header
	local icon = drawIcon(headerIcon, header, 1)
	create("UIScale", { Scale = 1.3, Parent = icon })
	icon.Size = UDim2.fromOffset(12, 12)
	local titleLabel = label({
		Text = title,
		Font = FONT_BOLD,
		TextSize = 15,
		TextColor3 = WIDGET_TEXT,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		TextStrokeTransparency = 0.8,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		LayoutOrder = 2,
		Parent = header,
	})

	local body = create("Frame", {
		Name = "Rows",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 36),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = frame,
	}, { padding(14, 0, 14, 10), listLayout(2) })
	self:_draggable(frame)

	local function compact()
		return widget.Style == "Compact"
	end

	local function applyStyle()
		local inverted = widget.Style == "Inverted"
		local headerHeight = compact() and 28 or 36
		header.Size = UDim2.new(1, 0, 0, headerHeight)
		body.Position = UDim2.fromOffset(0, headerHeight)
		header.BackgroundColor3 = widget.Accent
		header.BackgroundTransparency = inverted and 0 or 1
		titleLabel.TextColor3 = inverted and WIDGET_BG or WIDGET_TEXT
		titleLabel.TextSize = compact() and TEXT_MD or 15
		paintIcons(icon, inverted and WIDGET_BG or widget.Accent)
		headerLayout.HorizontalAlignment = widget.RightAligned and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
		icon.LayoutOrder = widget.RightAligned and 3 or 1
		-- затемнение всегда со стороны текста
		fade.Rotation = widget.RightAligned and 180 or 0
	end

	local function rebuild(entries, placeholder)
		for _, child in ipairs(body:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		local list = entries
		if #list == 0 and placeholder then
			list = { { Name = "None", Icon = "off", Dim = true } }
		end
		local height = compact() and 22 or 28
		local textSize = compact() and TEXT_SM or 14
		local alignment = widget.RightAligned and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
		for index, entry in ipairs(list) do
			local row = create("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, height),
				LayoutOrder = index,
				Parent = body,
			})
			local rowLayout = listLayout(14, Enum.FillDirection.Horizontal, Enum.VerticalAlignment.Center)
			rowLayout.HorizontalAlignment = alignment
			rowLayout.Parent = row
			local markerOrder = widget.RightAligned and 2 or 1
			if entry.Image then
				local image = create("ImageLabel", {
					BackgroundColor3 = Theme.NavActive,
					Image = entry.Image,
					Size = UDim2.fromOffset(20, 20),
					LayoutOrder = markerOrder,
					Parent = row,
				}, { corner(10) })
				local imageStroke = stroke(widget.Accent, 0.4, 1)
				imageStroke.Parent = image
			else
				drawSwitch(row, markerOrder, entry.Icon or "toggle")
			end
			label({
				Text = entry.Name,
				Font = FONT_MEDIUM,
				TextSize = textSize,
				TextColor3 = entry.Dim and Theme.Muted or Theme.Title,
				TextStrokeColor3 = Color3.new(0, 0, 0),
				TextStrokeTransparency = 0.8,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = widget.RightAligned and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -36, 1, 0),
				LayoutOrder = widget.RightAligned and 1 or 2,
				Parent = row,
			})
		end
	end

	function widget:SetEntries(entries, state)
		self.Entries = entries
		local parts = { self.Style, tostring(self.RightAligned), tostring(state.menuOpen) }
		for _, entry in ipairs(entries) do
			table.insert(parts, tostring(entry.Name) .. "=" .. tostring(entry.Icon) .. tostring(entry.Dim))
		end
		local signature = table.concat(parts, "|")
		if signature ~= self._signature then
			self._signature = signature
			rebuild(entries, state.menuOpen)
		end
		-- Dynamic: пустой список прячется, пока меню закрыто
		frame.Visible = self.Visible and (#entries > 0 or state.menuOpen or not self.Dynamic)
	end

	function widget:SetVisible(visible)
		self.Visible = visible
	end
	function widget:SetStyle(style)
		self.Style = style
		self._signature = nil
		applyStyle()
	end
	function widget:SetRightAligned(enabled)
		self.RightAligned = enabled
		self._signature = nil
		applyStyle()
	end
	function widget:SetDynamic(enabled)
		self.Dynamic = enabled
	end
	function widget:SetAccent(color)
		self.Accent = color
		self._signature = nil
		applyStyle()
	end
	widget.Frame = frame

	applyStyle()
	table.insert(self._widgets, widget)
	self:_startWidgetLoop()
	return widget
end

function Window:CreateHotkeyList(opts)
	opts = opts or {}
	local window = self
	local widget = self:_listWidget("Hotkeys", opts.Title or "Hotkeys", opts.Position or UDim2.fromOffset(16, 260), "list")
	widget.ShowAll = opts.ShowAll == true
	widget.Visible = opts.Visible ~= false

	function widget:SetShowAll(enabled)
		self.ShowAll = enabled
	end

	function widget:_update(state)
		local entries = {}
		for _, keybind in ipairs(Library.Keybinds) do
			if keybind.Window == window and keybind.Target and keybind.Value then
				if keybind:IsActive() then
					table.insert(entries, {
						Name = keybind.Target.Name,
						Icon = keybind.Mode == "Hold" and "hold" or "toggle",
					})
				elseif self.ShowAll then
					table.insert(entries, { Name = keybind.Target.Name, Icon = "off", Dim = true })
				end
			end
		end
		self:SetEntries(entries, state)
	end

	return widget
end

function Window:CreateSpectatorList(opts)
	opts = opts or {}
	local widget = self:_listWidget("Spectators", opts.Title or "Spectators", opts.Position or UDim2.fromOffset(16, 420), "eye")
	widget.Visible = opts.Visible ~= false

	function widget:_update(state)
		local getter = Library.GetSpectators or defaultSpectators
		local ok, players = pcall(getter)
		if not ok or type(players) ~= "table" then
			players = {}
		end
		local entries = {}
		for _, player in ipairs(players) do
			if typeof(player) == "Instance" and player:IsA("Player") then
				table.insert(entries, {
					Name = player.DisplayName,
					Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(player.UserId) .. "&w=48&h=48",
				})
			end
		end
		self:SetEntries(entries, state)
	end

	return widget
end

function Window:Destroy()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	self._connections = {}
	for i = #Library.Keybinds, 1, -1 do
		if Library.Keybinds[i].Window == self then
			table.remove(Library.Keybinds, i)
		end
	end
	self.gui:Destroy()
	for i, window in ipairs(Library.Windows) do
		if window == self then
			table.remove(Library.Windows, i)
			break
		end
	end
end

----------------------------------------------------------------------
-- Создание окна
----------------------------------------------------------------------

function Library:CreateWindow(opts)
	opts = opts or {}
	local window = setmetatable({
		Tabs = {},
		Visible = true,
		ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift,
		_connections = {},
		_popups = {},
		_widgets = {},
		_navOrder = 0,
	}, Window)

	local title = opts.Title or "Nocturne"
	local gui = create("ScreenGui", {
		Name = opts.GuiName or "NocturneUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	})
	gui.Parent = getGuiParent()
	window.gui = gui

	-- Слой виджетов создаётся первым, чтобы меню и всплывающие окна были поверх него.
	window.widgetLayer = create("Frame", { Name = "Widgets", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = gui })

	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = opts.Size or UDim2.fromOffset(780, 560),
		BackgroundColor3 = Theme.Window,
		Parent = gui,
	}, { corner(10), stroke(Theme.Stroke, 0.3, 1) })
	sink(main)
	window.main = main

	-- Сайдбар
	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 180, 1, 0),
		BackgroundColor3 = Theme.Sidebar,
		Parent = main,
	}, { corner(10) })
	create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 12, 1, 0),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	divider({ Position = UDim2.fromOffset(180, 0), Size = UDim2.new(0, 1, 1, 0), Parent = main })

	local brand = create("Frame", { Name = "Brand", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 58), Parent = sidebar })
	label({
		Text = opts.Logo or string.upper(string.sub(title, 1, 2)),
		Font = FONT_BOLD,
		TextSize = 18,
		TextColor3 = Theme.Logo,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(0, 30, 1, 0),
		Parent = brand,
	})
	label({
		Text = title,
		Font = FONT_BOLD,
		TextSize = TEXT_LG,
		TextColor3 = Theme.Title,
		Position = UDim2.fromOffset(52, 13),
		Size = UDim2.new(1, -58, 0, 16),
		Parent = brand,
	})
	label({
		Text = opts.Subtitle or "Universal",
		TextSize = TEXT_XS,
		TextColor3 = Theme.Muted,
		Position = UDim2.fromOffset(52, 30),
		Size = UDim2.new(1, -58, 0, 12),
		Parent = brand,
	})

	window.nav = create("ScrollingFrame", {
		Name = "Navigation",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 58),
		Size = UDim2.new(1, 0, 1, -118),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		Parent = sidebar,
	}, { padding(10, 0, 10, 8), listLayout(2) })

	local footer = create("Frame", {
		Name = "Footer",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 60),
		Parent = sidebar,
	})
	divider({ Parent = footer })
	create("ImageLabel", {
		BackgroundColor3 = Theme.NavActive,
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=48&h=48",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		Parent = footer,
	}, { corner(14) })
	label({
		Text = LocalPlayer.DisplayName,
		Font = FONT_MEDIUM,
		TextColor3 = Theme.TextStrong,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(54, 14),
		Size = UDim2.new(1, -86, 0, 16),
		Parent = footer,
	})
	label({
		Text = opts.Footer or "Menu preview",
		TextSize = TEXT_XS,
		TextColor3 = Theme.Muted,
		Position = UDim2.fromOffset(54, 31),
		Size = UDim2.new(1, -86, 0, 12),
		Parent = footer,
	})
	chevron({ AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0), Parent = footer })

	-- Тулбар
	local toolbar = create("Frame", {
		Name = "Toolbar",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(181, 0),
		Size = UDim2.new(1, -181, 0, 50),
		Parent = main,
	})
	divider({ Position = UDim2.fromOffset(181, 50), Size = UDim2.new(1, -181, 0, 1), Parent = main })
	window.toolbarTitle = label({
		Text = "",
		Font = FONT_MEDIUM,
		TextSize = TEXT_LG,
		TextColor3 = Theme.TextStrong,
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.new(1, -260, 1, 0),
		Parent = toolbar,
	})

	local search = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -46, 0.5, 0),
		Size = UDim2.fromOffset(170, 28),
		BackgroundColor3 = Theme.Field,
		Parent = toolbar,
	}, { corner(6) })
	window.searchBox = create("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		Font = FONT,
		TextSize = TEXT_SM,
		TextColor3 = Theme.TextStrong,
		PlaceholderText = "Search",
		PlaceholderColor3 = Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Text = "",
		Parent = search,
	})
	window.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		window:_filter(window.searchBox.Text)
	end)

	local close = create("TextButton", {
		Text = "×",
		Font = FONT_MEDIUM,
		TextSize = 20,
		TextColor3 = Theme.Muted,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		Parent = toolbar,
	})
	close.MouseEnter:Connect(function()
		tween(close, 0.12, { TextColor3 = Theme.Danger })
	end)
	close.MouseLeave:Connect(function()
		tween(close, 0.12, { TextColor3 = Theme.Muted })
	end)
	close.MouseButton1Click:Connect(function()
		window:SetVisible(false)
		window:Notify({ Title = title, Text = "Menu hidden. Press " .. window.ToggleKey.Name .. " to open it again.", Duration = 3 })
	end)

	window.content = create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(181, 51),
		Size = UDim2.new(1, -181, 1, -51),
		Parent = main,
	})

	-- Слои поверх окна: всплывающие панели и уведомления.
	window.popupLayer = create("Frame", { Name = "Popups", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = gui })
	window.notifyLayer = create("Frame", {
		Name = "Notifications",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(280, 400),
		Parent = gui,
	}, { listLayout(8, Enum.FillDirection.Vertical, Enum.VerticalAlignment.Bottom) })

	-- Перетаскивание за брендинг и тулбар.
	local dragStart, startPosition
	local function beginDrag(input)
		if isPointer(input) then
			dragStart = input.Position
			startPosition = main.Position
			window:_closeAll()
		end
	end
	brand.InputBegan:Connect(beginDrag)
	toolbar.InputBegan:Connect(beginDrag)
	window:_track(UserInputService.InputChanged:Connect(function(input)
		if dragStart and isMove(input) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end))
	window:_track(UserInputService.InputEnded:Connect(function(input)
		if isPointer(input) then
			dragStart = nil
		end
	end))

	-- Клик мимо всплывающей панели закрывает её.
	window:_track(UserInputService.InputBegan:Connect(function(input, processed)
		if isPointer(input) then
			-- input.Position и AbsolutePosition в одной системе координат (без inset)
			local point = Vector2.new(input.Position.X, input.Position.Y)
			for i = #window._popups, 1, -1 do
				local popup = window._popups[i]
				if pointIn(popup.frame, point) or (popup.anchor and pointIn(popup.anchor, point)) then
					break
				end
				window:_closePopup(popup.frame)
			end
		elseif not processed and not Library._listening and input.KeyCode == window.ToggleKey then
			window:Toggle()
		end
	end))

	table.insert(Library.Windows, window)
	return window
end

function Library:Notify(opts)
	local window = Library.Windows[#Library.Windows]
	if window then
		window:Notify(opts)
	end
end

function Library:Unload()
	for i = #Library.Windows, 1, -1 do
		Library.Windows[i]:Destroy()
	end
end

return Library
