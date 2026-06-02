task.wait(0.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Config
local Config = {
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
    FlyKeybind = nil,
    NoclipKeybind = nil,
    SpeedKeybind = nil,
    IsMinimized = false,
    MenuOpen = true,
    ActiveTab = "Main"
}

-- State
local ESPObjects = {}
local ToggleCallbacks = {}
local DroneNode = nil
local SavedPosition = nil

-- UI Setup
local Gui = Instance.new("ScreenGui")
Gui.Name = "SlimHub"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(500, 380)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = Gui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(40, 40, 50)
Stroke.Thickness = 1.5

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Cover = Instance.new("Frame")
Cover.Size = UDim2.new(1, 0, 0, 15)
Cover.Position = UDim2.new(0, 0, 1, -15)
Cover.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Cover.BorderSizePixel = 0
Cover.Parent = TopBar

Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(20, 0)
Title.BackgroundTransparency = 1
Title.Text = "SLIMHUB // PREMIUM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- ZERO INTERPOLATION DRAG (Forced Frame Lock)
local Dragging = false
local DragOffset = Vector2.zero

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        local mousePos = UIS:GetMouseLocation()
        local frameCenter = MainFrame.AbsolutePosition + (MainFrame.AbsoluteSize * 0.5)
        DragOffset = mousePos - frameCenter
    end
end)

UIS.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local currentMouse = UIS:GetMouseLocation()
        MainFrame.Position = UDim2.fromOffset(currentMouse.X - DragOffset.X, currentMouse.Y - DragOffset.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -50)
