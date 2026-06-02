local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    Flying = false, Noclip = false, SpeedHack = false, InfiniteJump = false,
    ClickTP = false, Invisible = false, ESPEnabled = false, ESPTracers = false,
    ESPNames = true, ESPRainbow = false, SilentAim = false, SilentAimFOV = 150,
    SilentAimTeamCheck = true, SilentAimWallCheck = false, SilentAimHitbox = "Head",
    SilentAimSmoothness = 0, FlySpeed = 50, HackSpeed = 100, DroneSpeed = 45,
    MenuKeybind = Enum.KeyCode.RightShift, FlyKeybind = nil, NoclipKeybind = nil,
    SpeedKeybind = nil, IsMinimized = false, MenuOpen = true, ActiveTab = "Main"
}

local ESPObjects = {}
local ToggleCallbacks = {}
local DronePosition = nil
local SavedPosition = nil
local MenuPositionBeforeMinimize = UDim2.new(0.5, 0, 0.5, 0)
local ShootRemotes = {}

local AnimationTrack = nil

local Gui = Instance.new("ScreenGui")
Gui.Name = "SlimHub"
Gui.ResetOnSpawn = false

local Success, Error = pcall(function()
    Gui.Parent = CoreGui
end)
if not Success then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame", Gui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(500, 380)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(40, 40, 50)
Stroke.Thickness = 1.5

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(20, 0)
Title.BackgroundTransparency = 1
Title.Text = "SLIMHUB // PREMIUM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextXAlignment = Enum.TextXAlignment.Left

local Dragging, DragOffset = false, Vector2.zero
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragOffset = UIS:GetMouseLocation() - (MainFrame.AbsolutePosition + (MainFrame.AbsoluteSize * 0.5))
    end
end)
UIS.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        MainFrame.Position = UDim2.fromOffset((UIS:GetMouseLocation() - DragOffset).X, (UIS:GetMouseLocation() - DragOffset).Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
end)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, -50)
Sidebar.Position = UDim2.fromOffset(0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
Sidebar.BorderSizePixel = 0
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -145, 1, -65)
ContentArea.Position = UDim2.fromOffset(140, 60)
ContentArea.BackgroundTransparency = 1

local MinimizedIcon = Instance.new("TextButton", Gui)
MinimizedIcon.Name = "MinimizedIcon"
MinimizedIcon.Size = UDim2.fromOffset(45, 45)
MinimizedIcon.Position = UDim2.new(1, -60, 1, -60)
MinimizedIcon.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
MinimizedIcon.Text = "S"
MinimizedIcon.Font = Enum.Font.GothamBold
MinimizedIcon.TextSize = 22
MinimizedIcon.TextColor3 = Color3.fromRGB(0, 255, 150)
MinimizedIcon.Visible = false
Instance.new("UICorner", MinimizedIcon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", MinimizedIcon).Color = Color3.fromRGB(40, 40, 50)

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.fromOffset(30, 30)
MinBtn.Position = UDim2.new(1, -45, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

local function MinimizeMenu()
    if Config.IsMinimized then return end
    Config.IsMinimized = true
    MenuPositionBeforeMinimize = MainFrame.Position
    Dragging = false
    local tweenOut = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(45, 45), Position = UDim2.new(1, -37.5, 1, -37.5)
    })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        if not Config.IsMinimized then return end
        MainFrame.Visible = false
        MainFrame.Size = UDim2.fromOffset(500, 380)
        MainFrame.Position = MenuPositionBeforeMinimize
        MinimizedIcon.Visible = true
        MinimizedIcon.Size = UDim2.fromOffset(0, 0)
        TweenService:Create(MinimizedIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(45, 45)
        }):Play()
    end)
end

local function MaximizeMenu()
    if not Config.IsMinimized then return end
    Config.IsMinimized = false
    
    local iconTween = TweenService:Create(MinimizedIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, 0)
    })
    iconTween:Play()
    iconTween.Completed:Connect(function()
        MinimizedIcon.Visible = false
    end)
    
    MainFrame.Visible = true
    MainFrame.Size = UDim2.fromOffset(45, 45)
    MainFrame.Position = UDim2.new(1, -37.5, 1, -37.5)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(500, 380), Position = MenuPositionBeforeMinimize
    }):Play()
