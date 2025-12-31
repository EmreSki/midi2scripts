local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Wait for character
repeat task.wait() until LocalPlayer.Character
repeat task.wait() until LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- File system setup
local FolderName = "kkavasakisaimbot"
local FileName = "notice_accepted.txt"

local function checkAcceptanceFile()
  local success, result = pcall(function()
    if not isfolder then return false end
    if not isfolder(FolderName) then makefolder(FolderName) end
    return isfile(FolderName .. "/" .. FileName)
  end)
  return success and result
end

local function saveAcceptance()
  pcall(function()
    if not writefile then return end
    if not isfolder(FolderName) then makefolder(FolderName) end
    writefile(FolderName .. "/" .. FileName, "Accepted by " .. LocalPlayer.Name .. " on " .. os.date())
  end)
end

-- Configuration
local Config = {
  AimbotEnabled = false,
  ESPEnabled = false,
  TeamCheck = true,
  TargetPart = "Head",
  FOVRadius = 200,
  Smoothness = 0.15,
  NoticeShown = checkAcceptanceFile(),
  ESPBoxes = {},
  LockTarget = nil,
  UpdateConnection = nil
}

-- Mobile GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local function createButton(name, text, yPos, color)
  local btn = Instance.new("TextButton")
  btn.Name = name
  btn.Size = UDim2.new(0, 80, 0, 80)
  btn.Position = UDim2.new(1, -95, 0, yPos)
  btn.BackgroundColor3 = color
  btn.BorderSizePixel = 0
  btn.Text = text
  btn.TextColor3 = Color3.new(1, 1, 1)
  btn.TextSize = 16
  btn.Font = Enum.Font.GothamBold
  btn.Parent = ScreenGui
  
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 15)
  corner.Parent = btn
  
  local stroke = Instance.new("UIStroke")
  stroke.Color = Color3.new(1, 1, 1)
  stroke.Thickness = 2
  stroke.Transparency = 0.7
  stroke.Parent = btn
  
  return btn
end

-- Create buttons
local AimbotBtn = createButton("Aimbot", "AIMBOT\nOFF", 80, Color3.fromRGB(60, 60, 70))
local ESPBtn = createButton("ESP", "ESP\nOFF", 175, Color3.fromRGB(60, 60, 70))
local MenuBtn = createButton("Menu", "MENU", 270, Color3.fromRGB(100, 60, 200))
local HideBtn = createButton("Hide", "HIDE", 365, Color3.fromRGB(80, 80, 90))

-- FOV Circle
local FOVCircle
if Drawing then
  FOVCircle = Drawing.new("Circle")
  FOVCircle.Radius = Config.FOVRadius
  FOVCircle.Color = Color3.new(1, 1, 1)
  FOVCircle.Thickness = 2
  FOVCircle.Visible = false
  FOVCircle.Filled = false
  FOVCircle.Transparency = 1
  FOVCircle.NumSides = 50
end

-- Functions
local function isValidTarget(player)
  if not player or player == LocalPlayer then return false end
  local char = player.Character
  if not char then return false end
  local hum = char:FindFirstChild("Humanoid")
  if not hum or hum.Health <= 0 then return false end
  if Config.TeamCheck and player.Team == LocalPlayer.Team and player.Team then return false end
  return true
end

local function getClosestTarget()
  local closest = nil
  local shortestDist = Config.FOVRadius
  local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
  
  for _, player in ipairs(Players:GetPlayers()) do
    if isValidTarget(player) then
      local char = player.Character
      local part = char:FindFirstChild(Config.TargetPart)
      if part then
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen and pos.Z > 0 then
          local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
          if dist < shortestDist then
            closest = player
            shortestDist = dist
          end
        end
      end
    end
  end
  
  return closest
end

local function aimAt(target)
  if not target or not target.Character then return end
  local part = target.Character:FindFirstChild(Config.TargetPart)
  if not part then return end
  
  local targetPos = part.Position
  local camCFrame = Camera.CFrame
  local direction = (targetPos - camCFrame.Position).Unit
  local newCFrame = CFrame.new(camCFrame.Position, camCFrame.Position + direction)
  
  Camera.CFrame = camCFrame:Lerp(newCFrame, Config.Smoothness)
end

-- ESP System
local function createESP(player)
  if not Drawing or Config.ESPBoxes[player] then return end
  
  local esp = {}
  esp.Box = Drawing.new("Square")
  esp.Box.Thickness = 2
  esp.Box.Filled = false
  esp.Box.Color = Color3.fromRGB(255, 50, 50)
  esp.Box.Visible = false
  esp.Box.Transparency = 1
  
  esp.Name = Drawing.new("Text")
  esp.Name.Size = 14
  esp.Name.Center = true
  esp.Name.Outline = true
  esp.Name.Color = Color3.new(1, 1, 1)
  esp.Name.Visible = false
  esp.Name.Font = 2
  
  Config.ESPBoxes[player] = esp
end

