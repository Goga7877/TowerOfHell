--[[
    MM2 HUB
    LocalScript
    Для Roblox Studio:
    StarterPlayer > StarterPlayerScripts

    ВАЖНО:
    Этот скрипт рассчитан на использование в собственной игре/тестовом
    Roblox-проекте в Studio.

    Возможности:
    • Farm Money — циклически ищет coin_server без учёта регистра
    • Fly — CFrame + TweenService, PC + мобильное управление
    • X3 Speed — множитель скорости полёта
    • InfJump — бесконечный прыжок
    • JumpHack — CFrame-прыжок с настройкой высоты
    • Noclip — отключение столкновений
    • Меню в стиле показанного скриншота
    • Открытие/закрытие
    • Перемещение меню
]]

--============================================================
-- SERVICES
--============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--============================================================
-- SETTINGS
--============================================================

local CONTAINER_NAME = "CoinContainer"
local TARGET_NAME = "coin_server"

local MIN_FLY_SPEED = 10
local MAX_FLY_SPEED = 150
local DEFAULT_FLY_SPEED = 48

local MIN_JUMP_HEIGHT = 5
local MAX_JUMP_HEIGHT = 80
local DEFAULT_JUMP_HEIGHT = 25

local FARM_SEARCH_DELAY = 0.25
local FLY_TWEEN_TIME = 0.07

local flySpeed = DEFAULT_FLY_SPEED
local jumpHeight = DEFAULT_JUMP_HEIGHT

local farmEnabled = false
local flyEnabled = false
local infJumpEnabled = false
local jumpHackEnabled = false
local noclipEnabled = false

local activeFarmTween = nil
local activeFlyTween = nil

local characterConnections = {}

--============================================================
-- CLEAN OLD GUI
--============================================================

local oldGui = playerGui:FindFirstChild("MM2Hub")
if oldGui then
    oldGui:Destroy()
end

--============================================================
-- SCREEN GUI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MM2Hub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

--============================================================
-- COLORS
--============================================================

local C = {
    Background = Color3.fromRGB(10, 11, 15),
    Sidebar = Color3.fromRGB(22, 25, 32),
    Panel = Color3.fromRGB(14, 15, 20),
    Card = Color3.fromRGB(18, 20, 27),
    Card2 = Color3.fromRGB(24, 27, 35),

    Border = Color3.fromRGB(38, 42, 52),
    BorderLight = Color3.fromRGB(52, 57, 70),

    Text = Color3.fromRGB(238, 240, 245),
    Text2 = Color3.fromRGB(165, 170, 182),
    Text3 = Color3.fromRGB(105, 111, 124),

    Accent = Color3.fromRGB(0, 174, 235),
    Accent2 = Color3.fromRGB(35, 198, 255),

    Green = Color3.fromRGB(70, 220, 135),
    Red = Color3.fromRGB(235, 80, 90),
}

--============================================================
-- HELPERS
--============================================================

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function makeStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function makeLabel(parent, text, position, size, font, textSize, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = size
    label.Text = text
    label.Font = font or Enum.Font.GothamMedium
    label.TextSize = textSize or 12
    label.TextColor3 = color or C.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local statusLabel

local function setStatus(text, color)
    if statusLabel then
        statusLabel.Text = text
        statusLabel.TextColor3 = color or C.Text2
    end
end

--============================================================
-- OPEN BUTTON
--============================================================

local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.AnchorPoint = Vector2.new(0, 1)
openButton.Position = UDim2.new(0, 16, 1, -16)
openButton.Size = UDim2.new(0, 58, 0, 58)
openButton.BackgroundColor3 = C.Sidebar
openButton.BorderSizePixel = 0
openButton.AutoButtonColor = false
openButton.Text = "M"
openButton.TextColor3 = C.Accent2
openButton.TextSize = 24
openButton.Font = Enum.Font.GothamBold
openButton.ZIndex = 100
openButton.Parent = gui

makeCorner(openButton, 18)
makeStroke(openButton, C.BorderLight, 1.5, 0.1)

--============================================================
-- MAIN WINDOW
--============================================================

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, 760, 0, 470)
main.BackgroundColor3 = C.Background
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.ZIndex = 10
main.Parent = gui

makeCorner(main, 14)
makeStroke(main, C.BorderLight, 1.2, 0.15)

-- Responsive scaling for phones
local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = main

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local sx = viewport.X / 760
    local sy = viewport.Y / 470

    scale.Scale = math.clamp(math.min(sx, sy), 0.55, 1)
end

updateScale()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

--============================================================
-- SIDEBAR
--============================================================

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 190, 1, 0)
sidebar.BackgroundColor3 = C.Sidebar
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 11
sidebar.Parent = main

local sideLine = Instance.new("Frame")
sideLine.Position = UDim2.new(1, -1, 0, 0)
sideLine.Size = UDim2.new(0, 1, 1, 0)
sideLine.BackgroundColor3 = C.Border
sideLine.BorderSizePixel = 0
sideLine.ZIndex = 12
sideLine.Parent = sidebar

makeLabel(
    sidebar,
    "MM2 HUB",
    UDim2.new(0, 22, 0, 20),
    UDim2.new(1, -44, 0, 34),
    Enum.Font.GothamBold,
    22,
    C.Text
)

makeLabel(
    sidebar,
    "MOBILE / PC",
    UDim2.new(0, 23, 0, 50),
    UDim2.new(1, -46, 0, 20),
    Enum.Font.GothamMedium,
    9,
    C.Text3
)

