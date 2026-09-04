-- LocalScript в StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- 1. СОЗДАНИЕ ИНТЕРФЕЙСА (UI)
-- ==========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Кнопка открыть/закрыть
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 110, 0, 40)
openButton.Position = UDim2.new(0, 10, 0.5, -20)
openButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Text = "Меню [Открыть]"
openButton.Font = Enum.Font.SourceSansBold
openButton.TextSize = 14
openButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openButton

-- Главная панель
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "Панель Управления"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

local function createButton(text, yOffset)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 180, 0, 36)
	btn.Position = UDim2.new(0.5, -90, 0, yOffset)
	btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 14
	btn.Parent = mainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	return btn
end

local godModeBtn = createButton("Бессмертие: ВЫКЛ", 45)
local infJumpBtn = createButton("Inf Jump: ВЫКЛ", 90)

-- Кнопки Флинга
local flingUpBtn = createButton("Fling to Up (+30)", 135)
flingUpBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)

local flingDownBtn = createButton("Fling to Down (-30)", 180)
flingDownBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)

-- Кнопка телепорта на Carpet
local tpCarpetBtn = createButton("TP to Carpet", 225)
tpCarpetBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 130)

-- ==========================================
-- 2. ЛОГИКА ФУНКЦИОНАЛА
-- ==========================================

local isGodMode = false
local isInfJumpActive = false

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
	openButton.Text = mainFrame.Visible and "Меню [Закрыть]" or "Меню [Открыть]"
end)

-- 1. БЕССМЕРТИЕ
RunService.Stepped:Connect(function()
	if isGodMode then
		local character = LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health < humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end
			for _, part in ipairs(character:GetChildren()) do
				if part:IsA("BasePart") then
					part.CanTouch = false
				end
			end
		end
	end
end)

godModeBtn.MouseButton1Click:Connect(function()
	isGodMode = not isGodMode
	godModeBtn.Text = isGodMode and "Бессмертие: ВКЛ" or "Бессмертие: ВЫКЛ"
	godModeBtn.BackgroundColor3 = isGodMode and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)

	local character = LocalPlayer.Character
	if character and not isGodMode then
		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanTouch = true
			end
		end
	end
end)

-- 2. INF JUMP
local lastJump = 0
UserInputService.JumpRequest:Connect(function()
	if isInfJumpActive and (tick() - lastJump) > 0.15 then
		lastJump = tick()
		local character = LocalPlayer.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if hrp and humanoid then
				hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, humanoid.JumpPower > 0 and humanoid.JumpPower or 50, hrp.AssemblyLinearVelocity.Z)
			end
		end
	end
end)

infJumpBtn.MouseButton1Click:Connect(function()
	isInfJumpActive = not isInfJumpActive
	infJumpBtn.Text = isInfJumpActive and "Inf Jump: ВКЛ" or "Inf Jump: ВЫКЛ"
	infJumpBtn.BackgroundColor3 = isInfJumpActive and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

-- 3. FLING TO UP
flingUpBtn.MouseButton1Click:Connect(function()
	local character = LocalPlayer.Character
	if character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.CFrame = hrp.CFrame + Vector3.new(0, 30, 0)
		end
	end
end)

-- 4. FLING TO DOWN
flingDownBtn.MouseButton1Click:Connect(function()
	local character = LocalPlayer.Character
	if character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.CFrame = hrp.CFrame - Vector3.new(0, 30, 0)
		end
	end
end)

-- 5. TP TO CARPET (Строго для модели exit)
tpCarpetBtn.MouseButton1Click:Connect(function()
	local character = LocalPlayer.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Ищем строго модель "exit" в Workspace
	local exitModel = workspace:FindFirstChild("exit")
	if exitModel then
		local carpet = exitModel:FindFirstChild("carpet")
		if carpet then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			
			if carpet:IsA("BasePart") then
				hrp.CFrame = carpet.CFrame + Vector3.new(0, 3, 0)
			elseif carpet:IsA("Model") then
				hrp.CFrame = carpet:GetPivot() + Vector3.new(0, 3, 0)
			end
			
			tpCarpetBtn.Text = "Успешно!"
			task.wait(1)
			tpCarpetBtn.Text = "TP to Carpet"
		else
			tpCarpetBtn.Text = "carpet не найден!"
			task.wait(1.5)
			tpCarpetBtn.Text = "TP to Carpet"
		end
	else
		tpCarpetBtn.Text = "exit не найден!"
		task.wait(1.5)
		tpCarpetBtn.Text = "TP to Carpet"
	end
end)
