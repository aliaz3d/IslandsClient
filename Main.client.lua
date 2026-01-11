local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ToggleManager = require(script.Modules.ToggleManager)
local UIBuilder = require(script.Modules.UIBuilder)
local CategoryManager = require(script.Modules.CategoryManager)
local Scheduler = require(script.Modules.Scheduler)

local AutoEat = require(script.Modules.AutoEat).new()
local Mining = require(script.Modules.MiningController).new()
local Farming = require(script.Modules.FarmingController).new()
local Movement = require(script.Modules.MovementController).new()
local TeleportController = require(script.Modules.TeleportController)

-- Register toggles
ToggleManager:Register("AutoEat", false)
ToggleManager:Register("Mining", false)
ToggleManager:Register("Farming", false)
ToggleManager:Register("Movement", false)
ToggleManager:Register("Teleports", false)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "IslandsCleanGUI"
gui.Parent = player:WaitForChild("PlayerGui")

-- Panels
local sidebar = UIBuilder:CreatePanel(gui, UDim2.fromOffset(160, 300))
sidebar.Position = UDim2.fromOffset(20, 100)

local contentRoot = UIBuilder:CreatePanel(gui, UDim2.fromOffset(220, 300))
contentRoot.Position = UDim2.fromOffset(200, 100)

local playerPanel = UIBuilder:CreatePanel(contentRoot, contentRoot.Size)
local farmingPanel = UIBuilder:CreatePanel(contentRoot, contentRoot.Size)
local miningPanel = UIBuilder:CreatePanel(contentRoot, contentRoot.Size)
local teleportPanel = UIBuilder:CreatePanel(contentRoot, contentRoot.Size)

CategoryManager:Register("Player", playerPanel)
CategoryManager:Register("Farming", farmingPanel)
CategoryManager:Register("Mining", miningPanel)
CategoryManager:Register("Teleports", teleportPanel)

local function guardedToggle(name)
	ToggleManager:Toggle(name)
	if ToggleManager:Get(name) then
		Scheduler:Apply(ToggleManager, name)
	end
end

local function sidebarButton(text, category)
	local btn = UIBuilder:CreateButton(sidebar, text, UDim2.fromOffset(150, 26))
	btn.MouseButton1Click:Connect(function()
		CategoryManager:Show(category)
	end)
end

sidebarButton("Player", "Player")
sidebarButton("Farming", "Farming")
sidebarButton("Mining", "Mining")
sidebarButton("Teleports", "Teleports")

CategoryManager:Show("Player")

-- Player panel
UIBuilder:CreateHeader(playerPanel, "Player")

local autoEatBtn = UIBuilder:CreateButton(playerPanel, "Auto Eat: OFF")
autoEatBtn.MouseButton1Click:Connect(function()
	guardedToggle("AutoEat")
end)

ToggleManager:OnChanged("AutoEat", function(state)
	autoEatBtn.Text = state and "Auto Eat: ON" or "Auto Eat: OFF"
	if state then AutoEat:Start() else AutoEat:Stop() end
end)

local moveBtn = UIBuilder:CreateButton(playerPanel, "Fast Move: OFF")
moveBtn.MouseButton1Click:Connect(function()
	guardedToggle("Movement")
end)

ToggleManager:OnChanged("Movement", function(state)
	moveBtn.Text = state and "Fast Move: ON" or "Fast Move: OFF"
	if state then Movement:Start() else Movement:Stop() end
end)

-- Farming panel
UIBuilder:CreateHeader(farmingPanel, "Farming")
local farmingBtn = UIBuilder:CreateButton(farmingPanel, "Farming: OFF")
farmingBtn.MouseButton1Click:Connect(function()
	guardedToggle("Farming")
end)

ToggleManager:OnChanged("Farming", function(state)
	farmingBtn.Text = state and "Farming: ON" or "Farming: OFF"
	if state then Farming:Start() else Farming:Stop() end
end)

-- Mining panel
UIBuilder:CreateHeader(miningPanel, "Mining")
local miningBtn = UIBuilder:CreateButton(miningPanel, "Mining: OFF")
miningBtn.MouseButton1Click:Connect(function()
	guardedToggle("Mining")
end)

ToggleManager:OnChanged("Mining", function(state)
	miningBtn.Text = state and "Mining: ON" or "Mining: OFF"
	if state then Mining:Start() else Mining:Stop() end
end)

-- Teleports panel
UIBuilder:CreateHeader(teleportPanel, "Teleports")
for name, pos in pairs(TeleportController:GetLocations()) do
	local btn = UIBuilder:CreateButton(teleportPanel, name)
	btn.MouseButton1Click:Connect(function()
		Scheduler:Apply(ToggleManager, "Teleports")
		TeleportController:TeleportTo(pos)
	end)
end