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
  local success, result = pcall(function()
    if not isfolder then return false end
    if not isfolder(FolderName) then
      makefolder(FolderName)
    end
    if isfile(FolderName .. "/" .. FileName) then
      return true
    end
    return false
  end)
  return success and result or false
end

-- Save acceptance to file
local function saveAcceptance()
  pcall(function()
    if not writefile then return end
    if not isfolder(FolderName) then
      makefolder(FolderName)
    end
    writefile(FolderName .. "/" .. FileName, "Notice accepted by " .. LocalPlayer.Name .. " on " .. os.date("%Y-%m-%d %H:%M:%S"))
  end)
end

-- Configuration
local Config = {
  Enabled = false,
  ESPEnabled = false,
  TeamCheck = true,
  TargetPart = "Head",
  FOV = 250,
  Sensitivity = 0.5,
  ShowFOV = true,
  FOVColor = Color3.fromRGB(255, 255, 255),
  LockOnTarget = nil,
  NoticeShown = checkAcceptanceFile(),
  ESPColor = Color3.fromRGB(255, 0, 0),
  ESPBoxes = {},
  ControlsVisible = true
}

-- FOV Circle Drawing
local FOVCircle
if Config.ShowFOV and Drawing then
  pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Radius = Config.FOV
    FOVCircle.Color = Config.FOVColor
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.NumSides = 64
  end)
end

-- Create Mobile Controls GUI
local ControlsGui
local AimbotButton
local ESPButton
local MenuButton
local ToggleButton

local function createMobileControls()
  pcall(function()
    -- Remove existing controls
    local existing = LocalPlayer.PlayerGui:FindFirstChild("MobileAimbotControls")
    if existing then
      existing:Destroy()
    end
    
    ControlsGui = Instance.new("ScreenGui")
    ControlsGui.Name = "MobileAimbotControls"
    ControlsGui.ResetOnSpawn = false
    ControlsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Container Frame (Right side of screen)
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, 70, 0, 240)
    Container.Position = UDim2.new(1, -80, 0.5, -120)
    Container.BackgroundTransparency = 1
    Container.Parent = ControlsGui
    
    -- Helper function to create buttons
    local function createButton(name, text, position, color)
      local Button = Instance.new("TextButton")
      Button.Name = name
      Button.Size = UDim2.new(0, 70, 0, 70)
      Button.Position = position
      Button.BackgroundColor3 = color
      Button.Text = ""
      Button.TextColor3 = Color3.fromRGB(255, 255, 255)
      Button.TextSize = 14
      Button.Font = Enum.Font.GothamBold
      Button.Parent = Container
      
      local Corner = Instance.new("UICorner")
      Corner.CornerRadius = UDim.new(0, 12)
      Corner.Parent = Button
      
      local Label = Instance.new("TextLabel")
      Label.Size = UDim2.new(1, 0, 1, 0)
      Label.BackgroundTransparency = 1
      Label.Text = text
      Label.TextColor3 = Color3.fromRGB(255, 255, 255)
      Label.TextSize = 12
      Label.Font = Enum.Font.GothamBold
      Label.Parent = Button
      
      local Stroke = Instance.new("UIStroke")
      Stroke.Color = Color3.fromRGB(255, 255, 255)
      Stroke.Thickness = 2
      Stroke.Transparency = 0.5
      Stroke.Parent = Button
      
      return Button
    end
    
    -- Create Aimbot Button
    AimbotButton = createButton("AimbotButton", "AIMBOT\nOFF", UDim2.new(0, 0, 0, 0), Color3.fromRGB(50, 50, 60))
    
    -- Create ESP Button
    ESPButton = createButton("ESPButton", "ESP\nOFF", UDim2.new(0, 0, 0, 85), Color3.fromRGB(50, 50, 60))
    
    -- Create Menu Button
    MenuButton = createButton("MenuButton", "MENU", UDim2.new(0, 0, 0, 170), Color3.fromRGB(100, 60, 200))
    
    -- Create Toggle Visibility Button (Small)
    ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 40, 0, 40)
    ToggleButton.Position = UDim2.new(1, -50, 0, 10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
    ToggleButton.Text = "👁️"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 20
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = ControlsGui
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton
    
    ControlsGui.Parent = LocalPlayer.PlayerGui or game:GetService("CoreGui")
  end)
