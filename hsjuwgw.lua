--// Fishing Toolkit V8 - Final Stable with Player Teleport
if game.CoreGui:FindFirstChild("FishingToolkitV8") then
    game.CoreGui.FishingToolkitV8:Destroy()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Teleport data
local filePath = "TeleportData.json"
local savedAreas = {}
if isfile and isfile(filePath) then
    local data = readfile(filePath)
    if data and data ~= "" then
        local success, decoded = pcall(function() return HttpService:JSONDecode(data) end)
        if success then savedAreas = decoded end
    end
end

-- Remotes
local RFChargeFishingRod = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
local RFRequestFishingMinigameStarted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]
local REFishingCompleted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]
local RFSellAllItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FishingToolkitV8"
gui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0,550,0,480)
main.Position = UDim2.new(0.25,0,0.15,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BackgroundTransparency = 0.25
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-100,0,40)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "🎣 Fishing Toolkit V8"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- Hide & Close
local hide = Instance.new("TextButton", main)
hide.Size = UDim2.new(0,60,0,30)
hide.Position = UDim2.new(1,-110,0,7)
hide.Text = "Hide"
hide.BackgroundColor3 = Color3.fromRGB(70,70,255)
hide.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", hide)

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,35,0,35)
close.Position = UDim2.new(1,-45,0,5)
close.Text = "✖"
close.BackgroundColor3 = Color3.fromRGB(255,70,70)
close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

hide.MouseButton1Click:Connect(function()
    main.Visible = false
    local show = Instance.new("TextButton", gui)
    show.Size = UDim2.new(0,100,0,40)
    show.Position = UDim2.new(0.02,0,0.85,0)
    show.Text = "Show GUI"
    show.BackgroundColor3 = Color3.fromRGB(70,70,255)
    show.TextColor3 = Color3.new(1,1,1)
    show.Font = Enum.Font.GothamBold
    Instance.new("UICorner", show)
    show.MouseButton1Click:Connect(function()
        main.Visible = true
        show:Destroy()
    end)
end)

-- Sidebar & Tabs
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0,150,1,-50)
sidebar.Position = UDim2.new(0,5,0,45)
sidebar.BackgroundTransparency = 1

local tabs = {"Player","Auto","Area Manager","Utilities","Player Teleport"}
local currentTab
local tabFrames = {}
local function createTab(name)
    local tab = Instance.new("ScrollingFrame", main)
    tab.Name = name.."Tab"
    tab.Size = UDim2.new(1,-160,1,-50)
    tab.Position = UDim2.new(0,150,0,50)
    tab.BackgroundTransparency = 1
    tab.Visible = false
    tab.CanvasSize = UDim2.new(0,0,0,500)
    tab.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tab.ScrollBarThickness = 6
    tabFrames[name] = tab
    return tab
end

for i,name in ipairs(tabs) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1,-10,0,40)
    btn.Position = UDim2.new(0,5,0,(i-1)*45)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextSize = 16
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        if currentTab then currentTab.Visible = false end
        tabFrames[name].Visible = true
        currentTab = tabFrames[name]
    end)
end

-- ========================= PLAYER TAB =========================
local playerTab = createTab("Player")
local speedBox = Instance.new("TextBox", playerTab)
speedBox.Size = UDim2.new(0,100,0,30)
speedBox.Position = UDim2.new(0,0,0,10)
speedBox.PlaceholderText = "WalkSpeed (16)"
speedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", speedBox)
speedBox.FocusLost:Connect(function()
    local v = tonumber(speedBox.Text)
    if v then hum.WalkSpeed = v end
end)

local jumpBox = Instance.new("TextBox", playerTab)
jumpBox.Size = UDim2.new(0,100,0,30)
jumpBox.Position = UDim2.new(0,0,0,50)
jumpBox.PlaceholderText = "JumpPower (50)"
jumpBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
jumpBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", jumpBox)
jumpBox.FocusLost:Connect(function()
    local v = tonumber(jumpBox.Text)
    if v then hum.JumpPower = v end
end)

