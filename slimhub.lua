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

-- Master Keybind Configurations (Cheats default to nil/optional)
local MenuKeybind = Enum.KeyCode.RightShift
local FlyKeybind = nil
local NoclipKeybind = nil
local SpeedKeybind = nil

local IsMinimized = false
local MenuOpen = true
local ActiveTab = "Main"

-- Advanced Camera & Drone Variables
local SavedPosition = nil
local DroneNode = nil

-- --- MODERN UI CREATION (NEON/CYBER THEME) ---
local Gui = Instance.new("ScreenGui")
Gui.Name = "SlimHub"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

-- Main Menu Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(500, 380)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Parent = Gui

local FrameCorner = Instance.new("UICorner", Frame)
FrameCorner.CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Frame)
Stroke.Color = Color3.fromRGB(35, 35, 45)
Stroke.Thickness = 1.5

-- Top Header Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = Frame

Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)
local Cover = Instance.new("Frame")
Cover.Size = UDim2.new(1, 0, 0, 15)
Cover.Position = UDim2.new(0, 0, 1, -15)
Cover.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Cover.BorderSizePixel = 0
Cover.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.fromOffset(20, 0)
Title.BackgroundTransparency = 1
Title.Text = "SLIMHUB // PREMIUM CLIENT"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Circular Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromOffset(28, 28)
MinBtn.Position = UDim2.new(1, -40, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

-- Sidebar Navigation Area
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -50)
Sidebar.Position = UDim2.fromOffset(0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Frame

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.Padding = UDim.new(0, 4)

-- Content Canvas Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -145, 1, -65)
ContentArea.Position = UDim2.fromOffset(140, 60)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Frame

-- Tab View Holders
local MainTabFrame = Instance.new("ScrollingFrame")
MainTabFrame.Size = UDim2.fromScale(1, 1)
MainTabFrame.BackgroundTransparency = 1
MainTabFrame.CanvasSize = UDim2.fromScale(0, 1.2)
MainTabFrame.ScrollBarThickness = 2
MainTabFrame.Visible = true
MainTabFrame.Parent = ContentArea

local MainLayout = Instance.new("UIListLayout", MainTabFrame)
MainLayout.Padding = UDim.new(0, 10)

local SettingsTabFrame = Instance.new("ScrollingFrame")
SettingsTabFrame.Size = UDim2.fromScale(1, 1)
SettingsTabFrame.BackgroundTransparency = 1
SettingsTabFrame.CanvasSize = UDim2.fromScale(0, 1.4)
SettingsTabFrame.ScrollBarThickness = 2
SettingsTabFrame.Visible = false
SettingsTabFrame.Parent = ContentArea

local SettingsLayout = Instance.new("UIListLayout", SettingsTabFrame)
SettingsLayout.Padding = UDim.new(0, 10)

-- Shared Global UI Object References for Keybind Actions
local ToggleButtonsMap = {}

-- --- UTILITY ANIMATION & UI FUNCTIONS ---
local function CreateTween(obj, info, propertyTable)
    local tween = TweenService:Create(obj, TweenInfo.new(unpack(info)), propertyTable)
    tween:Play()
    return tween
end

local function CreateTabButton(name)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.Position = UDim2.fromOffset(5, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = "" 
    Btn.Parent = Sidebar
    Btn.Name = name:upper()
    
    local Label = Instance.new("TextLabel")
    Label.Name = "TextLabel"
    Label.Size = UDim2.new(1, -15, 1, 0)
    Label.Position = UDim2.fromOffset(15, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.Text = name:upper()
    Label.TextColor3 = (name == "Main") and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(140, 140, 150)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        ActiveTab = name
        local mainBtn = Sidebar:FindFirstChild("MAIN")
        local settingsBtn = Sidebar:FindFirstChild("SETTINGS")
        
        if ActiveTab == "Main" then
            MainTabFrame.Visible = true
            SettingsTabFrame.Visible = false
            if mainBtn and mainBtn:FindFirstChild("TextLabel") then mainBtn.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 150) end
            if settingsBtn and settingsBtn:FindFirstChild("TextLabel") then settingsBtn.TextLabel.TextColor3 = Color3.fromRGB(140, 140, 150) end
        else
            MainTabFrame.Visible = false
            SettingsTabFrame.Visible = true
            if settingsBtn and settingsBtn:FindFirstChild("TextLabel") then settingsBtn.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 150) end
            if mainBtn and mainBtn:FindFirstChild("TextLabel") then mainBtn.TextLabel.TextColor3 = Color3.fromRGB(140, 140, 150) end
        end
    end)
