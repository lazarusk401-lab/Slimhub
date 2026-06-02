task.wait(0.5)

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local coreGui = game:GetService("CoreGui")

local player = players.LocalPlayer
local camera = workspace.CurrentCamera

-- Config & Feature States
local config = {
    Flying = false,
    Noclip = false,
    SpeedHack = false,
    InfiniteJump = false,
    ClickTP = false,
    Invisible = false,
    ESPEnabled = false,
    ESPTracers = false,
    ESPNames = true,
    ESPRainbow = false,
    SilentAim = false,
    SilentAimFOV = 150,
    SilentAimTeamCheck = true,
    SilentAimWallCheck = false,
    SilentAimHitbox = "Head",
    SilentAimSmoothness = 0,
    FlySpeed = 50,
    HackSpeed = 100,
    DroneSpeed = 45,
    MenuKeybind = Enum.KeyCode.RightShift,
    IsMinimized = false,
    MenuOpen = true,
    ActiveTab = "Main"
}

-- UI States
local isTweening = false
local mainDragging = false
local dragStart, startPos
local baseSize = 40

-- Container
local gui = Instance.new("ScreenGui")
gui.Name = "SlimHub"
gui.ResetOnSpawn = false
gui.Parent = coreGui

-- Main Menu
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(500, 380)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(40, 40, 50)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Topbar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local topBarCover = Instance.new("Frame")
topBarCover.Size = UDim2.new(1, 0, 0, 15)
topBarCover.Position = UDim2.new(0, 0, 1, -15)
topBarCover.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
topBarCover.BorderSizePixel = 0
topBarCover.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.fromOffset(20, 0)
title.BackgroundTransparency = 1
title.Text = "SLIMHUB // PREMIUM"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(30, 30)
minBtn.Position = UDim2.new(1, -45, 0.5, -15)
minBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Parent = topBar

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = minBtn

-- Sidebar Layout
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -50)
sidebar.Position = UDim2.fromOffset(0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 4)
tabList.Parent = sidebar

-- Content Window
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -145, 1, -65)
contentArea.Position = UDim2.fromOffset(140, 60)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- Bottom Right Locked Tray Button
local trayBtn = Instance.new("TextButton")
trayBtn.Name = "Tray"
trayBtn.Size = UDim2.fromOffset(0, 0)
trayBtn.Position = UDim2.new(1, -60, 1, -60) -- Locked to bottom-right boundary
trayBtn.AnchorPoint = Vector2.new(0.5, 0.5)
trayBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
trayBtn.Text = ""
trayBtn.Visible = false
trayBtn.ZIndex = 10
trayBtn.Parent = gui

local trayCorner = Instance.new("UICorner")
trayCorner.CornerRadius = UDim.new(1, 0)
trayCorner.Parent = trayBtn

local trayStroke = Instance.new("UIStroke")
trayStroke.Color = Color3.fromRGB(0, 255, 150)
trayStroke.Thickness = 2
trayStroke.Parent = trayBtn

local trayLabel = Instance.new("TextLabel")
trayLabel.Size = UDim2.new(1, 0, 1, 0)
trayLabel.BackgroundTransparency = 1
trayLabel.Text = "S"
trayLabel.Font = Enum.Font.GothamBold
trayLabel.TextSize = 16
trayLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
trayLabel.ZIndex = 11
trayLabel.Parent = trayBtn

-- Tab & Layout Builders
local tabs = {}
local function createTab(name)
    local tab = Instance.new("ScrollingFrame")
    tab.Size = UDim2.fromScale(1, 1)
    tab.BackgroundTransparency = 1
    tab.CanvasSize = UDim2.fromScale(0, 1.4)
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
    tab.Visible = false
    tab.Parent = contentArea
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = tab
    
    tabs[name] = tab
    return tab
end

local tabButtons = {}
local function createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.fromOffset(5, 0)
    btn.BackgroundColor3 = name == "Main" and Color3.fromRGB(28, 28, 36) or Color3.fromRGB(15, 15, 19)
    btn.Text = ""
    btn.Parent = sidebar
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 10)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.5, 0)
    indicator.Position = UDim2.fromOffset(8, 0.25)
    indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    indicator.BorderSizePixel = 0
    indicator.Visible = name == "Main"
    indicator.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.fromOffset(20, 0)
    label.BackgroundTransparency = 1
    label.Text = name:upper()
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextColor3 = name == "Main" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    
    tabButtons[name] = {Btn = btn, Indicator = indicator, Label = label}
    
    btn.MouseButton1Click:Connect(function()
        config.ActiveTab = name
        for n, t in pairs(tabs) do t.Visible = n == name end
        for n, data in pairs(tabButtons) do
            local active = n == name
            data.Indicator.Visible = active
            data.Label.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
            data.Btn.BackgroundColor3 = active and Color3.fromRGB(28, 28, 36) or Color3.fromRGB(15, 15, 19)
        end
    end)
end

local function createSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -10, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", section)
    stroke.Color = Color3.fromRGB(35, 35, 45)
    stroke.Thickness = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 28)
    titleLabel.Position = UDim2.fromOffset(15, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title:upper()
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -30, 0, 1)
    divider.Position = UDim2.fromOffset(15, 32)
    divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    divider.BorderSizePixel = 0
    divider.Parent = section
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.fromOffset(0, 42)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.Parent = section
    
    local list = Instance.new("UIListLayout", content)
    list.Padding = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", content)
    pad.PaddingLeft = UDim.new(0, 15)
    pad.PaddingRight = UDim.new(0, 15)
    pad.PaddingBottom = UDim.new(0, 15)
    
    return content
