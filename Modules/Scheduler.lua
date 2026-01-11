local Scheduler = {}

local CONFLICTS = {
	Movement = { "Mining", "Farming" },
	Mining   = { "Movement", "Farming" },
	Farming  = { "Movement", "Mining" },
	Teleports = { "Movement", "Mining", "Farming" },
}

function Scheduler:Apply(toggleManager, enabledFeature)
	local conflicts = CONFLICTS[enabledFeature]
	if not conflicts then return end
	for _, other in ipairs(conflicts) do
		if toggleManager:Get(other) then
			toggleManager:Set(other, false)
		end
	end
end

return Scheduler