local combatTitle = makeLabel(
    sidebar,
    "COMBAT",
    UDim2.new(0, 23, 0, 92),
    UDim2.new(1, -46, 0, 18),
    Enum.Font.GothamBold,
    10,
    C.Text3
)

--============================================================
-- CONTENT
--============================================================

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.new(0, 190, 0, 0)
content.Size = UDim2.new(1, -190, 1, 0)
content.BackgroundColor3 = C.Panel
content.BorderSizePixel = 0
content.ZIndex = 11
content.Parent = main

local header = Instance.new("Frame")
header.Position = UDim2.new(0, 0, 0, 0)
header.Size = UDim2.new(1, 0, 0, 72)
header.BackgroundTransparency = 1
header.ZIndex = 12
header.Parent = content

statusLabel = makeLabel(
    header,
    "Ready",
    UDim2.new(1, -210, 0, 20),
    UDim2.new(0, 160, 0, 18),
    Enum.Font.GothamMedium,
    10,
    C.Text2
)
statusLabel.TextXAlignment = Enum.TextXAlignment.Right
statusLabel.Position = UDim2.new(1, -210, 0, 44)

local pageTitle = makeLabel(
    header,
    "Farm",
    UDim2.new(0, 28, 0, 17),
    UDim2.new(1, -90, 0, 26),
    Enum.Font.GothamBold,
    22,
    C.Text
)

local pageSubtitle = makeLabel(
    header,
    "Automated coin movement",
    UDim2.new(0, 29, 0, 43),
    UDim2.new(1, -90, 0, 18),
    Enum.Font.GothamMedium,
    10,
    C.Text3
)

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -16, 0, 16)
closeButton.Size = UDim2.new(0, 36, 0, 36)
closeButton.BackgroundColor3 = C.Card2
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.Text = "×"
closeButton.TextColor3 = C.Text2
closeButton.TextSize = 24
closeButton.Font = Enum.Font.GothamBold
closeButton.ZIndex = 20
closeButton.Parent = header

makeCorner(closeButton, 9)

--============================================================
-- PAGE SYSTEM
--============================================================

local pages = {}
local navButtons = {}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Position = UDim2.new(0, 20, 0, 76)
    page.Size = UDim2.new(1, -40, 1, -90)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 12
    page.Parent = content

    pages[name] = page
    return page
end

local farmPage = createPage("Farm")
local playerPage = createPage("Player")
local espPage = createPage("ESP")
local combatPage = createPage("Combat")

farmPage.Visible = true

local function selectPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end

    for pageName, button in pairs(navButtons) do
        if pageName == name then
            button.BackgroundColor3 = Color3.fromRGB(30, 58, 72)
            button.TextColor3 = C.Text
        else
            button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            button.BackgroundTransparency = 1
            button.TextColor3 = C.Text2
        end
    end

    if name == "Farm" then
        pageTitle.Text = "Farm"
        pageSubtitle.Text = "Automated coin movement"
    elseif name == "Player" then
        pageTitle.Text = "Player"
        pageSubtitle.Text = "Movement and character"
    elseif name == "ESP" then
        pageTitle.Text = "ESP"
        pageSubtitle.Text = "Role markers"
    elseif name == "Combat" then
        pageTitle.Text = "Combat"
        pageSubtitle.Text = "Training / target controls"
    end
end

local function createNavButton(name, text, y)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = UDim2.new(0, 14, 0, y)
    button.Size = UDim2.new(1, -28, 0, 42)
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = "   " .. text
    button.TextColor3 = C.Text2
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.ZIndex = 13
    button.Parent = sidebar

    makeCorner(button, 9)

    navButtons[name] = button

    button.MouseButton1Click:Connect(function()
        selectPage(name)
    end)

    return button
end

createNavButton("Farm", "Farm", 118)
createNavButton("Player", "Player", 166)
createNavButton("ESP", "ESP", 214)
createNavButton("Combat", "Combat", 262)

makeLabel(
    sidebar,
    "MISCELLANEOUS",
    UDim2.new(0, 23, 0, 225),
    UDim2.new(1, -46, 0, 18),
    Enum.Font.GothamBold,
    10,
    C.Text3
)

makeLabel(
    sidebar,
    "MM2 HUB",
    UDim2.new(0, 23, 1, -48),
    UDim2.new(1, -46, 0, 18),
    Enum.Font.GothamBold,
    10,
    C.Text3
)

--============================================================
-- CARD / TOGGLE / SLIDER
--============================================================

local function createCard(parent, titleText, x, y, w, h)
    local card = Instance.new("Frame")
    card.Position = UDim2.new(0, x, 0, y)
    card.Size = UDim2.new(0, w, 0, h)
    card.BackgroundColor3 = C.Card
    card.BorderSizePixel = 0
    card.ZIndex = 13
    card.Parent = parent

    makeCorner(card, 10)
    makeStroke(card, C.Border, 1, 0.25)

    makeLabel(
        card,
        titleText,
        UDim2.new(0, 18, 0, 12),
        UDim2.new(1, -36, 0, 25),
        Enum.Font.GothamBold,
        15,
        C.Text
    )

    return card
end

