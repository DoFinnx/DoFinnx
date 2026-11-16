--!strict
--[[
	ESP — библиотека оверлеев для Roblox Studio (ModuleScript).
	Работает на официальных API: Highlight + BillboardGui.
	Положи в ReplicatedStorage, подключай из LocalScript в СВОЕЙ игре
	(спектатор, админ-панель, подсветка союзников/целей/предметов).

	API:
		local ESP = require(path.ESP)
		local esp = ESP.new({ ...config })
		esp:AddPlayers()                 -- автоматически следить за всеми игроками
		esp:Add(instance, {Name="Chest", FillColor=Color3.new(1,1,0)})  -- любой Model/BasePart
		esp:Remove(instance)
		esp:SetEnabled(false)
		esp:Destroy()
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

export type Config = {
	Enabled: boolean?,
	MaxDistance: number?,       -- студы; дальше — скрыто
	TeamCheck: boolean?,        -- не показывать игроков своей команды
	UseTeamColor: boolean?,     -- красить по цвету команды
	ShowHighlight: boolean?,
	ShowName: boolean?,
	ShowDistance: boolean?,
	ShowHealth: boolean?,
	FillColor: Color3?,
	OutlineColor: Color3?,
	FillTransparency: number?,
	OutlineTransparency: number?,
	TextColor: Color3?,
	TextSize: number?,
	Font: Enum.Font?,
}

export type EntryOptions = {
	Name: string?,
	FillColor: Color3?,
	OutlineColor: Color3?,
}

type Entry = {
	Target: Instance,
	Options: EntryOptions,
	Highlight: Highlight?,
	Gui: BillboardGui,
	NameLabel: TextLabel,
	InfoLabel: TextLabel,
	HealthBack: Frame,
	HealthBar: Frame,
	Player: Player?,
}

local DEFAULTS: Config = {
	Enabled = true,
	MaxDistance = 1000,
	TeamCheck = false,
	UseTeamColor = true,
	ShowHighlight = true,
	ShowName = true,
	ShowDistance = true,
	ShowHealth = true,
	FillColor = Color3.fromRGB(255, 60, 60),
	OutlineColor = Color3.fromRGB(255, 255, 255),
	FillTransparency = 0.6,
	OutlineTransparency = 0,
	TextColor = Color3.new(1, 1, 1),
	TextSize = 14,
	Font = Enum.Font.GothamBold,
}

local ESP = {}
ESP.__index = ESP

export type ESP = typeof(setmetatable({} :: {
	Config: Config,
	_entries: { [Instance]: Entry },
	_conns: { RBXScriptConnection },
	_folder: Folder,
	_destroyed: boolean,
}, ESP))

local function getRoot(target: Instance): BasePart?
	if target:IsA("BasePart") then
		return target
	elseif target:IsA("Model") then
		return target.PrimaryPart
			or target:FindFirstChild("HumanoidRootPart") :: BasePart?
			or target:FindFirstChildWhichIsA("BasePart") :: BasePart?
	end
	return nil
end

local function getHumanoid(target: Instance): Humanoid?
	if target:IsA("Model") then
		return target:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

function ESP.new(config: Config?): ESP
	local cfg = table.clone(DEFAULTS)
	if config then
		for k, v in config :: any do
			(cfg :: any)[k] = v
		end
	end

	local folder = Instance.new("Folder")
	folder.Name = "ESP_Overlays"
	folder.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local self = setmetatable({
		Config = cfg,
		_entries = {},
		_conns = {},
		_folder = folder,
		_destroyed = false,
	}, ESP)

	table.insert(self._conns, RunService.RenderStepped:Connect(function()
		self:_update()
	end))

	return self
end

function ESP.Add(self: ESP, target: Instance, options: EntryOptions?): ()
	if self._entries[target] or self._destroyed then
		return
	end
	local opts: EntryOptions = options or {}

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight"
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = target
	highlight.Parent = self._folder

	local gui = Instance.new("BillboardGui")
	gui.Name = "ESP_Gui"
	gui.AlwaysOnTop = true
	gui.Size = UDim2.fromOffset(140, 50)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.ResetOnSpawn = false
	gui.Adornee = getRoot(target)
	gui.Parent = self._folder

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0, 18)
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Parent = gui

	local infoLabel = Instance.new("TextLabel")
	infoLabel.BackgroundTransparency = 1
	infoLabel.Position = UDim2.fromOffset(0, 18)
	infoLabel.Size = UDim2.new(1, 0, 0, 16)
	infoLabel.TextStrokeTransparency = 0.5
	infoLabel.Parent = gui

	local healthBack = Instance.new("Frame")
	healthBack.BackgroundColor3 = Color3.new(0, 0, 0)
	healthBack.BorderSizePixel = 0
	healthBack.AnchorPoint = Vector2.new(0.5, 0)
	healthBack.Position = UDim2.new(0.5, 0, 0, 38)
	healthBack.Size = UDim2.fromOffset(80, 5)
	healthBack.Parent = gui

	local healthBar = Instance.new("Frame")
	healthBar.BorderSizePixel = 0
	healthBar.Size = UDim2.fromScale(1, 1)
	healthBar.Parent = healthBack

	local entry: Entry = {
		Target = target,
		Options = opts,
		Highlight = highlight,
		Gui = gui,
		NameLabel = nameLabel,
		InfoLabel = infoLabel,
		HealthBack = healthBack,
		HealthBar = healthBar,
		Player = Players:GetPlayerFromCharacter(target :: any),
	}
	self._entries[target] = entry

	-- автоочистка, если объект удалён
	table.insert(self._conns, target.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			self:Remove(target)
		end
	end))
