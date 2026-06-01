task.wait(0.5)

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // UTILITY FUNCTIONS
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function Tween(obj, info, props)
    local tween = TweenService:Create(obj, TweenInfo.new(unpack(info)), props)
    tween:Play()
    return tween
end

local function CreateRipple(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.fromScale(0, 0)
    ripple.Position = UDim2.fromOffset(x - button.AbsolutePosition.X, y - button.AbsolutePosition.Y)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.Parent = button
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(ripple, {0.5}, {Size = UDim2.fromOffset(maxSize, maxSize), BackgroundTransparency = 1})
    task.delay(0.5, function() ripple:Destroy() end)
end

-- // CONFIGURATION
local Config = {
    -- Features
    Flying = false,
    Noclip = false,
    SpeedHack = false,
    InfiniteJump = false,
    ClickTP = false,
    Invisible = false,
    
    -- ESP
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPTracers = true,
    ESPRainbow = false,
    ESPHealth = true,
    ESPDistance = false,
    ESPMaxDistance = 1000,
    
    -- Prison Life
    SilentAim = false,
    SilentAimFOV = 150,
    SilentAimTeamCheck = true,
    SilentAimWallCheck = false,
    SilentAimHitbox = "Head",
    SilentAimSmoothness = 0,
    
    -- Values
    FlySpeed = 50,
    NormalSpeed = 16,
    HackSpeed = 100,
    DroneSpeed = 45,
    
    -- Keybinds
    MenuKeybind = Enum.KeyCode.RightShift,
    
    -- UI State
    IsMinimized = false,
    MenuOpen = true,
    ActiveTab = "Main"
}

-- // CACHE
local ESPObjects = {}
local DroneNode = nil
local SavedPosition = nil
local RainbowHue = 0
local ToggleCallbacks = {}
local PrisonLifeHooks = {}

-- // UI CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SlimHubV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CoreGui

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainContainer"
MainFrame.Size = UDim2.fromOffset(550, 400)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Glass effect background
local Glass = Instance.new("Frame")
Glass.Size = UDim2.fromScale(1, 1)
Glass.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Glass.BackgroundTransparency = 0.1
Glass.BorderSizePixel = 0
Glass.Parent = MainFrame

-- Gradient overlay
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 210))
})
Gradient.Rotation = 90
Gradient.Parent = Glass

-- Corner radius
local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 16)

-- Stroke
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(40, 40, 50)
Stroke.Thickness = 1.5

-- Glow effect
local Glow = Instance.new("ImageLabel")
Glow.Name = "Glow"
Glow.Size = UDim2.fromOffset(600, 600)
Glow.Position = UDim2.fromOffset(-25, -100)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://8992230677"
Glow.ImageColor3 = Color3.fromRGB(0, 255, 150)
Glow.ImageTransparency = 0.95
Glow.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 55)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 16)

-- Cover bottom corners
local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 20)
TopCover.Position = UDim2.new(0, 0, 1, -20)
TopCover.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

-- Title with icon
local TitleContainer = Instance.new("Frame")
TitleContainer.Size = UDim2.new(1, -120, 1, 0)
TitleContainer.Position = UDim2.fromOffset(20, 0)
TitleContainer.BackgroundTransparency = 1
TitleContainer.Parent = TopBar

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.fromOffset(24, 24)
TitleIcon.Position = UDim2.fromOffset(0, 15)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "◆"
TitleIcon.Font = Enum.Font.GothamBold
TitleIcon.TextSize = 20
TitleIcon.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleIcon.Parent = TitleContainer

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -30, 1, 0)
TitleText.Position = UDim2.fromOffset(30, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "SLIMHUB"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 18
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleContainer

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -30, 0, 20)
Subtitle.Position = UDim2.fromOffset(30, 32)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "PREMIUM EDITION"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 10
Subtitle.TextColor3 = Color3.fromRGB(0, 255, 150)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TitleContainer

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Size = UDim2.fromOffset(32, 32)
MinimizeBtn.Position = UDim2.new(1, -45, 0.5, -16)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
MinimizeBtn.Text = "−"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Parent = TopBar

Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

