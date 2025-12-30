local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- File system setup
local FolderName = "kkavasakisaimbot"
local FileName = "notice_accepted.txt"

-- Check if file system is available
local function checkAcceptanceFile()
  if not isfolder then
    return false
  end
  
  if not isfolder(FolderName) then
    makefolder(FolderName)
  end
  
  if isfile(FolderName .. "/" .. FileName) then
    return true
  end
  
  return false
end

-- Save acceptance to file
local function saveAcceptance()
  if not writefile then
    return
  end
  
  if not isfolder(FolderName) then
    makefolder(FolderName)
  end
  
  writefile(FolderName .. "/" .. FileName, "Notice accepted by " .. LocalPlayer.Name .. " on " .. os.date("%Y-%m-%d %H:%M:%S"))
end

-- Configuration
local Config = {
  Enabled = false,
  Key = Enum.KeyCode.C,
  MenuKey = Enum.KeyCode.RightShift,
  ESPKey = Enum.KeyCode.X,
  ESPEnabled = false,
  TeamCheck = true,
  TargetPart = "Head",
  FOV = 250,
  Sensitivity = 0.5,
  ShowFOV = true,
  FOVColor = Color3.fromRGB(255, 255, 255),
  LockOnTarget = nil,
  NoticeShown = checkAcceptanceFile(),
  MenuOpen = false,
  ESPColor = Color3.fromRGB(255, 0, 0),
  ESPBoxes = {}
}

-- Create Notice GUI
local function createNoticeGUI()
  local ScreenGui = Instance.new("ScreenGui")
  ScreenGui.Name = "AimbotNotice"
  ScreenGui.ResetOnSpawn = false
  ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  
  -- Background Frame
  local Frame = Instance.new("Frame")
  Frame.Size = UDim2.new(0, 400, 0, 250)
  Frame.Position = UDim2.new(0.5, -200, 0.5, -125)
  Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
  Frame.BorderSizePixel = 0
  Frame.Parent = ScreenGui
  
  local UICorner = Instance.new("UICorner")
  UICorner.CornerRadius = UDim.new(0, 12)
  UICorner.Parent = Frame
  
  -- Title
  local Title = Instance.new("TextLabel")
  Title.Size = UDim2.new(1, -40, 0, 40)
  Title.Position = UDim2.new(0, 20, 0, 20)
  Title.BackgroundTransparency = 1
  Title.Text = "⚠️ AIMBOT NOTICE"
  Title.TextColor3 = Color3.fromRGB(200, 100, 255)
  Title.TextSize = 24
  Title.Font = Enum.Font.GothamBold
  Title.TextXAlignment = Enum.TextXAlignment.Left
  Title.Parent = Frame
  
  -- Message
  local Message = Instance.new("TextLabel")
  Message.Size = UDim2.new(1, -40, 0, 100)
  Message.Position = UDim2.new(0, 20, 0, 70)
  Message.BackgroundTransparency = 1
  Message.Text = "Aimbot is ready to use!\n\nPress C to toggle Aimbot ON/OFF\nPress X to toggle ESP ON/OFF\nPress Right Shift to open menu\n\nThis script is written by kkavasaki__"
  Message.TextColor3 = Color3.fromRGB(220, 220, 220)
  Message.TextSize = 16
  Message.Font = Enum.Font.Gotham
  Message.TextWrapped = true
  Message.TextYAlignment = Enum.TextYAlignment.Top
  Message.Parent = Frame
  
  -- OK Button
  local OKButton = Instance.new("TextButton")
  OKButton.Size = UDim2.new(0, 150, 0, 40)
  OKButton.Position = UDim2.new(0.5, -75, 1, -60)
  OKButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
  OKButton.Text = "OK"
  OKButton.TextColor3 = Color3.fromRGB(255, 255, 255)
  OKButton.TextSize = 18
  OKButton.Font = Enum.Font.GothamBold
  OKButton.Parent = Frame
  
  local ButtonCorner = Instance.new("UICorner")
  ButtonCorner.CornerRadius = UDim.new(0, 8)
  ButtonCorner.Parent = OKButton
  
  -- Button hover effect
  OKButton.MouseEnter:Connect(function()
    OKButton.BackgroundColor3 = Color3.fromRGB(120, 80, 220)
  end)
  
  OKButton.MouseLeave:Connect(function()
    OKButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
  end)
  
  -- Button click
  OKButton.MouseButton1Click:Connect(function()
    Config.NoticeShown = true
    saveAcceptance()
    ScreenGui:Destroy()
    
    game.StarterGui:SetCore("SendNotification", {
      Title = "Aimbot Ready",
      Text = "C: Aimbot | X: ESP | Right Shift: Menu",
      Duration = 3
    })
  end)
  
  ScreenGui.Parent = LocalPlayer.PlayerGui