local function createToggle(parent, text, y, callback)
    local row = Instance.new("Frame")
    row.Position = UDim2.new(0, 16, 0, y)
    row.Size = UDim2.new(1, -32, 0, 34)
    row.BackgroundTransparency = 1
    row.ZIndex = 14
    row.Parent = parent

    makeLabel(
        row,
        text,
        UDim2.new(0, 0, 0, 0),
        UDim2.new(1, -58, 1, 0),
        Enum.Font.GothamMedium,
        11,
        C.Text2
    )

    local toggle = Instance.new("TextButton")
    toggle.Position = UDim2.new(1, -42, 0.5, -10)
    toggle.Size = UDim2.new(0, 42, 0, 20)
    toggle.BackgroundColor3 = Color3.fromRGB(45, 49, 60)
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Text = ""
    toggle.ZIndex = 15
    toggle.Parent = row

    makeCorner(toggle, 10)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = UDim2.new(0, 3, 0.5, 0)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.BackgroundColor3 = Color3.fromRGB(175, 180, 190)
    knob.BorderSizePixel = 0
    knob.ZIndex = 16
    knob.Parent = toggle

    makeCorner(knob, 8)

    local state = false

    local function render()
        if state then
            toggle.BackgroundColor3 = C.Accent
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.Position = UDim2.new(1, -17, 0.5, 0)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(45, 49, 60)
            knob.BackgroundColor3 = Color3.fromRGB(175, 180, 190)
            knob.Position = UDim2.new(0, 3, 0.5, 0)
        end
    end

    toggle.MouseButton1Click:Connect(function()
        state = not state
        render()
        callback(state)
    end)

    return {
        Set = function(value)
            state = value == true
            render()
        end,
        Get = function()
            return state
        end
    }
end

