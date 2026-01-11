
-- Pascal Islands - FULL Rayfield Executor Version
repeat task.wait() until game:IsLoaded()

if getgenv().PascalIslandsLoaded then return end
getgenv().PascalIslandsLoaded = true

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Pascal Islands",
    LoadingTitle = "Islands",
    LoadingSubtitle = "Rayfield Executor",
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

local function getIsland()
    for _, i in pairs(workspace.Islands:GetChildren()) do
        if i:IsA("Model") then return i end
    end
end

local function pickFlowers()
    local island = getIsland()
    if not island or not island:FindFirstChild("Blocks") then return 0 end
    local c=0
    for _,b in pairs(island.Blocks:GetChildren()) do
        if b.Name and b.Name:lower():find("flower") then
            pcall(function()
                Net.client_request_1:InvokeServer({flower=b})
                c+=1
            end)
            if c%25==0 then task.wait() end
        end
    end
    return c
end

local function pickBerries()
    local island = getIsland()
    if not island or not island:FindFirstChild("Blocks") then return 0 end
    local c=0
    for _,b in pairs(island.Blocks:GetChildren()) do
        if b.Name and b.Name:lower():find("berry") and b:FindFirstChild("stage") and b.stage.Value==3 then
            pcall(function()
                Net.CLIENT_HARVEST_CROP_REQUEST:InvokeServer({
                    player=game.Players.LocalPlayer,
                    model=b,
                    player_tracking_category="join_from_web"
                })
                c+=1
            end)
            if c%20==0 then task.wait() end
        end
    end
    return c
end

local DropAura=false
task.spawn(function()
    while task.wait(1.2) do
        if not DropAura then continue end
        local island = getIsland()
        if not island or not island:FindFirstChild("Drops") then continue end
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        for _,t in pairs(island.Drops:GetChildren()) do
            if t:IsA("Tool") and t:FindFirstChild("HandleDisabled") then
                if (t.HandleDisabled.Position-hrp.Position).Magnitude<=25 then
                    pcall(function()
                        Net.CLIENT_TOOL_PICKUP_REQUEST:InvokeServer({
                            tool=t,
                            player_tracking_category="join_from_web"
                        })
                    end)
                    task.wait(0.1)
                end
            end
        end
    end
end)

FarmingTab:CreateButton({
    Name="Pick All Flowers",
    Callback=function()
        Rayfield:Notify({Title="Flowers",Content="Picked "..pickFlowers(),Duration=3})
    end
})

FarmingTab:CreateButton({
    Name="Pick All Berries",
    Callback=function()
        Rayfield:Notify({Title="Berries",Content="Picked "..pickBerries(),Duration=3})
    end
})

UtilityTab:CreateToggle({
    Name="Pickup Drops Aura",
    CurrentValue=false,
    Callback=function(v) DropAura=v end
})

Rayfield:Notify({
    Title="Pascal Islands",
    Content="Fully loaded (Rayfield Executor)",
    Duration=3
})
