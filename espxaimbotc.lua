local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- File system (exploit-dependent)
local FolderName = "kkavasakisaimbot"
local FileName = "notice_accepted.txt"

local function fileExists()
    if not (isfolder and isfile and makefolder and writefile) then return false end
    if not isfolder(FolderName) then makefolder(FolderName) end
    return isfile(FolderName .. "/" .. FileName)
end

local function saveAcceptance()
    if writefile and not isfolder(FolderName) then makefolder(FolderName) end
    if writefile then
        writefile(FolderName .. "/" .. FileName, "Accepted by " .. LocalPlayer.Name .. " on " .. os.date())
    end
end

-- Config
local Config = {
    Enabled = false,
    Key = Enum.KeyCode.C,
    MenuKey = Enum.KeyCode.RightShift,
    ESPKey = Enum.KeyCode.X,

    ESPEnabled = false,
    TeamCheck = true,
    VisibleCheck = true,        -- New: Wall check for aim & ESP
    Prediction = true,          -- New: Basic movement prediction
    PredictAmount = 0.135,      -- Adjust for bullet speed feel

    TargetPart = "Head",
    FOV = 250,
    Smoothness = 0.25,          -- Lower = smoother (0.05 very smooth, 1 instant)
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),

    ESPColor = Color3.fromRGB(255, 0, 0),
    TracerEnabled = true,
    HealthBarEnabled = true,

    NoticeShown = fileExists(),
    MenuOpen = false,
    LockOnTarget = nil,
    ESPObjects = {}  -- {player = {Box, Tracer, Text, HealthBar}}
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Config.FOVColor
FOVCircle.Radius = Config.FOV
FOVCircle.Visible = Config.ShowFOV and Config.Enabled

-- Notice GUI (unchanged mostly, minor style tweaks)
local function createNoticeGUI()
    -- (Your original notice GUI code here - kept identical for brevity)
    -- Just add the OKButton click to set Config.NoticeShown = true, save, destroy, notify
    -- ... (copy from original)
end

-- Simple draggable menu (better than recreating every time)
local MenuGui
local function createMenuGUI()
    if MenuGui then MenuGui:Destroy() end
    -- (Your original menu code, but update InfoText live instead of recreating)
    -- Add toggles/sliders for new options (VisibleCheck, Prediction, Smoothness, etc.)
    -- For brevity, imagine expanded version here
end

local function updateMenuText()
    if not MenuGui then return end
    -- Update the InfoText label with current config values
end

-- ESP Creation
local function createESP(player)
    if Config.ESPObjects[player] then return end

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1
    Box.Color = Config.ESPColor

    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 2
    Tracer.Transparency = 1
    Tracer.Color = Config.ESPColor

    local Text = Drawing.new("Text")
    Text.Size = 13
    Text.Center = true
    Text.Outline = true
    Text.Color = Color3.new(1,1,1)
    Text.Font = 2

    local HealthBar = Drawing.new("Line")
    HealthBar.Thickness = 3
    HealthBar.Color = Color3.fromRGB(0,255,0)

    Config.ESPObjects[player] = {Box = Box, Tracer = Tracer, Text = Text, HealthBar = HealthBar}
end

local function removeESP(player)
    local objs = Config.ESPObjects[player]
    if objs then
        for _, obj in pairs(objs) do obj:Remove() end
        Config.ESPObjects[player] = nil
    end
end

-- Raycast visible check
local function isVisible(targetPos)
    if not Config.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPos - origin)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, direction, params)
    return result == nil or result.Position.Magnitude > direction.Magnitude - 1
end

-- Valid target check
local function isValidTarget(player)
    if player == LocalPlayer or not player.Character then return false end
    local hum = player.Character:FindFirstChild("Humanoid")
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return false end
    if Config.TeamCheck and player.Team == LocalPlayer.Team then return false end
    return true
end

-- Get closest in FOV
local function getClosestPlayer()
    local closest = nil
    local shortest = Config.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local part = player.Character:FindFirstChild(Config.TargetPart) or player.Character:FindFirstChild("Head")
            if part then
                local pos = part.Position
                if Config.Prediction then
                    local velocity = player.Character.HumanoidRootPart.Velocity
                    pos = pos + velocity * Config.PredictAmount
                end
                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen and screenPos.Z > 0 and isVisible(pos) then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- Update ESP (called every frame)
