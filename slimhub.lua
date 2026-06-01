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

local SavedPosition = nil
local DroneNode = nil

-- --- CORE SCREEN GUI ---
local Gui = Instance.new("ScreenGui")
Gui.Name = "SlimHub"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(520, 360)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Parent = Gui

local FrameCorner = Instance.new("UICorner", Frame)
FrameCorner.CornerRadius = UDim.new(0, 8)

local FrameStroke = Instance.new("UIStroke", Frame)
FrameStroke.Color = Color3.fromRGB(32, 32, 40)
FrameStroke.Thickness = 1.5

-- Top Header Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
TopBar.BorderSizePixel = 0
TopBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "SLIMHUB // PREMIUM"
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromOffset(24, 24)
MinBtn.Position = UDim2.new(1, -35, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 16
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

-- Sidebar Navigation Area
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -45)
Sidebar.Position = UDim2.fromOffset(0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Frame

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
SidebarDivider.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

-- Content Containers
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -135, 1, -55)
ContentArea.Position = UDim2.fromOffset(130, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Frame

local MainTabFrame = Instance.new("ScrollingFrame")
MainTabFrame.Size = UDim2.fromScale(1, 1)
MainTabFrame.BackgroundTransparency = 1
MainTabFrame.CanvasSize = UDim2.fromScale(0, 0)
MainTabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
MainTabFrame.ScrollBarThickness = 2
MainTabFrame.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
MainTabFrame.Visible = true
MainTabFrame.Parent = ContentArea

local MainLayout = Instance.new("UIListLayout", MainTabFrame)
MainLayout.Padding = UDim.new(0, 6)

local SettingsTabFrame = Instance.new("ScrollingFrame")
SettingsTabFrame.Size = UDim2.fromScale(1, 1)
SettingsTabFrame.BackgroundTransparency = 1
SettingsTabFrame.CanvasSize = UDim2.fromScale(0, 0)
SettingsTabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
SettingsTabFrame.ScrollBarThickness = 2
SettingsTabFrame.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
SettingsTabFrame.Visible = false
SettingsTabFrame.Parent = ContentArea

local SettingsLayout = Instance.new("UIListLayout", SettingsTabFrame)
SettingsLayout.Padding = UDim.new(0, 6)

-- --- STATIC DIRECT NAVIGATION TABS ---
local MainBtn = Instance.new("TextButton")
MainBtn.Size = UDim2.new(1, -10, 0, 35)
MainBtn.Position = UDim2.fromOffset(5, 5)
MainBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
MainBtn.Text = "MAIN"
MainBtn.Font = Enum.Font.Code
MainBtn.TextSize = 12
MainBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
MainBtn.Parent = Sidebar
Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 4)

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(1, -10, 0, 35)
SettingsBtn.Position = UDim2.fromOffset(5, 44)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
SettingsBtn.Text = "SETTINGS"
SettingsBtn.Font = Enum.Font.Code
SettingsBtn.TextSize = 12
SettingsBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
SettingsBtn.Parent = Sidebar
Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 4)

MainBtn.MouseButton1Click:Connect(function()
    MainTabFrame.Visible = true
    SettingsTabFrame.Visible = false
    MainBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    MainBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    SettingsBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
    SettingsBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
end)

SettingsBtn.MouseButton1Click:Connect(function()
    MainTabFrame.Visible = false
    SettingsTabFrame.Visible = true
    SettingsBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    SettingsBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    MainBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
    MainBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
end)

-- --- CORE INTERACTION ELEMENTS ---
local ToggleButtonsMap = {}

