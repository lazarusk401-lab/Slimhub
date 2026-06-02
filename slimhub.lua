task.wait(0.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Config
local Config = {
    Flying = false,
    Noclip = false,
    SpeedHack = false,
    InfiniteJump = false,
    IsMinimized = false,
    MenuOpen = true,
    ActiveTab = "Main",
    MenuKeybind = Enum.KeyCode.RightShift,
    FlySpeed = 50,
    HackSpeed = 100
}

-- State
local ToggleCallbacks = {}
local MainDragging = false
local TrayDragging = false
local DragStart = nil
local StartPos = nil
local IsTweeningMin = false

-- Liquid State Settings
local LastTrayPos = Vector2.new(0,0)
local DragDistance = 0
local BaseSize = 52

-- Core GUI Setup
local Gui = Instance.new("ScreenGui")
Gui.Name = "SlimHub"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

-- ====================================================================
-- MAIN HUB UI
-- ====================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(500, 380)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = Gui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

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

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -145, 1, -65)
ContentArea.Position = UDim2.fromOffset(140, 60)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- ====================================================================
-- LIQUID TRAY FRAME (No Trails)
-- ====================================================================
local TrayBtn = Instance.new("Frame")
MainFrame.ClipsDescendants = true
TrayBtn.Name = "SlimTray"
TrayBtn.Size = UDim2.fromOffset(0, 0)
TrayBtn.Position = MainFrame.Position
TrayBtn.AnchorPoint = Vector2.new(0.5, 0.5)
TrayBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TrayBtn.Visible = false
TrayBtn.ZIndex = 10
TrayBtn.Parent = Gui

local TrayCorner = Instance.new("UICorner", TrayBtn)
TrayCorner.CornerRadius = UDim.new(1, 0)

local TrayStroke = Instance.new("UIStroke", TrayBtn)
TrayStroke.Color = Color3.fromRGB(0, 255, 150)
TrayStroke.Thickness = 2.5

local TrayLabel = Instance.new("TextLabel")
TrayLabel.Size = UDim2.new(1, 0, 1, 0)
TrayLabel.BackgroundTransparency = 1
TrayLabel.Text = "S"
TrayLabel.Font = Enum.Font.GothamBold
TrayLabel.TextSize = 22
TrayLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
TrayLabel.ZIndex = 11
TrayLabel.Parent = TrayBtn

-- Tabs & Module builders
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
Tabs.Main.Visible = true

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
end

CreateTabButton("Main")

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
    ToggleBtn.MouseButton1Click:Connect(function() Update(not Config[configKey]) end)
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
    Fill.Parent = Track
    
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local HitArea = Instance.new("TextButton")
    HitArea.Size = UDim2.new(1, 0, 4, 0)
    HitArea.Position = UDim2.new(0, 0, 0.5, -2)
    HitArea.BackgroundTransparency = 1
    HitArea.Text = ""
    HitArea.Parent = Track
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.Position = UDim2.new((Config[configKey] - min) / (max - min), -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    
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
    
    HitArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Holding = true
            Update(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if Holding and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Holding = false end
    end)
end

-- Build Layout Structure
local MainSection = CreateSection(Tabs.Main, "Movement")
CreateToggle(MainSection, "Fly", "Flying")
CreateSlider(MainSection, "Fly Speed", "FlySpeed", 16, 250)
CreateToggle(MainSection, "Noclip", "Noclip")
CreateToggle(MainSection, "Infinite Jump", "InfiniteJump")

-- ====================================================================
-- SEAMLESS TRANSITION ENGINE
-- ====================================================================
local function ToggleMinimize()
    if IsTweeningMin then return end
    IsTweeningMin = true
    
    Config.IsMinimized = not Config.IsMinimized
    
    local SpeedInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local FadeInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if Config.IsMinimized then
        local HideMain = TweenService:Create(MainFrame, FadeInfo, {Size = UDim2.fromOffset(0, 0)})
        HideMain:Play()
        
        HideMain.Completed:Connect(function()
            MainFrame.Visible = false
            
            TrayBtn.Position = MainFrame.Position
            TrayBtn.Size = UDim2.fromOffset(0, 0)
            TrayBtn.Visible = true
            
            local ShowTray = TweenService:Create(TrayBtn, SpeedInfo, {Size = UDim2.fromOffset(BaseSize, BaseSize)})
            ShowTray:Play()
            ShowTray.Completed:Connect(function()
                LastTrayPos = Vector2.new(TrayBtn.AbsolutePosition.X + (BaseSize/2), TrayBtn.AbsolutePosition.Y + (BaseSize/2))
                IsTweeningMin = false
            end)
        end)
    else
        local HideTray = TweenService:Create(TrayBtn, FadeInfo, {Size = UDim2.fromOffset(0, 0)})
        HideTray:Play()
        
        HideTray.Completed:Connect(function()
            TrayBtn.Visible = false
            
            MainFrame.Position = TrayBtn.Position
            MainFrame.Visible = true
            
            local ShowMain = TweenService:Create(MainFrame, SpeedInfo, {Size = UDim2.fromOffset(500, 380)})
            ShowMain:Play()
            ShowMain.Completed:Connect(function()
                IsTweeningMin = false
            end)
        end)
    end
end

MinBtn.MouseButton1Click:Connect(ToggleMinimize)

-- ====================================================================
-- DRAG ENGINE & INPUT HANDLING
-- ====================================================================
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MainDragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
    end
end)

TrayBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TrayDragging = true
        DragStart = input.Position
        StartPos = TrayBtn.Position
        DragDistance = 0
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if MainDragging then
            local delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        elseif TrayDragging then
            local delta = input.Position - DragStart
            DragDistance = (input.Position - DragStart).Magnitude
            TrayBtn.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if TrayDragging then
            TrayDragging = false
            -- Check drag distance to differentiate between a click vs a drag
            if DragDistance < 6 then
                ToggleMinimize()
            else
                -- Snap back to normal proportions immediately on release
                TweenService:Create(TrayBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.fromOffset(BaseSize, BaseSize)
                }):Play()
            end
        end
        MainDragging = false
    end
end)

-- Global Menu Keybind Thread
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Config.MenuKeybind and input.KeyCode == Config.MenuKeybind then
        Config.MenuOpen = not Config.MenuOpen
        if Config.IsMinimized then
            TrayBtn.Visible = Config.MenuOpen
        else
            MainFrame.Visible = Config.MenuOpen
        end
    end
end)

-- ====================================================================
-- REALTIME LIQUEFY PHYSICS PROCESSING LOOP (No Trails)
-- ====================================================================
RunService.RenderStepped:Connect(function()
    if Config.IsMinimized and TrayBtn.Visible then
        local currentCenter = Vector2.new(TrayBtn.AbsolutePosition.X + (TrayBtn.AbsoluteSize.X/2), TrayBtn.AbsolutePosition.Y + (TrayBtn.AbsoluteSize.Y/2))
        local rawVelocity = currentCenter - LastTrayPos
        local speed = rawVelocity.Magnitude
        
        if speed > 0.1 then
            -- Dynamic Vector Elastic Deformation Physics (Jelly/Liquid Stretch)
            local stretchFactor = math.clamp(1 + (speed / 35), 1, 1.5)
            local squeezeFactor = math.clamp(1 - (speed / 55), 0.5, 1)
            
            if math.abs(rawVelocity.X) > math.abs(rawVelocity.Y) then
                TrayBtn.Size = UDim2.fromOffset(BaseSize * stretchFactor, BaseSize * squeezeFactor)
            else
                TrayBtn.Size = UDim2.fromOffset(BaseSize * squeezeFactor, BaseSize * stretchFactor)
            end
        else
            -- Smooth, continuous snap structural normalization back to circle
            if not TrayDragging then
                TrayBtn.Size = TrayBtn.Size:Lerp(UDim2.fromOffset(BaseSize, BaseSize), 0.2)
            end
        end
        LastTrayPos = currentCenter
    end

    -- Flight Control Logic
    if Config.Flying and Player.Character then
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
            root.AssemblyLinearVelocity = move.Magnitude > 0 and (move.Unit * Config.FlySpeed) or Vector3.zero
        end
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip and Player.Character then
        for _, part in ipairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)