end

MinBtn.MouseButton1Click:Connect(MinimizeMenu)
MinimizedIcon.MouseButton1Click:Connect(MaximizeMenu)

local Tabs = {}
local function CreateTab(name)
    local Tab = Instance.new("ScrollingFrame", ContentArea)
    Tab.Size = UDim2.fromScale(1, 1)
    Tab.BackgroundTransparency = 1
    Tab.CanvasSize = UDim2.fromScale(0, 1.4)
    Tab.ScrollBarThickness = 3
    Tab.Visible = false
    Instance.new("UIListLayout", Tab).Padding = UDim.new(0, 8)
    Tabs[name] = Tab
end
CreateTab("Main"); CreateTab("ESP"); CreateTab("Prison"); CreateTab("Settings")
Tabs.Main.Visible = true

local TabButtons = {}
local function CreateTabButton(name)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.Position = UDim2.fromOffset(5, 0)
    Btn.BackgroundColor3 = name == "Main" and Color3.fromRGB(28, 28, 36) or Color3.fromRGB(15, 15, 19)
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
    
    local Indicator = Instance.new("Frame", Btn)
    Indicator.Size = UDim2.new(0, 3, 0.5, 0)
    Indicator.Position = UDim2.fromOffset(8, 0.25)
    Indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Indicator.BorderSizePixel = 0
    Indicator.Visible = name == "Main"
    
    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.fromOffset(20, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name:upper()
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextColor3 = name == "Main" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    TabButtons[name] = {Btn = Btn, Indicator = Indicator, Label = Label}
    Btn.MouseButton1Click:Connect(function()
        Config.ActiveTab = name
        for n, t in pairs(Tabs) do t.Visible = n == name end
        for n, data in pairs(TabButtons) do
            local active = n == name
            data.Indicator.Visible = active
            data.Label.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
            data.Btn.BackgroundColor3 = active and Color3.fromRGB(28, 28, 36) or Color3.fromRGB(15, 15, 19)
        end
    end)
end
CreateTabButton("Main"); CreateTabButton("ESP"); CreateTabButton("Prison"); CreateTabButton("Settings")

local function CreateSection(parent, title)
    local Section = Instance.new("Frame", parent)
    Section.Size = UDim2.new(1, -10, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Section.BorderSizePixel = 0
    Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Section).Color = Color3.fromRGB(35, 35, 45)
    
    local TitleLabel = Instance.new("TextLabel", Section)
    TitleLabel.Size = UDim2.new(1, -20, 0, 28)
    TitleLabel.Position = UDim2.fromOffset(15, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title:upper()
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 11
    TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Content = Instance.new("Frame", Section)
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.Position = UDim2.fromOffset(0, 35)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.BackgroundTransparency = 1
    Instance.new("UIListLayout", Content).Padding = UDim.new(0, 6)
    local Pad = Instance.new("UIPadding", Content)
    Pad.PaddingLeft = UDim.new(0, 15)
    Pad.PaddingRight = UDim.new(0, 15)
    Pad.PaddingBottom = UDim.new(0, 15)
    return Content
end

local function CreateToggle(parent, text, configKey, callback)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, 0, 0, 36)
    Row.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton", Row)
    ToggleBtn.Size = UDim2.fromOffset(48, 24)
    ToggleBtn.Position = UDim2.new(1, -48, 0.5, -12)
    ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 45)
    ToggleBtn.Text = ""
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame", ToggleBtn)
    Knob.Size = UDim2.fromOffset(18, 18)
    Knob.Position = Config[configKey] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
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
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, 0, 0, 50)
    Row.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(0.5, 0, 0, 22)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    local ValueLabel = Instance.new("TextLabel", Row)
    ValueLabel.Size = UDim2.fromOffset(45, 22)
    ValueLabel.Position = UDim2.new(1, -45, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Config[configKey])
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 13
    ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    local Track = Instance.new("Frame", Row)
    Track.Size = UDim2.new(1, 0, 0, 5)
    Track.Position = UDim2.new(0, 0, 0, 32)
    Track.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    local HitArea = Instance.new("TextButton", Track)
    HitArea.Size = UDim2.new(1, 0, 4, 0)
    HitArea.Position = UDim2.new(0, 0, 0.5, -2)
    HitArea.BackgroundTransparency = 1
    HitArea.Text = ""
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.Position = UDim2.new((Config[configKey] - min) / (max - min), -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local Holding = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0); Knob.Position = UDim2.new(pos, -7, 0.5, -7)
        local val = math.floor(min + (pos * (max - min))); Config[configKey] = val
        ValueLabel.Text = tostring(val); if callback then callback(val) end
    end
    HitArea.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Holding = true; Update(input) end end)
    UIS.InputChanged:Connect(function(input) if Holding and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 and Holding then Holding = false end end)
