-- Roblox Lightweight Tools UI - ULTRA LIGHT VERSION
-- Fitur: Toggle Minimize, Auto Clean Cache (REAL), Anti AFK (REAL)
-- Version: 2.2 - Ultra Optimized (No Heavy Monitor)
-- Tools by: Xcodelabs

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Buat ScreenGui utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightweightTools"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Variabel untuk state
local isMinimized = false
local isAntiAFKEnabled = false
local isAutoCleanEnabled = false
local lastCleanTime = tick()
local cleanedObjectsCount = 0
local totalCacheObjects = 0

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 290)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -145)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = 0
shadow.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- Title text
local titleText = Instance.new("TextLabel")
titleText.Name = "Title"
titleText.Size = UDim2.new(0.7, 0, 0.6, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Lightweight Tools v2.2"
titleText.TextColor3 = Color3.fromRGB(220, 220, 255)
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamSemibold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 3
titleText.Parent = titleBar

-- Subtitle - Tools by Xcodelabs
local subtitleText = Instance.new("TextLabel")
subtitleText.Name = "Subtitle"
subtitleText.Size = UDim2.new(0.7, 0, 0.4, 0)
subtitleText.Position = UDim2.new(0, 10, 0.6, 0)
subtitleText.BackgroundTransparency = 1
subtitleText.Text = "Tools by: Xcodelabs"
subtitleText.TextColor3 = Color3.fromRGB(100, 200, 255)
subtitleText.TextSize = 10
subtitleText.Font = Enum.Font.GothamMedium
subtitleText.TextXAlignment = Enum.TextXAlignment.Left
subtitleText.ZIndex = 3
subtitleText.Parent = titleBar

-- Close/minimize button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 60, 0, 25)
closeButton.Position = UDim2.new(1, -70, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
closeButton.AutoButtonColor = true
closeButton.Text = "Minimize"
closeButton.TextColor3 = Color3.fromRGB(220, 220, 255)
closeButton.TextSize = 12
closeButton.Font = Enum.Font.Gotham
closeButton.ZIndex = 3
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- Content frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 1, -55)
contentFrame.Position = UDim2.new(0, 10, 0, 45)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 2
contentFrame.Parent = mainFrame

-- Minimized version
local minimizedFrame = Instance.new("Frame")
minimizedFrame.Name = "MinimizedFrame"
minimizedFrame.Size = UDim2.new(0, 200, 0, 40)
minimizedFrame.Position = UDim2.new(1, -210, 0, 10)
minimizedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
minimizedFrame.BackgroundTransparency = 0.15
minimizedFrame.BorderSizePixel = 0
minimizedFrame.Visible = false
minimizedFrame.Active = true
minimizedFrame.Draggable = true
minimizedFrame.ZIndex = 2
minimizedFrame.Parent = screenGui

local minimizedCorner = Instance.new("UICorner")
minimizedCorner.CornerRadius = UDim.new(0, 8)
minimizedCorner.Parent = minimizedFrame

local minimizedTitle = Instance.new("TextLabel")
minimizedTitle.Name = "Title"
minimizedTitle.Size = UDim2.new(1, -40, 1, 0)
minimizedTitle.Position = UDim2.new(0, 10, 0, 0)
minimizedTitle.BackgroundTransparency = 1
minimizedTitle.Text = "Xcodelabs Tools"
minimizedTitle.TextColor3 = Color3.fromRGB(220, 220, 255)
minimizedTitle.TextSize = 13
minimizedTitle.Font = Enum.Font.GothamSemibold
minimizedTitle.TextXAlignment = Enum.TextXAlignment.Left
minimizedTitle.ZIndex = 3
minimizedTitle.Parent = minimizedFrame

local maximizeButton = Instance.new("TextButton")
maximizeButton.Name = "MaximizeButton"
maximizeButton.Size = UDim2.new(0, 25, 0, 25)
maximizeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
maximizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
maximizeButton.AutoButtonColor = true
maximizeButton.Text = "+"
maximizeButton.TextColor3 = Color3.fromRGB(220, 220, 255)
maximizeButton.TextSize = 16
maximizeButton.Font = Enum.Font.GothamBold
maximizeButton.ZIndex = 3
maximizeButton.Parent = minimizedFrame

local maximizeCorner = Instance.new("UICorner")
maximizeCorner.CornerRadius = UDim.new(0, 6)
maximizeCorner.Parent = maximizeButton

-- Fitur 1: Anti AFK
local antiAFKFrame = Instance.new("Frame")
antiAFKFrame.Name = "AntiAFKFrame"
antiAFKFrame.Size = UDim2.new(1, 0, 0, 70)
antiAFKFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
antiAFKFrame.BorderSizePixel = 0
antiAFKFrame.ZIndex = 2
antiAFKFrame.Parent = contentFrame

