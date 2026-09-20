--[[
    FARM MONEY GUI
    LocalScript
    StarterPlayer > StarterPlayerScripts

    Возможности:
    • FARM MONEY
    • Полёт к coin_server
    • Настройка скорости
    • Открытие/закрытие меню
    • Кнопка открытия в левом нижнем углу
    • Крестик закрытия
    • Перемещение меню мышью/пальцем
    • Поддержка Touch + Mouse
    • Автоматический сброс после респавна
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DEFAULT_SPEED = 16
local MIN_SPEED = 8
local MAX_SPEED = 100
local TARGET_NAME = "coin_server"
local CONTAINER_NAME = "CoinContainer"

local currentSpeed = DEFAULT_SPEED
local isFlying = false
local activeTween = nil

local oldGui = playerGui:FindFirstChild("FarmMoneyGui")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmMoneyGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.AnchorPoint = Vector2.new(0, 1)
openButton.Position = UDim2.new(0, 18, 1, -18)
openButton.Size = UDim2.new(0, 58, 0, 58)
openButton.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
openButton.BackgroundTransparency = 0.05
openButton.BorderSizePixel = 0
openButton.AutoButtonColor = false
openButton.Text = "$"
openButton.TextColor3 = Color3.fromRGB(120, 255, 160)
openButton.TextSize = 26
openButton.Font = Enum.Font.GothamBold
openButton.ZIndex = 20
openButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openButton

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(90, 220, 140)
openStroke.Thickness = 2
openStroke.Transparency = 0.25
openStroke.Parent = openButton

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, 270, 0, 185)
main.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
main.BackgroundTransparency = 0.03
main.BorderSizePixel = 0
main.Visible = true
main.ZIndex = 5
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(75, 80, 105)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.15
mainStroke.Parent = main

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundColor3 = Color3.fromRGB(28, 31, 45)
topBar.BorderSizePixel = 0
topBar.ZIndex = 6
topBar.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 16)
topCorner.Parent = topBar

local topMask = Instance.new("Frame")
topMask.Position = UDim2.new(0, 0, 1, -15)
topMask.Size = UDim2.new(1, 0, 0, 15)
topMask.BackgroundColor3 = Color3.fromRGB(28, 31, 45)
topMask.BorderSizePixel = 0
topMask.ZIndex = 6
topMask.Parent = topBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 15, 0, 5)
title.Size = UDim2.new(1, -60, 0, 22)
title.Text = "FARM MONEY"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 7
title.Parent = topBar

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0, 15, 0, 25)
subtitle.Size = UDim2.new(1, -60, 0, 15)
subtitle.Text = "Coin farming system"
subtitle.TextColor3 = Color3.fromRGB(145, 150, 170)
subtitle.TextSize = 10
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 7
subtitle.Parent = topBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -8, 0, 8)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.BackgroundColor3 = Color3.fromRGB(55, 58, 72)
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(220, 225, 235)
closeButton.TextSize = 22
closeButton.Font = Enum.Font.GothamBold
closeButton.ZIndex = 10
closeButton.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local statusFrame = Instance.new("Frame")
statusFrame.Name = "Status"
statusFrame.Position = UDim2.new(0, 15, 0, 58)
statusFrame.Size = UDim2.new(1, -30, 0, 28)
statusFrame.BackgroundColor3 = Color3.fromRGB(30, 34, 47)
statusFrame.BorderSizePixel = 0
statusFrame.ZIndex = 6
statusFrame.Parent = main

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusFrame

local statusDot = Instance.new("Frame")
statusDot.Name = "Dot"
statusDot.AnchorPoint = Vector2.new(0, 0.5)
statusDot.Position = UDim2.new(0, 9, 0.5, 0)
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.BackgroundColor3 = Color3.fromRGB(120, 255, 160)
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 7
statusDot.Parent = statusFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 25, 0, 0)
statusLabel.Size = UDim2.new(1, -30, 1, 0)
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(190, 195, 210)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 7
statusLabel.Parent = statusFrame

local farmBtn = Instance.new("TextButton")
farmBtn.Name = "FarmButton"
farmBtn.Position = UDim2.new(0, 15, 0, 94)
farmBtn.Size = UDim2.new(1, -30, 0, 42)
farmBtn.BackgroundColor3 = Color3.fromRGB(70, 190, 110)
farmBtn.BorderSizePixel = 0
farmBtn.AutoButtonColor = false
farmBtn.Text = "FARM MONEY"
farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmBtn.TextSize = 15
farmBtn.Font = Enum.Font.GothamBold
farmBtn.ZIndex = 6
farmBtn.Parent = main

