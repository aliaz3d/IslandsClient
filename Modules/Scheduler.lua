local S={}
local C={Movement={"Mining","Farming"},Mining={"Movement","Farming"},Farming={"Movement","Mining"},Teleports={"Movement","Mining","Farming"}}
function S:Apply(T,n) for _,o in ipairs(C[n] or {}) do if T:Get(o) then T:Set(o,false) end end end
return S