end

-- Update button states
local function updateButtonStates()
  pcall(function()
    if AimbotButton then
      if Config.Enabled then
        AimbotButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        AimbotButton.TextLabel.Text = "AIMBOT\nON"
      else
        AimbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        AimbotButton.TextLabel.Text = "AIMBOT\nOFF"
      end
    end
    
    if ESPButton then
      if Config.ESPEnabled then
        ESPButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        ESPButton.TextLabel.Text = "ESP\nON"
      else
        ESPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        ESPButton.TextLabel.Text = "ESP\nOFF"
      end
    end
  end)
end

-- Create Notice GUI
local function createNoticeGUI()
  local success = pcall(function()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotNotice"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 350, 0, 280)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -140)
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
    Title.Text = "⚠️ MOBILE AIMBOT"
    Title.TextColor3 = Color3.fromRGB(200, 100, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame
    
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -40, 0, 130)
    Message.Position = UDim2.new(0, 20, 0, 70)
    Message.BackgroundTransparency = 1
    Message.Text = "Mobile-friendly aimbot is ready!\n\nUse the buttons on the right:\n• AIMBOT - Toggle aimbot ON/OFF\n• ESP - Toggle ESP ON/OFF\n• MENU - Open settings menu\n• 👁️ - Hide/Show controls\n\nThis script is written by kkavasaki__"
    Message.TextColor3 = Color3.fromRGB(220, 220, 220)
    Message.TextSize = 14
    Message.Font = Enum.Font.Gotham
    Message.TextWrapped = true
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.Parent = Frame
    
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
    
    OKButton.MouseButton1Click:Connect(function()
      Config.NoticeShown = true
      saveAcceptance()
      ScreenGui:Destroy()
      createMobileControls()
      
      game.StarterGui:SetCore("SendNotification", {
        Title = "Aimbot Ready",
        Text = "Use buttons on right side of screen",
        Duration = 3
      })
    end)
    
    ScreenGui.Parent = LocalPlayer.PlayerGui or game:GetService("CoreGui")
  end)
  
  if not success then
    Config.NoticeShown = true
    createMobileControls()
  end
end

-- Create Menu GUI
local function createMenuGUI()
  pcall(function()
    local existingMenu = LocalPlayer.PlayerGui:FindFirstChild("AimbotMenu")
    if existingMenu then
      existingMenu:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 320, 0, 280)
    Frame.Position = UDim2.new(0.5, -160, 0.5, -140)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Frame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 35)
    Title.Position = UDim2.new(0, 20, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "🎯 AIMBOT MENU"
    Title.TextColor3 = Color3.fromRGB(200, 100, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame
    
    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, -40, 0, 160)
    InfoText.Position = UDim2.new(0, 20, 0, 60)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "Aimbot: " .. (Config.Enabled and "ENABLED ✓" or "DISABLED ✗") .. "\nESP: " .. (Config.ESPEnabled and "ENABLED ✓" or "DISABLED ✗") .. "\n\nControls:\n• AIMBOT button - Toggle aimbot\n• ESP button - Toggle ESP\n• MENU button - This menu\n• 👁️ button - Hide controls\n\nSettings:\n• FOV: " .. Config.FOV .. "\n• Target: " .. Config.TargetPart .. "\n• Sensitivity: " .. Config.Sensitivity
    InfoText.TextColor3 = Color3.fromRGB(220, 220, 220)
    InfoText.TextSize = 12
    InfoText.Font = Enum.Font.Gotham
    InfoText.TextWrapped = true
    InfoText.TextYAlignment = Enum.TextYAlignment.Top
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.Parent = Frame
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 120, 0, 35)
    CloseButton.Position = UDim2.new(0.5, -60, 1, -50)
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
      ScreenGui:Destroy()
    end)
    
    ScreenGui.Parent = LocalPlayer.PlayerGui or game:GetService("CoreGui")
  end)
end

-- Toggle functions
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
  
  updateButtonStates()
  
  local message = Config.Enabled and "Aimbot: ON" or "Aimbot: OFF"
  game.StarterGui:SetCore("SendNotification", {
    Title = "Aimbot",
    Text = message,
    Duration = 1.5
  })
