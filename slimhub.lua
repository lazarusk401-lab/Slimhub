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
local Dragging = false
local DragOffset = Vector2.zero
local TargetPosition = nil
local DroneNode = nil
local SavedPosition = nil

-- UI
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

-- Dragging Functionality Fixed (Handles AnchorPoint correctly)
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        local mousePos = UIS:GetMouseLocation()
        DragOffset = mousePos - Vector2.new(MainFrame.AbsolutePosition.X + (MainFrame.AbsoluteSize.X * MainFrame.AnchorPoint.X), MainFrame.AbsolutePosition.Y + (MainFrame.AbsoluteSize.Y * MainFrame.AnchorPoint.Y))
        
        local connection
        connection = UIS.InputChanged:Connect(function(changedInput)
            if Dragging and (changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch) then
                local currentMousePos = UIS:GetMouseLocation()
                TargetPosition = UDim2.new(0, currentMousePos.X - DragOffset.X, 0, currentMousePos.Y - DragOffset.Y)
            else
                connection:Disconnect()
            end
        end)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

-- Minimize Button
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

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -50)
Sidebar.Position = UDim2.fromOffset(0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.Padding = UDim.new(0, 4)

-- Content
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -145, 1, -65)
ContentArea.Position = UDim2.fromOffset(140, 60)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Tabs
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

-- Components
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

-- SLIDER WITH HOVER ANIMATIONS
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
    Fill.Parent = Track
    
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local HitArea = Instance.new("TextButton")
    HitArea.Name = "HitArea"
    HitArea.Size = UDim2.new(1, 0, 4, 0)
    HitArea.Position = UDim2.new(0, 0, 0.5, -2)
    HitArea.BackgroundTransparency = 1
    HitArea.Text = ""
    HitArea.Parent = Track
    
    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.Position = UDim2.new((Config[configKey] - min) / (max - min), -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    
    local Glow = Instance.new("Frame")
    Glow.Name = "Glow"
    Glow.Size = UDim2.fromOffset(0, 0)
    Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Glow.BackgroundTransparency = 0.8
    Glow.BorderSizePixel = 0
    Glow.Visible = false
    Glow.Parent = Knob
    
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(1, 0)
    
    local Holding = false
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Knob.Position = UDim2.new(pos, -7, 0.5, -7)
        local val = math.floor(min + (pos * (max - min)))
        Config[configKey] = val
        ValueLabel.Text = tostring(val)
        if callback then callback(val) end
    end
    
    Knob.MouseEnter:Connect(function()
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(18, 18)}):Play()
        Glow.Visible = true
        TweenService:Create(Glow, TweenInfo.new(0.2), {Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 0.6}):Play()
    end)
    
    Knob.MouseLeave:Connect(function()
        if not Holding then
            TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(14, 14)}):Play()
            TweenService:Create(Glow, TweenInfo.new(0.2), {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.8}):Play()
            task.delay(0.2, function()
                if not Holding then Glow.Visible = false end
            end)
        end
    end)
    
    HitArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Holding = true
            TweenService:Create(Knob, TweenInfo.new(0.15), {Size = UDim2.fromOffset(20, 20)}):Play()
            Glow.Visible = true
            TweenService:Create(Glow, TweenInfo.new(0.15), {Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 0.5}):Play()
            Update(input)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if Holding and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Holding then
            Holding = false
            TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(14, 14)}):Play()
            TweenService:Create(Glow, TweenInfo.new(0.2), {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.8}):Play()
            task.delay(0.2, function()
                Glow.Visible = false
            end)
        end
    end)
end

local function CreateKeybindButton(parent, text, configKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 40)
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
    
    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.fromOffset(120, 28)
    BindBtn.Position = UDim2.new(1, -120, 0.5, -14)
    BindBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    BindBtn.Text = Config[configKey] and Config[configKey].Name or "[NONE]"
    BindBtn.Font = Enum.Font.Code
    BindBtn.TextSize = 12
    BindBtn.TextColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(140, 140, 150)
    BindBtn.Parent = Row
    
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)
    
    local Stroke = Instance.new("UIStroke", BindBtn)
    Stroke.Color = Color3.fromRGB(45, 45, 55)
    Stroke.Thickness = 1
    
    local Listening = false
    
    BindBtn.MouseButton1Click:Connect(function()
        Listening = true
        BindBtn.Text = "[PRESS KEY]"
        BindBtn.TextColor3 = Color3.fromRGB(255, 150, 0)
    end)
    
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if not Listening or gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Listening = false
            if input.KeyCode == Enum.KeyCode.Escape then
                Config[configKey] = nil
                BindBtn.Text = "[NONE]"
                BindBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
            else
                Config[configKey] = input.KeyCode
                BindBtn.Text = input.KeyCode.Name
                BindBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
            end
            if callback then callback(Config[configKey]) end
        end
    end)
end

-- Build Main Tab
local MainSection = CreateSection(Tabs.Main, "Movement")
CreateToggle(MainSection, "Fly", "Flying")
CreateSlider(MainSection, "Fly Speed", "FlySpeed", 16, 250)
CreateToggle(MainSection, "Speed Hack", "SpeedHack", function(state)
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = state and Config.HackSpeed or 16 end
end)
CreateSlider(MainSection, "Walk Speed", "HackSpeed", 16, 150, function(val)
    if Config.SpeedHack then
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)
CreateToggle(MainSection, "Noclip", "Noclip")