end

local function CreateRow(name, parentContainer)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -5, 0, 52)
    Row.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    Row.BorderSizePixel = 0
    Row.Parent = parentContainer
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.45, 0, 1, 0)
    Label.Position = UDim2.fromOffset(15, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name:upper()
    Label.Font = Enum.Font.GothamMedium
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 200, 1, 0)
    Controls.Position = UDim2.new(1, -210, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Row
    
    return Controls
end

local function AddToggle(controls, cheatKey, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.fromOffset(42, 22)
    ToggleBtn.Position = UDim2.new(1, -45, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = controls
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    
    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.fromOffset(16, 16)
    Switch.Position = UDim2.fromOffset(3, 3)
    Switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Switch.BorderSizePixel = 0
    Switch.Parent = ToggleBtn
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    
    local state = false
    local function fireToggle()
        state = not state
        if state then
            CreateTween(ToggleBtn, {0.2}, {BackgroundColor3 = Color3.fromRGB(0, 255, 150)})
            CreateTween(Switch, {0.2, Enum.EasingStyle.Quad}, {Position = UDim2.fromOffset(23, 3)})
        else
            CreateTween(ToggleBtn, {0.2}, {BackgroundColor3 = Color3.fromRGB(32, 32, 42)})
            CreateTween(Switch, {0.2, Enum.EasingStyle.Quad}, {Position = UDim2.fromOffset(3, 3)})
        end
        callback(state)
    end
    
    ToggleBtn.MouseButton1Click:Connect(fireToggle)
    ToggleButtonsMap[cheatKey] = fireToggle
end

local function AddSlider(controls, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -100, 0, 5)
    SliderFrame.Position = UDim2.new(0, 0, 0.5, -2)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
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
    Trigger.Size = UDim2.new(1, 20, 3, 0)
    Trigger.Position = UDim2.new(0, -10, -1, 0)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.fromOffset(50, 20)
    ValueLabel.Position = UDim2.new(1, -50, 0.5, -10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    ValueLabel.TextSize = 13
    ValueLabel.Parent = controls

    local holding = false
    local function update(input)
        local pos = math.clamp((input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + (pos * (max - min)))
        ValueLabel.Text = tostring(value)
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
    BindBtn.Size = UDim2.fromOffset(120, 28)
    BindBtn.Position = UDim2.new(1, -120, 0.5, -14)
    BindBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    BindBtn.Text = defaultKey and defaultKey.Name:upper() or "[ NONE ]"
    BindBtn.Font = Enum.Font.Code
    BindBtn.TextSize = 12
    BindBtn.TextColor3 = defaultKey and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(140, 140, 150)
    BindBtn.Parent = controls
    
    local StrokeBind = Instance.new("UIStroke", BindBtn)
    StrokeBind.Color = Color3.fromRGB(45, 45, 55)
    StrokeBind.Thickness = 1
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
    
    local listening = false
    BindBtn.MouseButton1Click:Connect(function()
        listening = true
        BindBtn.Text = "[ PRESS KEY ]"
        BindBtn.TextColor3 = Color3.fromRGB(255, 150, 0)
    end)
    
    UIS.InputBegan:Connect(function(input, processed)
        if not listening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            if input.KeyCode == Enum.KeyCode.Escape then
                BindBtn.Text = "[ NONE ]"
                BindBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
                callback(nil)
            else
                BindBtn.Text = input.KeyCode.Name:upper()
                BindBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
                callback(input.KeyCode)
            end
        end
    end)
end

-- --- BUILD TABS ---
CreateTabButton("Main")
CreateTabButton("Settings")

-- MAIN TAB CONTROLS
local FlyControls = CreateRow("Fly", MainTabFrame)
AddSlider(FlyControls, 16, 250, FlySpeed, function(val) FlySpeed = val end)
AddToggle(FlyControls, "Fly", function(state) Flying = state end)

local NoclipControls = CreateRow("Noclip", MainTabFrame)
AddToggle(NoclipControls, "Noclip", function(state) Noclip = state end)

local SpeedControls = CreateRow("Speed", MainTabFrame)
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

local InvisControls = CreateRow("Invisibility", MainTabFrame)
AddToggle(InvisControls, "Invis", function(state)
    Invisible = state
    local character = GetCharacter()
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not root or not humanoid then return end
    
    if Invisible then
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
        
        if DroneNode then DroneNode:Destroy(); DroneNode = nil end
        SavedPosition = nil
    end
end)

-- SETTINGS TAB CONTROLS
local UIKeybindRow = CreateRow("UI Menu Toggle Bind", SettingsTabFrame)
AddKeybindButton(UIKeybindRow, MenuKeybind, function(newKey) MenuKeybind = newKey end)

local FlyKeybindRow = CreateRow("Fly Feature Keybind", SettingsTabFrame)
AddKeybindButton(FlyKeybindRow, FlyKeybind, function(newKey) FlyKeybind = newKey end)

local NoclipKeybindRow = CreateRow("Noclip Feature Keybind", SettingsTabFrame)
AddKeybindButton(NoclipKeybindRow, NoclipKeybind, function(newKey) NoclipKeybind = newKey end)

local SpeedKeybindRow = CreateRow("Speed Feature Keybind", SettingsTabFrame)
AddKeybindButton(SpeedKeybindRow, SpeedKeybind, function(newKey) SpeedKeybind = newKey end)

-- --- FIXED ANCHOR MINIMIZATION ENGINE ---
local MinCircle = Instance.new("TextButton")
MinCircle.Size = UDim2.fromOffset(55, 55)
MinCircle.Position = UDim2.new(1, -60, 1, -60)
MinCircle.AnchorPoint = Vector2.new(0.5, 0.5)
MinCircle.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MinCircle.Text = "S"
MinCircle.Font = Enum.Font.GothamBold
MinCircle.TextSize = 22
MinCircle.TextColor3 = Color3.fromRGB(0, 255, 150)
MinCircle.Visible = false
MinCircle.Parent = Gui

Instance.new("UICorner", MinCircle).CornerRadius = UDim.new(1, 0)
local CircleStroke = Instance.new("UIStroke", MinCircle)
CircleStroke.Color = Color3.fromRGB(0, 255, 150)
CircleStroke.Thickness = 1.5

MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = true
    
    local collapseTween = CreateTween(Frame, {0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In}, {
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.new(1, -60, 1, -60)
    })
    
    collapseTween.Completed:Wait()
    Frame.Visible = false
    
    MinCircle.Visible = true
    MinCircle.Size = UDim2.fromOffset(0, 0)
    CreateTween(MinCircle, {0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out}, {
        Size = UDim2.fromOffset(55, 55)
    })
end)

MinCircle.MouseButton1Click:Connect(function()
    IsMinimized = false
    
    local popCircle = CreateTween(MinCircle, {0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In}, {
        Size = UDim2.fromOffset(0, 0)
    })
    popCircle.Completed:Wait()
    MinCircle.Visible = false
    
    Frame.Visible = true
    CreateTween(Frame, {0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
        Size = UDim2.fromOffset(500, 380),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
end)

-- --- MECHANICS LOOPS ---

-- Drone Positioning Logic (High Speed Response Engine)
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

-- Fly Engine Loop
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

-- Noclip Engine Loop
RunService.Stepped:Connect(function()
    if not Noclip then return end
    local Character = GetCharacter()
    for _, v in ipairs(Character:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end)

-- Dynamic Rebindable Key & Master Controls Handler 
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Main Menu Toggle
    if input.KeyCode == MenuKeybind then
        if IsMinimized then return end
        MenuOpen = not MenuOpen
        Frame.Visible = MenuOpen
    
    -- Optional Feature Bind Checks
    elseif FlyKeybind and input.KeyCode == FlyKeybind then
        if ToggleButtonsMap["Fly"] then ToggleButtonsMap["Fly"]() end
        
    elseif NoclipKeybind and input.KeyCode == NoclipKeybind then
        if ToggleButtonsMap["Noclip"] then ToggleButtonsMap["Noclip"]() end
        
    elseif SpeedKeybind and input.KeyCode == SpeedKeybind then
        if ToggleButtonsMap["Speed"] then ToggleButtonsMap["Speed"]() end
    end
end)

-- --- DRAGGING MECHANICAL SYSTEM ---
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
