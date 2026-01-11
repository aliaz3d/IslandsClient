local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Rayfield (executor required)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Hybrid module loader
local Modules

if script:FindFirstChild("Modules") then
	-- Studio / proper hierarchy
	Modules = script.Modules
else
	-- Executor fallback (RAW URLs required)
	local base = "https://raw.githubusercontent.com/aliaz3d/IslandsClient/main/Modules/"
	Modules = {
		ToggleManager = loadstring(game:HttpGet(base .. "ToggleManager.lua"))(),
		Scheduler = loadstring(game:HttpGet(base .. "Scheduler.lua"))(),
		Presets = loadstring(game:HttpGet(base .. "Presets.lua"))(),
		AutoEat = loadstring(game:HttpGet(base .. "AutoEat.lua"))(),
		MiningController = loadstring(game:HttpGet(base .. "MiningController.lua"))(),
		FarmingController = loadstring(game:HttpGet(base .. "FarmingController.lua"))(),
		MovementController = loadstring(game:HttpGet(base .. "MovementController.lua"))(),
		TeleportController = loadstring(game:HttpGet(base .. "TeleportController.lua"))(),
	}
end

local ToggleManager = require(Modules.ToggleManager)
local Scheduler = require(Modules.Scheduler)
local Presets = require(Modules.Presets)

local AutoEat = require(Modules.AutoEat).new()
local Mining = require(Modules.MiningController).new()
local Farming = require(Modules.FarmingController).new()
local Movement = require(Modules.MovementController).new()
local TeleportController = require(Modules.TeleportController)

-- Window
local Window = Rayfield:CreateWindow({
	Name = "Islands Client",
	LoadingTitle = "Islands",
	LoadingSubtitle = "Rayfield Hybrid",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "IslandsClient",
		FileName = "RayfieldConfig"
	}
})

-- Register toggles
for _, name in ipairs({ "AutoEat", "Mining", "Farming", "Movement" }) do
	ToggleManager:Register(name, false)
end

local function syncToggle(name, value)
	ToggleManager:Set(name, value)
	if value then Scheduler:Apply(ToggleManager, name) end
end

-- Tabs
local PlayerTab = Window:CreateTab("Player", 4483362458)
local FarmingTab = Window:CreateTab("Farming", 4483362458)
local MiningTab = Window:CreateTab("Mining", 4483362458)
local TravelTab = Window:CreateTab("Travel", 4483362458)

-- PLAYER
PlayerTab:CreateToggle({
	Name = "Auto Eat",
	CurrentValue = false,
	Callback = function(v) syncToggle("AutoEat", v) end,
})

ToggleManager:OnChanged("AutoEat", function(v)
	if v then AutoEat:Start() else AutoEat:Stop() end
end)

PlayerTab:CreateToggle({
	Name = "Fast Movement",
	CurrentValue = false,
	Callback = function(v) syncToggle("Movement", v) end,
})

ToggleManager:OnChanged("Movement", function(v)
	if v then Movement:Start() else Movement:Stop() end
end)

PlayerTab:CreateSection("Presets")

PlayerTab:CreateButton({
	Name = "Mining Mode",
	Callback = function()
		Presets:Apply(ToggleManager, "MiningMode")
		Scheduler:Apply(ToggleManager, "Mining")
	end,
})

PlayerTab:CreateButton({
	Name = "Farming Mode",
	Callback = function()
		Presets:Apply(ToggleManager, "FarmingMode")
		Scheduler:Apply(ToggleManager, "Farming")
	end,
})

PlayerTab:CreateButton({
	Name = "Travel Mode",
	Callback = function()
		Presets:Apply(ToggleManager, "TravelMode")
	end,
})

-- FARMING
FarmingTab:CreateToggle({
	Name = "Auto Farming",
	CurrentValue = false,
	Callback = function(v) syncToggle("Farming", v) end,
})

ToggleManager:OnChanged("Farming", function(v)
	if v then Farming:Start() else Farming:Stop() end
end)

-- MINING
MiningTab:CreateToggle({
	Name = "Auto Mining",
	CurrentValue = false,
	Callback = function(v) syncToggle("Mining", v) end,
})

ToggleManager:OnChanged("Mining", function(v)
	if v then Mining:Start() else Mining:Stop() end
end)

-- TRAVEL
TravelTab:CreateSection("Teleports")
for name, pos in pairs(TeleportController:GetLocations()) do
	TravelTab:CreateButton({
		Name = name,
		Callback = function()
			Scheduler:Apply(ToggleManager, "Teleports")
			TeleportController:TeleportTo(pos)
		end,
	})
end

-- Respawn safety
player.CharacterAdded:Connect(function()
	task.wait(1)
	if ToggleManager:Get("AutoEat") then AutoEat:Start() end
	if ToggleManager:Get("Mining") then Mining:Start() end
	if ToggleManager:Get("Farming") then Farming:Start() end
	if ToggleManager:Get("Movement") then Movement:Start() end
end)

Rayfield:Notify({
	Title = "Islands Client",
	Content = "Rayfield Hybrid loaded successfully",
	Duration = 3,
})
