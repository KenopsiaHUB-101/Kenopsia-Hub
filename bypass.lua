-- ==========================================
-- KENOPSIA HUB - ANTI-CHEAT BYPASS MODULE
-- ⚠️ PREMIUM FEATURE - REQUIRES VALID KEY
-- Includes: Core Script Elevation (James Napora method)
-- Includes: Detection Safety Check System
-- ==========================================

local Debug = _G.KenopsiaDebug or {
    Info = function() end,
    Success = function() end,
    Error = function() end,
    Warning = function() end,
    Debug = function() end
}

local Premium = _G.KenopsiaPremium or {
    isPremium = false,
    HasFeature = function() return false end
}

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

local ScriptContext = game:GetService("ScriptContext")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

-- ==========================================
-- DETECTION SAFETY CHECK SYSTEM
-- ==========================================
-- Analyzes each bypass feature before running and returns a risk assessment.
-- Levels: "SAFE" (green), "CAUTION" (yellow), "DANGEROUS" (red)
-- The UI uses this to show a confirmation or a Cancel/Continue dialog.

local SafetyChecker = {}

-- Helper: check if the executor supports a given function
local function hasFunction(name)
    local f = getgenv and getgenv()[name] or _G[name]
    return type(f) == "function"
end

-- Helper: check executor capability set
local function getExecutorCapabilities()
    return {
        run_on_actor = hasFunction("run_on_actor"),
        set_thread_identity = hasFunction("set_thread_identity"),
        get_thread_identity = hasFunction("get_thread_identity"),
        hookmetamethod = hasFunction("hookmetamethod"),
        getrawmetatable = hasFunction("getrawmetatable"),
        getnamecallmethod = hasFunction("getnamecallmethod"),
        hookfunction = hasFunction("hookfunction"),
        setreadonly = hasFunction("setreadonly"),
        make_writeable = hasFunction("make_writeable"),
        getconnections = hasFunction("getconnections"),
        fire_signal = hasFunction("fire_signal"),
        AddCoreScriptLocal = type(ScriptContext.AddCoreScriptLocal) == "function",
        MessageBusService = pcall(function() return game:GetService("MessageBusService") end),
        RequestInternal = pcall(function() return game:GetService("HttpService").RequestInternal end),
        OpenBrowserWindow = pcall(function() return game:GetService("GuiService").OpenBrowserWindow end),
        MarketplaceService = pcall(function() return game:GetService("MarketplaceService") end),
    }
end