Sidebar.Position = UDim2.fromOffset(0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.Padding = UDim.new(0, 4)

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -145, 1, -65)
ContentArea.Position = UDim2.fromOffset(140, 60)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Minimize Button Functionality
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.fromOffset(30, 30)
MinBtn.Position = UDim2.new(1, -45, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Parent = TopBar

Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

local MinimizeCircle = Instance.new("Frame")
MinimizeCircle.Name = "MinimizeCircle"
MinimizeCircle.Size = UDim2.fromOffset(20, 20)
MinimizeCircle.Position = UDim2.new(1, -25, 1, -25)
MinimizeCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
MinimizeCircle.BorderSizePixel = 0
MinimizeCircle.Visible = false
MinimizeCircle.Parent = Gui

Instance.new("UICorner", MinimizeCircle).CornerRadius = UDim.new(1, 0)

local MinimizeLabel = Instance.new("TextLabel")
MinimizeLabel.Name = "MinimizeLabel"
MinimizeLabel.Size = UDim2.new(1, 0, 1, 0)
MinimizeLabel.BackgroundTransparency = 1
MinimizeLabel.Text = "S"
MinimizeLabel.Font = Enum.Font.GothamBold
MinimizeLabel.TextSize = 14
MinimizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeLabel.TextXAlignment = Enum.TextXAlignment.Center
MinimizeLabel.TextYAlignment = Enum.TextYAlignment.Center
MinimizeLabel.Parent = MinimizeCircle

MinBtn.MouseButton1Click:Connect(function()
    Config.IsMinimized = not Config.IsMinimized
    if Config.IsMinimized then
        -- Animate main frame to bottom right corner
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(MainFrame, tweenInfo, {
            Position = UDim2.new(1, -MainFrame.Size.X.Offset, 1, -MainFrame.Size.Y.Offset)
        })
        tween:Play()
        
        -- Hide main frame and show minimize circle
        MainFrame.Visible = false
        MinimizeCircle.Visible = true
    else
        -- Animate minimize circle back to main frame position
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(MinimizeCircle, tweenInfo, {
            Position = UDim2.new(1, -45, 0.5, -15)
        })
        tween:Play()
        
        -- Show main frame and hide minimize circle
        wait(0.5)
        MainFrame.Visible = true
        MinimizeCircle.Visible = false
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    end
end)

MinimizeCircle.MouseButton1Click:Connect(function()
    Config.IsMinimized = false
    -- Animate minimize circle back to main frame position
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(MinimizeCircle, tweenInfo, {
        Position = UDim2.new(1, -45, 0.5, -15)
    })
    tween:Play()
    
    -- Show main frame and hide minimize circle
    wait(0.5)
    MainFrame.Visible = true
    MinimizeCircle.Visible = false
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
end)

-- Tab Generator
local Tabs = {}
local function CreateTab(name)
    local Tab = Instance.new("ScrollingFrame")
    Tab.Size = UDim2.fromScale(1, 1)
    Tab.BackgroundTransparency = 1
    Tab.CanvasSize = UDim2.fromScale(0, 1.4)
    Tab.ScrollBarThickness = 3
    Tab.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
    Tab.Visible = false
    Tab.Parent = ContentArea
    
    local Layout = Instance.new("UIListLayout", Tab)
    Layout.Padding = UDim.new(0, 8)
    
    Tabs[name] = Tab
    return Tab
end

CreateTab("Main")
CreateTab("ESP")
CreateTab("Prison")
CreateTab("Settings")

Tabs.Main.Visible = true

-- Tab Buttons
local TabButtons = {}
local function CreateTabButton(name)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.Position = UDim2.fromOffset(5, 0)
    Btn.BackgroundColor3 = name == "Main" and Color3.fromRGB(28, 28, 36) or Color3.fromRGB(15, 15, 19)
    Btn.Text = ""
    Btn.Parent = Sidebar
    
    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 10)
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0.5, 0)
    Indicator.Position = UDim2.fromOffset(8, 0.25)
    Indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Indicator.BorderSizePixel = 0
    Indicator.Visible = name == "Main"
    Indicator.Parent = Btn
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.fromOffset(20, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name:upper()
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextColor3 = name == "Main" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Btn
    
    TabButtons[name] = {Btn = Btn, Indicator = Indicator, Label = Label}
    
    Btn.MouseButton1Click:Connect(function()
        Config.ActiveTab = name
        
        for n, t in pairs(Tabs) do
            t.Visible = n == name
        end
        
        for n, data in pairs(TabButtons) do
            local active = n == name
            data.Indicator.Visible = active
            data.Label.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
            data.Btn.BackgroundColor3 = active and Color3.fromRGB(28, 28, 36) or Color3.fromRGB(15, 15, 19)
        end
    end)
end

CreateTabButton("Main")
CreateTabButton("ESP")
CreateTabButton("Prison")
CreateTabButton("Settings")

-- Section Framework
local function CreateSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -10, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Section.BorderSizePixel = 0
    Section.Parent = parent
    
    Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", Section)
    Stroke.Color = Color3.fromRGB(35, 35, 45)
    Stroke.Thickness = 1
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 28)
    TitleLabel.Position = UDim2.fromOffset(15, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title:upper()
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 11
    TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Section
    
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, -30, 0, 1)
    Divider.Position = UDim2.fromOffset(15, 32)
    Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Divider.BorderSizePixel = 0
    Divider.Parent = Section
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.Position = UDim2.fromOffset(0, 42)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.BackgroundTransparency = 1
    Content.Parent = Section
    
    local List = Instance.new("UIListLayout", Content)
    List.Padding = UDim.new(0, 6)
    
    local Pad = Instance.new("UIPadding", Content)
    Pad.PaddingLeft = UDim.new(0, 15)
    Pad.PaddingRight = UDim.new(0, 15)
    Pad.PaddingBottom = UDim.new(0, 15)
    
    return Content
end

local function CreateToggle(parent, text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 36)
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
    ToggleBtn.Size = UDim2.fromOffset(48, 24)
    ToggleBtn.Position = UDim2.new(1, -48, 0.5, -12)
    ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 45)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Row
    
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(18, 18)
    Knob.Position = Config[configKey] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBtn
    
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    
    local function Update(state)
        Config[configKey] = state
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 45)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
        if callback then callback(state) end
    end
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Update(not Config[configKey])
    end)
    
    ToggleCallbacks[configKey] = Update
end

local function CreateSlider(parent, text, configKey, min, max, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 50)
    Row.BackgroundTransparency = 1
    Row.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0, 22)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.fromOffset(45, 22)
    ValueLabel.Position = UDim2.new(1, -45, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Config[configKey])
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 13
    ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Row
    
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 5)
    Track.Position = UDim2.new(0, 0, 0, 32)
    Track.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Track.BorderSizePixel = 0
    Track.Parent = Row
    
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Fill.BorderSizePixel = 0
    Fill.Parent =
