-- FarmMoney.lua
-- LocalScript for Roblox Studio / your own experience
-- Compact mobile-friendly menu inspired by the provided screenshot.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local SPEED_MULTIPLIER = 3
local HIGHLIGHT_COLOR = Color3.fromRGB(0, 170, 255)

--==================================================
-- STATE
--==================================================

local infJump = false
local godMode = false
local speed3x = false

local activeHighlights = {}
local characterConnections = {}

--==================================================
-- HELPERS
--==================================================

local function disconnectAll(list)
	for _, connection in pairs(list) do
		if connection and connection.Disconnect then
			connection:Disconnect()
		end
	end
	table.clear(list)
end

local function getHumanoid()
	local character = LocalPlayer.Character
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

local function setSpeed()
	local humanoid = getHumanoid()
	if humanoid then
		humanoid.WalkSpeed = speed3x and 48 or 16
	end
end

local function applyGodMode()
	local humanoid = getHumanoid()
	if not humanoid then
		return
	end

	if godMode then
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	else
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
		if humanoid.MaxHealth == math.huge then
			humanoid.MaxHealth = 100
			humanoid.Health = math.min(humanoid.Health, humanoid.MaxHealth)
		end
	end
end

--==================================================
-- CHARACTER SETUP
--==================================================

local function setupCharacter(character)
	disconnectAll(characterConnections)

	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then
		return
	end

	table.insert(characterConnections, humanoid.HealthChanged:Connect(function()
		if godMode and humanoid.Parent then
			if humanoid.Health < math.huge then
				humanoid.Health = math.huge
			end
		end
	end))

	table.insert(characterConnections, humanoid.Died:Connect(function()
		-- In a client script we cannot guarantee server-side immortality.
		-- This keeps the local humanoid protected while alive.
	end))

	task.defer(function()
		setSpeed()
		applyGodMode()
	end)
end

if LocalPlayer.Character then
	task.spawn(setupCharacter, LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)

--==================================================
-- GUI ROOT
--==================================================

local oldGui = PlayerGui:FindFirstChild("FarmMoneyGUI")
if oldGui then
	oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FarmMoneyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--==================================================
-- OPEN BUTTON
--==================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.fromOffset(52, 52)
OpenButton.Position = UDim2.new(0, 12, 0.5, -26)
OpenButton.BackgroundColor3 = Color3.fromRGB(18, 20, 24)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "FM"
OpenButton.TextColor3 = Color3.fromRGB(0, 190, 255)
OpenButton.TextSize = 17
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = OpenButton

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(0, 120, 180)
openStroke.Thickness = 1
openStroke.Parent = OpenButton

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 330)
Main.Position = UDim2.new(0.5, -260, 0.5, -165)
Main.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = Main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(38, 42, 50)
mainStroke.Thickness = 1
mainStroke.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(16, 0)
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Text = "FARM MONEY"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(40, 40)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(25, 27, 32)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(220, 220, 225)
CloseButton.TextSize = 25
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseButton

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 135, 1, -50)
Sidebar.Position = UDim2.fromOffset(0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(17, 19, 23)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = Sidebar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 12)
SidePadding.PaddingLeft = UDim.new(0, 8)
SidePadding.PaddingRight = UDim.new(0, 8)
SidePadding.Parent = Sidebar

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -135, 1, -50)
Content.Position = UDim2.fromOffset(135, 50)
Content.BackgroundColor3 = Color3.fromRGB(11, 12, 15)
Content.BorderSizePixel = 0
Content.Parent = Main

local Pages = {}

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Color3.fromRGB(0, 130, 190)
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = false
	page.Parent = Content

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 14)
	padding.PaddingBottom = UDim.new(0, 14)
	padding.PaddingLeft = UDim.new(0, 14)
	padding.PaddingRight = UDim.new(0, 14)
	padding.Parent = page

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 28)
	end)

	Pages[name] = page
	return page
end

local MainPage = createPage("MainPage")
local VisualPage = createPage("VisualPage")
local EggsPage = createPage("EggsPage")
local BadgesPage = createPage("BadgesPage")
local SettingsPage = createPage("SettingsPage")

local sideButtons = {}

local function showPage(name)
	for pageName, page in pairs(Pages) do
		page.Visible = pageName == name
	end

	for buttonName, button in pairs(sideButtons) do
		if buttonName == name then
			button.BackgroundColor3 = Color3.fromRGB(0, 100, 145)
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			button.BackgroundColor3 = Color3.fromRGB(22, 24, 29)
			button.TextColor3 = Color3.fromRGB(185, 190, 200)
		end
	end
