return function(HUB)
    local Tabs = HUB.Tabs
    local State = HUB.State
    local Fluent = HUB.Fluent
    local VirtualUser = game:GetService("VirtualUser")
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer = game:GetService("Players").LocalPlayer

    Tabs.Settings:AddParagraph({ Title = "Advanced Settings", Content = "Konfigurasi sistem & keamanan." })

    Tabs.Settings:AddToggle("SmartStockToggle", { Title = "Smart Stock Check", Default = true, Callback = function(V) State.smartStockActive = V end })
    
    -- Anti-AFK Logic
    Tabs.Settings:AddToggle("AntiAfkToggle", { Title = "Anti-AFK Protection", Default = true, Callback = function(V) State.antiAfkActive = V end })
    LocalPlayer.Idled:Connect(function()
        if getgenv().KenopsiaRunning and State.antiAfkActive then
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)

    -- Auto Reconnect Logic
    Tabs.Settings:AddToggle("AutoReconnectToggle", { Title = "Auto-Reconnect", Default = true, Callback = function(V) State.autoReconnectActive = V end })
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("RobloxPromptGui") and CoreGui.RobloxPromptGui:FindFirstChild("promptOverlay") then
        CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
            if getgenv().KenopsiaRunning and State.autoReconnectActive and child.Name == "ErrorPrompt" then
                task.wait(2)
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end)
    end

    -- Optimized FPS Toggle
    Tabs.Settings:AddToggle("OptimizeFpsToggle", { 
        Title = "Low FPS / Background Mode", 
        Default = false, 
        Callback = function(V) 
            State.optimizeFpsActive = V 
            if V then setfpscap(15) else setfpscap(999) end 
        end 
    })

    Tabs.Settings:AddInput("MinCoinInput", { Title = "Minimum Safe Coins", Default = "0", Numeric = true, Finished = true, Callback = function(V) State.minCoinThreshold = tonumber(V) or 0 end })
    Tabs.Settings:AddInput("WebhookInput", { Title = "Discord Webhook URL", Default = "", Finished = true, Callback = function(V) State.webhookUrl = V end })
    Tabs.Settings:AddInput("DelayInput", { Title = "Buy Delay (Seconds)", Default = "0.2", Numeric = true, Finished = false, Callback = function(V) local n = tonumber(V) if n and n >= 0.01 then State.buyDelay = n end end })

    HUB.InterfaceManager:SetLibrary(Fluent)
    HUB.SaveManager:SetLibrary(Fluent)
    HUB.InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    HUB.SaveManager:BuildConfigSection(Tabs.Settings)
end