local function createSlider(parent, titleText, minValue, maxValue, defaultValue, y, callback)
    local row = Instance.new("Frame")
    row.Position = UDim2.new(0, 16, 0, y)
    row.Size = UDim2.new(1, -32, 0, 58)
    row.BackgroundTransparency = 1
    row.ZIndex = 14
    row.Parent = parent

    local label = makeLabel(
        row,
        titleText,
        UDim2.new(0, 0, 0, 0),
        UDim2.new(0.55, 0, 0, 20),
        Enum.Font.GothamMedium,
        11,
        C.Text2
    )

    local valueLabel = makeLabel(
        row,
        tostring(defaultValue),
        UDim2.new(1, -45, 0, 0),
        UDim2.new(0, 45, 0, 20),
        Enum.Font.GothamBold,
        11,
        C.Text
    )
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bg = Instance.new("Frame")
    bg.Position = UDim2.new(0, 0, 0, 30)
    bg.Size = UDim2.new(1, 0, 0, 7)
    bg.BackgroundColor3 = Color3.fromRGB(46, 50, 62)
    bg.BorderSizePixel = 0
    bg.ZIndex = 15
    bg.Parent = row

    makeCorner(bg, 8)

    local alpha = (defaultValue - minValue) / (maxValue - minValue)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(alpha, 0, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 16
    fill.Parent = bg

    makeCorner(fill, 8)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(alpha, 0, 0.5, 0)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.BackgroundColor3 = Color3.fromRGB(230, 235, 240)
    knob.BorderSizePixel = 0
    knob.ZIndex = 17
    knob.Parent = bg

    makeCorner(knob, 8)

    local dragging = false

    local function update(x)
        local pos = bg.AbsolutePosition
        local size = bg.AbsoluteSize

        if size.X <= 0 then
            return
        end

        local a = math.clamp((x - pos.X) / size.X, 0, 1)
        local value = math.floor(minValue + a * (maxValue - minValue) + 0.5)

        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        valueLabel.Text = tostring(value)

        callback(value)
    end

    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--============================================================
-- FARM PAGE
--============================================================

local farmCard = createCard(
    farmPage,
    "Farm Money",
    5,
    5,
    500,
    270
)

makeLabel(
    farmCard,
    "Automatically searches for the coin target and repeats the trip.",
    UDim2.new(0, 18, 0, 42),
    UDim2.new(1, -36, 0, 34),
    Enum.Font.GothamMedium,
    10,
    C.Text3
)

local farmToggle = createToggle(
    farmCard,
    "Enable Farm",
    82,
    function(state)
        farmEnabled = state

        if state then
            setStatus("Farm enabled", C.Green)
        else
            setStatus("Farm disabled", C.Text2)

            if activeFarmTween then
                pcall(function()
                    activeFarmTween:Cancel()
                end)
                activeFarmTween = nil
            end
        end
    end
)

createSlider(
    farmCard,
    "Farm Speed",
    10,
    150,
    50,
    126,
    function(value)
        flySpeed = value
    end
)

makeLabel(
    farmCard,
    "Target: coin_server",
    UDim2.new(0, 18, 0, 205),
    UDim2.new(1, -36, 0, 20),
    Enum.Font.GothamMedium,
    10,
    C.Text2
)

makeLabel(
    farmCard,
    "Search is case-insensitive.",
    UDim2.new(0, 18, 0, 228),
    UDim2.new(1, -36, 0, 20),
    Enum.Font.GothamMedium,
    9,
    C.Text3
)

--============================================================
-- PLAYER PAGE
--============================================================

local movementCard = createCard(
    playerPage,
    "Movement",
    5,
    5,
    500,
    345
)

makeLabel(
    movementCard,
    "CFrame movement for PC and mobile.",
    UDim2.new(0, 18, 0, 42),
    UDim2.new(1, -36, 0, 25),
    Enum.Font.GothamMedium,
    10,
    C.Text3
)

createToggle(
    movementCard,
    "X3 Speed Fly",
    78,
    function(state)
        flyEnabled = state

        if state then
            setStatus("Fly enabled", C.Green)
        else
            setStatus("Fly disabled", C.Text2)

            if activeFlyTween then
                pcall(function()
                    activeFlyTween:Cancel()
                end)
                activeFlyTween = nil
            end
        end
    end
)

createSlider(
    movementCard,
    "Fly Speed",
    MIN_FLY_SPEED,
    MAX_FLY_SPEED,
    DEFAULT_FLY_SPEED,
    118,
    function(value)
        flySpeed = value
    end
)

createToggle(
    movementCard,
    "InfJump",
    184,
    function(state)
        infJumpEnabled = state

        if state then
            setStatus("InfJump enabled", C.Green)
        else
            setStatus("InfJump disabled", C.Text2)
        end
    end
)

createToggle(
    movementCard,
    "JumpHack",
    224,
    function(state)
        jumpHackEnabled = state

        if state then
            setStatus("JumpHack enabled", C.Green)
        else
            setStatus("JumpHack disabled", C.Text2)
        end
    end
)

createSlider(
    movementCard,
    "Jump Height",
    MIN_JUMP_HEIGHT,
    MAX_JUMP_HEIGHT,
    DEFAULT_JUMP_HEIGHT,
    262,
    function(value)
        jumpHeight = value
    end
)

createToggle(
    movementCard,
    "Noclip",
    328,
    function(state)
        noclipEnabled = state

        if state then
            setStatus("Noclip enabled", C.Green)
        else
            setStatus("Noclip disabled", C.Text2)
        end
    end
)

--============================================================
-- ESP PAGE
--============================================================

local espMurderEnabled = false
local espSheriffEnabled = false
local espOthersEnabled = false
local espObjects = {}

local MURDER_COLOR = Color3.fromRGB(235, 45, 55)
local SHERIFF_COLOR = Color3.fromRGB(55, 135, 255)
local OTHERS_COLOR = Color3.fromRGB(255, 255, 255)

local function normalizeRole(value)
    if typeof(value) ~= "string" then
        return nil
    end

    local role = string.lower(value)
    role = role:gsub("%s+", "")
    role = role:gsub("[_%-]", "")

    if role == "murder" or role == "murderer" or role == "murdererrole" then
        return "Murder"
    end

    if role == "sheriff" or role == "sheriffrole" then
        return "Sheriff"
    end

    if role == "innocent" or role == "innocentrole" or role == "civilian" then
        return "Others"
    end

    return nil
end

local function readRoleValue(container)
    if not container then
        return nil
    end

    local directNames = {
        "Role",
        "role",
        "RoleName",
        "PlayerRole",
        "CurrentRole",
        "CurrentRoleName"
    }

    -- 1. Attributes: Role / RoleName / etc.
    for _, name in ipairs(directNames) do
        local value = container:GetAttribute(name)
        local normalized = normalizeRole(value)
        if normalized then
            return normalized
        end
    end

    -- 2. Team name. This is commonly how role is stored in simple MM2 copies.
    local team = container:IsA("Player") and container.Team or nil
    if team then
        local normalized = normalizeRole(team.Name)
        if normalized then
            return normalized
        end
    end

    -- 3. Direct Role StringValue / ObjectValue / similar value objects.
    for _, name in ipairs(directNames) do
        local valueObject = container:FindFirstChild(name)
        if valueObject then
            if valueObject:IsA("StringValue") then
                local normalized = normalizeRole(valueObject.Value)
                if normalized then
                    return normalized
                end
            elseif valueObject:IsA("ObjectValue") and valueObject.Value then
                local normalized = normalizeRole(valueObject.Value.Name)
                if normalized then
                    return normalized
                end
            end
        end
    end

    -- 4. leaderstats Role.
    local leaderstats = container:FindFirstChild("leaderstats")
    if leaderstats then
        for _, valueObject in ipairs(leaderstats:GetChildren()) do
            if valueObject:IsA("StringValue") then
                local normalized = normalizeRole(valueObject.Value)
                if normalized then
                    return normalized
                end
            end
        end
    end

    return nil
end

local function getRoleFromObject(obj)
    if not obj then
        return nil
    end

    -- Players: check player first, then their live character.
    local playerObject = obj:IsA("Player") and obj or Players:GetPlayerFromCharacter(obj)

    if playerObject then
        local role = readRoleValue(playerObject)
        if role then
            return role
        end

        if playerObject.Character then
            role = readRoleValue(playerObject.Character)
            if role then
                return role
            end
        end

        return nil
    end

    -- NPC/model: check model itself first.
    local role = readRoleValue(obj)
    if role then
        return role
    end

    return nil
end

local function classifyObject(obj)
    -- ESP is role-only. It NEVER checks Gun, Knife, Backpack or Tools.
    return getRoleFromObject(obj) or "Others"
end

local function getESPColor(category)
    if category == "Murder" then
        return MURDER_COLOR
    elseif category == "Sheriff" then
        return SHERIFF_COLOR
    end

    return OTHERS_COLOR
end

local function removeESP(obj)
    local data = espObjects[obj]
    if not data then
        return
    end

    for _, instance in ipairs(data.instances or {}) do
        if instance and instance.Parent then
            instance:Destroy()
        end
    end

    espObjects[obj] = nil
end

local function addESP(obj, category)
    if not obj or not obj.Parent then
        return
    end

    if not obj:IsA("Model") then
        return
    end

    local existing = espObjects[obj]
    if existing and existing.category == category and existing.adorned == obj then
        return
    end

    removeESP(obj)

    local color = getESPColor(category)
    local list = {}

    local highlight = Instance.new("Highlight")
    highlight.Name = "MM2HubESP"
    highlight.Adornee = obj
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.58
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Parent = obj
    table.insert(list, highlight)

    local head = obj:FindFirstChild("Head", true)
    local root = obj:FindFirstChild("HumanoidRootPart", true)
    local adorneePart = (head and head:IsA("BasePart") and head)
        or (root and root:IsA("BasePart") and root)
        or obj.PrimaryPart

    local bill
    if adorneePart and adorneePart:IsA("BasePart") then
        bill = Instance.new("BillboardGui")
        bill.Name = "MM2HubRole"
        bill.Adornee = adorneePart
        bill.Size = UDim2.new(0, 120, 0, 26)
        bill.StudsOffset = Vector3.new(0, 3.2, 0)
        bill.AlwaysOnTop = true
        bill.ResetOnSpawn = false
        bill.Parent = obj

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Text = category
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.Parent = bill

        table.insert(list, bill)
    end

    espObjects[obj] = {
        instances = list,
        category = category,
        adorned = obj,
        highlight = highlight,
        bill = bill
    }
end

local function isESPCharacterModel(obj)
    if not obj or not obj:IsA("Model") then
        return false
    end

    return obj:FindFirstChildOfClass("Humanoid") ~= nil
end

local function refreshESP()
    local anyEnabled = espMurderEnabled or espSheriffEnabled or espOthersEnabled

    if not anyEnabled then
        for obj in pairs(espObjects) do
            removeESP(obj)
        end
        return
    end

    local seen = {}

    -- Players.
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char and isESPCharacterModel(char) then
                seen[char] = true

                local category = classifyObject(plr)
                local enabled =
                    (category == "Murder" and espMurderEnabled)
                    or (category == "Sheriff" and espSheriffEnabled)
                    or (category == "Others" and espOthersEnabled)

                if enabled then
                    addESP(char, category)
                else
                    removeESP(char)
                end
            end
        end
    end

    -- NPCs / dummies with Humanoid. Player characters are skipped above.
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isESPCharacterModel(obj) and not Players:GetPlayerFromCharacter(obj) then
            seen[obj] = true

            local category = classifyObject(obj)
            local enabled =
                (category == "Murder" and espMurderEnabled)
                or (category == "Sheriff" and espSheriffEnabled)
                or (category == "Others" and espOthersEnabled)

            if enabled then
                addESP(obj, category)
            else
                removeESP(obj)
            end
        end
    end

    -- Remove stale ESP immediately.
    for obj in pairs(espObjects) do
        if not seen[obj] or not obj.Parent then
            removeESP(obj)
        end
    end
end

local espCard = createCard(espPage, "ESP", 5, 5, 500, 275)

createToggle(espCard, "ESP Murder", 55, function(state)
    espMurderEnabled = state
    refreshESP()
end)

createToggle(espCard, "ESP Sheriff", 95, function(state)
    espSheriffEnabled = state
    refreshESP()
end)

createToggle(espCard, "ESP Others", 135, function(state)
    espOthersEnabled = state
    refreshESP()
end)

makeLabel(
    espCard,
    "Murder = RED   |   Sheriff = BLUE   |   Others = WHITE",
    UDim2.new(0, 18, 0, 195),
    UDim2.new(1, -36, 0, 22),
    Enum.Font.GothamMedium,
    10,
    C.Text2
)

makeLabel(
    espCard,
    "Only the current role is used. No Gun / Knife checks.",
    UDim2.new(0, 18, 0, 222),
    UDim2.new(1, -36, 0, 22),
    Enum.Font.GothamMedium,
    9,
    C.Text3
)

--============================================================
-- COMBAT PAGE
--============================================================

local combatRunning = false
local originalCombatCFrame = nil

local function getRootFromTarget(target)
    if not target then return nil end

    if target:IsA("Player") then
        local char = target.Character
        if char then
            return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        end
    elseif target:IsA("Model") then
        return target:FindFirstChild("HumanoidRootPart")
            or target:FindFirstChild("Torso")
            or target.PrimaryPart
    end

    return nil
end

local function getHumanoidFromTarget(target)
    if target:IsA("Player") then
        local char = target.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    return target:FindFirstChildOfClass("Humanoid")
end

local function findRoleTarget(wantedRole)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local category = classifyObject(plr)
            if category == wantedRole then
                return plr
            end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            if classifyObject(obj) == wantedRole then
                return obj
            end
        end
    end

    return nil
end

local function getAllTargets()
    local targets = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and getHumanoidFromTarget(plr) then
            table.insert(targets, plr)
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
            and obj ~= player.Character
            and obj:FindFirstChildOfClass("Humanoid")
            and not Players:GetPlayerFromCharacter(obj) then
            table.insert(targets, obj)
        end
    end

    return targets
end

local function getAttackTool()
    local char = player.Character
    if not char then return nil end

    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                return item
            end
        end
    end

    return nil
end

local function attackTarget(target)
    local _, root = getCharacter()
    local targetRoot = getRootFromTarget(target)
    local humanoid = getHumanoidFromTarget(target)

    if not root or not targetRoot or not humanoid then
        return
    end

    if humanoid.Health <= 0 then
        return
    end

    root.CFrame = CFrame.lookAt(
        targetRoot.Position - targetRoot.CFrame.LookVector * 3,
        targetRoot.Position
    )

    local tool = getAttackTool()

    if tool then
        pcall(function()
            tool:Activate()
        end)
    end
end

local function findGunDrop()
    local wanted = "gundrop"

    for _, object in ipairs(workspace:GetDescendants()) do
        local lowerName = string.lower(object.Name)

        if lowerName == wanted then
            if object:IsA("Model") or object:IsA("BasePart") then
                return object
            end
        end
    end

    return nil
end

local function getObjectCFrame(object)
    if not object then
        return nil
    end

    if object:IsA("Model") then
        return object:GetPivot()
    elseif object:IsA("BasePart") then
        return object.CFrame
    end

    return nil
end

local function teleportToGunDrop()
    local _, root = getCharacter()

    if not root then
        setStatus("Character not found", C.Red)
        return
    end

    local gunDrop = findGunDrop()

    if not gunDrop then
        setStatus("GunDrop not found", C.Red)
        return
    end

    local targetCFrame = getObjectCFrame(gunDrop)

    if not targetCFrame then
        setStatus("GunDrop position not found", C.Red)
        return
    end

    local originalCFrame = root.CFrame

    root.CFrame = targetCFrame + Vector3.new(0, 3, 0)
    setStatus("At GunDrop", C.Green)

    task.wait(0.35)

    if root.Parent then
        root.CFrame = originalCFrame
        setStatus("Returned to original position", C.Text2)
    end
end

local function stopCombat()
    combatRunning = false

    if originalCombatCFrame then
        local _, root = getCharacter()
        if root then
            root.CFrame = originalCombatCFrame
        end
    end

    originalCombatCFrame = nil
    setStatus("Combat stopped", C.Text2)
end

local function runCombat(targets)
    if combatRunning then return end

    local _, root = getCharacter()
    if not root then return end

    combatRunning = true
    originalCombatCFrame = root.CFrame
    setStatus("Combat running", C.Green)

    task.spawn(function()
        for _, target in ipairs(targets) do
            if not combatRunning then break end

            local targetRoot = getRootFromTarget(target)
            local humanoid = getHumanoidFromTarget(target)

            if targetRoot and humanoid and humanoid.Health > 0 then
                while combatRunning and humanoid.Parent and humanoid.Health > 0 do
                    local _, myRoot = getCharacter()

                    if not myRoot then break end

                    myRoot.CFrame = CFrame.lookAt(
                        targetRoot.Position - targetRoot.CFrame.LookVector * 3,
                        targetRoot.Position
                    )

                    local tool = getAttackTool()

                    if tool then
                        pcall(function()
                            tool:Activate()
                        end)
                    end

                    task.wait(0.08)
                end
            end
        end

        if combatRunning then
            stopCombat()
        end
    end)
end

local combatCard = createCard(combatPage, "Combat", 5, 5, 500, 400)

makeLabel(
    combatCard,
    "Uses the normal Tool:Activate() system of the game.",
    UDim2.new(0, 18, 0, 42),
    UDim2.new(1, -36, 0, 30),
    Enum.Font.GothamMedium,
    10,
    C.Text3
)

local function combatButton(text, y, callback)
    local b = Instance.new("TextButton")
    b.Position = UDim2.new(0, 16, 0, y)
    b.Size = UDim2.new(1, -32, 0, 43)
    b.BackgroundColor3 = C.Card2
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Text = text
    b.TextColor3 = C.Text
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 14
    b.Parent = combatCard

    makeCorner(b, 9)
    makeStroke(b, C.BorderLight, 1, 0.2)

    b.MouseButton1Click:Connect(callback)

    return b
end

combatButton("TP TO GUNDROP", 82, function()
    teleportToGunDrop()
end)

combatButton("KILL ALL", 132, function()
    runCombat(getAllTargets())
end)

combatButton("KILL SHERIFF", 182, function()
    local target = findRoleTarget("Sheriff")
    if target then
        runCombat({target})
    else
        setStatus("Sheriff not found", C.Red)
    end
end)

combatButton("KILL MURDER", 232, function()
    local target = findRoleTarget("Murder")
    if target then
        runCombat({target})
    else
        setStatus("Murder not found", C.Red)
    end
end)

combatButton("STOP / RETURN", 282, function()
    stopCombat()
end)

makeLabel(
    combatCard,
    "Targets include players and Humanoid NPCs.",
    UDim2.new(0, 18, 0, 345),
    UDim2.new(1, -36, 0, 20),
    Enum.Font.GothamMedium,
    9,
    C.Text3
)

-- ESP refresh loop
task.spawn(function()
    while gui.Parent do
        refreshESP()
        task.wait(0.5)
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.2)
        refreshESP()
    end)
