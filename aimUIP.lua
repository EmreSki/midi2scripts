-- Full Featured Aimbot + ESP with UI
-- RightShift to toggle | C for Aimbot | X for ESP
-- Script by kkavasaki__ (patched to fix "locks on feet" issue)

local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Wait for character
repeat task.wait() until LocalPlayer.Character
repeat task.wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

--// File System
local FOLDER = "kkavasakisaimbot"
local CONFIG_FILE = FOLDER.."/config.json"
local NOTICE_FILE = FOLDER.."/notice_accepted.txt"

local function setupFolder()
    pcall(function()
        if writefile and not isfolder(FOLDER) then
            makefolder(FOLDER)
        end
    end)
end

setupFolder()

--// Check Acceptance
local function checkAcceptanceFile()
    local success, result = pcall(function()
        if not isfolder or not isfile then return false end
        return isfile(NOTICE_FILE)
    end)
    return success and result
end

local function saveAcceptance()
    pcall(function()
        if not writefile then return end
        setupFolder()
        writefile(NOTICE_FILE, "Accepted by " .. LocalPlayer.Name .. " on " .. os.date("%Y-%m-%d %H:%M:%S"))
    end)
end

--// Default Config
local Config = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        TargetPart = "Head",
        FOV = 250,
        Sensitivity = 0.5,
        ShowFOV = true
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true
    },
    NoticeAccepted = checkAcceptanceFile()
}

--// Save/Load Config
local function saveConfig()
    pcall(function()
        if not writefile then return end
        setupFolder()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
    end)
end

local function loadConfig()
    pcall(function()
        if not readfile or not isfile(CONFIG_FILE) then return end
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if data then
            for k, v in pairs(data) do
                if Config[k] then
                    for k2, v2 in pairs(v) do
                        if Config[k][k2] ~= nil then
                            Config[k][k2] = v2
                        end
                    end
                end
            end
        end
    end)
end

loadConfig()

--// Theme
local Theme = {
    Main = Color3.fromRGB(25, 25, 35),
    Secondary = Color3.fromRGB(35, 35, 50),
    Button = Color3.fromRGB(45, 45, 60),
    Accent = Color3.fromRGB(180, 120, 255),
    Text = Color3.fromRGB(255, 255, 255)
}

--// Variables
local LockOnTarget = nil
local FOVCircle
local ESPBoxes = {}

-- Helper: Resolve requested body part across rig types and provide aiming offset
local function resolvePart(character, partName)
    if not character then return nil, nil end

    local candidates = {}
    if partName == "Head" then
        candidates = {"Head"}
    elseif partName == "Torso" then
        candidates = {"Torso", "UpperTorso", "LowerTorso"}
    elseif partName == "HumanoidRootPart" then
        candidates = {"HumanoidRootPart", "Root", "LowerTorso", "UpperTorso", "Torso"}
    else
        candidates = {partName, "Head", "HumanoidRootPart"}
    end

    for _, name in ipairs(candidates) do
        local p = character:FindFirstChild(name)
        if p then
            return p, name
        end
    end

    return nil, nil
end

local function getAimPositionFromPart(part, resolvedName)
    if not part then return nil end
    -- Aim slightly above head/chest to avoid aiming at feet or lower points
    if resolvedName == "Head" then
        return part.Position + Vector3.new(0, 0.5, 0)
    elseif resolvedName == "UpperTorso" or resolvedName == "Torso" or resolvedName == "Torso" then
        return part.Position + Vector3.new(0, 0.8, 0)
    elseif resolvedName == "HumanoidRootPart" or resolvedName == "Root" then
        -- HRP often near waist; aim a bit higher (chest)
        return part.Position + Vector3.new(0, 1, 0)
    else
        -- Generic small upward offset
        return part.Position + Vector3.new(0, 0.7, 0)
    end
end

--// FOV Circle
if Drawing then
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Radius = Config.Aimbot.FOV
        FOVCircle.Color = Color3.new(1, 1, 1)
        FOVCircle.Thickness = 2
        FOVCircle.Filled = false
        FOVCircle.Transparency = 1
        FOVCircle.NumSides = 64
    end)