local timeBox = Instance.new("TextBox", playerTab)
timeBox.Size = UDim2.new(0,100,0,30)
timeBox.Position = UDim2.new(0,0,0,90)
timeBox.PlaceholderText = "TimeSpeed (1)"
timeBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
timeBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", timeBox)
timeBox.FocusLost:Connect(function()
    local v = tonumber(timeBox.Text)
    if v and v > 0 then
        workspace:SetPhysicsSteppingMethod(Enum.PhysicsSteppingMethod.Fixed)
        workspace.PhysicsSimulationRate = v
    end
end)

-- ========================= AUTO TAB =========================
local autoTab = createTab("Auto")
local autoFish = false
local autoSell = false
local fishBtn = Instance.new("TextButton", autoTab)
fishBtn.Text = "🎣 Auto Instant Fishing (OFF)"
fishBtn.Size = UDim2.new(0,250,0,40)
fishBtn.Position = UDim2.new(0,0,0,10)
fishBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
fishBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", fishBtn)
fishBtn.MouseButton1Click:Connect(function()
    autoFish = not autoFish
    fishBtn.Text = autoFish and "🎣 Auto Instant Fishing (ON)" or "🎣 Auto Instant Fishing (OFF)"
    task.spawn(function()
        while autoFish do
            RFChargeFishingRod:InvokeServer(workspace:GetServerTimeNow())
            RFRequestFishingMinigameStarted:InvokeServer(0.5,0.9)
            REFishingCompleted:FireServer()
            task.wait(0.1)
        end
    end)
end)

local delayBox = Instance.new("TextBox", autoTab)
delayBox.Size = UDim2.new(0,100,0,30)
delayBox.Position = UDim2.new(0,0,0,60)
delayBox.PlaceholderText = "Delay Sell (s)"
delayBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
delayBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", delayBox)

local sellBtn = Instance.new("TextButton", autoTab)
sellBtn.Text = "💰 Auto Sell (OFF)"
sellBtn.Size = UDim2.new(0,180,0,40)
sellBtn.Position = UDim2.new(0,110,0,60)
sellBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
sellBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", sellBtn)
sellBtn.MouseButton1Click:Connect(function()
    autoSell = not autoSell
    sellBtn.Text = autoSell and "💰 Auto Sell (ON)" or "💰 Auto Sell (OFF)"
    task.spawn(function()
        while autoSell do
            local d = tonumber(delayBox.Text) or 30
            RFSellAllItems:InvokeServer()
            task.wait(d)
        end
    end)
end)

-- ========================= AREA MANAGER =========================
local areaTab = createTab("Area Manager")
local freezeArea = false
local frozenPosition

local saveBtn = Instance.new("TextButton", areaTab)
saveBtn.Text = "💾 Save Area"
saveBtn.Size = UDim2.new(0,140,0,35)
saveBtn.Position = UDim2.new(0,0,0,10)
saveBtn.BackgroundColor3 = Color3.fromRGB(0,140,255)
saveBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", saveBtn)

local areaList = Instance.new("ScrollingFrame", areaTab)
areaList.Size = UDim2.new(1,-20,0,250)
areaList.Position = UDim2.new(0,0,0,55)
areaList.BackgroundTransparency = 0.9
areaList.CanvasSize = UDim2.new(0,0,0,500)
areaList.AutomaticCanvasSize = Enum.AutomaticSize.Y
areaList.ScrollBarThickness = 6