end

local function createSideButton(text, pageName, order)
	local button = Instance.new("TextButton")
	button.Name = pageName .. "Button"
	button.Size = UDim2.new(1, 0, 0, 40)
	button.BackgroundColor3 = Color3.fromRGB(22, 24, 29)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(185, 190, 200)
	button.TextSize = 13
	button.Font = Enum.Font.GothamMedium
	button.LayoutOrder = order
	button.Parent = Sidebar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button

	button.MouseButton1Click:Connect(function()
		showPage(pageName)
	end)

	sideButtons[pageName] = button
end

createSideButton("Main", "MainPage", 1)
createSideButton("Visuals", "VisualPage", 2)
createSideButton("Eggs", "EggsPage", 3)
createSideButton("Badges", "BadgesPage", 4)
createSideButton("Settings", "SettingsPage", 5)

--==================================================
-- PAGE UI HELPERS
--==================================================

local function createSectionTitle(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -2, 0, 30)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(235, 238, 245)
	label.TextSize = 17
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function createToggle(parent, text, callback, initial)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -2, 0, 42)
	button.BackgroundColor3 = Color3.fromRGB(22, 24, 29)
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(12, 0)
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Text = text
	label.TextColor3 = Color3.fromRGB(215, 218, 225)
	label.TextSize = 13
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button

	local state = initial == true

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.fromOffset(38, 20)
	indicator.Position = UDim2.new(1, -50, 0.5, -10)
	indicator.BorderSizePixel = 0
	indicator.Parent = button

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = indicator

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	knob.BorderSizePixel = 0
	knob.Parent = indicator

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local function refresh()
		if state then
			indicator.BackgroundColor3 = Color3.fromRGB(0, 150, 210)
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			knob.Position = UDim2.new(1, -18, 0.5, -8)
		else
			indicator.BackgroundColor3 = Color3.fromRGB(55, 58, 65)
			knob.BackgroundColor3 = Color3.fromRGB(170, 175, 185)
			knob.Position = UDim2.fromOffset(2, 2)
		end
	end

	button.MouseButton1Click:Connect(function()
		state = not state
		refresh()
		callback(state)
	end)

	refresh()
	return button
end

local function createAction(parent, text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -2, 0, 42)
	button.BackgroundColor3 = Color3.fromRGB(22, 24, 29)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(215, 218, 225)
	button.TextSize = 13
	button.Font = Enum.Font.GothamMedium
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button

	button.MouseButton1Click:Connect(callback)
	return button
end

--==================================================
-- HIGHLIGHT SYSTEM
--==================================================

local function clearHighlightGroup(group)
	for i = #activeHighlights, 1, -1 do
		local item = activeHighlights[i]
		if item.group == group then
			if item.highlight and item.highlight.Parent then
				item.highlight:Destroy()
			end
			table.remove(activeHighlights, i)
		end
	end
end