end

--// UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

--// Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(460, 380)
Main.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(230, 190)
Main.BackgroundColor3 = Theme.Main
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

--// Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.fromOffset(10, 10)
Title.BackgroundTransparency = 1
Title.Text = "🎯 AIMBOT v2.0"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--// Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(30, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Theme.Button
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = Main

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

--// Drag
local dragging, dragStart, startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--// Tab System
local Tabs = {"Aimbot", "ESP", "Config"}
local Pages = {}
local CurrentTab = nil

local TabBar = Instance.new("Frame")
TabBar.Position = UDim2.fromOffset(10, 50)
TabBar.Size = UDim2.fromOffset(120, 320)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local Holder = Instance.new("ScrollingFrame")
Holder.Position = UDim2.fromOffset(140, 50)
Holder.Size = UDim2.fromOffset(310, 320)
Holder.BackgroundTransparency = 1
Holder.BorderSizePixel = 0
Holder.ScrollBarThickness = 4
Holder.CanvasSize = UDim2.fromOffset(0, 0)
Holder.Parent = Main

local HolderLayout = Instance.new("UIListLayout")
HolderLayout.Padding = UDim.new(0, 8)
HolderLayout.Parent = Holder

local function switchTab(name)
    for tabName, page in pairs(Pages) do
        page.Visible = (tabName == name)
    end
    CurrentTab = name
end

for i, name in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name
    TabBtn.Size = UDim2.fromOffset(120, 36)
    TabBtn.Position = UDim2.fromOffset(0, (i - 1) * 42)
    TabBtn.BackgroundColor3 = Theme.Button
    TabBtn.Text = name
    TabBtn.TextColor3 = Theme.Text
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 14
    TabBtn.Parent = TabBar
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabBtn
    
    TabBtn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    
    local Page = Instance.new("Frame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.fromScale(1, 1)
    Page.BackgroundTransparency = 1
    Page.Visible = (i == 1)
    Page.Parent = Holder
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = Page
    
    Pages[name] = Page
end

--// Widget Functions
local function Toggle(parent, name, getValue, setValue)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 32)
    Frame.BackgroundColor3 = Theme.Secondary
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.fromOffset(10, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.Parent = Frame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(44, 20)
    Button.Position = UDim2.new(1, -54, 0.5, -10)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 11
    Button.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button
    
    local function refresh()
        local val = getValue()
        Button.Text = val and "ON" or "OFF"
        Button.BackgroundColor3 = val and Theme.Accent or Theme.Button
        Button.TextColor3 = Theme.Text
    end
    
    refresh()
    
    Button.MouseButton1Click:Connect(function()
        setValue(not getValue())
        refresh()
        saveConfig()
    end)
end

local function Slider(parent, name, min, max, getValue, setValue)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 50)
    Frame.BackgroundColor3 = Theme.Secondary
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 0, 20)
    Label.Position = UDim2.fromOffset(10, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.Parent = Frame
    
    local Value = Instance.new("TextLabel")
    Value.Size = UDim2.fromOffset(60, 20)
    Value.Position = UDim2.new(1, -70, 0, 5)
    Value.BackgroundTransparency = 1
    Value.TextColor3 = Theme.Accent
    Value.Font = Enum.Font.GothamBold
    Value.TextSize = 12
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.Parent = Frame
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -20, 0, 4)
    SliderBG.Position = UDim2.fromOffset(10, 32)
    SliderBG.BackgroundColor3 = Theme.Button
    SliderBG.Parent = Frame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.Parent = SliderBG
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.fromScale(0.5, 1)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.Parent = SliderBG
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.Parent = Fill
    
    local function update()
        local val = getValue()
        Value.Text = tostring(math.floor(val * 10) / 10)
        Fill.Size = UDim2.fromScale(math.clamp((val - min) / (max - min), 0, 1), 1)
    end
    
    update()
    
    local dragging = false
    
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
            setValue(min + (max - min) * pos)
            update()
            saveConfig()
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
            setValue(min + (max - min) * pos)
            update()
            saveConfig()
        end
    end)
end