local farmCorner = Instance.new("UICorner")
farmCorner.CornerRadius = UDim.new(0, 10)
farmCorner.Parent = farmBtn

local farmStroke = Instance.new("UIStroke")
farmStroke.Color = Color3.fromRGB(130, 255, 170)
farmStroke.Thickness = 1.3
farmStroke.Transparency = 0.35
farmStroke.Parent = farmBtn

local farmGradient = Instance.new("UIGradient")
farmGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 215, 135)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 165, 95))
})
farmGradient.Rotation = 90
farmGradient.Parent = farmBtn

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.BackgroundTransparency = 1
speedLabel.Position = UDim2.new(0, 15, 0, 143)
speedLabel.Size = UDim2.new(1, -30, 0, 16)
speedLabel.Text = "Speed: " .. currentSpeed
speedLabel.TextColor3 = Color3.fromRGB(175, 180, 195)
speedLabel.TextSize = 11
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.ZIndex = 6
speedLabel.Parent = main

local sliderBg = Instance.new("Frame")
sliderBg.Name = "Slider"
sliderBg.Position = UDim2.new(0, 15, 0, 165)
sliderBg.Size = UDim2.new(1, -30, 0, 8)
sliderBg.BackgroundColor3 = Color3.fromRGB(48, 52, 68)
sliderBg.BorderSizePixel = 0
sliderBg.ZIndex = 6
sliderBg.Parent = main

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = sliderBg

local initialAlpha = (currentSpeed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)

local sliderFill = Instance.new("Frame")
sliderFill.Name = "Fill"
sliderFill.Size = UDim2.new(initialAlpha, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(90, 215, 135)
sliderFill.BorderSizePixel = 0
sliderFill.ZIndex = 7
sliderFill.Parent = sliderBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = sliderFill

local sliderKnob = Instance.new("Frame")
sliderKnob.Name = "Knob"
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Position = UDim2.new(initialAlpha, 0, 0.5, 0)
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 8
sliderKnob.Parent = sliderBg

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = sliderKnob

local function pressEffect(button)
	local originalSize = button.Size
	local originalPosition = button.Position

	button.Size = UDim2.new(
		originalSize.X.Scale,
		originalSize.X.Offset - 4,
		originalSize.Y.Scale,
		originalSize.Y.Offset - 4
	)

	button.Position = UDim2.new(
		originalPosition.X.Scale,
		originalPosition.X.Offset + 2,
		originalPosition.Y.Scale,
		originalPosition.Y.Offset + 2
	)

	task.delay(0.08, function()
		if button and button.Parent then
			button.Size = originalSize
			button.Position = originalPosition
		end
	end)
end

local sliderDragging = false

local function updateSlider(inputX)
	local absolutePosition = sliderBg.AbsolutePosition
	local absoluteSize = sliderBg.AbsoluteSize

	if absoluteSize.X <= 0 then
		return
	end

	local alpha = math.clamp(
		(inputX - absolutePosition.X) / absoluteSize.X,
		0,
		1
	)

	local newSpeed = math.floor(
		MIN_SPEED + alpha * (MAX_SPEED - MIN_SPEED) + 0.5
	)

	currentSpeed = newSpeed
	sliderFill.Size = UDim2.new(alpha, 0, 1, 0)
	sliderKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
	speedLabel.Text = "Speed: " .. currentSpeed
end

sliderBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		sliderDragging = true
		updateSlider(input.Position.X)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not sliderDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		updateSlider(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		sliderDragging = false
	end
end)

local function findCoinServer()
	local container = workspace:FindFirstChild(CONTAINER_NAME, true)

	if not container then
		return nil
	end

	-- Ищем coin_server без учёта регистра:
	-- coin_server
	-- Coin_Server
	-- COin_SErver
	-- COIN_SERVER
	-- и любые другие варианты регистра.
	local targetLower = string.lower(TARGET_NAME)

	for _, descendant in ipairs(container:GetDescendants()) do
		if string.lower(descendant.Name) == targetLower then
			return descendant
		end
	end

	-- На случай, если сам CoinContainer является нужным объектом.
	if string.lower(container.Name) == targetLower then
		return container
	end

	return nil
end

local function getTargetCFrame(target)
	if not target then
		return nil
	end

	if target:IsA("BasePart") then
		return target.CFrame
	end

	if target:IsA("Model") then
		if target.PrimaryPart then
			return target.PrimaryPart.CFrame
		end

		return target:GetPivot()
	end

	if target:IsA("Attachment") then
		return target.WorldCFrame
	end

	return nil
end

local function stopFly()
	if activeTween then
		pcall(function()
			activeTween:Cancel()
		end)

		activeTween = nil
	end

	local character = player.Character

	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if root then
			root.Anchored = false
		end

		if humanoid then
			humanoid.PlatformStand = false

			pcall(function()
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end)
		end
	end

	isFlying = false
	farmBtn.Text = "FARM MONEY"
	statusLabel.Text = "Ready"
	statusDot.BackgroundColor3 = Color3.fromRGB(120, 255, 160)
end

local function startFly()
	if isFlying then
		stopFly()
		return
	end

	local target = findCoinServer()

	if not target then
		statusLabel.Text = "coin_server not found"
		statusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)

		warn("[FarmMoney] coin_server не найден в " .. CONTAINER_NAME .. "!")
		return
	end

	local targetCFrame = getTargetCFrame(target)

	if not targetCFrame then
		statusLabel.Text = "Invalid target"
		statusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)

		warn("[FarmMoney] Не удалось получить позицию coin_server!")
		return
	end

	local character = player.Character

	if not character then
		character = player.CharacterAdded:Wait()
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		root = character:WaitForChild("HumanoidRootPart", 5)
	end

	if not root then
		statusLabel.Text = "Character error"
		statusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)

		warn("[FarmMoney] HumanoidRootPart не найден!")
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	isFlying = true
	farmBtn.Text = "STOP FARM"
	statusLabel.Text = "Flying to coin..."
	statusDot.BackgroundColor3 = Color3.fromRGB(255, 210, 80)

	if humanoid then
		humanoid.PlatformStand = true

		pcall(function()
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		end)
	end

	root.Anchored = true

	local distance = (targetCFrame.Position - root.Position).Magnitude
	local duration = distance / math.max(currentSpeed, 1)
	duration = math.max(duration, 0.05)

	local tweenInfo = TweenInfo.new(
		duration,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false,
		0
	)

	local tween = TweenService:Create(
		root,
		tweenInfo,
		{ CFrame = targetCFrame }
	)

	activeTween = tween

	tween.Completed:Connect(function()
		if activeTween ~= tween then
			return
		end

		activeTween = nil
		stopFly()
	end)

	tween:Play()
