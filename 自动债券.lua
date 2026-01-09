--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- Here script 😄
if not game:IsLoaded() then game.Loaded:Wait() end

if _G.Rejoined then return end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        queueonteleport("_G.Rejoined = true")
        TeleportService:Teleport(game.PlaceId)
    end)
end)
repeat task.wait() until Players.LocalPlayer.Character and not Players.LocalPlayer.PlayerGui:FindFirstChild("LoadingScreenPrefab")
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EndDecision"):FireServer(false)

if not game.CoreGui:FindFirstChild("BondFarm") then
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "BondFarm"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Name = "mainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 80)
    mainFrame.Position = UDim2.new(0, 20, 0, 100)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    mainFrame.ZIndex = 2

    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart = nil
    local startPos = nil

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    mainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0.4, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "shenmi脚本自动债券🤑"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.ZIndex = 3

    local bondCount = Instance.new("TextLabel", mainFrame)
    bondCount.Name = "bondCount"
    bondCount.Size = UDim2.new(1, 0, 0.6, 0)
    bondCount.Position = UDim2.new(0, 0, 0.4, 0)
    bondCount.BackgroundTransparency = 1
    bondCount.Text = "债券数量: 0"
    bondCount.TextColor3 = Color3.new(0.8, 0.8, 1)
    bondCount.TextScaled = true
    bondCount.Font = Enum.Font.SourceSans
    bondCount.ZIndex = 3
end

_G.Bond = 0
workspace.RuntimeItems.ChildAdded:Connect(function(v)
    if v.Name:find("Bond") and v:FindFirstChild("Part") then
        v.Destroying:Connect(function()
            _G.Bond += 1
        end)
    end
end)

task.spawn(function()
    while true do
        local gui = game.CoreGui:FindFirstChild("BondFarm")
        if gui and gui:FindFirstChild("mainFrame") and gui.mainFrame:FindFirstChild("bondCount") then
            gui.mainFrame.bondCount.Text = "债券数量: " .. tostring(_G.Bond)
        end
        task.wait(0.1)
    end
end)

local player = Players.LocalPlayer
player.CameraMode = "Classic"
player.CameraMaxZoomDistance = math.huge
player.CameraMinZoomDistance = 30

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
workspace.CurrentCamera.CameraSubject = hum
hrp.Anchored = true
task.wait(0.2)

hrp.CFrame = CFrame.new(80, 3, -9000)
repeat task.wait() until workspace.RuntimeItems:FindFirstChild("MaximGun")
task.wait(0.2)

for _, v in pairs(workspace.RuntimeItems:GetChildren()) do
    if v.Name == "MaximGun" and v:FindFirstChild("VehicleSeat") then
        v.VehicleSeat.Disabled = false
        v.VehicleSeat:SetAttribute("Disabled", false)
        v.VehicleSeat:Sit(hum)
    end
end

task.wait(0.2)
for _, v in pairs(workspace.RuntimeItems:GetChildren()) do
    if v.Name == "MaximGun" and v:FindFirstChild("VehicleSeat") and (hrp.Position - v.VehicleSeat.Position).Magnitude < 400 then
        hrp.CFrame = v.VehicleSeat.CFrame
    end
end

task.wait(0.5)
hrp.Anchored = false
repeat task.wait(0.1) until hum.Sit
task.wait(0.3)
hum.Sit = false
task.wait(0.2)

repeat
    for _, v in pairs(workspace.RuntimeItems:GetChildren()) do
        if v.Name == "MaximGun" and v:FindFirstChild("VehicleSeat") and (hrp.Position - v.VehicleSeat.Position).Magnitude < 400 then
            hrp.CFrame = v.VehicleSeat.CFrame
        end
    end
    task.wait(0.2)
until hum.Sit

task.wait(0.4)
for _, v in pairs(workspace:GetChildren()) do
    if v:IsA("Model") and v:FindFirstChild("RequiredComponents") then
        local seat = v.RequiredComponents:FindFirstChild("Controls") and v.RequiredComponents.Controls:FindFirstChild("ConductorSeat") and v.RequiredComponents.Controls.ConductorSeat:FindFirstChild("VehicleSeat")
        if seat then
            local tp = game:GetService("TweenService"):Create(hrp, TweenInfo.new(15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = seat.CFrame * CFrame.new(0, 20, 0)})
            tp:Play()
            if not hrp:FindFirstChild("VelocityHandler") then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Name = "VelocityHandler"
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Velocity = Vector3.zero
            end
            tp.Completed:Wait()
        end
    end
end

task.wait(0.5)
while true do
    if hum.Sit then
        local tp = game:GetService("TweenService"):Create(hrp, TweenInfo.new(10, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = CFrame.new(0.5, -78, -49429)})
        tp:Play()
        if not hrp:FindFirstChild("VelocityHandler") then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "VelocityHandler"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
        end
        repeat task.wait() until workspace.RuntimeItems:FindFirstChild("Bond")
        tp:Cancel()

        for _, v in pairs(workspace.RuntimeItems:GetChildren()) do
            if v.Name:find("Bond") and v:FindFirstChild("Part") then
                repeat
                    if v:FindFirstChild("Part") then
                        hrp.CFrame = v.Part.CFrame
                        game:GetService("ReplicatedStorage").Shared.Network.RemotePromise.Remotes.C_ActivateObject:FireServer(v)
                    end
                    task.wait(0.1)
                until not v:FindFirstChild("Part")
            end
        end
    end
    task.wait(0.1)
end