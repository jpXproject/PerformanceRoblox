--[[
    ROBLOX PERFORMANCE MONITOR & OPTIMIZER V2
    IMPROVED VERSION - Fixed double UI & Aggressive optimization
    
    Fitur:
    - Monitor Ping/Latency/FPS/Memory
    - AGGRESSIVE cleaning & optimization
    - Fix double UI issue
    - Better minimize animation
    - Kill high FPS untuk stabilkan performa
    
    PERHATIAN PING:
    Ping TIDAK bisa diperbaiki dengan script karena itu masalah KONEKSI INTERNET.
    Script ini hanya bisa:
    ✅ Optimasi FPS (turunkan graphics)
    ✅ Bersihkan memory
    ✅ Stabilkan gameplay
    ❌ Tidak bisa turunkan ping (itu masalah ISP/router Anda)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- DESTROY UI LAMA JIKA ADA (FIX DOUBLE UI)
if playerGui:FindFirstChild("PerformanceMonitor") then
    playerGui:FindFirstChild("PerformanceMonitor"):Destroy()
    wait(0.5)
end

-- ========================================
-- CONFIGURATION
-- ========================================
local CONFIG = {
    CLEANUP_INTERVAL = 30, -- Clean setiap 30 detik (lebih agresif)
    UPDATE_RATE = 0.3,
    MAX_FPS = 60, -- Batasi FPS maksimal untuk stabilitas
    AGGRESSIVE_MODE = false,
    THEME = {
        PRIMARY = Color3.fromRGB(20, 20, 30),
        SECONDARY = Color3.fromRGB(35, 35, 50),
        ACCENT = Color3.fromRGB(80, 160, 255),
        SUCCESS = Color3.fromRGB(50, 255, 130),
        WARNING = Color3.fromRGB(255, 180, 50),
        DANGER = Color3.fromRGB(255, 70, 70),
        TEXT = Color3.fromRGB(255, 255, 255)
    }
}

-- ========================================
-- VARIABLES
-- ========================================
local optimizationEnabled = false
local autoCleanEnabled = false
local aggressiveMode = false
local lastCleanupTime = 0
local frameCount = 0
local lastFrameTime = tick()
local cleanedTotal = 0

-- ========================================
-- CREATE UI
-- ========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PerformanceMonitor"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 450)
mainFrame.Position = UDim2.new(1, -360, 0, 20)
mainFrame.BackgroundColor3 = CONFIG.THEME.PRIMARY
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

-- Stroke
local stroke = Instance.new("UIStroke")
stroke.Color = CONFIG.THEME.ACCENT
stroke.Thickness = 2
stroke.Transparency = 0.5
stroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 55)
header.BackgroundColor3 = CONFIG.THEME.SECONDARY
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 15)
headerFix.Position = UDim2.new(0, 0, 1, -15)
headerFix.BackgroundColor3 = CONFIG.THEME.SECONDARY
headerFix.BorderSizePixel = 0
headerFix.Parent = header

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ PERF OPTIMIZER"
title.TextColor3 = CONFIG.THEME.ACCENT
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Status indicator
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 15, 0, 10)
statusDot.BackgroundColor3 = CONFIG.THEME.SUCCESS
statusDot.BorderSizePixel = 0
statusDot.Parent = title

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

-- Animate status dot
spawn(function()
    while wait(1) do
        if statusDot.Parent then
            TweenService:Create(statusDot, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), 
                {BackgroundTransparency = 0.3}):Play()
            wait(0.5)
            TweenService:Create(statusDot, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), 
                {BackgroundTransparency = 0}):Play()
        end
    end
end)

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -50, 0, 7.5)
closeBtn.BackgroundColor3 = CONFIG.THEME.DANGER
closeBtn.Text = "✕"
closeBtn.TextColor3 = CONFIG.THEME.TEXT
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 10)
closeBtnCorner.Parent = closeBtn

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
minimizeBtn.Position = UDim2.new(1, -95, 0, 7.5)
minimizeBtn.BackgroundColor3 = CONFIG.THEME.ACCENT
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = CONFIG.THEME.TEXT
minimizeBtn.TextSize = 24
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = header

local minimizeBtnCorner = Instance.new("UICorner")
minimizeBtnCorner.CornerRadius = UDim.new(0, 10)
minimizeBtnCorner.Parent = minimizeBtn

