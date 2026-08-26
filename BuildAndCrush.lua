if getgenv().KenopsiaRunning then
    getgenv().KenopsiaRunning = false
    task.wait(0.5)
end
getgenv().KenopsiaRunning = true

local baseUrl = "https://raw.githubusercontent.com/KenopsiaHUB-101/Kenopsia-Hub/main/"

-- Step 1: Inisialisasi Core UI & Shared State
local HUB = loadstring(game:HttpGet(baseUrl .. "ui.lua"))()

-- Step 2: Eksekusi Kategori Sesuai Urutan (1 - 4)
loadstring(game:HttpGet(baseUrl .. "shop.lua"))()(HUB)          -- 1. SHOP
loadstring(game:HttpGet(baseUrl .. "misc.lua"))()(HUB)          -- 2. MISC
loadstring(game:HttpGet(baseUrl .. "Monitoring.lua"))()(HUB)    -- 3. Monitoring
loadstring(game:HttpGet(baseUrl .. "Settings.lua"))()(HUB)      -- 4. Settings

-- Step 3: Load Konfigurasi Tersimpan
HUB.SaveManager:LoadAutoloadConfig()