end

-- Create Menu GUI
local function createMenuGUI()
  local ScreenGui = Instance.new("ScreenGui")
  ScreenGui.Name = "AimbotMenu"
  ScreenGui.ResetOnSpawn = false
  ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  
  local Frame = Instance.new("Frame")
  Frame.Size = UDim2.new(0, 350, 0, 300)
  Frame.Position = UDim2.new(0.5, -175, 0.5, -150)
  Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
  Frame.BorderSizePixel = 0
  Frame.Parent = ScreenGui
  
  local UICorner = Instance.new("UICorner")
  UICorner.CornerRadius = UDim.new(0, 12)
  UICorner.Parent = Frame
  
  local Title = Instance.new("TextLabel")
  Title.Size = UDim2.new(1, -40, 0, 40)
  Title.Position = UDim2.new(0, 20, 0, 20)
  Title.BackgroundTransparency = 1
  Title.Text = "🎯 AIMBOT MENU"
  Title.TextColor3 = Color3.fromRGB(200, 100, 255)
  Title.TextSize = 22
  Title.Font = Enum.Font.GothamBold
  Title.TextXAlignment = Enum.TextXAlignment.Left
  Title.Parent = Frame
  
  local InfoText = Instance.new("TextLabel")
  InfoText.Size = UDim2.new(1, -40, 0, 180)
  InfoText.Position = UDim2.new(0, 20, 0, 70)
  InfoText.BackgroundTransparency = 1
  InfoText.Text = "Aimbot: " .. (Config.Enabled and "ENABLED ✓" or "DISABLED ✗") .. "\nESP: " .. (Config.ESPEnabled and "ENABLED ✓" or "DISABLED ✗") .. "\n\nKeybinds:\n• C - Toggle Aimbot\n• X - Toggle ESP\n• Right Shift - Toggle Menu\n\nSettings:\n• FOV: " .. Config.FOV .. "\n• Target: " .. Config.TargetPart .. "\n• Sensitivity: " .. Config.Sensitivity
  InfoText.TextColor3 = Color3.fromRGB(220, 220, 220)
  InfoText.TextSize = 14
  InfoText.Font = Enum.Font.Gotham
  InfoText.TextWrapped = true
  InfoText.TextYAlignment = Enum.TextYAlignment.Top
  InfoText.TextXAlignment = Enum.TextXAlignment.Left
  InfoText.Parent = Frame
  
  local CloseButton = Instance.new("TextButton")
  CloseButton.Size = UDim2.new(0, 120, 0, 35)
  CloseButton.Position = UDim2.new(0.5, -60, 1, -55)
  CloseButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
  CloseButton.Text = "CLOSE"
  CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
  CloseButton.TextSize = 16
  CloseButton.Font = Enum.Font.GothamBold
  CloseButton.Parent = Frame
  
  local CloseCorner = Instance.new("UICorner")
  CloseCorner.CornerRadius = UDim.new(0, 8)
  CloseCorner.Parent = CloseButton
  
  CloseButton.MouseButton1Click:Connect(function()
    Config.MenuOpen = false
    ScreenGui:Destroy()
  end)
  
  ScreenGui.Parent = LocalPlayer.PlayerGui
  return ScreenGui
end

-- FOV Circle Drawing
local FOVCircle
if Config.ShowFOV and Drawing then
  FOVCircle = Drawing.new("Circle")
  FOVCircle.Visible = Config.Enabled
  FOVCircle.Radius = Config.FOV
  FOVCircle.Color = Config.FOVColor
  FOVCircle.Thickness = 1
  FOVCircle.Filled = false
  FOVCircle.Transparency = 1
