local PersistedSettings = require(script.Parent.PersistedSettings)

local ToggleManager = {}
local toggles = {}
local listeners = {}

function ToggleManager:Register(name, default)
	local saved = PersistedSettings:Load(name)
	if saved ~= nil then
		toggles[name] = saved
	else
		toggles[name] = default or false
	end
	listeners[name] = {}
end

function ToggleManager:Set(name, value)
	if toggles[name] == value then return end
	toggles[name] = value
	PersistedSettings:Save(name, value)
	for _, callback in ipairs(listeners[name]) do
		task.spawn(callback, value)
	end
end

function ToggleManager:Get(name)
	return toggles[name]
end

function ToggleManager:Toggle(name)
	self:Set(name, not toggles[name])
end

function ToggleManager:OnChanged(name, callback)
	table.insert(listeners[name], callback)
end

return ToggleManager