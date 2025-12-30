-- kavasaki esp / aimbot / fling (companion script for pasted.txt)
-- made by kkavasaki__ inspired by infinite yield
-- Place this script AFTER Infinite Yield (pasted.txt) is loaded, or run it separately.
-- Provides keybind-driven toggles and a right-shift quick menu to adjust aim range.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Create a ScreenGui parent safely (uses get_hidden_gui / gethui / syn.protect_gui fallback)
local function createScreenGui()
	local COREGUI = game:GetService("CoreGui")
	if get_hidden_gui or gethui then
		local hiddenUI = get_hidden_gui or gethui
		local Main = Instance.new("ScreenGui")
		Main.Name = "KavasakiGUI_" .. tostring(math.random(1000,9999))
		Main.Parent = hiddenUI()
		return Main
	elseif syn and syn.protect_gui then
		local Main = Instance.new("ScreenGui")
		Main.Name = "KavasakiGUI_" .. tostring(math.random(1000,9999))
		syn.protect_gui(Main)
		Main.Parent = COREGUI
		return Main
	else
		local Main = Instance.new("ScreenGui")
		Main.Name = "KavasakiGUI_" .. tostring(math.random(1000,9999))
		Main.Parent = LocalPlayer:WaitForChild("PlayerGui")
		return Main
	end
end

local GUI = createScreenGui()

-- Settings / state
local settings = {
	espEnabled = false,
	aimbotEnabled = false,
	aimRange = 100, -- default range in studs
	aimSmoothing = 0.25, -- smoothing factor when aimbot aims
	flareColor = Color3.fromRGB(0, 255, 128),
	keybinds = {
		toggleESP = Enum.KeyCode.E,
		toggleAimbot = Enum.KeyCode.F,
		fling = Enum.KeyCode.G,
		menu = Enum.KeyCode.RightShift,
	}
}

-- UI creation
local function makeButton(parent, text, posY)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 180, 0, 28)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(36,36,37)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Text = text
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 14
	btn.Parent = parent
	return btn
end

local menu = Instance.new("Frame")
menu.Name = "KavasakiMenu"
menu.Size = UDim2.new(0, 200, 0, 210)
menu.Position = UDim2.new(0.5, -100, 0.5, -105)
menu.AnchorPoint = Vector2.new(0.5,0.5)
menu.BackgroundColor3 = Color3.fromRGB(36,36,37)
menu.BorderSizePixel = 0
menu.Visible = false
menu.ZIndex = 50
menu.Parent = GUI

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,28)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.Text = "kavasaki esp, aimbot, fling"
title.Parent = menu

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1,0,0,18)
subtitle.Position = UDim2.new(0,0,0,28)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.SourceSans
subtitle.TextSize = 12
subtitle.TextColor3 = Color3.new(1,1,1)
subtitle.Text = "made by kkavasaki__ inspired by infinite yield"
subtitle.Parent = menu

local btnESP = makeButton(menu, "Toggle ESP (E)", 52)
local btnAimbot = makeButton(menu, "Toggle Aimbot (F)", 86)
local btnFling = makeButton(menu, "Fling Now (G)", 120)

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0, 180, 0, 20)
rangeLabel.Position = UDim2.new(0,10,0,156)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.new(1,1,1)
rangeLabel.Font = Enum.Font.SourceSans
rangeLabel.TextSize = 14
rangeLabel.Text = "Aim range: " .. tostring(settings.aimRange)
rangeLabel.Parent = menu

local btnRangeAdd = makeButton(menu, "+ Range", 178)
local btnRangeSub = makeButton(menu, "- Range", 178)
-- adjust position for the +/-: place them side-by-side
btnRangeAdd.Size = UDim2.new(0, 86, 0, 28)
btnRangeAdd.Position = UDim2.new(0,10,0,178)
btnRangeSub.Size = UDim2.new(0, 86, 0, 28)
btnRangeSub.Position = UDim2.new(0,104,0,178)
btnRangeAdd.Text = "+ Range"
btnRangeSub.Text = "- Range"

-- Visual feedback label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 52)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = menu

