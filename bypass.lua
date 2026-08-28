this is bypass.lua :
local function bypassMetaMethods()
    local checks = {
        "checkcaller",
        "getcallingscript",
        "getfenv",
        "setfenv",
        "getreg",
        "getgc",
        "getconnections",
        "hookfunction",
        "newcclosure"
    }
    
    local foundChecks = {}
    
    for _, check in ipairs(checks) do
        if getgenv()[check] or _G[check] then
            table.insert(foundChecks, check)
        end
    end
    
    if hookfunction then
        local originalHook = hookfunction
        hookfunction = function(func, replacement)
            return originalHook(func, function(...)
                return replacement(...)
            end)
        end
    end
    
    if setreadonly then
        setreadonly(getrenv(), false)
    end
    
    if make_writeable then
        make_writeable(getreg())
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Metamethod Bypass",
        Text = "Bypassed " .. #foundChecks .. " metamethod checks",
        Duration = 5
    })
end

local function bypassHandshakes()
    local remotes = game:GetService("ReplicatedStorage"):GetDescendants()
    local handshakeRemotes = {}
    
    for _, remote in ipairs(remotes) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            if remote.Name:lower():find("handshake") or 
               remote.Name:lower():find("validate") or 
               remote.Name:lower():find("verify") then
                table.insert(handshakeRemotes, remote.Name)
                
                if remote:IsA("RemoteEvent") then
                    local originalFire = remote.FireServer
                    remote.FireServer = function(self, ...)
                        return true
                    end
                elseif remote:IsA("RemoteFunction") then
                    local originalInvoke = remote.InvokeServer
                    remote.InvokeServer = function(self, ...)
                        return true
                    end
                end
            end
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Handshake Bypass",
        Text = "Bypassed " .. #handshakeRemotes .. " handshake remotes",
        Duration = 5
    })
end

local function bypassHookChecks()
    local hooksBypassed = 0
    
    if detour_function then
        local originalDetour = detour_function
        detour_function = function(...)
            return true
        end
        hooksBypassed = hooksBypassed + 1
    end
    
    if hookfunction then
        for _, func in pairs(getreg()) do
            if type(func) == "function" then
                pcall(function()
                    hookfunction(func, func)
                end)
                hooksBypassed = hooksBypassed + 1
            end
        end
    end
    
    if getconnections then
        for _, connection in ipairs(getconnections(game:GetService("ScriptContext").Error)) do
            connection:Disable()
            hooksBypassed = hooksBypassed + 1
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Hook Check Bypass",
        Text = "Bypassed " .. hooksBypassed .. " hook checks",
        Duration = 5
    })
end

local function bypassDetours()
    local detoursBypassed = 0
    
    local criticalFunctions = {
        "Instance.new",
        "getfenv",
        "setfenv",
        "getreg",
        "getgc",
        "checkcaller"
    }
    
    for _, funcName in ipairs(criticalFunctions) do
        local success = pcall(function()
            local original = _G[funcName] or getgenv()[funcName]
            if original then
                _G[funcName] = original
                detoursBypassed = detoursBypassed + 1
            end
        end)
    end
    
    if getrenv then
        local env = getrenv()
        for name, func in pairs(env) do
            if type(func) == "function" and not string.find(name, "__") then
                pcall(function()
                    env[name] = func
                end)
                detoursBypassed = detoursBypassed + 1
            end
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Detour Bypass",
        Text = "Restored " .. detoursBypassed .. " detoured functions",
        Duration = 5
    })
end

local function bypassMemoryChecks()
    local memoryPatches = 0
    
    if setreadonly then
        pcall(function() setreadonly(getrenv(), false) end)
        pcall(function() setreadonly(getreg(), false) end)
        pcall(function() setreadonly(getgc(), false) end)
        memoryPatches = memoryPatches + 3
    end
    
    for _, script in ipairs(getscripts()) do
        if script and script:IsA("LocalScript") then
            pcall(function()
                script.Enabled = true
                memoryPatches = memoryPatches + 1
            end)
        end
    end
    
    if getgc then
        for _, obj in ipairs(getgc()) do
            if type(obj) == "table" and rawget(obj, "__acsignature") then
                rawset(obj, "__acsignature", nil)
                memoryPatches = memoryPatches + 1
            end
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Memory Bypass",
        Text = "Applied " .. memoryPatches .. " memory patches",
        Duration = 5
    })
end

