-- // SLIMHUB V2.1 - Clean & Fluid
-- // No emojis, smooth dragging, proper minimize animation

task.wait(0.5)

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // UTILITY
local function GetCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function Tween(obj, info, props)
	local tween = TweenService:Create(obj, TweenInfo.new(unpack(info)), props)
	tween:Play()
	return tween
end

-- // CONFIG
local Config = {
	Flying = false,
	Noclip = false,
	SpeedHack = false,
	InfiniteJump = false,
	ClickTP = false,
	Invisible = false,
	
	ESPEnabled = false,
	ESPBoxes = true,
	ESPNames = true,
	ESPTracers = true,
	ESPRainbow = false,
	ESPHealth = true,
	ESPMaxDistance = 1000,
	
	SilentAim = false,
	SilentAimFOV = 150,
	SilentAimTeamCheck = true,
	SilentAimWallCheck = false,
	SilentAimHitbox = "Head",
	SilentAimSmoothness = 0,
	
	FlySpeed = 50,
	NormalSpeed = 16,
	HackSpeed = 100,
	
	MenuKeybind = Enum.KeyCode.RightShift,
	IsMinimized = false,
	MenuOpen = true,
	ActiveTab = "Main"
}

-- // STATE
local ESPObjects = {}
local PrisonLifeHooks = {}
local RainbowHue = 0
local ToggleCallbacks = {}

-- // UI CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SlimHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.fromOffset(520, 380)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 50)
MainStroke.Thickness = 1.5

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 14)

local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 20)
TopCover.Position = UDim2.new(0, 0, 1, -20)
TopCover.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

-- Title
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
MinBtn.Name = "Minimize"
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
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -50)
Sidebar.Position = UDim2.fromOffset(0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "Content"
ContentArea.Size = UDim2.new(1, -145, 1, -65)
ContentArea.Position = UDim2.fromOffset(140, 60)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- // TABS
local Tabs = {}

local function CreateTab(name)
	local TabFrame = Instance.new("ScrollingFrame")
	TabFrame.Name = name .. "Tab"
	TabFrame.Size = UDim2.fromScale(1, 1)
	TabFrame.BackgroundTransparency = 1
	TabFrame.CanvasSize = UDim2.fromScale(0, 1.4)
	TabFrame.ScrollBarThickness = 3
	TabFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
	TabFrame.Visible = false
	TabFrame.Parent = ContentArea
	
	local Layout = Instance.new("UIListLayout", TabFrame)
	Layout.Padding = UDim.new(0, 8)
	
	Tabs[name] = TabFrame
	return TabFrame
end

CreateTab("Main")
CreateTab("ESP")
CreateTab("Prison")
CreateTab("Settings")

Tabs.Main.Visible = true

-- // TAB BUTTONS
local TabButtons = {}

local function CreateTabButton(name)
	local Btn = Instance.new("TextButton")
	Btn.Name = name .. "Btn"
	Btn.Size = UDim2.new(1, -10, 0, 40)
	Btn.Position = UDim2.fromOffset(5, 0)
	Btn.BackgroundColor3 = name == "Main" and Color3.fromRGB(28, 28, 36) or Color3.fromRGB(15, 15, 19)
	Btn.Text = ""
	Btn.LayoutOrder = #TabButtons + 1
	Btn.Parent = Sidebar
	
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
	
	local Indicator = Instance.new("Frame")
	Indicator.Name = "Indicator"
	Indicator.Size = UDim2.new(0, 3, 0.5, 0)
	Indicator.Position = UDim2.fromOffset(8, 0.25)
	Indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
	Indicator.BorderSizePixel = 0
	Indicator.Visible = name == "Main"
	Indicator.Parent = Btn
	
	Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 2)
	
	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.Size = UDim2.new(1, -20, 1, 0)
	Label.Position = UDim2.fromOffset(20, 0)
	Label.BackgroundTransparency = 1
	Label.Text = name:upper()
	Label.Font = Enum.Font.GothamSemibold
	Label.TextSize = 12
	Label.TextColor3 = name == "Main" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Btn
	
	TabButtons[name] = {Button = Btn, Indicator = Indicator, Label = Label}
	
	Btn.MouseButton1Click:Connect(function()
		Config.ActiveTab = name
		
		for tabName, tab in pairs(Tabs) do
			tab.Visible = tabName == name
		end
		
		for btnName, data in pairs(TabButtons) do
			local active = btnName == name
			data.Indicator.Visible = active
			Tween(data.Label, {0.2}, {TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150)})
			Tween(data.Button, {0.2}, {BackgroundColor3 = active and Color3.fromRGB(28, 28, 36) or Color3.fromRGB(15, 15, 19)})
		end
	end)
	
	Btn.MouseEnter:Connect(function()
		if name ~= Config.ActiveTab then
			Tween(Btn, {0.15}, {BackgroundColor3 = Color3.fromRGB(22, 22, 28)})
		end
	end)
	
	Btn.MouseLeave:Connect(function()
		if name ~= Config.ActiveTab then
			Tween(Btn, {0.15}, {BackgroundColor3 = Color3.fromRGB(15, 15, 19)})
		end
	end)