CreateToggle(MainSection, "Invisibility", "Invisible", function(state)
    local character = Player.Character or Player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not root or not humanoid then return end
    
    if state then
        SavedPosition = root.CFrame
        
        DroneNode = Instance.new("Part")
        DroneNode.Name = "DroneTrackingNode"
        DroneNode.Size = Vector3.new(1, 1, 1)
        DroneNode.Transparency = 1
        DroneNode.CanCollide = false
        DroneNode.Anchored = true
        DroneNode.CFrame = SavedPosition * CFrame.new(0, 2, 0)
        DroneNode.Parent = workspace
        
        root.CFrame = SavedPosition * CFrame.new(0, -100, 0)
        task.wait(0.05)
        root.Anchored = true
        
        Camera.CameraSubject = DroneNode
        Camera.CameraType = Enum.CameraType.Custom
    else
        Camera.CameraSubject = humanoid
        Camera.CameraType = Enum.CameraType.Custom
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        
        root.Anchored = false
        if DroneNode and SavedPosition then
            root.CFrame = CFrame.new(DroneNode.Position.X, SavedPosition.Position.Y, DroneNode.Position.Z)
        end
        
        if DroneNode then 
            DroneNode:Destroy() 
            DroneNode = nil 
        end
        SavedPosition = nil
    end
end)

CreateToggle(MainSection, "Infinite Jump", "InfiniteJump")
CreateToggle(MainSection, "Click TP (Ctrl+Click)", "ClickTP")

-- Build ESP Tab
local ESPSection = CreateSection(Tabs.ESP, "Visuals")
CreateToggle(ESPSection, "ESP Enabled", "ESPEnabled")
CreateToggle(ESPSection, "Show Tracers", "ESPTracers")
CreateToggle(ESPSection, "Show Names", "ESPNames")
CreateToggle(ESPSection, "Rainbow Mode", "ESPRainbow")

-- Build Prison Tab
local PrisonSection = CreateSection(Tabs.Prison, "Combat")
CreateToggle(PrisonSection, "Silent Aim", "SilentAim")
CreateSlider(PrisonSection, "FOV Size", "SilentAimFOV", 50, 400)
CreateSlider(PrisonSection, "Smoothness", "SilentAimSmoothness", 0, 100)
CreateToggle(PrisonSection, "Team Check", "SilentAimTeamCheck")
CreateToggle(PrisonSection, "Wall Check", "SilentAimWallCheck")

local HitboxRow = Instance.new("Frame")
HitboxRow.Size = UDim2.new(1, 0, 0, 40)
HitboxRow.BackgroundTransparency = 1
HitboxRow.Parent = PrisonSection

local HitboxLabel = Instance.new("TextLabel")
HitboxLabel.Size = UDim2.new(0.5, 0, 1, 0)
HitboxLabel.BackgroundTransparency = 1
HitboxLabel.Text = "Target Hitbox"
HitboxLabel.Font = Enum.Font.Gotham
HitboxLabel.TextSize = 13
HitboxLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
HitboxLabel.TextXAlignment = Enum.TextXAlignment.Left
HitboxLabel.Parent = HitboxRow

local HitboxBtn = Instance.new("TextButton")
HitboxBtn.Size = UDim2.fromOffset(120, 28)
HitboxBtn.Position = UDim2.new(1, -120, 0.5, -14)
HitboxBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
HitboxBtn.Text = Config.SilentAimHitbox:upper()
HitboxBtn.Font = Enum.Font.GothamSemibold
HitboxBtn.TextSize = 11
HitboxBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
HitboxBtn.Parent = HitboxRow

Instance.new("UICorner", HitboxBtn).CornerRadius = UDim.new(0, 6)

HitboxBtn.MouseButton1Click:Connect(function()
    local hitboxes = {"Head", "Torso", "HumanoidRootPart"}
    local idx = table.find(hitboxes, Config.SilentAimHitbox) or 1
    local nextIdx = idx % #hitboxes + 1
    Config.SilentAimHitbox = hitboxes[nextIdx]
    HitboxBtn.Text = Config.SilentAimHitbox:upper()
end)

-- Build Settings Tab
local SettingsSection = CreateSection(Tabs.Settings, "Keybinds")
CreateKeybindButton(SettingsSection, "Menu Toggle", "MenuKeybind")
CreateKeybindButton(SettingsSection, "Fly Toggle", "FlyKeybind")
CreateKeybindButton(SettingsSection, "Noclip Toggle", "NoclipKeybind")
CreateKeybindButton(SettingsSection, "Speed Toggle", "SpeedKeybind")

-- ESP Drawing Objects
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.fromRGB(0, 255, 150)
    box.Filled = false
    box.Visible = false
    
    local name = Drawing.new("Text")
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Visible = false
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(0, 255, 150)
    tracer.Visible = false
    
    ESPObjects[player] = {Box = box, Name = name, Tracer = tracer}
