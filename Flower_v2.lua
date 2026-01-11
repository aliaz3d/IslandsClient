
-- Pascal Islands - Rayfield Executor (FLOWER ULTIMATE V3)
-- Features:
-- Auto Replant (NetManaged-safe)
-- Distance Slider
-- Flower Assist (smart cycle)
-- Inventory-aware farming
-- Modular GitHub loader ready
-- Light obfuscation (string decoding)

repeat task.wait() until game:IsLoaded()

if getgenv().PascalIslandsLoaded then return end
getgenv().PascalIslandsLoaded = true

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- ========= NetManaged (safe) =========
local function getNetManaged()
    local ok, net = pcall(function()
        return RS:WaitForChild("rbxts_include")
            :WaitForChild("node_modules")
            :WaitForChild("@rbxts")
            :WaitForChild("net")
            :WaitForChild("out")
            :WaitForChild("_NetManaged")
    end)
    return ok and net or nil
end

local NetManaged = getNetManaged()
if not NetManaged then
    warn("NetManaged not found")
    return
end

local CLIENT_WATER_BLOCK   = NetManaged:FindFirstChild("CLIENT_WATER_BLOCK")
local CLIENT_PICK_FLOWER   = NetManaged:FindFirstChild("client_request_1")
local CLIENT_PLACE_BLOCK   = NetManaged:FindFirstChild("CLIENT_PLACE_BLOCK")

-- ========= Rayfield =========
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Pascal Islands",
    LoadingTitle = "Islands",
    LoadingSubtitle = "Flower Ultimate V3",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PascalIslands",
        FileName = "FlowerUltimateV3"
    }
})

local FlowersTab = Window:CreateTab("Flowers", 4483362458)
local UtilityTab = Window:CreateTab("Utility", 4483362458)

-- ========= Helpers =========
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

-- ========= Movement =========
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
    local hum = getHumanoid()
    hum.WalkSpeed = 16
end

-- ========= Inventory-aware =========
local function inventoryIsFull()
    -- conservative heuristic
    return #Player.Backpack:GetChildren() >= 22
end

-- ========= Flower Queries =========
local function getUnwatered(maxDist)
    local isl = getIsland()
    local root = getRoot()
    if not isl or not isl:FindFirstChild("Blocks") or not root then return {} end
    local t={}
    for _,v in pairs(isl.Blocks:GetChildren()) do
        if v:IsA("Part") and v:FindFirstChild("Watered") and v:FindFirstChild("Top") and not v.Watered.Value then
            if not maxDist or (root.Position-v.Position).Magnitude <= maxDist then
                table.insert(t,v)
            end
        end
    end
    table.sort(t,function(a,b)
        return (root.Position-a.Position).Magnitude < (root.Position-b.Position).Magnitude
    end)
    return t
end

local function getFertiles(maxDist)
    local isl = getIsland()
    local root = getRoot()
    if not isl or not isl:FindFirstChild("Blocks") or not root then return {} end
    local t={}
    for _,v in pairs(isl.Blocks:GetChildren()) do
        if v:IsA("Part") and v:FindFirstChild("Watered") and v:FindFirstChild("Top") and v.Watered.Value then
            if not maxDist or (root.Position-v.Position).Magnitude <= maxDist then
                table.insert(t,v)
            end
        end
    end
    return t
end

local function getUnfertiles(maxDist)
    local isl = getIsland()
    local root = getRoot()
    if not isl or not isl:FindFirstChild("Blocks") or not root then return {} end
    local t={}
    for _,v in pairs(isl.Blocks:GetChildren()) do
        if v:IsA("Part") and v:FindFirstChild("Watered") and not v:FindFirstChild("Top") then
            if not maxDist or (root.Position-v.Position).Magnitude <= maxDist then
                table.insert(t,v)
            end
        end
    end
    return t
end

-- ========= Equip =========
local function equipWateringCan()
    local bp = Player.Backpack
    local char = getChar()
    if bp:FindFirstChild("wateringCan") then
        bp.wateringCan.Parent = char
        task.wait()
    end
end

-- ========= States =========
local AutoWater=false
local AutoCollect=false
local AutoClean=false
local FlowerCycle=false
local MaxDistance=40

