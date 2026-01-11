
-- Pascal Islands - Rayfield Executor (FULL Farming+Watering)
repeat task.wait() until game:IsLoaded()

if getgenv().PascalIslandsLoaded then return end
getgenv().PascalIslandsLoaded = true

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Pascal Islands",
    LoadingTitle = "Islands",
    LoadingSubtitle = "Rayfield Farming+",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PascalIslands",
        FileName = "Config"
    }
})

local FarmingTab = Window:CreateTab("Farming", 4483362458)
local UtilityTab = Window:CreateTab("Utility", 4483362458)

local RS = game:GetService("ReplicatedStorage")
local Net = RS.rbxts_include.node_modules["@rbxts"].net.out._NetManaged

local function getChar()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function getHumanoid()
    return getChar():WaitForChild("Humanoid")
end

local function getRoot()
    local c = getChar()
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
end

local function getIsland()
    return workspace.Islands:GetChildren()[1]
end

local runFastConn
local function runFast()
    local hum = getHumanoid()
    if runFastConn then runFastConn:Disconnect() end
    runFastConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        hum.WalkSpeed = 30
    end)
    hum.WalkSpeed = 30
end

local function stopRunFast()
    if runFastConn then runFastConn:Disconnect() runFastConn=nil end
    getHumanoid().WalkSpeed = 16
end

local function getClosestFertiles()
    local isl = getIsland()
    local root = getRoot()
    if not isl or not isl:FindFirstChild("Blocks") or not root then return {} end

    local list = {}
    for _,v in pairs(isl.Blocks:GetChildren()) do
        if v:IsA("Part") and v:FindFirstChild("Watered") and v:FindFirstChild("Top") and not v.Watered.Value then
            table.insert(list,v)
        end
    end
    table.sort(list,function(a,b)
        return (root.Position-a.Position).Magnitude < (root.Position-b.Position).Magnitude
    end)
    return list
end

local function getUnfertiles()
    local isl = getIsland()
    if not isl or not isl:FindFirstChild("Blocks") then return {} end
    local list={}
    for _,v in pairs(isl.Blocks:GetChildren()) do
        if v:IsA("Part") and v:FindFirstChild("Watered") and not v:FindFirstChild("Top") then
            table.insert(list,v)
        end
    end
    return list
end

local function equipWateringCan()
    local bp = Player.Backpack
    local char = getChar()
    if bp:FindFirstChild("wateringCan") then
        bp.wateringCan.Parent = char
        task.wait()
    end
end

local AutoWater=false
local AutoPickUnfertile=false

task.spawn(function()
    while task.wait(0.4) do
        if not AutoWater then continue end
        runFast()
        local hum = getHumanoid()
        local root = getRoot()
        for _,f in ipairs(getClosestFertiles()) do
            if not AutoWater then break end
            if (root.Position-f.Position).Magnitude>24 then
                hum:MoveTo(f.Position)
                hum.MoveToFinished:Wait()
            end
            equipWateringCan()
            pcall(function()
                Net.CLIENT_WATER_BLOCK:InvokeServer({block=f})
            end)
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not AutoPickUnfertile then continue end
        for _,f in pairs(getUnfertiles()) do
            if not AutoPickUnfertile then break end
            pcall(function()
                Net.client_request_1:InvokeServer({flower=f})
            end)
            task.wait(0.15)
        end
    end
end)

FarmingTab:CreateToggle({
    Name="Auto Water Closest Fertiles",
    CurrentValue=false,
    Callback=function(v)
        AutoWater=v
        if not v then stopRunFast() end
    end
})

FarmingTab:CreateButton({
    Name="Water Nearby Fertiles",
    Callback=function()
        for _,f in ipairs(getClosestFertiles()) do
            if (getRoot().Position-f.Position).Magnitude<=24 then
                equipWateringCan()
                Net.CLIENT_WATER_BLOCK:InvokeServer({block=f})
            end
        end
        Rayfield:Notify({Title="Watering",Content="Nearby watered",Duration=3})
    end
})

FarmingTab:CreateToggle({
    Name="Auto Pick Unfertile Flowers",
    CurrentValue=false,
    Callback=function(v)
        AutoPickUnfertile=v
    end
})

UtilityTab:CreateButton({
    Name="Stop All Farming",
    Callback=function()
        AutoWater=false
        AutoPickUnfertile=false
        stopRunFast()
        Rayfield:Notify({Title="Stopped",Content="All farming stopped",Duration=3})
    end
})

Rayfield:Notify({
    Title="Pascal Islands",
    Content="Farming+Watering Loaded",
    Duration=3
})