-- Minimize hover effect
MinimizeBtn.MouseEnter:Connect(function()
    Tween(MinimizeBtn, {0.2}, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)})
end)
MinimizeBtn.MouseLeave:Connect(function()
    Tween(MinimizeBtn, {0.2}, {BackgroundColor3 = Color3.fromRGB(28, 28, 36)})
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -55)
Sidebar.Position = UDim2.fromOffset(0, 55)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "Content"
ContentArea.Size = UDim2.new(1, -155, 1, -70)
ContentArea.Position = UDim2.fromOffset(150, 65)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Tab Containers
local Tabs = {}
local function CreateTab(name)
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Name = name .. "Tab"
    TabFrame.Size = UDim2.fromScale(1, 1)
    TabFrame.BackgroundTransparency = 1
    TabFrame.CanvasSize = UDim2.fromScale(0, 1.5)
    TabFrame.ScrollBarThickness = 3
    TabFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    TabFrame.Visible = false
    TabFrame.Parent = ContentArea
    
    local Layout = Instance.new("UIListLayout", TabFrame)
    Layout.Padding = UDim.new(0, 8)
    
    Tabs[name] = TabFrame
    return TabFrame
end

CreateTab("Main")
CreateTab("ESP")
CreateTab("PrisonLife")
CreateTab("Settings")

Tabs.Main.Visible = true

-- Tab Button Creation
local TabButtons = {}
local function CreateTabButton(name, icon)
    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Btn"
    Btn.Size = UDim2.new(1, -10, 0, 44)
    Btn.Position = UDim2.fromOffset(5, 0)
    Btn.BackgroundColor3 = name == "Main" and Color3.fromRGB(28, 28, 36) or Color3.fromRGB(16, 16, 20)
    Btn.Text = ""
    Btn.LayoutOrder = #TabButtons + 1
    Btn.Parent = Sidebar
    
    local BtnCorner = Instance.new("UICorner", Btn)
    BtnCorner.CornerRadius = UDim.new(0, 10)
    
    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 3, 0.6, 0)
    Indicator.Position = UDim2.fromOffset(8, 0.2)
    Indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Indicator.BorderSizePixel = 0
    Indicator.Visible = name == "Main"
    Indicator.Parent = Btn
    
    local IndicatorCorner = Instance.new("UICorner", Indicator)
    IndicatorCorner.CornerRadius = UDim.new(0, 2)
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.fromOffset(20, 20)
    IconLabel.Position = UDim2.fromOffset(18, 12)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 14
    IconLabel.TextColor3 = name == "Main" and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(140, 140, 150)
    IconLabel.Parent = Btn
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -45, 1, 0)
    TextLabel.Position = UDim2.fromOffset(45, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = name:upper()
    TextLabel.Font = Enum.Font.GothamSemibold
    TextLabel.TextSize = 12
    TextLabel.TextColor3 = name == "Main" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = Btn
    
    TabButtons[name] = {Button = Btn, Indicator = Indicator, Icon = IconLabel, Text = TextLabel}
    
    Btn.MouseButton1Click:Connect(function()
        Config.ActiveTab = name
        
        for tabName, tab in pairs(Tabs) do
            tab.Visible = tabName == name
        end
        
        for btnName, btnData in pairs(TabButtons) do
            local isActive = btnName == name
            btnData.Indicator.Visible = isActive
            Tween(btnData.Icon, {0.2}, {TextColor3 = isActive and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(140, 140, 150)})
            Tween(btnData.Text, {0.2}, {TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)})
            Tween(btnData.Button, {0.2}, {BackgroundColor3 = isActive and Color3.fromRGB(28, 28, 36) or Color3.fromRGB(16, 16, 20)})
        end
    end)
    
    Btn.MouseEnter:Connect(function()
        if name ~= Config.ActiveTab then
            Tween(Btn, {0.2}, {BackgroundColor3 = Color3.fromRGB(22, 22, 28)})
        end
    end)
    
    Btn.MouseLeave:Connect(function()
        if name ~= Config.ActiveTab then
            Tween(Btn, {0.2}, {BackgroundColor3 = Color3.fromRGB(16, 16, 20)})
        end
    end)