local function updateStatus()
	local s = ("ESP: %s  |  Aimbot: %s  |  Range: %s"):format(
		(settings.espEnabled and "ON" or "OFF"),
		(settings.aimbotEnabled and "ON" or "OFF"),
		tostring(settings.aimRange)
	)
	statusLabel.Text = s
	rangeLabel.Text = "Aim range: " .. tostring(settings.aimRange)
end
updateStatus()

-- Rebinding keys via UI (click a button to rebind)
local function requestKeyBind(button, bindName)
	button.Text = "Press a key..."
	local conn
	conn = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			settings.keybinds[bindName] = input.KeyCode
			button.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
			updateStatus()
			conn:Disconnect()
		end
	end)
end

-- optionally allow clicking the listed buttons to rebind
local rebindESP = Instance.new("TextButton")
rebindESP.Size = UDim2.new(0, 60, 0, 20)
rebindESP.Position = UDim2.new(0, 120, 0, 54)
rebindESP.BackgroundColor3 = Color3.fromRGB(46,46,47)
rebindESP.TextColor3 = Color3.new(1,1,1)
rebindESP.Font = Enum.Font.SourceSans
rebindESP.TextSize = 11
rebindESP.Text = tostring(settings.keybinds.toggleESP):gsub("Enum.KeyCode.", "")
rebindESP.Parent = menu

local rebindAim = rebindESP:Clone()
rebindAim.Position = UDim2.new(0, 120, 0, 88)
rebindAim.Text = tostring(settings.keybinds.toggleAimbot):gsub("Enum.KeyCode.", "")
rebindAim.Parent = menu

local rebindFling = rebindESP:Clone()
rebindFling.Position = UDim2.new(0, 120, 0, 122)
rebindFling.Text = tostring(settings.keybinds.fling):gsub("Enum.KeyCode.", "")
rebindFling.Parent = menu

rebindESP.MouseButton1Click:Connect(function() requestKeyBind(rebindESP, "toggleESP") end)
rebindAim.MouseButton1Click:Connect(function() requestKeyBind(rebindAim, "toggleAimbot") end)
rebindFling.MouseButton1Click:Connect(function() requestKeyBind(rebindFling, "fling") end)

-- Button actions
btnESP.MouseButton1Click:Connect(function()
	settings.espEnabled = not settings.espEnabled
	updateStatus()
end)

btnAimbot.MouseButton1Click:Connect(function()
	settings.aimbotEnabled = not settings.aimbotEnabled
	updateStatus()
end)

btnFling.MouseButton1Click:Connect(function()
	-- fling nearest player once
	local function doFling()
		local target, dist = nil, math.huge
		local lpPos = LocalPlayer.Character and (LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position) or (Camera and Camera.CFrame.p)
		if not lpPos then return end
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = plr.Character.HumanoidRootPart
				local d = (hrp.Position - lpPos).magnitude
				if d < dist and d > 0 then
					dist = d
					target = plr
				end
			end
		end
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			coroutine.wrap(function()
				pcall(function()
					local hrp = target.Character.HumanoidRootPart
					-- impulse fling: set velocity briefly
					hrp.Velocity = Vector3.new(0, 200, 0) + (hrp.CFrame.LookVector * 50)
					-- slight repeat for stronger effect
					task.wait(0.12)
					hrp.Velocity = hrp.Velocity + Vector3.new(0, 100, 0)
				end)
			end)()
		end
	end
	doFling()
end)

btnRangeAdd.MouseButton1Click:Connect(function()
	settings.aimRange = settings.aimRange + 25
	updateStatus()
end)
btnRangeSub.MouseButton1Click:Connect(function()
	settings.aimRange = math.max(10, settings.aimRange - 25)
	updateStatus()
end)