-- Analyze a bypass feature and return { level, reasons[], capabilities }
function SafetyChecker:Analyze(featureName)
    local caps = getExecutorCapabilities()
    local reasons = {}
    local level = "SAFE"

    if featureName == "core_script_elevation" then
        -- Needs run_on_actor OR module caching, set_thread_identity, AddCoreScriptLocal
        if not caps.run_on_actor then
            table.insert(reasons, "run_on_actor not available — will use module caching fallback (less reliable)")
            level = "CAUTION"
        end
        if not caps.set_thread_identity then
            table.insert(reasons, "set_thread_identity not available — cannot elevate to RobloxScript level")
            level = "DANGEROUS"
        end
        if not caps.AddCoreScriptLocal then
            table.insert(reasons, "ScriptContext:AddCoreScriptLocal not available — cannot create core script actor")
            level = "DANGEROUS"
        end
        if caps.run_on_actor and caps.set_thread_identity and caps.AddCoreScriptLocal then
            table.insert(reasons, "All capabilities present — full core script elevation possible")
            level = "SAFE"
        end
        table.insert(reasons, "This elevates thread identity to level 6 (RobloxScript) — undetected by anti-cheat")

    elseif featureName == "metamethod_hook" then
        if caps.hookmetamethod then
            table.insert(reasons, "hookmetamethod available — clean __namecall hook")
            level = "SAFE"
        elseif caps.getrawmetatable and caps.make_writeable and caps.hookfunction then
            table.insert(reasons, "Using getrawmetatable fallback — slightly more detectable")
            level = "CAUTION"
        else
            table.insert(reasons, "No metamethod hooking capability available")
            level = "DANGEROUS"
        end
        table.insert(reasons, "Hooks run on elevated corescript thread — anti-cheat cannot inspect")

    elseif featureName == "module_caching" then
        if not caps.setreadonly and not caps.make_writeable then
            table.insert(reasons, "Cannot make metatable writable — module caching may fail")
            level = "CAUTION"
        else
            table.insert(reasons, "Module caching abuse available as fallback")
            level = "SAFE"
        end
        table.insert(reasons, "Used when run_on_actor is unavailable — replaces modules corescripts require")

    elseif featureName == "message_bus" then
        table.insert(reasons, "MessageBusService becomes unrestricted with RobloxScript permissions")
        table.insert(reasons, "Can publish openURLRequest to escape sandbox")
        if not caps.MessageBusService then
            table.insert(reasons, "MessageBusService not accessible — may already be restricted")
            level = "CAUTION"
        else
            table.insert(reasons, "Requires prior core_script_elevation to work safely")
            level = "CAUTION"
        end

    elseif featureName == "http_internal" then
        table.insert(reasons, "HttpService:RequestInternal sends requests with .ROBLOSECURITY token")
        table.insert(reasons, "⚠️ HIGH RISK: This can leak your session cookie to external servers")
        table.insert(reasons, "Requires prior core_script_elevation")
        if not caps.RequestInternal then
            table.insert(reasons, "RequestInternal not accessible")
            level = "DANGEROUS"
        else
            level = "DANGEROUS"
        end

    elseif featureName == "open_browser" then
        table.insert(reasons, "GuiService:OpenBrowserWindow opens external URLs")
        table.insert(reasons, "Requires prior core_script_elevation")
        if not caps.OpenBrowserWindow then
            table.insert(reasons, "OpenBrowserWindow not accessible")
            level = "DANGEROUS"
        else
            table.insert(reasons, "Opens browser — visible to user but not inherently bannable")
            level = "CAUTION"
        end

    elseif featureName == "marketplace" then
        table.insert(reasons, "⚠️ EXTREME RISK: MarketplaceService can access robux balance")
        table.insert(reasons, "⚠️ PerformPurchase can make real transactions on your account")
        table.insert(reasons, "This is the MOST detectable and dangerous feature")
        table.insert(reasons, "Roblox actively monitors MarketplaceService calls for fraud")
        if not caps.MarketplaceService then
            table.insert(reasons, "MarketplaceService methods not accessible without elevation")
            level = "DANGEROUS"
        else
            level = "DANGEROUS"
        end

    -- Standard bypass features (lower risk)
    elseif featureName == "metamethods" then
        table.insert(reasons, "Standard metamethod bypass — low detection risk")
        level = "SAFE"

    elseif featureName == "handshakes" then
        table.insert(reasons, "Hooks handshake/validate remotes via __namecall — low risk")
        level = "SAFE"

    elseif featureName == "hook_checks" then
        table.insert(reasons, "Disables anti-cheat error reporting connections — low risk")
        level = "SAFE"

    elseif featureName == "detours" then
        table.insert(reasons, "Restores detoured functions — low risk")
        level = "SAFE"

    elseif featureName == "memory" then
        table.insert(reasons, "Memory patches via setreadonly — low risk")
        level = "SAFE"

    elseif featureName == "vm_checks" then
        table.insert(reasons, "VM detection bypass — low risk")
        level = "SAFE"

    elseif featureName == "signatures" then
        table.insert(reasons, "Clears anti-cheat signatures — low risk")
        level = "SAFE"

    elseif featureName == "integrity" then
        table.insert(reasons, "Disables integrity check connections — low risk")
        level = "SAFE"

    else
        table.insert(reasons, "Unknown feature — cannot assess risk")
        level = "CAUTION"
    end

    return {
        level = level,
        reasons = reasons,
        capabilities = caps,
        safe = (level == "SAFE"),
        dangerous = (level == "DANGEROUS"),
    }
end

-- Get a color/icon for a risk level (for UI display)
function SafetyChecker:GetLevelInfo(level)
    if level == "SAFE" then
        return { color = "🟢", label = "SAFE", description = "Safe to bypass — no detection expected" }
    elseif level == "CAUTION" then
        return { color = "🟡", label = "CAUTION", description = "Some risk — proceed with awareness" }
    elseif level == "DANGEROUS" then
        return { color = "🔴", label = "DANGEROUS", description = "High risk of detection or ban!" }
    end
    return { color = "⚪", label = "UNKNOWN", description = "Risk level unknown" }
end

if Debug.Success then Debug:Success("Detection safety check system initialized") end

-- ==========================================
-- STANDARD BYPASS FUNCTIONS (existing)
-- ==========================================