end

CreateTabButton("Main", "⚡")
CreateTabButton("ESP", "👁")
CreateTabButton("PrisonLife", "🎯")
CreateTabButton("Settings", "⚙")

-- // UI COMPONENTS

local function CreateSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -10, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Section.BorderSizePixel = 0
    Section.Parent = parent
    
    local SectionCorner = Instance.new("UICorner", Section)
    SectionCorner.CornerRadius = UDim.new(0, 12)
    
    local SectionStroke = Instance.new("UIStroke", Section)
    SectionStroke.Color = Color3.fromRGB(35, 35, 45)
    SectionStroke.Thickness = 1
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 30)
    TitleLabel.Position = UDim2.fromOffset(15, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title:upper()
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 11
    TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Section
    
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, -30, 0, 1)
    Divider.Position = UDim2.fromOffset(15, 35)
    Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Divider.BorderSizePixel = 0
    Divider.Parent = Section
    
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.Position = UDim2.fromOffset(0, 45)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.BackgroundTransparency = 1
    Content.Parent = Section
    
    local ContentLayout = Instance.new("UIListLayout", Content)
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local Padding = Instance.new("UIPadding", Content)
    Padding.PaddingLeft = UDim.new(0, 15)
    Padding.PaddingRight = UDim.new(0, 15)
    Padding.PaddingBottom = UDim.new(0, 15)
    
    return Content
end

local function CreateToggle(parent, text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 40)
    Row.BackgroundTransparency = 1
    Row.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.fromOffset(50, 26)
    ToggleBtn.Position = UDim2.new(1, -50, 0.5, -13)
    ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 45)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Row
    
    local ToggleCorner = Instance.new("UICorner", ToggleBtn)
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(20, 20)
    Knob.Position = Config[configKey] and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBtn
    
    local KnobCorner = Instance.new("UICorner", Knob)
    KnobCorner.CornerRadius = UDim.new(1, 0)
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.fromOffset(30, 30)
    Shadow.Position = UDim2.fromOffset(-5, -5)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://13131880415"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.Parent = Knob
    
    local function UpdateState(state)
        Config[configKey] = state
        Tween(ToggleBtn, {0.25, Enum.EasingStyle.Quart}, {BackgroundColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 45)})
        Tween(Knob, {0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Position = state and UDim2.new(1, -24, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)})
        if callback then callback(state) end
    end
    
    ToggleBtn.MouseButton1Click:Connect(function()
        UpdateState(not Config[configKey])
    end)
    
    ToggleCallbacks[configKey] = UpdateState
    return UpdateState
end