end

CreateTabButton("Main")
CreateTabButton("ESP")
CreateTabButton("Prison")
CreateTabButton("Settings")

-- // COMPONENTS
local function CreateSection(parent, title)
	local Section = Instance.new("Frame")
	Section.Size = UDim2.new(1, -10, 0, 0)
	Section.AutomaticSize = Enum.AutomaticSize.Y
	Section.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	Section.BorderSizePixel = 0
	Section.Parent = parent
	
	Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 10)
	
	local SectionStroke = Instance.new("UIStroke", Section)
	SectionStroke.Color = Color3.fromRGB(35, 35, 45)
	SectionStroke.Thickness = 1
	
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
	Content.Name = "Content"
	Content.Size = UDim2.new(1, 0, 0, 0)
	Content.Position = UDim2.fromOffset(0, 42)
	Content.AutomaticSize = Enum.AutomaticSize.Y
	Content.BackgroundTransparency = 1
	Content.Parent = Section
	
	local ContentLayout = Instance.new("UIListLayout", Content)
	ContentLayout.Padding = UDim.new(0, 6)
	ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local Padding = Instance.new("UIPadding", Content)
	Padding.PaddingLeft = UDim.new(0, 15)
	Padding.PaddingRight = UDim.new(0, 15)
	Padding.PaddingBottom = UDim.new(0, 15)
	
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
	
	local function UpdateState(state)
		Config[configKey] = state
		Tween(ToggleBtn, {0.2, Enum.EasingStyle.Quart}, {BackgroundColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 45)})
		Tween(Knob, {0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)})
		if callback then callback(state) end
	end
	
	ToggleBtn.MouseButton1Click:Connect(function()
		UpdateState(not Config[configKey])
	end)
	
	ToggleCallbacks[configKey] = UpdateState
	return UpdateState
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
	
	local Knob = Instance.new("Frame")
	Knob.Size = UDim2.fromOffset(14, 14)
	Knob.Position = UDim2.new((Config[configKey] - min) / (max - min), -7, 0.5, -7)
	Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Knob.BorderSizePixel = 0
	Knob.Parent = Track
	
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
	
	local Dragging = false
	
	local function Update(input)
		local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
		Fill.Size = UDim2.new(pos, 0, 1, 0)
		Knob.Position = UDim2.new(pos, -7, 0.5, -7)
		local value = math.floor(min + (pos * (max - min)))
		Config[configKey] = value
		ValueLabel.Text = tostring(value)
		if callback then callback(value) end
	end
	
	Track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			Update(input)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			Update(input)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false
		end
	end)
end

local function CreateDropdown(parent, text, configKey, options, callback)
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
	
	local DropdownBtn = Instance.new("TextButton")
	DropdownBtn.Size = UDim2.fromOffset(120, 28)
	DropdownBtn.Position = UDim2.new(1, -120, 0.5, -14)
	DropdownBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	DropdownBtn.Text = Config[configKey]:upper()
	DropdownBtn.Font = Enum.Font.GothamSemibold
	DropdownBtn.TextSize = 11
	DropdownBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
	DropdownBtn.Parent = Row
	
	Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 6)
	
	local Stroke = Instance.new("UIStroke", DropdownBtn)
	Stroke.Color = Color3.fromRGB(45, 45, 55)
	Stroke.Thickness = 1
	
	DropdownBtn.MouseButton1Click:Connect(function()
		local currentIndex = table.find(options, Config[configKey]) or 1
		local nextIndex = currentIndex % #options + 1
		Config[configKey] = options[nextIndex]
		DropdownBtn.Text = Config[configKey]:upper()
		if callback then callback(Config[configKey]) end
	end)
end