end

farmBtn.MouseButton1Click:Connect(function()
	pressEffect(farmBtn)
	startFly()
end)

openButton.MouseButton1Click:Connect(function()
	pressEffect(openButton)
	main.Visible = true
	openButton.Visible = false
end)

closeButton.MouseButton1Click:Connect(function()
	pressEffect(closeButton)
	main.Visible = false
	openButton.Visible = true
end)

local draggingMenu = false
local dragStart = nil
local startPosition = nil
local dragInput = nil

local function updateMenuDrag(input)
	if not draggingMenu or not dragStart or not startPosition then
		return
	end

	local delta = input.Position - dragStart

	main.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		local mousePos = input.Position
		local closePos = closeButton.AbsolutePosition
		local closeSize = closeButton.AbsoluteSize

		local insideClose =
			mousePos.X >= closePos.X
			and mousePos.X <= closePos.X + closeSize.X
			and mousePos.Y >= closePos.Y
			and mousePos.Y <= closePos.Y + closeSize.Y

		if insideClose then
			return
		end

		draggingMenu = true
		dragStart = input.Position
		startPosition = main.Position
		dragInput = input
	end
end)

topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingMenu and input == dragInput then
		updateMenuDrag(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		draggingMenu = false
		dragStart = nil
		startPosition = nil
		dragInput = nil
	end
end)

player.CharacterAdded:Connect(function()
	if activeTween then
		pcall(function()
			activeTween:Cancel()
		end)

		activeTween = nil
	end

	isFlying = false
	farmBtn.Text = "FARM MONEY"
	statusLabel.Text = "Ready"
	statusDot.BackgroundColor3 = Color3.fromRGB(120, 255, 160)
end)

print("[FarmMoney] GUI loaded successfully.")
