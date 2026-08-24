local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local zapFolder = ReplicatedStorage:WaitForChild("ZAP", 5)
if not zapFolder then
    Fluent:Notify({ Title = "Kenopsia HUB", Content = "Folder ZAP tidak ditemukan!", Duration = 6 })
    return
end

local merchantRemote = zapFolder:WaitForChild("merchant_RELIABLE")
local charmRemote = zapFolder:WaitForChild("charm_RELIABLE")

local partItemList = {
    "cube-t1", "wedge-t1", "stair-t1", "cornerWedge-t1", "cornerStair-t1",
    "pole-t1", "triangleWedge-t1", "invertedCornerWedge-t1", "invertedCornerStair-t1",
    "slab-t1", "basicWheel-t1", "utilityWheel-t1", "bigWheel-t1", "piston-t1",
    "spinner-t1", "hinge-t1", "rope-t1", "balloon-t1", "propeller-t1",
    "thruster-t1", "decoupler-t1", "rockLauncher-t1", "bumper-t1", "spike-t1",
    "sawblade-t1", "wrecker-t1", "tnt-t1"
}

local gardenItemList = {
    "basic-sprinkler", "advanced-sprinkler", "master-sprinkler",
    "structural-oil", "mechanical-oil", "combat-oil", "crateDrone"
}

local selectedItems = {}
local blacklistedItems = {}
local itemToggles = {}
local blacklistToggles = {}
local serverStockCache = {}
local bufferCache = {}

local autoBuyActive = false
local smartStockActive = true
local antiAfkActive = true
local autoReconnectActive = true
local optimizeFpsActive = false
local devLoggingActive = true
local webhookUrl = ""
local minCoinThreshold = 0
local buyDelay = 0.2
local isRunning = true
local isDevUnlocked = false

local sessionStats = {
    itemsBought = 0,
    startTime = os.time()
}

local function getCleanDisplayName(rawName)
    local clean = rawName:gsub("(%l)(%u)", "%1 %2")
    clean = clean:gsub("%-t%d+", ""):gsub("%-", " ")
    return clean:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

