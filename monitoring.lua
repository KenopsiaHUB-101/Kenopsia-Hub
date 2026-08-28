return function(HUB)
    local Fluent = HUB.Fluent
    local Tabs = HUB.Tabs
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    Tabs.Monitoring:AddParagraph({ Title = "📊 System Monitor", Content = "Real-time stats." })

    -- 1. Memory Monitor
    local memLabel = Tabs.Monitoring:AddLabel({ Title = "Lua Memory: Loading..." })
    local gcLabel = Tabs.Monitoring:AddLabel({ Title = "GC Load: Loading..." })

    task.spawn(function()
        while getgenv().KenopsiaRunning do
            task.wait(2)
            local mem = collectgarbage("count")
            local gc = gcinfo()
            memLabel:SetText("Lua Memory: " .. string.format("%.2f", mem) .. " KB")
            gcLabel:SetText("GC Load: " .. string.format("%.2f", gc) .. "%")
        end
    end)

    -- 2. Inventory Stats (Example)
    local invLabel = Tabs.Monitoring:AddLabel({ Title = "Inventory: 0 Items" })
    task.spawn(function()
        while getgenv().KenopsiaRunning do
            task.wait(1)
            -- Replace 'Inventory' with your game's actual inventory structure
            local inventory = ReplicatedStorage:FindFirstChild("Inventory") or LocalPlayer:FindFirstChild("Backpack")
            if inventory then
                local count = #inventory:GetChildren()
                invLabel:SetText("Inventory: " .. count .. " Items")
            end
        end
    end)

    -- 3. Network Latency
    local pingLabel = Tabs.Monitoring:AddLabel({ Title = "Ping: Loading..." })
    task.spawn(function()
        while getgenv().KenopsiaRunning do
            task.wait(5)
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"].Value
            pingLabel:SetText("Ping: " .. ping .. " ms")
        end
    end)
end
