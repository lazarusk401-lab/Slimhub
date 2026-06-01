task.wait(1)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

-- --- GLOBAL STATES & CONFIG ---
local Flying = false
local Noclip = false
local SpeedHack = false
local Invisible = false

local FlySpeed = 50
local NormalSpeed = 16
local HackSpeed = 100
local DroneSpeed = 45

local MenuKeybind = Enum.KeyCode.RightShift
local FlyKeybind = nil
local NoclipKeybind = nil
local SpeedKeybind = nil

local IsMinimized = false
local MenuOpen = true
local ActiveTab = "Main"

local SavedPosition = nil
local DroneNode = nil

-- --- MODERN UI CREATION (CYBERPUNK NEON THEME) ---
local Gui = Instance.new("ScreenGui")
Gui.Name = "SlimHub"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(540, 390)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(9, 9, 11)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Parent = Gui

local FrameCorner = Instance.new("UICorner", Frame)
FrameCorner.CornerRadius = UDim.new(0, 10)

local FrameStroke = Instance.new("UIStroke", Frame)
FrameStroke.Color = Color3.fromRGB(28, 28, 35)
FrameStroke.Thickness = 1.5

-- Decorative Tech-Line Glow at top of UI
local GlowBar = Instance.new("Frame")
GlowBar.Size = UDim2.new(1, 0, 0, 2)
GlowBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
GlowBar.BorderSizePixel = 0
GlowBar.ZIndex = 5
GlowBar.Parent = Frame

-- Top Header Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.Position = UDim2.fromOffset(0, 2)
TopBar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
TopBar.BorderSizePixel = 0
TopBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.fromOffset(18, 0)
Title.BackgroundTransparency = 1
Title.Text = "SLIMHUB // CORE"
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(230, 230, 240)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Minimalist Square Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromOffset(24, 24)
MinBtn.Position = UDim2.new(1, -36, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 16
MinBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar

local MinBtnCorner = Instance.new("UICorner", MinBtn)
MinBtnCorner.CornerRadius = UDim.new(0, 4)

local MinBtnStroke = Instance.new("UIStroke", MinBtn)
MinBtnStroke.Color = Color3.fromRGB(35, 35, 45)

MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 75, 75)}):Play()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 35, 45)}):Play()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
end)

-- Sidebar Navigation Area
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 135, 1, -47)
Sidebar.Position = UDim2.fromOffset(0, 47)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Frame

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
SidebarDivider.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.Padding = UDim.new(0, 2)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Canvas Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -155, 1, -67)
ContentArea.Position = UDim2.fromOffset(150, 62)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Frame

-- Tab View Holders
local MainTabFrame = Instance.new("ScrollingFrame")
MainTabFrame.Size = UDim2.fromScale(1, 1)
MainTabFrame.BackgroundTransparency = 1
MainTabFrame.CanvasSize = UDim2.fromScale(0, 0)
MainTabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainTabFrame.ScrollBarThickness = 2
MainTabFrame.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 50)
MainTabFrame.Visible = true
MainTabFrame.Parent = ContentArea

local MainLayout = Instance.new("UIListLayout", MainTabFrame)
MainLayout.Padding = UDim.new(0, 8)

local SettingsTabFrame = Instance.new("ScrollingFrame")
SettingsTabFrame.Size = UDim2.fromScale(1, 1)
SettingsTabFrame.BackgroundTransparency = 1
SettingsTabFrame.CanvasSize = UDim2.fromScale(0, 0)
SettingsTabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
SettingsTabFrame.ScrollBarThickness = 2
SettingsTabFrame.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 50)
SettingsTabFrame.Visible = false
SettingsTabFrame.Parent = ContentArea

local SettingsLayout = Instance.new("UIListLayout", SettingsTabFrame)
SettingsLayout.Padding = UDim.new(0, 8)

local ToggleButtonsMap = {}

