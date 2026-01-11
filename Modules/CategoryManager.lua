local M, cats = {}, {}
function M:Register(n,f) cats[n]=f; f.Visible=false end
function M:Show(n) for k,f in pairs(cats) do f.Visible=(k==n) end end
return M