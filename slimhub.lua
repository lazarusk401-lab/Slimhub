task.wait(1)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local function GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

-- --- STATES & CONFIG ---
local Flying = false
local Noclip = false
local SpeedHack = false
local Invisible = false

local FlySpeed = 50
local NormalSpeed = 16
local HackSpeed = 100
local IsMinimized = false
local MenuOpen = true

-- --- MODERN UI CREATION ---
local Gui = Instance.new("ScreenGui")
Gui.Name = "SlimHub"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(420, 360)
Frame.Position = UDim2.new(0.5, -210, 0.5, -180)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Parent = Gui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Frame)
Stroke.Color = Color3.fromRGB(40, 40, 45)
Stroke.Thickness = 1.5

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = Frame

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 10)

local Cover = Instance.new("Frame")
Cover.Size = UDim2.new(1, 0, 0, 10)
Cover.Position = UDim2.new(0, 0, 1, -10)
Cover.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
Cover.BorderSizePixel = 0
Cover.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "SLIMHUB // CLIENT [RSHIFT]"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(0, 255, 130)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromOffset(30, 30)
MinBtn.Position = UDim2.new(1, -40, 0.5, -15)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.TextColor3 = Color3.fromRGB(150, 150, 155)
MinBtn.Parent = TopBar

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -30, 1, -65)
Container.Position = UDim2.fromOffset(15, 55)
Container.BackgroundTransparency = 1
Container.Parent = Frame

local Layout = Instance.new("UIListLayout", Container)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 12)

-- --- UTILITY UI FUNCTIONS ---
local function CreateTween(obj, info, propertyTable)
    local tween = TweenService:Create(obj, TweenInfo.new(unpack(info)), propertyTable)
    tween:Play()
    return tween
end

local function CreateRow(name, layoutOrder)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 50)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Row.BorderSizePixel = 0
    Row.LayoutOrder = layoutOrder
    Row.Parent = Container
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.35, 0, 1, 0)
    Label.Position = UDim2.fromOffset(12, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name:upper()
    Label.Font = Enum.Font.GothamMedium
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0.65, -12, 1, 0)
    Controls.Position = UDim2.new(0.35, 0, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Row
    
    return Controls
end

local function AddToggle(controls, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.fromOffset(45, 22)
    ToggleBtn.Position = UDim2.new(1, -45, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
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
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            CreateTween(ToggleBtn, {0.2}, {BackgroundColor3 = Color3.fromRGB(0, 255, 130)})
            CreateTween(Switch, {0.2, Enum.EasingStyle.Quad}, {Position = UDim2.fromOffset(26, 3)})
        else
            CreateTween(ToggleBtn, {0.2}, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)})
            CreateTween(Switch, {0.2, Enum.EasingStyle.Quad}, {Position = UDim2.fromOffset(3, 3)})
        end
        callback(state)
    end)
end

local function AddSlider(controls, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -110, 0, 6)
    SliderFrame.Position = UDim2.new(0, 0, 0.5, -3)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = controls
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 130)
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
    ValueLabel.Size = UDim2.fromOffset(45, 20)
    ValueLabel.Position = UDim2.new(1, -100, 0.5, -10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextColor3 = Color3.fromRGB(140, 140, 145)
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Center
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            holding = true
            update(input)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if holding and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            holding = false
        end
    end)
end

-- --- BUILDING THE INTERFACE ---

local FlyControls = CreateRow("Fly Hack", 1)
AddSlider(FlyControls, 16, 250, FlySpeed, function(val) FlySpeed = val end)
AddToggle(FlyControls, function(state) Flying = state end)

local NoclipControls = CreateRow("Noclip", 2)
AddToggle(NoclipControls, function(state) Noclip = state end)

local SpeedControls = CreateRow("Speed Hack", 3)
AddSlider(SpeedControls, 16, 150, HackSpeed, function(val)
    HackSpeed = val
    if SpeedHack then
        local char = GetCharacter()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = HackSpeed end
    end
end)
AddToggle(SpeedControls, function(state)
    SpeedHack = state
    local char = GetCharacter()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = state and HackSpeed or NormalSpeed
    end
end)

-- Server-Replicating Client Invisibility
local InvisControls = CreateRow("Invisibility", 4)
AddToggle(InvisControls, function(state)
    Invisible = state
    local character = GetCharacter()
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if Invisible and root then
        -- Exploit Trick: Break visual joints on the client. 
        -- Because the client has network ownership of their character physics,
        -- deleting these joints forces the server to replicate the destruction.
        -- To other players, your avatar collapses or vanishes entirely, but your
        -- HumanoidRootPart remains fully physics-active, letting you move and shoot.
        local lowerTorso = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
        if lowerTorso then
            local rootJoint = lowerTorso:FindFirstChild("RootJoint")
            if rootJoint then
                rootJoint:Destroy()
            end
        end
    else
        -- Un-toggling respawns the character to fix the broken joints safely
        Player:LoadCharacter()
    end
end)

-- --- MINIMIZE SYSTEM ---
MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        CreateTween(Frame, {0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {Size = UDim2.fromOffset(420, 45)})
        MinBtn.Text = "+"
    else
        CreateTween(Frame, {0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {Size = UDim2.fromOffset(420, 360)})
        MinBtn.Text = "-"
    end
end)

-- --- KEYBIND TO SHOW/HIDE CLIENT (RSHIFT) ---
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MenuOpen = not MenuOpen
        Frame.Visible = MenuOpen
    end
end)

-- --- MECHANICS LOOPS ---

-- Fly Engine
RunService.RenderStepped:Connect(function()
    if not Flying then return end
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

-- Noclip Engine
RunService.Stepped:Connect(function()
    if not Noclip then return end
    local Character = GetCharacter()
    for _, v in ipairs(Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end)

-- Speed Maintainer Loop
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = SpeedHack and HackSpeed or NormalSpeed
                end
            end
        end)
    end
end)

-- --- DRAGGING SYSTEM ---
local Dragging, DragInput, DragStart, StartPos

local function UpdateDrag(input)
    local delta = input.Position - DragStart
    Frame.Position = UDim2.new(
        StartPos.X.Scale,
        StartPos.X.Offset + delta.X,
        StartPos.Y.Scale,
        StartPos.Y.Offset + delta.Y
    )
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = Frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        UpdateDrag(input)
    end
end)