-- ========= Auto Replant =========
local function findFlowerSeed()
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item.Name and item.Name:lower():find("flower") then
            return item
        end
    end
end

local function replantOnce(maxDist)
    if not CLIENT_PLACE_BLOCK then return 0 end
    local seed = findFlowerSeed()
    if not seed then return 0 end
    local count=0
    for _, spot in pairs(getUnfertiles(maxDist)) do
        CLIENT_PLACE_BLOCK:InvokeServer({
            blockType = seed.Name,
            cframe = spot.CFrame,
            player_tracking_category = "join_from_web"
        })
        count+=1
        if count%10==0 then task.wait() end
    end
    return count
end

-- ========= Loops =========
task.spawn(function()
    while task.wait(0.4) do
        if not AutoWater or not CLIENT_WATER_BLOCK then continue end
        runFast()
        local hum=getHumanoid()
        local root=getRoot()
        for _,f in ipairs(getUnwatered(MaxDistance)) do
            if not AutoWater then break end
            if (root.Position-f.Position).Magnitude>24 then
                hum:MoveTo(f.Position)
                hum.MoveToFinished:Wait()
            end
            equipWateringCan()
            CLIENT_WATER_BLOCK:InvokeServer({block=f})
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    while task.wait(1.2) do
        if not AutoCollect or not CLIENT_PICK_FLOWER then continue end
        if inventoryIsFull() then continue end
        for _,f in pairs(getFertiles(MaxDistance)) do
            if not AutoCollect then break end
            CLIENT_PICK_FLOWER:InvokeServer({flower=f})
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if not AutoClean or not CLIENT_PICK_FLOWER then continue end
        for _,f in pairs(getUnfertiles(MaxDistance)) do
            if not AutoClean then break end
            CLIENT_PICK_FLOWER:InvokeServer({flower=f})
            task.wait(0.25)
        end
    end
end)

-- ========= Flower Assist (smart cycle) =========
task.spawn(function()
    while task.wait(6) do
        if not FlowerCycle then continue end
        -- Water
        AutoWater=true
        task.wait(5)
        AutoWater=false
        stopRunFast()
        -- Wait for growth (poll)
        local waited=0
        while waited<25 and #getFertiles(MaxDistance)==0 do
            task.wait(1); waited+=1
        end
        -- Collect
        AutoCollect=true
        task.wait(5)
        AutoCollect=false
        -- Clean
        AutoClean=true
        task.wait(4)
        AutoClean=false
        -- Replant
        replantOnce(MaxDistance)
    end
end)

-- ========= UI =========
FlowersTab:CreateSlider({
    Name="Max Flower Distance",
    Range={10,120},
    Increment=5,
    CurrentValue=MaxDistance,
    Callback=function(v) MaxDistance=v end
})

FlowersTab:CreateToggle({Name="Auto Water Flowers",CurrentValue=false,Callback=function(v)AutoWater=v if not v then stopRunFast() end end})
FlowersTab:CreateToggle({Name="Auto Collect Fertile Flowers",CurrentValue=false,Callback=function(v)AutoCollect=v end})
FlowersTab:CreateToggle({Name="Auto Clean Unfertile Flowers",CurrentValue=false,Callback=function(v)AutoClean=v end})
FlowersTab:CreateToggle({Name="Flower Assist (Smart Cycle)",CurrentValue=false,Callback=function(v)FlowerCycle=v end})

FlowersTab:CreateButton({
    Name="Replant Flowers (Once)",
    Callback=function()
        local c = replantOnce(MaxDistance)
        Rayfield:Notify({Title="Replant",Content="Replanted "..c,Duration=3})
    end
})

UtilityTab:CreateButton({
    Name="STOP ALL FLOWER ACTIONS",
    Callback=function()
        AutoWater=false; AutoCollect=false; AutoClean=false; FlowerCycle=false
        stopRunFast()
        Rayfield:Notify({Title="Stopped",Content="All flower actions stopped",Duration=3})
    end
})

Rayfield:Notify({
    Title="Pascal Islands",
    Content="Flower Ultimate V3 Loaded",
    Duration=3
})
