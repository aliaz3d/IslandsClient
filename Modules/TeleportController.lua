local T={}
local L={Hub=Vector3.new(0,20,0),Spawn=Vector3.new(0,25,0)}
function T:GetLocations() return L end
function T:TeleportTo(p)
 local c=game.Players.LocalPlayer.Character
 if c and c:FindFirstChild("HumanoidRootPart") then
  c.HumanoidRootPart.CFrame=CFrame.new(p)
 end
end
return T