end)

--============================================================
-- DRAG WINDOW
--============================================================

local dragging = false
local dragStart = nil
local startPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        local closePos = closeButton.AbsolutePosition
        local closeSize = closeButton.AbsoluteSize

        local p = input.Position

        local onClose =
            p.X >= closePos.X
            and p.X <= closePos.X + closeSize.X
            and p.Y >= closePos.Y
            and p.Y <= closePos.Y + closeSize.Y

        if onClose then
            return
        end

        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

--============================================================
-- OPEN / CLOSE
--============================================================

openButton.MouseButton1Click:Connect(function()
    main.Visible = true
    openButton.Visible = false
end)

closeButton.MouseButton1Click:Connect(function()
    main.Visible = false
    openButton.Visible = true
end)

--============================================================
-- FIND COIN - CASE INSENSITIVE
--============================================================

local function findCoinServer()
    local container = workspace:FindFirstChild(CONTAINER_NAME, true)

    if not container then
        return nil
    end

    local wanted = string.lower(TARGET_NAME)

    -- Сам контейнер тоже проверяем.
    if string.lower(container.Name) == wanted then
        return container
    end

    for _, object in ipairs(container:GetDescendants()) do
        if string.lower(object.Name) == wanted then
            return object
        end
    end

    return nil
end