local function addHighlight(target, group)
	if not target or not target.Parent then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "FarmMoneyHighlight"
	highlight.FillColor = HIGHLIGHT_COLOR
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.55
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	if target:IsA("Model") or target:IsA("BasePart") then
		highlight.Adornee = target
		highlight.Parent = target
		table.insert(activeHighlights, {
			highlight = highlight,
			group = group
		})
		return
	end

	local found = false
	for _, descendant in ipairs(target:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local h = Instance.new("Highlight")
			h.Name = "FarmMoneyHighlight"
			h.FillColor = HIGHLIGHT_COLOR
			h.OutlineColor = Color3.fromRGB(255, 255, 255)
			h.FillTransparency = 0.55
			h.OutlineTransparency = 0
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Adornee = descendant
			h.Parent = descendant

			table.insert(activeHighlights, {
				highlight = h,
				group = group
			})
			found = true
		end
	end

	if not found then
		highlight:Destroy()
	end
end

local function highlightExactName(name, group)
	clearHighlightGroup(group)

	local found = 0

	for _, object in ipairs(workspace:GetDescendants()) do
		if object.Name == name then
			addHighlight(object, group)
			found += 1
		end
	end

	return found
end

local function highlightContainsName(text, group)
	clearHighlightGroup(group)

	local wanted = string.lower(text)

	for _, object in ipairs(workspace:GetDescendants()) do
		if string.find(string.lower(object.Name), wanted, 1, true) then
			addHighlight(object, group)
		end
	end
end

--==================================================
-- MAIN PAGE
--==================================================

createSectionTitle(MainPage, "Player")

createToggle(MainPage, "Inf Jump", function(value)
	infJump = value
end, false)

createToggle(MainPage, "Immortality", function(value)
	godMode = value
	applyGodMode()
end, false)

createToggle(MainPage, "X3 Speed", function(value)
	speed3x = value
	setSpeed()
end, false)


--==================================================
-- VISUAL PAGE
--==================================================

createSectionTitle(VisualPage, "Object search")

-- Одна кнопка подсвечивает только объекты с названием "Button"
-- без учёта регистра: Button, button, BUtton, BUTTon и т.д.
createAction(VisualPage, "Подсветить Button", function()
	clearHighlightGroup("Button")

	for _, object in ipairs(workspace:GetDescendants()) do
		if string.lower(object.Name) == "button" then
			addHighlight(object, "Button")
		end
	end
end)

createAction(VisualPage, "Убрать подсветку Button", function()
	clearHighlightGroup("Button")
	clearHighlightGroup("Button_Variants")
end)

createAction(VisualPage, "Убрать всю подсветку", function()
	for i = #activeHighlights, 1, -1 do
		local item = activeHighlights[i]
		if item.highlight and item.highlight.Parent then
			item.highlight:Destroy()
		end
		table.remove(activeHighlights, i)
	end
end)

createSectionTitle(VisualPage, "Numbered objects")

createAction(VisualPage, "Подсветить 1–10", function()
	for i = 1, 10 do
		highlightExactName(tostring(i), "Number_" .. i)
	end
end)

--==================================================
-- EGG PAGE
--==================================================

createSectionTitle(EggsPage, "Egg1 – Egg10")

-- Одна кнопка подсвечивает Egg1, Egg2, ... Egg10
createAction(EggsPage, "Подсветить Egg", function()
	for i = 1, 10 do
		highlightExactName("Egg" .. i, "Egg_" .. i)
	end
end)

createAction(EggsPage, "Убрать подсветку Egg", function()
	for i = 1, 10 do
		clearHighlightGroup("Egg_" .. i)
	end
end)

--==================================================
-- BADGE PAGE
--==================================================

createSectionTitle(BadgesPage, "Badge1 – Badge10")

-- Одна кнопка подсвечивает Badge1, Badge2, ... Badge10
createAction(BadgesPage, "Подсветить Badge", function()
	for i = 1, 10 do
		highlightExactName("Badge" .. i, "Badge_" .. i)
	end
end)

createAction(BadgesPage, "Убрать подсветку Badge", function()
	for i = 1, 10 do
		clearHighlightGroup("Badge_" .. i)
	end
end)

--==================================================
-- SETTINGS PAGE
--==================================================

createSectionTitle(SettingsPage, "Menu")

createAction(SettingsPage, "Закрыть меню", function()
	Main.Visible = false
	OpenButton.Visible = true
end)

createAction(SettingsPage, "Убрать всю подсветку", function()
	for i = #activeHighlights, 1, -1 do
		local item = activeHighlights[i]
		if item.highlight and item.highlight.Parent then
			item.highlight:Destroy()
		end
		table.remove(activeHighlights, i)
	end
end)

createAction(SettingsPage, "Сбросить скорость", function()
	speed3x = false
	setSpeed()
end)

--==================================================
-- INFINITE JUMP
--==================================================

UserInputService.JumpRequest:Connect(function()
	if not infJump then
		return
	end

	local humanoid = getHumanoid()
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

--==================================================
-- CONTINUOUS LOCAL PROTECTION
--==================================================

RunService.Heartbeat:Connect(function()
	if godMode then
		local humanoid = getHumanoid()
		if humanoid then
			if humanoid.MaxHealth ~= math.huge then
				humanoid.MaxHealth = math.huge
			end
			if humanoid.Health < math.huge then
				humanoid.Health = math.huge
			end
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		end
	end

	if speed3x then
		local humanoid = getHumanoid()
		if humanoid and humanoid.WalkSpeed ~= 48 then
			humanoid.WalkSpeed = 48
		end
	end
end)

--==================================================
-- OPEN / CLOSE
--==================================================

CloseButton.MouseButton1Click:Connect(function()
	Main.Visible = false
	OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
	Main.Visible = true
	OpenButton.Visible = false
end)

--==================================================
-- MOBILE DRAGGING
--==================================================

local dragging = false
local dragStart
local startPos

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--==================================================
-- INITIAL PAGE
--==================================================

showPage("MainPage")
Main.Visible = true
OpenButton.Visible = false
