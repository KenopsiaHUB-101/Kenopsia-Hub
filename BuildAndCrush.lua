-- ==========================================
-- KENOPSIA HUB - FLUENT UI EDITION
-- ==========================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/Fluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Cek ketersediaan folder ZAP & Remote
local zapFolder = ReplicatedStorage:WaitForChild("ZAP", 5)
if not zapFolder then
    Fluent:Notify({
        Title = "Kenopsia HUB",
        Content = "Folder ZAP tidak ditemukan! Pastikan Anda berada di dalam game.",
        Duration = 6
    })
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
local itemToggles = {}
local serverStockCache = {}
local bufferCache = {}

local autoBuyActive = false
local smartStockActive = true
local buyDelay = 0.2
local isRunning = true

local function getCleanDisplayName(rawName)
    local clean = rawName:gsub("(%l)(%u)", "%1 %2")
    clean = clean:gsub("%-t%d+", ""):gsub("%-", " ")
    return clean:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

-- Generate Buffer
for _, itemName in ipairs(partItemList) do
    bufferCache[itemName] = buffer.fromstring(string.format("\0\6\0blocks%s\0%s", string.char(#itemName), itemName))
end
for _, itemName in ipairs(gardenItemList) do
    bufferCache[itemName] = buffer.fromstring(string.format("\0\6\0garden%s\0%s", string.char(#itemName), itemName))
end

-- Window Fluent UI (Ukuran lebih kompak & pas)
local Window = Fluent:CreateWindow({
    Title = "Kenopsia HUB | v2.5",
    SubTitle = "Auto Store",
    TabWidth = 120,
    Size = UDim2.fromOffset(480, 340),
    Acrylic = true, -- Efek blur kaca transparan khas Fluent
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Store = Window:AddTab({ Title = "Store", Icon = "shopping-cart" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    Logs = Window:AddTab({ Title = "Logs", Icon = "list" })
}

local Options = Fluent.Options

-- NOTIFIKASI SUKSES LOAD
Fluent:Notify({
    Title = "Kenopsia HUB",
    Content = "Script berhasil dimuat menggunakan Fluent UI!",
    SubContent = "Tekan RightCtrl untuk minimize.",
    Duration = 4
})

-- ================= TAB STORE =================
Tabs.Store:AddParagraph({
    Title = "Auto Buy Store",
    Content = "Pilih item di bawah untuk dibeli secara otomatis ketika stok tersedia."
})

Tabs.Store:AddToggle("AutoBuyToggle", {
    Title = "Aktifkan Auto Buy",
    Default = false,
    Callback = function(Value)
        autoBuyActive = Value
        if Value then
            Fluent:Notify({ Title = "Auto Buy", Content = "Auto Buy diaktifkan!", Duration = 2 })
        else
            Fluent:Notify({ Title = "Auto Buy", Content = "Auto Buy dimatikan.", Duration = 2 })
        end
    end
})

Tabs.Store:AddParagraph({ Title = "--- KATEGORI PARTS ---", Content = "" })

for _, itemName in ipairs(partItemList) do
    local dName = getCleanDisplayName(itemName)
    selectedItems[itemName] = false
    
    itemToggles[itemName] = Tabs.Store:AddToggle(itemName, {
        Title = dName,
        Default = false,
        Callback = function(Value)
            selectedItems[itemName] = Value
        end
    })
end

Tabs.Store:AddParagraph({ Title = "--- KATEGORI GARDEN ---", Content = "" })

for _, itemName in ipairs(gardenItemList) do
    local dName = getCleanDisplayName(itemName)
    selectedItems[itemName] = false
    
    itemToggles[itemName] = Tabs.Store:AddToggle(itemName, {
        Title = dName,
        Default = false,
        Callback = function(Value)
            selectedItems[itemName] = Value
        end
    })
end

-- ================= TAB SETTINGS =================
Tabs.Settings:AddToggle("SmartStockToggle", {
    Title = "Smart Stock Check",
    Description = "Mencegah pembelian jika stok server habis.",
    Default = true,
    Callback = function(Value)
        smartStockActive = Value
    end
})

Tabs.Settings:AddInput("DelayInput", {
    Title = "Delay Pembelian (Detik)",
    Default = tostring(buyDelay),
    Placeholder = "0.2",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0.01 then
            buyDelay = num
        end
    end
})

-- ================= TAB LOGS =================
local LogsParagraph = Tabs.Logs:AddParagraph({
    Title = "Aktivitas Pembelian",
    Content = "Belum ada item yang dibeli."
})

local logHistory = {}
local function addLog(msg)
    local timeStr = os.date("%H:%M:%S")
    table.insert(logHistory, 1, string.format("[%s] %s", timeStr, msg))
    if #logHistory > 20 then
        table.remove(logHistory, 21)
    end
    LogsParagraph:SetDesc(table.concat(logHistory, "\n"))
end

-- Stock Listener
local stockConnection = charmRemote.OnClientEvent:Connect(function(header, data)
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
    if checkServerStock(itemName) <= 0 then return end
    if bufferCache[itemName] then
        local success = pcall(function()
            merchantRemote:FireServer(bufferCache[itemName], {})
        end)
        if success then
            addLog("Berhasil membeli: " .. getCleanDisplayName(itemName))
        end
    end
end

-- Loop Auto-Buy Background
task.spawn(function()
    while isRunning do
        task.wait(buyDelay)
        if autoBuyActive then
            for itemName, isSelected in pairs(selectedItems) do
                if isSelected then
                    task.spawn(function() beliItem(itemName) end)
                end
            end
        end
    end
end)

-- Window Select Default Tab
Window:SelectTab(1)

