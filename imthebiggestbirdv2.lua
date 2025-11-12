--[[
    Made by kavasaki
    Roblox Tower Autofarm UI + Mod Ayarları
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Moveable ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoTowerGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 260)
MainFrame.Position = UDim2.new(0.045, 0, 0.32, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundTransparency = 1
Title.Text = "⭕ Kavasaki Tower Autofarm"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 21
Title.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0, 0, 0, 37)
Status.Size = UDim2.new(1, 0, 0, 23)
Status.BackgroundTransparency = 1
Status.Text = "Durum: Kapalı"
Status.TextColor3 = Color3.fromRGB(255, 200, 60)
Status.Font = Enum.Font.Gotham
Status.TextSize = 17
Status.Parent = MainFrame

local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UDim2.new(0.96, 0, 0, 21)
ModeLabel.Position = UDim2.new(0.02, 0, 0.19, 0)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Text = "Farm Modu:"
ModeLabel.TextColor3 = Color3.fromRGB(200,220,255)
ModeLabel.Font = Enum.Font.GothamBold
ModeLabel.TextSize = 16
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Parent = MainFrame

local TweenModeBtn = Instance.new("TextButton")
TweenModeBtn.Size = UDim2.new(0.47, 0, 0, 31)
TweenModeBtn.Position = UDim2.new(0.02, 0, 0.29, 0)
TweenModeBtn.Text = "[Tween] UNDETECTED"
TweenModeBtn.Font = Enum.Font.GothamBold
TweenModeBtn.TextColor3 = Color3.fromRGB(70, 255, 120)
TweenModeBtn.BackgroundColor3 = Color3.fromRGB(25, 40, 35)
TweenModeBtn.TextSize = 15
TweenModeBtn.Parent = MainFrame

local TeleportModeBtn = Instance.new("TextButton")
TeleportModeBtn.Size = UDim2.new(0.47, 0, 0, 31)
TeleportModeBtn.Position = UDim2.new(0.51, 0, 0.29, 0)
TeleportModeBtn.Text = "[Teleport] DETECTED"
TeleportModeBtn.Font = Enum.Font.GothamBold
TeleportModeBtn.TextColor3 = Color3.fromRGB(255, 70, 72)
TeleportModeBtn.BackgroundColor3 = Color3.fromRGB(49, 22, 26)
TeleportModeBtn.TextSize = 15
TeleportModeBtn.Parent = MainFrame

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.43, 0, 0, 38)
StartBtn.Position = UDim2.new(0.05, 0, 0.47, 0)
StartBtn.Text = "Başlat"
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextColor3 = Color3.fromRGB(30, 255, 47)
StartBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StartBtn.TextSize = 20
StartBtn.Parent = MainFrame

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.43, 0, 0, 38)
StopBtn.Position = UDim2.new(0.52, 0, 0.47, 0)
StopBtn.Text = "Durdur"
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextColor3 = Color3.fromRGB(255, 58, 58)
StopBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
StopBtn.TextSize = 20
StopBtn.Parent = MainFrame

local Note = Instance.new("TextLabel")
Note.Size = UDim2.new(0.93, 0, 0, 40)
Note.Position = UDim2.new(0.035, 0, 0.68, 0)
Note.BackgroundTransparency = 1
Note.Text = "Her ölüm ve respawn sonrası otomatik devam eder.\nTween: UNDETECTED | Teleport: DETECTED"
Note.TextColor3 = Color3.fromRGB(128, 168, 255)
Note.Font = Enum.Font.GothamSemibold
Note.TextSize = 14
Note.TextWrapped = true
Note.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.33, 0, 0, 28)
CloseBtn.Position = UDim2.new(0.63, 0, 0.89, 0)
CloseBtn.Text = "Kapat"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 18)
Credit.Position = UDim2.new(0, 0, 1, -18)
Credit.BackgroundTransparency = 1
Credit.Text = "Made by kavasaki"
Credit.TextColor3 = Color3.fromRGB(80,255,120)
Credit.Font = Enum.Font.GothamBold
Credit.TextSize = 14
Credit.TextStrokeTransparency = 0.7
Credit.Parent = MainFrame

-- Mod seçimi
local farmMode = "Tween" -- Tween veya Teleport

TweenModeBtn.MouseButton1Click:Connect(function()
    farmMode = "Tween"
    TweenModeBtn.BackgroundColor3 = Color3.fromRGB(25, 40, 35)
    TeleportModeBtn.BackgroundColor3 = Color3.fromRGB(49, 22, 26)
    TweenModeBtn.TextColor3 = Color3.fromRGB(70, 255, 120)
    TeleportModeBtn.TextColor3 = Color3.fromRGB(255, 70, 72)
end)

TeleportModeBtn.MouseButton1Click:Connect(function()
    farmMode = "Teleport"
    TeleportModeBtn.BackgroundColor3 = Color3.fromRGB(35, 22, 26)
    TweenModeBtn.BackgroundColor3 = Color3.fromRGB(14, 30, 22)
    TeleportModeBtn.TextColor3 = Color3.fromRGB(255, 70, 72)
    TweenModeBtn.TextColor3 = Color3.fromRGB(70, 255, 120)
end)