local function Dropdown(parent, name, options, getValue, setValue)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 32)
    Frame.BackgroundColor3 = Theme.Secondary
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, -10, 1, 0)
    Label.Position = UDim2.fromOffset(10, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.Parent = Frame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.5, -20, 0, 24)
    Button.Position = UDim2.new(0.5, 10, 0.5, -12)
    Button.BackgroundColor3 = Theme.Button
    Button.TextColor3 = Theme.Text
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 12
    Button.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button
    
    local function refresh()
        Button.Text = getValue()
    end
    
    refresh()
    
    local currentIndex = 1
    for i, v in ipairs(options) do
        if v == getValue() then
            currentIndex = i
            break
        end
    end
    
    Button.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        setValue(options[currentIndex])
        refresh()
        saveConfig()
    end)
end

--// Aimbot Page
Toggle(Pages.Aimbot, "Enable Aimbot",
    function() return Config.Aimbot.Enabled end,
    function(v) 
        Config.Aimbot.Enabled = v
        if FOVCircle then
            FOVCircle.Visible = v and Config.Aimbot.ShowFOV
        end
        if not v then
            LockOnTarget = nil
        end
    end)

Toggle(Pages.Aimbot, "Team Check",
    function() return Config.Aimbot.TeamCheck end,
    function(v) Config.Aimbot.TeamCheck = v end)

Toggle(Pages.Aimbot, "Show FOV Circle",
    function() return Config.Aimbot.ShowFOV end,
    function(v)
        Config.Aimbot.ShowFOV = v
        if FOVCircle then
            FOVCircle.Visible = v and Config.Aimbot.Enabled
        end
    end)

Slider(Pages.Aimbot, "FOV Radius", 50, 500,
    function() return Config.Aimbot.FOV end,
    function(v)
        Config.Aimbot.FOV = v
        if FOVCircle then
            FOVCircle.Radius = v
        end
    end)

Slider(Pages.Aimbot, "Sensitivity", 0.1, 1,
    function() return Config.Aimbot.Sensitivity end,
    function(v) Config.Aimbot.Sensitivity = v end)

Dropdown(Pages.Aimbot, "Target Part", {"Head", "Torso", "HumanoidRootPart"},
    function() return Config.Aimbot.TargetPart end,
    function(v) Config.Aimbot.TargetPart = v end)

--// ESP Page
Toggle(Pages.ESP, "Enable ESP",
    function() return Config.ESP.Enabled end,
    function(v) Config.ESP.Enabled = v end)

Toggle(Pages.ESP, "Show Boxes",
    function() return Config.ESP.Boxes end,
    function(v) Config.ESP.Boxes = v end)

Toggle(Pages.ESP, "Show Names",
    function() return Config.ESP.Names end,
    function(v) Config.ESP.Names = v end)

Toggle(Pages.ESP, "Show Distance",
    function() return Config.ESP.Distance end,
    function(v) Config.ESP.Distance = v end)

Toggle(Pages.ESP, "Show Health",
    function() return Config.ESP.Health end,
    function(v) Config.ESP.Health = v end)

--// Config Page
local function createButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 36)
    Button.BackgroundColor3 = Theme.Button
    Button.Text = text
    Button.TextColor3 = Theme.Text
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
end

createButton(Pages.Config, "💾 Save Config", saveConfig)
createButton(Pages.Config, "📂 Load Config", function()
    loadConfig()
    -- Refresh UI elements
    switchTab(CurrentTab or "Aimbot")
end)

--// ESP Functions
local function createESP(player)
    if not Drawing or ESPBoxes[player] then return end
    
    pcall(function()
        local esp = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Info = Drawing.new("Text")
        }
        
        esp.Box.Visible = false
        esp.Box.Color = Color3.fromRGB(255, 0, 0)
        esp.Box.Thickness = 2
        esp.Box.Transparency = 1
        esp.Box.Filled = false
        
        esp.Name.Visible = false
        esp.Name.Color = Color3.new(1, 1, 1)
        esp.Name.Size = 14
        esp.Name.Center = true
        esp.Name.Outline = true
        esp.Name.Font = 2
        
        esp.Info.Visible = false
        esp.Info.Color = Color3.new(1, 1, 1)
        esp.Info.Size = 12
        esp.Info.Center = true
        esp.Info.Outline = true
        esp.Info.Font = 2
        
        ESPBoxes[player] = esp
    end)