local function CreateRow(name, parentContainer)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -6, 0, 46)
    Row.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    Row.BorderSizePixel = 0
    Row.Parent = parentContainer
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.Position = UDim2.fromOffset(12, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name:upper()
    Label.Font = Enum.Font.Code
    Label.TextColor3 = Color3.fromRGB(210, 210, 220)
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
    ToggleBtn.Size = UDim2.fromOffset(36, 18)
    ToggleBtn.Position = UDim2.new(1, -40, 0.5, -9)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = controls
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    
    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.fromOffset(12, 12)
    Switch.Position = UDim2.fromOffset(3, 3)
    Switch.BackgroundColor3 = Color3.fromRGB(140, 140, 150)
    Switch.BorderSizePixel = 0
    Switch.Parent = ToggleBtn
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    
    local state = false
    local function fireToggle()
        state = not state
        if state then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            Switch.Position = UDim2.fromOffset(21, 3)
            Switch.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            Switch.Position = UDim2.fromOffset(3, 3)
            Switch.BackgroundColor3 = Color3.fromRGB(140, 140, 150)
        end
        callback(state)
    end
    
    ToggleBtn.MouseButton1Click:Connect(fireToggle)
    ToggleButtonsMap[cheatKey] = fireToggle
end

local function AddSlider(controls, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -85, 0, 4)
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
    ValueLabel.Size = UDim2.fromOffset(40, 20)
    ValueLabel.Position = UDim2.new(1, -40, 0.5, -10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
    ValueLabel.TextSize = 12
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
    BindBtn.Size = UDim2.fromOffset(110, 24)
    BindBtn.Position = UDim2.new(1, -110, 0.5, -12)
    BindBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    BindBtn.Text = defaultKey and defaultKey.Name:upper() or "[ NONE ]"
    BindBtn.Font = Enum.Font.Code
    BindBtn.TextSize = 11
    BindBtn.TextColor3 = defaultKey and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(130, 130, 140)
    BindBtn.Parent = controls
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
    
    local StrokeBind = Instance.new("UIStroke", BindBtn)
    StrokeBind.Color = Color3.fromRGB(38, 38, 48)
    
    local listening = false
    BindBtn.MouseButton1Click:Connect(function()
        listening = true
        BindBtn.Text = "[ CHOOSE ]"
        BindBtn.TextColor3 = Color3.fromRGB(255, 150, 0)
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

-- --- INJECT GAMEPLAY SECTIONS ---
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
        DroneNode.Name = "DroneNode"
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

-- SETTINGS CONFIGS
local UIKeybindRow = CreateRow("UI Menu Toggle", SettingsTabFrame)
AddKeybindButton(UIKeybindRow, MenuKeybind, function(newKey) MenuKeybind = newKey end)

local FlyKeybindRow = CreateRow("Fly Keybind", SettingsTabFrame)
AddKeybindButton(FlyKeybindRow, FlyKeybind, function(newKey) FlyKeybind = newKey end)

local NoclipKeybindRow = CreateRow("Noclip Keybind", SettingsTabFrame)
AddKeybindButton(NoclipKeybindRow, NoclipKeybind, function(newKey) NoclipKeybind = newKey end)

local SpeedKeybindRow = CreateRow("Speed Keybind", SettingsTabFrame)
AddKeybindButton(SpeedKeybindRow, SpeedKeybind, function(newKey) SpeedKeybind = newKey end)

-- --- MECHANICAL MINIMIZE CORE ---
local MinCircle = Instance.new("TextButton")
MinCircle.Size = UDim2.fromOffset(45, 45)
MinCircle.Position = UDim2.new(1, -55, 1, -55)
MinCircle.AnchorPoint = Vector2.new(0.5, 0.5)
MinCircle.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
MinCircle.Text = "S"
MinCircle.Font = Enum.Font.Code
MinCircle.TextSize = 16
MinCircle.TextColor3 = Color3.fromRGB(0, 255, 150)
MinCircle.Visible = false
MinCircle.Parent = Gui

Instance.new("UICorner", MinCircle).CornerRadius = UDim.new(1, 0)
local CircleStroke = Instance.new("UIStroke", MinCircle)
CircleStroke.Color = Color3.fromRGB(0, 255, 150)

MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = true
    Frame.Visible = false
    MinCircle.Visible = true
end)

MinCircle.MouseButton1Click:Connect(function()
    IsMinimized = false
    MinCircle.Visible = false
    Frame.Visible = true
end)

-- --- PIPELINE MECHANICS LOOPS ---

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
        DroneNode.Position = targetPosition
    end
end)

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

RunService.Stepped:Connect(function()
    if not Noclip then return end
    local Character = GetCharacter()
    for _, v in ipairs(Character:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end)

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

-- --- DRAG HOOK ---
local Dragging, DragInput, DragStart, StartPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true; DragStart = input.Position; StartPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - DragStart
        Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end)
