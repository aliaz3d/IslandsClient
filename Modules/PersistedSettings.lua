local PersistedSettings = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PREFIX = "IslandsToggle_"

function PersistedSettings:Save(name, value)
	player:SetAttribute(PREFIX .. name, value)
end

function PersistedSettings:Load(name)
	return player:GetAttribute(PREFIX .. name)
end

return PersistedSettings