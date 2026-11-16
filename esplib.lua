--[[
    DoFinnx ESP Library — Frame Version (работает везде)
    Полная замена Drawing на Frame/TextLabel.
    Работает в Studio, на телефоне, в обычном Roblox и в эксплойтах.
]]

local ESPLibrary = {}
ESPLibrary.__index = ESPLibrary

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Vec2 = Vector2.new
local Vec3 = Vector3.new
local fromRGB = Color3.fromRGB
local clamp = math.clamp
local abs = math.abs
local floor = math.floor
local min = math.min

function ESPLibrary.new(parentGui, settings)
    local self = setmetatable({}, ESPLibrary)

    self.Settings = {
        Enabled = true,
        Boxes = true,
        CornerBoxes = false,
        Names = true,
        Distance = true,
        Health = true,
        Weapon = false,
        Skeleton = false,
        HeadDot = false,
        Tracers = false,
        Chams = false,
        Offscreen = false,
        TeamCheck = true,
        TeamColor = false,
        MaxDistance = 1500,

        BoxColor = fromRGB(255, 63, 87),
        NameColor = fromRGB(255, 255, 255),
        TracerColor = fromRGB(255, 63, 87),
        SkeletonColor = fromRGB(255, 255, 255),
        HeadDotColor = fromRGB(255, 63, 87),
        ChamsColor = fromRGB(255, 63, 87),
        ChamsFill = 0.55,
        ChamsOutline = 0,

        UpdateRate = 0,
    }

    if settings then
        for k, v in pairs(settings) do
            self.Settings[k] = v
        end
    end

    self.Drawings = {}
    self.Connections = {}
    self.Destroyed = false
    self.Frame = 0

    -- Создаём ScreenGui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "DoFinnxESP"
    self.Gui.IgnoreGuiInset = true
    self.Gui.ResetOnSpawn = false
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Gui.DisplayOrder = 50
    self.Gui.Parent = parentGui or game:GetService("CoreGui")

    self.BonesR15 = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    }
    self.BonesR6 = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
        {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
    }

    self:_start()
    return self
end

function ESPLibrary:_connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(self.Connections, c)
    return c
end

function ESPLibrary:_create(cls, props)
    local inst = Instance.new(cls)
    for k, v in pairs(props) do
        inst[k] = v
    end
    inst.Parent = self.Gui
    return inst
end

function ESPLibrary:_clearPlayer(plr)
    local data = self.Drawings[plr]
    if not data then return end

    local function rem(obj)
        if obj then pcall(function() obj:Destroy() end) end
    end

    rem(data.box)
    rem(data.name)
    rem(data.dist)
    rem(data.weapon)
    rem(data.healthBg)
    rem(data.health)
    rem(data.tracer)
    rem(data.headDot)
    rem(data.arrow)

    if data.skeleton then for _, l in pairs(data.skeleton) do rem(l) end end
    if data.corners then for _, l in pairs(data.corners) do rem(l) end end
    if data.chams then rem(data.chams) end

    self.Drawings[plr] = nil
end