local function bypassVMChecks()
    local vmBypasses = 0
    
    if debug then
        debug.info = function() return "C" end
        debug.traceback = function() return "" end
        vmBypasses = vmBypasses + 2
    end
    
    if getcallingscript then
        local original = getcallingscript
        getcallingscript = function() return nil end
        vmBypasses = vmBypasses + 1
    end
    
    if getfenv then
        for i = 1, 10 do
            pcall(function()
                local env = getfenv(i)
                if env and env.script then
                    env.script = nil
                    vmBypasses = vmBypasses + 1
                end
            end)
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "VM Check Bypass",
        Text = "Applied " .. vmBypasses .. " VM detection bypasses",
        Duration = 5
    })
end

local function bypassSignatures()
    local signaturesBypassed = 0
    
    local signatureTables = {
        "_G",
        "shared",
        "getgenv",
        "getrenv"
    }
    
    for _, tableName in ipairs(signatureTables) do
        local target = _G[tableName] or getgenv()[tableName]
        if target and type(target) == "table" then
            for key, value in pairs(target) do
                if string.find(tostring(key), "signature") or 
                   string.find(tostring(key), "checksum") or
                   string.find(tostring(key), "hash") then
                    target[key] = nil
                    signaturesBypassed = signaturesBypassed + 1
                end
            end
        end
    end
    
    if getscripts then
        for _, script in ipairs(getscripts()) do
            if script and script:IsA("LocalScript") then
                pcall(function()
                    script.Name = game:GetService("HttpService"):GenerateGUID(false)
                    signaturesBypassed = signaturesBypassed + 1
                end)
            end
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Signature Bypass",
        Text = "Cleared " .. signaturesBypassed .. " signatures",
        Duration = 5
    })
end

local function bypassIntegrityChecks()
    local integrityBypasses = 0
    
    if getconnections then
        for _, connection in ipairs(getconnections(game:GetService("ScriptContext").ScriptAdded)) do
            connection:Disable()
            integrityBypasses = integrityBypasses + 1
        end
        
        for _, connection in ipairs(getconnections(game:GetService("ScriptContext").ScriptRemoved)) do
            connection:Disable()
            integrityBypasses = integrityBypasses + 1
        end
    end
    
    local modules = game:GetService("ReplicatedStorage"):GetDescendants()
    for _, module in ipairs(modules) do
        if module:IsA("ModuleScript") and 
           (module.Name:lower():find("integrity") or 
            module.Name:lower():find("security") or
            module.Name:lower():find("anti")) then
            pcall(function()
                module:Destroy()
                integrityBypasses = integrityBypasses + 1
            end)
        end
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Integrity Bypass",
        Text = "Applied " .. integrityBypasses .. " integrity bypasses",
        Duration = 5
    })
end

-- Run all bypass methods sequentially
task.spawn(function()
    bypassMetaMethods()
    task.wait(1)
    bypassHandshakes()
    task.wait(1)
    bypassHookChecks()
    task.wait(1)
    bypassDetours()
    task.wait(1)
    bypassMemoryChecks()
    task.wait(1)
    bypassVMChecks()
    task.wait(1)
    bypassSignatures()
    task.wait(1)
    bypassIntegrityChecks()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Auto Bypass Complete",
        Text = "All anti cheat bypass methods have been applied",
        Duration = 8
    })
end)

ini BuildAndCrush.lua : 

if getgenv().KenopsiaRunning then
    getgenv().KenopsiaRunning = false
    task.wait(0.5)
end
getgenv().KenopsiaRunning = true

local baseUrl = "https://raw.githubusercontent.com/KenopsiaHUB-101/Kenopsia-Hub/main/"
local currentVersion = "1.0.0"

-- 1. Helper Function Fetch Script (Fail-Safe)
local function safeLoad(file)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(baseUrl .. file))()
    end)
    if not success or not result then
        warn("[Kenopsia HUB] Gagal memuat file: " .. file .. " | Error: " .. tostring(result))
        return nil
    end
    return result
end

-- 2. Auto-Updater Check
task.spawn(function()
    local versionRaw = game:HttpGet(baseUrl .. "version.json", true)
    if versionRaw then
        local HttpService = game:GetService("HttpService")
        local success, data = pcall(function() return HttpService:JSONDecode(versionRaw) end)
        if success and data and data.version and data.version ~= currentVersion then
            print("[Kenopsia HUB] Versi baru ditemukan: " .. data.version .. " (Versi Anda: " .. currentVersion .. ")")
        end
    end
end)

-- 3. Eksekusi Core UI & Modul Sesuai Urutan
local HUB = safeLoad("ui.lua")
if not HUB then return end

local shopModule = safeLoad("shop.lua")
if shopModule then shopModule(HUB) end