end

local function createToggle(parent, text, configKey, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.fromOffset(48, 24)
    toggleBtn.Position = UDim2.new(1, -48, 0.5, -12)
    toggleBtn.BackgroundColor3 = config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 45)
    toggleBtn.Text = ""
    toggleBtn.Parent = row
    
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = config[configKey] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBtn
    
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local function update(state)
        config[configKey] = state
        tweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 45)}):Play()
        tweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
        if callback then callback(state) end
    end
    toggleBtn.MouseButton1Click:Connect(function() update(not config[configKey]) end)
end

local function createSlider(parent, text, configKey, min, max, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundTransparency = 1
    row.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.fromOffset(45, 22)
    valueLabel.Position = UDim2.new(1, -45, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(config[configKey])
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 5)
    track.Position = UDim2.new(0, 0, 0, 32)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    track.BorderSizePixel = 0
    track.Parent = row
    
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((config[configKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local hitArea = Instance.new("TextButton")
    hitArea.Size = UDim2.new(1, 0, 4, 0)
    hitArea.Position = UDim2.new(0, 0, 0.5, -2)
    hitArea.BackgroundTransparency = 1
    hitArea.Text = ""
    hitArea.Parent = track
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = UDim2.new((config[configKey] - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local holding = false
    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -7, 0.5, -7)
        local val = math.floor(min + (pos * (max - min)))
        config[configKey] = val
        valueLabel.Text = tostring(val)
        if callback then callback(val) end
    end
    
    hitArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            holding = true
            update(input)
        end
    end)
    uis.InputChanged:Connect(function(input)
        if holding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then holding = false end
    end)
end

-- Rebuilding Feature Tab Menus
createTab("Main")
createTab("ESP")
createTab("Prison")
createTab("Settings")
tabs.Main.Visible = true

createTabButton("Main")
createTabButton("ESP")
createTabButton("Prison")
createTabButton("Settings")

-- Setup Feature Sections
local mainSection = createSection(tabs.Main, "Movement")
createToggle(mainSection, "Fly", "Flying")
createSlider(mainSection, "Fly Speed", "FlySpeed", 16, 250)
createToggle(mainSection, "Speed Hack", "SpeedHack", function(state)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = state and config.HackSpeed or 16 end
end)
createSlider(mainSection, "Walk Speed", "HackSpeed", 16, 150, function(val)
    if config.SpeedHack then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)
createToggle(mainSection, "Noclip", "Noclip")
createToggle(mainSection, "Infinite Jump", "InfiniteJump")

local espSection = createSection(tabs.ESP, "Visuals")
createToggle(espSection, "ESP Enabled", "ESPEnabled")
createToggle(espSection, "Show Tracers", "ESPTracers")
createToggle(espSection, "Show Names", "ESPNames")
createToggle(espSection, "Rainbow Mode", "ESPRainbow")

local combatSection = createSection(tabs.Prison, "Combat")
createToggle(combatSection, "Silent Aim", "SilentAim")
createSlider(combatSection, "FOV Size", "SilentAimFOV", 50, 400)

local settingsSection = createSection(tabs.Settings, "Keybinds")

-- Smooth Transition Engine (Strictly Corner Collapsing Structure)
local function toggleUI()
    if isTweening then return end
    isTweening = true
    config.IsMinimized = not config.IsMinimized
    
    local speedInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if config.IsMinimized then
        -- Direct slide anchor manipulation into bottom right corner layout bounds
        local hideMain = tweenService:Create(mainFrame, speedInfo, {
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.new(1, -60, 1, -60)
        })
        hideMain:Play()
        hideMain.Completed:Connect(function()
            mainFrame.Visible = false
            trayBtn.Size = UDim2.fromOffset(0, 0)
            trayBtn.Visible = true
            
            local showTray = tweenService:Create(trayBtn, speedInfo, {Size = UDim2.fromOffset(baseSize, baseSize)})
            showTray:Play()
            showTray.Completed:Connect(function()
                isTweening = false
            end)
        end)
    else
        local hideTray = tweenService:Create(trayBtn, speedInfo, {Size = UDim2.fromOffset(0, 0)})
        hideTray:Play()
        hideTray.Completed:Connect(function()
            trayBtn.Visible = false
            mainFrame.Visible = true
            
            local showMain = tweenService:Create(mainFrame, speedInfo, {
                Size = UDim2.fromOffset(500, 380),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            showMain:Play()
            showMain.Completed:Connect(function()
                isTweening = false
            end)
        end)
    end
end

-- Input Mappings
minBtn.MouseButton1Click:Connect(toggleUI)
trayBtn.MouseButton1Click:Connect(toggleUI)

-- Main Frame Drag Mappings
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

uis.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if mainDragging and not config.IsMinimized then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = false
    end
end)

-- Global Keybind Processing
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if config.MenuKeybind and input.KeyCode == config.MenuKeybind then
        config.MenuOpen = not config.MenuOpen
        if config.IsMinimized then
            trayBtn.Visible = config.MenuOpen
        else
            mainFrame.Visible = config.MenuOpen
        end
    end
end)

-- Background Runtime Thread Logic
runService.RenderStepped:Connect(function()
    if config.Flying and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local move = Vector3.zero
            if uis:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
            if uis:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
            root.AssemblyLinearVelocity = move.Magnitude > 0 and (move.Unit * config.FlySpeed) or Vector3.zero
        end
    end
end)

runService.Stepped:Connect(function()
    if config.Noclip and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)
