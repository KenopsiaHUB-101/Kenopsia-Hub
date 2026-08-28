if getgenv().KenopsiaRunning then
    getgenv().KenopsiaRunning = false
    task.wait(0.5)
end
getgenv().KenopsiaRunning = true

-- Initialize Hub Table
if not getgenv().KenopsiaHUB then
    getgenv().KenopsiaHUB = { State = { } }
end
local HUB = getgenv().KenopsiaHUB

local baseUrl = "https://raw.githubusercontent.com/KenopsiaHUB-101/Kenopsia-Hub/main/"
local currentVersion = "1.0.0"

-- Helper Function
local function safeLoad(file)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(baseUrl .. file))()
    end)
    if not success or not result then
        warn("[Kenopsia HUB] Failed to load: " .. file .. " | Error: " .. tostring(result))
        return nil
    end
    return result
end

-- Auto-Updater
task.spawn(function()
    local versionRaw = game:HttpGet(baseUrl .. "version.json", true)
    if versionRaw then
        local HttpService = game:GetService("HttpService")
        local success, data = pcall(function() return HttpService:JSONDecode(versionRaw) end)
        if success and data and data.version and data.version ~= currentVersion then
            print("[Kenopsia HUB] New version available: " .. data.version)
        end
    end
end)

-- 1. Load UI
local uiModule = safeLoad("ui.lua")
if not uiModule then return end

-- 2. Load Debug
local debugModule = safeLoad("debug.lua")
if debugModule then debugModule(HUB) end

-- 3. Load Shop
local shopModule = safeLoad("shop.lua")
if shopModule then shopModule(HUB) end

-- 4. Load Misc
local miscModule = safeLoad("misc.lua")
if miscModule then miscModule(HUB) end

-- 5. Load Monitoring
local monitoringModule = safeLoad("monitoring.lua")
if monitoringModule then monitoringModule(HUB) end

-- 6. Load Settings
local settingsModule = safeLoad("settings.lua")
if settingsModule then settingsModule(HUB) end

-- 7. Load Bypass (Last, so UI is ready)
local bypassModule = safeLoad("bypass.lua")
if bypassModule then
    HUB.Bypass = bypassModule.Bypass
    HUB.SetBypass = bypassModule.SetBypass
    -- Start bypass active by default
    HUB.Bypass.Active = true
end

-- Load Save Config
HUB.SaveManager:LoadAutoloadConfig()

-- Notify
if HUB.Fluent and HUB.Fluent.Notify then
    HUB.Fluent:Notify({ Title = "Kenopsia HUB", Content = "Loaded Successfully!", Duration = 5 })
end