local function removeESP(player)
  local esp = Config.ESPBoxes[player]
  if esp then
    if esp.Box then esp.Box:Remove() end
    if esp.Name then esp.Name:Remove() end
    Config.ESPBoxes[player] = nil
  end
end

local function updateESP()
  if not Config.ESPEnabled then
    for _, esp in pairs(Config.ESPBoxes) do
      esp.Box.Visible = false
      esp.Name.Visible = false
    end
    return
  end
  
  for player, esp in pairs(Config.ESPBoxes) do
    if isValidTarget(player) then
      local char = player.Character
      local hrp = char:FindFirstChild("HumanoidRootPart")
      local head = char:FindFirstChild("Head")
      local hum = char:FindFirstChild("Humanoid")
      
      if hrp and head and hum then
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if onScreen and pos.Z > 0 then
          local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
          local botPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
          
          local height = math.abs(topPos.Y - botPos.Y)
          local width = height * 0.5
          
          esp.Box.Size = Vector2.new(width, height)
          esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
          esp.Box.Visible = true
          
          local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
          local hp = math.floor(hum.Health)
          local maxHp = math.floor(hum.MaxHealth)
          
          esp.Name.Text = player.Name .. " | " .. hp .. "/" .. maxHp .. " | " .. dist .. " studs"
          esp.Name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 18)
          esp.Name.Visible = true
        else
          esp.Box.Visible = false
          esp.Name.Visible = false
        end
      end
    else
      esp.Box.Visible = false
      esp.Name.Visible = false
    end
  end
end

-- Button Functions
local function toggleAimbot()
  if not Config.NoticeShown then return end
  
  Config.AimbotEnabled = not Config.AimbotEnabled
  
  if Config.AimbotEnabled then
    AimbotBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    AimbotBtn.Text = "AIMBOT\nON"
    if FOVCircle then FOVCircle.Visible = true end
  else
    AimbotBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    AimbotBtn.Text = "AIMBOT\nOFF"
    if FOVCircle then FOVCircle.Visible = false end
    Config.LockTarget = nil
  end
  
  game.StarterGui:SetCore("SendNotification", {
    Title = "Aimbot",
    Text = Config.AimbotEnabled and "Enabled" or "Disabled",
    Duration = 2
  })
end

local function toggleESP()
  if not Config.NoticeShown then return end
  
  Config.ESPEnabled = not Config.ESPEnabled
  
  if Config.ESPEnabled then
    ESPBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    ESPBtn.Text = "ESP\nON"
    for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
        createESP(player)
      end
    end
  else
    ESPBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    ESPBtn.Text = "ESP\nOFF"
  end
  
  game.StarterGui:SetCore("SendNotification", {
    Title = "ESP",
    Text = Config.ESPEnabled and "Enabled" or "Disabled",
    Duration = 2
  })
end

local function showMenu()
  if not Config.NoticeShown then return end
  
  local menu = Instance.new("Frame")
  menu.Name = "Menu"
  menu.Size = UDim2.new(0, 320, 0, 260)
  menu.Position = UDim2.new(0.5, -160, 0.5, -130)
  menu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
  menu.BorderSizePixel = 0
  menu.Parent = ScreenGui
  
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 12)
  corner.Parent = menu
  
  local title = Instance.new("TextLabel")
  title.Size = UDim2.new(1, -30, 0, 35)
  title.Position = UDim2.new(0, 15, 0, 10)
  title.BackgroundTransparency = 1
  title.Text = "🎯 AIMBOT MENU"
  title.TextColor3 = Color3.fromRGB(200, 100, 255)
  title.TextSize = 20
  title.Font = Enum.Font.GothamBold
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.Parent = menu
  
  local info = Instance.new("TextLabel")
  info.Size = UDim2.new(1, -30, 0, 150)
  info.Position = UDim2.new(0, 15, 0, 55)
  info.BackgroundTransparency = 1
  info.Text = string.format([[Aimbot: %s
ESP: %s

Settings:
• FOV: %d
• Target: %s
• Smoothness: %.2f
• Team Check: %s

Script by kkavasaki__]], 
    Config.AimbotEnabled and "ON ✓" or "OFF ✗",
    Config.ESPEnabled and "ON ✓" or "OFF ✗",
    Config.FOVRadius,
    Config.TargetPart,
    Config.Smoothness,
    Config.TeamCheck and "ON" or "OFF"
  )
  info.TextColor3 = Color3.new(0.9, 0.9, 0.9)
  info.TextSize = 14
  info.Font = Enum.Font.Gotham
  info.TextXAlignment = Enum.TextXAlignment.Left
  info.TextYAlignment = Enum.TextYAlignment.Top
  info.Parent = menu
  
  local closeBtn = Instance.new("TextButton")
  closeBtn.Size = UDim2.new(0, 120, 0, 35)
  closeBtn.Position = UDim2.new(0.5, -60, 1, -45)
  closeBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
  closeBtn.BorderSizePixel = 0
  closeBtn.Text = "CLOSE"
  closeBtn.TextColor3 = Color3.new(1, 1, 1)
  closeBtn.TextSize = 16
  closeBtn.Font = Enum.Font.GothamBold
  closeBtn.Parent = menu
  
  local btnCorner = Instance.new("UICorner")
  btnCorner.CornerRadius = UDim.new(0, 8)
  btnCorner.Parent = closeBtn
  
  closeBtn.MouseButton1Click:Connect(function()
    menu:Destroy()
  end)