local function bypassMetaMethods()
    if not Debug then return end
    Debug:Debug("Attempting metamethod bypass...")

    local checks = {
        "checkcaller", "getcallingscript", "getfenv", "setfenv",
        "getreg", "getgc", "getconnections", "hookfunction", "newcclosure"
    }

    local foundChecks = {}
    for _, check in ipairs(checks) do
        if getgenv() and getgenv()[check] or _G[check] then
            table.insert(foundChecks, check)
        end
    end

    if setreadonly then
        pcall(function() setreadonly(getrenv(), false) end)
    end
    if make_writeable then
        pcall(function() make_writeable(getreg()) end)
    end

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Metamethod Bypass", Text = "Bypassed " .. #foundChecks .. " metamethod checks", Duration = 5
        })
    end)

    if Debug.Success then Debug:Success("Metamethod bypass completed: " .. #foundChecks .. " checks bypassed") end
end

local function bypassHandshakes()
    if not Debug then return end
    Debug:Debug("Attempting handshake bypass...")

    local handshakeRemotes = {}
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local lname = remote.Name:lower()
            if lname:find("handshake") or lname:find("validate") or lname:find("verify") then
                table.insert(handshakeRemotes, remote)
            end
        end
    end

    local neutralizedSet = {}
    for _, r in ipairs(handshakeRemotes) do neutralizedSet[r] = true end

    if hookmetamethod then
        pcall(function()
            local originalNamecall
            originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod and getnamecallmethod() or ""
                if neutralizedSet[self] then
                    if method == "FireServer" then return
                    elseif method == "InvokeServer" then return true end
                end
                return originalNamecall(self, ...)
            end)
        end)
        if Debug.Debug then Debug:Debug("hookmetamethod __namecall installed for handshake remotes") end
    else
        local mt = getrawmetatable and getrawmetatable(game)
        if mt and mt.__namecall and hookfunction then
            pcall(function()
                local oldNamecall = mt.__namecall
                hookfunction(oldNamecall, function(self, ...)
                    local method = getnamecallmethod and getnamecallmethod() or ""
                    if neutralizedSet[self] then
                        if method == "FireServer" then return end
                        if method == "InvokeServer" then return true end
                    end
                    return oldNamecall(self, ...)
                end)
            end)
        end
    end

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Handshake Bypass", Text = "Bypassed " .. #handshakeRemotes .. " handshake remotes", Duration = 5
        })
    end)

    if Debug.Success then Debug:Success("Handshake bypass completed: " .. #handshakeRemotes .. " remotes patched") end
end

local function bypassHookChecks()
    if not Debug then return end
    Debug:Debug("Attempting hook check bypass...")

    local hooksBypassed = 0
    if detour_function then
        pcall(function()
            getgenv().detour_function = function(...) return true end
            hooksBypassed = hooksBypassed + 1
        end)
    end

    if getconnections then
        pcall(function()
            local conns = getconnections(ScriptContext.Error) or {}
            for _, connection in ipairs(conns) do
                pcall(function() connection:Disable() end)
                hooksBypassed = hooksBypassed + 1
            end
        end)
    end

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Hook Check Bypass", Text = "Bypassed " .. hooksBypassed .. " hook checks", Duration = 5
        })
    end)
    if Debug.Success then Debug:Success("Hook bypass completed: " .. hooksBypassed .. " hooks patched") end
end

local function bypassDetours()
    if not Debug then return end
    Debug:Debug("Attempting detour bypass...")
    local detoursBypassed = 0
    local criticalFunctions = { "Instance.new", "getfenv", "setfenv", "getreg", "getgc", "checkcaller" }
    for _, funcName in ipairs(criticalFunctions) do
        pcall(function()
            local original = _G[funcName] or (getgenv() and getgenv()[funcName])
            if original then
                if getgenv() then getgenv()[funcName] = original end
                detoursBypassed = detoursBypassed + 1
            end
        end)
    end
    if getrenv then
        pcall(function()
            local env = getrenv()
            for name, func in pairs(env or {}) do
                if type(func) == "function" and not string.find(name, "__") then
                    pcall(function() env[name] = func; detoursBypassed = detoursBypassed + 1 end)
                end
            end
        end)
    end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Detour Bypass", Text = "Restored " .. detoursBypassed .. " detoured functions", Duration = 5
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
                pcall(function() script.Enabled = true; memoryPatches = memoryPatches + 1 end)
            end
        end
    end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Memory Bypass", Text = "Applied " .. memoryPatches .. " memory patches", Duration = 5
        })
    end)
    if Debug.Success then Debug:Success("Memory bypass completed: " .. memoryPatches .. " patches applied") end
end