for _, itemName in ipairs(partItemList) do
    bufferCache[itemName] = buffer.fromstring(string.format("\0\6\0blocks%s\0%s", string.char(#itemName), itemName))
end
for _, itemName in ipairs(gardenItemList) do
    bufferCache[itemName] = buffer.fromstring(string.format("\0\6\0garden%s\0%s", string.char(#itemName), itemName))
end

local Window = Fluent:CreateWindow({
    Title = "Kenopsia HUB | v3.1 Secured DevTools",
    SubTitle = "Ultimate AFK & Password-Protected DevSuite",
    TabWidth = 120,
    Size = UDim2.fromOffset(500, 420),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Store = Window:AddTab({ Title = "Store", Icon = "shopping-cart" }),
    Presets = Window:AddTab({ Title = "Presets", Icon = "bookmark" }),
    Blacklist = Window:AddTab({ Title = "Blacklist", Icon = "shield-alert" }),
    DevTools = Window:AddTab({ Title = "DevTools (Locked)", Icon = "lock" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Logs = Window:AddTab({ Title = "Logs", Icon = "list" })
}

Fluent:Notify({ Title = "Kenopsia HUB", Content = "v3.1 Berhasil Dimuat!", SubTitle = "Tab DevTools terkunci.", Duration = 5 })

Tabs.Store:AddParagraph({ Title = "Auto Buy Store", Content = "Pilih item untuk dibeli otomatis saat stok tersedia." })
Tabs.Store:AddToggle("AutoBuyToggle", {
    Title = "Aktifkan Auto Buy",
    Default = false,
    Callback = function(Value) autoBuyActive = Value end
})

Tabs.Store:AddParagraph({ Title = "--- KATEGORI PARTS ---", Content = "" })
for _, itemName in ipairs(partItemList) do
    local dName = getCleanDisplayName(itemName)
    selectedItems[itemName] = false
    itemToggles[itemName] = Tabs.Store:AddToggle(itemName, { Title = dName, Default = false, Callback = function(Value) selectedItems[itemName] = Value end })
end

Tabs.Store:AddParagraph({ Title = "--- KATEGORI GARDEN ---", Content = "" })
for _, itemName in ipairs(gardenItemList) do
    local dName = getCleanDisplayName(itemName)
    selectedItems[itemName] = false
    itemToggles[itemName] = Tabs.Store:AddToggle(itemName, { Title = dName, Default = false, Callback = function(Value) selectedItems[itemName] = Value end })
end

Tabs.Presets:AddParagraph({ Title = "Quick Presets Manager", Content = "Pilih kombinasi cepat." })
Tabs.Presets:AddButton({
    Title = "Preset: Vehicle Parts",
    Description = "Mencentang semua komponen dasar kendaraan.",
    Callback = function()
        local vehicleItems = {"basicWheel-t1", "utilityWheel-t1", "bigWheel-t1", "piston-t1", "hinge-t1", "thruster-t1", "propeller-t1"}
        for _, itemName in ipairs(vehicleItems) do
            if itemToggles[itemName] then itemToggles[itemName]:SetValue(true) end
        end
    end
})

Tabs.Presets:AddButton({
    Title = "Preset: Farming Setup",
    Description = "Mencentang semua sprinkler dan cairan oli.",
    Callback = function()
        local farmItems = {"basic-sprinkler", "advanced-sprinkler", "master-sprinkler", "structural-oil", "mechanical-oil", "combat-oil", "crateDrone"}
        for _, itemName in ipairs(farmItems) do
            if itemToggles[itemName] then itemToggles[itemName]:SetValue(true) end
        end
    end
})

Tabs.Presets:AddButton({
    Title = "Reset / Kosongkan Pilihan",
    Description = "Menghilangkan centang pada semua item.",
    Callback = function()
        for itemName, _ in pairs(selectedItems) do
            if itemToggles[itemName] then itemToggles[itemName]:SetValue(false) end
        end
    end
})

Tabs.Blacklist:AddParagraph({ Title = "Item Blacklist / Skip List", Content = "Item yang dicekal tidak akan pernah dibeli." })
for _, itemName in ipairs(partItemList) do
    local dName = getCleanDisplayName(itemName)
    blacklistedItems[itemName] = false
    blacklistToggles[itemName] = Tabs.Blacklist:AddToggle("BL_"..itemName, { Title = "Skip: " .. dName, Default = false, Callback = function(Value) blacklistedItems[itemName] = Value end })
end

local devParagraph = Tabs.DevTools:AddParagraph({ Title = "🔒 Status: TERKUNCI", Content = "Masukkan password developer di bawah ini." })

local function buildUnlockedDevTools()
    devParagraph:SetTitle("🔓 Status: TERBUKA (Developer Mode)")
    devParagraph:SetDesc("Akses penuh diaktifkan.")

    Tabs.DevTools:AddButton({
        Title = "Load SimpleSpy (Remote Inspector GUI)",
        Description = "Membuka GUI SimpleSpy.",
        Callback = function()
            pcall(function() loadstring(game:HttpGet("https://github.com/exxtremeshock/SimpleSpy/raw/master/SimpleSpy.lua"))() end)
            Fluent:Notify({ Title = "SimpleSpy", Content = "SimpleSpy dimuat!", Duration = 3 })
        end
    })

    Tabs.DevTools:AddToggle("DevLoggingToggle", { Title = "Kenopsia Internal Remote Logger", Default = true, Callback = function(Value) devLoggingActive = Value end })

    Tabs.DevTools:AddButton({
        Title = "Test Remote FireServer (Ping Test)",
        Callback = function()
            local testBuffer = buffer.fromstring("\0\6\0blocks_test\0test")
            pcall(function() merchantRemote:FireServer(testBuffer, {}) end)
            Fluent:Notify({ Title = "DevTools", Content = "Test Remote dikirim!", Duration = 3 })
        end
    })

    Tabs.DevTools:AddButton({
        Title = "Force Garbage Collection (Clean Memory)",
        Callback = function()
            local memBefore = gcinfo() or collectgarbage("count")
            collectgarbage("collect")
            local memAfter = gcinfo() or collectgarbage("count")
            Fluent:Notify({ Title = "DevTools", Content = string.format("Merilis ±%d KB", math.floor(memBefore - memAfter)), Duration = 3 })
        end
    })

    local DevInfoParagraph = Tabs.DevTools:AddParagraph({ Title = "📊 Real-time Memory Status", Content = "Memuat..." })
    task.spawn(function()
        while isRunning do
            task.wait(2)
            pcall(function()
                local memUsage = gcinfo() or collectgarbage("count")
                DevInfoParagraph:SetDesc(string.format("• Lua Memory: %.2f MB\n• Target: %s", memUsage / 1024, tostring(merchantRemote.Name)))
            end)
        end
    end)
end

Tabs.DevTools:AddInput("DevPasswordInput", {
    Title = "Masukkan Password Developer",
    Default = "",
    Placeholder = "Password...",
    Finished = true,
    Callback = function(Value)
        if isDevUnlocked then return end
        if Value == "kenopsia2004" then
            isDevUnlocked = true
            Fluent:Notify({ Title = "Unlocked", Content = "Password benar!", Duration = 4 })
            buildUnlockedDevTools()
        else
            Fluent:Notify({ Title = "Access Denied", Content = "Password salah!", Duration = 4 })
        end
    end
})

Tabs.Settings:AddParagraph({ Title = "Pengaturan Lanjutan & Keamanan", Content = "Konfigurasi." })
Tabs.Settings:AddToggle("SmartStockToggle", { Title = "Smart Stock Check", Default = true, Callback = function(Value) smartStockActive = Value end })
Tabs.Settings:AddToggle("AntiAfkToggle", { Title = "Anti-AFK Protection", Default = true, Callback = function(Value) antiAfkActive = Value end })
Tabs.Settings:AddToggle("AutoReconnectToggle", { Title = "Auto-Reconnect", Default = true, Callback = function(Value) autoReconnectActive = Value end })
Tabs.Settings:AddToggle("OptimizeFpsToggle", { Title = "Low FPS / Background Mode", Default = false, Callback = function(Value) optimizeFpsActive = Value if not Value then setfpscap(999) end end })
Tabs.Settings:AddInput("MinCoinInput", { Title = "Batas Minimal Koin Aman", Default = "0", Numeric = true, Finished = true, Callback = function(Value) minCoinThreshold = tonumber(Value) or 0 end })
Tabs.Settings:AddInput("WebhookInput", { Title = "Discord Webhook URL", Default = "", Finished = true, Callback = function(Value) webhookUrl = Value end })
Tabs.Settings:AddInput("DelayInput", { Title = "Delay Pembelian (Detik)", Default = tostring(buyDelay), Numeric = true, Finished = false, Callback = function(Value) local num = tonumber(Value) if num and num >= 0.01 then buyDelay = num end end })

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Tabs.Logs:AddParagraph({ Title = "📊 Statistik Sesi", Content = "Monitoring." })
local LogsParagraph = Tabs.Logs:AddParagraph({ Title = "Riwayat Pembelian", Content = "Belum ada item." })

local logHistory = {}
local function addLog(msg)
    local timeStr = os.date("%H:%M:%S")
    table.insert(logHistory, 1, string.format("[%s] %s", timeStr, msg))
    if #logHistory > 15 then table.remove(logHistory, 16) end
    local uptimeSec = os.time() - sessionStats.startTime
    local statsHeader = string.format("⏱️ Durasi: %02d:%02d:%02d | 📦 Total: %d\n\n", math.floor(uptimeSec / 3600), math.floor((uptimeSec % 3600) / 60), uptimeSec % 60, sessionStats.itemsBought)
    LogsParagraph:SetDesc(statsHeader .. table.concat(logHistory, "\n"))
end

local function sendDiscordWebhook(itemName)
    if webhookUrl == "" or not webhookUrl:match("discord.com/api/webhooks") then return end
    local data = { ["content"] = "", ["embeds"] = {{ ["title"] = "Kenopsia HUB - Item Purchased!", ["description"] = getCleanDisplayName(itemName), ["color"] = 65280 }} }
    pcall(function() request({ Url = webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(data) }) end)
end

charmRemote.OnClientEvent:Connect(function(header, data)
    if type(data) == "table" then
        for _, playerData in pairs(data) do
            if type(playerData) == "table" then
                for _, userBlocks in pairs(playerData) do
                    if userBlocks and userBlocks.blocks and userBlocks.blocks.items then
                        for _, itemInfo in pairs(userBlocks.blocks.items) do
                            if itemInfo and itemInfo.stock and itemInfo.name then
                                serverStockCache[itemInfo.name] = itemInfo.stock
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function checkServerStock(itemName)
    if not smartStockActive then return 999 end
    if serverStockCache[itemName] ~= nil and serverStockCache[itemName] <= 0 then return 0 end
    return 999
end

local function beliItem(itemName)
    if blacklistedItems[itemName] then return end
    if checkServerStock(itemName) <= 0 then return end
    if bufferCache[itemName] then
        pcall(function() merchantRemote:FireServer(bufferCache[itemName], {}) end)
        sessionStats.itemsBought = sessionStats.itemsBought + 1
        addLog("Beli: " .. getCleanDisplayName(itemName))
        task.spawn(function() sendDiscordWebhook(itemName) end)
    end
end

LocalPlayer.Idled:Connect(function()
    if antiAfkActive then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

if autoReconnectActive then
    local CoreGui = game:GetService("CoreGui")
    local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
    if promptGui then
        local promptOverlay = promptGui:FindFirstChild("promptOverlay")
        if promptOverlay then
            promptOverlay.ChildAdded:Connect(function(child)
                if child.Name == "ErrorPrompt" then
                    task.wait(2)
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            end)
        end
    end
end

task.spawn(function()
    while isRunning do
        task.wait(buyDelay)
        if optimizeFpsActive then setfpscap(15) end
        if autoBuyActive then
            for itemName, isSelected in pairs(selectedItems) do
                if isSelected then task.spawn(function() beliItem(itemName) end) end
            end
        end
    end
end)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
