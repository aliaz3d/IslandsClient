local Players = game:GetService("Players")
local player = Players.LocalPlayer
local P = "IslandsToggle_"
local M = {}
function M:Save(k,v) player:SetAttribute(P..k,v) end
function M:Load(k) return player:GetAttribute(P..k) end
return M