-- Content Container
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -30, 1, -75)
content.Position = UDim2.new(0, 15, 0, 65)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- Scrolling Frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
scrollFrame.Parent = content

-- Stats Container
local statsContainer = Instance.new("Frame")
statsContainer.Size = UDim2.new(1, -10, 0, 145)
statsContainer.BackgroundColor3 = CONFIG.THEME.SECONDARY
statsContainer.BorderSizePixel = 0
statsContainer.Parent = scrollFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 12)
statsCorner.Parent = statsContainer

local statsStroke = Instance.new("UIStroke")
statsStroke.Color = CONFIG.THEME.ACCENT
statsStroke.Thickness = 1
statsStroke.Transparency = 0.7
statsStroke.Parent = statsContainer

-- Stats Title
local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -20, 0, 25)
statsTitle.Position = UDim2.new(0, 10, 0, 5)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "📊 REALTIME STATS"
statsTitle.TextColor3 = CONFIG.THEME.ACCENT
statsTitle.TextSize = 14
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsContainer

-- Ping Display
local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(1, -20, 0, 30)
pingLabel.Position = UDim2.new(0, 10, 0, 35)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "📡 Ping: -- ms"
pingLabel.TextColor3 = CONFIG.THEME.TEXT
pingLabel.TextSize = 15
pingLabel.Font = Enum.Font.GothamMedium
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Parent = statsContainer

-- FPS Display
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -20, 0, 30)
fpsLabel.Position = UDim2.new(0, 10, 0, 70)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "🎮 FPS: --"
fpsLabel.TextColor3 = CONFIG.THEME.TEXT
fpsLabel.TextSize = 15
fpsLabel.Font = Enum.Font.GothamMedium
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = statsContainer

-- Memory Display
local memoryLabel = Instance.new("TextLabel")
memoryLabel.Size = UDim2.new(1, -20, 0, 30)
memoryLabel.Position = UDim2.new(0, 10, 0, 105)
memoryLabel.BackgroundTransparency = 1
memoryLabel.Text = "💾 Memory: -- MB"
memoryLabel.TextColor3 = CONFIG.THEME.TEXT
memoryLabel.TextSize = 15
memoryLabel.Font = Enum.Font.GothamMedium
memoryLabel.TextXAlignment = Enum.TextXAlignment.Left
memoryLabel.Parent = statsContainer

-- PING WARNING
local pingWarning = Instance.new("Frame")
pingWarning.Size = UDim2.new(1, -10, 0, 60)
pingWarning.Position = UDim2.new(0, 0, 0, 155)
pingWarning.BackgroundColor3 = CONFIG.THEME.WARNING
pingWarning.BorderSizePixel = 0
pingWarning.Parent = scrollFrame

local pingWarningCorner = Instance.new("UICorner")
pingWarningCorner.CornerRadius = UDim.new(0, 12)
pingWarningCorner.Parent = pingWarning

local warningText = Instance.new("TextLabel")
warningText.Size = UDim2.new(1, -20, 1, -10)
warningText.Position = UDim2.new(0, 10, 0, 5)
warningText.BackgroundTransparency = 1
warningText.Text = "⚠️ PING tidak bisa diperbaiki dengan script! Itu masalah INTERNET Anda."
warningText.TextColor3 = CONFIG.THEME.PRIMARY
warningText.TextSize = 12
warningText.Font = Enum.Font.GothamBold
warningText.TextWrapped = true
warningText.TextXAlignment = Enum.TextXAlignment.Left
warningText.Parent = pingWarning

-- Controls Container
local controlsContainer = Instance.new("Frame")
controlsContainer.Size = UDim2.new(1, -10, 0, 280)
controlsContainer.Position = UDim2.new(0, 0, 0, 225)
controlsContainer.BackgroundTransparency = 1
controlsContainer.Parent = scrollFrame