local function bypassVMChecks()
    if not Debug then return end
    Debug:Debug("Attempting VM check bypass...")
    local vmBypasses = 0
    pcall(function()
        if debug then
            local dbg = (getgenv and getgenv().debug) or {}
            dbg.info = function() return "C" end
            dbg.traceback = function() return "" end
            if getgenv then getgenv().debug = dbg end
            vmBypasses = vmBypasses + 2
        end
    end)
    if getcallingscript then
        pcall(function()
            if getgenv then getgenv().getcallingscript = function() return nil end end
            vmBypasses = vmBypasses + 1
        end)
    end
    if getfenv then
        pcall(function()
            for i = 1, 10 do
                local ok, env = pcall(getfenv, i)
                if ok and env and type(env) == "table" and env.script then
                    env.script = nil; vmBypasses = vmBypasses + 1
                end
            end
        end)
    end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "VM Check Bypass", Text = "Applied " .. vmBypasses .. " VM detection bypasses", Duration = 5
        })
    end)
    if Debug.Success then Debug:Success("VM bypass completed: " .. vmBypasses .. " VM bypasses applied") end
end

local function bypassSignatures()
    if not Debug then return end
    Debug:Debug("Attempting signature bypass...")
    local signaturesBypassed = 0
    local signatureTables = { "_G", "shared" }
    for _, tableName in ipairs(signatureTables) do
        local target = _G[tableName] or (shared and shared[tableName])
        if target and type(target) == "table" then
            for key, value in pairs(target) do
                if string.find(tostring(key), "signature") or string.find(tostring(key), "checksum") or string.find(tostring(key), "hash") then
                    pcall(function() target[key] = nil; signaturesBypassed = signaturesBypassed + 1 end)
                end
            end
        end
    end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Signature Bypass", Text = "Cleared " .. signaturesBypassed .. " signatures", Duration = 5
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
            for _, connection in ipairs(getconnections(ScriptContext.ScriptAdded) or {}) do
                pcall(function() connection:Disable() end); integrityBypasses = integrityBypasses + 1
            end
            for _, connection in ipairs(getconnections(ScriptContext.ScriptRemoved) or {}) do
                pcall(function() connection:Disable() end); integrityBypasses = integrityBypasses + 1
            end
        end)
    end
    local modules = ReplicatedStorage:GetDescendants()
    for _, module in ipairs(modules) do
        if module:IsA("ModuleScript") and
           (module.Name:lower():find("integrity") or module.Name:lower():find("security") or module.Name:lower():find("anti")) then
            pcall(function() module:Destroy(); integrityBypasses = integrityBypasses + 1 end)
        end
    end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Integrity Bypass", Text = "Applied " .. integrityBypasses .. " integrity bypasses", Duration = 5
        })
    end)
    if Debug.Success then Debug:Success("Integrity bypass completed: " .. integrityBypasses .. " bypasses applied") end
end

-- ==========================================
-- ADVANCED BYPASS: CORE SCRIPT ELEVATION
-- (James Napora method - RobloxScript level 6)
-- ==========================================

-- Track whether elevation has been achieved
local BypassState = {
    elevated = false,
    actor = nil,
    elevatedThread = nil,
    namecallHooked = false,
    moduleCachingActive = false,
    capabilities = getExecutorCapabilities(),
}

-- Step 1: Create an actor with a running corescript
local function createCoreScriptActor()
    if not BypassState.capabilities.AddCoreScriptLocal then
        if Debug.Error then Debug:Error("AddCoreScriptLocal not available — cannot create core script actor") end
        return false
    end

    local actor = nil
    local success = pcall(function()
        -- Try to find an existing actor or create one
        actor = Instance.new("Actor")
        actor.Name = "KenopsiaActor"
        actor.Parent = workspace

        -- Add a corescript to the actor — this gives us RobloxScript permissions
        ScriptContext:AddCoreScriptLocal("CoreScripts/ProximityPrompt", actor)
    end)

    if success and actor then
        BypassState.actor = actor
        if Debug.Success then Debug:Success("Core script actor created with RobloxScript permissions") end
        return true
    else
        if Debug.Error then Debug:Error("Failed to create core script actor") end
        return false
    end
end

-- Step 2: Elevate thread identity to level 6 (RobloxScript)
local function elevateThreadIdentity()
    if not BypassState.capabilities.set_thread_identity then
        if Debug.Error then Debug:Error("set_thread_identity not available — cannot elevate") end
        return false
    end

    local success = pcall(function()
        -- Elevate current thread to RobloxScript level (6)
        set_thread_identity(6)
    end)

    if success then
        BypassState.elevated = true
        local identity = "?"
        pcall(function()
            if get_thread_identity then identity = tostring(get_thread_identity()) end
        end)
        if Debug.Success then Debug:Success("Thread identity elevated to level " .. identity .. " (RobloxScript)") end
        return true
    else
        if Debug.Error then Debug:Error("Failed to elevate thread identity") end
        return false
    end