function ESPLibrary:_w2s(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return Vec2(v.X, v.Y), on, v.Z
end

function ESPLibrary:_getColor(plr)
    local s = self.Settings
    if s.TeamColor and plr.Team and plr.Team.TeamColor then
        return plr.Team.TeamColor.Color
    end
    return s.BoxColor
end

function ESPLibrary:_start()
    self:_connect(RunService.RenderStepped, function()
        if self.Destroyed then return end

        self.Frame += 1
        local s = self.Settings

        if s.UpdateRate > 0 and (self.Frame % (s.UpdateRate + 1)) ~= 0 then
            return
        end

        if not s.Enabled then
            for plr in pairs(self.Drawings) do self:_clearPlayer(plr) end
            return
        end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myPos = myRoot and myRoot.Position
        local screen = Camera.ViewportSize
        local center = Vec2(screen.X * 0.5, screen.Y * 0.5)
        local seen = {}

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            seen[plr] = true

            local char = plr.Character
            if not char then
                self:_clearPlayer(plr)
                continue
            end

            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root or hum.Health <= 0 then
                self:_clearPlayer(plr)
                continue
            end

            if s.TeamCheck and LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then
                self:_clearPlayer(plr)
                continue
            end

            if myPos and (root.Position - myPos).Magnitude > s.MaxDistance then
                self:_clearPlayer(plr)
                continue
            end

            local pos, onScreen = self:_w2s(root.Position)
            local dist = myPos and (root.Position - myPos).Magnitude or 0

            local data = self.Drawings[plr]
            if not data then
                data = {
                    box = self:_create("Frame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 1,
                        BorderColor3 = Color3.new(1, 1, 1),
                        Visible = false,
                        ZIndex = 10,
                    }),
                    name = self:_create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(200, 15),
                        AnchorPoint = Vec2(0.5, 1),
                        Text = "",
                        TextColor3 = Color3.new(1, 1, 1),
                        TextStrokeTransparency = 0,
                        TextStrokeColor3 = Color3.new(0, 0, 0),
                        Font = Enum.Font.GothamMedium,
                        TextSize = 13,
                        Visible = false,
                        ZIndex = 11,
                    }),
                    dist = self:_create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(100, 15),
                        AnchorPoint = Vec2(0.5, 0),
                        Text = "",
                        TextColor3 = Color3.new(1, 1, 1),
                        TextStrokeTransparency = 0,
                        TextStrokeColor3 = Color3.new(0, 0, 0),
                        Font = Enum.Font.GothamMedium,
                        TextSize = 12,
                        Visible = false,
                        ZIndex = 11,
                    }),
                    weapon = self:_create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(100, 15),
                        AnchorPoint = Vec2(0.5, 0),
                        Text = "",
                        TextColor3 = fromRGB(255, 200, 90),
                        TextStrokeTransparency = 0,
                        TextStrokeColor3 = Color3.new(0, 0, 0),
                        Font = Enum.Font.GothamMedium,
                        TextSize = 12,
                        Visible = false,
                        ZIndex = 11,
                    }),
                    healthBg = self:_create("Frame", {
                        BackgroundColor3 = fromRGB(30, 30, 30),
                        BorderSizePixel = 0,
                        Visible = false,
                        ZIndex = 10,
                    }),
                    health = self:_create("Frame", {
                        BackgroundColor3 = fromRGB(0, 255, 0),
                        BorderSizePixel = 0,
                        Visible = false,
                        ZIndex = 11,
                    }),
                    tracer = self:_create("Frame", {
                        BackgroundColor3 = fromRGB(255, 63, 87),
                        BorderSizePixel = 0,
                        AnchorPoint = Vec2(0, 0.5),
                        Visible = false,
                        ZIndex = 9,
                    }),
                    headDot = self:_create("Frame", {
                        BackgroundColor3 = fromRGB(255, 63, 87),
                        BorderSizePixel = 0,
                        Size = UDim2.fromOffset(6, 6),
                        AnchorPoint = Vec2(0.5, 0.5),
                        Visible = false,
                        ZIndex = 11,
                    }),
                    arrow = self:_create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(20, 20),
                        AnchorPoint = Vec2(0.5, 0.5),
                        Text = "▼",
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 20,
                        Visible = false,
                        ZIndex = 12,
                    }),
                    skeleton = {},
                    corners = {},
                    chams = nil,
                    lastDist = -1,
                    lastHp = -1,
                    lastName = "",
                }

                for i = 1, 14 do
                    data.skeleton[i] = self:_create("Frame", {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        AnchorPoint = Vec2(0, 0.5),
                        Visible = false,
                        ZIndex = 9,
                    })
                end
                for i = 1, 8 do
                    data.corners[i] = self:_create("Frame", {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        AnchorPoint = Vec2(0, 0.5),
                        Visible = false,
                        ZIndex = 10,
                    })
                end

                self.Drawings[plr] = data
            end

            local color = self:_getColor(plr)
            local head = char:FindFirstChild("Head")
            local headPos = head and head.Position or root.Position + Vec3(0, 1.5, 0)

            local top = select(1, self:_w2s(headPos + Vec3(0, 0.35, 0)))
            local bottom = select(1, self:_w2s(root.Position - Vec3(0, 3, 0)))

            local height = abs(top.Y - bottom.Y)
            local width = height * 0.55
            local x = pos.X - width * 0.5
            local y = top.Y

            -- === BOX ===
            local boxVis = s.Boxes and onScreen and not s.CornerBoxes
            data.box.Visible = boxVis
            if boxVis then
                data.box.Position = UDim2.fromOffset(x, y)
                data.box.Size = UDim2.fromOffset(width, height)
                data.box.BorderColor3 = color
            end

            -- === CORNER BOX ===
            local cornerVis = s.CornerBoxes and onScreen
            if cornerVis then
                local len = min(width, height) * 0.25
                local c = data.corners
                local function setLine(line, fromX, fromY, toX, toY)
                    local dx, dy = toX - fromX, toY - fromY
                    local len2 = math.sqrt(dx*dx + dy*dy)
                    line.Position = UDim2.fromOffset(fromX, fromY)
                    line.Size = UDim2.fromOffset(len2, 2)
                    line.Rotation = math.deg(math.atan2(dy, dx))
                    line.BackgroundColor3 = color
                    line.Visible = true
                end
                setLine(c[1], x, y, x + len, y)
                setLine(c[2], x, y, x, y + len)
                setLine(c[3], x + width, y, x + width - len, y)
                setLine(c[4], x + width, y, x + width, y + len)
                setLine(c[5], x, y + height, x + len, y + height)
                setLine(c[6], x, y + height, x, y + height - len)
                setLine(c[7], x + width, y + height, x + width - len, y + height)
                setLine(c[8], x + width, y + height, x + width, y + height - len)
            else
                for i = 1, 8 do data.corners[i].Visible = false end
            end

            -- === NAME ===
            data.name.Visible = s.Names and onScreen
            if data.name.Visible then
                if data.lastName ~= plr.DisplayName then
                    data.name.Text = plr.DisplayName
                    data.lastName = plr.DisplayName
                end
                data.name.Position = UDim2.fromOffset(pos.X, y - 15)
                data.name.TextColor3 = s.NameColor
            end

            -- === DISTANCE ===
            data.dist.Visible = s.Distance and onScreen
            if data.dist.Visible then
                local d = floor(dist)
                if data.lastDist ~= d then
                    data.dist.Text = "[" .. d .. "]"
                    data.lastDist = d
                end
                data.dist.Position = UDim2.fromOffset(pos.X, y + height + 2)
                data.dist.TextColor3 = fromRGB(180, 180, 180)
            end

            -- === WEAPON ===
            data.weapon.Visible = s.Weapon and onScreen
            if data.weapon.Visible then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    data.weapon.Text = tool.Name
                    data.weapon.Position = UDim2.fromOffset(pos.X, y + height + (s.Distance and 15 or 2))
                else
                    data.weapon.Visible = false
                end
            end

            -- === HEALTH ===
            data.healthBg.Visible = s.Health and onScreen
            data.health.Visible = s.Health and onScreen
            if s.Health and onScreen then
                local hp = clamp(hum.Health / hum.MaxHealth, 0, 1)
                local barH = height * hp
                data.healthBg.Position = UDim2.fromOffset(x - 6, y)
                data.healthBg.Size = UDim2.fromOffset(3, height)
                data.healthBg.BackgroundColor3 = fromRGB(30, 30, 30)
                data.health.Position = UDim2.fromOffset(x - 6, y + height - barH)
                data.health.Size = UDim2.fromOffset(3, barH)
                data.health.BackgroundColor3 = fromRGB(255 * (1 - hp), 255 * hp, 50)
            end

            -- === TRACER ===
            data.tracer.Visible = s.Tracers and onScreen
            if data.tracer.Visible then
                local fromX, fromY = center.X, screen.Y
                local toX, toY = pos.X, y + height
                local dx, dy = toX - fromX, toY - fromY
                local len = math.sqrt(dx*dx + dy*dy)
                data.tracer.Position = UDim2.fromOffset(fromX, fromY)
                data.tracer.Size = UDim2.fromOffset(len, 1)
                data.tracer.Rotation = math.deg(math.atan2(dy, dx))
                data.tracer.BackgroundColor3 = s.TracerColor
            end

            -- === HEAD DOT ===
            data.headDot.Visible = s.HeadDot and onScreen and head
            if data.headDot.Visible then
                local hp = select(1, self:_w2s(head.Position))
                data.headDot.Position = UDim2.fromOffset(hp.X, hp.Y)
                data.headDot.BackgroundColor3 = s.HeadDotColor
            end

            -- === SKELETON ===
            if s.Skeleton and onScreen then
                local isR15 = char:FindFirstChild("UpperTorso")
                local list = isR15 and self.BonesR15 or self.BonesR6
                for i = 1, 14 do data.skeleton[i].Visible = false end
                for i, bone in ipairs(list) do
                    local p1 = char:FindFirstChild(bone[1])
                    local p2 = char:FindFirstChild(bone[2])
                    if p1 and p2 then
                        local s1, o1 = self:_w2s(p1.Position)
                        local s2, o2 = self:_w2s(p2.Position)
                        if o1 and o2 then
                            local line = data.skeleton[i]
                            local dx, dy = s2.X - s1.X, s2.Y - s1.Y
                            local len2 = math.sqrt(dx*dx + dy*dy)
                            line.Position = UDim2.fromOffset(s1.X, s1.Y)
                            line.Size = UDim2.fromOffset(len2, 1.5)
                            line.Rotation = math.deg(math.atan2(dy, dx))
                            line.BackgroundColor3 = s.SkeletonColor
                            line.Visible = true
                        end
                    end
                end
            else
                for i = 1, 14 do data.skeleton[i].Visible = false end
            end

            -- === OFFSCREEN ARROW ===
            data.arrow.Visible = s.Offscreen and not onScreen
            if data.arrow.Visible then
                local dirX, dirY = pos.X - center.X, pos.Y - center.Y
                local mag = math.sqrt(dirX*dirX + dirY*dirY)
                if mag > 0 then
                    dirX, dirY = dirX / mag, dirY / mag
                    local apX = center.X + dirX * (min(screen.X, screen.Y) * 0.38)
                    local apY = center.Y + dirY * (min(screen.X, screen.Y) * 0.38)
                    data.arrow.Position = UDim2.fromOffset(apX, apY)
                    data.arrow.Rotation = math.deg(math.atan2(dirY, dirX)) + 90
                    data.arrow.TextColor3 = color
                end
            end

            -- === CHAMS ===
            if s.Chams then
                if not data.chams or not data.chams.Parent then
                    local hl = Instance.new("Highlight")
                    hl.Name = "DoFinnxChams"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = self.Gui
                    data.chams = hl
                end
                data.chams.Adornee = char
                data.chams.FillColor = s.ChamsColor
                data.chams.OutlineColor = s.ChamsColor
                data.chams.FillTransparency = s.ChamsFill
                data.chams.OutlineTransparency = s.ChamsOutline
                data.chams.Enabled = true
            elseif data.chams then
                data.chams.Enabled = false
            end
        end

        for plr in pairs(self.Drawings) do
            if not seen[plr] then self:_clearPlayer(plr) end
        end
    end)

    local function hook(plr)
        self:_connect(plr.CharacterAdded, function()
            task.wait(0.25)
            self:_clearPlayer(plr)
        end)
        self:_connect(plr.CharacterRemoving, function()
            self:_clearPlayer(plr)
        end)
    end

    for _, plr in ipairs(Players:GetPlayers()) do hook(plr) end
    self:_connect(Players.PlayerAdded, hook)
    self:_connect(Players.PlayerRemoving, function(plr) self:_clearPlayer(plr) end)
end

function ESPLibrary:Update(t)
    for k, v in pairs(t) do self.Settings[k] = v end
end

function ESPLibrary:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    for _, c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
    self.Connections = {}
    for plr in pairs(self.Drawings) do self:_clearPlayer(plr) end
    self.Drawings = {}
    self.Gui:Destroy()
    print("[DoFinnx ESP] Destroyed")
end

return ESPLibrary