-- ESP implementation (simple BoxHandleAdornment per player's character parts)
local adornments = {} -- player -> {AdornmentInstances}
local function createESPForPlayer(plr)
	if not plr.Character then return end
	if adornments[plr] then
		-- already present
		return
	end
	local folder = Instance.new("Folder")
	folder.Name = "KavasakiESP_"..plr.Name
	folder.Parent = GUI

	adornments[plr] = {folder = folder, boxes = {}}
	for _, part in pairs(plr.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			local box = Instance.new("BoxHandleAdornment")
			box.Name = "kesp_"..part.Name
			box.Adornee = part
			box.Size = part.Size
			box.AlwaysOnTop = true
			box.ZIndex = 10
			box.Transparency = 0.5
			box.Color = plr.TeamColor and plr.TeamColor.Color or Color3.fromRGB(255,255,255)
			box.Parent = folder
			table.insert(adornments[plr].boxes, box)
		end
	end

	-- update on character changes
	local function onDescAdded(desc)
		if desc:IsA("BasePart") then
			local box = Instance.new("BoxHandleAdornment")
			box.Name = "kesp_"..desc.Name
			box.Adornee = desc
			box.Size = desc.Size
			box.AlwaysOnTop = true
			box.ZIndex = 10
			box.Transparency = 0.5
			box.Color = plr.TeamColor and plr.TeamColor.Color or Color3.fromRGB(255,255,255)
			box.Parent = folder
			table.insert(adornments[plr].boxes, box)
		end
	end
	adornments[plr].descConn = plr.Character.DescendantAdded:Connect(onDescAdded)

	-- cleanup on humanoid death/character removal
	adornments[plr].charRemovedConn = plr.Character.AncestryChanged:Connect(function()
		if plr.Character and plr.Character.Parent == nil then
			if adornments[plr].descConn then adornments[plr].descConn:Disconnect() end
			if adornments[plr].charRemovedConn then adornments[plr].charRemovedConn:Disconnect() end
			if folder then folder:Destroy() end
			adornments[plr] = nil
		end
	end)
end

local function removeESPForPlayer(plr)
	if adornments[plr] then
		if adornments[plr].descConn then adornments[plr].descConn:Disconnect() end
		if adornments[plr].charRemovedConn then adornments[plr].charRemovedConn:Disconnect() end
		if adornments[plr].folder then adornments[plr].folder:Destroy() end
		adornments[plr] = nil
	end
end

local function refreshAllESP()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if settings.espEnabled then
				createESPForPlayer(plr)
			else
				removeESPForPlayer(plr)
			end
		end
	end
end

Players.PlayerAdded:Connect(function(plr)
	if settings.espEnabled and plr ~= LocalPlayer then
		plr.CharacterAdded:Connect(function()
			createESPForPlayer(plr)
		end)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	removeESPForPlayer(plr)
end)

-- Aimbot: smoothly rotate camera to look at closest target's head within range
local function getClosestTarget(range)
	local best = nil
	local bestDist = range + 1
	local camPos = Camera and Camera.CFrame.Position or Vector3.new()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then
			local head = plr.Character.Head
			local d = (head.Position - camPos).magnitude
			if d <= range and d < bestDist then
				best = plr
				bestDist = d
			end
		end
	end
	return best, bestDist
end

local aiming = false
local aimConn
local function startAimbot()
	if aimConn then aimConn:Disconnect() end
	aimConn = RunService.RenderStepped:Connect(function(dt)
		if not settings.aimbotEnabled then return end
		local target = getClosestTarget(settings.aimRange)
		if target and target.Character and target.Character:FindFirstChild("Head") then
			local headPos = target.Character.Head.Position
			local camPos = Camera.CFrame.Position
			local desiredCFrame = CFrame.new(camPos, headPos)
			-- smoothing: slerp-ish via lerp on rotation using CFrame interpolation
			local current = Camera.CFrame
			local newCF = current:Lerp(desiredCFrame, math.clamp(settings.aimSmoothing * dt * 60, 0, 1))
			Camera.CFrame = newCF
		end
	end)
end

local function stopAimbot()
	if aimConn then aimConn:Disconnect() aimConn = nil end
end

-- Key handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local kc = input.KeyCode
		-- menu toggle
		if kc == settings.keybinds.menu then
			menu.Visible = not menu.Visible
		end

		-- toggle ESP
		if kc == settings.keybinds.toggleESP then
			settings.espEnabled = not settings.espEnabled
			refreshAllESP()
			updateStatus()
			rebindESP.Text = tostring(settings.keybinds.toggleESP):gsub("Enum.KeyCode.", "")
		end

		-- toggle aimbot
		if kc == settings.keybinds.toggleAimbot then
			settings.aimbotEnabled = not settings.aimbotEnabled
			if settings.aimbotEnabled then
				startAimbot()
			else
				stopAimbot()
			end
			updateStatus()
			rebindAim.Text = tostring(settings.keybinds.toggleAimbot):gsub("Enum.KeyCode.", "")
		end

		-- fling
		if kc == settings.keybinds.fling then
			-- if bound to fling button, also run fling
			btnFling:CaptureFocus()
			btnFling.MouseButton1Click:Connect(function() end) -- noop to ensure button exists
			btnFling.MouseButton1Click:Disconnect()
			-- Do fling
			btnFling:Click()
			rebindFling.Text = tostring(settings.keybinds.fling):gsub("Enum.KeyCode.", "")
		end
	end
end)

-- also allow hotkeys to be changed by clicking rebind buttons (done above),
-- update rebind buttons text whenever a keybind changes programmatically:
local function updateRebindDisplays()
	rebindESP.Text = tostring(settings.keybinds.toggleESP):gsub("Enum.KeyCode.", "")
	rebindAim.Text = tostring(settings.keybinds.toggleAimbot):gsub("Enum.KeyCode.", "")
	rebindFling.Text = tostring(settings.keybinds.fling):gsub("Enum.KeyCode.", "")
end

-- Observe setting changes to keep UI consistent
local function watchSettings()
	updateStatus()
	updateRebindDisplays()
end
watchSettings()

-- Initial population of ESP if enabled
refreshAllESP()

-- Cleanup helper on script destroy
local function cleanup()
	for plr,_ in pairs(adornments) do
		removeESPForPlayer(plr)
	end
	if aimConn then aimConn:Disconnect() end
	GUI:Destroy()
end

-- Expose a small API to change range from external scripts if desired:
local KavasakiAPI = {
	ToggleESP = function() settings.espEnabled = not settings.espEnabled refreshAllESP() updateStatus() end,
	SetAimRange = function(v) settings.aimRange = tonumber(v) or settings.aimRange updateStatus() end,
	IncreaseRange = function() settings.aimRange = settings.aimRange + 25 updateStatus() end,
	DecreaseRange = function() settings.aimRange = math.max(10, settings.aimRange - 25) updateStatus() end,
	ToggleAimbot = function() settings.aimbotEnabled = not settings.aimbotEnabled if settings.aimbotEnabled then startAimbot() else stopAimbot() end updateStatus() end,
	FlingNearest = function()
		btnFling:MouseButton1Click:Connect(function() end)
		btnFling:MouseButton1Click:Disconnect()
		btnFling:Click()
	end,
	Cleanup = cleanup,
	GetSettings = function() return settings end,
}
_G.KavasakiAPI = KavasakiAPI

-- Helpful notify in-game (uses a simple label fade in/out)
local function notifySimple(text, dur)
	dur = dur or 3
	local notif = Instance.new("TextLabel")
	notif.BackgroundColor3 = Color3.fromRGB(24,24,24)
	notif.BorderSizePixel = 0
	notif.TextColor3 = Color3.new(1,1,1)
	notif.Text = text
	notif.Size = UDim2.new(0, 300, 0, 30)
	notif.Position = UDim2.new(0.5, -150, 0.05, 0)
	notif.AnchorPoint = Vector2.new(0.5,0)
	notif.Parent = GUI
	notif.TextSize = 16
	notif.TextStrokeTransparency = 0.8
	task.spawn(function()
		for i = 1, 20 do
			notif.TextTransparency = 1 - i/20
			wait(0.02)
		end
		wait(dur)
		for i = 1, 20 do
			notif.TextTransparency = i/20
			wait(0.02)
		end
		notif:Destroy()
	end)
end

notifySimple("kavasaki loaded (RightShift opens menu)", 4)
updateStatus()

-- End of kavasaki companion script
-- Notes:
-- - This script intentionally does not modify the original Infinite Yield code.
-- - Run this after Infinite Yield is present to get the UI + keybind driven controls.
-- - You can change keybinds in the on-screen menu or by editing settings.keybinds in the script.