end

Players.PlayerAdded:Connect(function(p)
    if p ~= Player then CreateESP(p) end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then
        ESPObjects[p].Box:Remove()
        ESPObjects[p].Name:Remove()
        ESPObjects[p].Tracer:Remove()
        ESPObjects[p] = nil
    end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= Player then CreateESP(p) end
end

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Filled = false
FOVCircle.NumSides = 64

-- Silent Aim
local function GetTarget()
    local mousePos = UIS:GetMouseLocation()
    local closest = nil
    local closestDist = Config.SilentAimFOV
    
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= Player and targetPlayer.Character then
            if Config.SilentAimTeamCheck and targetPlayer.Team == Player.Team then
                continue
            end
            
            local targetPart = targetPlayer.Character:FindFirstChild(Config.SilentAimHitbox) 
                or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetPart then
                local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < closestDist then
                            if Config.SilentAimWallCheck then
                                local params = RaycastParams.new()
                                params.FilterDescendantsInstances = {Player.Character, targetPlayer.Character}
                                params.FilterType = Enum.RaycastFilterType.Exclude
                                
                                local dir = (targetPart.Position - Camera.CFrame.Position).Unit
                                local result = workspace:Raycast(Camera.CFrame.Position, dir * 1000, params)
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

-- Hook Prison Life
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        local name = obj.Name:lower()
        if name:find("shoot") or name:find("fire") or name:find("gun") then
            local oldFire = obj.FireServer
            obj.FireServer = function(self, ...)
                local args = {...}
                if Config.SilentAim and #args >= 2 then
                    local target = GetTarget()
                    if target then
                        local camPos = Camera.CFrame.Position
                        local targetPos = target.Position
                        
                        if Config.SilentAimSmoothness > 0 then
                            local currentDir = Camera.CFrame.LookVector
                            local targetDir = (targetPos - camPos).Unit
                            local smoothedDir = currentDir:Lerp(targetDir, Config.SilentAimSmoothness / 100)
                            args[2] = camPos + (smoothedDir * 1000)
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

-- Loops
RunService.RenderStepped:Connect(function()
    -- Smooth dragging
    if Dragging and TargetPosition then
        local current = MainFrame.Position
        local target = TargetPosition
        local smooth = UDim2.new(
            current.X.Scale,
            current.X.Offset + (target.X.Offset - current.X.Offset) * 0.3,
            current.Y.Scale,
            current.Y.Offset + (target.Y.Offset - current.Y.Offset) * 0.3
        )
        MainFrame.Position = smooth
    end
    
    -- Fly
    if Config.Flying then
        local char = Player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local move = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
                
                if move.Magnitude > 0 then
                    root.AssemblyLinearVelocity = move.Unit * Config.FlySpeed
                else
                    root.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end
    end
    
    -- Drone movement for invis
    if Config.Invisible and DroneNode then
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        
        local speed = Config.SpeedHack and Config.HackSpeed or Config.DroneSpeed
        
        if move.Magnitude > 0 then
            local flatDir = Vector3.new(move.X, 0, move.Z).Unit
            local target = DroneNode.Position + (flatDir * speed * 0.016)
            if SavedPosition then
                target = Vector3.new(target.X, SavedPosition.Position.Y + 2, target.Z)
            end
            DroneNode.Position = DroneNode.Position:Lerp(target, 0.5)
        end
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip then
        local char = Player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ESP Loop
RunService.RenderStepped:Connect(function()
    local rainbowColor = Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
    local espColor = Config.ESPRainbow and rainbowColor or Color3.fromRGB(0, 255, 150)
    
    FOVCircle.Visible = Config.SilentAim
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = Config.SilentAimFOV
    FOVCircle.Color = espColor
    
    for p, drawings in pairs(ESPObjects) do
        if Config.ESPEnabled and p.Character then
            local char = p.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if root and humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local sizeY = math.abs(Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
                    local sizeX = sizeY * 0.6
                    
                    drawings.Box.Size = Vector2.new(sizeX, sizeY)
                    drawings.Box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                    drawings.Box.Color = espColor
                    drawings.Box.Visible = true
                    
                    drawings.Name.Text = p.Name
                    drawings.Name.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 15)
                    drawings.Name.Color = espColor
                    drawings.Name.Visible = Config.ESPNames
                    
                    if Config.ESPTracers then
                        local localChar = Player.Character
                        if localChar then
                            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                            if localRoot then
                                local myPos = Camera:WorldToViewportPoint(localRoot.Position)
                                drawings.Tracer.From = Vector2.new(myPos.X, myPos.Y)
                                drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
                                drawings.Tracer.Color = espColor
                                drawings.Tracer.Visible = true
                            end
                        end
                    else
                        drawings.Tracer.Visible = false
                    end
                else
                    drawings.Box.Visible = false
                    drawings.Name.Visible = false
                    drawings.Tracer.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Name.Visible = false
                drawings.Tracer.Visible = false
            end
        else
            if drawings then
                drawings.Box.Visible = false
                drawings.Name.Visible = false
                drawings.Tracer.Visible = false
            end
        end
    end
end)