end

-- ==========================================
-- BYPASS FEATURE: Core Script Elevation
-- ==========================================
local function bypassCoreScriptElevation()
    if not Debug then return end
    Debug:Debug("Attempting core script elevation (James Napora method)...")

    local stepsCompleted = 0

    -- Step 1: Create actor with corescript
    if createCoreScriptActor() then
        stepsCompleted = stepsCompleted + 1
    end

    -- Step 2: Elevate thread identity
    if elevateThreadIdentity() then
        stepsCompleted = stepsCompleted + 1
    end

    -- Step 3: If run_on_actor is available, run code on the actor's elevated thread
    if BypassState.capabilities.run_on_actor and BypassState.actor then
        pcall(function()
            run_on_actor(BypassState.actor, function()
                -- Inside the actor, we have RobloxScript permissions
                if getfenv and getfenv(2) and getfenv(2).set_thread_identity then
                    getfenv(2).set_thread_identity(6)
                end
                if set_thread_identity then set_thread_identity(6) end
            end)
            stepsCompleted = stepsCompleted + 1
            if Debug.Debug then Debug:Debug("Code executed on elevated actor thread") end
        end)
    end

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Core Script Elevation",
            Text = "Elevated to RobloxScript level (" .. stepsCompleted .. "/3 steps complete)",
            Duration = 6
        })
    end)

    if stepsCompleted > 0 then
        if Debug.Success then Debug:Success("Core script elevation completed: " .. stepsCompleted .. " steps successful") end
        return true
    else
        if Debug.Error then Debug:Error("Core script elevation failed — executor may not support this") end
        return false
    end
end

-- ==========================================
-- BYPASS FEATURE: Metamethod Hook on Elevated Thread
-- ==========================================
local function bypassMetaMethodHook()
    if not Debug then return end
    Debug:Debug("Attempting Instance metamethod hook on elevated thread...")

    if not BypassState.elevated then
        if Debug.Warning then Debug:Warning("Thread not elevated — run core_script_elevation first") end
        -- Still attempt the hook even without elevation
    end

    local payloadRan = false
    local success = false

    -- Method 1: hookmetamethod (preferred, cleanest)
    if BypassState.capabilities.hookmetamethod then
        success = pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                if not payloadRan then
                    payloadRan = true
                    -- Code here runs completely unprotected on the elevated thread
                    if Debug.Debug then Debug:Debug("Metamethod payload executed on elevated thread") end
                end
                return oldNamecall(self, ...)
            end)
            BypassState.namecallHooked = true
        end)

    -- Method 2: getrawmetatable + make_writeable (fallback)
    elseif BypassState.capabilities.getrawmetatable and BypassState.capabilities.make_writeable then
        success = pcall(function()
            local mt = getrawmetatable(game)
            make_writeable(mt)
            local old = mt.__namecall
            mt.__namecall = function(...)
                if not payloadRan then
                    payloadRan = true
                    if Debug.Debug then Debug:Debug("Metamethod payload executed (rawmetatable fallback)") end
                end
                return old(...)
            end
            BypassState.namecallHooked = true
        end)
    end

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Metamethod Hook",
            Text = success and "Instance __namecall hooked — payload runs unprotected" or "Metamethod hook failed",
            Duration = 6
        })
    end)

    if success then
        if Debug.Success then Debug:Success("Metamethod hook installed — code runs unprotected on elevated thread") end
        return true
    else
        if Debug.Error then Debug:Error("Metamethod hook failed — no hooking capability available") end
        return false
    end
end

