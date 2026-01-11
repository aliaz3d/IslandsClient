local M, t, l = {}, {}, {}
function M:Register(n,d) t[n]=d or false; l[n]={} end
function M:Set(n,v) if t[n]==v then return end; t[n]=v; for _,c in ipairs(l[n]) do task.spawn(c,v) end end
function M:Get(n) return t[n] end
function M:OnChanged(n,c) table.insert(l[n],c) end
return M