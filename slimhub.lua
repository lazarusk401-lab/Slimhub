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

local FlySpeed = 50
local NormalSpeed = 16
local HackSpeed = 100

-- --- MOD MODERN UI CREATION ---
local Gui = Instance.new("ScreenGui")
Gui.Name = "SlimJimPremium"
Gui.ResetOnSpawn = false
Gui.Parent = Player.PlayerGui

-- Main Panel
local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(400, 320)
Frame.Position = UDim2.new(0.5, -200, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Parent = Gui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Frame)
Stroke.Color = Color3.fromRGB(40, 40, 45)
Stroke.Thickness = 1.5

-- Top Bar / Drag Handle
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = Frame

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 10)

-- Cover the bottom corners of the top bar to keep them sharp
local Cover = Instance.new("Frame")
Cover.Size = UDim2.new(1, 0, 0, 10)
Cover.Position = UDim2.new(0, 0, 1, -10)
Cover.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
Cover.BorderSizePixel = 0
Cover.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "SLIM JIM // CHEAT MENU"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(0, 255, 130)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- UI Layout Container
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

-- Smooth Component Builders
local function CreateRow(name, layoutOrder)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 45)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Row.BorderSizePixel = 0
    Row.LayoutOrder = layoutOrder
    Row.Parent = Container
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.Position = UDim2.fromOffset(12, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name:upper()
    Label.Font = Enum.Font.GothamMedium
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    
    return Row
end

local function AddToggle(row, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.fromOffset(45, 22)
    ToggleBtn.Position = UDim2.new(1, -57, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = row
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

local function AddSlider(row, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.4, 0, 0, 6)
    SliderFrame.Position = UDim2.new(0.6, -210, 0.5, -3)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = row
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
    ValueLabel.Size = UDim2.fromOffset(40, 20)
    ValueLabel.Position = UDim2.new(0.6, -260, 0.5, -10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextColor3 = Color3.fromRGB(140, 140, 145)
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = row

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

-- Fly Row
local FlyRow = CreateRow("Fly Hack", 1)
AddToggle(FlyRow, function(state)
    Flying = state
end)
AddSlider(FlyRow, 16, 250, FlySpeed, function(val)
    FlySpeed = val
end)

-- Noclip Row
local NoclipRow = CreateRow("Noclip", 2)
AddToggle(NoclipRow, function(state)
    Noclip = state
end)

-- Speed Row
local SpeedRow = CreateRow("Speed Hack", 3)
AddToggle(SpeedRow, function(state)
    SpeedHack = state
    local char = GetCharacter()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = state and HackSpeed or NormalSpeed
    end
end)
AddSlider(SpeedRow, 16, 150, HackSpeed, function(val)
    HackSpeed = val
    if SpeedHack then
        local char = GetCharacter()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = HackSpeed end
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

-- Continuous Speed Control (Prevents game resets resetting walkspeed)
GetCharacter():FindFirstChildOfClass("Humanoid").WalkSpeed = SpeedHack and HackSpeed or NormalSpeed
Player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = SpeedHack and HackSpeed or NormalSpeed
end)

-- --- SMOOTH DRAGGING SYSTEM ---
local Dragging, DragStart, StartPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = Frame.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = input.Position - DragStart
        TweenService:Create(Frame, TweenInfo.new(0.08, Enum.EasingStyle.OutQuad), {
            Position = UDim2.new(
                StartPos.X.Scale,
                StartPos.X.Offset + Delta.X,
                StartPos.Y.Scale,
                StartPos.Y.Offset + Delta.Y
            )
        }):Play()
    end
end)