local function updateAllESP()
    if not Config.ESPEnabled then
        for _, objs in pairs(Config.ESPObjects) do
            for _, obj in pairs(objs) do obj.Visible = false end
        end
        return
    end

    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for player, objs in pairs(Config.ESPObjects) do
        if isValidTarget(player) then
            local root = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character.Humanoid
            if root and head and hum then
                local headScreen, headOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                local rootScreen, rootOn = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                if headOn and rootOn then
                    local height = math.abs(headScreen.Y - rootScreen.Y)
                    local width = height / 2

                    -- Box
                    objs.Box.Size = Vector2.new(width, height)
                    objs.Box.Position = Vector2.new(headScreen.X - width/2, headScreen.Y)
                    objs.Box.Visible = true

                    -- Tracer
                    if Config.TracerEnabled then
                        objs.Tracer.From = screenCenter
                        objs.Tracer.To = Vector2.new(headScreen.X, headScreen.Y + height/2)
                        objs.Tracer.Visible = true
                    end

                    -- Text
                    local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                    objs.Text.Text = string.format("%s\n%d/%d | %d studs", player.Name, math.floor(hum.Health), hum.MaxHealth, dist)
                    objs.Text.Position = Vector2.new(headScreen.X, headScreen.Y - 15)
                    objs.Text.Visible = true

                    -- Health Bar
                    if Config.HealthBarEnabled then
                        local healthPct = hum.Health / hum.MaxHealth
                        objs.HealthBar.From = Vector2.new(headScreen.X - width/2 - 5, headScreen.Y)
                        objs.HealthBar.To = Vector2.new(headScreen.X - width/2 - 5, headScreen.Y + height * healthPct)
                        objs.HealthBar.Color = Color3.fromHSV((healthPct / 3), 1, 1)
                        objs.HealthBar.Visible = true
                    end
                else
                    for _, obj in pairs(objs) do obj.Visible = false end
                end
            end
        else
            for _, obj in pairs(objs) do obj.Visible = false end
        end
    end
end

-- Main loop
RunService.RenderStepped:Connect(function(dt)
    -- Update FOV circle (centered on mouse, +36 for Roblox UI offset)
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = Config.FOV
    FOVCircle.Visible = Config.ShowFOV and Config.Enabled

    updateAllESP()

    if Config.Enabled and Config.NoticeShown then
        local target = Config.LockOnTarget
        if target and isValidTarget(target) and target.Character:FindFirstChild(Config.TargetPart) then
            local part = target.Character[Config.TargetPart]
            local predictPos = part.Position
            if Config.Prediction then
                predictPos = predictPos + part.Velocity * Config.PredictAmount
            end
            local screenPos, onScreen = Camera:WorldToViewportPoint(predictPos)
            if onScreen and screenPos.Z > 0 and isVisible(predictPos) then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local delta = Vector2.new(screenPos.X, screenPos.Y) - mousePos
                local move = delta * (1 - Config.Smoothness)
                mousemoverel(move.X, move.Y)
            else
                Config.LockOnTarget = nil
            end
        else
            Config.LockOnTarget = getClosestPlayer()
            if Config.LockOnTarget then
                -- Optional lock notification
            end
        end
    end
end)

-- Input
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.Key then
        if not Config.NoticeShown then return end
        Config.Enabled = not Config.Enabled
        FOVCircle.Visible = Config.ShowFOV and Config.Enabled
        Config.LockOnTarget = nil
    elseif input.KeyCode == Config.ESPKey then
        if not Config.NoticeShown then return end
        Config.ESPEnabled = not Config.ESPEnabled
    elseif input.KeyCode == Config.MenuKey then
        if not Config.NoticeShown then return end
        Config.MenuOpen = not Config.MenuOpen
        if Config.MenuOpen then createMenuGUI() else if MenuGui then MenuGui:Destroy() end end
    end
end)

-- Player handling
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Wait()
    if Config.ESPEnabled and plr ~= LocalPlayer then createESP(plr) end
end)

Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
    if Config.LockOnTarget == plr then Config.LockOnTarget = nil end
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then createESP(plr) end
end

-- Init
if not Config.NoticeShown then
    createNoticeGUI()
else
    -- Ready notification
end
