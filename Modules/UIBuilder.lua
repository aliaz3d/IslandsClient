local TweenService = game:GetService("TweenService")
local UI = {}

function UI:CreatePanel(parent,size)
	local f = Instance.new("Frame")
	f.Size=size; f.BackgroundColor3=Color3.fromRGB(25,25,25)
	f.BorderSizePixel=0; f.Parent=parent
	local l=Instance.new("UIListLayout")
	l.Padding=UDim.new(0,6); l.Parent=f
	return f
end

function UI:CreateButton(parent,text,size)
	local b=Instance.new("TextButton")
	b.Size=size or UDim2.fromOffset(140,24)
	b.BackgroundColor3=Color3.fromRGB(45,45,45)
	b.TextColor3=Color3.new(1,1,1)
	b.TextScaled=true; b.Text=text; b.Parent=parent
	return b
end

function UI:CreateHeader(parent,text)
	local l=Instance.new("TextLabel")
	l.Size=UDim2.fromOffset(160,24)
	l.BackgroundColor3=Color3.fromRGB(35,35,35)
	l.TextColor3=Color3.new(1,1,1)
	l.TextScaled=true; l.Text=text; l.Parent=parent
	return l
end

function UI:AnimateHover(b)
	b.MouseEnter:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(65,65,65)}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(45,45,45)}):Play()
	end)
end

return UI