local miscModule = safeLoad("misc.lua")
if miscModule then miscModule(HUB) end

local monitoringModule = safeLoad("monitoring.lua")
if monitoringModule then monitoringModule(HUB) end

local settingsModule = safeLoad("settings.lua")
if settingsModule then settingsModule(HUB) end

-- 4. Load Config
HUB.SaveManager:LoadAutoloadConfig()

This is misc.lua : 
return function(HUB)
    local Tabs = HUB.Tabs
    local Fluent = HUB.Fluent
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    Tabs.Misc:AddParagraph({ Title = "🛠️ Movement & Player Utilities", Content = "Modifikasi pergerakan dan visual pemain." })

    -- 1. WalkSpeed & JumpPower
    Tabs.Misc:AddSlider("WalkSpeedSlider", {
        Title = "Walk Speed",
        Description = "Kecepatan Jalan Karakter",
        Default = 16,
        Min = 16,
        Max = 150,
        Rounding = 0,
        Callback = function(V)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = V
            end
        end
    })

    Tabs.Misc:AddSlider("JumpPowerSlider", {
        Title = "Jump Power",
        Description = "Tinggi Lompatan Karakter",
        Default = 50,
        Min = 50,
        Max = 200,
        Rounding = 0,
        Callback = function(V)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                hum.UseJumpPower = true
                hum.JumpPower = V
            end
        end
    })

    -- 2. Player ESP
    local playerEspActive = false
    local espHighlights = {}

    local function updatePlayerEsp()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if playerEspActive then
                    if not espHighlights[plr] or not espHighlights[plr].Parent then
                        local hl = Instance.new("Highlight")
                        hl.Name = "KenopsiaPlayerESP"
                        hl.FillColor = Color3.fromRGB(0, 255, 150)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Adornee = plr.Character
                        hl.Parent = plr.Character
                        espHighlights[plr] = hl
                    end
                else
                    if espHighlights[plr] then
                        espHighlights[plr]:Destroy()
                        espHighlights[plr] = nil
                    end
                end
            end
        end
    end

    Tabs.Misc:AddToggle("PlayerEspToggle", {
        Title = "Player ESP (Highlight Pemain)",
        Default = false,
        Callback = function(V)
            playerEspActive = V
            updatePlayerEsp()
        end
    })

    -- 3. Smart Noclip
    local smartNoclipActive = false
    RunService.Stepped:Connect(function()
        if not getgenv().KenopsiaRunning then return end
        if smartNoclipActive and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end)

    Tabs.Misc:AddToggle("SmartNoclipToggle", {
        Title = "Smart Noclip",
        Default = false,
        Callback = function(V) smartNoclipActive = V end
    })

    -- 4. Fly System
    local flyingActive = false
    local flySpeed = 50
    local bodyVel, bodyGyro

    Tabs.Misc:AddToggle("FlyToggle", {
        Title = "Player Fly (Terbang)",
        Default = false,
        Callback = function(V)
            flyingActive = V
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local root = char.HumanoidRootPart

            if flyingActive then
                bodyVel = Instance.new("BodyVelocity")
                bodyGyro = Instance.new("BodyGyro")
                bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                bodyVel.Parent = root
                bodyGyro.Parent = root
                
                task.spawn(function()
                    while flyingActive and getgenv().KenopsiaRunning do
                        local camCF = workspace.CurrentCamera.CFrame
                        local moveDir = Vector3.zero
                        local UIS = game:GetService("UserInputService")
                        
                        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end

                        bodyVel.Velocity = moveDir * flySpeed
                        bodyGyro.CFrame = camCF
                        task.wait()
                    end
                    if bodyVel then bodyVel:Destroy() end
                    if bodyGyro then bodyGyro:Destroy() end
                end)
            else
                if bodyVel then bodyVel:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
            end
        end
    })

    -- 5. Utilitas Tambahan
    Tabs.Misc:AddButton({
        Title = "Auto Flip Vehicle / Character",
        Callback = function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = CFrame.new(root.Position + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.rad(root.Orientation.Y), 0) end
        end
    })

    Tabs.Misc:AddButton({
        Title = "Clear Local Debris (Anti-Lag)",
        Callback = function()
            local count = 0
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored and not part.Parent:FindFirstChildOfClass("Humanoid") then
                    if not part.Parent:IsA("Accessory") then part:Destroy() count = count + 1 end
                end
            end
            Fluent:Notify({ Title = "Anti-Lag", Content = "Menghapus " .. count .. " puing!", Duration = 3 })
        end
    })
end

this is monitoring.lua :

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

this is settings.lua : 