-- --- ENGINE GENERATORS ---
local function CreateTabButton(name)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -16, 0, 36)
    Btn.BackgroundTransparency = 1
    Btn.Text = "" 
    Btn.Parent = Sidebar
    Btn.Name = name:upper()
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0, 16)
    Indicator.Position = UDim2.new(0, 2, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Indicator.BorderSizePixel = 0
    Indicator.BackgroundTransparency = (name == "Main") and 0 or 1
    Indicator.Parent = Btn
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.fromOffset(15, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Code
    Label.TextSize = 13
    Label.Text = name:upper()
    Label.TextColor3 = (name == "Main") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(110, 110, 125)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Btn
    
    Btn.MouseEnter:Connect(function()
        if ActiveTab ~= name then
            TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 195)}):Play()
        end
    end)
    Btn.MouseLeave:Connect(function()
        if ActiveTab ~= name then
            TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(110, 110, 125)}):Play()
        end
    end)

    Btn.MouseButton1Click:Connect(function()
        ActiveTab = name
        
        for _, otherBtn in ipairs(Sidebar:GetChildren()) do
            if otherBtn:IsA("TextButton") then
                local ind = otherBtn:FindFirstChild("Frame")
                local txt = otherBtn:FindFirstChild("TextLabel")
                if ind and txt then
                    if otherBtn.Name == name:upper() then
                        TweenService:Create(ind, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                        TweenService:Create(txt, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    else
                        TweenService:Create(ind, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                        TweenService:Create(txt, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(110, 110, 125)}):Play()
                    end
                end
            end
        end

        if ActiveTab == "Main" then
            MainTabFrame.Visible = true
            SettingsTabFrame.Visible = false
        else
            MainTabFrame.Visible = false
            SettingsTabFrame.Visible = true
        end
    end)
end

local function CreateRow(name, parentContainer)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -8, 0, 50)
    Row.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    Row.BorderSizePixel = 0
    Row.Parent = parentContainer
    
    local RowCorner = Instance.new("UICorner", Row)
    RowCorner.CornerRadius = UDim.new(0, 6)
    
    local RowStroke = Instance.new("UIStroke", Row)
    RowStroke.Color = Color3.fromRGB(24, 24, 30)
    RowStroke.Thickness = 1
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.Position = UDim2.fromOffset(14, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name:upper()
    Label.Font = Enum.Font.Code
    Label.TextColor3 = Color3.fromRGB(200, 200, 210)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 210, 1, 0)
    Controls.Position = UDim2.new(1, -220, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Row
    
    Row.MouseEnter:Connect(function()
        TweenService:Create(RowStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(38, 38, 48)}):Play()
    end)
    Row.MouseLeave:Connect(function()
        TweenService:Create(RowStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(24, 24, 30)}):Play()
    end)
    
    return Controls
end

local function AddToggle(controls, cheatKey, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.fromOffset(38, 20)
    ToggleBtn.Position = UDim2.new(1, -42, 0.5, -10)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = controls
    
    local ToggleCorner = Instance.new("UICorner", ToggleBtn)
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    
    local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
    ToggleStroke.Color = Color3.fromRGB(38, 38, 48)
    ToggleStroke.Thickness = 1
    
    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.fromOffset(14, 14)
    Switch.Position = UDim2.fromOffset(2, 2)
    Switch.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
    Switch.BorderSizePixel = 0
    Switch.Parent = ToggleBtn
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    
    local state = false
    local function fireToggle()
        state = not state
        if state then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 45, 25)}):Play()
            TweenService:Create(ToggleStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 150)}):Play()
            TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.fromOffset(20, 2), BackgroundColor3 = Color3.fromRGB(0, 255, 150)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 32)}):Play()
            TweenService:Create(ToggleStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(38, 38, 48)}):Play()
            TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.fromOffset(2, 2), BackgroundColor3 = Color3.fromRGB(150, 150, 160)}):Play()
        end
        callback(state)
    end
    
    ToggleBtn.MouseButton1Click:Connect(fireToggle)
    ToggleButtonsMap[cheatKey] = fireToggle
end