end

local function removeESP(player)
    pcall(function()
        local esp = ESPBoxes[player]
        if esp then
            if esp.Box then esp.Box:Remove() end
            if esp.Name then esp.Name:Remove() end
            if esp.Info then esp.Info:Remove() end
            ESPBoxes[player] = nil
        end
    end)
end

local function updateESP()
    if not Config.ESP.Enabled or not Drawing then
        for _, esp in pairs(ESPBoxes) do
            pcall(function()
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Info.Visible = false
            end)
        end
        return
    end
    
    for player, esp in pairs(ESPBoxes) do
        pcall(function()
            if not player or not player.Parent or player == LocalPlayer then
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Info.Visible = false
                return
            end
            
            local char = player.Character
            if not char then
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Info.Visible = false
                return
            end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChild("Humanoid")
            
            if not hrp or not head or not hum or hum.Health <= 0 then
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Info.Visible = false
                return
            end
            
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen and vector.Z > 0 then
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2
                
                if Config.ESP.Boxes then
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end
                
                if Config.ESP.Names then
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(vector.X, vector.Y - height / 2 - 18)
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end
                
                if Config.ESP.Distance or Config.ESP.Health then
                    local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                    local hp = math.floor(hum.Health)
                    local maxHp = math.floor(hum.MaxHealth)
                    
                    local infoText = ""
                    if Config.ESP.Health then
                        infoText = hp .. "/" .. maxHp
                    end
                    if Config.ESP.Distance then
                        if infoText ~= "" then
                            infoText = infoText .. " | "
                        end
                        infoText = infoText .. dist .. " studs"
                    end
                    
                    esp.Info.Text = infoText
                    esp.Info.Position = Vector2.new(vector.X, vector.Y + height / 2 + 5)
                    esp.Info.Visible = true
                else
                    esp.Info.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Info.Visible = false
            end
        end)
    end
end

--// Aimbot Functions
local function isValidTarget(player)
    if not player or player == LocalPlayer then return false end
    if not player.Character then return false end
    
    local hum = player.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    if Config.Aimbot.TeamCheck and player.Team == LocalPlayer.Team and player.Team then
        return false
    end
    
    return true
end

local function getClosestPlayerInFOV()
    local closest = nil
    local shortestDist = Config.Aimbot.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        pcall(function()
            if isValidTarget(player) then
                local part, resolvedName = resolvePart(player.Character, Config.Aimbot.TargetPart)
                if part then
                    local aimPos = getAimPositionFromPart(part, resolvedName)
                    if aimPos then
                        local pos, onScreen = Camera:WorldToViewportPoint(aimPos)
                        if onScreen and pos.Z > 0 then
                            local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                            if dist < shortestDist then
                                closest = player
                                shortestDist = dist
                            end
                        end
                    end
                end
            end
        end)
    end
    
    return closest
end

--// Update FOV Circle
if FOVCircle then
    RunService.RenderStepped:Connect(function()
        pcall(function()
            FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        end)
    end)
end

--// Main Loop
RunService.RenderStepped:Connect(function()
    updateESP()
    
    if Config.Aimbot.Enabled and Config.NoticeAccepted then
        pcall(function()
            if LockOnTarget and isValidTarget(LockOnTarget) then
                local part, resolvedName = resolvePart(LockOnTarget.Character, Config.Aimbot.TargetPart)
                if part then
                    local aimPos = getAimPositionFromPart(part, resolvedName)
                    local pos, onScreen = Camera:WorldToViewportPoint(aimPos)
                    if onScreen and pos.Z > 0 then
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local aimScreen = Vector2.new(pos.X, pos.Y)
                        local movement = (aimScreen - mousePos) * Config.Aimbot.Sensitivity
                        
                        if mousemoverel then
                            mousemoverel(movement.X, movement.Y)
                        end
                    end
                end
            else
                LockOnTarget = getClosestPlayerInFOV()
            end
        end)
    end
end)