local function CreateSlider(parent, text, configKey, min, max, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 55)
    Row.BackgroundTransparency = 1
    Row.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.fromOffset(50, 25)
    ValueLabel.Position = UDim2.new(1, -50, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Config[configKey])
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 13
    ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row
    
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 6)
    Track.Position = UDim2.new(0, 0, 0, 35)
    Track.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Track.BorderSizePixel = 0
    Track.Parent = Row
    
    local TrackCorner = Instance.new("UICorner", Track)
    TrackCorner.CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    local FillCorner = Instance.new("UICorner", Fill)
    FillCorner.CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(16, 16)
    Knob.Position = UDim2.new((Config[configKey] - min) / (max - min), -8, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    
    local KnobCorner = Instance.new("UICorner", Knob)
    KnobCorner.CornerRadius = UDim.new(1, 0)
    
    local Glow = Instance.new("ImageLabel")
    Glow.Size = UDim2.fromOffset(30, 30)
    Glow.Position = UDim2.fromOffset(-7, -7)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://13131880415"
    Glow.ImageColor3 = Color3.fromRGB(0, 255, 150)
    Glow.ImageTransparency = 0.8
    Glow.Parent = Knob
    
    local Dragging = false
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Knob.Position = UDim2.new(pos, -8, 0.5, -8)
        local value = math.floor(min + (pos * (max - min)))
        Config[configKey] = value
        ValueLabel.Text = tostring(value)
        if callback then callback(value) end
    end
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
end

local function CreateDropdown(parent, text, configKey, options, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 45)
    Row.BackgroundTransparency = 1
    Row.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.fromOffset(140, 32)
    DropdownBtn.Position = UDim2.new(1, -140, 0.5, -16)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    DropdownBtn.Text = Config[configKey]:upper()
    DropdownBtn.Font = Enum.Font.GothamSemibold
    DropdownBtn.TextSize = 11
    DropdownBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    DropdownBtn.Parent = Row
    
    local DropdownCorner = Instance.new("UICorner", DropdownBtn)
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    
    local DropdownStroke = Instance.new("UIStroke", DropdownBtn)
    DropdownStroke.Color = Color3.fromRGB(45, 45, 55)
    DropdownStroke.Thickness = 1
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.fromOffset(20, 20)
    Arrow.Position = UDim2.new(1, -25, 0, 6)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.Font = Enum.Font.Gotham
    Arrow.TextSize = 10
    Arrow.TextColor3 = Color3.fromRGB(140, 140, 150)
    Arrow.Parent = DropdownBtn
    
    DropdownBtn.MouseButton1Click:Connect(function()
        local currentIndex = table.find(options, Config[configKey]) or 1
        local nextIndex = currentIndex % #options + 1
        Config[configKey] = options[nextIndex]
        DropdownBtn.Text = Config[configKey]:upper()
        if callback then callback(Config[configKey]) end
    end)
end

-- // BUILD MAIN TAB
local MainSection = CreateSection(Tabs.Main, "Movement")
CreateToggle(MainSection, "Fly", "Flying")
CreateSlider(MainSection, "Fly Speed", "FlySpeed", 16, 250)
CreateToggle(MainSection, "Speed Hack", "SpeedHack", function(state)
    local char = GetCharacter()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = state and Config.HackSpeed or Config.NormalSpeed end
end)
CreateSlider(MainSection, "Walk Speed", "HackSpeed", 16, 150, function(val)
    if Config.SpeedHack then
        local char = GetCharacter()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)
CreateToggle(MainSection, "Noclip", "Noclip")
CreateToggle(MainSection, "Infinite Jump", "InfiniteJump")
CreateToggle(MainSection, "Click Teleport (Ctrl+Click)", "ClickTP")

-- // BUILD ESP TAB
local ESPSection = CreateSection(Tabs.ESP, "Visuals")
CreateToggle(ESPSection, "ESP Master", "ESPEnabled")
CreateToggle(ESPSection, "Show Boxes", "ESPBoxes")
CreateToggle(ESPSection, "Show Names", "ESPNames")
CreateToggle(ESPSection, "Show Tracers", "ESPTracers")
CreateToggle(ESPSection, "Show Health", "ESPHealth")
CreateToggle(ESPSection, "Rainbow Mode", "ESPRainbow")
CreateSlider(ESPSection, "Max Distance", "ESPMaxDistance", 100, 2000)

-- // BUILD PRISON LIFE TAB
local PLSection = CreateSection(Tabs.PrisonLife, "Combat")
CreateToggle(PLSection, "Silent Aim", "SilentAim")
CreateSlider(PLSection, "FOV Size", "SilentAimFOV", 50, 400)
CreateSlider(PLSection, "Smoothness", "SilentAimSmoothness", 0, 100)
CreateToggle(PLSection, "Team Check", "SilentAimTeamCheck")
CreateToggle(PLSection, "Wall Check", "SilentAimWallCheck")
CreateDropdown(PLSection, "Target Hitbox", "SilentAimHitbox", {"Head", "Torso", "HumanoidRootPart"})

-- // BUILD SETTINGS TAB
local SettingsSection = CreateSection(Tabs.Settings, "Configuration")
CreateSlider(SettingsSection, "Menu Keybind (RightShift)", "MenuKeybind", 1, 1) -- Placeholder

-- // FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Filled = false
FOVCircle.NumSides = 64

-- // ESP SYSTEM (BEAM-BASED FOR SMOOTHNESS)
local function CreateESPBeam()
    local attachment0 = Instance.new("Attachment")
    local attachment1 = Instance.new("Attachment")
    
    local beam = Instance.new("Beam")
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150))
    beam.Width0 = 0.05
    beam.Width1 = 0.05
    beam.FaceCamera = true
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Parent = attachment0
    
    return {
        Beam = beam,
        Attachment0 = attachment0,
        Attachment1 = attachment1,
        Box = nil,
        Name = nil,
        HealthBar = nil
    }
