local CategoryManager = {}
local categories = {}
local activeCategory = nil

function CategoryManager:Register(name, frame)
	categories[name] = frame
	frame.Visible = false
end

function CategoryManager:Show(name)
	for cat, frame in pairs(categories) do
		frame.Visible = (cat == name)
	end
	activeCategory = name
end

return CategoryManager