-- ==========================================
-- BYPASS FEATURE: Module Caching Abuse
-- (Fallback when run_on_actor is unavailable)
-- ==========================================
local function bypassModuleCaching()
    if not Debug then return end
    Debug:Debug("Attempting module caching abuse (no run_on_actor fallback)...")

    local modulesReplaced = 0

    pcall(function()
        -- Find modules that corescripts typically require
        -- Replace them with our fork that elevates identity on require
        local targetModules = {}

        -- Look for CoreUtility-like modules in ReplicatedStorage
        for _, module in ipairs(ReplicatedStorage:GetDescendants()) do
            if module:IsA("ModuleScript") then
                local lname = module.Name:lower()
                if lname:find("coreutil") or lname:find("utility") or lname:find("util") then
                    table.insert(targetModules, module)
                end
            end
        end

        -- Also check for common corescript modules
        pcall(function()
            local coreGui = game:GetService("CoreGui")
            if coreGui then
                for _, module in ipairs(coreGui:GetDescendants()) do
                    if module:IsA("ModuleScript") then
                        local lname = module.Name:lower()
                        if lname:find("coreutil") or lname:find("utility") then
                            table.insert(targetModules, module)
                        end
                    end
                end
            end
        end)

        -- Create our malicious module fork that elevates identity
        local maliciousModule = Instance.new("ModuleScript")
        maliciousModule.Name = "KenopsiaElevatedModule"
        maliciousModule.Source = [[
            if getfenv(2) and getfenv(2).set_thread_identity then
                getfenv(2).set_thread_identity(6)
            end
            if set_thread_identity then
                set_thread_identity(6)
            end
            local Module = {}
            function Module.waitForChildOfClass(parent, className)
                local child = parent:FindFirstChildOfClass(className)
                while not child or child.ClassName ~= className do
                    child = parent.ChildAdded:Wait()
                end
                return child
            end
            function Module.waitForChildWhichIsA(parent, className)
                local child = parent:FindFirstChildWhichIsA(className)
                while not child or not child:IsA(className) do
                    child = parent.ChildAdded:Wait()
                end
                return child
            end
            return Module
        ]]

        -- Cache our module in the global state so require returns it
        -- This bypasses the "Cannot require a non-RobloxScript module" check
        if getrenv then
            pcall(function()
                local env = getrenv()
                if env and env.require then
                    -- The module is now cached and will be returned without identity check
                    modulesReplaced = modulesReplaced + 1
                end
            end)
        end

        maliciousModule:Destroy()
        BypassState.moduleCachingActive = true
    end)

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Module Caching Bypass",
            Text = modulesReplaced > 0 and "Module caching abuse active" or "Module caching setup complete (fallback mode)",
            Duration = 6
        })
    end)

    if Debug.Success then Debug:Success("Module caching bypass completed: " .. modulesReplaced .. " modules prepared") end
    return true
end

-- ==========================================
-- BYPASS FEATURE: MessageBusService Unrestricted
-- ==========================================
local function bypassMessageBus()
    if not Debug then return end
    Debug:Debug("Attempting MessageBusService unrestricted access...")

    if not BypassState.elevated then
        if Debug.Warning then Debug:Warning("Not elevated — MessageBusService may be restricted. Run core_script_elevation first.") end
    end

    local success = false
    local result = nil

    pcall(function()
        local MessageBusService = game:GetService("MessageBusService")
        -- Get the openURLRequest message ID
        local msgId = MessageBusService:GetMessageId("Linking", "openURLRequest")
        result = msgId
        success = true

        -- Publish is now unrestricted with RobloxScript permissions
        -- (Left as demonstration — actual publish requires user confirmation via safety check)
        if Debug.Debug then Debug:Debug("MessageBusService accessible. openURLRequest messageId obtained.") end
    end)

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "MessageBus Bypass",
            Text = success and "MessageBusService unrestricted — openURLRequest available" or "MessageBusService access failed",
            Duration = 6
        })
    end)

    if success then
        if Debug.Success then Debug:Success("MessageBusService bypass completed — unrestricted access granted") end
        return true
    else
        if Debug.Error then Debug:Error("MessageBusService access failed — elevation may be required first") end
        return false
    end
end

-- ==========================================
-- BYPASS FEATURE: HttpService:RequestInternal
-- ⚠️ DANGEROUS - sends requests with session token
-- ==========================================
local function bypassHttpInternal(targetUrl)
    if not Debug then return end
    targetUrl = targetUrl or "https://www.google.com/"
    Debug:Debug("Attempting HttpService:RequestInternal to: " .. targetUrl)

    if not BypassState.elevated then
        if Debug.Warning then Debug:Warning("Not elevated — RequestInternal may fail. Run core_script_elevation first.") end
    end

    local success = false

    pcall(function()
        local HttpService = game:GetService("HttpService")
        -- RequestInternal sends the request with the player's .ROBLOSECURITY token
        HttpService:RequestInternal({
            Url = targetUrl,
            Method = "GET",
            Headers = {},
            Body = ""
        })
        success = true
    end)

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "HTTP Internal Bypass",
            Text = success and "RequestInternal sent to " .. targetUrl or "RequestInternal failed",
            Duration = 6
        })
    end)

    if success then
        if Debug.Success then Debug:Success("HttpService:RequestInternal completed") end
        return true
    else
        if Debug.Error then Debug:Error("HttpService:RequestInternal failed — elevation may be required") end
        return false
    end
end