local function AddSlider(controls, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -95, 0, 4)
    SliderFrame.Position = UDim2.new(0, 0, 0.5, -2)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = controls
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderFrame
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local Trigger = Instance.new("TextButton")
    Trigger.Size = UDim2.new(1, 20, 4, 0)
    Trigger.Position = UDim2.new(0, -10, -1.5, 0)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.fromOffset(45, 20)
    ValueLabel.Position = UDim2.new(1, -45, 0.5, -10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
    ValueLabel.TextSize = 12
    ValueLabel.Parent = controls

    local holding = false
    local function update(input)
        local pos = math.clamp((input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + (pos * (max - min)))
        ValueLabel.Text = tostring(value)
        
        -- Interactive Slide Color Fade (Muted tone shifts vibrant as power goes up)
        Fill.BackgroundColor3 = Color3.fromRGB(30):Lerp(Color3.fromRGB(0, 255, 150), pos)
        callback(value)
    end
    
    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then holding = true; update(input) end
    end)
    UIS.InputChanged:Connect(function(input)
        if holding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then holding = false end
    end)
end

local function AddKeybindButton(controls, defaultKey, callback)
    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.fromOffset(110, 24)
    BindBtn.Position = UDim2.new(1, -110, 0.5, -12)
    BindBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    BindBtn.Text = defaultKey and defaultKey.Name:upper() or "[ NONE ]"
    BindBtn.Font = Enum.Font.Code
    BindBtn.TextSize = 11
    BindBtn.TextColor3 = defaultKey and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(130, 130, 140)
    BindBtn.Parent = controls
    
    local StrokeBind = Instance.new("UIStroke", BindBtn)
    StrokeBind.Color = Color3.fromRGB(38, 38, 48)
    StrokeBind.Thickness = 1
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
    
    BindBtn.MouseEnter:Connect(function()
        TweenService:Create(StrokeBind, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 75)}):Play()
    end)
    BindBtn.MouseLeave:Connect(function()
        TweenService:Create(StrokeBind, TweenInfo.new(0.2), {Color = Color3.fromRGB(38, 38, 48)}):Play()
    end)

    local listening = false
    BindBtn.MouseButton1Click:Connect(function()
        listening = true
        BindBtn.Text = "[ KEY ]"
        BindBtn.TextColor3 = Color3.fromRGB(255, 160, 0)
    end)
    
    UIS.InputBegan:Connect(function(input, processed)
        if not listening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            if input.KeyCode == Enum.KeyCode.Escape then
                BindBtn.Text = "[ NONE ]"
                BindBtn.TextColor3 = Color3.fromRGB(130, 130, 140)
                callback(nil)
            else
                BindBtn.Text = input.KeyCode.Name:upper()
                BindBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
                callback(input.KeyCode)
            end
        end
    end)
end

-- --- BUILD STRUCTURES ---
CreateTabButton("Main")
CreateTabButton("Settings")

-- MAIN TAB CONTENT Rows
local FlyControls = CreateRow("Fly System", MainTabFrame)
AddSlider(FlyControls, 16, 250, FlySpeed, function(val) FlySpeed = val end)
AddToggle(FlyControls, "Fly", function(state) Flying = state end)

local NoclipControls = CreateRow("Noclip Architecture", MainTabFrame)
AddToggle(NoclipControls, "Noclip", function(state) Noclip = state end)

local SpeedControls = CreateRow("Speed Processing", MainTabFrame)
AddSlider(SpeedControls, 16, 150, HackSpeed, function(val)
    HackSpeed = val
    if SpeedHack then
        local char = GetCharacter()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = HackSpeed end
    end
end)
AddToggle(SpeedControls, "Speed", function(state)
    SpeedHack = state
    local char = GetCharacter()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = state and HackSpeed or NormalSpeed end
end)

local InvisControls = CreateRow("Invisibility Frame", MainTabFrame)
AddToggle(InvisControls, "Invis", function(state)
    Invisible = state
    local character = GetCharacter()
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not root or not humanoid then return end
    
    if Invisible then
        SavedPosition = root.CFrame
        
        DroneNode = Instance.new("Part")
        DroneNode.Name = "TrackingMatrixNode"
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
        
        if DroneNode then DroneNode:Destroy(); DroneNode = nil end
        SavedPosition = nil
    end
end)

-- SETTINGS TAB CONTENT Rows
local UIKeybindRow = CreateRow("Core Menu Toggle", SettingsTabFrame)
AddKeybindButton(UIKeybindRow, MenuKeybind, function(newKey) MenuKeybind = newKey end)

local FlyKeybindRow = CreateRow("Fly System Keybind", SettingsTabFrame)
AddKeybindButton(FlyKeybindRow, FlyKeybind, function(newKey) FlyKeybind = newKey end)

local NoclipKeybindRow = CreateRow("Noclip System Keybind", SettingsTabFrame)
AddKeybindButton(NoclipKeybindRow, NoclipKeybind, function(newKey) NoclipKeybind = newKey end)

local SpeedKeybindRow = CreateRow("Speed System Keybind", SettingsTabFrame)
AddKeybindButton(SpeedKeybindRow, SpeedKeybind, function(newKey) SpeedKeybind = newKey end)