local antiAFKCorner = Instance.new("UICorner")
antiAFKCorner.CornerRadius = UDim.new(0, 6)
antiAFKCorner.Parent = antiAFKFrame

local antiAFKTitle = Instance.new("TextLabel")
antiAFKTitle.Name = "Title"
antiAFKTitle.Size = UDim2.new(0.6, 0, 0, 25)
antiAFKTitle.Position = UDim2.new(0, 10, 0, 5)
antiAFKTitle.BackgroundTransparency = 1
antiAFKTitle.Text = "🎮 Anti AFK"
antiAFKTitle.TextColor3 = Color3.fromRGB(220, 220, 255)
antiAFKTitle.TextSize = 14
antiAFKTitle.Font = Enum.Font.GothamSemibold
antiAFKTitle.TextXAlignment = Enum.TextXAlignment.Left
antiAFKTitle.ZIndex = 3
antiAFKTitle.Parent = antiAFKFrame

local antiAFKDesc = Instance.new("TextLabel")
antiAFKDesc.Name = "Description"
antiAFKDesc.Size = UDim2.new(1, -20, 0, 35)
antiAFKDesc.Position = UDim2.new(0, 10, 0, 30)
antiAFKDesc.BackgroundTransparency = 1
antiAFKDesc.Text = "Mencegah kick AFK otomatis"
antiAFKDesc.TextColor3 = Color3.fromRGB(180, 180, 220)
antiAFKDesc.TextSize = 11
antiAFKDesc.Font = Enum.Font.Gotham
antiAFKDesc.TextXAlignment = Enum.TextXAlignment.Left
antiAFKDesc.TextYAlignment = Enum.TextYAlignment.Top
antiAFKDesc.TextWrapped = true
antiAFKDesc.ZIndex = 3
antiAFKDesc.Parent = antiAFKFrame

local antiAFKToggle = Instance.new("TextButton")
antiAFKToggle.Name = "Toggle"
antiAFKToggle.Size = UDim2.new(0, 60, 0, 25)
antiAFKToggle.Position = UDim2.new(1, -70, 0, 5)
antiAFKToggle.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
antiAFKToggle.AutoButtonColor = true
antiAFKToggle.Text = "OFF"
antiAFKToggle.TextColor3 = Color3.fromRGB(255, 180, 180)
antiAFKToggle.TextSize = 12
antiAFKToggle.Font = Enum.Font.GothamBold
antiAFKToggle.ZIndex = 3
antiAFKToggle.Parent = antiAFKFrame

local antiAFKToggleCorner = Instance.new("UICorner")
antiAFKToggleCorner.CornerRadius = UDim.new(0, 6)
antiAFKToggleCorner.Parent = antiAFKToggle

-- Fitur 2: Auto Clean Cache
local cleanCacheFrame = Instance.new("Frame")
cleanCacheFrame.Name = "CleanCacheFrame"
cleanCacheFrame.Size = UDim2.new(1, 0, 0, 70)
cleanCacheFrame.Position = UDim2.new(0, 0, 0, 80)
cleanCacheFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
cleanCacheFrame.BorderSizePixel = 0
cleanCacheFrame.ZIndex = 2
cleanCacheFrame.Parent = contentFrame

local cleanCacheCorner = Instance.new("UICorner")
cleanCacheCorner.CornerRadius = UDim.new(0, 6)
cleanCacheCorner.Parent = cleanCacheFrame

local cleanCacheTitle = Instance.new("TextLabel")
cleanCacheTitle.Name = "Title"
cleanCacheTitle.Size = UDim2.new(0.6, 0, 0, 25)
cleanCacheTitle.Position = UDim2.new(0, 10, 0, 5)
cleanCacheTitle.BackgroundTransparency = 1
cleanCacheTitle.Text = "🗑️ Auto Clean"
cleanCacheTitle.TextColor3 = Color3.fromRGB(220, 220, 255)
cleanCacheTitle.TextSize = 14
cleanCacheTitle.Font = Enum.Font.GothamSemibold
cleanCacheTitle.TextXAlignment = Enum.TextXAlignment.Left
cleanCacheTitle.ZIndex = 3
cleanCacheTitle.Parent = cleanCacheFrame