end

local function SetupESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ESPObjects[player] then
            ESPObjects[player] = {
                Beams = {},
                Billboard = nil,
                Character = nil
            }
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        ESPObjects[player] = {
            Beams = {},
            Billboard = nil,
            Character = nil
        }
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, data in pairs(ESPObjects[player].Beams) do
            if data.Attachment0 then data.Attachment0:Destroy() end
            if data.Attachment1 then data.Attachment1:Destroy() end
        end
        if ESPObjects[player].Billboard then
            ESPObjects[player].Billboard:Destroy()
        end
        ESPObjects[player] = nil
    end
end)

-- // SILENT AIM FUNCTIONS
local function GetClosestPlayer()
    local mousePos = UserInputService:GetMouseLocation()
    local closest = nil
    local closestDist = Config.SilentAimFOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Config.SilentAimTeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local targetPart = player.Character:FindFirstChild(Config.SilentAimHitbox) 
                or player.Character:FindFirstChild("HumanoidRootPart")
            
            if targetPart then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < closestDist then
                            if Config.SilentAimWallCheck then
                                local raycastParams = RaycastParams.new()
                                raycastParams.FilterDescendantsInstances = {GetCharacter(), player.Character}
                                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                                
                                local direction = (targetPart.Position - Camera.CFrame.Position).Unit
                                local result = workspace:Raycast(Camera.CFrame.Position, direction * 1000, raycastParams)
                                
                                if result then continue end
                            end
                            
                            closestDist = dist
                            closest = targetPart
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

-- Hook Prison Life remotes
local function HookPrisonLife()
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("shoot") or name:find("fire") or name:find("gun") or name:find("bullet") then
                local oldFire = obj.FireServer
                PrisonLifeHooks[obj] = oldFire
                
                obj.FireServer = function(self, ...)
                    local args = {...}
                    
                    if Config.SilentAim and #args >= 2 then
                        local target = GetClosestPlayer()
                        if target then
                            -- Modify raycast direction to hit target
                            local cameraPos = Camera.CFrame.Position
                            local targetPos = target.Position
                            
                            if Config.SilentAimSmoothness > 0 then
                                local currentDir = Camera.CFrame.LookVector
                                local targetDir = (targetPos - cameraPos).Unit
                                local smoothedDir = currentDir:Lerp(targetDir, Config.SilentAimSmoothness / 100)
                                args[2] = cameraPos + (smoothedDir * 1000)
                            else
                                args[2] = targetPos
                            end
                        end
                    end
                    
                    return oldFire(self, unpack(args))
                end
            end
        end
    end
end

-- // FEATURE LOOPS

