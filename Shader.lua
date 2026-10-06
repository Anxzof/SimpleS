local lighting = game:GetService("Lighting")
local ws = game:GetService("Workspace")
local rs = game:GetService("RunService")
local lp = game:GetService("Players").LocalPlayer
local stats = game:GetService("Stats")
local pg = lp:WaitForChild("PlayerGui")

lighting.Ambient = Color3.fromRGB(180, 200, 180)
lighting.OutdoorAmbient = Color3.fromRGB(200, 215, 190)
lighting.Brightness = 1.2
lighting.ClockTime = 14

for _, child in ipairs(lighting:GetChildren()) do
    if child:IsA("PostEffect") then
        child:Destroy()
    end
end

local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.14
bloom.Threshold = 0.9
bloom.Parent = lighting

local cc = Instance.new("ColorCorrectionEffect")
cc.Brightness = -0.05
cc.Contrast = 0.3
cc.Saturation = 0.7
cc.Parent = lighting

local function applySlate(part)
    if part.Material ~= Enum.Material.Slate then
        part.Material = Enum.Material.Slate
    end
end

for _, part in ipairs(ws:GetDescendants()) do
    if part:IsA("BasePart") then
        applySlate(part)
    end
end

if _G.MaterialConn then
    _G.MaterialConn:Disconnect()
    _G.MaterialConn = nil
end

_G.MaterialConn = ws.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("BasePart") then
        applySlate(descendant)
    end
end)

local existingGui = pg:FindFirstChild("FpsCounterGui")
if existingGui then
    existingGui:Destroy()
end

if _G.FpsConn then
    _G.FpsConn:Disconnect()
    _G.FpsConn = nil
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FpsCounterGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = pg

local textLabel = Instance.new("TextLabel")
textLabel.Name = "FpsLabel"
textLabel.Size = UDim2.new(0, 90, 0, 20)
textLabel.Position = UDim2.new(0.75, -45, 0, 8)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextStrokeTransparency = 0.3
textLabel.TextSize = 11
textLabel.Font = Enum.Font.Legacy
textLabel.TextXAlignment = Enum.TextXAlignment.Center
textLabel.Parent = screenGui

local pingLabel = Instance.new("TextLabel")
pingLabel.Name = "PingLabel"
pingLabel.Size = UDim2.new(0, 90, 0, 20)
pingLabel.Position = UDim2.new(0.75, -45, 0, 30)
pingLabel.BackgroundTransparency = 1
pingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pingLabel.TextStrokeTransparency = 0.3
pingLabel.TextSize = 11
pingLabel.Font = Enum.Font.Legacy
pingLabel.TextXAlignment = Enum.TextXAlignment.Center
pingLabel.Parent = screenGui

local lastTime = os.clock()
local frameCount = 0

_G.FpsConn = rs.RenderStepped:Connect(function()
    frameCount += 1
    local currentTime = os.clock()
    if currentTime - lastTime >= 1 then
        textLabel.Text = string.format("FPS: %d", math.floor(frameCount / (currentTime - lastTime)))
        
        local pingValue = 0
        local networkStats = stats:FindFirstChild("Network")
        if networkStats then
            local serverStatsItem = networkStats:FindFirstChild("ServerStatsItem")
            if serverStatsItem then
                local dataPing = serverStatsItem:FindFirstChild("Data Ping")
                if dataPing then
                    pingValue = dataPing:GetValue()
                end
            end
        end
        
        pingLabel.Text = string.format("Ping: %d ms", math.floor(pingValue))
        
        frameCount = 0
        lastTime = currentTime
    end
end)