local function refreshAreaList()
    areaList:ClearAllChildren()
    for i,pos in ipairs(savedAreas) do
        local btn = Instance.new("Frame", areaList)
        btn.Size = UDim2.new(1,0,0,40)
        btn.Position = UDim2.new(0,0,0,(i-1)*45)
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        Instance.new("UICorner", btn)
        local txt = Instance.new("TextLabel", btn)
        txt.Size = UDim2.new(0.5,0,1,0)
        txt.Position = UDim2.new(0,5,0,0)
        txt.BackgroundTransparency = 1
        txt.Text = "Area "..i.." | X:"..math.floor(pos.X).." Y:"..math.floor(pos.Y).." Z:"..math.floor(pos.Z)
        txt.TextColor3 = Color3.new(1,1,1)
        txt.TextScaled = true

        local tpBtn = Instance.new("TextButton", btn)
        tpBtn.Size = UDim2.new(0.15,0,1,0)
        tpBtn.Position = UDim2.new(0.5,0,0,0)
        tpBtn.Text = "Go"
        tpBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        tpBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", tpBtn)
        tpBtn.MouseButton1Click:Connect(function()
            hrp.CFrame = CFrame.new(pos)
        end)

        local freezeBtn = Instance.new("TextButton", btn)
        freezeBtn.Size = UDim2.new(0.15,0,1,0)
        freezeBtn.Position = UDim2.new(0.65,0,0,0)
        freezeBtn.Text = "Freeze"
        freezeBtn.BackgroundColor3 = Color3.fromRGB(255,150,0)
        freezeBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", freezeBtn)
        freezeBtn.MouseButton1Click:Connect(function()
            frozenPosition = pos
            freezeArea = true
        end)

        local delBtn = Instance.new("TextButton", btn)
        delBtn.Size = UDim2.new(0.2,0,1,0)
        delBtn.Position = UDim2.new(0.8,0,0,0)
        delBtn.Text = "Delete"
        delBtn.BackgroundColor3 = Color3.fromRGB(255,70,70)
        delBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", delBtn)
        delBtn.MouseButton1Click:Connect(function()
            table.remove(savedAreas,i)
            if writefile then writefile(filePath,HttpService:JSONEncode(savedAreas)) end
            refreshAreaList()
        end)
    end
end

saveBtn.MouseButton1Click:Connect(function()
    table.insert(savedAreas,hrp.Position)
    if writefile then writefile(filePath,HttpService:JSONEncode(savedAreas)) end
    refreshAreaList()
end)

refreshAreaList()

RunService.RenderStepped:Connect(function()
    if freezeArea and frozenPosition then
        hrp.CFrame = CFrame.new(frozenPosition)
    end
end)


-- ========================= PLAYER TELEPORT =========================
local playerTabTP = createTab("Player Teleport")
local playerList = Instance.new("ScrollingFrame", playerTabTP)
playerList.Size = UDim2.new(1,-20,1,0)
playerList.Position = UDim2.new(0,0,0,0)
playerList.BackgroundTransparency = 0.9
playerList.CanvasSize = UDim2.new(0,0,0,500)
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.ScrollBarThickness = 6

local function refreshPlayerList()
    playerList:ClearAllChildren()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton", playerList)
            btn.Size = UDim2.new(1,0,0,40)
            btn.Position = UDim2.new(0,0,0,(_-1)*45)
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Text = plr.Name
            Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = plr.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- ========================= UTILITIES =========================
local utilTab = createTab("Utilities")
local antiBtn = Instance.new("TextButton", utilTab)
antiBtn.Text = "🛡️ Anti AFK (OFF)"
antiBtn.Size = UDim2.new(0,180,0,40)
antiBtn.Position = UDim2.new(0,0,0,10)
antiBtn.BackgroundColor3 = Color3.fromRGB(200,200,70)
antiBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", antiBtn)

local anti = false
antiBtn.MouseButton1Click:Connect(function()
    anti = not anti
    antiBtn.Text = anti and "🟢 Anti AFK (ON)" or "🛡️ Anti AFK (OFF)"
    task.spawn(function()
        while anti do
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            task.wait(60)
        end
    end)
end)

-- Freeze Area

local freezeActive = false
FreezeButton.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	freezeActive = not freezeActive
	if freezeActive then
		root.Anchored = true
		FreezeButton.Text = "🧊 Freeze Area (ON)"
	else
		root.Anchored = false
		FreezeButton.Text = "🧊 Freeze Area (OFF)"
	end
end)

-- Default tab
currentTab = playerTab
playerTab.Visible = true