--// Input Handling
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    pcall(function()
        if input.KeyCode == Enum.KeyCode.RightShift then
            Main.Visible = not Main.Visible
        elseif input.KeyCode == Enum.KeyCode.C then
            if not Config.NoticeAccepted then return end
            Config.Aimbot.Enabled = not Config.Aimbot.Enabled
            if FOVCircle then
                FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
            end
            if not Config.Aimbot.Enabled then
                LockOnTarget = nil
            end
            game.StarterGui:SetCore("SendNotification", {
                Title = "Aimbot",
                Text = Config.Aimbot.Enabled and "Enabled" or "Disabled",
                Duration = 2
            })
        elseif input.KeyCode == Enum.KeyCode.X then
            if not Config.NoticeAccepted then return end
            Config.ESP.Enabled = not Config.ESP.Enabled
            game.StarterGui:SetCore("SendNotification", {
                Title = "ESP",
                Text = Config.ESP.Enabled and "Enabled" or "Disabled",
                Duration = 2
            })
        end
    end)
end)

--// Player Events
Players.PlayerRemoving:Connect(function(player)
    if LockOnTarget == player then
        LockOnTarget = nil
    end
    removeESP(player)
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if player ~= LocalPlayer then
            createESP(player)
        end
    end)
end)

--// Initialize ESP
task.wait(1)
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

--// Notice GUI
if not Config.NoticeAccepted then
    local NoticeGui = Instance.new("ScreenGui")
    NoticeGui.Name = "Notice"
    NoticeGui.ResetOnSpawn = false
    NoticeGui.Parent = game:GetService("CoreGui")
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(400, 260)
    Frame.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(200, 130)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = NoticeGui
    
    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 10)
    FCorner.Parent = Frame
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -40, 0, 40)
    NTitle.Position = UDim2.fromOffset(20, 20)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = "⚠️ AIMBOT NOTICE"
    NTitle.TextColor3 = Color3.fromRGB(200, 100, 255)
    NTitle.TextSize = 24
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Frame
    
    local NMsg = Instance.new("TextLabel")
    NMsg.Size = UDim2.new(1, -40, 0, 110)
    NMsg.Position = UDim2.fromOffset(20, 70)
    NMsg.BackgroundTransparency = 1
    NMsg.Text = "Aimbot & ESP ready to use!\n\nControls:\n• C - Toggle Aimbot\n• X - Toggle ESP\n• Right Shift - Open Menu\n\nScript by kkavasaki__"
    NMsg.TextColor3 = Color3.fromRGB(220, 220, 220)
    NMsg.TextSize = 15
    NMsg.Font = Enum.Font.Gotham
    NMsg.TextWrapped = true
    NMsg.TextYAlignment = Enum.TextYAlignment.Top
    NMsg.TextXAlignment = Enum.TextXAlignment.Left
    NMsg.Parent = Frame
    
    local AcceptBtn = Instance.new("TextButton")
    AcceptBtn.Size = UDim2.fromOffset(160, 42)
    AcceptBtn.Position = UDim2.fromScale(0.5, 1) - UDim2.fromOffset(80, 60)
    AcceptBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
    AcceptBtn.Text = "ACCEPT"
    AcceptBtn.TextColor3 = Color3.new(1, 1, 1)
    AcceptBtn.TextSize = 18
    AcceptBtn.Font = Enum.Font.GothamBold
    AcceptBtn.Parent = Frame
    
    local ACorner = Instance.new("UICorner")
    ACorner.CornerRadius = UDim.new(0, 8)
    ACorner.Parent = AcceptBtn
    
    AcceptBtn.MouseButton1Click:Connect(function()
        Config.NoticeAccepted = true
        saveAcceptance()
        saveConfig()
        NoticeGui:Destroy()
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Aimbot Ready",
            Text = "Press Right Shift to open menu",
            Duration = 3
        })
    end)
else
    game.StarterGui:SetCore("SendNotification", {
        Title = "Aimbot Loaded",
        Text = "Right Shift: Menu | C: Aimbot | X: ESP",
        Duration = 3
    })
end

print("✓ Aimbot UI Framework loaded by kkavasaki__ (patched)")
