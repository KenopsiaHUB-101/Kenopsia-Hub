-- ==========================================
-- KENOPSIA HUB - ULTIMATE VVIP (FULL FIXED + CLEAN TOGGLE BAR)
-- ==========================================

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- TEMA WARNA (THEMES)
local Themes = {
    Purple = { bg = Color3.fromRGB(13, 14, 18), card = Color3.fromRGB(20, 22, 29), accent = Color3.fromRGB(139, 92, 246), topbar = Color3.fromRGB(16, 17, 22) },
    Cyberpunk = { bg = Color3.fromRGB(10, 10, 20), card = Color3.fromRGB(15, 20, 35), accent = Color3.fromRGB(6, 182, 212), topbar = Color3.fromRGB(12, 15, 28) },
    Crimson = { bg = Color3.fromRGB(18, 10, 12), card = Color3.fromRGB(28, 15, 18), accent = Color3.fromRGB(244, 63, 94), topbar = Color3.fromRGB(22, 12, 14) },
    Emerald = { bg = Color3.fromRGB(10, 18, 14), card = Color3.fromRGB(15, 28, 20), accent = Color3.fromRGB(34, 197, 94), topbar = Color3.fromRGB(12, 22, 16) }
}
local C = Themes.Purple
local ActiveColor = Color3.fromRGB(34, 197, 94)
local InactiveColor = Color3.fromRGB(244, 63, 94)

local function getParent()
    local ok, cg = pcall(function() return CoreGui end)
    if ok and cg then return cg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local userName = LocalPlayer.Name
local displayName = LocalPlayer.DisplayName
local userId = LocalPlayer.UserId
local profilePicUrl = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&x=150&y=150"

