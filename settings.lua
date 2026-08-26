return function(HUB)
    local Tabs = HUB.Tabs
    local State = HUB.State
    local Fluent = HUB.Fluent
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = game:GetService("Players").LocalPlayer

    Tabs.Settings:AddParagraph({ Title = "Advanced Settings", Content = "Konfigurasi sistem, jaringan & keamanan." })

    -- 1. Server Hop (Low Player Server & Rejoin)
    Tabs.Settings:AddButton({
        Title = "Server Hop (Pindah Server Sepi)",
        Description = "Cari server baru yang lebih sedikit pemainnya.",
        Callback = function()
            Fluent:Notify({ Title = "Server Hop", Content = "Mencari server sepi...", Duration = 3 })
            pcall(function()
                local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=Asc&limit=100")).data
                for _, s in pairs(servers) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        break
                    end
                end
            end)
        end
    })

    Tabs.Settings:AddButton({
        Title = "Rejoin Server Current",
        Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end
    })

    -- 2. Streamproof & Floating Button Toggle
    Tabs.Settings:AddToggle("StreamproofToggle", {
        Title = "Streamproof Mode (Sembunyikan Username)",
        Default = false,
        Callback = function(V) State.streamproofActive = V end
    })

    Tabs.Settings:AddToggle("AudioAlertToggle", {
        Title = "Audio Alert Saat Beli Item",
        Default = true,
        Callback = function(V) State.audioAlertActive = V end
    })

    Tabs.Settings:AddToggle("FloatingButtonToggle", {
        Title = "Tampilkan Tombol Melayang (Mobile)",
        Default = true,
        Callback = function(V)
            if HUB.FloatingButton then HUB.FloatingButton.Enabled = V end
        end
    })

    -- 3. Auto AFK & Auto Reconnect
    Tabs.Settings:AddToggle("SmartStockToggle", { Title = "Smart Stock Check", Default = true, Callback = function(V) State.smartStockActive = V end })
    Tabs.Settings:AddToggle("AntiAfkToggle", { Title = "Anti-AFK Protection", Default = true, Callback = function(V) State.antiAfkActive = V end })
    Tabs.Settings:AddToggle("AutoReconnectToggle", { Title = "Auto-Reconnect Error Prompt", Default = true, Callback = function(V) State.autoReconnectActive = V end })

    -- 4. Low FPS / Background Mode
    Tabs.Settings:AddToggle("OptimizeFpsToggle", { 
        Title = "Low FPS / Background Mode (15 FPS)", 
        Default = false, 
        Callback = function(V) 
            State.optimizeFpsActive = V 
            if V then setfpscap(15) else setfpscap(999) end 
        end 
    })

    -- Inputs
    Tabs.Settings:AddInput("WebhookInput", { Title = "Discord Webhook URL", Default = "", Finished = true, Callback = function(V) State.webhookUrl = V end })
    Tabs.Settings:AddInput("DelayInput", { Title = "Buy Delay (Seconds)", Default = "0.2", Numeric = true, Finished = false, Callback = function(V) local n = tonumber(V) if n and n >= 0.01 then State.buyDelay = n end end })

    HUB.InterfaceManager:SetLibrary(Fluent)
    HUB.SaveManager:SetLibrary(Fluent)
    HUB.InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    HUB.SaveManager:BuildConfigSection(Tabs.Settings)
end
