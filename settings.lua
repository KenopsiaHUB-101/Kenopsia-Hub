-- ==========================================
-- KENOPSIA HUB - SETTINGS MODULE
-- ==========================================

local Debug = _G.KenopsiaDebug or {
    Info = function() end,
    Success = function() end,
    Error = function() end,
    Warning = function() end,
    Debug = function() end
}

return function(HUB)
    if Debug.Info then Debug:Info("Loading settings module...") end
    
    local Tabs = HUB.Tabs
    local State = HUB.State
    local Fluent = HUB.Fluent
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = game:GetService("Players").LocalPlayer

    if not LocalPlayer then
        if Debug.Error then Debug:Error("LocalPlayer not found") end
        return
    end

    Tabs.Settings:AddParagraph({ Title = "Advanced Settings", Content = "Konfigurasi sistem, jaringan & keamanan." })

    -- 1. Server Hop & Rejoin
    Tabs.Settings:AddButton({
        Title = "Server Hop (Pindah Server Sepi)",
        Description = "Cari server baru yang lebih sedikit pemainnya.",
        Callback = function()
            if Fluent then
                Fluent:Notify({ Title = "Server Hop", Content = "Mencari server sepi...", Duration = 3 })
            end
            
            if Debug.Info then Debug:Info("Starting server hop...") end
            
            pcall(function()
                local response = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=Asc&limit=100", true)
                local servers = HttpService:JSONDecode(response).data
                
                for _, s in pairs(servers) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        if Debug.Success then Debug:Success("Found server with " .. s.playing .. "/" .. s.maxPlayers .. " players") end
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        break
                    end
                end
            end)
        end
    })

    Tabs.Settings:AddButton({
        Title = "Rejoin Server Current",
        Description = "Kembali ke server saat ini",
        Callback = function()
            if Debug.Info then Debug:Info("Rejoining current server...") end
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    })

    -- 2. Streamproof & Audio Alert
    Tabs.Settings:AddToggle("StreamproofToggle", {
        Title = "Streamproof Mode (Sembunyikan Username)",
        Default = false,
        Callback = function(V) 
            State.streamproofActive = V
            if Debug.Info then Debug:Info("Streamproof mode " .. (V and "enabled" or "disabled")) end
        end
    })

    Tabs.Settings:AddToggle("AudioAlertToggle", {
        Title = "Audio Alert Saat Beli Item",
        Default = true,
        Callback = function(V) 
            State.audioAlertActive = V
            if Debug.Info then Debug:Info("Audio alert " .. (V and "enabled" or "disabled")) end
        end
    })

    Tabs.Settings:AddToggle("FloatingButtonToggle", {
        Title = "Tampilkan Tombol Melayang (Mobile)",
        Default = true,
        Callback = function(V)
            pcall(function()
                if HUB.FloatingButton then 
                    HUB.FloatingButton.Enabled = V
                    if Debug.Debug then Debug:Debug("Floating button visibility: " .. tostring(V)) end
                end
            end)
        end
    })

    -- 3. Protection Settings
    Tabs.Settings:AddToggle("SmartStockToggle", { 
        Title = "Smart Stock Check", 
        Default = true, 
        Callback = function(V) 
            State.smartStockActive = V
            if Debug.Info then Debug:Info("Smart stock check " .. (V and "enabled" or "disabled")) end
        end 
    })
    
    Tabs.Settings:AddToggle("AntiAfkToggle", { 
        Title = "Anti-AFK Protection", 
        Default = true, 
        Callback = function(V) 
            State.antiAfkActive = V
            if Debug.Info then Debug:Info("Anti-AFK " .. (V and "enabled" or "disabled")) end
        end 
    })
    
    Tabs.Settings:AddToggle("AutoReconnectToggle", { 
        Title = "Auto-Reconnect Error Prompt", 
        Default = true, 
        Callback = function(V) 
            State.autoReconnectActive = V
            if Debug.Info then Debug:Info("Auto-reconnect " .. (V and "enabled" or "disabled")) end
        end 
    })

    -- 4. Performance Mode
    Tabs.Settings:AddToggle("OptimizeFpsToggle", { 
        Title = "Low FPS / Background Mode (15 FPS)", 
        Default = false, 
        Callback = function(V) 
            State.optimizeFpsActive = V
            pcall(function()
                if setfpscap then
                    setfpscap(V and 15 or 999)
                    if Debug.Info then Debug:Info("FPS cap set to: " .. (V and 15 or 999)) end
                end
            end)
        end 
    })

    -- 5. Input Fields
    Tabs.Settings:AddInput("WebhookInput", { 
        Title = "Discord Webhook URL", 
        Default = "", 
        Finished = true, 
        Callback = function(V) 
            State.webhookUrl = V
            if Debug.Debug then Debug:Debug("Webhook URL updated") end
        end 
    })
    
    Tabs.Settings:AddInput("DelayInput", { 
        Title = "Buy Delay (Seconds)", 
        Default = "0.2", 
        Numeric = true, 
        Finished = false, 
        Callback = function(V) 
            local n = tonumber(V)
            if n and n >= 0.01 then 
                State.buyDelay = n
                if Debug.Debug then Debug:Debug("Buy delay set to: " .. n) end
            end 
        end 
    })

    -- 6. Configuration Management
    if HUB.InterfaceManager then
        pcall(function()
            HUB.InterfaceManager:SetLibrary(Fluent)
            HUB.InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        end)
    end
    
    if HUB.SaveManager then
        pcall(function()
            HUB.SaveManager:SetLibrary(Fluent)
            HUB.SaveManager:BuildConfigSection(Tabs.Settings)
        end)
    end
    
    if Debug.Success then Debug:Success("Settings module loaded successfully") end
end