-- // BUILD MAIN TAB
local MainSection = CreateSection(Tabs.Main, "Movement")
CreateToggle(MainSection, "Fly", "Flying")
CreateSlider(MainSection, "Fly Speed", "FlySpeed", 16, 250)
CreateToggle(MainSection, "Speed Hack", "SpeedHack", function(state)
	local char = GetCharacter()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = state and Config.HackSpeed or Config.NormalSpeed end
end)
CreateSlider(MainSection, "Walk Speed", "HackSpeed", 16, 150, function(val)
	if Config.SpeedHack then
		local char = GetCharacter()
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val end
	end
end)
CreateToggle(MainSection, "Noclip", "Noclip")
CreateToggle(MainSection, "Infinite Jump", "InfiniteJump")
CreateToggle(MainSection, "Click TP (Ctrl+Click)", "ClickTP")

-- // BUILD ESP TAB
local ESPSection = CreateSection(Tabs.ESP, "Visuals")
CreateToggle(ESPSection, "ESP Enabled", "ESPEnabled")
CreateToggle(ESPSection, "Show Boxes", "ESPBoxes")
CreateToggle(ESPSection, "Show Names", "ESPNames")
CreateToggle(ESPSection, "Show Tracers", "ESPTracers")
CreateToggle(ESPSection, "Show Health", "ESPHealth")
CreateToggle(ESPSection, "Rainbow Mode", "ESPRainbow")
CreateSlider(ESPSection, "Max Distance", "ESPMaxDistance", 100, 2000)

-- // BUILD PRISON TAB
local PrisonSection = CreateSection(Tabs.Prison, "Combat")
CreateToggle(PrisonSection, "Silent Aim", "SilentAim")
CreateSlider(PrisonSection, "FOV Size", "SilentAimFOV", 50, 400)
CreateSlider(PrisonSection, "Smoothness", "SilentAimSmoothness", 0, 100)
CreateToggle(PrisonSection, "Team Check", "SilentAimTeamCheck")
CreateToggle(PrisonSection, "Wall Check", "SilentAimWallCheck")
CreateDropdown(PrisonSection, "Hitbox", "SilentAimHitbox", {"Head", "Torso", "HumanoidRootPart"})

-- // BUILD SETTINGS TAB
local SettingsSection = CreateSection(Tabs.Settings, "Config")
CreateToggle(SettingsSection, "Show FPS", "ShowFPS")

-- // FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Filled = false
FOVCircle.NumSides = 64

-- // ESP SYSTEM
local function CreateESPObject(player)
	if ESPObjects[player] then return end
	
	local container = Instance.new("Folder")
	container.Name = "ESP_" .. player.Name
	container.Parent = ScreenGui
	
	ESPObjects[player] = {
		Container = container,
		Beams = {},
		Billboard = nil,
		Box = nil
	}
end

