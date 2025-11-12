-- UI ve Otomasyon Kısmı
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Moveable ScreenGui ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoTowerGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true         -- Moveable için aktif olmalı
MainFrame.Draggable = true      -- Taşınabilirlik

MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "Auto Tower Script"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 25
Title.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0, 0, 0, 45)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.BackgroundTransparency = 1
Status.Text = "Durum: Kapalı"
Status.TextColor3 = Color3.fromRGB(255, 200, 60)
Status.Font = Enum.Font.SourceSans
Status.TextSize = 20
Status.Parent = MainFrame

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.4, 0, 0, 35)
StartBtn.Position = UDim2.new(0.05, 0, 0.30, 0)
StartBtn.Text = "Başlat"
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextColor3 = Color3.fromRGB(30, 255, 47)
StartBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StartBtn.TextSize = 18
StartBtn.Parent = MainFrame

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.4, 0, 0, 35)
StopBtn.Position = UDim2.new(0.55, 0, 0.30, 0)
StopBtn.Text = "Durdur"
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextColor3 = Color3.fromRGB(255, 58, 58)
StopBtn.BackgroundColor3 = Color3.fromRGB(55, 40, 40)
StopBtn.TextSize = 18
StopBtn.Parent = MainFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.57, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Tween Hızı (opsiyonel):"
SpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.TextSize = 18
SpeedLabel.Parent = MainFrame

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0.4, 0, 0, 30)
SpeedBox.Position = UDim2.new(0.05, 0, 0.68, 0)
SpeedBox.Text = ""
SpeedBox.PlaceholderText = "Boş bırak = Otomatik"
SpeedBox.TextColor3 = Color3.fromRGB(0, 0, 0)
SpeedBox.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
SpeedBox.TextSize = 16
SpeedBox.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.35, 0, 0, 28)
CloseBtn.Position = UDim2.new(0.61, 0, 0.83, 0)
CloseBtn.Text = "Kapat"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
CloseBtn.TextSize = 17
CloseBtn.Parent = MainFrame

-- Otomasyon scripti fonksiyonları
local running = false
local autoThread
local lastSpeedOverride = nil

local function TweenObj(Object, Destination, SpeedOverride)
    local Distance = (Object.Position - Destination).Magnitude
    local Time = Distance / LocalPlayer.Character.Humanoid.WalkSpeed
    if SpeedOverride then
        Time = SpeedOverride
    end
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
        Object.Velocity = Vector3.zero
    until getgenv().finished
    finishConn:Disconnect()
    Object.Velocity = Vector3.new(0, 50, 0)
    task.wait(1.5)
end

local function StartAutomation()
    if running then return end
    running = true
    Status.Text = "Durum: Çalışıyor"
    Status.TextColor3 = Color3.fromRGB(20,255,120)
    local speedOverride = tonumber(SpeedBox.Text)
    lastSpeedOverride = speedOverride
    autoThread = task.spawn(function()
        while running do
            -- Oyuncu öldüğünde tekrar başlatmak için
            local function WaitForCharacter()
                repeat
                    task.wait(0.5)
                until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.Humanoid.Health > 0
            end
            WaitForCharacter()
            local RootPart = LocalPlayer.Character.HumanoidRootPart

            -- Humanoid ölü ise bekle
            if LocalPlayer.Character.Humanoid.Health <= 0 then
                repeat
                    task.wait(0.2)
                until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0
            end

            local success, err = pcall(function()
                local Tower = workspace:WaitForChild("tower")
                local Sections = Tower.sections
                for _,v in pairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanTouch = false
                    end
                end
                for _,Section in pairs(Sections:GetChildren()) do
                    -- Ölüm kontrolü
                    if not running or LocalPlayer.Character.Humanoid.Health <= 0 then break end
                    if Section:FindFirstChild("start") then
                        TweenObj(RootPart, Section.start.Position + Vector3.new(0, 3.1, 0), speedOverride)
                    end
                    if Section.Name == "finish" then
                        for _,v in pairs(LocalPlayer.Character:GetChildren()) do
                            if v:IsA("BasePart") then
                                v.CanTouch = true
                            end
                        end
                    end
                end
                local oldPos = RootPart.Position
                if running and LocalPlayer.Character.Humanoid.Health > 0 then
                    TweenObj(RootPart, Tower.sections.finish.FinishGlow.Position - Vector3.new(0,5,0), speedOverride)
                end
                if running and LocalPlayer.Character.Humanoid.Health > 0 then
                    TweenObj(RootPart, oldPos, speedOverride)
                end
                Tower.sections.finish.FinishGlow.Destroying:Wait()
            end)
            if not success then
                warn("Otomasyon hatası: "..tostring(err))
            end
        end
        Status.Text = "Durum: Kapalı"
        Status.TextColor3 = Color3.fromRGB(255,200,60)
    end)
end

StartBtn.MouseButton1Click:Connect(StartAutomation)

StopBtn.MouseButton1Click:Connect(function()
    running = false
    Status.Text = "Durum: Kapalı"
    Status.TextColor3 = Color3.fromRGB(255,200,60)
end)

CloseBtn.MouseButton1Click:Connect(function()
    running = false
    ScreenGui:Destroy()
end)

-- Oyuncu öldüğünde otomatik yeniden başlasın
LocalPlayer.CharacterAdded:Connect(function()
    if running then
        -- Kısa bekle (yeni karakter yükleniyor)
        task.wait(2)
        if running then
            -- Eski başlattıysa tekrar başlat (speed override'ı koru)
            pcall(StartAutomation)
        end
    end
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