end

local function CreateKeybindButton(parent, text, configKey, callback)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, 0, 0, 40)
    Row.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    local BindBtn = Instance.new("TextButton", Row)
    BindBtn.Size = UDim2.fromOffset(120, 28)
    BindBtn.Position = UDim2.new(1, -120, 0.5, -14)
    BindBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    BindBtn.Text = Config[configKey] and Config[configKey].Name or "[NONE]"
    BindBtn.Font = Enum.Font.Code
    BindBtn.TextSize = 12
    BindBtn.TextColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(140, 140, 150)
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)

    local Listening = false
    BindBtn.MouseButton1Click:Connect(function()
        Listening = true; BindBtn.Text = "[PRESS KEY]"; BindBtn.TextColor3 = Color3.fromRGB(255, 150, 0)
    end)
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if not Listening or gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Listening = false
            if input.KeyCode == Enum.KeyCode.Escape then
                Config[configKey] = nil; BindBtn.Text = "[NONE]"; BindBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
            else
                Config[configKey] = input.KeyCode; BindBtn.Text = input.KeyCode.Name; BindBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
            end
            if callback then callback(Config[configKey]) end
        end
    end)
end

local MainSection = CreateSection(Tabs.Main, "Movement")

local function ClearFlight()
    if AnimationTrack then AnimationTrack:Stop(); AnimationTrack:Destroy(); AnimationTrack = nil end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then 
        hum.PlatformStand = false
    end
end

local function StartFlight()
    ClearFlight()
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local animProvider = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    local flyAnim = Instance.new("Animation")
    flyAnim.AnimationId = "rbxassetid://616006778"
    
    pcall(function()
        AnimationTrack = animProvider:LoadAnimation(flyAnim)
        AnimationTrack.Priority = Enum.AnimationPriority.Movement
        AnimationTrack:Play(0.2)
        AnimationTrack:AdjustSpeed(0)
    end)
end

CreateToggle(MainSection, "Fly", "Flying", function(state)
    if state then
        StartFlight()
    else
        ClearFlight()
    end
end)

