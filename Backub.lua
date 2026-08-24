-- ==========================================
-- KENOPSIA HUB - ULTRA MODERN GLASS EDITION
-- ==========================================

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. MODERN COLOR PALETTE
local C = {
    bg        = Color3.fromRGB(13, 14, 18),
    card      = Color3.fromRGB(20, 22, 29),
    cardHover = Color3.fromRGB(28, 30, 40),
    topbar    = Color3.fromRGB(16, 17, 22),
    accent    = Color3.fromRGB(139, 92, 246), -- Violet
    accentG   = Color3.fromRGB(168, 85, 247),
    cyan      = Color3.fromRGB(6, 182, 212),
    border    = Color3.fromRGB(38, 42, 55),
    borderActive = Color3.fromRGB(124, 58, 237),
    text      = Color3.fromRGB(248, 250, 252),
    muted     = Color3.fromRGB(148, 163, 184),
    success   = Color3.fromRGB(34, 197, 94),
    danger    = Color3.fromRGB(244, 63, 94)
}

local function getParent()
    local ok, cg = pcall(function() return CoreGui end)
    if ok and cg then return cg end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

startKenopsiaHUB = function()
    local LocalPlayer = Players.LocalPlayer
    local zapFolder = ReplicatedStorage:WaitForChild("ZAP")
    local merchantRemote = zapFolder:WaitForChild("merchant_RELIABLE")
    local charmRemote = zapFolder:WaitForChild("charm_RELIABLE")

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

    local function getCleanDisplayName(rawName)
        local clean = rawName:gsub("(%l)(%u)", "%1 %2")
        clean = clean:gsub("%-t%d+", ""):gsub("%-", " ")
        return clean:gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
    end

    for _, itemName in ipairs(partItemList) do
        bufferCache[itemName] = buffer.fromstring(string.format("\0\6\0blocks%s\0%s", string.char(#itemName), itemName))
    end
    for _, itemName in ipairs(gardenItemList) do
        bufferCache[itemName] = buffer.fromstring(string.format("\0\6\0garden%s\0%s", string.char(#itemName), itemName))
    end

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

    local function checkServerStock(itemName)
        if not smartStockActive then return 999 end
        if serverStockCache[itemName] ~= nil and serverStockCache[itemName] <= 0 then return 0 end
        return 999
    end

    local function beliItem(itemName)
        if checkServerStock(itemName) <= 0 then return end
        if bufferCache[itemName] then
            merchantRemote:FireServer(bufferCache[itemName], {})
        end
    end

    -- GUI ROOT
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "KenopsiaHUB_ModernUI"
    MainGui.ResetOnSpawn = false
    MainGui.Parent = getParent()

    -- TOGGLE BUTTON
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
    local ballStroke = Instance.new("UIStroke", ToggleBall)
    ballStroke.Color = C.accent; ballStroke.Thickness = 2

    -- MAIN FRAME
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 560, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
    MainFrame.BackgroundColor3 = C.bg
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MainGui
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
    local mainStroke = Instance.new("UIStroke", MainFrame)
    mainStroke.Color = C.border; mainStroke.Thickness = 1.5

    -- DRAGGABLE SYSTEM
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- TOP BAR
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 46)
    TopBar.BackgroundColor3 = C.topbar
    TopBar.BorderSizePixel = 0
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = "  ⚡ KENOPSIA <font color=\"rgb(139, 92, 246)\">HUB</font>"
    Title.RichText = true
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = C.text
    Title.TextSize = 16
    Title.Font = Enum.Font.FredokaOne
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local HideBtn = Instance.new("TextButton", TopBar)
    HideBtn.Text = "✕"
    HideBtn.Size = UDim2.new(0, 30, 0, 30)
    HideBtn.Position = UDim2.new(1, -38, 0.5, -15)
    HideBtn.BackgroundColor3 = C.card
    HideBtn.TextColor3 = C.muted
    HideBtn.TextSize = 13
    HideBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 8)
    local hideStroke = Instance.new("UIStroke", HideBtn)
    hideStroke.Color = C.border

    -- TAB HOLDER
    local TabHolder = Instance.new("Frame", MainFrame)
    TabHolder.Size = UDim2.new(0, 140, 1, -46)
    TabHolder.Position = UDim2.new(0, 0, 0, 46)
    TabHolder.BackgroundColor3 = C.topbar
    TabHolder.BorderSizePixel = 0

    local ShopTabBtn = Instance.new("TextButton", TabHolder)
    ShopTabBtn.Size = UDim2.new(0.86, 0, 0, 38)
    ShopTabBtn.Position = UDim2.new(0.07, 0, 0.05, 0)
    ShopTabBtn.Text = "🛒 Store"
    ShopTabBtn.BackgroundColor3 = C.accent
    ShopTabBtn.TextColor3 = C.text
    ShopTabBtn.Font = Enum.Font.FredokaOne
    ShopTabBtn.TextSize = 13
    Instance.new("UICorner", ShopTabBtn).CornerRadius = UDim.new(0, 10)

    local SettingsTabBtn = Instance.new("TextButton", TabHolder)
    SettingsTabBtn.Size = UDim2.new(0.86, 0, 0, 38)
    SettingsTabBtn.Position = UDim2.new(0.07, 0, 0.17, 0)
    SettingsTabBtn.Text = "⚙️ Settings"
    SettingsTabBtn.BackgroundColor3 = C.card
    SettingsTabBtn.TextColor3 = C.muted
    SettingsTabBtn.Font = Enum.Font.FredokaOne
    SettingsTabBtn.TextSize = 13
    Instance.new("UICorner", SettingsTabBtn).CornerRadius = UDim.new(0, 10)
    local setStroke = Instance.new("UIStroke", SettingsTabBtn); setStroke.Color = C.border

    -- CONTAINER HOLDER
    local ContainerHolder = Instance.new("Frame", MainFrame)
    ContainerHolder.Size = UDim2.new(1, -140, 1, -46)
    ContainerHolder.Position = UDim2.new(0, 140, 0, 46)
    ContainerHolder.BackgroundTransparency = 1

    local ShopFrame = Instance.new("Frame", ContainerHolder)
    ShopFrame.Size = UDim2.new(1, 0, 1, 0)
    ShopFrame.BackgroundTransparency = 1

    local SettingsFrame = Instance.new("Frame", ContainerHolder)
    SettingsFrame.Size = UDim2.new(1, 0, 1, 0)
    SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.Visible = false

    -- SUB TABS (PARTS / GARDEN)
    local PartShopBtn = Instance.new("TextButton", ShopFrame)
    PartShopBtn.Size = UDim2.new(0.44, 0, 0, 30)
    PartShopBtn.Position = UDim2.new(0.04, 0, 0.03, 0)
    PartShopBtn.Text = "Parts"
    PartShopBtn.BackgroundColor3 = C.accent
    PartShopBtn.TextColor3 = C.text
    PartShopBtn.Font = Enum.Font.FredokaOne
    PartShopBtn.TextSize = 12
    Instance.new("UICorner", PartShopBtn).CornerRadius = UDim.new(0, 8)

    local GardenShopBtn = Instance.new("TextButton", ShopFrame)
    GardenShopBtn.Size = UDim2.new(0.44, 0, 0, 30)
    GardenShopBtn.Position = UDim2.new(0.52, 0, 0.03, 0)
    GardenShopBtn.Text = "Garden"
    GardenShopBtn.BackgroundColor3 = C.card
    GardenShopBtn.TextColor3 = C.muted
    GardenShopBtn.Font = Enum.Font.FredokaOne
    GardenShopBtn.TextSize = 12
    Instance.new("UICorner", GardenShopBtn).CornerRadius = UDim.new(0, 8)
    local gdnStroke = Instance.new("UIStroke", GardenShopBtn); gdnStroke.Color = C.border

    -- SEARCH & BUTTONS
    local SearchBox = Instance.new("TextBox", ShopFrame)
    SearchBox.Size = UDim2.new(0.92, 0, 0, 32)
    SearchBox.Position = UDim2.new(0.04, 0, 0.13, 0)
    SearchBox.BackgroundColor3 = C.card
    SearchBox.PlaceholderText = "🔍 Search item name..."
    SearchBox.PlaceholderColor3 = C.muted
    SearchBox.Text = ""; SearchBox.TextColor3 = C.text
    SearchBox.Font = Enum.Font.BuilderSansMedium; SearchBox.TextSize = 13
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)
    local schStroke = Instance.new("UIStroke", SearchBox); schStroke.Color = C.border

    local SelectAllBtn = Instance.new("TextButton", ShopFrame)
    SelectAllBtn.Size = UDim2.new(0.44, 0, 0, 26)
    SelectAllBtn.Position = UDim2.new(0.04, 0, 0.23, 0)
    SelectAllBtn.BackgroundColor3 = C.card
    SelectAllBtn.Text = "Select All"; SelectAllBtn.TextColor3 = C.cyan
    SelectAllBtn.Font = Enum.Font.FredokaOne; SelectAllBtn.TextSize = 11
    Instance.new("UICorner", SelectAllBtn).CornerRadius = UDim.new(0, 6)
    local saStroke = Instance.new("UIStroke", SelectAllBtn); saStroke.Color = C.border

    local DeselectAllBtn = Instance.new("TextButton", ShopFrame)
    DeselectAllBtn.Size = UDim2.new(0.44, 0, 0, 26)
    DeselectAllBtn.Position = UDim2.new(0.52, 0, 0.23, 0)
    DeselectAllBtn.BackgroundColor3 = C.card
    DeselectAllBtn.Text = "Deselect All"; DeselectAllBtn.TextColor3 = C.danger
    DeselectAllBtn.Font = Enum.Font.FredokaOne; DeselectAllBtn.TextSize = 11
    Instance.new("UICorner", DeselectAllBtn).CornerRadius = UDim.new(0, 6)
    local daStroke = Instance.new("UIStroke", DeselectAllBtn); daStroke.Color = C.border

    local AutoBuyToggle = Instance.new("TextButton", ShopFrame)
    AutoBuyToggle.Size = UDim2.new(0.92, 0, 0, 36)
    AutoBuyToggle.Position = UDim2.new(0.04, 0, 0.31, 0)
    AutoBuyToggle.BackgroundColor3 = C.danger
    AutoBuyToggle.Text = "⚡ AUTO BUY: DISABLED"
    AutoBuyToggle.TextColor3 = C.text
    AutoBuyToggle.Font = Enum.Font.FredokaOne; AutoBuyToggle.TextSize = 13
    Instance.new("UICorner", AutoBuyToggle).CornerRadius = UDim.new(0, 10)

    -- ITEM CARD CREATOR WITH ANIMATION
    local function createItemCard(rawItemName, parentScroll)
        local displayName = getCleanDisplayName(rawItemName)
        local ItemFrame = Instance.new("Frame", parentScroll)
        ItemFrame.Size = UDim2.new(0.96, 0, 0, 34)
        ItemFrame.BackgroundColor3 = C.card
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 8)
        local itemStroke = Instance.new("UIStroke", ItemFrame); itemStroke.Color = C.border

        local CheckBox = Instance.new("Frame", ItemFrame)
        CheckBox.Size = UDim2.new(0, 18, 0, 18)
        CheckBox.Position = UDim2.new(0, 10, 0.5, -9)
        CheckBox.BackgroundColor3 = C.bg
        Instance.new("UICorner", CheckBox).CornerRadius = UDim.new(0, 5)
        local chkStroke = Instance.new("UIStroke", CheckBox); chkStroke.Color = C.border

        local CheckIcon = Instance.new("TextLabel", CheckBox)
        CheckIcon.Size = UDim2.new(1, 0, 1, 0)
        CheckIcon.BackgroundTransparency = 1
        CheckIcon.Text = "✓"; CheckIcon.TextColor3 = C.text
        CheckIcon.TextSize = 12; CheckIcon.Font = Enum.Font.FredokaOne; CheckIcon.Visible = false

        local ItemBtn = Instance.new("TextButton", ItemFrame)
        ItemBtn.Size = UDim2.new(1, -40, 1, 0)
        ItemBtn.Position = UDim2.new(0, 36, 0, 0)
        ItemBtn.BackgroundTransparency = 1
        ItemBtn.Text = displayName; ItemBtn.TextColor3 = C.text
        ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
        ItemBtn.Font = Enum.Font.BuilderSansMedium; ItemBtn.TextSize = 13

        local function updateState(state)
            selectedItems[rawItemName] = state
            if state then
                TweenService:Create(ItemFrame, TweenInfo.new(0.2), {BackgroundColor3 = C.cardHover}):Play()
                itemStroke.Color = C.accent
                CheckBox.BackgroundColor3 = C.accent
                CheckIcon.Visible = true
            else
                TweenService:Create(ItemFrame, TweenInfo.new(0.2), {BackgroundColor3 = C.card}):Play()
                itemStroke.Color = C.border
                CheckBox.BackgroundColor3 = C.bg
                CheckIcon.Visible = false
            end
        end

        ItemBtn.MouseButton1Click:Connect(function() updateState(not selectedItems[rawItemName]) end)
        itemCards[rawItemName] = { Frame = ItemFrame, Update = updateState, DisplayName = displayName }
    end

    local ScrollParts = Instance.new("ScrollingFrame", ShopFrame)
    ScrollParts.Size = UDim2.new(0.92, 0, 0.56, 0)
    ScrollParts.Position = UDim2.new(0.04, 0, 0.42, 0)
    ScrollParts.BackgroundTransparency = 1
    ScrollParts.CanvasSize = UDim2.new(0, 0, 0, #partItemList * 38)
    ScrollParts.ScrollBarThickness = 3
    ScrollParts.ScrollBarImageColor3 = C.accent
    Instance.new("UIListLayout", ScrollParts).Padding = UDim.new(0, 4)

    for _, itemName in ipairs(partItemList) do createItemCard(itemName, ScrollParts) end

    local ScrollGarden = Instance.new("ScrollingFrame", ShopFrame)
    ScrollGarden.Size = UDim2.new(0.92, 0, 0.56, 0)
    ScrollGarden.Position = UDim2.new(0.04, 0, 0.42, 0)
    ScrollGarden.BackgroundTransparency = 1
    ScrollGarden.CanvasSize = UDim2.new(0, 0, 0, #gardenItemList * 38)
    ScrollGarden.ScrollBarThickness = 3
    ScrollGarden.ScrollBarImageColor3 = C.accent
    ScrollGarden.Visible = false
    Instance.new("UIListLayout", ScrollGarden).Padding = UDim.new(0, 4)

    for _, itemName in ipairs(gardenItemList) do createItemCard(itemName, ScrollGarden) end

    -- SETTINGS PAGE
    local SmartStockToggle = Instance.new("TextButton", SettingsFrame)
    SmartStockToggle.Size = UDim2.new(0.92, 0, 0, 40)
    SmartStockToggle.Position = UDim2.new(0.04, 0, 0.05, 0)
    SmartStockToggle.BackgroundColor3 = C.success
    SmartStockToggle.Text = "🛡️  Smart Stock Check: ACTIVE"
    SmartStockToggle.TextColor3 = C.text
    SmartStockToggle.Font = Enum.Font.FredokaOne; SmartStockToggle.TextSize = 13
    Instance.new("UICorner", SmartStockToggle).CornerRadius = UDim.new(0, 10)

    local DelayBox = Instance.new("TextBox", SettingsFrame)
    DelayBox.Size = UDim2.new(0.92, 0, 0, 36)
    DelayBox.Position = UDim2.new(0.04, 0, 0.18, 0)
    DelayBox.BackgroundColor3 = C.card
    DelayBox.Text = tostring(buyDelay)
    DelayBox.TextColor3 = C.cyan
    DelayBox.Font = Enum.Font.FredokaOne; DelayBox.TextSize = 14
    Instance.new("UICorner", DelayBox).CornerRadius = UDim.new(0, 10)
    local dbStroke = Instance.new("UIStroke", DelayBox); dbStroke.Color = C.border

    DelayBox.FocusLost:Connect(function()
        local val = tonumber(DelayBox.Text)
        if val and val >= 0.01 then buyDelay = val else DelayBox.Text = tostring(buyDelay) end
    end)

    -- CONTROLS & LISTENERS
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for rawName, cardData in pairs(itemCards) do
            cardData.Frame.Visible = (query == "" or string.lower(cardData.DisplayName):find(query) or string.lower(rawName):find(query))
        end
    end)

    SelectAllBtn.MouseButton1Click:Connect(function()
        local list = ScrollParts.Visible and partItemList or gardenItemList
        for _, rawName in ipairs(list) do
            if itemCards[rawName] and itemCards[rawName].Frame.Visible then itemCards[rawName].Update(true) end
        end
    end)

    DeselectAllBtn.MouseButton1Click:Connect(function()
        local list = ScrollParts.Visible and partItemList or gardenItemList
        for _, rawName in ipairs(list) do
            if itemCards[rawName] then itemCards[rawName].Update(false) end
        end
    end)

    AutoBuyToggle.MouseButton1Click:Connect(function()
        autoBuyActive = not autoBuyActive
        if autoBuyActive then
            AutoBuyToggle.Text = "⚡ AUTO BUY: ACTIVE"
            TweenService:Create(AutoBuyToggle, TweenInfo.new(0.2), {BackgroundColor3 = C.success}):Play()
        else
            AutoBuyToggle.Text = "⚡ AUTO BUY: DISABLED"
            TweenService:Create(AutoBuyToggle, TweenInfo.new(0.2), {BackgroundColor3 = C.danger}):Play()
        end
    end)

    HideBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; ToggleBall.Visible = true end)
    ToggleBall.MouseButton1Click:Connect(function() MainFrame.Visible = true; ToggleBall.Visible = false end)

    ShopTabBtn.MouseButton1Click:Connect(function()
        ShopFrame.Visible = true; SettingsFrame.Visible = false
        ShopTabBtn.BackgroundColor3 = C.accent; ShopTabBtn.TextColor3 = C.text
        SettingsTabBtn.BackgroundColor3 = C.card; SettingsTabBtn.TextColor3 = C.muted
    end)

    SettingsTabBtn.MouseButton1Click:Connect(function()
        ShopFrame.Visible = false; SettingsFrame.Visible = true
        SettingsTabBtn.BackgroundColor3 = C.accent; SettingsTabBtn.TextColor3 = C.text
        ShopTabBtn.BackgroundColor3 = C.card; ShopTabBtn.TextColor3 = C.muted
    end)

    PartShopBtn.MouseButton1Click:Connect(function()
        ScrollParts.Visible = true; ScrollGarden.Visible = false
        PartShopBtn.BackgroundColor3 = C.accent; PartShopBtn.TextColor3 = C.text
        GardenShopBtn.BackgroundColor3 = C.card; GardenShopBtn.TextColor3 = C.muted
    end)

    GardenShopBtn.MouseButton1Click:Connect(function()
        ScrollParts.Visible = false; ScrollGarden.Visible = true
        GardenShopBtn.BackgroundColor3 = C.accent; GardenShopBtn.TextColor3 = C.text
        PartShopBtn.BackgroundColor3 = C.card; PartShopBtn.TextColor3 = C.muted
    end)

    -- AUTO PURCHASE THREAD
    task.spawn(function()
        while true do
            task.wait(buyDelay)
            if autoBuyActive then
                for itemName, isSelected in pairs(selectedItems) do
                    if isSelected then
                        task.spawn(function() beliItem(itemName) end)
                    end
                end
            end
        end
    end)
end

startKenopsiaHUB()