-- Otomasyon scripti fonksiyonları
local running = false
local autoThread
local autofarm_enabled = false

local function WaitForCharacter()
    repeat
        task.wait(0.3)
    until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.Humanoid.Health > 0
end

local function TweenObj(Object, Destination)
    local Distance = (Object.Position - Destination).Magnitude
    local Time = Distance / (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.WalkSpeed or 16)
    local Tw = TweenService:Create(Object, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut,0,false,0),
        {CFrame = CFrame.new(Destination)})
    Tw:Play()
    getgenv().finished = false
    local finishConn = Tw.Completed:Connect(function()
        getgenv().finished = true
        Tw:Destroy()
    end)
    repeat
        task.wait()
        if Object then
            Object.Velocity = Vector3.zero
        end
    until getgenv().finished or (not running)
    finishConn:Disconnect()
    if Object then
        Object.Velocity = Vector3.new(0, 50, 0)
    end
    task.wait(1.2)
end

local function TeleportObj(Object, Destination)
    Object.CFrame = CFrame.new(Destination)
    task.wait(0.25)
end

local function DoAutoFarm()
    if autoThread then
        pcall(function() task.cancel(autoThread) end)
    end
    autoThread = task.spawn(function()
        while running do
            WaitForCharacter()
            local RootPart = LocalPlayer.Character.HumanoidRootPart
            if LocalPlayer.Character.Humanoid.Health <= 0 then continue end

            local Tower = workspace:FindFirstChild("tower")
            if not Tower or not Tower:FindFirstChild("sections") then
                Status.Text = "Hata: Kule bulunamadı."
                task.wait(2)
                continue
            end
            local Sections = Tower.sections

            for _,v in pairs(LocalPlayer.Character:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanTouch = false
                end
            end

            for _,Section in ipairs(Sections:GetChildren()) do
                if not running or (LocalPlayer.Character.Humanoid.Health <= 0) then break end
                if Section:FindFirstChild("start") then
                    if farmMode == "Tween" then
                        TweenObj(RootPart, Section.start.Position + Vector3.new(0, 3.1, 0))
                    else
                        TeleportObj(RootPart, Section.start.Position + Vector3.new(0, 3.1, 0))
                    end
                end
                if Section.Name == "finish" then
                    for _,v in pairs(LocalPlayer.Character:GetChildren()) do
                        if v:IsA("BasePart") then
                            v.CanTouch = true
                        end
                    end
                end
            end
            if running and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local oldPos = RootPart.Position
                if Tower.sections and Tower.sections:FindFirstChild("finish") and Tower.sections.finish:FindFirstChild("FinishGlow") then
                    if farmMode == "Tween" then
                        TweenObj(RootPart, Tower.sections.finish.FinishGlow.Position - Vector3.new(0,6,0))
                    else
                        TeleportObj(RootPart, Tower.sections.finish.FinishGlow.Position - Vector3.new(0,6,0))
                    end
                end
                if farmMode == "Tween" then
                    TweenObj(RootPart, oldPos)
                else
                    TeleportObj(RootPart, oldPos)
                end
                pcall(function()
                    Tower.sections.finish.FinishGlow.Destroying:Wait(7)
                end)
            end
        end
    end)
end

StartBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    autofarm_enabled = true
    Status.Text = "Durum: Çalışıyor"
    Status.TextColor3 = Color3.fromRGB(20,255,120)
    DoAutoFarm()
end)

StopBtn.MouseButton1Click:Connect(function()
    running = false
    autofarm_enabled = false
    Status.Text = "Durum: Kapalı"
    Status.TextColor3 = Color3.fromRGB(255,200,60)
end)

CloseBtn.MouseButton1Click:Connect(function()
    running = false
    autofarm_enabled = false
    ScreenGui:Destroy()
end)

-- Otomatik yeniden başlat (ölünce/respawn olunca)
local function onCharacter()
    if autofarm_enabled then
        running = false
        task.wait(0.8)
        running = true
        Status.Text = "Durum: Çalışıyor"
        Status.TextColor3 = Color3.fromRGB(20,255,120)
        DoAutoFarm()
    end
end

LocalPlayer.CharacterAdded:Connect(onCharacter)

if LocalPlayer.Character then
    LocalPlayer.Character:WaitForChild("Humanoid").Died:Connect(function()
        if autofarm_enabled then
            Status.Text = "Öldün, tekrar başlatılıyor..."
            Status.TextColor3 = Color3.fromRGB(255,82,100)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        if autofarm_enabled then
            Status.Text = "Öldün, tekrar başlatılıyor..."
            Status.TextColor3 = Color3.fromRGB(255,82,100)
        end
    end)
end)

-- Anti-kick, anti-afk
pcall(function()
    getsenv(LocalPlayer.PlayerScripts:WaitForChild("LocalScript")).kick = function() return end
end)

local VVU = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VVU:CaptureController()
    VVU:ClickButton2(Vector2.new())
end)
