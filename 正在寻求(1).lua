local SCRIPT_URL = "https://raw.githubusercontent.com/YunLua/Lua/refs/heads/main/ATM.lua"
local AUTO_FOLDER = "shenmiV2脚本"
local AUTO_RELOAD_FILE = AUTO_FOLDER .. "/auto_reload.txt"
local STATE_FILE = AUTO_FOLDER .. "/atm_state.txt"

if not isfolder(AUTO_FOLDER) then
makefolder(AUTO_FOLDER)
end

if isfile(AUTO_RELOAD_FILE) then
delfile(AUTO_RELOAD_FILE)
task.wait(2)
loadstring(game:HttpGet(SCRIPT_URL))()
return
end

local MainScript = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/YunLua/Lua/refs/heads/main/ATM.lua"))()
]]

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")

local RUN = true
local NO_ATM_TIME = 0
local SERVER_HOP_TIME = 25

local RANDOM_POS = {
    Vector3.new(-1137, 78, -1953),
    Vector3.new(-44, 63, -2083),
    Vector3.new(194, 60, -2884),
    Vector3.new(-412, 106, -1301),
    Vector3.new(-377, 410, -741),
    Vector3.new(-985, 380, -1145),
    Vector3.new(-854, 406, -1505)
}

local GizmosFolder = workspace.Local.Gizmos.White

if isfile(STATE_FILE) then
RUN = readfile(STATE_FILE) == "1"
end

local function saveState()
writefile(STATE_FILE, RUN and "1" or "0")
end

local function getPart(obj)
if obj:IsA("BasePart") then return obj end
for _, v in ipairs(obj:GetDescendants()) do
if v:IsA("BasePart") then
return v
end
end
end

local ATTACK_ATM = true
local ATTACK_REGISTER = true

local function isATM(obj)
local t = obj:GetAttribute("gizmoType")
if t == "ATM" and ATTACK_ATM then
return true
elseif t == "Register" and ATTACK_REGISTER then
return true
end
return false
end

local function getNearestATM()
local nearest, dist = nil, math.huge
for _, gizmo in ipairs(GizmosFolder:GetChildren()) do
if isATM(gizmo) then
local part = getPart(gizmo)
if part then
local d = (HRP.Position - part.Position).Magnitude
if d < dist then
nearest, dist = part, d
end
end
end
end
return nearest
end

local function teleportTo(target)
if typeof(target) == "Vector3" then
HRP.CFrame = CFrame.new(target)
elseif typeof(target) == "Instance" then
HRP.CFrame = target.CFrame * CFrame.new(0, 5, 0)
end
end

local function pressE(time)
local start = tick()
while tick() - start < time do
VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
task.wait(0.05)
end
end

local function collectATM(atm)
local start = tick()
while tick() - start < 3 and atm.Parent and not atm:GetAttribute("Collected") do
task.wait(0.1)
end
pressE(1.5)
end

local function serverHop()
writefile(AUTO_RELOAD_FILE, "1")
saveState()

local placeId = game.PlaceId
local ok, data = pcall(function()
local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(placeId)
return HttpService:JSONDecode(game:HttpGet(url)).data
end)

if not ok then return end

local servers = {}
for _, s in pairs(data) do
if s.playing < s.maxPlayers and s.id ~= game.JobId then
table.insert(servers, s.id)
end
end

if #servers > 0 then
TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(#servers)], player)
end

end

local function startATM()
task.spawn(function()
    NO_ATM_TIME = 0
    while RUN do
    local atm = getNearestATM()
    if atm then
        teleportTo(atm)
        task.wait(0.3)
        pressE(1.5)
        collectATM(atm)
        NO_ATM_TIME = 0
    else
        NO_ATM_TIME += 0.7
        teleportTo(RANDOM_POS[math.random(#RANDOM_POS)])
        if NO_ATM_TIME >= SERVER_HOP_TIME then    
                warn("25秒未找到目标，正在换服")    
                task.wait(1)    
                RUN = false    
                queue_on_teleport(MainScript)  
                wait()  
                serverHop()    
                break    
            end    
        end    
        task.wait(0.7)    
        end
    end)
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/whenheet/-3/refs/heads/main/1", true))()
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "shenmiV2脚本 - 正在寻求",
    Size = UDim2.fromOffset(220, 270),
    Theme = "Dark",
})

local UtilitySection = Window:Tab({
    Title = "主要",
    Locked = false,
})

UtilitySection:Toggle({
    Title = "打击目标收银机",
    Value = ATTACK_REGISTER,
    Callback = function(state)
        ATTACK_REGISTER = state
    end
})

UtilitySection:Toggle({
    Title = "打击目标ATM",
    Value = ATTACK_ATM,
    Callback = function(state)
        ATTACK_ATM = state
    end
})

UtilitySection:Toggle({
    Title = "自动打击",
    Value = RUN,
    Desc = "自动寻找目标并打击，未找到自动换服后自动重载",
    Callback = function(state)
        RUN = state
        saveState()
        if state then
            startATM()
        end
    end
})

if RUN then
    task.wait(1)
    startATM()
end