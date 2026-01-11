local UIBuilder = {}

function UIBuilder:CreatePanel(parent, size)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = frame

	return frame
end

function UIBuilder:CreateButton(parent, text, size)
	local button = Instance.new("TextButton")
	button.Size = size or UDim2.fromOffset(140, 24)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Text = text
	button.Parent = parent
	return button
end

function UIBuilder:CreateHeader(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromOffset(160, 24)
	label.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Text = text
	label.Parent = parent
	return label
end

return UIBuilder