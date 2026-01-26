-- Islands Auto Plow (NetManaged-safe, Executor-only)

repeat task.wait() until game:IsLoaded()
if getgenv().AutoPlowLoaded then return end
getgenv().AutoPlowLoaded = true

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

------------------------------------------------
-- NetManaged (SAFE)
------------------------------------------------
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

local Net = getNetManaged()
if not Net then
    warn("NetManaged not found")
    return
end

local CLIENT_PLOW_BLOCK = Net:FindFirstChild("CLIENT_PLOW_BLOCK")
if not CLIENT_PLOW_BLOCK then
    warn("CLIENT_PLOW_BLOCK remote not found")
    return
end

------------------------------------------------
-- Helpers
------------------------------------------------
local function getChar()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function getHumanoid()
    return getChar():WaitForChild("Humanoid")
end

local function getRoot()
    local c = getChar()
    return c:FindFirstChild("HumanoidRootPart")
        or c:FindFirstChild("UpperTorso")
        or c:FindFirstChild("Torso")
end

local function getIsland()
    return workspace.Islands:GetChildren()[1]
end

local function equipHoe()
    local bp = Player.Backpack
    local char = getChar()
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("hoe") then
            tool.Parent = char
            task.wait()
            return true
        end
    end
end

------------------------------------------------
-- Find unplowed soil
------------------------------------------------
local function getUnplowed(maxDistance)
    local isl = getIsland()
    local root = getRoot()
    if not isl or not isl:FindFirstChild("Blocks") or not root then return {} end

    local plots = {}
    for _, block in pairs(isl.Blocks:GetChildren()) do
        if block:IsA("Part")
            and block.Name:lower():find("soil")
            and not block:FindFirstChild("Plowed") then

            local dist = (root.Position - block.Position).Magnitude
            if not maxDistance or dist <= maxDistance then
                table.insert(plots, block)
            end
        end
    end

    table.sort(plots, function(a,b)
        return (root.Position-a.Position).Magnitude < (root.Position-b.Position).Magnitude
    end)

    return plots
end

------------------------------------------------
-- States
------------------------------------------------
local AutoPlow = false
local MaxPlowDistance = 40

------------------------------------------------
-- Auto plow loop
------------------------------------------------
task.spawn(function()
    while task.wait(0.6) do
        if not AutoPlow then continue end

        local hum = getHumanoid()
        local root = getRoot()
        if not hum or not root then continue end

        for _, soil in ipairs(getUnplowed(MaxPlowDistance)) do
            if not AutoPlow then break end

            if (root.Position - soil.Position).Magnitude > 24 then
                hum:MoveTo(soil.Position)
                hum.MoveToFinished:Wait()
            end

            equipHoe()

            pcall(function()
                CLIENT_PLOW_BLOCK:InvokeServer({
                    block = soil,
                    player_tracking_category = "join_from_web"
                })
            end)

            task.wait(0.25)
        end
    end
end)

------------------------------------------------
-- Rayfield UI
------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Islands – Auto Plow",
    LoadingTitle = "Islands",
    LoadingSubtitle = "Auto Plow",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PascalIslands",
        FileName = "AutoPlow"
    }
})

local PlowTab = Window:CreateTab("Plow", 4483362458)

PlowTab:CreateSlider({
    Name = "Plow Max Distance",
    Range = {10, 120},
    Increment = 5,
    CurrentValue = MaxPlowDistance,
    Callback = function(v)
        MaxPlowDistance = v
    end
})

PlowTab:CreateToggle({
    Name = "Auto Plow Soil",
    CurrentValue = false,
    Callback = function(v)
        AutoPlow = v
    end
})

PlowTab:CreateButton({
    Name = "Plow Nearby (Once)",
    Callback = function()
        local count = 0
        for _, soil in ipairs(getUnplowed(24)) do
            equipHoe()
            CLIENT_PLOW_BLOCK:InvokeServer({ block = soil })
            count += 1
            if count % 10 == 0 then task.wait() end
        end
        Rayfield:Notify({
            Title = "Auto Plow",
            Content = ("Plowed %d plots"):format(count),
            Duration = 3
        })
    end
})

Rayfield:Notify({
    Title = "Auto Plow",
    Content = "Loaded successfully",
    Duration = 3
})
