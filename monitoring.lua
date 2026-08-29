-- ==========================================
-- KENOPSIA HUB - MONITORING MODULE
-- ==========================================

local Debug = _G.KenopsiaDebug or {
    Info = function() end,
    Success = function() end,
    Error = function() end,
    Warning = function() end,
    Debug = function() end
}

return function(HUB)
    if Debug.Info then Debug:Info("Loading monitoring module...") end
    
    local Tabs = HUB.Tabs
    local State = HUB.State
    local LocalPlayer = game:GetService("Players").LocalPlayer

    if not LocalPlayer then
        if Debug.Error then Debug:Error("LocalPlayer not found") end
        return
    end

    local StatsParagraph = Tabs.Monitoring:AddParagraph({ Title = "📊 Session Statistics", Content = "Monitoring aktif..." })
    local LogsParagraph = Tabs.Monitoring:AddParagraph({ Title = "📋 Purchase History", Content = "Belum ada log." })
    local DevInfoParagraph = Tabs.Monitoring:AddParagraph({ Title = "⚡ Real-time Memory Status", Content = "Loading..." })

    State.addLog = function(msg)
        pcall(function()
            local timeStr = os.date("%H:%M:%S")
            table.insert(State.logHistory, 1, string.format("[%s] %s", timeStr, msg))
            if #State.logHistory > 15 then table.remove(State.logHistory, 16) end
            
            local userDisplay = State.streamproofActive and "[PROTECTED USER]" or (LocalPlayer and LocalPlayer.Name) or "Unknown"
            local uptimeSec = os.time() - State.sessionStats.startTime
            local uptimeHours = math.floor(uptimeSec / 3600)
            local uptimeMin = math.floor((uptimeSec % 3600) / 60)
            local uptimeSecs = uptimeSec % 60
            
            local statsHeader = string.format("👤 User: %s\n⏱️ Uptime: %02d:%02d:%02d | 📦 Total Bought: %d\n\n", 
                userDisplay, uptimeHours, uptimeMin, uptimeSecs, State.sessionStats.itemsBought)
            
            StatsParagraph:SetDesc(statsHeader)
            LogsParagraph:SetDesc(table.concat(State.logHistory, "\n"))
        end)
    end

    -- Real-time memory monitoring
    task.spawn(function()
        while getgenv().KenopsiaRunning do
            task.wait(2)
            pcall(function()
                local memUsage = 0
                
                -- Try to get memory usage from multiple sources
                if gcinfo then
                    memUsage = gcinfo()
                elseif collectgarbage then
                    memUsage = collectgarbage("count")
                end
                
                -- Convert to MB if in KB
                if memUsage > 1000 then
                    memUsage = memUsage / 1024
                end
                
                local streamproofStatus = State.streamproofActive and "ON 🔒" or "OFF"
                local memText = string.format("• Lua Memory Usage: %.2f MB\n• Streamproof: %s", memUsage, streamproofStatus)
                
                DevInfoParagraph:SetDesc(memText)
                
                if Debug.Debug then Debug:Debug("Memory update: " .. string.format("%.2f MB", memUsage)) end
            end)
        end
    end)
    
    if Debug.Success then Debug:Success("Monitoring module loaded successfully") end
end
