return function(HUB)
    local Tabs = HUB.Tabs
    local State = HUB.State
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService")
    
    local zapFolder = ReplicatedStorage:WaitForChild("ZAP", 5)
    if not zapFolder then return end
    
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

    for _, itemName in ipairs(partItemList) do
        State.bufferCache[itemName] = buffer.fromstring(string.format("\0\6\0blocks%s\0%s", string.char(#itemName), itemName))
    end
    for _, itemName in ipairs(gardenItemList) do
        State.bufferCache[itemName] = buffer.fromstring(string.format("\0\6\0garden%s\0%s", string.char(#itemName), itemName))
    end

    Tabs.Store:AddParagraph({ Title = "Auto Buy Store", Content = "Pilih item untuk dibeli otomatis saat stok tersedia." })
    
    Tabs.Store:AddToggle("AutoBuyToggle", {
        Title = "Enable Auto Buy",
        Default = false,
        Callback = function(Value) State.autoBuyActive = Value end
    })

    Tabs.Store:AddParagraph({ Title = "--- PARTS CATEGORY ---", Content = "" })
    for _, itemName in ipairs(partItemList) do
        State.selectedItems[itemName] = false
        Tabs.Store:AddToggle("Item_"..itemName, { Title = HUB.getCleanDisplayName(itemName), Default = false, Callback = function(V) State.selectedItems[itemName] = V end })
    end

    Tabs.Store:AddParagraph({ Title = "--- GARDEN CATEGORY ---", Content = "" })
    for _, itemName in ipairs(gardenItemList) do
        State.selectedItems[itemName] = false
        Tabs.Store:AddToggle("Item_"..itemName, { Title = HUB.getCleanDisplayName(itemName), Default = false, Callback = function(V) State.selectedItems[itemName] = V end })
    end

    charmRemote.OnClientEvent:Connect(function(header, data)
        if not getgenv().KenopsiaRunning then return end
        if type(data) == "table" then
            for _, playerData in pairs(data) do
                if type(playerData) == "table" then
                    for _, userBlocks in pairs(playerData) do
                        if userBlocks and userBlocks.blocks and userBlocks.blocks.items then
                            for _, itemInfo in pairs(userBlocks.blocks.items) do
                                if itemInfo and itemInfo.stock and itemInfo.name then
                                    State.serverStockCache[itemInfo.name] = itemInfo.stock
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    local function checkStock(name)
        if not State.smartStockActive then return 999 end
        if State.serverStockCache[name] ~= nil and State.serverStockCache[name] <= 0 then return 0 end
        return 999
    end

    local function beliItem(itemName)
        if checkStock(itemName) <= 0 then return end
        if State.bufferCache[itemName] then
            pcall(function() merchantRemote:FireServer(State.bufferCache[itemName], {}) end)
            State.sessionStats.itemsBought = State.sessionStats.itemsBought + 1
            if State.addLog then State.addLog("Buy: " .. HUB.getCleanDisplayName(itemName)) end
            if State.webhookUrl ~= "" and State.webhookUrl:match("discord.com/api/webhooks") then
                task.spawn(function()
                    pcall(function()
                        request({ Url = State.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode({ ["embeds"] = {{ ["title"] = "Kenopsia HUB - Purchased!", ["description"] = HUB.getCleanDisplayName(itemName), ["color"] = 65280 }} }) })
                    end)
                end)
            end
        end
    end

    task.spawn(function()
        while getgenv().KenopsiaRunning do
            task.wait(State.buyDelay)
            if State.autoBuyActive then
                for itemName, isSelected in pairs(State.selectedItems) do
                    if isSelected then task.spawn(function() beliItem(itemName) end) end
                end
            end
        end
    end)
end