startKenopsiaHUB = function()
    local zapFolder = ReplicatedStorage:WaitForChild("ZAP", 5)
    local merchantRemote = zapFolder and zapFolder:FindFirstChild("merchant_RELIABLE")
    local charmRemote = zapFolder and zapFolder:FindFirstChild("charm_RELIABLE")

    -- ITEM LISTS
    local partItemList = {
        "cube-t1", "wedge-t1", "stair-t1", "cornerWedge-t1", "cornerStair-t1",
        "pole-t1", "triangleWedge-t1", "invertedCornerWedge-t1", "invertedCornerStair-t1",
        "slab-t1", "basicWheel-t1", "utilityWheel-t1", "bigWheel-t1", "piston-t1",
        "spinner-t1", "hinge-t1", "rope-t1", "balloon-t1", "propeller-t1",
        "thruster-t1", "decoupler-t1", "rockLauncher-t1", "bumper-t1", "spike-t1",
        "sawblade-t1", "wrecker-t1", "tnt-t1"
    }

    local gardenItemList = {
        "basic-sprinkler", "advanced-sprinkler", "master-sprinkler",
        "structural-oil", "mechanical-oil", "combat-oil", "crateDrone"
    }

    local selectedItems = {}
    local itemCards = {}
    local autoBuyActive = false
    local smartStockActive = true
    local buyDelay = 0.2
    local serverStockCache = {}
    local bufferCache = {}
    local savedSchematic = {}

    -- TOGGLES MASTER TABLE
    local Toggles = {
        InfJump = false,
        Noclip = false,
        Fly = false,
        Esp = false,
        AutoCollect = false,
        AutoPlantHarvest = false,
        AutoResearch = false,
        AutoFarmCrush = false,
        AutoSellLowTier = false,
        SmartMerchantFilter = false,
        AutoSchematics = false,
        AutoWeld = false,
        AutoFlipVehicle = false,
        DebrisCleaner = false,
        AutoTPCrate = false
    }

    local walkSpeedValue = 16
    local defaultSpeed = 16
    local webhookUrl = ""

    local function getCleanDisplayName(rawName)
        local clean = rawName:gsub("(%l)(%u)", "%1 %2")
        clean = clean:gsub("%-t%d+", ""):gsub("%-", " ")
        return clean:gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
    end

    -- PRE-GENERATE BUFFERS FOR PARTS & GARDEN
    for _, itemName in ipairs(partItemList) do
        bufferCache[itemName] = buffer.fromstring(string.format("\0\6\0blocks%s\0%s", string.char(#itemName), itemName))
    end
    for _, itemName in ipairs(gardenItemList) do
        bufferCache[itemName] = buffer.fromstring(string.format("\0\6\0garden%s\0%s", string.char(#itemName), itemName))
    end

    -- WEBHOOK FUNCTION
    local function sendWebhook(msg)
        if webhookUrl == "" or not string.find(webhookUrl, "http") then return end
        local requestFunc = request or http_request or (syn and syn.request)
        if requestFunc then
            requestFunc({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({content = "⚡ **[KenopsiaHUB]**: " .. msg})
            })
        end
    end

    if charmRemote then
        charmRemote.OnClientEvent:Connect(function(header, data)
            if type(data) == "table" then
                for _, playerData in pairs(data) do
                    if type(playerData) == "table" then
                        for _, userBlocks in pairs(playerData) do
                            if userBlocks and userBlocks.blocks and userBlocks.blocks.items then
                                for _, itemInfo in pairs(userBlocks.blocks.items) do
                                    if itemInfo and itemInfo.stock and itemInfo.name then
                                        serverStockCache[itemInfo.name] = itemInfo.stock
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    local function checkServerStock(itemName)
        if not smartStockActive then return 999 end
        if serverStockCache[itemName] ~= nil and serverStockCache[itemName] <= 0 then return 0 end
        return 999
    end

    local function beliItem(itemName)
        if checkServerStock(itemName) <= 0 then return end
        if merchantRemote and bufferCache[itemName] then
            merchantRemote:FireServer(bufferCache[itemName], {})
            sendWebhook("Berhasil Auto Buy Item: " .. itemName)
        end
    end

    -- GUI ROOT
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "KenopsiaHUB_Ultimate_UI"
    MainGui.ResetOnSpawn = false
    MainGui.Parent = getParent()

    -- TOGGLE BUTTON (FLOATING ICON)
    local ToggleBall = Instance.new("TextButton")
    ToggleBall.Size = UDim2.new(0, 48, 0, 48)
    ToggleBall.Position = UDim2.new(0.02, 0, 0.25, 0)
    ToggleBall.BackgroundColor3 = C.card
    ToggleBall.Text = "⚡"
    ToggleBall.TextColor3 = C.accent
    ToggleBall.TextSize = 22
    ToggleBall.Font = Enum.Font.FredokaOne
    ToggleBall.Visible = false
    ToggleBall.ZIndex = 999
    ToggleBall.Parent = MainGui
    Instance.new("UICorner", ToggleBall).CornerRadius = UDim.new(1, 0)

    -- MAIN FRAME
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 640, 0, 470)
    MainFrame.Position = UDim2.new(0.5, -320, 0.5, -235)
    MainFrame.BackgroundColor3 = C.bg
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MainGui
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

    -- DRAGGABLE SYSTEM
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- TOP BAR
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 46); TopBar.BackgroundColor3 = C.topbar
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = "  ⚡ KENOPSIA <font color=\"rgb(139, 92, 246)\">HUB</font> [ULTIMATE VVIP]"
    Title.RichText = true; Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.BackgroundTransparency = 1; Title.TextColor3 = Color3.fromRGB(248, 250, 252)
    Title.TextSize = 15; Title.Font = Enum.Font.FredokaOne; Title.TextXAlignment = Enum.TextXAlignment.Left

    local HideBtn = Instance.new("TextButton", TopBar)
    HideBtn.Text = "✕"; HideBtn.Size = UDim2.new(0, 30, 0, 30); HideBtn.Position = UDim2.new(1, -38, 0.5, -15)
    HideBtn.BackgroundColor3 = C.card; HideBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
    HideBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 8)

    -- TAB HOLDER (NAVIGATION)
    local TabHolder = Instance.new("Frame", MainFrame)
    TabHolder.Size = UDim2.new(0, 140, 1, -46); TabHolder.Position = UDim2.new(0, 0, 0, 46)
    TabHolder.BackgroundColor3 = C.topbar

    local function createTabBtn(name, text, posIndex)
        local btn = Instance.new("TextButton", TabHolder)
        btn.Size = UDim2.new(0.86, 0, 0, 30); btn.Position = UDim2.new(0.07, 0, 0.015 + ((posIndex - 1) * 0.075), 0)
        btn.Text = text; btn.BackgroundColor3 = posIndex == 1 and C.accent or C.card
        btn.TextColor3 = Color3.fromRGB(248, 250, 252); btn.Font = Enum.Font.FredokaOne; btn.TextSize = 10
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        return btn
    end

    local ProfileTabBtn  = createTabBtn("Profile", "👤 Profile", 1)
    local ShopTabBtn     = createTabBtn("Shop", "🛒 Store", 2)
    local AutoTabBtn     = createTabBtn("Auto", "🌾 Auto Farm", 3)
    local BuildTabBtn    = createTabBtn("Build", "🛠️ Building", 4)
    local MiscTabBtn     = createTabBtn("Misc", "⚡ Player Misc", 5)
    local VisualTabBtn   = createTabBtn("Visual", "👁️ Visuals", 6)
    local TeleportTabBtn = createTabBtn("Teleport", "🌀 Teleport", 7)
    local SettingsTabBtn = createTabBtn("Settings", "⚙️ Settings", 8)

    -- CONTAINER HOLDER
    local ContainerHolder = Instance.new("Frame", MainFrame)
    ContainerHolder.Size = UDim2.new(1, -140, 1, -46); ContainerHolder.Position = UDim2.new(0, 140, 0, 46)
    ContainerHolder.BackgroundTransparency = 1

    -- UNIFIED TOGGLE SWITCH BAR COMPONENT
    local toggleButtonsRef = {}
    local function createToggleBar(parent, text, keyName, posIndex)
        local Bar = Instance.new("Frame", parent)
        Bar.Size = UDim2.new(0.92, 0, 0, 34); Bar.Position = UDim2.new(0.04, 0, 0.02 + ((posIndex - 1) * 0.105), 0)
        Bar.BackgroundColor3 = C.card
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 8)

        local Label = Instance.new("TextLabel", Bar)
        Label.Size = UDim2.new(0.65, 0, 1, 0); Label.Position = UDim2.new(0.03, 0, 0, 0)
        Label.BackgroundTransparency = 1; Label.Text = text
        Label.TextColor3 = Color3.fromRGB(248, 250, 252); Label.Font = Enum.Font.BuilderSansMedium
        Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left

        local SwitchBtn = Instance.new("TextButton", Bar)
        SwitchBtn.Size = UDim2.new(0, 85, 0, 24); SwitchBtn.Position = UDim2.new(1, -92, 0.5, -12)
        SwitchBtn.BackgroundColor3 = Toggles[keyName] and ActiveColor or InactiveColor
        SwitchBtn.Text = Toggles[keyName] and "ACTIVE" or "DISABLED"
        SwitchBtn.TextColor3 = Color3.fromRGB(255, 255, 255); SwitchBtn.Font = Enum.Font.FredokaOne; SwitchBtn.TextSize = 10
        Instance.new("UICorner", SwitchBtn).CornerRadius = UDim.new(0, 6)

        SwitchBtn.MouseButton1Click:Connect(function()
            Toggles[keyName] = not Toggles[keyName]
            local isON = Toggles[keyName]
            SwitchBtn.Text = isON and "ACTIVE" or "DISABLED"
            SwitchBtn.BackgroundColor3 = isON and ActiveColor or InactiveColor
        end)

        toggleButtonsRef[keyName] = { Button = SwitchBtn }
    end

    -- TAB 1: PROFILE & STATS
    local ProfileFrame = Instance.new("Frame", ContainerHolder)
    ProfileFrame.Size = UDim2.new(1, 0, 1, 0); ProfileFrame.BackgroundTransparency = 1

    local ProfileCard = Instance.new("Frame", ProfileFrame)
    ProfileCard.Size = UDim2.new(0.92, 0, 0, 140); ProfileCard.Position = UDim2.new(0.04, 0, 0.05, 0)
    ProfileCard.BackgroundColor3 = C.card
    Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 12)

    local AvatarImg = Instance.new("ImageLabel", ProfileCard)
    AvatarImg.Size = UDim2.new(0, 68, 0, 68); AvatarImg.Position = UDim2.new(0, 14, 0.15, 0)
    AvatarImg.Image = profilePicUrl; AvatarImg.BackgroundColor3 = C.bg
    Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

    local NameLabel = Instance.new("TextLabel", ProfileCard)
    NameLabel.Size = UDim2.new(0.65, 0, 0, 20); NameLabel.Position = UDim2.new(0, 94, 0, 12)
    NameLabel.BackgroundTransparency = 1; NameLabel.Text = displayName .. " (@" .. userName .. ")"
    NameLabel.TextColor3 = Color3.fromRGB(248, 250, 252); NameLabel.TextSize = 13; NameLabel.Font = Enum.Font.FredokaOne; NameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local StatsLabel = Instance.new("TextLabel", ProfileCard)
    StatsLabel.Size = UDim2.new(0.65, 0, 0, 60); StatsLabel.Position = UDim2.new(0, 94, 0, 36)
    StatsLabel.BackgroundTransparency = 1; StatsLabel.Text = "📊 Ping: Calculating...\n🎮 FPS: Calculating...\n⏱️ Server Uptime: 0s"
    StatsLabel.TextColor3 = Color3.fromRGB(148, 163, 184); StatsLabel.TextSize = 11; StatsLabel.Font = Enum.Font.BuilderSansMedium; StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        local startTime = os.time()
        local frameCount = 0; local lastFpsCheck = tick(); local currentFps = 60
        RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            if tick() - lastFpsCheck >= 1 then currentFps = frameCount; frameCount = 0; lastFpsCheck = tick() end
        end)
        while task.wait(0.5) do
            local ping = math.floor(workspace:GetRealPhysicsFPS())
            local uptime = os.time() - startTime
            StatsLabel.Text = string.format("📊 Ping: %d ms\n🎮 FPS: %d\n⏱️ Server Uptime: %ds", ping, currentFps, uptime)
        end
    end)

    -- TAB 2: SHOP (STORE FOR PARTS & GARDEN)
    local ShopFrame = Instance.new("Frame", ContainerHolder)
    ShopFrame.Size = UDim2.new(1, 0, 1, 0); ShopFrame.BackgroundTransparency = 1; ShopFrame.Visible = false

    local PartShopBtn = Instance.new("TextButton", ShopFrame)
    PartShopBtn.Size = UDim2.new(0.44, 0, 0, 28); PartShopBtn.Position = UDim2.new(0.04, 0, 0.03, 0)
    PartShopBtn.Text = "Parts"; PartShopBtn.BackgroundColor3 = C.accent; PartShopBtn.TextColor3 = Color3.fromRGB(248, 250, 252)
    PartShopBtn.Font = Enum.Font.FredokaOne; PartShopBtn.TextSize = 11
    Instance.new("UICorner", PartShopBtn).CornerRadius = UDim.new(0, 8)

    local GardenShopBtn = Instance.new("TextButton", ShopFrame)
    GardenShopBtn.Size = UDim2.new(0.44, 0, 0, 28); GardenShopBtn.Position = UDim2.new(0.52, 0, 0.03, 0)
    GardenShopBtn.Text = "Garden"; GardenShopBtn.BackgroundColor3 = C.card; GardenShopBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
    GardenShopBtn.Font = Enum.Font.FredokaOne; GardenShopBtn.TextSize = 11
    Instance.new("UICorner", GardenShopBtn).CornerRadius = UDim.new(0, 8)

    local AutoBuyToggle = Instance.new("TextButton", ShopFrame)
    AutoBuyToggle.Size = UDim2.new(0.92, 0, 0, 32); AutoBuyToggle.Position = UDim2.new(0.04, 0, 0.13, 0)
    AutoBuyToggle.BackgroundColor3 = InactiveColor; AutoBuyToggle.Text = "⚡ AUTO BUY: DISABLED"
    AutoBuyToggle.TextColor3 = Color3.fromRGB(248, 250, 252); AutoBuyToggle.Font = Enum.Font.FredokaOne; AutoBuyToggle.TextSize = 11
    Instance.new("UICorner", AutoBuyToggle).CornerRadius = UDim.new(0, 8)

    local function createItemCard(rawItemName, parentScroll)
        local displayNameClean = getCleanDisplayName(rawItemName)
        local ItemFrame = Instance.new("Frame", parentScroll)
        ItemFrame.Size = UDim2.new(0.96, 0, 0, 32); ItemFrame.BackgroundColor3 = C.card
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 8)

        local ItemBtn = Instance.new("TextButton", ItemFrame)
        ItemBtn.Size = UDim2.new(1, 0, 1, 0); ItemBtn.BackgroundTransparency = 1
        ItemBtn.Text = "  " .. displayNameClean; ItemBtn.TextColor3 = Color3.fromRGB(248, 250, 252); ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
        ItemBtn.Font = Enum.Font.BuilderSansMedium; ItemBtn.TextSize = 12

        local function updateState(state)
            selectedItems[rawItemName] = state
            ItemFrame.BackgroundColor3 = state and C.accent or C.card
        end

        ItemBtn.MouseButton1Click:Connect(function() updateState(not selectedItems[rawItemName]) end)
        itemCards[rawItemName] = { Frame = ItemFrame, Update = updateState }
    end

    local ScrollParts = Instance.new("ScrollingFrame", ShopFrame)
    ScrollParts.Size = UDim2.new(0.92, 0, 0.7, 0); ScrollParts.Position = UDim2.new(0.04, 0, 0.25, 0); ScrollParts.BackgroundTransparency = 1
    ScrollParts.CanvasSize = UDim2.new(0, 0, 0, #partItemList * 36); ScrollParts.ScrollBarThickness = 3
    Instance.new("UIListLayout", ScrollParts).Padding = UDim.new(0, 4)
    for _, itemName in ipairs(partItemList) do createItemCard(itemName, ScrollParts) end

    local ScrollGarden = Instance.new("ScrollingFrame", ShopFrame)
    ScrollGarden.Size = UDim2.new(0.92, 0, 0.7, 0); ScrollGarden.Position = UDim2.new(0.04, 0, 0.25, 0); ScrollGarden.BackgroundTransparency = 1
    ScrollGarden.CanvasSize = UDim2.new(0, 0, 0, #gardenItemList * 36); ScrollGarden.ScrollBarThickness = 3; ScrollGarden.Visible = false
    Instance.new("UIListLayout", ScrollGarden).Padding = UDim.new(0, 4)
    for _, itemName in ipairs(gardenItemList) do createItemCard(itemName, ScrollGarden) end

    -- TAB 3: AUTOMATION
    local AutoFrame = Instance.new("Frame", ContainerHolder)
    AutoFrame.Size = UDim2.new(1, 0, 1, 0); AutoFrame.BackgroundTransparency = 1; AutoFrame.Visible = false

    createToggleBar(AutoFrame, "🌱 Auto Plant & Harvest Crates", "AutoPlantHarvest", 1)
    createToggleBar(AutoFrame, "🔬 Auto Research Garage", "AutoResearch", 2)
    createToggleBar(AutoFrame, "💥 Auto Farm Map Destruction", "AutoFarmCrush", 3)
    createToggleBar(AutoFrame, "💰 Auto Sell Low Tier (T1 Parts)", "AutoSellLowTier", 4)
    createToggleBar(AutoFrame, "🛒 Smart Merchant Filter (T2+)", "SmartMerchantFilter", 5)

    -- TAB 4: BUILDING
    local BuildFrame = Instance.new("Frame", ContainerHolder)
    BuildFrame.Size = UDim2.new(1, 0, 1, 0); BuildFrame.BackgroundTransparency = 1; BuildFrame.Visible = false

    createToggleBar(BuildFrame, "💾 Save/Load Build Schematics (.json)", "AutoSchematics", 1)
    createToggleBar(BuildFrame, "🔄 Mass Part Duplicator / Fast Weld", "AutoWeld", 2)

    -- TAB 5: PLAYER MISC
    local MiscFrame = Instance.new("ScrollingFrame", ContainerHolder)
    MiscFrame.Size = UDim2.new(1, 0, 1, 0); MiscFrame.BackgroundTransparency = 1; MiscFrame.Visible = false
    MiscFrame.CanvasSize = UDim2.new(0, 0, 0, 480); MiscFrame.ScrollBarThickness = 3

    local SpeedLabel = Instance.new("TextLabel", MiscFrame)
    SpeedLabel.Size = UDim2.new(0.92, 0, 0, 18); SpeedLabel.Position = UDim2.new(0.04, 0, 0.01, 0)
    SpeedLabel.BackgroundTransparency = 1; SpeedLabel.Text = "🏃 Speedwalk: 16 (Default: 0/16)"
    SpeedLabel.TextColor3 = Color3.fromRGB(248, 250, 252); SpeedLabel.Font = Enum.Font.FredokaOne; SpeedLabel.TextSize = 11; SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SliderFrame = Instance.new("Frame", MiscFrame)
    SliderFrame.Size = UDim2.new(0.92, 0, 0, 14); SliderFrame.Position = UDim2.new(0.04, 0, 0.05, 0)
    SliderFrame.BackgroundColor3 = C.card
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

    local SliderFill = Instance.new("Frame", SliderFrame)
    SliderFill.Size = UDim2.new(16/100, 0, 1, 0); SliderFill.BackgroundColor3 = C.accent
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 8)

    local SliderBtn = Instance.new("TextButton", SliderFrame)
    SliderBtn.Size = UDim2.new(1, 0, 1, 0); SliderBtn.BackgroundTransparency = 1; SliderBtn.Text = ""

    local sliding = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
        local val = math.floor(pos * 100)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        walkSpeedValue = val == 0 and defaultSpeed or val
        SpeedLabel.Text = "🏃 Speedwalk: " .. tostring(val) .. (val == 0 and " (Default)" or "")
    end
    SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; updateSlider(input) end end)
    SliderBtn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
    UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end end)

    createToggleBar(MiscFrame, "🕊️ Fly (Press F Hotkey)", "Fly", 2)
    createToggleBar(MiscFrame, "🦘 Infinite Jump", "InfJump", 3)
    createToggleBar(MiscFrame, "👻 Noclip (Press N Hotkey)", "Noclip", 4)
    createToggleBar(MiscFrame, "🧲 Auto Collect Drop Items", "AutoCollect", 5)
    createToggleBar(MiscFrame, "🏎️ Vehicle Flip Helper (Anti-Stuck)", "AutoFlipVehicle", 6)
    createToggleBar(MiscFrame, "🧹 Physics Debris Cleaner (Anti-Lag)", "DebrisCleaner", 7)

    -- HOTKEYS (F = FLY, N = NOCLIP)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F then
            Toggles.Fly = not Toggles.Fly
            if toggleButtonsRef["Fly"] then
                toggleButtonsRef["Fly"].Button.Text = Toggles.Fly and "ACTIVE" or "DISABLED"
                toggleButtonsRef["Fly"].Button.BackgroundColor3 = Toggles.Fly and ActiveColor or InactiveColor
            end
        elseif input.KeyCode == Enum.KeyCode.N then
            Toggles.Noclip = not Toggles.Noclip
            if toggleButtonsRef["Noclip"] then
                toggleButtonsRef["Noclip"].Button.Text = Toggles.Noclip and "ACTIVE" or "DISABLED"
                toggleButtonsRef["Noclip"].Button.BackgroundColor3 = Toggles.Noclip and ActiveColor or InactiveColor
            end
        end
    end)

    -- TAB 6: VISUALS (ESP)
    local VisualFrame = Instance.new("Frame", ContainerHolder)
    VisualFrame.Size = UDim2.new(1, 0, 1, 0); VisualFrame.BackgroundTransparency = 1; VisualFrame.Visible = false

    createToggleBar(VisualFrame, "👁️ Player ESP (Boxes & Names)", "Esp", 1)

    RunService.RenderStepped:Connect(function()
        if not Toggles.Esp then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                if not hrp:FindFirstChild("ESPGui") then
                    local bgui = Instance.new("BillboardGui", hrp)
                    bgui.Name = "ESPGui"; bgui.AlwaysOnTop = true; bgui.Size = UDim2.new(0, 100, 0, 40); bgui.StudsOffset = Vector3.new(0, 3, 0)
                    local txt = Instance.new("TextLabel", bgui)
                    txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.Text = plr.DisplayName
                    txt.TextColor3 = ActiveColor; txt.Font = Enum.Font.FredokaOne; txt.TextSize = 12
                end
            end
        end
    end)

    -- TAB 7: TELEPORT & SERVER HOP
    local TeleportFrame = Instance.new("Frame", ContainerHolder)
    TeleportFrame.Size = UDim2.new(1, 0, 1, 0); TeleportFrame.BackgroundTransparency = 1; TeleportFrame.Visible = false

    local function createActionBtn(parent, text, posScaleY, onClick)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0.92, 0, 0, 32); btn.Position = UDim2.new(0.04, 0, posScaleY, 0)
        btn.BackgroundColor3 = C.card; btn.Text = text; btn.TextColor3 = Color3.fromRGB(248, 250, 252)
        btn.Font = Enum.Font.FredokaOne; btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(onClick)
    end

    createToggleBar(TeleportFrame, "📦 Auto Teleport to Crate Drops", "AutoTPCrate", 1)

    createActionBtn(TeleportFrame, "📍 Teleport to Safe Zone", 0.17, function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
        end
    end)

    createActionBtn(TeleportFrame, "🔄 Rejoin Current Server", 0.28, function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)

    createActionBtn(TeleportFrame, "🌐 Server Hop (Random Server)", 0.39, function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    -- TAB 8: SETTINGS
    local SettingsFrame = Instance.new("ScrollingFrame", ContainerHolder)
    SettingsFrame.Size = UDim2.new(1, 0, 1, 0); SettingsFrame.BackgroundTransparency = 1; SettingsFrame.Visible = false
    SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, 420); SettingsFrame.ScrollBarThickness = 3

    createActionBtn(SettingsFrame, "🚀 Enable FPS Booster (Remove Lag)", 0.02, function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
        Lighting.GlobalShadows = false
    end)

    createActionBtn(SettingsFrame, "💾 Save Config (.json)", 0.12, function()
        if writefile then
            writefile("KenopsiaConfig.json", HttpService:JSONEncode(selectedItems))
        end
    end)

    createActionBtn(SettingsFrame, "📂 Load Config (.json)", 0.22, function()
        if readfile and isfile and isfile("KenopsiaConfig.json") then
            local data = HttpService:JSONDecode(readfile("KenopsiaConfig.json"))
            for itemName, state in pairs(data) do
                if itemCards[itemName] then itemCards[itemName].Update(state) end
            end
        end
    end)

    local WebhookInput = Instance.new("TextBox", SettingsFrame)
    WebhookInput.Size = UDim2.new(0.92, 0, 0, 32); WebhookInput.Position = UDim2.new(0.04, 0, 0.32, 0)
    WebhookInput.BackgroundColor3 = C.card; WebhookInput.PlaceholderText = "🔗 Paste Discord Webhook URL..."
    WebhookInput.TextColor3 = Color3.fromRGB(248, 250, 252); WebhookInput.Font = Enum.Font.BuilderSansMedium; WebhookInput.TextSize = 11
    Instance.new("UICorner", WebhookInput).CornerRadius = UDim.new(0, 8)
    WebhookInput.FocusLost:Connect(function() webhookUrl = WebhookInput.Text end)

    local ThemeLabel = Instance.new("TextLabel", SettingsFrame)
    ThemeLabel.Size = UDim2.new(0.92, 0, 0, 20); ThemeLabel.Position = UDim2.new(0.04, 0, 0.43, 0)
    ThemeLabel.BackgroundTransparency = 1; ThemeLabel.Text = "🎨 Select UI Theme:"
    ThemeLabel.TextColor3 = Color3.fromRGB(248, 250, 252); ThemeLabel.Font = Enum.Font.FredokaOne; ThemeLabel.TextSize = 12; ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local function applyTheme(themeObj)
        C = themeObj
        MainFrame.BackgroundColor3 = C.bg
        TopBar.BackgroundColor3 = C.topbar
        TabHolder.BackgroundColor3 = C.topbar
        ToggleBall.TextColor3 = C.accent
    end

    createActionBtn(SettingsFrame, "🟣 Purple Theme", 0.49, function() applyTheme(Themes.Purple) end)
    createActionBtn(SettingsFrame, "🔵 Cyberpunk Theme", 0.58, function() applyTheme(Themes.Cyberpunk) end)
    createActionBtn(SettingsFrame, "🔴 Crimson Theme", 0.67, function() applyTheme(Themes.Crimson) end)
    createActionBtn(SettingsFrame, "🟢 Emerald Theme", 0.76, function() applyTheme(Themes.Emerald) end)

    -- EVENT SWITCH TABS LOGIC
    local function hideAllFrames()
        ProfileFrame.Visible = false; ShopFrame.Visible = false
        AutoFrame.Visible = false; BuildFrame.Visible = false
        MiscFrame.Visible = false; VisualFrame.Visible = false
        TeleportFrame.Visible = false; SettingsFrame.Visible = false
        ProfileTabBtn.BackgroundColor3 = C.card; ShopTabBtn.BackgroundColor3 = C.card
        AutoTabBtn.BackgroundColor3 = C.card; BuildTabBtn.BackgroundColor3 = C.card
        MiscTabBtn.BackgroundColor3 = C.card; VisualTabBtn.BackgroundColor3 = C.card
        TeleportTabBtn.BackgroundColor3 = C.card; SettingsTabBtn.BackgroundColor3 = C.card
    end

    ProfileTabBtn.MouseButton1Click:Connect(function() hideAllFrames(); ProfileFrame.Visible = true; ProfileTabBtn.BackgroundColor3 = C.accent end)
    ShopTabBtn.MouseButton1Click:Connect(function() hideAllFrames(); ShopFrame.Visible = true; ShopTabBtn.BackgroundColor3 = C.accent end)
    AutoTabBtn.MouseButton1Click:Connect(function() hideAllFrames(); AutoFrame.Visible = true; AutoTabBtn.BackgroundColor3 = C.accent end)
    BuildTabBtn.MouseButton1Click:Connect(function() hideAllFrames(); BuildFrame.Visible = true; BuildTabBtn.BackgroundColor3 = C.accent end)
    MiscTabBtn.MouseButton1Click:Connect(function() hideAllFrames(); MiscFrame.Visible = true; MiscTabBtn.BackgroundColor3 = C.accent end)
    VisualTabBtn.MouseButton1Click:Connect(function() hideAllFrames(); VisualFrame.Visible = true; VisualTabBtn.BackgroundColor3 = C.accent end)
    TeleportTabBtn.MouseButton1Click:Connect(function() hideAllFrames(); TeleportFrame.Visible = true; TeleportTabBtn.BackgroundColor3 = C.accent end)
    SettingsTabBtn.MouseButton1Click:Connect(function() hideAllFrames(); SettingsFrame.Visible = true; SettingsTabBtn.BackgroundColor3 = C.accent end)

    PartShopBtn.MouseButton1Click:Connect(function() ScrollParts.Visible = true; ScrollGarden.Visible = false; PartShopBtn.BackgroundColor3 = C.accent; GardenShopBtn.BackgroundColor3 = C.card end)
    GardenShopBtn.MouseButton1Click:Connect(function() ScrollParts.Visible = false; ScrollGarden.Visible = true; GardenShopBtn.BackgroundColor3 = C.accent; PartShopBtn.BackgroundColor3 = C.card end)

    AutoBuyToggle.MouseButton1Click:Connect(function()
        autoBuyActive = not autoBuyActive
        AutoBuyToggle.Text = "⚡ AUTO BUY: " .. (autoBuyActive and "ACTIVE" or "DISABLED")
        AutoBuyToggle.BackgroundColor3 = autoBuyActive and ActiveColor or InactiveColor
    end)

    HideBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; ToggleBall.Visible = true end)
    ToggleBall.MouseButton1Click:Connect(function() MainFrame.Visible = true; ToggleBall.Visible = false end)

      -- BACKGROUND BACKEND LOOPS

    -- INF JUMP & NOCLIP & SPEED
    UserInputService.JumpRequest:Connect(function()
        if Toggles.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    RunService.Stepped:Connect(function()
        if Toggles.Noclip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if LocalPlayer.Character.Humanoid.WalkSpeed ~= walkSpeedValue then
                LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
            end
        end
    end)

    -- AUTO COLLECT
    task.spawn(function()
        while task.wait(0.5) do
            if Toggles.AutoCollect and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, item in pairs(workspace:GetChildren()) do
                    if item:IsA("TouchTransmitter") or item:FindFirstChild("TouchInterest") then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, item.Parent, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, item.Parent, 1)
                    end
                end
            end
        end
    end)

    -- AUTO BUY LOOP (EXPLICIT FOR PARTS & GARDEN)
    task.spawn(function()
        while true do
            task.wait(buyDelay)
            if autoBuyActive then
                for itemName, isSelected in pairs(selectedItems) do
                    if isSelected then 
                        task.spawn(function() 
                            beliItem(itemName) 
                        end) 
                    end
                end
            end
        end
    end)

    -- AUTO PLANT & HARVEST
    task.spawn(function()
        while task.wait(1) do
            if Toggles.AutoPlantHarvest then
                for _, plant in pairs(workspace:GetDescendants()) do
                    if plant:IsA("ProximityPrompt") then fireproximityprompt(plant) end
                    if plant:IsA("ClickDetector") then fireclickdetector(plant) end
                end
            end
        end
    end)

    -- AUTO RESEARCH
    task.spawn(function()
        while task.wait(3) do
            if Toggles.AutoResearch and charmRemote then
                charmRemote:FireServer("ResearchGarage", {})
            end
        end
    end)

    -- AUTO FARM CRUSH
    task.spawn(function()
        while task.wait(0.5) do
            if Toggles.AutoFarmCrush and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, target in pairs(workspace:GetChildren()) do
                    if target:IsA("Model") and target:FindFirstChild("Humanoid") and target.Name ~= LocalPlayer.Name then
                        target.Humanoid:TakeDamage(10)
                    end
                end
            end
        end
    end)

    -- AUTO SELL LOW TIER
    task.spawn(function()
        while task.wait(2) do
            if Toggles.AutoSellLowTier and merchantRemote then
                local lowTierParts = {"cube-t1", "wedge-t1", "stair-t1", "cornerWedge-t1"}
                for _, item in ipairs(lowTierParts) do
                    local buf = buffer.fromstring(string.format("\0\6\0sell%s\0%s", string.char(#item), item))
                    merchantRemote:FireServer(buf, {})
                end
            end
        end
    end)

    -- SMART MERCHANT FILTER
    task.spawn(function()
        while task.wait(1) do
            if Toggles.SmartMerchantFilter and merchantRemote then
                local item = "master-sprinkler"
                local buf = buffer.fromstring(string.format("\0\6\0garden%s\0%s", string.char(#item), item))
                merchantRemote:FireServer(buf, {})
            end
        end
    end)

    -- AUTO SCHEMATICS
    task.spawn(function()
        while task.wait(5) do
            if Toggles.AutoSchematics and LocalPlayer.Character then
                savedSchematic = {}
                for _, obj in pairs(LocalPlayer.Character:GetChildren()) do
                    if obj:IsA("BasePart") then
                        table.insert(savedSchematic, {Name = obj.Name, Size = tostring(obj.Size), Position = tostring(obj.Position)})
                    end
                end
                if writefile then writefile("BuildSchematic.json", HttpService:JSONEncode(savedSchematic)) end
            end
        end
    end)

    -- AUTO WELD
    task.spawn(function()
        while task.wait(1) do
            if Toggles.AutoWeld and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, p in pairs(LocalPlayer.Character:GetChildren()) do
                    if p:IsA("BasePart") and p ~= LocalPlayer.Character.HumanoidRootPart and not p:FindFirstChildOfClass("WeldConstraint") then
                        local weld = Instance.new("WeldConstraint", p)
                        weld.Part0 = p
                        weld.Part1 = LocalPlayer.Character.HumanoidRootPart
                    end
                end
            end
        end
    end)

    -- AUTO FLIP VEHICLE
    RunService.Stepped:Connect(function()
        if Toggles.AutoFlipVehicle and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if hrp.CFrame.UpVector.Y < -0.5 then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.pi)
            end
        end
    end)

    -- DEBRIS CLEANER
    task.spawn(function()
        while task.wait(2) do
            if Toggles.DebrisCleaner then
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("BasePart") and not v.Anchored and v.Size.Magnitude < 4 and not v:IsDescendantOf(LocalPlayer.Character) then
                        v:Destroy()
                    end
                end
            end
        end
    end)

    -- AUTO TP CRATE
    task.spawn(function()
        while task.wait(2) do
            if Toggles.AutoTPCrate and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (string.find(v.Name:lower(), "crate") or string.find(v.Name:lower(), "drop")) then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                        break
                    end
                end
            end
        end
    end)
end

startKenopsiaHUB()
