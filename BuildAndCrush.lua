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

local monitoringModule = safeLoad("Monitoring.lua")
if monitoringModule then monitoringModule(HUB) end

local settingsModule = safeLoad("Settings.lua")
if settingsModule then settingsModule(HUB) end

-- 4. Load Config
HUB.SaveManager:LoadAutoloadConfig()