local cleanCacheDesc = Instance.new("TextLabel")
cleanCacheDesc.Name = "Description"
cleanCacheDesc.Size = UDim2.new(1, -20, 0, 35)
cleanCacheDesc.Position = UDim2.new(0, 10, 0, 30)
cleanCacheDesc.BackgroundTransparency = 1
cleanCacheDesc.Text = "Bersihkan cache otomatis setiap 5 menit"
cleanCacheDesc.TextColor3 = Color3.fromRGB(180, 180, 220)
cleanCacheDesc.TextSize = 11
cleanCacheDesc.Font = Enum.Font.Gotham
cleanCacheDesc.TextXAlignment = Enum.TextXAlignment.Left
cleanCacheDesc.TextYAlignment = Enum.TextYAlignment.Top
cleanCacheDesc.TextWrapped = true
cleanCacheDesc.ZIndex = 3
cleanCacheDesc.Parent = cleanCacheFrame

local cleanCacheToggle = Instance.new("TextButton")
cleanCacheToggle.Name = "Toggle"
cleanCacheToggle.Size = UDim2.new(0, 60, 0, 25)
cleanCacheToggle.Position = UDim2.new(1, -70, 0, 5)
cleanCacheToggle.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
cleanCacheToggle.AutoButtonColor = true
cleanCacheToggle.Text = "OFF"
cleanCacheToggle.TextColor3 = Color3.fromRGB(255, 180, 180)
cleanCacheToggle.TextSize = 12
cleanCacheToggle.Font = Enum.Font.GothamBold
cleanCacheToggle.ZIndex = 3
cleanCacheToggle.Parent = cleanCacheFrame

local cleanCacheToggleCorner = Instance.new("UICorner")
cleanCacheToggleCorner.CornerRadius = UDim.new(0, 6)
cleanCacheToggleCorner.Parent = cleanCacheToggle

-- Fitur 3: Cache Monitor (SIMPLE)
local cacheMonitorFrame = Instance.new("Frame")
cacheMonitorFrame.Name = "CacheMonitorFrame"
cacheMonitorFrame.Size = UDim2.new(1, 0, 0, 55)
cacheMonitorFrame.Position = UDim2.new(0, 0, 0, 160)
cacheMonitorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
cacheMonitorFrame.BorderSizePixel = 0
cacheMonitorFrame.ZIndex = 2
cacheMonitorFrame.Parent = contentFrame

local cacheMonitorCorner = Instance.new("UICorner")
cacheMonitorCorner.CornerRadius = UDim.new(0, 6)
cacheMonitorCorner.Parent = cacheMonitorFrame

local cacheMonitorTitle = Instance.new("TextLabel")
cacheMonitorTitle.Name = "Title"
cacheMonitorTitle.Size = UDim2.new(1, -20, 0, 20)
cacheMonitorTitle.Position = UDim2.new(0, 10, 0, 5)
cacheMonitorTitle.BackgroundTransparency = 1
cacheMonitorTitle.Text = "📊 Cache Monitor"
cacheMonitorTitle.TextColor3 = Color3.fromRGB(220, 220, 255)
cacheMonitorTitle.TextSize = 13
cacheMonitorTitle.Font = Enum.Font.GothamSemibold
cacheMonitorTitle.TextXAlignment = Enum.TextXAlignment.Left
cacheMonitorTitle.ZIndex = 3
cacheMonitorTitle.Parent = cacheMonitorFrame

local cacheCountLabel = Instance.new("TextLabel")
cacheCountLabel.Name = "CacheCount"
cacheCountLabel.Size = UDim2.new(1, -20, 0, 25)
cacheCountLabel.Position = UDim2.new(0, 10, 0, 27)
cacheCountLabel.BackgroundTransparency = 1
cacheCountLabel.Text = "Cache Objects: --"
cacheCountLabel.TextColor3 = Color3.fromRGB(150, 220, 150)
cacheCountLabel.TextSize = 12
cacheCountLabel.Font = Enum.Font.GothamMedium
cacheCountLabel.TextXAlignment = Enum.TextXAlignment.Left
cacheCountLabel.ZIndex = 3
cacheCountLabel.Parent = cacheMonitorFrame

-- ==========================
-- FUNGSI CACHE MONITOR (ULTRA SIMPLE - Update setiap 5 detik)
-- ==========================
local lastCacheUpdate = tick()

local function updateCacheCount()
	local count = 0
	
	-- Hitung hanya objek yang akan dibersihkan (SIMPLE & FAST)
	pcall(function()
		local checked = 0
		for _, obj in pairs(Workspace:GetDescendants()) do
			checked = checked + 1
			if checked > 300 then break end -- Hard limit untuk performa
			
			if (obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("ParticleEmitter")) and not obj.Enabled then
				count = count + 1
			elseif obj:IsA("Sound") and not obj.IsPlaying and not obj.Looped then
				count = count + 1
			end
		end
	end)
	
	totalCacheObjects = count
	
	-- Update display dengan warna
	cacheCountLabel.Text = string.format("Cache Objects: %d items", count)
	
	if count < 30 then
		cacheCountLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Hijau
	elseif count < 80 then
		cacheCountLabel.TextColor3 = Color3.fromRGB(255, 200, 100) -- Kuning
	else
		cacheCountLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Merah
	end
