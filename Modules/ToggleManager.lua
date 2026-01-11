local PersistedSettings = require(script.Parent.PersistedSettings)
local ToggleManager = {}
local toggles, listeners = {}, {}

function ToggleManager:Register(name, default)
	local saved = PersistedSettings:Load(name)
	toggles[name] = saved ~= nil and saved or (default or false)
	listeners[name] = {}
end

function ToggleManager:Set(name, value)
	if toggles[name] == value then return end
	toggles[name] = value
	PersistedSettings:Save(name, value)
	for _, cb in ipairs(listeners[name]) do task.spawn(cb, value) end
end

function ToggleManager:Get(name) return toggles[name] end
function ToggleManager:Toggle(name) self:Set(name, not toggles[name]) end
function ToggleManager:OnChanged(name, cb) table.insert(listeners[name], cb) end
return ToggleManager