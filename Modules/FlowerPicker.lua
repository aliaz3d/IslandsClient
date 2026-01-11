
local FP = {}
local Net = game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.client_request_1
local function isFlower(b) return b.Name and b.Name:lower():find("flower") end
function FP:PickAll()
    local isl = workspace.Islands:GetChildren()[1]
    if not isl or not isl:FindFirstChild("Blocks") then return 0 end
    local c=0
    for _,b in ipairs(isl.Blocks:GetChildren()) do
        if isFlower(b) and b:FindFirstChild("Hitbox") then
            Net:InvokeServer(b.Hitbox,"pick")
            c+=1
            if c%40==0 then task.wait() end
        end
    end
    return c
end
return FP