-- --- INDUSTRIAL FIXED ANCHOR MINIMIZE RADIAL ---
local MinCircle = Instance.new("TextButton")
MinCircle.Size = UDim2.fromOffset(45, 45)
MinCircle.Position = UDim2.new(1, -55, 1, -55)
MinCircle.AnchorPoint = Vector2.new(0.5, 0.5)
MinCircle.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MinCircle.Text = "//"
MinCircle.Font = Enum.Font.Code
MinCircle.TextSize = 16
MinCircle.TextColor3 = Color3.fromRGB(0, 255, 150)
MinCircle.Visible = false
MinCircle.Parent = Gui

Instance.new("UICorner", MinCircle).CornerRadius = UDim.new(1, 0)
local CircleStroke = Instance.new("UIStroke", MinCircle)
CircleStroke.Color = Color3.fromRGB(0, 255, 150)
CircleStroke.Thickness = 1

MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = true
    
    local collapseTween = TweenService:Create(Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.new(1, -55, 1, -55)
    })
    collapseTween:Play()
    collapseTween.Completed:Wait()
    Frame.Visible = false
    
    MinCircle.Visible = true
    MinCircle.Size = UDim2.fromOffset(0, 0)
    TweenService:Create(MinCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(45, 45)
    }):Play()
end)

MinCircle.MouseButton1Click:Connect(function()
    IsMinimized = false
    
    local popCircle = TweenService:Create(MinCircle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, 0)
    })
    popCircle:Play()
    popCircle.Completed:Wait()
    MinCircle.Visible = false
    
    Frame.Visible = true
    TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(540, 390),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
end)

-- --- PERFORMANCE MECHANICS ENGINE ---

-- Vector Tracking Interpolation
RunService.RenderStepped:Connect(function(deltaTime)
    if not Invisible or not DroneNode then return end
    
    local cameraCFrame = Camera.CFrame
    local moveVector = Vector3.zero
    
    if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector += cameraCFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector -= cameraCFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector -= cameraCFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector += cameraCFrame.RightVector end
    
    local speedMultiplier = SpeedHack and HackSpeed or DroneSpeed
    
    if moveVector.Magnitude > 0 then
        local flattenedDirection = Vector3.new(moveVector.X, 0, moveVector.Z).Unit
        local targetPosition = DroneNode.Position + (flattenedDirection * speedMultiplier * deltaTime)
        
        if SavedPosition then
            targetPosition = Vector3.new(targetPosition.X, SavedPosition.Position.Y + 2, targetPosition.Z)
        end
        
        DroneNode.Position = DroneNode.Position:Lerp(targetPosition, math.clamp(deltaTime * 24, 0, 1))
    end
end)

-- Force Velocity Engine (Fly)
RunService.RenderStepped:Connect(function()
    if not Flying or Invisible then return end
    local Character = GetCharacter()
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local Cam = workspace.CurrentCamera
    local Move = Vector3.zero

    if UIS:IsKeyDown(Enum.KeyCode.W) then Move += Cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then Move -= Cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then Move -= Cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then Move += Cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then Move += Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then Move -= Vector3.yAxis end

    if Move.Magnitude > 0 then
        Root.AssemblyLinearVelocity = Move.Unit * FlySpeed
    else
        Root.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- Collision Pipeline Interceptor (Noclip)
RunService.Stepped:Connect(function()
    if not Noclip then return end
    local Character = GetCharacter()
    for _, v in ipairs(Character:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end)

-- Core Keybind Map Subscriptions
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == MenuKeybind then
        if IsMinimized then return end
        MenuOpen = not MenuOpen
        Frame.Visible = MenuOpen
    elseif FlyKeybind and input.KeyCode == FlyKeybind then
        if ToggleButtonsMap["Fly"] then ToggleButtonsMap["Fly"]() end
    elseif NoclipKeybind and input.KeyCode == NoclipKeybind then
        if ToggleButtonsMap["Noclip"] then ToggleButtonsMap["Noclip"]() end
    elseif SpeedKeybind and input.KeyCode == SpeedKeybind then
        if ToggleButtonsMap["Speed"] then ToggleButtonsMap["Speed"]() end
    end
end)

-- --- SMOOTH DRAG SYSTEM ---
local Dragging, DragInput, DragStart, StartPos
local function UpdateDrag(input)
    local delta = input.Position - DragStart
    Frame.Position = UDim2.new(
        StartPos.X.Scale, StartPos.X.Offset + delta.X,
        StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
    )
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true; DragStart = input.Position; StartPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then UpdateDrag(input) end
end)