Players.PlayerAdded:Connect(function(player)
	if player ~= LocalPlayer then
		CreateESPObject(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if ESPObjects[player] then
		ESPObjects[player].Container:Destroy()
		ESPObjects[player] = nil
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		CreateESPObject(player)
	end
end

-- // SILENT AIM
local function GetSilentAimTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local closest = nil
	local closestDist = Config.SilentAimFOV
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if Config.SilentAimTeamCheck and player.Team == LocalPlayer.Team then
				continue
			end
			
			local targetPart = player.Character:FindFirstChild(Config.SilentAimHitbox) 
				or player.Character:FindFirstChild("HumanoidRootPart")
			
			if targetPart then
				local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
					if onScreen then
						local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
						if dist < closestDist then
							if Config.SilentAimWallCheck then
								local params = RaycastParams.new()
								params.FilterDescendantsInstances = {GetCharacter(), player.Character}
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
local function HookPrisonLife()
	for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
		if obj:IsA("RemoteEvent") then
			local name = obj.Name:lower()
			if name:find("shoot") or name:find("fire") or name:find("gun") then
				local oldFire = obj.FireServer
				PrisonLifeHooks[obj] = oldFire
				
				obj.FireServer = function(self, ...)
					local args = {...}
					if Config.SilentAim and #args >= 2 then
						local target = GetSilentAimTarget()
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
end

-- // FEATURE LOOPS

-- Fly
RunService.RenderStepped:Connect(function()
	if Config.Flying then
		local char = GetCharacter()
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local move = Vector3.zero
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
			
			if move.Magnitude > 0 then
				root.AssemblyLinearVelocity = move.Unit * Config.FlySpeed
			else
				root.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end
end)

-- Noclip
RunService.Stepped:Connect(function()
	if Config.Noclip then
		local char = GetCharacter()
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Infinite Jump
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if Config.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
		local char = GetCharacter()
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- Click TP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if Config.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 
		and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		
		local char = GetCharacter()
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local mousePos = UserInputService:GetMouseLocation()
			local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
			
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {char}
			params.FilterType = Enum.RaycastFilterType.Exclude
			
			local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
			if result then
				root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
			end
		end
	end
end)

-- ESP & Silent Aim Visuals
RunService.RenderStepped:Connect(function(deltaTime)
	RainbowHue = (RainbowHue + deltaTime * 0.5) % 1
	local rainbowColor = Color3.fromHSV(RainbowHue, 1, 1)
	local espColor = Config.ESPRainbow and rainbowColor or Color3.fromRGB(0, 255, 150)
	
	-- FOV Circle
	FOVCircle.Visible = Config.SilentAim
	FOVCircle.Position = UserInputService:GetMouseLocation()
	FOVCircle.Radius = Config.SilentAimFOV
	FOVCircle.Color = espColor
	
	-- ESP
	for player, data in pairs(ESPObjects) do
		if Config.ESPEnabled and player.Character then
			local char = player.Character
			local root = char:FindFirstChild("HumanoidRootPart")
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			
			if root and humanoid and humanoid.Health > 0 then
				local distance = (root.Position - Camera.CFrame.Position).Magnitude
				if distance <= Config.ESPMaxDistance then
					local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
					
					if onScreen then
						-- Tracer using Beam
						if Config.ESPTracers then
							if not data.Beams.Tracer then
								local attachment0 = Instance.new("Attachment")
								local attachment1 = Instance.new("Attachment")
								
								local beam = Instance.new("Beam")
								beam.Color = ColorSequence.new(espColor)
								beam.Width0 = 0.03
								beam.Width1 = 0.03
								beam.FaceCamera = true
								beam.Attachment0 = attachment0
								beam.Attachment1 = attachment1
								beam.Parent = data.Container
								
								data.Beams.Tracer = {Beam = beam, Att0 = attachment0, Att1 = attachment1}
							end
							
							local localRoot = GetCharacter():FindFirstChild("HumanoidRootPart")
							if localRoot then
								data.Beams.Tracer.Att0.Parent = localRoot
								data.Beams.Tracer.Att1.Parent = root
								data.Beams.Tracer.Att0.WorldPosition = Camera.CFrame.Position
								data.Beams.Tracer.Att1.WorldPosition = root.Position
								data.Beams.Tracer.Beam.Color = ColorSequence.new(espColor)
								data.Beams.Tracer.Beam.Enabled = true
							end
						elseif data.Beams.Tracer then
							data.Beams.Tracer.Beam.Enabled = false
						end
						
						-- Billboard
						if Config.ESPNames or Config.ESPHealth then
							if not data.Billboard then
								data.Billboard = Instance.new("BillboardGui")
								data.Billboard.Size = UDim2.fromOffset(120, 40)
								data.Billboard.AlwaysOnTop = true
								data.Billboard.Parent = data.Container
								
								local nameLabel = Instance.new("TextLabel")
								nameLabel.Name = "Name"
								nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
								nameLabel.BackgroundTransparency = 1
								nameLabel.Font = Enum.Font.GothamBold
								nameLabel.TextSize = 12
								nameLabel.TextColor3 = espColor
								nameLabel.Parent = data.Billboard
								
								local healthBar = Instance.new("Frame")
								healthBar.Name = "HealthBar"
								healthBar.Size = UDim2.new(0.8, 0, 0, 3)
								healthBar.Position = UDim2.new(0.1, 0, 0.65, 0)
								healthBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
								healthBar.BorderSizePixel = 0
								healthBar.Parent = data.Billboard
								
								local fill = Instance.new("Frame")
								fill.Name = "Fill"
								fill.Size = UDim2.new(1, 0, 1, 0)
								fill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
								fill.BorderSizePixel = 0
								fill.Parent = healthBar
							end
							
							data.Billboard.Enabled = true
							data.Billboard.Adornee = root
							
							local nameLabel = data.Billboard:FindFirstChild("Name")
							local healthBar = data.Billboard:FindFirstChild("HealthBar")
							
							if nameLabel then
								nameLabel.Visible = Config.ESPNames
								nameLabel.Text = player.Name
								nameLabel.TextColor3 = espColor
							end
							
							if healthBar then
								healthBar.Visible = Config.ESPHealth
								local fill = healthBar:FindFirstChild("Fill")
								if fill then
									local hp = humanoid.Health / humanoid.MaxHealth
									fill.Size = UDim2.new(hp, 0, 1, 0)
									fill.BackgroundColor3 = hp > 0.5 and Color3.fromRGB(0, 255, 100) 
										or hp > 0.25 and Color3.fromRGB(255, 255, 0) 
										or Color3.fromRGB(255, 0, 0)
								end
							end
						end
					end
				end
			end
		else
			for _, beamData in pairs(data.Beams) do
				if beamData.Beam then beamData.Beam.Enabled = false end
			end
			if data.Billboard then
				data.Billboard.Enabled = false
			end
		end
	end
end)

-- // MINIMIZE SYSTEM - FLUID ANIMATION
local MinCircle = Instance.new("TextButton")
MinCircle.Name = "MinCircle"
MinCircle.Size = UDim2.fromOffset(0, 0)
MinCircle.Position = UDim2.new(1, -70, 1, -70)
MinCircle.AnchorPoint = Vector2.new(0.5, 0.5)
MinCircle.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MinCircle.Text = "S"
MinCircle.Font = Enum.Font.GothamBold
MinCircle.TextSize = 22
MinCircle.TextColor3 = Color3.fromRGB(0, 255, 150)
MinCircle.Visible = false
MinCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner", MinCircle)
CircleCorner.CornerRadius = UDim.new(1, 0)

local CircleStroke = Instance.new("UIStroke", MinCircle)
CircleStroke.Color = Color3.fromRGB(0, 255, 150)
CircleStroke.Thickness = 2

-- Minimize animation
MinBtn.MouseButton1Click:Connect(function()
	Config.IsMinimized = true
	
	-- Get position where circle will be
	local circlePos = MinCircle.AbsolutePosition + Vector2.new(25, 25)
	
	-- Animate main frame to that position while shrinking
	Tween(MainFrame, {0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In}, {
		Size = UDim2.fromOffset(0, 0),
		Position = UDim2.fromOffset(circlePos.X, circlePos.Y)
	}).Completed:Wait()
	
	MainFrame.Visible = false
	
	-- Show and animate circle
	MinCircle.Visible = true
	MinCircle.Size = UDim2.fromOffset(0, 0)
	Tween(MinCircle, {0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out}, {
		Size = UDim2.fromOffset(55, 55)
	})
end)

-- Restore animation
MinCircle.MouseButton1Click:Connect(function()
	Config.IsMinimized = false
	
	-- Shrink circle
	Tween(MinCircle, {0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In}, {
		Size = UDim2.fromOffset(0, 0)
	}).Completed:Wait()
	
	MinCircle.Visible = false
	
	-- Restore main frame
	MainFrame.Visible = true
	Tween(MainFrame, {0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
		Size = UDim2.fromOffset(520, 380),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	})
end)

-- Hover effects
MinCircle.MouseEnter:Connect(function()
	Tween(MinCircle, {0.2, Enum.EasingStyle.Quad}, {Size = UDim2.fromOffset(65, 65)})
	Tween(CircleStroke, {0.2}, {Thickness = 3})
end)

MinCircle.MouseLeave:Connect(function()
	Tween(MinCircle, {0.2, Enum.EasingStyle.Quad}, {Size = UDim2.fromOffset(55, 55)})
	Tween(CircleStroke, {0.2}, {Thickness = 2})
end)

-- // DRAGGING - FIXED
local Dragging = false
local DragOffset = nil

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = true
		local mousePos = UserInputService:GetMouseLocation()
		local framePos = MainFrame.AbsolutePosition
		DragOffset = mousePos - framePos
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local mousePos = UserInputService:GetMouseLocation()
		local newPos = mousePos - DragOffset
		MainFrame.Position = UDim2.fromOffset(newPos.X, newPos.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = false
		DragOffset = nil
	end
end)

-- // KEYBINDS
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Config.MenuKeybind then
		if Config.IsMinimized then
			MinCircle.MouseButton1Click:Fire()
		else
			Config.MenuOpen = not Config.MenuOpen
			MainFrame.Visible = Config.MenuOpen
		end
	end
end)

-- // INIT
HookPrisonLife()

-- Entrance animation
MainFrame.Size = UDim2.fromOffset(0, 0)
Tween(MainFrame, {0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
	Size = UDim2.fromOffset(520, 380)
})

print("SlimHub Loaded")
