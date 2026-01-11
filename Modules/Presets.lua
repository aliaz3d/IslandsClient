local P={}
local D={
 MiningMode={Mining=true,Farming=false,Movement=false,AutoEat=true},
 FarmingMode={Farming=true,Mining=false,Movement=false,AutoEat=true},
 TravelMode={Movement=true,Mining=false,Farming=false},
}
function P:Apply(T,n) for k,v in pairs(D[n] or {}) do T:Set(k,v) end end
return P