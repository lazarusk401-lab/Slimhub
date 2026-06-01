local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local function GetCharacter()
	return Player.Character or Player.CharacterAdded:Wait()
end

-- STATES

local Flying = false
local Noclip = false
local FlySpeed = 50

-- UI

local Gui = Instance.new("ScreenGui")
Gui.Name = "SlimJim"
Gui.ResetOnSpawn = false
Gui.Parent = Player.PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(350, 180)
Frame.Position = UDim2.new(0.5, -175, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BorderSizePixel = 0
Frame.Parent = Gui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundTransparency = 1
Title.Text = "SLIM JIM"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(0,255,100)
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,-20,0,25)
Status.Position = UDim2.fromOffset(10,40)
Status.BackgroundTransparency = 1
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Font = Enum.Font.Code
Status.TextSize = 16
Status.TextColor3 = Color3.new(1,1,1)
Status.Parent = Frame

local CommandBox = Instance.new("TextBox")
CommandBox.Size = UDim2.new(1,-20,0,35)
CommandBox.Position = UDim2.new(0,10,1,-45)
CommandBox.PlaceholderText = "speed 50 | fly | noclip"
CommandBox.Text = ""
CommandBox.Font = Enum.Font.Code
CommandBox.TextSize = 18
CommandBox.Parent = Frame

Instance.new("UICorner", CommandBox).CornerRadius = UDim.new(0,8)

local function UpdateStatus()
	Status.Text =
		("FLY: %s | NOCLIP: %s | SPEED: %d")
		:format(
			Flying and "ON" or "OFF",
			Noclip and "ON" or "OFF",
			GetCharacter():WaitForChild("Humanoid").WalkSpeed
		)
end

UpdateStatus()

-- COMMAND SYSTEM

local Commands = {}

Commands.speed = function(args)
	local num = tonumber(args[1])

	if num then
		GetCharacter():WaitForChild("Humanoid").WalkSpeed = num
	end
end

Commands.fly = function()
	Flying = true
end

Commands.unfly = function()
	Flying = false
end

Commands.noclip = function()
	Noclip = true
end

Commands.clip = function()
	Noclip = false
end

local function loadstring(commandText)
	local split = string.split(commandText," ")

	local cmd = string.lower(split[1] or "")

	table.remove(split,1)

	if Commands[cmd] then
		Commands[cmd](split)
	end

	UpdateStatus()
end

CommandBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed then
		return
	end

	loadstring(CommandBox.Text)
	CommandBox.Text = ""
end)

-- FLY

RunService.RenderStepped:Connect(function()
	if not Flying then
		return
	end

	local Character = GetCharacter()
	local Root = Character:FindFirstChild("HumanoidRootPart")

	if not Root then
		return
	end

	local Cam = workspace.CurrentCamera
	local Move = Vector3.zero

	if UIS:IsKeyDown(Enum.KeyCode.W) then
		Move += Cam.CFrame.LookVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.S) then
		Move -= Cam.CFrame.LookVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.A) then
		Move -= Cam.CFrame.RightVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.D) then
		Move += Cam.CFrame.RightVector
	end

	if UIS:IsKeyDown(Enum.KeyCode.Space) then
		Move += Vector3.yAxis
	end

	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
		Move -= Vector3.yAxis
	end

	if Move.Magnitude > 0 then
		Root.AssemblyLinearVelocity = Move.Unit * FlySpeed
	else
		Root.AssemblyLinearVelocity = Vector3.zero
	end
end)

-- NOCLIP

RunService.Stepped:Connect(function()
	if not Noclip then
		return
	end

	local Character = GetCharacter()

	for _,v in ipairs(Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end)

-- DRAGGING

local Dragging = false
local DragStart
local StartPos

Title.InputBegan:Connect(function(input)
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

		Frame.Position = UDim2.new(
			StartPos.X.Scale,
			StartPos.X.Offset + Delta.X,
			StartPos.Y.Scale,
			StartPos.Y.Offset + Delta.Y
		)
	end
end)
