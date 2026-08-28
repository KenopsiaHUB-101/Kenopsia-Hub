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
    local originalMetamethods = {}

    for _, check in ipairs(checks) do
        if getgenv()[check] or _G[check] then
            table.insert(foundChecks, check)
            -- Store original to restore if needed
            originalMetamethods[check] = _G[check] or getgenv()[check]
        end
    end
    
    if hookfunction then
        local originalHook = hookfunction
        hookfunction = function(func, replacement)
            -- Bypass wrapper
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

    return #foundChecks
end

local function bypassHandshakes()
    local remotes = game:GetService("ReplicatedStorage"):GetDescendants()
    local handshakeRemotes = {}
    
    for _, remote in ipairs(remotes) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local lowerName = remote.Name:lower()
            if lowerName:find("handshake") or lowerName:find("validate") or lowerName:find("verify") then
                table.insert(handshakeRemotes, remote.Name)
                
                if remote:IsA("RemoteEvent") then
                    -- Prevent fire server from actually sending or being detected
                    pcall(function()
                        remote.FireServer = function(self, ...) return true end
                    end)
                elseif remote:IsA("RemoteFunction") then
                    pcall(function()
                        remote.InvokeServer = function(self, ...) return true end
                    end)
                end
            end
        end
    end
    
    return #handshakeRemotes
end

local function bypassHookChecks()
    local hooksBypassed = 0
    
    if detour_function then
        detour_function = function(...) return true end
        hooksBypassed = hooksBypassed + 1
    end
    
    -- Reset hookfunction to original to avoid infinite loops in other scripts
    -- This is a risky move but often necessary for "clean" bypass
    if hookfunction then
        for _, func in pairs(getreg()) do
            if type(func) == "function" then
                pcall(function()
                    hookfunction(func, func) -- Identity hook to confuse checkers
                end)
                hooksBypassed = hooksBypassed + 1
            end
        end
    end
    
    if getconnections then
        local ctx = game:GetService("ScriptContext")
        if ctx then
            for _, connection in ipairs(getconnections(ctx.Error)) do
                connection:Disable()
                hooksBypassed = hooksBypassed + 1
            end
        end
    end
    
    return hooksBypassed
end

local function bypassMemoryChecks()
    local memoryPatches = 0
    if setreadonly then
        pcall(function() setreadonly(getrenv(), false) end)
        pcall(function() setreadonly(getreg(), false) end)
        pcall(function() setreadonly(getgc(), false) end)
        memoryPatches = memoryPatches + 3
    end
    
    -- Remove common anticheat signatures from GC
    if getgc then
        for _, obj in ipairs(getgc()) do
            if type(obj) == "table" then
                if rawget(obj, "__acsignature") then
                    rawset(obj, "__acsignature", nil)
                    memoryPatches = memoryPatches + 1
                end
                -- Clean up common anticheat flags
                if rawget(obj, "__nameguard") then
                    rawset(obj, "__nameguard", nil)
                    memoryPatches = memoryPatches + 1
                end
            end
        end
    end
    
    return memoryPatches
end

local function bypassVMChecks()
    local vmBypasses = 0
    if debug then
        debug.info = function() return "C" end
        debug.traceback = function() return "" end
        vmBypasses = vmBypasses + 2
    end
    
    if getcallingscript then
        getcallingscript = function() return nil end
        vmBypasses = vmBypasses + 1
    end
    
    return vmBypasses
end

local function bypassSignatures()
    local signaturesBypassed = 0
    local signatureTables = { "_G", "shared", "getgenv", "getrenv" }
    
    for _, tableName in ipairs(signatureTables) do
        local target = _G[tableName] or getgenv()[tableName]
        if target and type(target) == "table" then
            for key, value in pairs(target) do
                local strKey = tostring(key)
                if strKey:find("signature") or strKey:find("checksum") or strKey:find("hash") then
                    target[key] = nil
                    signaturesBypassed = signaturesBypassed + 1
                end
            end
        end
    end
    
    return signaturesBypassed
end

local function bypassIntegrityChecks()
    local integrityBypasses = 0
    local ctx = game:GetService("ScriptContext")
    
    if getconnections and ctx then
        for _, connection in ipairs(getconnections(ctx.ScriptAdded)) do
            connection:Disable()
            integrityBypasses = integrityBypasses + 1
        end
        for _, connection in ipairs(getconnections(ctx.ScriptRemoved)) do
            connection:Disable()
            integrityBypasses = integrityBypasses + 1
        end
    end
    
    return integrityBypasses
end

-- Run all bypass methods sequentially
task.spawn(function()
    local meta = bypassMetaMethods()
    task.wait(0.5)
    local handshake = bypassHandshakes()
    task.wait(0.5)
    local hooks = bypassHookChecks()
    task.wait(0.5)
    local memory = bypassMemoryChecks()
    task.wait(0.5)
    local vm = bypassVMChecks()
    task.wait(0.5)
    local sigs = bypassSignatures()
    task.wait(0.5)
    local integrity = bypassIntegrityChecks()
    
    -- Store stats in global env for debugging
    getgenv().BypassStats = {
        Meta = meta,
        Handshake = handshake,
        Hooks = hooks,
        Memory = memory,
        VM = vm,
        Signatures = sigs,
        Integrity = integrity
    }
end)

return true
 
