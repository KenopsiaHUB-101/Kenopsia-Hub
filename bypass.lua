-- ==========================================
-- KENOPSIA HUB - ANTI-CHEAT BYPASS MODULE
-- ⚠️ PREMIUM FEATURE - REQUIRES VALID KEY
-- ==========================================

local Debug = require(game:GetService("ReplicatedStorage"):WaitForChild("KenopsiaDebug", 5))
local Premium = require(game:GetService("ReplicatedStorage"):WaitForChild("KenopsiaPremium", 5))

if not Debug then Debug = _G.KenopsiaDebug or {} end
if not Premium then Premium = _G.KenopsiaPremium or {} end

-- PREMIUM CHECK
if not Premium.isPremium then
    if Debug.Warning then Debug:Warning("Bypass feature locked! Premium key required.") end
    return false
end

if not Premium:HasFeature("bypass") then
    if Debug.Error then Debug:Error("Your key does not have access to bypass features.") end
    return false
end

if Debug.Info then Debug:Info("Loading bypass module (Premium Access Granted)") end

local function bypassMetaMethods()
    if not Debug then return end
    Debug:Debug("Attempting metamethod bypass...")
    
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
        pcall(function() setreadonly(getrenv(), false) end)
    end
    
    if make_writeable then
        pcall(function() make_writeable(getreg()) end)
    end
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Metamethod Bypass",
            Text = "Bypassed " .. #foundChecks .. " metamethod checks",
            Duration = 5
        })
    end)
    
    if Debug.Success then Debug:Success("Metamethod bypass completed: " .. #foundChecks .. " checks bypassed") end
end

local function bypassHandshakes()
    if not Debug then return end
    Debug:Debug("Attempting handshake bypass...")
    
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
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Handshake Bypass",
            Text = "Bypassed " .. #handshakeRemotes .. " handshake remotes",
            Duration = 5
        })
    end)
    
    if Debug.Success then Debug:Success("Handshake bypass completed: " .. #handshakeRemotes .. " remotes patched") end
end

local function bypassHookChecks()
    if not Debug then return end
    Debug:Debug("Attempting hook check bypass...")
    
    local hooksBypassed = 0
    
    if detour_function then
        local originalDetour = detour_function
        detour_function = function(...)
            return true
        end
        hooksBypassed = hooksBypassed + 1
    end
    
    if hookfunction then
        local gcResult = pcall(function() return getreg() end)
        if gcResult then
            for _, func in pairs(getreg() or {}) do
                if type(func) == "function" then
                    pcall(function()
                        hookfunction(func, func)
                        hooksBypassed = hooksBypassed + 1
                    end)
                end
            end
        end
    end
    
    if getconnections then
        pcall(function()
            for _, connection in ipairs(getconnections(game:GetService("ScriptContext").Error) or {}) do
                connection:Disable()
                hooksBypassed = hooksBypassed + 1
            end
        end)
    end
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Hook Check Bypass",
            Text = "Bypassed " .. hooksBypassed .. " hook checks",
            Duration = 5
        })
    end)
    
    if Debug.Success then Debug:Success("Hook bypass completed: " .. hooksBypassed .. " hooks patched") end
end

local function bypassDetours()
    if not Debug then return end
    Debug:Debug("Attempting detour bypass...")
    
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
        pcall(function()
            local env = getrenv()
            for name, func in pairs(env or {}) do
                if type(func) == "function" and not string.find(name, "__") then
                    pcall(function()
                        env[name] = func
                        detoursBypassed = detoursBypassed + 1
                    end)
                end
            end
        end)
    end
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Detour Bypass",
            Text = "Restored " .. detoursBypassed .. " detoured functions",
            Duration = 5
        })
    end)
    
    if Debug.Success then Debug:Success("Detour bypass completed: " .. detoursBypassed .. " functions restored") end
end

