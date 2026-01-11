
-- Islands Client EXECUTOR-ONLY (Rayfield Farming Edition)

if getgenv().IslandsClientLoaded then return end
getgenv().IslandsClientLoaded = true

local base = "https://raw.githubusercontent.com/aliaz3d/IslandsClient/main/Modules/"

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local ToggleManager      = loadstring(game:HttpGet(base .. "ToggleManager.lua"))()
local Scheduler          = loadstring(game:HttpGet(base .. "Scheduler.lua"))()
local Presets            = loadstring(game:HttpGet(base .. "Presets.lua"))()
local AutoEat            = loadstring(game:HttpGet(base .. "AutoEat.lua"))().new()
local Mining             = loadstring(game:HttpGet(base .. "MiningController.lua"))().new()
local Farming            = loadstring(game:HttpGet(base .. "FarmingController.lua"))().new()
local Movement           = loadstring(game:HttpGet(base .. "MovementController.lua"))().new()
local TeleportController = loadstring(game:HttpGet(base .. "TeleportController.lua"))()

local FlowerPicker = loadstring(game:HttpGet(base .. "FlowerPicker.lua"))()
local CropPicker   = loadstring(game:HttpGet(base .. "CropPicker.lua"))()
local FruitPicker  = loadstring(game:HttpGet(base .. "FruitPicker.lua"))()

for _, n in ipairs({ "AutoEat", "Mining", "Farming", "Movement" }) do
    ToggleManager:Register(n, false)
end

local function sync(name, v)
    ToggleManager:Set(name, v)
    if v then Scheduler:Apply(ToggleManager, name) end
end

local Window = Rayfield:CreateWindow({
    Name = "Islands Client",
    LoadingTitle = "Islands",
    LoadingSubtitle = "Executor Farming",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "IslandsClient",
        FileName = "FarmingConfig"
    }
})

local PlayerTab  = Window:CreateTab("Player", 4483362458)
local FarmingTab = Window:CreateTab("Farming", 4483362458)
local MiningTab  = Window:CreateTab("Mining", 4483362458)

PlayerTab:CreateToggle({
    Name = "Auto Eat",
    CurrentValue = false,
    Callback = function(v) sync("AutoEat", v) end
})

ToggleManager:OnChanged("AutoEat", function(v)
    if v then AutoEat:Start() else AutoEat:Stop() end
end)

PlayerTab:CreateToggle({
    Name = "Fast Movement",
    CurrentValue = false,
    Callback = function(v) sync("Movement", v) end
})

ToggleManager:OnChanged("Movement", function(v)
    if v then Movement:Start() else Movement:Stop() end
end)

FarmingTab:CreateButton({
    Name = "Pick All Flowers",
    Callback = function()
        local c = FlowerPicker:PickAll() or 0
        Rayfield:Notify({ Title="Flowers", Content="Picked "..c, Duration=3 })
    end
})

FarmingTab:CreateButton({
    Name = "Pick All Crops (Nearby)",
    Callback = function()
        local c = CropPicker:PickAll(80) or 0
        Rayfield:Notify({ Title="Crops", Content="Picked "..c, Duration=3 })
    end
})

FarmingTab:CreateButton({
    Name = "Pick All Fruits",
    Callback = function()
        local c = FruitPicker:PickAll() or 0
        Rayfield:Notify({ Title="Fruits", Content="Picked "..c, Duration=3 })
    end
})

FarmingTab:CreateButton({
    Name = "Farm Assist (All)",
    Callback = function()
        local f1 = FlowerPicker:PickAll() or 0
        task.wait(0.3)
        local f2 = CropPicker:PickAll(80) or 0
        task.wait(0.3)
        local f3 = FruitPicker:PickAll() or 0
        Rayfield:Notify({
            Title="Farm Assist",
            Content=("🌸 %d  🌾 %d  🍎 %d"):format(f1,f2,f3),
            Duration=4
        })
    end
})

MiningTab:CreateToggle({
    Name = "Auto Mining",
    CurrentValue = false,
    Callback = function(v) sync("Mining", v) end
})

ToggleManager:OnChanged("Mining", function(v)
    if v then Mining:Start() else Mining:Stop() end
end)

Rayfield:Notify({
    Title="Islands Client",
    Content="Executor Farming Loaded",
    Duration=3
})