--============================================================
-- TARGET / INVENTORY HELPERS
--============================================================

local function findByNameInsensitive(root, wantedName)
    if not root then
        return nil
    end

    local wanted = string.lower(wantedName)

    if string.lower(root.Name) == wanted then
        return root
    end

    for _, object in ipairs(root:GetDescendants()) do
        if string.lower(object.Name) == wanted then
            return object
        end
    end

    return nil
end

local function findGunDrop()
    -- Ищем GunDrop по всей карте без учёта регистра.
    -- Поэтому подходят GunDrop, gundrop, GUNDROP, GuNdRoP и т.д.
    return findByNameInsensitive(workspace, "GunDrop")
end

local function playerHasGun()
    local character = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")

    if character and findByNameInsensitive(character, "Gun") then
        return true
    end

    if backpack and findByNameInsensitive(backpack, "Gun") then
        return true
    end

    return false
end

local function getObjectPosition(object)
    if not object then
        return nil
    end

    if object:IsA("BasePart") then
        return object.Position
    end

    if object:IsA("Model") then
        return object:GetPivot().Position
    end

    if object:IsA("Attachment") then
        return object.WorldPosition
    end

    return nil
end

--============================================================
-- TARGET CFRAME
--============================================================

local function getTargetCFrame(object)
    if not object then
        return nil
    end

    if object:IsA("BasePart") then
        return object.CFrame
    end

    if object:IsA("Model") then
        return object:GetPivot()
    end

    if object:IsA("Attachment") then
        return object.WorldCFrame
    end

    return nil