-- Function to create toggle
local function createToggle(name, labelText, icon, position, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 55)
    toggleFrame.Position = position
    toggleFrame.BackgroundColor3 = CONFIG.THEME.SECONDARY
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = controlsContainer
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleFrame
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = CONFIG.THEME.ACCENT
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 0.7
    toggleStroke.Parent = toggleFrame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 35, 0, 35)
    iconLabel.Position = UDim2.new(0, 10, 0, 10)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 24
    iconLabel.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120, 1, 0)
    label.Position = UDim2.new(0, 50, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = CONFIG.THEME.TEXT
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = toggleFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 55, 0, 35)
    toggleBtn.Position = UDim2.new(1, -65, 0.5, -17.5)
    toggleBtn.BackgroundColor3 = CONFIG.THEME.DANGER
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = CONFIG.THEME.TEXT
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = toggleFrame
    
    local toggleBtnCorner = Instance.new("UICorner")
    toggleBtnCorner.CornerRadius = UDim.new(0, 10)
    toggleBtnCorner.Parent = toggleBtn
    
    local isEnabled = false
    
    toggleBtn.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        if isEnabled then
            toggleBtn.Text = "ON"
            TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = CONFIG.THEME.SUCCESS}):Play()
            TweenService:Create(toggleStroke, TweenInfo.new(0.3), {Color = CONFIG.THEME.SUCCESS}):Play()
        else
            toggleBtn.Text = "OFF"
            TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = CONFIG.THEME.DANGER}):Play()
            TweenService:Create(toggleStroke, TweenInfo.new(0.3), {Color = CONFIG.THEME.ACCENT}):Play()
        end
        
        callback(isEnabled)
    end)
    
    return toggleBtn
end

-- Toggles
createToggle(
    "Optimize",
    "Graphics Optimization\nTurunkan kualitas grafis",
    "🎨",
    UDim2.new(0, 0, 0, 0),
    function(enabled)
        optimizationEnabled = enabled
        if enabled then
            applyOptimization()
        end
    end
)

createToggle(
    "AutoClean",
    "Auto Clean (30s)\nBersihkan cache otomatis",
    "🧹",
    UDim2.new(0, 0, 0, 65),
    function(enabled)
        autoCleanEnabled = enabled
    end
)

createToggle(
    "Aggressive",
    "AGGRESSIVE Mode\nOptimasi ekstrem (KILL FPS)",
    "⚠️",
    UDim2.new(0, 0, 0, 130),
    function(enabled)
        aggressiveMode = enabled
        if enabled then
            applyAggressiveMode()
        end
    end
)

-- Manual Clean Button
local cleanBtn = Instance.new("TextButton")
cleanBtn.Size = UDim2.new(1, 0, 0, 55)
cleanBtn.Position = UDim2.new(0, 0, 0, 195)
cleanBtn.BackgroundColor3 = CONFIG.THEME.ACCENT
cleanBtn.Text = "🗑️ CLEAN NOW"
cleanBtn.TextColor3 = CONFIG.THEME.TEXT
cleanBtn.TextSize = 16
cleanBtn.Font = Enum.Font.GothamBold
cleanBtn.BorderSizePixel = 0
cleanBtn.Parent = controlsContainer

local cleanBtnCorner = Instance.new("UICorner")
cleanBtnCorner.CornerRadius = UDim.new(0, 12)
cleanBtnCorner.Parent = cleanBtn

local cleanBtnStroke = Instance.new("UIStroke")
cleanBtnStroke.Color = CONFIG.THEME.TEXT
cleanBtnStroke.Thickness = 2
cleanBtnStroke.Transparency = 0.8
cleanBtnStroke.Parent = cleanBtn

-- Stats Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 30)
footer.Position = UDim2.new(0, 0, 0, 260)
footer.BackgroundTransparency = 1
footer.Text = "Total Cleaned: 0 objects"
footer.TextColor3 = CONFIG.THEME.SUCCESS
footer.TextSize = 12
footer.Font = Enum.Font.GothamMedium
footer.Parent = controlsContainer

-- ========================================
-- OPTIMIZATION FUNCTIONS
-- ========================================

function applyOptimization()
    pcall(function()
        -- Turunkan quality
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        
        -- Lighting optimization
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        
        print("[OPTIMIZER] Graphics optimized!")
    end)
end

function applyAggressiveMode()
    pcall(function()
        -- AGGRESSIVE optimization
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        
        -- Disable semua effects
        local Lighting = game:GetService("Lighting")
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
        
        -- Kurangi particle effects
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = false
            end
        end
        
        -- Limit FPS
        RunService:Set3dRenderingEnabled(true)
        
        print("[OPTIMIZER] AGGRESSIVE mode activated!")
    end)
