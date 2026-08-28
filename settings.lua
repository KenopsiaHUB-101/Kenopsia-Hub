return function(HUB)
    local Fluent = HUB.Fluent
    local Tabs = HUB.Tabs
    local State = HUB.State
    local SaveManager = HUB.SaveManager

    Tabs.Settings:AddParagraph({ Title = "⚙️ Settings", Content = "Configure your hub." })

    -- 1. Bypass Toggle
    Tabs.Settings:AddToggle({
        Title = "Enable Bypass",
        Description = "Toggle anti-cheat bypass.",
        Default = State.bypassEnabled,
        Callback = function(value)
            State.bypassEnabled = value
            HUB.Bypass.SetBypass(value) -- Call from bypass.lua
            SaveManager:SaveConfig()
        end
    })

    -- 2. Auto Buy
    Tabs.Settings:AddToggle({
        Title = "Auto Buy",
        Default = State.autoBuy,
        Callback = function(value)
            State.autoBuy = value
            SaveManager:SaveConfig()
        end
    })

    -- 3. Smart Stock
    Tabs.Settings:AddToggle({
        Title = "Smart Stock",
        Default = State.smartStock,
        Callback = function(value)
            State.smartStock = value
            SaveManager:SaveConfig()
        end
    })

    -- 4. Anti-AFK
    Tabs.Settings:AddToggle({
        Title = "Anti-AFK",
        Default = State.antiAFK,
        Callback = function(value)
            State.antiAFK = value
            SaveManager:SaveConfig()
        end
    })

    -- 5. Fast Walk
    Tabs.Settings:AddToggle({
        Title = "Fast Walk",
        Default = State.fastWalk,
        Callback = function(value)
            State.fastWalk = value
            SaveManager:SaveConfig()
        end
    })

    -- 6. ESP
    Tabs.Settings:AddToggle({
        Title = "ESP",
        Default = State.esp,
        Callback = function(value)
            State.esp = value
            SaveManager:SaveConfig()
        end
    })

    -- 7. Audio Alert
    Tabs.Settings:AddToggle({
        Title = "Audio Alerts",
        Default = State.audioAlert,
        Callback = function(value)
            State.audioAlert = value
            SaveManager:SaveConfig()
        end
    })

    -- 8. Streamproof
    Tabs.Settings:AddToggle({
        Title = "Streamproof",
        Description = "Hide username from streamers.",
        Default = State.streamproof,
        Callback = function(value)
            State.streamproof = value
            if value then
                -- Change username to something generic
                if LocalPlayer then
                    LocalPlayer.Name = "Player"
                end
            else
                if LocalPlayer then
                    LocalPlayer.Name = "KenopsiaUser"
                end
            end
            SaveManager:SaveConfig()
        end
    })

    -- 9. Save Config
    Tabs.Settings:AddButton({
        Title = "Save Settings",
        Callback = function()
            SaveManager:SaveConfig()
            Fluent:Notify({ Title = "Saved", Content = "Settings saved successfully.", Duration = 3 })
        end
    })

    -- 10. Load Config
    Tabs.Settings:AddButton({
        Title = "Load Settings",
        Callback = function()
            SaveManager:LoadConfig()
            Fluent:Notify({ Title = "Loaded", Content = "Settings loaded.", Duration = 3 })
        end
    })
end