end

-- ESP Functions
local function createESP(player)
  if not Drawing then return end
  if Config.ESPBoxes[player] then return end
  
  local success = pcall(function()
    local esp = {
      Box = Drawing.new("Square"),
      Info = Drawing.new("Text")
    }
    
    esp.Box.Visible = false
    esp.Box.Color = Config.ESPColor
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    
    esp.Info.Visible = false
    esp.Info.Color = Color3.fromRGB(255, 255, 255)
    esp.Info.Size = 13
    esp.Info.Center = true
    esp.Info.Outline = true
    esp.Info.Font = 2
    
    Config.ESPBoxes[player] = esp
  end)
  
  if not success then
    Config.ESPBoxes[player] = nil
  end
end

local function removeESP(player)
  pcall(function()
    local esp = Config.ESPBoxes[player]
    if esp then
      if esp.Box then esp.Box:Remove() end
      if esp.Info then esp.Info:Remove() end
      Config.ESPBoxes[player] = nil
    end
  end)
end

local function updateESP()
  if not Config.ESPEnabled or not Drawing then
    for _, esp in pairs(Config.ESPBoxes) do
      pcall(function()
        if esp.Box then esp.Box.Visible = false end
        if esp.Info then esp.Info.Visible = false end
      end)
    end
    return
  end
  
  for player, esp in pairs(Config.ESPBoxes) do
    pcall(function()
      if not player or not player.Parent or player == LocalPlayer then
        esp.Box.Visible = false
        esp.Info.Visible = false
        return
      end
      
      local character = player.Character
      if not character then
        esp.Box.Visible = false
        esp.Info.Visible = false
        return
      end
      
      local hrp = character:FindFirstChild("HumanoidRootPart")
      local head = character:FindFirstChild("Head")
      local humanoid = character:FindFirstChild("Humanoid")
      
      if not hrp or not head or not humanoid or humanoid.Health <= 0 then
        esp.Box.Visible = false
        esp.Info.Visible = false
        return
      end
      
      if Config.TeamCheck and player.Team == LocalPlayer.Team and player.Team ~= nil then
        esp.Box.Visible = false
        esp.Info.Visible = false
        return
      end
      
      local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
      
      if onScreen and vector.Z > 0 then
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        local height = math.abs(headPos.Y - legPos.Y)
        local width = height / 2
        
        esp.Box.Size = Vector2.new(width, height)
        esp.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
        esp.Box.Visible = true
        
        local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
        local health = math.floor(humanoid.Health)
        local maxHealth = math.floor(humanoid.MaxHealth)
        
        esp.Info.Text = player.Name .. " | " .. health .. "/" .. maxHealth .. " | " .. distance .. " studs"
        esp.Info.Position = Vector2.new(vector.X, vector.Y - height / 2 - 15)
        esp.Info.Visible = true
      else
        esp.Box.Visible = false
        esp.Info.Visible = false
      end
    end)
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
    for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
        createESP(player)
      end
    end
  else
    for _, esp in pairs(Config.ESPBoxes) do
      pcall(function()
        if esp.Box then esp.Box.Visible = false end
        if esp.Info then esp.Info.Visible = false end
      end)
    end
  end
  
  updateButtonStates()
  
  local message = Config.ESPEnabled and "ESP: ON" or "ESP: OFF"
  game.StarterGui:SetCore("SendNotification", {
    Title = "ESP",
    Text = message,
    Duration = 1.5
  })
end

-- Toggle controls visibility
local function toggleControlsVisibility()
  Config.ControlsVisible = not Config.ControlsVisible
  
  pcall(function()
    if ControlsGui and ControlsGui:FindFirstChild("Container") then
      ControlsGui.Container.Visible = Config.ControlsVisible
    end
    
    if ToggleButton then
      ToggleButton.Text = Config.ControlsVisible and "👁️" or "👁️‍🗨️"
    end
  end)
end

