-- Cleaned up UI Script // No AI Boilerplate
task.wait(0.5)

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local coreGui = game:GetService("CoreGui")

local player = players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variables
local activeTab = "Main"
local isMinimized = false
local isTweening = false

-- Dragging physics states
local mainDragging = false
local trayDragging = false
local dragStart, startPos
local dragDistance = 0

-- Liquid properties
local lastTrayPos = Vector2.new(0, 0)
local baseSize = 40 -- Shrunk down from 52 for a cleaner look

-- Container
local gui = Instance.new("ScreenGui")
gui.Name = "SlimHub"
gui.ResetOnSpawn = false
gui.Parent = coreGui

-- Main Menu
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(500, 380)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(40, 40, 50)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Topbar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

-- Fixes corner showing on bottom of topbar
local topBarCover = Instance.new("Frame")
topBarCover.Size = UDim2.new(1, 0, 0, 15)
topBarCover.Position = UDim2.new(0, 0, 1, -15)
topBarCover.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
topBarCover.BorderSizePixel = 0
topBarCover.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.fromOffset(20, 0)
title.BackgroundTransparency = 1
title.Text = "SLIMHUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(30, 30)
minBtn.Position = UDim2.new(1, -45, 0.5, -15)
minBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Parent = topBar

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = minBtn

-- Liquid Minimize Circle
local trayBtn = Instance.new("Frame")
trayBtn.Name = "Tray"
trayBtn.Size = UDim2.fromOffset(0, 0)
trayBtn.Position = mainFrame.Position
trayBtn.AnchorPoint = Vector2.new(0.5, 0.5)
trayBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
trayBtn.Visible = false
trayBtn.ZIndex = 10
trayBtn.Parent = gui

local trayCorner = Instance.new("UICorner")
trayCorner.CornerRadius = UDim.new(1, 0)
trayCorner.Parent = trayBtn

local trayStroke = Instance.new("UIStroke")
trayStroke.Color = Color3.fromRGB(0, 255, 150)
trayStroke.Thickness = 2
trayStroke.Parent = trayBtn

local trayLabel = Instance.new("TextLabel")
trayLabel.Size = UDim2.new(1, 0, 1, 0)
trayLabel.BackgroundTransparency = 1
trayLabel.Text = "S"
trayLabel.Font = Enum.Font.GothamBold
trayLabel.TextSize = 18
trayLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
trayLabel.ZIndex = 11
trayLabel.Parent = trayBtn

-- Window Toggle Animation Engine
local function toggleUI()
    if isTweening then return end
    isTweening = true
    isMinimized = not isMinimized
    
    local speedInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local fadeInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if isMinimized then
        local hideMain = tweenService:Create(mainFrame, fadeInfo, {Size = UDim2.fromOffset(0, 0)})
        hideMain:Play()
        hideMain.Completed:Connect(function()
            mainFrame.Visible = false
            trayBtn.Position = mainFrame.Position
            trayBtn.Size = UDim2.fromOffset(0, 0)
            trayBtn.Visible = true
            
            local showTray = tweenService:Create(trayBtn, speedInfo, {Size = UDim2.fromOffset(baseSize, baseSize)})
            showTray:Play()
            showTray.Completed:Connect(function()
                lastTrayPos = Vector2.new(trayBtn.AbsolutePosition.X + (baseSize/2), trayBtn.AbsolutePosition.Y + (baseSize/2))
                isTweening = false
            end)
        end)
    else
        local hideTray = tweenService:Create(trayBtn, fadeInfo, {Size = UDim2.fromOffset(0, 0)})
        hideTray:Play()
        hideTray.Completed:Connect(function()
            trayBtn.Visible = false
            mainFrame.Position = trayBtn.Position
            mainFrame.Visible = true
            
            local showMain = tweenService:Create(mainFrame, speedInfo, {Size = UDim2.fromOffset(500, 380)})
            showMain:Play()
            showMain.Completed:Connect(function()
                isTweening = false
            end)
        end)
    end
end

minBtn.MouseButton1Click:Connect(toggleUI)

-- Raw Input Processing (Blocks button click system over-rides)
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

trayBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        trayDragging = true
        dragStart = input.Position
        startPos = trayBtn.Position
        dragDistance = 0
    end
end)

uis.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if mainDragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        elseif trayDragging then
            local delta = input.Position - dragStart
            dragDistance = (input.Position - dragStart).Magnitude
            trayBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if trayDragging then
            trayDragging = false
            if dragDistance < 6 then
                toggleUI()
            else
                tweenService:Create(trayBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.fromOffset(baseSize, baseSize)
                }):Play()
            end
        end
        mainDragging = false
    end
end)

-- Liquid Core System (Strictly deformation physics only)
runService.RenderStepped:Connect(function()
    if isMinimized and trayBtn.Visible then
        local center = Vector2.new(trayBtn.AbsolutePosition.X + (trayBtn.AbsoluteSize.X/2), trayBtn.AbsolutePosition.Y + (trayBtn.AbsoluteSize.Y/2))
        local velocity = center - lastTrayPos
        local speed = velocity.Magnitude
        
        if speed > 0.1 then
            -- Structural Squish Calculations
            local stretch = math.clamp(1 + (speed / 35), 1, 1.4)
            local squeeze = math.clamp(1 - (speed / 55), 0.6, 1)
            
            if math.abs(velocity.X) > math.abs(velocity.Y) then
                trayBtn.Size = UDim2.fromOffset(baseSize * stretch, baseSize * squeeze)
            else
                trayBtn.Size = UDim2.fromOffset(baseSize * squeeze, baseSize * stretch)
            end
        else
            if not trayDragging then
                trayBtn.Size = trayBtn.Size:Lerp(UDim2.fromOffset(baseSize, baseSize), 0.2)
            end
        end
        lastTrayPos = center
    end
end)