end

--============================================================
-- CHARACTER
--============================================================

local function getCharacter()
    local character = player.Character

    if not character then
        return nil
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        return nil
    end

    return character, root, humanoid
end

--============================================================
-- GUNDROP INSTANT TELEPORT
--============================================================

local function teleportToGunDropAndBack()
    local character, root, humanoid = getCharacter()

    if not character or not root then
        setStatus("Character not ready", C.Red)
        return
    end

    local gunDrop = findGunDrop()

    if not gunDrop then
        setStatus("GunDrop not found", C.Red)
        return
    end

    -- Сохраняем именно исходный CFrame (позиция + направление взгляда).
    local originalCFrame = root.CFrame
    local targetPosition = getObjectPosition(gunDrop)

    if not targetPosition then
        setStatus("Invalid GunDrop", C.Red)
        return
    end

    -- Моментальный TP к GunDrop.
    root.CFrame = CFrame.new(targetPosition)

    -- Сразу возвращаем исходный CFrame.
    root.CFrame = originalCFrame

    -- Проверка инвентаря после TP/возврата.
    if playerHasGun() then
        setStatus("Gun found in inventory", C.Green)
    else
        setStatus("Gun not found", C.Text2)
    end
end

--============================================================
-- FARM LOOP
--============================================================

task.spawn(function()
    while gui.Parent do
        if farmEnabled then
            local character, root = getCharacter()

            if character and root then
                local target = findCoinServer()

                if target then
                    local targetCFrame = getTargetCFrame(target)

                    if targetCFrame then
                        local distance = (targetCFrame.Position - root.Position).Magnitude
                        local duration = math.max(
                            distance / math.max(flySpeed, 1),
                            0.05
                        )

                        if activeFarmTween then
                            pcall(function()
                                activeFarmTween:Cancel()
                            end)
                        end

                        activeFarmTween = TweenService:Create(
                            root,
                            TweenInfo.new(
                                duration,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.Out
                            ),
                            {
                                CFrame = targetCFrame
                            }
                        )

                        local tween = activeFarmTween

                        setStatus("Flying to coin", C.Green)

                        tween:Play()

                        tween.Completed:Wait()

                        if activeFarmTween == tween then
                            activeFarmTween = nil
                        end
                    end
                else
                    setStatus("Searching for coin_server", C.Text3)
                end
            end
        end

        task.wait(FARM_SEARCH_DELAY)
    end
end)

--============================================================
-- PC FLY INPUT
--============================================================

local keys = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false,
    LeftControl = false
}

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    local key = input.KeyCode

    if key == Enum.KeyCode.W then
        keys.W = true
    elseif key == Enum.KeyCode.A then
        keys.A = true
    elseif key == Enum.KeyCode.S then
        keys.S = true
    elseif key == Enum.KeyCode.D then
        keys.D = true
    elseif key == Enum.KeyCode.Space then
        keys.Space = true
    elseif key == Enum.KeyCode.LeftControl then
        keys.LeftControl = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode

    if key == Enum.KeyCode.W then
        keys.W = false
    elseif key == Enum.KeyCode.A then
        keys.A = false
    elseif key == Enum.KeyCode.S then
        keys.S = false
    elseif key == Enum.KeyCode.D then
        keys.D = false
    elseif key == Enum.KeyCode.Space then
        keys.Space = false
    elseif key == Enum.KeyCode.LeftControl then
        keys.LeftControl = false
    end
end)

--============================================================
-- MOBILE FLY BUTTONS
--============================================================