end

function ESP.Remove(self: ESP, target: Instance): ()
	local entry = self._entries[target]
	if not entry then
		return
	end
	if entry.Highlight then
		entry.Highlight:Destroy()
	end
	entry.Gui:Destroy()
	self._entries[target] = nil
end

function ESP.AddPlayers(self: ESP): ()
	local function hookPlayer(player: Player)
		if player == LocalPlayer then
			return
		end
		if player.Character then
			self:Add(player.Character, { Name = player.DisplayName })
		end
		table.insert(self._conns, player.CharacterAdded:Connect(function(char)
			self:Add(char, { Name = player.DisplayName })
		end))
		table.insert(self._conns, player.CharacterRemoving:Connect(function(char)
			self:Remove(char)
		end))
	end

	for _, p in Players:GetPlayers() do
		hookPlayer(p)
	end
	table.insert(self._conns, Players.PlayerAdded:Connect(hookPlayer))
end

function ESP.SetEnabled(self: ESP, enabled: boolean): ()
	self.Config.Enabled = enabled
	if not enabled then
		for _, e in self._entries do
			e.Gui.Enabled = false
			if e.Highlight then
				e.Highlight.Enabled = false
			end
		end
	end
end

function ESP._update(self: ESP): ()
	local cfg = self.Config
	if not cfg.Enabled then
		return
	end

	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local camPos = cam.CFrame.Position

	for target, e in self._entries do
		local root = getRoot(target)
		local visible = root ~= nil

		if root then
			e.Gui.Adornee = root
			local dist = (root.Position - camPos).Magnitude
			if dist > (cfg.MaxDistance :: number) then
				visible = false
			end

			if visible and cfg.TeamCheck and e.Player and e.Player.Team ~= nil
				and e.Player.Team == LocalPlayer.Team then
				visible = false
			end

			local hum = getHumanoid(target)
			if hum and hum.Health <= 0 then
				visible = false
			end

			if visible then
				local fill = e.Options.FillColor or cfg.FillColor :: Color3
				local outline = e.Options.OutlineColor or cfg.OutlineColor :: Color3
				if cfg.UseTeamColor and e.Player and e.Player.Team then
					fill = e.Player.Team.TeamColor.Color
				end

				if e.Highlight then
					e.Highlight.Enabled = cfg.ShowHighlight :: boolean
					e.Highlight.FillColor = fill
					e.Highlight.OutlineColor = outline
					e.Highlight.FillTransparency = cfg.FillTransparency :: number
					e.Highlight.OutlineTransparency = cfg.OutlineTransparency :: number
				end

				for _, label in { e.NameLabel, e.InfoLabel } do
					label.TextColor3 = cfg.TextColor :: Color3
					label.TextSize = cfg.TextSize :: number
					label.Font = cfg.Font :: Enum.Font
				end

				e.NameLabel.Visible = cfg.ShowName :: boolean
				e.NameLabel.Text = e.Options.Name or target.Name

				e.InfoLabel.Visible = cfg.ShowDistance :: boolean
				e.InfoLabel.Text = string.format("[%d studs]", math.floor(dist))

				local showHealth = (cfg.ShowHealth :: boolean) and hum ~= nil
				e.HealthBack.Visible = showHealth
				if hum and showHealth then
					local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
					e.HealthBar.Size = UDim2.fromScale(pct, 1)
					e.HealthBar.BackgroundColor3 = Color3.fromHSV(pct * 0.33, 1, 1)
				end
			end
		end

		e.Gui.Enabled = visible
		if e.Highlight and not visible then
			e.Highlight.Enabled = false
		end
	end
end

function ESP.Destroy(self: ESP): ()
	self._destroyed = true
	for _, c in self._conns do
		c:Disconnect()
	end
	table.clear(self._conns)
	self._folder:Destroy()
	table.clear(self._entries)
end

return ESP