end

-- ==========================
-- FUNGSI ANTI AFK (EFFICIENT)
-- ==========================
local lastAFKAction = tick()

local function performAntiAFK()
	if not isAntiAFKEnabled then return end
	
	local currentTime = tick()
	if currentTime - lastAFKAction >= 20 then
		lastAFKAction = currentTime
		
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end

-- Hook Idled event (paling penting untuk anti AFK)
player.Idled:Connect(function()
	if isAntiAFKEnabled then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)

-- ==========================
-- FUNGSI AUTO CLEAN CACHE
-- ==========================
local function cleanCache()
	if not isAutoCleanEnabled then return end
	
	lastCleanTime = tick()
	cleanedObjectsCount = 0
	
	pcall(function()
		local maxClean = 80
		
		for _, obj in pairs(Workspace:GetDescendants()) do
			if cleanedObjectsCount >= maxClean then break end
			
			if (obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("ParticleEmitter")) and not obj.Enabled then
				obj:Destroy()
				cleanedObjectsCount = cleanedObjectsCount + 1
			elseif obj:IsA("Sound") and not obj.IsPlaying and not obj.Looped then
				obj:Destroy()
				cleanedObjectsCount = cleanedObjectsCount + 1
			end
		end
		
		collectgarbage("collect")
	end)
	
	-- Update cache count setelah clean
	updateCacheCount()
end

-- ==========================
-- TOGGLE FUNCTIONS
-- ==========================
local function toggleMinimize()
	isMinimized = not isMinimized
	mainFrame.Visible = not isMinimized
	minimizedFrame.Visible = isMinimized
end

local function toggleAntiAFK()
	isAntiAFKEnabled = not isAntiAFKEnabled
	
	if isAntiAFKEnabled then
		antiAFKToggle.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
		antiAFKToggle.Text = "ON"
		antiAFKToggle.TextColor3 = Color3.fromRGB(180, 255, 180)
		antiAFKDesc.Text = "Status: ACTIVE ✓"
	else
		antiAFKToggle.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
		antiAFKToggle.Text = "OFF"
		antiAFKToggle.TextColor3 = Color3.fromRGB(255, 180, 180)
		antiAFKDesc.Text = "Mencegah kick AFK otomatis"
	end
end

local function toggleAutoClean()
	isAutoCleanEnabled = not isAutoCleanEnabled
	
	if isAutoCleanEnabled then
		cleanCacheToggle.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
		cleanCacheToggle.Text = "ON"
		cleanCacheToggle.TextColor3 = Color3.fromRGB(180, 255, 180)
		cleanCacheDesc.Text = "Status: ACTIVE ✓"
		cleanCache() -- Clean langsung
	else
		cleanCacheToggle.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
		cleanCacheToggle.Text = "OFF"
		cleanCacheToggle.TextColor3 = Color3.fromRGB(255, 180, 180)
		cleanCacheDesc.Text = "Bersihkan cache otomatis setiap 5 menit"
	end
end

-- ==========================
-- UPDATE LOOP (MINIMAL)
-- ==========================
local updateCounter = 0

local function mainUpdate()
	updateCounter = updateCounter + 1
	local currentTime = tick()
	
	-- Anti AFK check
	performAntiAFK()
	
	-- Update cache count setiap 5 detik (bukan setiap frame!)
	if currentTime - lastCacheUpdate >= 5 then
		updateCacheCount()
		lastCacheUpdate = currentTime
	end
	
	-- Auto clean setiap 5 menit
	if isAutoCleanEnabled and currentTime - lastCleanTime >= 300 then
		cleanCache()
	end
end

-- ==========================
-- CONNECTIONS
-- ==========================
closeButton.MouseButton1Click:Connect(toggleMinimize)
maximizeButton.MouseButton1Click:Connect(toggleMinimize)
antiAFKToggle.MouseButton1Click:Connect(toggleAntiAFK)
cleanCacheToggle.MouseButton1Click:Connect(toggleAutoClean)

-- Update character saat respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
end)

-- Main update loop (MINIMAL)
RunService.Heartbeat:Connect(mainUpdate)

-- Initial cache count
spawn(function()
	wait(2)
	updateCacheCount()
end)

-- Notifications
print("=================================")
print("Lightweight Tools v2.2 Ultra Light")
print("Tools by: Xcodelabs")
print("No FPS/Memory Monitor = Max Performance!")
print("=================================")

game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "Xcodelabs Tools v2.2";
	Text = "Ultra Light - Ready!";
	Duration = 3;
})
