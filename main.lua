--[[
    远程加载脚本 - 移速调节 + 跳跃增强
    特性：持续循环保持速度（防重置）、可拖动UI、预设速度一键切换
]]
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

repeat task.wait() until lp and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")

local PlayerGui = lp:WaitForChild("PlayerGui")
local humanoid = lp.Character:FindFirstChildOfClass("Humanoid")
local currentSpeed = 16
local speedLoop = nil

local function applySpeed()
    if humanoid then humanoid.WalkSpeed = currentSpeed end
end

local function startSpeedLoop()
    if speedLoop then return end
    speedLoop = RunService.Heartbeat:Connect(function()
        if not humanoid or not humanoid.Parent then
            local char = lp.Character
            if char then humanoid = char:FindFirstChildOfClass("Humanoid") end
        end
        if humanoid and humanoid.WalkSpeed ~= currentSpeed then
            humanoid.WalkSpeed = currentSpeed
        end
    end)
end

lp.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then applySpeed() end
end)

applySpeed()
startSpeedLoop()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 99999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, parent = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = (success and parent) or PlayerGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 130, 0, 48)
ToggleBtn.Position = UDim2.new(0.72, 0, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(26,26,26)
ToggleBtn.BorderColor3 = Color3.fromRGB(130,130,130)
ToggleBtn.BorderSizePixel = 2
ToggleBtn.Text = "开/关"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextSize = 17
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.ZIndex = 9999
ToggleBtn.Parent = ScreenGui

local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 330, 0, 430)
MainPanel.Position = UDim2.new(0.02, 0, 0.2, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(18,18,18)
MainPanel.BorderColor3 = Color3.fromRGB(85,85,85)
MainPanel.BorderSizePixel = 3
MainPanel.Visible = false
MainPanel.Active = true
MainPanel.ZIndex = 9998
MainPanel.Parent = ScreenGui

local dragBtn = false
local btnStartPos, touchStart, dragDistance
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragBtn = true
        dragDistance = 0
        touchStart = input.Position
        btnStartPos = ToggleBtn.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragBtn then
        local delta = input.Position - touchStart
        dragDistance = dragDistance + math.abs(delta.X) + math.abs(delta.Y)
        ToggleBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
    end
end)
ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragBtn = false
        if dragDistance < 22 then MainPanel.Visible = not MainPanel.Visible end
    end
end)
ToggleBtn.MouseButton1Click:Connect(function() MainPanel.Visible = not MainPanel.Visible end)
ToggleBtn.TouchTap:Connect(function() MainPanel.Visible = not MainPanel.Visible end)

local dragPanel = false
local panelStartPos, panelTouchStart
MainPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragPanel = true
        panelTouchStart = input.Position
        panelStartPos = MainPanel.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragPanel then
        local delta = input.Position - panelTouchStart
        MainPanel.Position = UDim2.new(panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X, panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragPanel = false
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 32)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "⚙ 设置面板"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 21
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainPanel

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 5
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.Parent = MainPanel

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 12)
List.Parent = Content

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1,0,0,30)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "当前移速："..currentSpeed
SpeedLabel.TextColor3 = Color3.new(1,1,1)
SpeedLabel.TextSize = 16
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = Content

local speeds = {
    {name = "慢速 1",   val = 1},
    {name = "默认 16",  val = 16},
    {name = "快速 60",  val = 60},
    {name = "高速 180", val = 180},
    {name = "超速 350", val = 350},
    {name = "极限 500", val = 500},
}
for _, s in ipairs(speeds) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,36)
    btn.BackgroundColor3 = Color3.fromRGB(38,38,38)
    btn.BorderColor3 = Color3.fromRGB(90,90,90)
    btn.BorderSizePixel = 1
    btn.Text = s.name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 15
    btn.Font = Enum.Font.SourceSans
    btn.Parent = Content
    btn.MouseButton1Click:Connect(function()
        currentSpeed = s.val
        SpeedLabel.Text = "当前移速："..currentSpeed
        applySpeed()
        btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(38,38,38)
    end)
end

local function createFuncBtn(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,36)
    btn.BackgroundColor3 = Color3.fromRGB(38,38,38)
    btn.BorderColor3 = Color3.fromRGB(90,90,90)
    btn.BorderSizePixel = 1
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 15
    btn.Parent = Content
    btn.MouseButton1Click:Connect(function()
        callback()
        btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(38,38,38)
    end)
end

createFuncBtn("🚀 超高跳跃", function()
    if humanoid then humanoid.JumpPower = 55 end
end)
createFuncBtn("↺ 重置跳跃", function()
    if humanoid then humanoid.JumpPower = 7.2 end
end)

task.wait(0.1)
Content.CanvasSize = UDim2.new(0,0,0, List.AbsoluteContentSize.Y + 20)

print("✅ 速度脚本已加载，当前移速："..currentSpeed)