CreateSlider(MainSection, "Fly Speed", "FlySpeed", 16, 250)
CreateToggle(MainSection, "Speed Hack", "SpeedHack", function(state)
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = state and Config.HackSpeed or 16 end
end)
CreateSlider(MainSection, "Walk Speed", "HackSpeed", 16, 150, function(val)
    if Config.SpeedHack then
        local hum = (Player.Character or Player.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
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
        DronePosition = SavedPosition.Position + Vector3.new(0, 2, 0)
        root.CFrame = SavedPosition * CFrame.new(0, -100, 0)
        task.wait(0.05); root.Anchored = true
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 1; part.CanCollide = false end
        end
        Camera.CameraSubject = root; Camera.CameraType = Enum.CameraType.Custom
    else
        Camera.CameraSubject = humanoid; Camera.CameraType = Enum.CameraType.Custom
        UIS.MouseBehavior = Enum.MouseBehavior.Default; root.Anchored = false
        if SavedPosition then root.CFrame = SavedPosition end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 0; part.CanCollide = true end
        end
        DronePosition = nil; SavedPosition = nil
    end
end)
CreateToggle(MainSection, "Infinite Jump", "InfiniteJump")

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and Config.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local ESPSection = CreateSection(Tabs.ESP, "Visuals")
CreateToggle(ESPSection, "ESP Enabled", "ESPEnabled")
CreateToggle(ESPSection, "Show Tracers", "ESPTracers")
CreateToggle(ESPSection, "Show Names", "ESPNames")
CreateToggle(ESPSection, "Rainbow Mode", "ESPRainbow")

local PrisonSection = CreateSection(Tabs.Prison, "Combat")
CreateToggle(PrisonSection, "Silent Aim", "SilentAim")
CreateSlider(PrisonSection, "FOV Size", "SilentAimFOV", 50, 400)
CreateSlider(PrisonSection, "Smoothness", "SilentAimSmoothness", 0, 100)
CreateToggle(PrisonSection, "Team Check", "SilentAimTeamCheck")
CreateToggle(PrisonSection, "Wall Check", "SilentAimWallCheck")
local HitboxRow = Instance.new("Frame", PrisonSection); HitboxRow.Size = UDim2.new(1, 0, 0, 40); HitboxRow.BackgroundTransparency = 1
local HitboxLabel = Instance.new("TextLabel", HitboxRow); HitboxLabel.Size = UDim2.new(0.5, 0, 1, 0); HitboxLabel.BackgroundTransparency = 1
HitboxLabel.Text = "Target Hitbox"; HitboxLabel.Font = Enum.Font.Gotham; HitboxLabel.TextSize = 13; HitboxLabel.TextColor3 = Color3.fromRGB(220, 220, 230); HitboxLabel.TextXAlignment = Enum.TextXAlignment.Left
local HitboxBtn = Instance.new("TextButton", HitboxRow); HitboxBtn.Size = UDim2.fromOffset(120, 28); HitboxBtn.Position = UDim2.new(1, -120, 0.5, -14)
HitboxBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36); HitboxBtn.Text = Config.SilentAimHitbox:upper(); HitboxBtn.Font = Enum.Font.GothamSemibold
HitboxBtn.TextSize = 11; HitboxBtn.TextColor3 = Color3.fromRGB(0, 255, 150); Instance.new("UICorner", HitboxBtn).CornerRadius = UDim.new(0, 6)
HitboxBtn.MouseButton1Click:Connect(function()
    local hitboxes = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"}
    local idx = table.find(hitboxes, Config.SilentAimHitbox) or 1
    Config.SilentAimHitbox = hitboxes[(idx % #hitboxes) + 1]
    HitboxBtn.Text = Config.SilentAimHitbox:upper()
end)

local SettingsSection = CreateSection(Tabs.Settings, "Keybinds")
CreateKeybindButton(SettingsSection, "Menu Toggle", "MenuKeybind")
CreateKeybindButton(SettingsSection, "Fly Toggle", "FlyKeybind")
CreateKeybindButton(SettingsSection, "Noclip Toggle", "NoclipKeybind")
CreateKeybindButton(SettingsSection, "Speed Toggle", "SpeedKeybind")

local function CreateESP(player)
    if ESPObjects[player] then return end
    local box = Drawing.new("Square"); box.Thickness = 1; box.Color = Color3.fromRGB(0, 255, 150); box.Filled = false; box.Visible = false
    local name = Drawing.new("Text"); name.Size = 13; name.Center = true; name.Outline = true; name.Color = Color3.fromRGB(255, 255, 255); name.Visible = false
    local tracer = Drawing.new("Line"); tracer.Thickness = 0.8; tracer.Color = Color3.fromRGB(0, 255, 150); tracer.Visible = false
    ESPObjects[player] = {Box = box, Name = name, Tracer = tracer}
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Config.MenuKeybind and input.KeyCode == Config.MenuKeybind then
        if Config.IsMinimized then MaximizeMenu() else MinimizeMenu() end
    end
    if Config.FlyKeybind and input.KeyCode == Config.FlyKeybind then
        Config.Flying = not Config.Flying
        if ToggleCallbacks.Flying then ToggleCallbacks.Flying(Config.Flying) end
    end
    if Config.NoclipKeybind and input.KeyCode == Config.NoclipKeybind then
        Config.Noclip = not Config.Noclip
        if ToggleCallbacks.Noclip then ToggleCallbacks.Noclip(Config.Noclip) end
    end
    if Config.SpeedKeybind and input.KeyCode == Config.SpeedKeybind then
        Config.SpeedHack = not Config.SpeedHack
        if ToggleCallbacks.SpeedHack then ToggleCallbacks.SpeedHack(Config.SpeedHack) end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do if p ~= Player then CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= Player then CreateESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then 
        ESPObjects[p].Box:Remove(); ESPObjects[p].Name:Remove(); ESPObjects[p].Tracer:Remove()
        ESPObjects[p] = nil 
    end
end)

local FOVCircle = Drawing.new("Circle"); FOVCircle.Visible = false; FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 150); FOVCircle.Filled = false; FOVCircle.NumSides = 64

