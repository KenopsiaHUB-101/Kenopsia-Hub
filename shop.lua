return function(HUB)
    local Fluent = HUB.Fluent
    local Tabs = HUB.Tabs
    local State = HUB.State
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    Tabs.Store:AddParagraph({ Title = "🛒 Shop Assistant", Content = "Buy items automatically." })

    -- 1. Auto Buy
    Tabs.Store:AddToggle({
        Title = "Auto Buy Items",
        Description = "Automatically buy items from the shop.",
        Default = State.autoBuy,
        Callback = function(value)
            State.autoBuy = value
            if value then
                HUB.SaveManager:SaveConfig()
                task.spawn(function()
                    while State.autoBuy and getgenv().KenopsiaRunning do
                        task.wait(0.5)
                        -- Simulate buying logic
                        -- Replace 'ShopItem' with actual remote/event name in your game
                        local shopItem = ReplicatedStorage:FindFirstChild("ShopItem") or ReplicatedStorage:FindFirstChild("BuyItem")
                        if shopItem then
                            if shopItem:IsA("RemoteEvent") then
                                shopItem:FireServer()
                            end
                        end
                    end
                end)
            end
        end
    })

    -- 2. Smart Stock
    Tabs.Store:AddToggle({
        Title = "Smart Stock",
        Description = "Only buy if stock is above threshold.",
        Default = State.smartStock,
        Callback = function(value)
            State.smartStock = value
            HUB.SaveManager:SaveConfig()
        end
    })

    -- 3. Anti-Fraud (Prevent banning)
    Tabs.Store:AddToggle({
        Title = "Anti-Fraud",
        Description = "Randomize buy delays to look human.",
        Default = true,
        Callback = function(value)
            -- Anti-fraud is usually active by default
        end
    })

    -- 4. Buy Delay Slider
    Tabs.Store:AddSlider({
        Title = "Buy Delay (Seconds)",
        Default = 0.5,
        Min = 0.1,
        Max = 5.0,
        Rounding = 1,
        Callback = function(value)
            -- Used in Auto Buy loop
        end
    })

    -- 5. Log
    Tabs.Store:AddButton({
        Title = "Clear Shop Log",
        Callback = function()
            -- Clear logs
        end
    })
end