end

-- Toggle function
local function toggleAimbot()
  if not Config.NoticeShown then
    game.StarterGui:SetCore("SendNotification", {
      Title = "Notice Required",
      Text = "Please accept the notice first!",
      Duration = 2
    })
    return
  end
  
  Config.Enabled = not Config.Enabled
  if FOVCircle then
    FOVCircle.Visible = Config.Enabled
  end
  
  if not Config.Enabled then
    Config.LockOnTarget = nil
  end
  
  local message = Config.Enabled and "Aimbot: ON" or "Aimbot: OFF"
  game.StarterGui:SetCore("SendNotification", {
    Title = "Aimbot",
    Text = message,
    Duration = 2
  })
end

-- Toggle menu
local function toggleMenu()
  if not Config.NoticeShown then
    return
  end
  
  Config.MenuOpen = not Config.MenuOpen
  
  if Config.MenuOpen then
    createMenuGUI()
  else
    local gui = LocalPlayer.PlayerGui:FindFirstChild("AimbotMenu")
    if gui then
      gui:Destroy()
    end
  end
end

-- ESP Functions
local function createESP(player)
  if not Drawing then return end
  
  local esp = {
    Box = Drawing.new("Square"),
    Info = Drawing.new("Text")
  }
  
  -- Box settings
  esp.Box.Visible = false
  esp.Box.Color = Config.ESPColor
  esp.Box.Thickness = 2
  esp.Box.Transparency = 1
  esp.Box.Filled = false
  
  -- Info text settings (combined username, health, studs)
  esp.Info.Visible = false
  esp.Info.Color = Color3.fromRGB(255, 255, 255)
  esp.Info.Size = 13
  esp.Info.Center = true
  esp.Info.Outline = true
  esp.Info.Font = 2
  
  Config.ESPBoxes[player] = esp
end

local function removeESP(player)
  local esp = Config.ESPBoxes[player]
  if esp then
    for _, drawing in pairs(esp) do
      drawing:Remove()
    end
    Config.ESPBoxes[player] = nil
  end
end

local function updateESP()
  if not Config.ESPEnabled then
    for _, esp in pairs(Config.ESPBoxes) do
      for _, drawing in pairs(esp) do
        drawing.Visible = false
      end
    end
    return
  end
  
  for player, esp in pairs(Config.ESPBoxes) do
    if isValidTarget(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
      local hrp = player.Character.HumanoidRootPart
      local head = player.Character:FindFirstChild("Head")
      local humanoid = player.Character:FindFirstChild("Humanoid")
      
      if hrp and head and humanoid then
        local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        
        if onScreen then
          local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
          local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
          
          local height = math.abs(headPos.Y - legPos.Y)
          local width = height / 2
          
          -- Update box
          esp.Box.Size = Vector2.new(width, height)
          esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
          esp.Box.Visible = true
          
          -- Calculate distance in studs
          local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
          
          -- Get health
          local health = math.floor(humanoid.Health)
          local maxHealth = math.floor(humanoid.MaxHealth)
          
          -- Combined info text: Username | Health | Studs
          esp.Info.Text = player.Name .. " | " .. health .. "/" .. maxHealth .. " | " .. distance .. " studs"
          esp.Info.Position = Vector2.new(vector.X, vector.Y - height / 2 - 15)
          esp.Info.Visible = true
        else
          esp.Box.Visible = false
          esp.Info.Visible = false
        end
      end
    else
      esp.Box.Visible = false
      esp.Info.Visible = false
    end
  end
end

local function toggleESP()
  if not Config.NoticeShown then
    game.StarterGui:SetCore("SendNotification", {
      Title = "Notice Required",
      Text = "Please accept the notice first!",
      Duration = 2
    })
    return
  end
  
  Config.ESPEnabled = not Config.ESPEnabled
  
  if Config.ESPEnabled then
    -- Create ESP for all valid players
    for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
        createESP(player)
      end
    end
  else
    -- Hide all ESP
    for _, esp in pairs(Config.ESPBoxes) do
      for _, drawing in pairs(esp) do
        drawing.Visible = false
      end
    end
  end
  
  local message = Config.ESPEnabled and "ESP: ON" or "ESP: OFF"
  game.StarterGui:SetCore("SendNotification", {
    Title = "ESP",
    Text = message,
    Duration = 2
  })
end

-- Check if player is on the same team
local function isTeamMate(player)
  if not Config.TeamCheck then return false end
  return player.Team == LocalPlayer.Team and player.Team ~= nil
end

-- Check if player is valid target
local function isValidTarget(player)
  if player == LocalPlayer then return false end
  if not player.Character then return false end
  if not player.Character:FindFirstChild("Humanoid") then return false end
  if player.Character.Humanoid.Health <= 0 then return false end
  if isTeamMate(player) then return false end
  return true
end

-- Get closest player within FOV
local function getClosestPlayerInFOV()
  local closestPlayer = nil
  local shortestDistance = Config.FOV
  
  for _, player in pairs(Players:GetPlayers()) do
    if isValidTarget(player) then
      local targetPart = player.Character:FindFirstChild(Config.TargetPart)
      
      if targetPart then
        local screenPoint = Camera:WorldToScreenPoint(targetPart.Position)
        local vectorDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
        
        if vectorDistance < shortestDistance then
          closestPlayer = player
          shortestDistance = vectorDistance
        end
      end
    end
  end
  
  return closestPlayer
end

-- Update FOV circle position
if FOVCircle then
  RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
  end)
