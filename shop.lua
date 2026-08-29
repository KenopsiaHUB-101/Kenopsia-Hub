-- ==========================================
-- KENOPSIA HUB - SHOP MODULE
-- ==========================================

local Debug = _G.KenopsiaDebug or {
    Info = function() end,
    Success = function() end,
    Error = function() end,
    Warning = function() end,
    Debug = function() end
}

return function(HUB)
    if Debug.Info then Debug:Info("Loading shop module...") end
    
    local Tabs = HUB.Tabs
    local State = HUB.State
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService")
    
    local zapFolder = ReplicatedStorage:WaitForChild("ZAP", 5)
    if not zapFolder then
        if Debug.Error then Debug:Error("ZAP folder not found in ReplicatedStorage") end
        return
    end
    
    local merchantRemote = zapFolder:WaitForChild("merchant_RELIABLE", 5)
    local charmRemote = zapFolder:WaitForChild("charm_RELIABLE", 5)
    
    if not merchantRemote or not charmRemote then
        if Debug.Error then Debug:Error("Required remotes not found") end
        return
    end
    
    if Debug.Debug then Debug:Debug("Shop remotes connected successfully") end
    
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

    -- Setup buffer cache
    for _, itemName in ipairs(partItemList) do
        pcall(function()
            State.bufferCache[itemName] = buffer.fromstring(string.format("\\0\\6\\0blocks%s\\0%s", string.char(#itemName), itemName))
        end)
    end
    
    for _, itemName in ipairs(gardenItemList) do
        pcall(function()
            State.bufferCache[itemName] = buffer.fromstring(string.format("\\0\\6\\0garden%s\\0%s", string.char(#itemName), itemName))
        end)
    end

    if Debug.Debug then Debug:Debug("Buffer cache initialized for " .. (#partItemList + #gardenItemList) .. " items") end

    Tabs.Store:AddParagraph({ Title = "Auto Buy Store", Content = "Pilih item untuk dibeli otomatis." })
    
    Tabs.Store:AddToggle("AutoBuyToggle", {
        Title = "Enable Auto Buy",
        Default = false,
        Callback = function(Value) 
            State.autoBuyActive = Value
            if Debug.Info then Debug:Info("Auto buy " .. (Value and "enabled" or "disabled")) end
        end
    })

    Tabs.Store:AddParagraph({ Title = "--- PARTS CATEGORY ---", Content = "" })
    for _, itemName in ipairs(partItemList) do
        State.selectedItems[itemName] = false
        Tabs.Store:AddToggle("Item_"..itemName, { 
            Title = HUB.getCleanDisplayName(itemName), 
            Default = false, 
            Callback = function(V) 
                State.selectedItems[itemName] = V
                if Debug.Debug then Debug:Debug("Item " .. itemName .. " selection: " .. tostring(V)) end
            end 
        })
    end

    Tabs.Store:AddParagraph({ Title = "--- GARDEN CATEGORY ---", Content = "" })
    for _, itemName in ipairs(gardenItemList) do
        State.selectedItems[itemName] = false
        Tabs.Store:AddToggle("Item_"..itemName, { 
            Title = HUB.getCleanDisplayName(itemName), 
            Default = false, 
            Callback = function(V) 
                State.selectedItems[itemName] = V
                if Debug.Debug then Debug:Debug("Item " .. itemName .. " selection: " .. tostring(V)) end
            end 
        })
    end

    -- Monitor charm remote for stock updates
    charmRemote.OnClientEvent:Connect(function(header, data)
        if not getgenv().KenopsiaRunning then return end
        
        pcall(function()
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
    end)

    local lastWebhookTime = 0
    local function sendWebhookRateLimited(itemName)
        if State.webhookUrl == "" or not State.webhookUrl:match("discord.com/api/webhooks") then return end
        if os.clock() - lastWebhookTime < 1.5 then return end
        
        lastWebhookTime = os.clock()
        pcall(function()
            local success = request({
                Url = State.webhookUrl,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({
                    ["embeds"] = {{
                        ["title"] = "Kenopsia HUB - Purchased!",
                        ["description"] = HUB.getCleanDisplayName(itemName),
                        ["color"] = 65280
                    }}
                })
            })
            if Debug.Debug then Debug:Debug("Webhook sent for: " .. itemName) end
        end)
    end

    local function playBuySound()
        if not State.audioAlertActive then return end
        
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://459066276"
            sound.Volume = 0.5
            sound.Parent = workspace
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 2)
        end)
    end

    local function beliItem(itemName)
        if State.smartStockActive and State.serverStockCache[itemName] and State.serverStockCache[itemName] <= 0 then
            if Debug.Warning then Debug:Warning("Item out of stock: " .. itemName) end
            return
        end
        
        if State.bufferCache[itemName] then
            pcall(function()
                merchantRemote:FireServer(State.bufferCache[itemName], {})
                State.sessionStats.itemsBought = State.sessionStats.itemsBought + 1
                
                if State.addLog then 
                    State.addLog("Buy: " .. HUB.getCleanDisplayName(itemName)) 
                end
                
                playBuySound()
                task.spawn(function() sendWebhookRateLimited(itemName) end)
                
                if Debug.Debug then Debug:Debug("Purchased: " .. itemName) end
            end)
        end
    end

    task.spawn(function()
        while getgenv().KenopsiaRunning do
            task.wait(State.buyDelay)
            if State.autoBuyActive then
                for itemName, isSelected in pairs(State.selectedItems) do
                    if isSelected then
                        task.spawn(function() beliItem(itemName) end)
                    end
                end
            end
        end
    end)
    
    if Debug.Success then Debug:Success("Shop module loaded successfully") end
end
