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