-- Fly
RunService.RenderStepped:Connect(function()
    if Config.Flying then
        local char = GetCharacter()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local move = Vector3.zero
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
            
            if move.Magnitude > 0 then
                root.AssemblyLinearVelocity = move.Unit * Config.FlySpeed
            else
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if Config.Noclip then
        local char = GetCharacter()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Config.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        local char = GetCharacter()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Click TP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Config.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 
        and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        
        local char = GetCharacter()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local mousePos = UserInputService:GetMouseLocation()
            local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Exclude
            
            local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
            if result then
                root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- ESP Loop
RunService.RenderStepped:Connect(function(deltaTime)
    RainbowHue = (RainbowHue + deltaTime * 0.5) % 1
    local rainbowColor = Color3.fromHSV(RainbowHue, 1, 1)
    local espColor = Config.ESPRainbow and rainbowColor or Color3.fromRGB(0, 255, 150)
    
    -- Update FOV Circle
    FOVCircle.Visible = Config.SilentAim
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Config.SilentAimFOV
    FOVCircle.Color = espColor
    
    -- Update ESP
    for player, data in pairs(ESPObjects) do
        if Config.ESPEnabled and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if root and humanoid and humanoid.Health > 0 then
                local distance = (root.Position - Camera.CFrame.Position).Magnitude
                if distance <= Config.ESPMaxDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen then
                        -- Setup beams if not exists
                        if not data.Beams.Tracer then
                            data.Beams.Tracer = CreateESPBeam()
                        end
                        
                        -- Update tracer
                        if Config.ESPTracers then
                            local localRoot = GetCharacter():FindFirstChild("HumanoidRootPart")
                            if localRoot then
                                data.Beams.Tracer.Attachment0.Parent = localRoot
                                data.Beams.Tracer.Attachment1.Parent = root
                                data.Beams.Tracer.Attachment0.WorldPosition = Camera.CFrame.Position
                                data.Beams.Tracer.Attachment1.WorldPosition = root.Position
                                data.Beams.Tracer.Beam.Color = ColorSequence.new(espColor)
                                data.Beams.Tracer.Beam.Enabled = true
                            end
                        elseif data.Beams.Tracer then
                            data.Beams.Tracer.Beam.Enabled = false
                        end
                        
                        -- Billboard for name/health
                        if Config.ESPNames or Config.ESPHealth then
                            if not data.Billboard or data.Billboard.Parent == nil then
                                data.Billboard = Instance.new("BillboardGui")
                                data.Billboard.Size = UDim2.fromOffset(150, 50)
                                data.Billboard.AlwaysOnTop = true
                                data.Billboard.Parent = root
                                
                                local nameLabel = Instance.new("TextLabel")
                                nameLabel.Name = "Name"
                                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                                nameLabel.BackgroundTransparency = 1
                                nameLabel.Font = Enum.Font.GothamBold
                                nameLabel.TextSize = 12
                                nameLabel.TextColor3 = espColor
                                nameLabel.Parent = data.Billboard
                                
                                local healthBar = Instance.new("Frame")
                                healthBar.Name = "HealthBar"
                                healthBar.Size = UDim2.new(0.8, 0, 0, 4)
                                healthBar.Position = UDim2.new(0.1, 0, 0.7, 0)
                                healthBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                                healthBar.BorderSizePixel = 0
                                healthBar.Parent = data.Billboard
                                
                                local healthFill = Instance.new("Frame")
                                healthFill.Name = "Fill"
                                healthFill.Size = UDim2.new(1, 0, 1, 0)
                                healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                                healthFill.BorderSizePixel = 0
                                healthFill.Parent = healthBar
                            end
                            
                            data.Billboard.Enabled = true
                            local nameLabel = data.Billboard:FindFirstChild("Name")
                            local healthBar = data.Billboard:FindFirstChild("HealthBar")
                            
                            if nameLabel then
                                nameLabel.Visible = Config.ESPNames
                                nameLabel.Text = player.Name:upper()
                                nameLabel.TextColor3 = espColor
                            end
                            
                            if healthBar then
                                healthBar.Visible = Config.ESPHealth
                                local fill = healthBar:FindFirstChild("Fill")
                                if fill then
                                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                                    fill.Size = UDim2.new(healthPercent, 0, 1, 0)
                                    fill.BackgroundColor3 = healthPercent > 0.5 and Color3.fromRGB(0, 255, 100) 
                                        or healthPercent > 0.25 and Color3.fromRGB(255, 255, 0) 
                                        or Color3.fromRGB(255, 0, 0)
                                end
                            end
                        elseif data.Billboard then
                            data.Billboard.Enabled = false
                        end
                    end
                end
            end
        else
            -- Hide ESP
            for _, beamData in pairs(data.Beams) do
                if beamData.Beam then beamData.Beam.Enabled = false end
            end
            if data.Billboard then
                data.Billboard.Enabled = false
            end
        end
    end
end)

-- // MINIMIZE SYSTEM (Preserved & Enhanced)
local MinCircle = Instance.new("TextButton")
MinCircle.Name = "MinimizedCircle"
MinCircle.Size = UDim2.fromOffset(60, 60)
MinCircle.Position = UDim2.new(1, -80, 1, -80)
MinCircle.AnchorPoint = Vector2.new(0.5, 0.5)
MinCircle.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MinCircle.Text = "S"
MinCircle.Font = Enum.Font.GothamBold
MinCircle.TextSize = 24
MinCircle.TextColor3 = Color3.fromRGB(0, 255, 150)
MinCircle.Visible = false
MinCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner", MinCircle)
CircleCorner.CornerRadius = UDim.new(1, 0)

local CircleStroke = Instance.new("UIStroke", MinCircle)
CircleStroke.Color = Color3.fromRGB(0, 255, 150)
CircleStroke.Thickness = 2

local CircleGlow = Instance.new("ImageLabel")
CircleGlow.Size = UDim2.fromOffset(100, 100)
CircleGlow.Position = UDim2.fromOffset(-20, -20)
CircleGlow.BackgroundTransparency = 1
CircleGlow.Image = "rbxassetid://8992230677"
CircleGlow.ImageColor3 = Color3.fromRGB(0, 255, 150)
CircleGlow.ImageTransparency = 0.7
CircleGlow.Parent = MinCircle

-- Hover effects
MinCircle.MouseEnter:Connect(function()
    Tween(MinCircle, {0.3, Enum.EasingStyle.Back}, {Size = UDim2.fromOffset(70, 70)})
    Tween(CircleStroke, {0.3}, {Thickness = 3})
end)

MinCircle.MouseLeave:Connect(function()
    Tween(MinCircle, {0.3, Enum.EasingStyle.Back}, {Size = UDim2.fromOffset(60, 60)})
    Tween(CircleStroke, {0.3}, {Thickness = 2})
end)

-- Minimize animation
MinimizeBtn.MouseButton1Click:Connect(function()
    Config.IsMinimized = true
    
    local targetPos = MinCircle.AbsolutePosition + Vector2.new(30, 30)
    local collapseTween = Tween(MainFrame, {0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In}, {
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(targetPos.X, targetPos.Y)
    })
    
    collapseTween.Completed:Wait()
    MainFrame.Visible = false
    
    MinCircle.Visible = true
    MinCircle.Size = UDim2.fromOffset(0, 0)
    Tween(MinCircle, {0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out}, {
        Size = UDim2.fromOffset(60, 60)
    })
end)

-- Restore animation
MinCircle.MouseButton1Click:Connect(function()
    Config.IsMinimized = false
    
    Tween(MinCircle, {0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In}, {
        Size = UDim2.fromOffset(0, 0)
    }).Completed:Wait()
    
    MinCircle.Visible = false
    MainFrame.Visible = true
    
    Tween(MainFrame, {0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
        Size = UDim2.fromOffset(550, 400),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
end)

-- // DRAGGING
local Dragging, DragStart, StartPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if Dragging then
            local delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(
                StartPos.X.Scale, StartPos.X.Offset + delta.X,
                StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- // KEYBINDS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Config.MenuKeybind then
        if Config.IsMinimized then
            MinCircle.MouseButton1Click:Fire()
        else
            Config.MenuOpen = not Config.MenuOpen
            MainFrame.Visible = Config.MenuOpen
        end
    end
end)

-- // INITIALIZATION
SetupESP()
HookPrisonLife()

-- Initial animation
MainFrame.Size = UDim2.fromOffset(0, 0)
Tween(MainFrame, {0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
    Size = UDim2.fromOffset(550, 400)
})

print("SlimHub V2 Loaded | Premium Edition")
