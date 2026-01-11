
local CP = {}
local Net = game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.client_request_1
local function isCrop(b)
    if not b.Name then return false end
    local n=b.Name:lower()
    return n:find("crop") or n:find("wheat") or n:find("berry") or n:find("tomato")
end
function CP:PickAll(dist)
    local pl=game.Players.LocalPlayer
    local hrp=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    local isl=workspace.Islands:GetChildren()[1]
    if not isl or not isl:FindFirstChild("Blocks") then return 0 end
    local c=0
    for _,b in ipairs(isl.Blocks:GetChildren()) do
        if isCrop(b) and b.PrimaryPart then
            if dist and (b.PrimaryPart.Position-hrp.Position).Magnitude>dist then continue end
            Net:InvokeServer(b.Hitbox,"harvest")
            c+=1
            if c%40==0 then task.wait() end
        end
    end
    return c
end
return CP