local function GetTarget()
    local mousePos = UIS:GetMouseLocation()
    local closest = nil
    local closestDist = Config.SilentAimFOV
    
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= Player and targetPlayer.Character then
            if Config.SilentAimTeamCheck and targetPlayer.Team == Player.Team then continue end
            
            local targetPart = targetPlayer.Character:FindFirstChild(Config.SilentAimHitbox) 
                or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetPart then
                local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        if Config.SilentAimWallCheck then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterDescendantsInstances = {Player.Character}
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.IgnoreWater = true
                            local origin = Camera.CFrame.Position
                            local direction = (targetPart.Position - origin)
                            local result = workspace:Raycast(origin, direction, rayParams)
                            if result and result.Instance and not result.Instance:IsDescendantOf(targetPlayer.Character) then
                                continue
                            end
                        end

                        if dist < closestDist then
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

local function IsShootRemote(remote)
    if not remote or not remote:IsA("RemoteEvent") then return false end
    local n = remote.Name:lower()
    return n == "shootevent" or n:find("shoot") or n:find("fire") or n:find("gun")
end
local function CollectShootRemotes()
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if IsShootRemote(obj) and not table.find(ShootRemotes, obj) then table.insert(ShootRemotes, obj) end
    end
end
CollectShootRemotes()
ReplicatedStorage.DescendantAdded:Connect(function(obj)
    if IsShootRemote(obj) and not table.find(ShootRemotes, obj) then table.insert(ShootRemotes, obj) end
end)

local function ModifyArgs(args)
    local target = GetTarget()
    if not target then return args end
    
    local camPos = Camera.CFrame.Position
    local targetPos = target.Position
    
    if Config.SilentAimSmoothness > 0 then
        targetPos = camPos + (Camera.CFrame.LookVector:Lerp((targetPos - camPos).Unit, Config.SilentAimSmoothness / 100) * 1000)
    end
    
    local newArgs = {unpack(args)}
    if #newArgs >= 1 and type(newArgs[1]) == "table" then
        local firstArg = newArgs[1]
        if #firstArg > 0 and type(firstArg[1]) == "table" and firstArg[1].Hit ~= nil then
            for i = 1, #firstArg do
                firstArg[i].Hit = target
                firstArg[i].Distance = (camPos - targetPos).Magnitude
                firstArg[i].Cframe = CFrame.new(camPos, targetPos)
            end
        elseif firstArg.Hit ~= nil then
            firstArg.Hit = target
            firstArg.Distance = (camPos - targetPos).Magnitude
            firstArg.Cframe = CFrame.new(camPos, targetPos)
        else
            newArgs[1] = {{Hit = target, Distance = (camPos - targetPos).Magnitude, Cframe = CFrame.new(camPos, targetPos)}}
        end
    elseif #newArgs >= 2 then
        newArgs[2] = targetPos
    elseif #newArgs >= 1 then
        newArgs[2] = targetPos
    end
    
    return newArgs
end

if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and Config.SilentAim and self:IsA("RemoteEvent") and (IsShootRemote(self) or table.find(ShootRemotes, self)) then
            return oldNamecall(self, unpack(ModifyArgs({...})))
        end
        return oldNamecall(self, ...)
    end)
end