end

-- Check if locked target is valid
local function isLockedTargetValid()
  local target = Config.LockOnTarget
  if not target then return false end
  if not target.Parent then return false end
  if not isValidTarget(target) then return false end
  if not target.Character:FindFirstChild(Config.TargetPart) then return false end
  return true
end

-- Main aimbot loop
RunService.RenderStepped:Connect(function()
  -- Update ESP
  updateESP()
  
  if Config.Enabled and Config.NoticeShown then
    if Config.LockOnTarget and isLockedTargetValid() then
      local targetPart = Config.LockOnTarget.Character[Config.TargetPart]
      local targetPosition = Camera:WorldToScreenPoint(targetPart.Position)
      
      if targetPosition.Z > 0 then
        local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
        local aimPosition = Vector2.new(targetPosition.X, targetPosition.Y)
        local movement = (aimPosition - mousePosition) * Config.Sensitivity
        mousemoverel(movement.X, movement.Y)
      end
    else
      local newTarget = getClosestPlayerInFOV()
      if newTarget then
        Config.LockOnTarget = newTarget
        game.StarterGui:SetCore("SendNotification", {
          Title = "Target Locked",
          Text = "Locked onto " .. newTarget.Name,
          Duration = 1.5
        })
      end
    end
  end
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
  if gameProcessed then return end
  
  if input.KeyCode == Config.Key then
    toggleAimbot()
    Config.LockOnTarget = nil
  elseif input.KeyCode == Config.MenuKey then
    toggleMenu()
  elseif input.KeyCode == Config.ESPKey then
    toggleESP()
  end
end)

-- Player removal handling
Players.PlayerRemoving:Connect(function(player)
  if Config.LockOnTarget == player then
    Config.LockOnTarget = nil
    if Config.Enabled then
      game.StarterGui:SetCore("SendNotification", {
        Title = "Target Lost",
        Text = "Target left the game",
        Duration = 1.5
      })
    end
  end
  
  -- Remove ESP
  removeESP(player)
end)

-- Player added handling
Players.PlayerAdded:Connect(function(player)
  if Config.ESPEnabled then
    player.CharacterAdded:Connect(function()
      wait(0.5)
      createESP(player)
    end)
  end
end)

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
  if player ~= LocalPlayer then
    createESP(player)
  end
end

-- Show notice on load (only if not already accepted)
if not Config.NoticeShown then
  createNoticeGUI()
  print("Aimbot script loaded by kkavasaki__")
  print("Accept the notice to begin using the aimbot")
else
  game.StarterGui:SetCore("SendNotification", {
    Title = "Aimbot Loaded",
    Text = "C: Aimbot | X: ESP | Right Shift: Menu",
    Duration = 3
  })
  print("Aimbot script loaded by kkavasaki__")
  print("Notice already accepted - Ready to use!")
end