local mobileControls = Instance.new("Frame")
mobileControls.Name = "MobileControls"
mobileControls.AnchorPoint = Vector2.new(1, 1)
mobileControls.Position = UDim2.new(1, -20, 1, -20)
mobileControls.Size = UDim2.new(0, 190, 0, 160)
mobileControls.BackgroundTransparency = 1
mobileControls.Visible = false
mobileControls.ZIndex = 80
mobileControls.Parent = gui

local function mobileButton(name, text, x, y)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Position = UDim2.new(0, x, 0, y)
    b.Size = UDim2.new(0, 54, 0, 45)
    b.BackgroundColor3 = C.Sidebar
    b.BackgroundTransparency = 0.05
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Text = text
    b.TextColor3 = C.Text
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 81
    b.Parent = mobileControls

    makeCorner(b, 10)
    makeStroke(b, C.BorderLight, 1, 0.2)

    return b
end

local mbW = mobileButton("W", "▲", 68, 0)
local mbA = mobileButton("A", "◀", 8, 50)
local mbS = mobileButton("S", "▼", 68, 50)
local mbD = mobileButton("D", "▶", 128, 50)
local mbUp = mobileButton("Up", "UP", 8, 105)
local mbDown = mobileButton("Down", "DOWN", 128, 105)

local function bindMobile(button, keyName)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            keys[keyName] = true
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            keys[keyName] = false
        end
    end)
end

bindMobile(mbW, "W")
bindMobile(mbA, "A")
bindMobile(mbS, "S")
bindMobile(mbD, "D")
bindMobile(mbUp, "Space")
bindMobile(mbDown, "LeftControl")

local function updateMobileVisibility()
    mobileControls.Visible =
        flyEnabled
        and UserInputService.TouchEnabled
end

task.spawn(function()
    while gui.Parent do
        updateMobileVisibility()
        task.wait(0.25)
    end
end)

--============================================================
-- FLY LOOP
--============================================================

local flyConnection = RunService.RenderStepped:Connect(function()
    if not flyEnabled then
        return
    end

    local character, root, humanoid = getCharacter()

    if not character or not root or not humanoid then
        return
    end

    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local direction = Vector3.zero

    if keys.W then
        direction += camera.CFrame.LookVector
    end

    if keys.S then
        direction -= camera.CFrame.LookVector
    end

    if keys.A then
        direction -= camera.CFrame.RightVector
    end

    if keys.D then
        direction += camera.CFrame.RightVector
    end

    if keys.Space then
        direction += Vector3.new(0, 1, 0)
    end

    if keys.LeftControl then
        direction -= Vector3.new(0, 1, 0)
    end

    -- На телефоне обычный Roblox джойстик тоже используется.
    if direction.Magnitude < 0.05 then
        local move = humanoid.MoveDirection

        if move.Magnitude > 0.05 then
            direction = move
        end
    end

    if direction.Magnitude > 0.05 then
        direction = direction.Unit

        local distance = flySpeed * 0.035

        local targetCFrame =
            root.CFrame + direction * distance

        if activeFlyTween then
            pcall(function()
                activeFlyTween:Cancel()
            end)
        end

        activeFlyTween = TweenService:Create(
            root,
            TweenInfo.new(
                FLY_TWEEN_TIME,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out
            ),
            {
                CFrame = targetCFrame
            }
        )

        activeFlyTween:Play()
    end
end)

--============================================================
-- INF JUMP
--============================================================

UserInputService.JumpRequest:Connect(function()
    if not infJumpEnabled then
        return
    end

    local character, root, humanoid = getCharacter()

    if not character or not root or not humanoid then
        return
    end

    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end)

--============================================================
-- JUMP HACK
--============================================================

local jumpCooldown = false

UserInputService.JumpRequest:Connect(function()
    if not jumpHackEnabled or jumpCooldown then
        return
    end

    local character, root, humanoid = getCharacter()

    if not character or not root or not humanoid then
        return
    end

    jumpCooldown = true

    local startCFrame = root.CFrame
    local upCFrame = startCFrame + Vector3.new(0, jumpHeight, 0)

    local upTween = TweenService:Create(
        root,
        TweenInfo.new(
            0.22,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            CFrame = upCFrame
        }
    )

    local downTween = TweenService:Create(
        root,
        TweenInfo.new(
            0.22,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        ),
        {
            CFrame = startCFrame
        }
    )

    upTween:Play()
    upTween.Completed:Wait()

    if jumpHackEnabled and root.Parent then
        downTween:Play()
    end

    task.delay(0.5, function()
        jumpCooldown = false
    end)
end)

--============================================================
-- NOCLIP
--============================================================

RunService.Stepped:Connect(function()
    if not noclipEnabled then
        return
    end

    local character = player.Character

    if not character then
        return
    end

    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart") then
            object.CanCollide = false
        end
    end
end)

--============================================================
-- RESPAWN
--============================================================

player.CharacterAdded:Connect(function()
    task.wait(0.5)

    if noclipEnabled then
        local character = player.Character

        if character then
            for _, object in ipairs(character:GetDescendants()) do
                if object:IsA("BasePart") then
                    object.CanCollide = false
                end
            end
        end
    end
end)

--============================================================
-- CLOSE / OPEN
--============================================================

main.Visible = true
openButton.Visible = false

--============================================================
-- DEFAULT PAGE
--============================================================

selectPage("Farm")

print("[MM2 Hub] Loaded successfully.")