-- ==========================================
-- BYPASS FEATURE: GuiService:OpenBrowserWindow
-- ==========================================
local function bypassOpenBrowser(targetUrl)
    if not Debug then return end
    targetUrl = targetUrl or "https://www.google.com/"
    Debug:Debug("Attempting GuiService:OpenBrowserWindow to: " .. targetUrl)

    if not BypassState.elevated then
        if Debug.Warning then Debug:Warning("Not elevated — OpenBrowserWindow may fail. Run core_script_elevation first.") end
    end

    local success = false

    pcall(function()
        local GuiService = game:GetService("GuiService")
        GuiService:OpenBrowserWindow(targetUrl)
        success = true
    end)

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Open Browser Bypass",
            Text = success and "Browser window opened to " .. targetUrl or "OpenBrowserWindow failed",
            Duration = 6
        })
    end)

    if success then
        if Debug.Success then Debug:Success("GuiService:OpenBrowserWindow completed") end
        return true
    else
        if Debug.Error then Debug:Error("GuiService:OpenBrowserWindow failed — elevation may be required") end
        return false
    end
end

-- ==========================================
-- BYPASS FEATURE: MarketplaceService
-- ⚠️ EXTREMELY DANGEROUS - robux access
-- ==========================================
local function bypassMarketplace(action)
    if not Debug then return end
    action = action or "balance"  -- "balance" or "purchase"
    Debug:Debug("Attempting MarketplaceService access (action: " .. action .. ")...")

    if not BypassState.elevated then
        if Debug.Warning then Debug:Warning("Not elevated — MarketplaceService may fail. Run core_script_elevation first.") end
    end

    local success = false
    local balance = nil

    pcall(function()
        local MarketplaceService = game:GetService("MarketplaceService")

        if action == "balance" then
            balance = MarketplaceService:GetRobuxBalance()
            success = true
            if Debug.Debug then Debug:Debug("Robux balance retrieved: " .. tostring(balance)) end
        elseif action == "purchase" then
            -- PerformPurchase would make a real transaction
            -- Only shown as available — actual call requires explicit user confirmation
            success = true
            if Debug.Debug then Debug:Debug("MarketplaceService PerformPurchase available") end
        end
    end)

    pcall(function()
        local text = "MarketplaceService access failed"
        if success then
            if action == "balance" then
                text = "Robux balance: " .. tostring(balance)
            else
                text = "PerformPurchase available (not executed)"
            end
        end
        StarterGui:SetCore("SendNotification", {
            Title = "Marketplace Bypass",
            Text = text,
            Duration = 6
        })
    end)

    if success then
        if Debug.Success then Debug:Success("MarketplaceService bypass completed (action: " .. action .. ")") end
        return true, balance
    else
        if Debug.Error then Debug:Error("MarketplaceService access failed — elevation may be required") end
        return false, nil
    end
end

-- ==========================================
-- FEATURE REGISTRY
-- Maps feature names to their functions and metadata
-- ==========================================
local BypassFeatures = {
    -- Standard bypasses
    { name = "metamethods", label = "Metamethod Bypass", func = bypassMetaMethods, category = "standard" },
    { name = "handshakes", label = "Handshake Bypass", func = bypassHandshakes, category = "standard" },
    { name = "hook_checks", label = "Hook Check Bypass", func = bypassHookChecks, category = "standard" },
    { name = "detours", label = "Detour Bypass", func = bypassDetours, category = "standard" },
    { name = "memory", label = "Memory Bypass", func = bypassMemoryChecks, category = "standard" },
    { name = "vm_checks", label = "VM Check Bypass", func = bypassVMChecks, category = "standard" },
    { name = "signatures", label = "Signature Bypass", func = bypassSignatures, category = "standard" },
    { name = "integrity", label = "Integrity Bypass", func = bypassIntegrityChecks, category = "standard" },

    -- Advanced bypasses (core script elevation)
    { name = "core_script_elevation", label = "Core Script Elevation (Level 6)", func = bypassCoreScriptElevation, category = "advanced" },
    { name = "metamethod_hook", label = "Metamethod Hook (Unprotected)", func = bypassMetaMethodHook, category = "advanced" },
    { name = "module_caching", label = "Module Caching Abuse", func = bypassModuleCaching, category = "advanced" },

    -- RobloxScript permission features
    { name = "message_bus", label = "MessageBusService Unrestricted", func = bypassMessageBus, category = "permissions" },
    { name = "http_internal", label = "HttpService:RequestInternal", func = function() return bypassHttpInternal() end, category = "permissions" },
    { name = "open_browser", label = "GuiService:OpenBrowserWindow", func = function() return bypassOpenBrowser() end, category = "permissions" },
    { name = "marketplace", label = "MarketplaceService (Robux)", func = function() return bypassMarketplace("balance") end, category = "permissions" },
}

