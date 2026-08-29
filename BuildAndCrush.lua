-- ==========================================
-- KENOPSIA HUB - MAIN LOADER
-- ==========================================

if getgenv().KenopsiaRunning then
    getgenv().KenopsiaRunning = false
    task.wait(0.5)
end
getgenv().KenopsiaRunning = true

local baseUrl = "https://raw.githubusercontent.com/KenopsiaHUB-101/Kenopsia-Hub/main/"
local currentVersion = "1.0.0"

-- ==================== DEBUG INITIALIZATION ====================
print("[KENOPSIA] Initializing debug system...")

local Debug = nil
pcall(function()
    local content = game:HttpGet(baseUrl .. "debug.lua")
    if content and content ~= "" then
        local fn = loadstring(content)
        if fn then
            Debug = fn()
        end
    end
end)

if not Debug then
    warn("[KENOPSIA] Failed to load debug module")
    Debug = {
        Info = function() end,
        Success = function() end,
        Error = function() end,
        Warning = function() end,
        Debug = function() end,
        Initialize = function() end
    }
end

Debug:Initialize()
if Debug.Info then Debug:Info("Kenopsia HUB v" .. currentVersion .. " starting...") end

-- ==================== PREMIUM SYSTEM INITIALIZATION ====================
if Debug.Debug then Debug:Debug("Loading premium system...") end

local Premium = nil
pcall(function()
    local content = game:HttpGet(baseUrl .. "premium.lua")
    if content and content ~= "" then
        local fn = loadstring(content)
        if fn then
            Premium = fn()
        end
    end
end)

if not Premium then
    if Debug.Error then Debug:Error("Failed to load premium system") end
    Premium = {
        isPremium = false,
        HasFeature = function() return false end,
        ValidateKey = function() return false end
    }
end

-- Set initial premium key (can be validated by Panda Auth)
Premium:ValidateKey("kenopsia_hub123")
if Debug.Success then Debug:Success("Premium system initialized") end

-- ==================== SAFE LOAD FUNCTION ====================
local function safeLoad(file)
    if Debug.Debug then Debug:Debug("Loading file: " .. file) end
    
    local success, result = pcall(function()
        local url = baseUrl .. file
        local content = game:HttpGet(url)
        if not content or content == "" then
            return nil
        end
        return loadstring(content)()
    end)
    
    if not success or not result then
        if Debug.Error then Debug:Error("Failed to load " .. file .. ": " .. tostring(result)) end
        return nil
    end
    
    if Debug.Success then Debug:Success("Successfully loaded: " .. file) end
    return result
end

-- ==================== AUTO-UPDATE CHECK ====================
task.spawn(function()
    if Debug.Debug then Debug:Debug("Checking for updates...") end
    
    local success, versionRaw = pcall(function()
        return game:HttpGet(baseUrl .. "version.json", true)
    end)
    
    if success and versionRaw then
        local HttpService = game:GetService("HttpService")
        local decodeSuccess, data = pcall(function() 
            return HttpService:JSONDecode(versionRaw) 
        end)
        
        if decodeSuccess and data and data.version then
            if data.version ~= currentVersion then
                if Debug.Warning then 
                    Debug:Warning("New version available: " .. data.version .. " (Current: " .. currentVersion .. ")") 
                end
            else
                if Debug.Info then Debug:Info("You are running the latest version") end
            end
        end
    end
end)

-- ==================== LOAD UI MODULE ====================
if Debug.Info then Debug:Info("Loading UI module...") end

local HUB = safeLoad("ui.lua")
if not HUB then
    if Debug.Error then Debug:Error("Failed to load UI module - aborting") end
    return
end

if Debug.Success then Debug:Success("UI module ready") end

-- ==================== LOAD BYPASS MODULE ====================
if Debug.Info then Debug:Info("Checking bypass access...") end

if Premium:HasFeature("bypass") then
    task.spawn(function()
        if Debug.Debug then Debug:Debug("Loading bypass module...") end
        local bypassSuccess = safeLoad("bypass.lua")
        if bypassSuccess then
            if Debug.Success then Debug:Success("Bypass module activated") end
        else
            if Debug.Warning then Debug:Warning("Bypass module failed to load") end
        end
    end)
else
    if Debug.Warning then Debug:Warning("Bypass feature requires premium access") end
end

-- ==================== LOAD FEATURE MODULES ====================
if Debug.Info then Debug:Info("Loading feature modules...") end

local shopModule = safeLoad("shop.lua")
if shopModule then
    if Debug.Debug then Debug:Debug("Initializing shop module...") end
    shopModule(HUB)
    if Debug.Success then Debug:Success("Shop module ready") end
else
    if Debug.Warning then Debug:Warning("Shop module failed to load") end
end

local miscModule = safeLoad("misc.lua")
if miscModule then
    if Debug.Debug then Debug:Debug("Initializing misc module...") end
    miscModule(HUB)
    if Debug.Success then Debug:Success("Misc module ready") end
else
    if Debug.Warning then Debug:Warning("Misc module failed to load") end
end

local monitoringModule = safeLoad("monitoring.lua")
if monitoringModule then
    if Debug.Debug then Debug:Debug("Initializing monitoring module...") end
    monitoringModule(HUB)
    if Debug.Success then Debug:Success("Monitoring module ready") end
else
    if Debug.Warning then Debug:Warning("Monitoring module failed to load") end
end

local settingsModule = safeLoad("settings.lua")
if settingsModule then
    if Debug.Debug then Debug:Debug("Initializing settings module...") end
    settingsModule(HUB)
    if Debug.Success then Debug:Success("Settings module ready") end
else
    if Debug.Warning then Debug:Warning("Settings module failed to load") end
end

-- ==================== LOAD CONFIGURATION ====================
if Debug.Debug then Debug:Debug("Loading user configuration...") end

if HUB.SaveManager and HUB.SaveManager.LoadAutoloadConfig then
    pcall(function()
        HUB.SaveManager:LoadAutoloadConfig()
        if Debug.Success then Debug:Success("Configuration loaded") end
    end)
else
    if Debug.Debug then Debug:Debug("SaveManager not available for config loading") end
end

-- ==================== FINAL STATUS ====================
if Debug.Success then
    Debug:Success("=====================================================")
    Debug:Success("KENOPSIA HUB v" .. currentVersion .. " FULLY LOADED")
    Debug:Success("Premium Status: " .. (Premium.isPremium and "ACTIVE ✓" or "INACTIVE ✗"))
    Debug:Success("=====================================================")
end

-- ==================== GLOBAL REFERENCES ====================
_G.KenopsiaDebug = Debug
_G.KenopsiaPremium = Premium
_G.KenopsiaHUB = HUB

if Debug.Info then Debug:Info("All systems online - Ready to use!") end
