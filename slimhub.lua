task.wait(0.1)

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
    FlySpeed = 50,
    HackSpeed = 100,
    MenuKeybind = Enum.KeyCode.RightShift,
    IsMinimized = false,
    MenuOpen = true,
    ActiveTab = "Main"
}

-- UI Target Selection (Fallback to PlayerGui if CoreGui is restricted)
local TargetGuiContainer = CoreGui
local success, _ = pcall(function() local t = CoreGui.Name end)
if not success then
    TargetGuiContainer = Player:WaitForChild("PlayerGui")
end

-- UI Setup
local Gui = Instance.new("ScreenGui")
Gui.Name = "SlimHub_Restored"
Gui.ResetOnSpawn = false
Gui.Parent = TargetGuiContainer

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(500, 380)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
MainFrame.BorderSizePixel = 0
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

Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(20, 0)
Title.BackgroundTransparency = 1
Title.Text = "SLIMHUB // STABLE"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Optimized Dragging
local Dragging = false
local DragOffset = Vector2.zero

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        local mousePos = UIS:GetMouseLocation()
        DragOffset = mousePos - Vector2.new(MainFrame.AbsolutePosition.X + (MainFrame.AbsoluteSize.X/2), MainFrame.AbsolutePosition.Y + (MainFrame.AbsoluteSize.Y/2))
    end
end)

UIS.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentMouse = UIS:GetMouseLocation()
        MainFrame.Position = UDim2.fromOffset(currentMouse.X - DragOffset.X, currentMouse.Y - DragOffset.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

local WindowContainer = Instance.new("Frame")
WindowContainer.Name = "WindowContainer"
WindowContainer.Size = UDim2.new(1, 0, 1, -50)
WindowContainer.Position = UDim2.fromOffset(0, 50)
WindowContainer.BackgroundTransparency = 1
WindowContainer.Parent = MainFrame

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = WindowContainer

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.Padding = UDim.new(0, 4)

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -145, 1, -15)
ContentArea.Position = UDim2.fromOffset(140, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = WindowContainer

-- Minimize Layout
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromOffset(30, 30)
MinBtn.Position = UDim2.new(1, -45, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Parent = TopBar

Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

MinBtn.MouseButton1Click:Connect(function()
    Config.IsMinimized = not Config.IsMinimized
    if Config.IsMinimized then
        WindowContainer.Visible = false
        MainFrame.Size = UDim2.fromOffset(500, 50)
        MinBtn.Text = "+"
    else
        MainFrame.Size = UDim2.fromOffset(500, 380)
        WindowContainer.Visible = true
        MinBtn.Text = "-"
    end
end)

-- Tab Creation
local Tabs = {}
local function CreateTab(name)
    local Tab = Instance.new("ScrollingFrame")
    Tab.Size = UDim2.fromScale(1, 1)
    Tab.BackgroundTransparency = 1
    Tab.CanvasSize = UDim2.fromScale(0, 1.2)
    Tab.ScrollBarThickness = 2
    Tab.Visible = false
    Tab.Parent = ContentArea
    
    local Layout = Instance.new("UIListLayout", Tab)
    Layout.Padding = UDim.new(0, 8)
    
    Tabs[name] = Tab
    return Tab
end

CreateTab("Main")
Tabs.Main.Visible = true

-- Control Components
local function CreateSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -10, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Section.BorderSizePixel = 0
    Section.Parent = parent
    
    Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 10)
    
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
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.Position = UDim2.fromOffset(0, 36)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.BackgroundTransparency = 1
    Content.Parent = Section
    
    local List = Instance.new("UIListLayout", Content)
    List.Padding = UDim.new(0, 6)
    
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
    ToggleBtn.Position = UDim2.new(1, -58, 0.5, -12)
    ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 45)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Row
    
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 45)
        if callback then callback(Config[configKey]) end
    end)
end

-- Build Interface Interface
local MainSection = CreateSection(Tabs.Main, "Movement Modules")

CreateToggle(MainSection, "Fly Mode", "Flying")
CreateToggle(MainSection, "Noclip", "Noclip")
CreateToggle(MainSection, "Speed Modifiers", "SpeedHack", function(state)
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = state and Config.HackSpeed or 16 end
end)

-- Global Listeners
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.MenuKeybind then
        Config.MenuOpen = not Config.MenuOpen
        MainFrame.Visible = Config.MenuOpen
    elseif input.KeyCode == Enum.KeyCode.Space and Config.InfiniteJump then
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.Flying then
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
            
            if move.Magnitude > 0 then
                root.AssemblyLinearVelocity = move.Unit * Config.FlySpeed
            else
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip then
        local char = Player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)