Player.CharacterAdding:Connect(function()
    ClearFlight()
    Config.Flying = false
    if ToggleCallbacks.Flying then ToggleCallbacks.Flying(false) end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if Config.Flying and root and hum then
        hum.PlatformStand = true
        
        local moveDir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        local look = Camera.CFrame.LookVector
        local targetCFrame = CFrame.new(root.Position, root.Position + Vector3.new(look.X, 0, look.Z))
        
        if moveDir.Magnitude > 0 then
            if AnimationTrack then AnimationTrack:AdjustSpeed(1) end
            local newPosition = root.Position + (moveDir.Unit * Config.FlySpeed * deltaTime)
            
            local horizontalMove = Vector3.new(moveDir.X, 0, moveDir.Z)
            if horizontalMove.Magnitude > 0 then
                local forwardSpace = root.CFrame:VectorToWorldSpace(Vector3.new(0, 0, -1))
                local dot = horizontalMove.Unit:Dot(forwardSpace)
                local rightSpace = root.CFrame:VectorToWorldSpace(Vector3.new(1, 0, 0))
                local rightDot = horizontalMove.Unit:Dot(rightSpace)
                
                local tiltAngle = math.rad(-20) * math.clamp(dot, -1, 1)
                local rollAngle = math.rad(-20) * math.clamp(rightDot, -1, 1)
                targetCFrame = CFrame.new(newPosition, newPosition + Vector3.new(look.X, 0, look.Z)) * CFrame.Angles(tiltAngle, 0, rollAngle)
            else
                targetCFrame = CFrame.new(newPosition, newPosition + Vector3.new(look.X, 0, look.Z))
            end
        else
            if AnimationTrack then AnimationTrack:AdjustSpeed(0) end
            targetCFrame = CFrame.new(root.Position, root.Position + Vector3.new(look.X, 0, look.Z))
        end
        
        root.CFrame = targetCFrame
    end
    
    if Config.Invisible and DronePosition and root then
        local moveDir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        local speed = Config.SpeedHack and Config.HackSpeed or Config.DroneSpeed
        if moveDir.Magnitude > 0 then
            DronePosition = DronePosition + Vector3.new(moveDir.X, 0, moveDir.Z).Unit * speed * deltaTime
        end
        root.CFrame = CFrame.new(DronePosition.X, DronePosition.Y - 100, DronePosition.Z)
    end

    -- FOV Rendering Logic
    if Config.SilentAim then
        local mousePos = UIS:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Config.SilentAimFOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    -- ESP Rendering Loop
    local tickValue = tick()
    local rainbowColor = Color3.fromHSV((tickValue % 5) / 5, 1, 1)
    
    for p, drawings in pairs(ESPObjects) do
        local box = drawings.Box
        local name = drawings.Name
        local tracer = drawings.Tracer
        
        local pChar = p.Character
        local pRoot = pChar and pChar:FindFirstChild("HumanoidRootPart")
        local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
        
        if Config.ESPEnabled and pRoot and pHum and pHum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(pRoot.Position)
            
            if onScreen then
                local currentC = Config.ESPRainbow and rainbowColor or Color3.fromRGB(0, 255, 150)
                
                -- Calculations for bounding screen dimensions based on distance
                local factor = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView / 2))) * 1000
                local w, h = 4 * factor, 6 * factor
                
                box.Size = Vector2.new(w, h)
                box.Position = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                box.Color = currentC
                box.Visible = true
                
                if Config.ESPNames then
                    name.Text = p.Name .. " [" .. math.floor(pHum.Health) .. "]"
                    name.Position = Vector2.new(pos.X, (pos.Y - h / 2) - 15)
                    name.Visible = true
                else
                    name.Visible = false
                end
                
                if Config.ESPTracers then
                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(pos.X, pos.Y + h / 2)
                    tracer.Color = currentC
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end
            else
                box.Visible = false
                name.Visible = false
                tracer.Visible = false
            end
        else
            box.Visible = false
            name.Visible = false
            tracer.Visible = false
        end
    end
end)

-- Noclip Collisions Loop
RunService.Stepped:Connect(function()
    if Config.Noclip then
        local char = Player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)