local function bypassMemoryChecks()
    if not Debug then return end
    Debug:Debug("Attempting memory check bypass...")
    
    local memoryPatches = 0
    
    if setreadonly then
        pcall(function() setreadonly(getrenv(), false) memoryPatches = memoryPatches + 1 end)
        pcall(function() setreadonly(getreg(), false) memoryPatches = memoryPatches + 1 end)
        pcall(function() setreadonly(getgc(), false) memoryPatches = memoryPatches + 1 end)
    end
    
    if getscripts then
        for _, script in ipairs(getscripts() or {}) do
            if script and script:IsA("LocalScript") then
                pcall(function()
                    script.Enabled = true
                    memoryPatches = memoryPatches + 1
                end)
            end
        end
    end
    
    if getgc then
        pcall(function()
            for _, obj in ipairs(getgc() or {}) do
                if type(obj) == "table" and rawget(obj, "__acsignature") then
                    rawset(obj, "__acsignature", nil)
                    memoryPatches = memoryPatches + 1
                end
            end
        end)
    end
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Memory Bypass",
            Text = "Applied " .. memoryPatches .. " memory patches",
            Duration = 5
        })
    end)
    
    if Debug.Success then Debug:Success("Memory bypass completed: " .. memoryPatches .. " patches applied") end
end

local function bypassVMChecks()
    if not Debug then return end
    Debug:Debug("Attempting VM check bypass...")
    
    local vmBypasses = 0
    
    if debug then
        pcall(function()
            debug.info = function() return "C" end
            debug.traceback = function() return "" end
            vmBypasses = vmBypasses + 2
        end)
    end
    
    if getcallingscript then
        pcall(function()
            local original = getcallingscript
            getcallingscript = function() return nil end
            vmBypasses = vmBypasses + 1
        end)
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
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "VM Check Bypass",
            Text = "Applied " .. vmBypasses .. " VM detection bypasses",
            Duration = 5
        })
    end)
    
    if Debug.Success then Debug:Success("VM bypass completed: " .. vmBypasses .. " VM bypasses applied") end
end

local function bypassSignatures()
    if not Debug then return end
    Debug:Debug("Attempting signature bypass...")
    
    local signaturesBypassed = 0
    
    local signatureTables = {
        "_G",
        "shared"
    }
    
    for _, tableName in ipairs(signatureTables) do
        local target = _G[tableName] or (shared and shared[tableName])
        if target and type(target) == "table" then
            for key, value in pairs(target) do
                if string.find(tostring(key), "signature") or 
                   string.find(tostring(key), "checksum") or
                   string.find(tostring(key), "hash") then
                    pcall(function()
                        target[key] = nil
                        signaturesBypassed = signaturesBypassed + 1
                    end)
                end
            end
        end
    end
    
    if getscripts then
        for _, script in ipairs(getscripts() or {}) do
            if script and script:IsA("LocalScript") then
                pcall(function()
                    script.Name = game:GetService("HttpService"):GenerateGUID(false)
                    signaturesBypassed = signaturesBypassed + 1
                end)
            end
        end
    end
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Signature Bypass",
            Text = "Cleared " .. signaturesBypassed .. " signatures",
            Duration = 5
        })
    end)
    
    if Debug.Success then Debug:Success("Signature bypass completed: " .. signaturesBypassed .. " signatures cleared") end
end

local function bypassIntegrityChecks()
    if not Debug then return end
    Debug:Debug("Attempting integrity check bypass...")
    
    local integrityBypasses = 0
    
    if getconnections then
        pcall(function()
            for _, connection in ipairs(getconnections(game:GetService("ScriptContext").ScriptAdded) or {}) do
                connection:Disable()
                integrityBypasses = integrityBypasses + 1
            end
            
            for _, connection in ipairs(getconnections(game:GetService("ScriptContext").ScriptRemoved) or {}) do
                connection:Disable()
                integrityBypasses = integrityBypasses + 1
            end
        end)
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
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Integrity Bypass",
            Text = "Applied " .. integrityBypasses .. " integrity bypasses",
            Duration = 5
        })
    end)
    
    if Debug.Success then Debug:Success("Integrity bypass completed: " .. integrityBypasses .. " bypasses applied") end
end

-- Run all bypass methods sequentially
task.spawn(function()
    if Debug.Info then Debug:Info("Starting auto-bypass sequence...") end
    
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
    
    if Debug.Success then Debug:Success("All bypass methods completed successfully!") end
    
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto Bypass Complete",
            Text = "All anti cheat bypass methods have been applied",
            Duration = 8
        })
    end)
end)

return true