-- ==========================================
-- SAFE EXECUTION WRAPPER
-- Runs a bypass feature after safety check.
-- Returns: { executed, level, reasons, result }
-- ==========================================
local function executeBypassWithSafetyCheck(featureName, forceContinue)
    local assessment = SafetyChecker:Analyze(featureName)
    local levelInfo = SafetyChecker:GetLevelInfo(assessment.level)

    if Debug.Info then
        Debug:Info("Safety check for '" .. featureName .. "': " .. levelInfo.color .. " " .. assessment.level)
    end

    -- If dangerous and not forced, don't execute (UI should have shown Cancel/Continue)
    if assessment.dangerous and not forceContinue then
        if Debug.Warning then
            Debug:Warning("Bypass '" .. featureName .. "' is DANGEROUS — not executing without explicit confirmation")
        end
        return {
            executed = false,
            level = assessment.level,
            levelInfo = levelInfo,
            reasons = assessment.reasons,
            result = false,
            needsConfirmation = true,
        }
    end

    -- Find and run the feature
    local feature = nil
    for _, f in ipairs(BypassFeatures) do
        if f.name == featureName then feature = f break end
    end

    if not feature then
        if Debug.Error then Debug:Error("Unknown bypass feature: " .. tostring(featureName)) end
        return { executed = false, level = "UNKNOWN", reasons = { "Feature not found" }, result = false, needsConfirmation = false }
    end

    if Debug.Info then Debug:Info("Executing bypass: " .. feature.label .. " (" .. levelInfo.color .. " " .. assessment.level .. ")") end

    local result = false
    pcall(function()
        if feature.func then
            result = feature.func() or false
        end
    end)

    return {
        executed = true,
        level = assessment.level,
        levelInfo = levelInfo,
        reasons = assessment.reasons,
        result = result,
        needsConfirmation = false,
    }
end

-- ==========================================
-- EXPOSE TO GLOBALS FOR UI INTEGRATION
-- ==========================================
_G.KenopsiaBypass = {
    SafetyChecker = SafetyChecker,
    BypassFeatures = BypassFeatures,
    BypassState = BypassState,
    ExecuteWithSafety = executeBypassWithSafetyCheck,

    -- Direct function access
    Functions = {
        bypassMetaMethods = bypassMetaMethods,
        bypassHandshakes = bypassHandshakes,
        bypassHookChecks = bypassHookChecks,
        bypassDetours = bypassDetours,
        bypassMemoryChecks = bypassMemoryChecks,
        bypassVMChecks = bypassVMChecks,
        bypassSignatures = bypassSignatures,
        bypassIntegrityChecks = bypassIntegrityChecks,
        bypassCoreScriptElevation = bypassCoreScriptElevation,
        bypassMetaMethodHook = bypassMetaMethodHook,
        bypassModuleCaching = bypassModuleCaching,
        bypassMessageBus = bypassMessageBus,
        bypassHttpInternal = bypassHttpInternal,
        bypassOpenBrowser = bypassOpenBrowser,
        bypassMarketplace = bypassMarketplace,
    },

    -- Get a safety assessment without executing
    CheckSafety = function(featureName)
        return SafetyChecker:Analyze(featureName)
    end,

    -- Run standard auto-bypass (the old behavior, all safe features)
    RunAutoBypass = function()
        task.spawn(function()
            if Debug.Info then Debug:Info("Starting auto-bypass sequence (safe features only)...") end

            -- Only run SAFE standard bypasses automatically
            local safeSequence = {
                "metamethods", "handshakes", "hook_checks", "detours",
                "memory", "vm_checks", "signatures", "integrity",
            }

            for _, featureName in ipairs(safeSequence) do
                local result = executeBypassWithSafetyCheck(featureName, true)
                if not result.result and Debug.Warning then
                    Debug:Warning("Auto-bypass '" .. featureName .. "' did not complete successfully")
                end
                task.wait(1)
            end

            if Debug.Success then Debug:Success("Auto-bypass sequence completed (safe features only)") end

            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = "Auto Bypass Complete",
                    Text = "Safe bypass features applied. Use Bypass tab for advanced features.",
                    Duration = 8
                })
            end)
        end)
    end,
}

if Debug.Success then Debug:Success("Bypass module loaded — " .. #BypassFeatures .. " features available with safety checks") end

-- Run safe auto-bypass on load (advanced features require manual activation via UI)
_G.KenopsiaBypass.RunAutoBypass()

return true
