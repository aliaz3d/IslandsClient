-- Aliaz Islands - Auto Plow (Rayfield)
repeat task.wait() until game:IsLoaded()

-- prevent double load
if getgenv().AliazAutoPlowLoaded then return end
getgenv().AliazAutoPlowLoaded = true

------------------------------------------------
-- SERVICES
------------------------------------------------
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- Net
local Net = RS.rbxts_include.node_modules["@rbxts"].net.out._NetManaged

------------------------------------------------
-- RAYFIELD (KNOWN WORKING LOADER)
------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Aliaz Islands",
    LoadingTitle = "Islands",
    LoadingSubtitle = "Auto Plow",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AliazIslands",
        FileName = "AutoPlow"
    }
})

local FarmingTab = Window:CreateTab("Farming", 4483362458)
local UtilityTab = Window:CreateTab("Utility", 4483362458)

------------------------------------------------
-- HELPERS (same style as your working script)
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

------------------------------------------------
-- EQUIP PLOW
------------------------------------------------
local function equipPlow()
    local bp = Player.Backpack
    local char = getChar()
    if char:FindFirstChild("plow") then return end
    if bp:FindFirstChild("plow") then
        bp.plow.Parent = char
        task.wait()
    end
end

------------------------------------------------
-- STATES
------------------------------------------------
local AutoPlow = false
local PlowRadius = 10
local PlowDelay = 0.05 -- server-safe throttle

------------------------------------------------
-- AUTO PLOW LOOP (GRID / FAST)
------------------------------------------------
task.spawn(function()
    while task.wait(0.3) do
        if not AutoPlow then continue end

        local isl = getIsland()
        local root = getRoot()
        if not isl or not isl:FindFirstChild("Blocks") or not root then
            continue
        end

        equipPlow()

        for _,block in pairs(isl.Blocks:GetChildren()) do
            if not AutoPlow then break end

            if block.Name == "grass" then
                local dist = (root.Position - block.Position).Magnitude
                if dist <= PlowRadius then
                    pcall(function()
                        Net.CLIENT_PLOW_BLOCK_REQUEST:InvokeServer({
                            block = block
                        })
                    end)
                    task.wait(PlowDelay)
                end
            end
        end
    end
end)

------------------------------------------------
-- UI
------------------------------------------------
FarmingTab:CreateToggle({
    Name = "Auto Plow Nearby",
    CurrentValue = false,
    Callback = function(v)
        AutoPlow = v
        Rayfield:Notify({
            Title = "Auto Plow",
            Content = v and "Plowing started" or "Plowing stopped",
            Duration = 2
        })
    end
})

FarmingTab:CreateSlider({
    Name = "Plow Radius",
    Range = {4, 25},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = PlowRadius,
    Callback = function(v)
        PlowRadius = v
    end
})

UtilityTab:CreateButton({
    Name = "Stop Auto Plow",
    Callback = function()
        AutoPlow = false
        Rayfield:Notify({
            Title = "Auto Plow",
            Content = "Stopped",
            Duration = 2
        })
    end
})

------------------------------------------------
-- LOADED NOTIFICATION
------------------------------------------------
Rayfield:Notify({
    Title = "Aliaz Islands",
    Content = "Auto Plow Loaded",
    Duration = 3
})
