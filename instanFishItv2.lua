-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote
local RFChargeFishingRod = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
local RFRequestFishingMinigameStarted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]
local REFishingCompleted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]

-- GUI Setup
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "SpeedHackFishing"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.4, 0, 0.25, 0)
frame.Position = UDim2.new(0.3, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0.25, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ SpeedHack Auto Fishing"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- Slider background
local sliderBg = Instance.new("Frame", frame)
sliderBg.Size = UDim2.new(0.9, 0, 0.15, 0)
sliderBg.Position = UDim2.new(0.05, 0, 0.35, 0)
sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderBg.BorderSizePixel = 0
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 8)

-- Slider button
local sliderBtn = Instance.new("Frame", sliderBg)
sliderBtn.Size = UDim2.new(0.1, 0, 1, 0)
sliderBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
sliderBtn.BorderSizePixel = 0
Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(0, 8)

-- Label kecepatan
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(1, 0, 0.15, 0)
speedLabel.Position = UDim2.new(0, 0, 0.52, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 3x"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextScaled = true

-- Tombol ON/OFF
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.9, 0, 0.2, 0)
toggleBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
toggleBtn.Text = "🟢 ON"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextScaled = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

-- Tombol Hide dan Close
local hideBtn = Instance.new("TextButton", frame)
hideBtn.Size = UDim2.new(0.22, 0, 0.18, 0)
hideBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
hideBtn.Text = "👁 Hide"
hideBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
hideBtn.TextColor3 = Color3.new(1, 1, 1)
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextScaled = true
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0.18, 0, 0.18, 0)
closeBtn.Position = UDim2.new(0.77, 0, 0.05, 0)
closeBtn.Text = "✖"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Variabel utama
local autoFishingRunning = false
local speedMultiplier = 3
local hidden = false
local dragging = false
local sliderConnection

-- Auto Fishing Function
local function autoFishing()
	while autoFishingRunning do
		for i = 1, speedMultiplier do
			RFChargeFishingRod:InvokeServer(workspace:GetServerTimeNow())
			RFRequestFishingMinigameStarted:InvokeServer(math.random(), math.random())
			REFishingCompleted:FireServer()
			task.wait(0.05)
		end
		task.wait(0.1)
	end
end

-- Fungsi Toggle
toggleBtn.MouseButton1Click:Connect(function()
	autoFishingRunning = not autoFishingRunning
	if autoFishingRunning then
		toggleBtn.Text = "🔴 OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		spawn(autoFishing)
	else
		toggleBtn.Text = "🟢 ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
	end
end)

-- Fungsi Hide
hideBtn.MouseButton1Click:Connect(function()
	hidden = not hidden
	for _, v in pairs(frame:GetChildren()) do
		if v ~= hideBtn and v ~= closeBtn then
			v.Visible = not hidden
		end
	end
	hideBtn.Text = hidden and "👁 Show" or "👁 Hide"
end)

-- Fungsi Close
closeBtn.MouseButton1Click:Connect(function()
	autoFishingRunning = false
	gui:Destroy()
end)

-- Fungsi Slider
local UserInputService = game:GetService("UserInputService")

sliderBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)

sliderBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
		sliderBtn.Size = UDim2.new(0.1, 0, 1, 0)
		sliderBtn.Position = UDim2.new(pos - 0.05, 0, 0, 0)
		speedMultiplier = math.floor(pos * 9) + 1 -- dari 1x sampai 10x
		speedLabel.Text = "Speed: " .. speedMultiplier .. "x"
	end
end)
