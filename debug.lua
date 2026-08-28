return function(HUB)
    local Fluent = HUB.Fluent
    local Tabs = HUB.Tabs
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    Tabs.Debug:AddParagraph({ Title = "🛠️ Debug Console", Content = "Logs and diagnostics." })

    -- 1. Memory Monitor
    local memLabel = Tabs.Debug:AddLabel({ Title = "Lua Memory: Loading..." })
    local gcLabel = Tabs.Debug:AddLabel({ Title = "GC Load: Loading..." })
    
    task.spawn(function()
        while getgenv().KenopsiaRunning do
            task.wait(2)
            local mem = collectgarbage("count")
            local gc = gcinfo()
            memLabel:SetText("Lua Memory: " .. string.format("%.2f", mem) .. " KB")
            gcLabel:SetText("GC Load: " .. string.format("%.2f", gc) .. "%")
        end
    end)

    -- 2. Remote Event Logger
    local logArea = Tabs.Debug:AddTextbox({ 
        Title = "Remote Event Log", 
        Text = "Waiting for events...", 
        MaxLines = 10 
    })

    local function logRemote(name, args)
        local timestamp = os.date("%H:%M:%S")
        local logText = string.format("[%s] Remote: %s\nArgs: %s\n", timestamp, name, table.concat(args, ", "))
        
        local currentText = logArea:GetText()
        local lines = {}
        for line in currentText:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        
        table.insert(lines, logText)
        if #lines > 50 then table.remove(lines, 1) end
        
        logArea:SetText(table.concat(lines, "\n"))
    end

    local function scanRemotes()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local originalFire = remote.FireServer
                remote.FireServer = function(self, ...)
                    logRemote(remote.Name, {...})
                    return originalFire(self, ...)
                end
            end
        end
    end
    scanRemotes()

    -- 3. Script Inspector
    local scriptCount = 0
    for _, script in ipairs(game:GetDescendants()) do
        if script:IsA("LocalScript") or script:IsA("Script") then
            scriptCount = scriptCount + 1
        end
    end
    Tabs.Debug:AddLabel({ Title = "Active Scripts: " .. scriptCount })

    -- 4. Save Debug Log
    Tabs.Debug:AddButton({
        Title = "Save Debug Log to File",
        Callback = function()
            local logContent = logArea:GetText()
            local filename = "Kenopsia_Debug_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".txt"
            
            if writefile then
                writefile(filename, logContent)
                Fluent:Notify({
                    Title = "Debug Saved",
                    Content = "Log saved to " .. filename,
                    Duration = 5
                })
            else
                Fluent:Notify({
                    Title = "No Write File",
                    Content = "Your executor doesn't support writefile.",
                    Duration = 5
                })
            end
        end
    })

    -- 5. Force GC
    Tabs.Debug:AddButton({
        Title = "Force Garbage Collection",
        Callback = function()
            collectgarbage("collect")
            Fluent:Notify({ Title = "GC Forced", Content = "Memory cleared.", Duration = 3 })
        end
    })
end