end

local function toggleButtons()
  local visible = AimbotBtn.Visible
  AimbotBtn.Visible = not visible
  ESPBtn.Visible = not visible
  MenuBtn.Visible = not visible
  HideBtn.Text = visible and "SHOW" or "HIDE"
end

-- Connect buttons
AimbotBtn.MouseButton1Click:Connect(toggleAimbot)
ESPBtn.MouseButton1Click:Connect(toggleESP)
MenuBtn.MouseButton1Click:Connect(showMenu)
HideBtn.MouseButton1Click:Connect(toggleButtons)

-- Main Loop
RunService.RenderStepped:Connect(function()
  -- Update FOV Circle
  if FOVCircle then
    local center = Camera.ViewportSize / 2
    FOVCircle.Position = Vector2.new(center.X, center.Y)
  end
  
  -- Update ESP
  updateESP()
  
  -- Aimbot
  if Config.AimbotEnabled then
    if not Config.LockTarget or not isValidTarget(Config.LockTarget) then
      Config.LockTarget = getClosestTarget()
      if Config.LockTarget then
        game.StarterGui:SetCore("SendNotification", {
          Title = "Target Locked",
          Text = Config.LockTarget.Name,
          Duration = 1
        })
      end
    end
    
    if Config.LockTarget then
      aimAt(Config.LockTarget)
    end
  end
end)

-- Player Events
Players.PlayerRemoving:Connect(function(player)
  removeESP(player)
  if Config.LockTarget == player then
    Config.LockTarget = nil
  end
end)

Players.PlayerAdded:Connect(function(player)
  player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Config.ESPEnabled then
      createESP(player)
    end
  end)
end)

-- Initialize ESP
for _, player in ipairs(Players:GetPlayers()) do
  if player ~= LocalPlayer then
    createESP(player)
  end
end

-- Notice GUI
if not Config.NoticeShown then
  local notice = Instance.new("Frame")
  notice.Size = UDim2.new(0, 340, 0, 280)
  notice.Position = UDim2.new(0.5, -170, 0.5, -140)
  notice.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
  notice.BorderSizePixel = 0
  notice.Parent = ScreenGui
  
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 12)
  corner.Parent = notice
  
  local title = Instance.new("TextLabel")
  title.Size = UDim2.new(1, -30, 0, 35)
  title.Position = UDim2.new(0, 15, 0, 15)
  title.BackgroundTransparency = 1
  title.Text = "⚠️ MOBILE AIMBOT"
  title.TextColor3 = Color3.fromRGB(200, 100, 255)
  title.TextSize = 22
  title.Font = Enum.Font.GothamBold
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.Parent = notice
  
  local msg = Instance.new("TextLabel")
  msg.Size = UDim2.new(1, -30, 0, 150)
  msg.Position = UDim2.new(0, 15, 0, 60)
  msg.BackgroundTransparency = 1
  msg.Text = [[Mobile aimbot ready!

Buttons (right side):
• AIMBOT - Toggle aimbot
• ESP - Toggle ESP
• MENU - Settings
• HIDE - Hide buttons

This script is written by kkavasaki__]]
  msg.TextColor3 = Color3.new(0.9, 0.9, 0.9)
  msg.TextSize = 14
  msg.Font = Enum.Font.Gotham
  msg.TextWrapped = true
  msg.TextXAlignment = Enum.TextXAlignment.Left
  msg.TextYAlignment = Enum.TextYAlignment.Top
  msg.Parent = notice
  
  local okBtn = Instance.new("TextButton")
  okBtn.Size = UDim2.new(0, 140, 0, 40)
  okBtn.Position = UDim2.new(0.5, -70, 1, -55)
  okBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
  okBtn.BorderSizePixel = 0
  okBtn.Text = "OK"
  okBtn.TextColor3 = Color3.new(1, 1, 1)
  okBtn.TextSize = 18
  okBtn.Font = Enum.Font.GothamBold
  okBtn.Parent = notice
  
  local btnCorner = Instance.new("UICorner")
  btnCorner.CornerRadius = UDim.new(0, 8)
  btnCorner.Parent = okBtn
  
  okBtn.MouseButton1Click:Connect(function()
    Config.NoticeShown = true
    saveAcceptance()
    notice:Destroy()
    game.StarterGui:SetCore("SendNotification", {
      Title = "Aimbot Ready",
      Text = "Use buttons on right",
      Duration = 3
    })
  end)
else
  game.StarterGui:SetCore("SendNotification", {
    Title = "Aimbot Loaded",
    Text = "Buttons on right side",
    Duration = 2
  })
end

ScreenGui.Parent = game:GetService("CoreGui")

print("Mobile Aimbot loaded by kkavasaki__")
