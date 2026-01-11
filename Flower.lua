
-- Pascal Islands - Rayfield Executor (FLOWER ULTIMATE)
repeat task.wait() until game:IsLoaded()

if getgenv().PascalIslandsLoaded then return end
getgenv().PascalIslandsLoaded = true

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Pascal Islands",
    LoadingTitle = "Islands",
    LoadingSubtitle = "Flower Ultimate",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PascalIslands",
        FileName = "FlowerUltimate"
    }
})

local FarmingTab = Window:CreateTab("Flowers", 4483362458)
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

local function getUnwatered()
    local isl = getIsland()
    local root = getRoot()
    if not isl or not isl:FindFirstChild("Blocks") or not root then return {} end
    local t={}
    for _,v in pairs(isl.Blocks:GetChildren()) do
        if v:IsA("Part") and v:FindFirstChild("Watered") and v:FindFirstChild("Top") and not v.Watered.Value then
            table.insert(t,v)
        end
    end
    table.sort(t,function(a,b)
        return (root.Position-a.Position).Magnitude < (root.Position-b.Position).Magnitude
    end)
    return t
end

local function getFertiles()
    local isl = getIsland()
    if not isl or not isl:FindFirstChild("Blocks") then return {} end
    local t={}
    for _,v in pairs(isl.Blocks:GetChildren()) do
        if v:IsA("Part") and v:FindFirstChild("Watered") and v:FindFirstChild("Top") and v.Watered.Value then
            table.insert(t,v)
        end
    end
    return t
end

local function getUnfertiles()
    local isl = getIsland()
    if not isl or not isl:FindFirstChild("Blocks") then return {} end
    local t={}
    for _,v in pairs(isl.Blocks:GetChildren()) do
        if v:IsA("Part") and v:FindFirstChild("Watered") and not v:FindFirstChild("Top") then
            table.insert(t,v)
        end
    end
    return t
end

local function equipWateringCan()
    local bp = Player.Backpack
    local char = getChar()
    if bp:FindFirstChild("wateringCan") then
        bp.wateringCan.Parent = char
        task.wait()
    end
end

local Busy=false
local function safe(fn)
    if Busy then return end
    Busy=true
    pcall(fn)
    Busy=false
end

local AutoWater=false
local AutoCollect=false
local AutoClean=false
local FlowerCycle=false

task.spawn(function()
    while task.wait(0.4) do
        if not AutoWater then continue end
        runFast()
        local hum=getHumanoid()
        local root=getRoot()
        for _,f in ipairs(getUnwatered()) do
            if not AutoWater then break end
            if (root.Position-f.Position).Magnitude>24 then
                hum:MoveTo(f.Position)
                hum.MoveToFinished:Wait()
            end
            equipWateringCan()
            Net.CLIENT_WATER_BLOCK:InvokeServer({block=f})
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    while task.wait(1.2) do
        if not AutoCollect then continue end
        for _,f in pairs(getFertiles()) do
            if not AutoCollect then break end
            Net.client_request_1:InvokeServer({flower=f})
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if not AutoClean then continue end
        for _,f in pairs(getUnfertiles()) do
            if not AutoClean then break end
            Net.client_request_1:InvokeServer({flower=f})
            task.wait(0.25)
        end
    end
end)

task.spawn(function()
    while task.wait(6) do
        if not FlowerCycle then continue end
        AutoWater=true
        task.wait(5)
        AutoWater=false
        stopRunFast()
        task.wait(10)
        AutoCollect=true
        task.wait(5)
        AutoCollect=false
        AutoClean=true
        task.wait(4)
        AutoClean=false
    end
end)

FarmingTab:CreateToggle({Name="Auto Water Flowers",CurrentValue=false,Callback=function(v)AutoWater=v if not v then stopRunFast() end end})
FarmingTab:CreateToggle({Name="Auto Collect Fertile Flowers",CurrentValue=false,Callback=function(v)AutoCollect=v end})
FarmingTab:CreateToggle({Name="Auto Clean Unfertile Flowers",CurrentValue=false,Callback=function(v)AutoClean=v end})
FarmingTab:CreateToggle({Name="Flower Cycle Mode",CurrentValue=false,Callback=function(v)FlowerCycle=v end})

FarmingTab:CreateButton({
    Name="Collect Fertile Flowers (Once)",
    Callback=function()
        safe(function()
            local c=0
            for _,f in pairs(getFertiles()) do
                Net.client_request_1:InvokeServer({flower=f})
                c+=1
                if c%20==0 then task.wait() end
            end
            Rayfield:Notify({Title="Flowers",Content="Collected "..c,Duration=3})
        end)
    end
})

UtilityTab:CreateButton({
    Name="STOP ALL FLOWER ACTIONS",
    Callback=function()
        AutoWater=false
        AutoCollect=false
        AutoClean=false
        FlowerCycle=false
        stopRunFast()
        Rayfield:Notify({Title="Stopped",Content="All flower actions stopped",Duration=3})
    end
})

Rayfield:Notify({
    Title="Pascal Islands",
    Content="Flower Ultimate Loaded",
    Duration=3
})
