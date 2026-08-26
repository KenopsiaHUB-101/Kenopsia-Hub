return function(HUB)
    local Tabs = HUB.Tabs
    local State = HUB.State
    local LocalPlayer = game:GetService("Players").LocalPlayer

    local StatsParagraph = Tabs.Monitoring:AddParagraph({ Title = "📊 Session Statistics", Content = "Monitoring aktif..." })
    local LogsParagraph = Tabs.Monitoring:AddParagraph({ Title = "📜 Purchase History", Content = "Belum ada log." })
    local DevInfoParagraph = Tabs.Monitoring:AddParagraph({ Title = "⚡ Real-time Memory Status", Content = "Loading..." })

    State.addLog = function(msg)
        local timeStr = os.date("%H:%M:%S")
        table.insert(State.logHistory, 1, string.format("[%s] %s", timeStr, msg))
        if #State.logHistory > 15 then table.remove(State.logHistory, 16) end
        
        local userDisplay = State.streamproofActive and "[PROTECTED USER]" or LocalPlayer.Name
        local uptimeSec = os.time() - State.sessionStats.startTime
        local statsHeader = string.format("👤 User: %s\n⏱️ Uptime: %02d:%02d:%02d | 📦 Total Bought: %d\n\n", 
            userDisplay, math.floor(uptimeSec / 3600), math.floor((uptimeSec % 3600) / 60), uptimeSec % 60, State.sessionStats.itemsBought)
        
        StatsParagraph:SetDesc(statsHeader)
        LogsParagraph:SetDesc(table.concat(State.logHistory, "\n"))
    end

    task.spawn(function()
        while getgenv().KenopsiaRunning do
            task.wait(2)
            pcall(function()
                local memUsage = gcinfo() or collectgarbage("count")
                DevInfoParagraph:SetDesc(string.format("• Lua Memory Usage: %.2f MB\n• Streamproof: %s", memUsage / 1024, State.streamproofActive and "ON" or "OFF"))
            end)
        end
    end)
end