-- Setup button connections
task.spawn(function()
  task.wait(0.5)
  
  if AimbotButton then
    AimbotButton.MouseButton1Click:Connect(toggleAimbot)
  end
  
  if ESPButton then
    ESPButton.MouseButton1Click:Connect(toggleESP)
  end
  
  if MenuButton then
    MenuButton.MouseButton1Click:Connect(createMenuGUI)
  end
  
  if ToggleButton then
    ToggleButton.MouseButton1Click:Connect(toggleControlsVisibility)
  end
end)

-- Check if player is valid target
local function isValidTarget(player)
  if not player or player == LocalPlayer then return false end
  if not player.Character then return false end
  
  local humanoid = player.Character:FindFirstChild("Humanoid")
  if not humanoid or humanoid.Health <= 0 then return false end
  
  if Config.TeamCheck and player.Team == LocalPlayer.Team and player.Team ~= nil then
    return false
  end
  
  return true
end

-- Get closest player within FOV
local function getClosestPlayerInFOV()
  local closestPlayer = nil
  local shortestDistance = Config.FOV
  local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
  
  for _, player in pairs(Players:GetPlayers()) do
    pcall(function()
      if isValidTarget(player) then
        local targetPart = player.Character:FindFirstChild(Config.TargetPart)
        
        if targetPart then
          local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
          
          if onScreen and screenPoint.Z > 0 then
            local vectorDistance = (screenCenter - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
            
            if vectorDistance < shortestDistance then
              closestPlayer = player
              shortestDistance = vectorDistance
            end
          end
        end
      end
    end)
  end
  
  return closestPlayer
end

-- Update FOV circle position (center of screen for mobile)
if FOVCircle then
  RunService.RenderStepped:Connect(function()
    pcall(function()
      local screenCenter = Camera.ViewportSize / 2
      FOVCircle.Position = Vector2.new(screenCenter.X, screenCenter.Y)
    end)
  end)
end

-- Check if locked target is valid
local function isLockedTargetValid()
  local target = Config.LockOnTarget
  if not target or not target.Parent then return false end
  if not isValidTarget(target) then return false end
  
  local character = target.Character
  if not character then return false end
  
  local targetPart = character:FindFirstChild(Config.TargetPart)
  if not targetPart then return false end
  
  return true
end

-- Main aimbot and ESP loop
RunService.RenderStepped:Connect(function()
  updateESP()
  
  if Config.Enabled and Config.NoticeShown then
    pcall(function()
      if Config.LockOnTarget and isLockedTargetValid() then
        local targetPart = Config.LockOnTarget.Character[Config.TargetPart]
        local targetPosition, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        
        if onScreen and targetPosition.Z > 0 then
          -- For mobile, we adjust the camera instead of mouse
          local screenCenter = Camera.ViewportSize / 2
          local aimPosition = Vector2.new(targetPosition.X, targetPosition.Y)
          local offset = (aimPosition - screenCenter) * Config.Sensitivity * 0.01
          
          -- Smoothly rotate camera towards target
          Camera.CFrame = Camera.CFrame * CFrame.Angles(0, offset.X, 0) * CFrame.Angles(offset.Y, 0, 0)
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
    end)
  end
end)

-- Player removal handling
Players.PlayerRemoving:Connect(function(player)
  pcall(function()
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
    
    removeESP(player)
  end)
end)

-- Player added handling
Players.PlayerAdded:Connect(function(player)
  pcall(function()
    player.CharacterAdded:Connect(function()
      task.wait(0.5)
      if Config.ESPEnabled and player ~= LocalPlayer then
        createESP(player)
      end
    end)
  end)
end)

-- Initialize ESP for existing players
task.spawn(function()
  task.wait(1)
  for _, player in pairs(Players:GetPlayers()) do
    pcall(function()
      if player ~= LocalPlayer then
        createESP(player)
      end
    end)
  end
end)

-- Show notice on load
if not Config.NoticeShown then
  createNoticeGUI()
  print("Mobile Aimbot script loaded by kkavasaki__")
  print("Accept the notice to begin using the aimbot")
else
  createMobileControls()
  updateButtonStates()
  game.StarterGui:SetCore("SendNotification", {
    Title = "Mobile Aimbot Loaded",
    Text = "Use buttons on right side",
    Duration = 3
  })
  print("Mobile Aimbot script loaded by kkavasaki__")
  print("Notice already accepted - Ready to use!")
end