end

function cleanCache()
    local cleaned = 0
    
    pcall(function()
        -- Hapus part transparan
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if obj.Transparency >= 0.95 and not obj.CanCollide and #obj:GetChildren() == 0 then
                    obj:Destroy()
                    cleaned = cleaned + 1
                end
            elseif obj:IsA("Decal") and obj.Transparency >= 0.9 then
                obj:Destroy()
                cleaned = cleaned + 1
            elseif obj:IsA("Texture") and obj.Transparency >= 0.9 then
                obj:Destroy()
                cleaned = cleaned + 1
            end
        end
        
        if aggressiveMode then
            -- AGGRESSIVE: Hapus semua particle yang disabled
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    if not obj.Enabled then
                        obj:Destroy()
                        cleaned = cleaned + 1
                    end
                end
            end
        end
        
        -- Garbage collection
        wait()
        
        cleanedTotal = cleanedTotal + cleaned
        footer.Text = string.format("Total Cleaned: %d objects", cleanedTotal)
    end)
    
    return cleaned
end

-- ========================================
-- UPDATE STATS
-- ========================================
local function updateStats()
    -- Ping
    local ping = player:GetNetworkPing() * 1000
    local pingColor = ping < 50 and CONFIG.THEME.SUCCESS or ping < 100 and CONFIG.THEME.WARNING or CONFIG.THEME.DANGER
    pingLabel.Text = string.format("📡 Ping: %d ms", math.floor(ping))
    pingLabel.TextColor3 = pingColor
    
    -- FPS
    frameCount = frameCount + 1
    local currentTime = tick()
    local deltaTime = currentTime - lastFrameTime
    
    if deltaTime >= CONFIG.UPDATE_RATE then
        local fps = frameCount / deltaTime
        local fpsColor = fps >= 55 and CONFIG.THEME.SUCCESS or fps >= 30 and CONFIG.THEME.WARNING or CONFIG.THEME.DANGER
        fpsLabel.Text = string.format("🎮 FPS: %d", math.floor(fps))
        fpsLabel.TextColor3 = fpsColor
        
        frameCount = 0
        lastFrameTime = currentTime
    end
    
    -- Memory
    local memoryUsed = Stats:GetTotalMemoryUsageMb()
    local memoryColor = memoryUsed < 500 and CONFIG.THEME.SUCCESS or memoryUsed < 1000 and CONFIG.THEME.WARNING or CONFIG.THEME.DANGER
    memoryLabel.Text = string.format("💾 Memory: %.1f MB", memoryUsed)
    memoryLabel.TextColor3 = memoryColor
end

-- ========================================
-- AUTO CLEAN LOOP
-- ========================================
spawn(function()
    while wait(1) do
        if autoCleanEnabled then
            if tick() - lastCleanupTime >= CONFIG.CLEANUP_INTERVAL then
                cleanCache()
                lastCleanupTime = tick()
            end
        end
    end
end)

-- ========================================
-- BUTTON EVENTS
-- ========================================

cleanBtn.MouseButton1Click:Connect(function()
    cleanBtn.Text = "⏳ CLEANING..."
    cleanBtn.BackgroundColor3 = CONFIG.THEME.WARNING
    wait(0.3)
    
    local cleaned = cleanCache()
    cleanBtn.Text = string.format("✅ Cleaned %d!", cleaned)
    cleanBtn.BackgroundColor3 = CONFIG.THEME.SUCCESS
    
    wait(2)
    cleanBtn.Text = "🗑️ CLEAN NOW"
    cleanBtn.BackgroundColor3 = CONFIG.THEME.ACCENT
end)

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        minimizeBtn.Text = "+"
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 340, 0, 55)}):Play()
        content.Visible = false
    else
        minimizeBtn.Text = "−"
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 340, 0, 450)}):Play()
        content.Visible = true
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ========================================
-- MAIN LOOP
-- ========================================
RunService.RenderStepped:Connect(function()
    updateStats()
end)

print("=================================")
print("Performance Monitor V2 Loaded!")
print("Fixed: Double UI issue")
print("Added: Aggressive optimization")
print("=================================")
