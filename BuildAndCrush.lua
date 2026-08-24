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
    Fluent:Notify({ Title = "Kenopsia HUB", Content = "ZAP folder not found!", Duration = 6 })
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

-- Kamus Multi-Bahasa
local currentLang = "English"
local Translations = {
    English = {
        Store = "Store", Presets = "Presets", Blacklist = "Blacklist", DevTools = "DevTools", Settings = "Settings", Logs = "Logs",
        Locked = "🔒 Status: LOCKED", Unlocked = "🔓 Status: UNLOCKED",
        EnterPass = "Enter Developer Password", PassPlaceholder = "Type password...",
        WrongPass = "Incorrect password!", CorrectPass = "Password correct! DevTools unlocked.",
        AutoBuyTitle = "Auto Buy Store", AutoBuyDesc = "Select items to buy automatically when in stock.",
        ToggleAutoBuy = "Enable Auto Buy", PartsHeader = "--- PARTS CATEGORY ---", GardenHeader = "--- GARDEN CATEGORY ---",
        PresetsTitle = "Quick Presets Manager", PresetsDesc = "Select fast combinations.",
        PresetVehicle = "Preset: Vehicle Parts", PresetVehicleDesc = "Check all basic vehicle components.",
        PresetFarm = "Preset: Farming Setup", PresetFarmDesc = "Check all sprinklers and oils.",
        ResetPreset = "Reset / Clear Selection", ResetPresetDesc = "Uncheck all items.",
        BlacklistTitle = "Item Blacklist / Skip List", BlacklistDesc = "Blacklisted items will never be bought.",
        SettingsTitle = "Advanced Settings & Security", SettingsDesc = "Configuration options.",
        SmartStock = "Smart Stock Check", AntiAfk = "Anti-AFK Protection", AutoReconnect = "Auto-Reconnect",
        LowFps = "Low FPS / Background Mode", MinCoin = "Minimum Safe Coins", Webhook = "Discord Webhook URL", Delay = "Buy Delay (Seconds)",
        StatsTitle = "📊 Session Statistics", LogsTitle = "Purchase History", NoItem = "No items bought yet.",
        Loaded = "Loaded successfully!", LockedSub = "DevTools tab is locked."
    },
    Indonesian = {
        Store = "Toko", Presets = "Preset", Blacklist = "Daftar Hitam", DevTools = "Alat Dev", Settings = "Pengaturan", Logs = "Log",
        Locked = "🔒 Status: TERKUNCI", Unlocked = "🔓 Status: TERBUKA",
        EnterPass = "Masukkan Password Developer", PassPlaceholder = "Ketik password...",
        WrongPass = "Password salah!", CorrectPass = "Password benar! DevTools dibuka.",
        AutoBuyTitle = "Toko Beli Otomatis", AutoBuyDesc = "Pilih item untuk dibeli otomatis saat stok tersedia.",
        ToggleAutoBuy = "Aktifkan Beli Otomatis", PartsHeader = "--- KATEGORI PARTS ---", GardenHeader = "--- KATEGORI GARDEN ---",
        PresetsTitle = "Manajer Preset Cepat", PresetsDesc = "Pilih kombinasi cepat.",
        PresetVehicle = "Preset: Komponen Kendaraan", PresetVehicleDesc = "Centang semua komponen dasar kendaraan.",
        PresetFarm = "Preset: Pengaturan Pertanian", PresetFarmDesc = "Centang semua sprinkler dan oli.",
        ResetPreset = "Reset / Kosongkan Pilihan", ResetPresetDesc = "Hilangkan centang pada semua item.",
        BlacklistTitle = "Daftar Hitam / Lewati Item", BlacklistDesc = "Item yang dicekal tidak akan pernah dibeli.",
        SettingsTitle = "Pengaturan Lanjutan & Keamanan", SettingsDesc = "Opsi konfigurasi.",
        SmartStock = "Cek Stok Pintar", AntiAfk = "Perlindungan Anti-AFK", AutoReconnect = "Sambung Ulang Otomatis",
        LowFps = "FPS Rendah / Mode Latar Belakang", MinCoin = "Batas Minimal Koin Aman", Webhook = "URL Webhook Discord", Delay = "Delay Pembelian (Detik)",
        StatsTitle = "📊 Statistik Sesi", LogsTitle = "Riwayat Pembelian", NoItem = "Belum ada item yang dibeli.",
        Loaded = "Berhasil dimuat!", LockedSub = "Tab DevTools terkunci."
    },
    Spanish = {
        Store = "Tienda", Presets = "Pre ajustes", Blacklist = "Lista Negra", DevTools = "DevTools", Settings = "Ajustes", Logs = "Registros",
        Locked = "🔒 Estado: BLOQUEADO", Unlocked = "🔓 Estado: DESBLOQUEADO",
        EnterPass = "Ingrese contraseña de desarrollador", PassPlaceholder = "Escriba la contraseña...",
        WrongPass = "¡Contraseña incorrecta!", CorrectPass = "¡Contraseña correcta! DevTools desbloqueado.",
        AutoBuyTitle = "Tienda de Compra Automática", AutoBuyDesc = "Seleccione artículos para comprar automáticamente.",
        ToggleAutoBuy = "Activar Compra Automática", PartsHeader = "--- CATEGORÍA DE PIEZAS ---", GardenHeader = "--- CATEGORÍA DE JARDÍN ---",
        PresetsTitle = "Administrador de Preajustes", PresetsDesc = "Seleccione combinaciones rápidas.",
        PresetVehicle = "Preajuste: Piezas de Vehículo", PresetVehicleDesc = "Marcar componentes de vehículos.",
        PresetFarm = "Preajuste: Configuración de Granja", PresetFarmDesc = "Marcar aspersores y aceites.",
        ResetPreset = "Restablecer / Borrar Selección", ResetPresetDesc = "Desmarcar todos los elementos.",
        BlacklistTitle = "Lista Negra de Artículos", BlacklistDesc = "Los artículos en lista negra no se comprarán.",
        SettingsTitle = "Configuración Avanzada", SettingsDesc = "Opciones de configuración.",
        SmartStock = "Verificación de Stock", AntiAfk = "Protección Anti-AFK", AutoReconnect = "Reconexión Automática",
        LowFps = "FPS Bajos / Modo Fondo", MinCoin = "Monedas Mínimas Seguras", Webhook = "URL de Webhook de Discord", Delay = "Retraso de Compra (Seg)",
        StatsTitle = "📊 Estadísticas de Sesión", LogsTitle = "Historial de Compras", NoItem = "No hay artículos comprados aún.",
        Loaded = "¡Cargado con éxito!", LockedSub = "La pestaña DevTools está bloqueada."
    },
    Portuguese = {
        Store = "Loja", Presets = "Predefinições", Blacklist = "Lista Negra", DevTools = "DevTools", Settings = "Configurações", Logs = "Registros",
        Locked = "🔒 Status: BLOQUEADO", Unlocked = "🔓 Status: DESBLOQUEADO",
        EnterPass = "Digite a senha do desenvolvedor", PassPlaceholder = "Digite a senha...",
        WrongPass = "Senha incorreta!", CorrectPass = "Senha correta! DevTools desbloqueado.",
        AutoBuyTitle = "Loja de Compra Automática", AutoBuyDesc = "Selecione itens para comprar automaticamente.",
        ToggleAutoBuy = "Ativar Compra Automática", PartsHeader = "--- CATEGORIA DE PEÇAS ---", GardenHeader = "--- CATEGORIA DE JARDIM ---",
        PresetsTitle = "Gerenciador de Predefinições", PresetsDesc = "Selecione combinações rápidas.",
        PresetVehicle = "Predefinição: Peças de Veículo", PresetVehicleDesc = "Marcar componentes do veículo.",
        PresetFarm = "Predefinição: Configuração de Fazenda", PresetFarmDesc = "Marcar pulverizadores e óleos.",
        ResetPreset = "Redefinir / Limpar Seleção", PresetResetDesc = "Desmarcar todos os itens.",
        BlacklistTitle = "Lista Negra de Itens", BlacklistDesc = "Itens na lista negra nunca serão comprados.",
        SettingsTitle = "Configurações Avançadas", SettingsDesc = "Opções de configuração.",
        SmartStock = "Verificação de Estoque", AntiAfk = "Proteção Anti-AFK", AutoReconnect = "Reconexão Automática",
        LowFps = "FPS Baixo / Modo Fundo", MinCoin = "Moedas Mínimas Seguras", Webhook = "URL do Webhook do Discord", Delay = "Atraso de Compra (Seg)",
        StatsTitle = "📊 Estatísticas da Sessão", LogsTitle = "Histórico de Compras", NoItem = "Nenhum item comprado ainda.",
        Loaded = "Carregado com sucesso!", LockedSub = "A aba DevTools está bloqueada."
    },
    Russian = {
        Store = "Магазин", Presets = "Пресеты", Blacklist = "Черный список", DevTools = "Разработчик", Settings = "Настройки", Logs = "Логи",
        Locked = "🔒 Статус: ЗАБЛОКИРОВАНО", Unlocked = "🔓 Статус: РАЗБЛОКИРОВАНО",
        EnterPass = "Введите пароль разработчика", PassPlaceholder = "Введите пароль...",
        WrongPass = "Неверный пароль!", CorrectPass = "Пароль верен! Раздел разблокирован.",
        AutoBuyTitle = "Автопокупка", AutoBuyDesc = "Выберите предметы для автоматической покупки.",
        ToggleAutoBuy = "Включить автопокупку", PartsHeader = "--- КАТЕГОРИЯ ДЕТАЛЕЙ ---", GardenHeader = "--- КАТЕГОРИЯ САД ---",
        PresetsTitle = "Менеджер пресетов", PresetsDesc = "Быстрый выбор комбинаций.",
        PresetVehicle = "Пресет: Детали транспорта", PresetVehicleDesc = "Выбрать базовые компоненты.",
        PresetFarm = "Пресет: Фермерство", PresetFarmDesc = "Выбрать распылители и масла.",
        ResetPreset = "Сбросить / Очистить выбор", PresetResetDesc = "Снять выделение со всех элементов.",
        BlacklistTitle = "Черный список предметов", BlacklistDesc = "Предметы из черного списка не покупаются.",
        SettingsTitle = "Расширенные настройки", SettingsDesc = "Параметры конфигурации.",
        SmartStock = "Проверка запасов", AntiAfk = "Защита от AFK", AutoReconnect = "Автоподключение",
        LowFps = "Низкий FPS / Фоновый режим", MinCoin = "Мин. безопасных монет", Webhook = "URL Discord Webhook", Delay = "Задержка покупки (сек)",
        StatsTitle = "📊 Статистика сессии", LogsTitle = "История покупок", NoItem = "Покупок пока нет.",
        Loaded = "Успешно загружено!", LockedSub = "Вкладка разработчика заблокирована."
    },
    Chinese = {
        Store = "商店", Presets = "预设", Blacklist = "黑名单", DevTools = "开发者工具", Settings = "设置", Logs = "日志",
        Locked = "🔒 状态：已锁定", Unlocked = "🔓 状态：已解锁",
        EnterPass = "输入开发者密码", PassPlaceholder = "输入密码...",
        WrongPass = "密码错误！", CorrectPass = "密码正确！开发者工具已解锁。",
        AutoBuyTitle = "自动购买商店", AutoBuyDesc = "选择在有库存时自动购买的物品。",
        ToggleAutoBuy = "启用自动购买", PartsHeader = "--- 零件类别 ---", GardenHeader = "--- 花园类别 ---",
        PresetsTitle = "快速预设管理器", PresetsDesc = "选择快捷组合。",
        PresetVehicle = "预设：载具零件", PresetVehicleDesc = "勾选所有基础载具组件。",
        PresetFarm = "预设：农业设置", PresetFarmDesc = "勾选所有喷水器和油料。",
        PresetReset = "重置 / 清除选择", ResetPresetDesc = "取消勾选所有物品。",
        BlacklistTitle = "物品黑名单", BlacklistDesc = "黑名单中的物品将永远不会被购买。",
        SettingsTitle = "高级设置与安全", SettingsDesc = "配置选项。",
        SmartStock = "智能库存检查", AntiAfk = "防挂机保护", AutoReconnect = "自动重连",
        LowFps = "低帧率 / 后台模式", MinCoin = "最低安全金币", Webhook = "Discord Webhook 链接", Delay = "购买延迟（秒）",
        StatsTitle = "📊 会话统计", LogsTitle = "购买历史", NoItem = "尚未购买任何物品。",
        Loaded = "加载成功！", LockedSub = "开发者工具选项卡已锁定。"
    }
}

local function L(key)
    if Translations[currentLang] and Translations[currentLang][key] then
        return Translations[currentLang][key]
    elseif Translations["English"][key] then
        return Translations["English"][key]
    end
    return key
end

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
    SubTitle = "Ultimate AFK & Multi-Language DevSuite",
    TabWidth = 120,
    Size = UDim2.fromOffset(500, 420),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Store = Window:AddTab({ Title = L("Store"), Icon = "shopping-cart" }),
    Presets = Window:AddTab({ Title = L("Presets"), Icon = "bookmark" }),
    Blacklist = Window:AddTab({ Title = L("Blacklist"), Icon = "shield-alert" }),
    DevTools = Window:AddTab({ Title = L("DevTools"), Icon = "lock" }),
    Settings = Window:AddTab({ Title = L("Settings"), Icon = "settings" }),
    Logs = Window:AddTab({ Title = L("Logs"), Icon = "list" })
}

Fluent:Notify({ Title = "Kenopsia HUB", Content = L("Loaded"), SubTitle = L("LockedSub"), Duration = 5 })

Tabs.Store:AddParagraph({ Title = L("AutoBuyTitle"), Content = L("AutoBuyDesc") })
Tabs.Store:AddToggle("AutoBuyToggle", {
    Title = L("ToggleAutoBuy"),
    Default = false,
    Callback = function(Value) autoBuyActive = Value end
})

Tabs.Store:AddParagraph({ Title = L("PartsHeader"), Content = "" })
for _, itemName in ipairs(partItemList) do
    local dName = getCleanDisplayName(itemName)
    selectedItems[itemName] = false
    itemToggles[itemName] = Tabs.Store:AddToggle(itemName, { Title = dName, Default = false, Callback = function(Value) selectedItems[itemName] = Value end })
end

Tabs.Store:AddParagraph({ Title = L("GardenHeader"), Content = "" })
for _, itemName in ipairs(gardenItemList) do
    local dName = getCleanDisplayName(itemName)
    selectedItems[itemName] = false
    itemToggles[itemName] = Tabs.Store:AddToggle(itemName, { Title = dName, Default = false, Callback = function(Value) selectedItems[itemName] = Value end })
end

Tabs.Presets:AddParagraph({ Title = L("PresetsTitle"), Content = L("PresetsDesc") })
Tabs.Presets:AddButton({
    Title = L("PresetVehicle"),
    Description = L("PresetVehicleDesc"),
    Callback = function()
        local vehicleItems = {"basicWheel-t1", "utilityWheel-t1", "bigWheel-t1", "piston-t1", "hinge-t1", "thruster-t1", "propeller-t1"}
        for _, itemName in ipairs(vehicleItems) do
            if itemToggles[itemName] then itemToggles[itemName]:SetValue(true) end
        end
    end
})

Tabs.Presets:AddButton({
    Title = L("PresetFarm"),
    Description = L("PresetFarmDesc"),
    Callback = function()
        local farmItems = {"basic-sprinkler", "advanced-sprinkler", "master-sprinkler", "structural-oil", "mechanical-oil", "combat-oil", "crateDrone"}
        for _, itemName in ipairs(farmItems) do
            if itemToggles[itemName] then itemToggles[itemName]:SetValue(true) end
        end
    end
})

Tabs.Presets:AddButton({
    Title = L("ResetPreset"),
    Description = L("ResetPresetDesc"),
    Callback = function()
        for itemName, _ in pairs(selectedItems) do
            if itemToggles[itemName] then itemToggles[itemName]:SetValue(false) end
        end
    end
})

Tabs.Blacklist:AddParagraph({ Title = L("BlacklistTitle"), Content = L("BlacklistDesc") })
for _, itemName in ipairs(partItemList) do
    local dName = getCleanDisplayName(itemName)
    blacklistedItems[itemName] = false
    blacklistToggles[itemName] = Tabs.Blacklist:AddToggle("BL_"..itemName, { Title = "Skip: " .. dName, Default = false, Callback = function(Value) blacklistedItems[itemName] = Value end })
end

local devParagraph = Tabs.DevTools:AddParagraph({ Title = L("Locked"), Content = L("EnterPass") })

local function buildUnlockedDevTools()
    devParagraph:SetTitle(L("Unlocked"))
    devParagraph:SetDesc("Full developer access enabled.")

    Tabs.DevTools:AddButton({
        Title = "Load SimpleSpy (Remote Inspector GUI)",
        Description = "Open SimpleSpy GUI.",
        Callback = function()
            pcall(function() loadstring(game:HttpGet("https://github.com/exxtremeshock/SimpleSpy/raw/master/SimpleSpy.lua"))() end)
            Fluent:Notify({ Title = "SimpleSpy", Content = "SimpleSpy loaded!", Duration = 3 })
        end
    })

    Tabs.DevTools:AddToggle("DevLoggingToggle", { Title = "Kenopsia Internal Remote Logger", Default = true, Callback = function(Value) devLoggingActive = Value end })

    Tabs.DevTools:AddButton({
        Title = "Test Remote FireServer (Ping Test)",
        Callback = function()
            local testBuffer = buffer.fromstring("\0\6\0blocks_test\0test")
            pcall(function() merchantRemote:FireServer(testBuffer, {}) end)
            Fluent:Notify({ Title = "DevTools", Content = "Test Remote sent!", Duration = 3 })
        end
    })

    Tabs.DevTools:AddButton({
        Title = "Force Garbage Collection (Clean Memory)",
        Callback = function()
            local memBefore = gcinfo() or collectgarbage("count")
            collectgarbage("collect")
            local memAfter = gcinfo() or collectgarbage("count")
            Fluent:Notify({ Title = "DevTools", Content = string.format("Freed ±%d KB", math.floor(memBefore - memAfter)), Duration = 3 })
        end
    })

    local DevInfoParagraph = Tabs.DevTools:AddParagraph({ Title = "📊 Real-time Memory Status", Content = "Loading..." })
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
    Title = L("EnterPass"),
    Default = "",
    Placeholder = L("PassPlaceholder"),
    Finished = true,
    Callback = function(Value)
        if isDevUnlocked then return end
        if Value == "kenopsia2004" then
            isDevUnlocked = true
            Fluent:Notify({ Title = "Unlocked", Content = L("CorrectPass"), Duration = 4 })
            buildUnlockedDevTools()
        else
            Fluent:Notify({ Title = "Access Denied", Content = L("WrongPass"), Duration = 4 })
        end
    end
})

Tabs.Settings:AddParagraph({ Title = L("SettingsTitle"), Content = L("SettingsDesc") })

-- Pilihan Bahasa (Default: English, Bahasa Kedua: Indonesian, Serta Bahasa Lainnya)
Tabs.Settings:AddDropdown("LanguageDropdown", {
    Title = "Language / Bahasa / Idioma / Язык / 语言",
    Description = "Select UI Language (Default: English)",
    Values = {"English", "Indonesian", "Spanish", "Portuguese", "Russian", "Chinese"},
    Default = 1,
    Callback = function(Value)
        currentLang = Value
        Fluent:Notify({ Title = "Language Updated", Content = "Language changed to: " .. Value, Duration = 3 })
    end
})

Tabs.Settings:AddToggle("SmartStockToggle", { Title = L("SmartStock"), Default = true, Callback = function(Value) smartStockActive = Value end })
Tabs.Settings:AddToggle("AntiAfkToggle", { Title = L("AntiAfk"), Default = true, Callback = function(Value) antiAfkActive = Value end })
Tabs.Settings:AddToggle("AutoReconnectToggle", { Title = L("AutoReconnect"), Default = true, Callback = function(Value) autoReconnectActive = Value end })
Tabs.Settings:AddToggle("OptimizeFpsToggle", { Title = L("LowFps"), Default = false, Callback = function(Value) optimizeFpsActive = Value if not Value then setfpscap(999) end end })
Tabs.Settings:AddInput("MinCoinInput", { Title = L("MinCoin"), Default = "0", Numeric = true, Finished = true, Callback = function(Value) minCoinThreshold = tonumber(Value) or 0 end })
Tabs.Settings:AddInput("WebhookInput", { Title = L("Webhook"), Default = "", Finished = true, Callback = function(Value) webhookUrl = Value end })
Tabs.Settings:AddInput("DelayInput", { Title = L("Delay"), Default = tostring(buyDelay), Numeric = true, Finished = false, Callback = function(Value) local num = tonumber(Value) if num and num >= 0.01 then buyDelay = num end end })

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Tabs.Logs:AddParagraph({ Title = L("StatsTitle"), Content = "Monitoring." })
local LogsParagraph = Tabs.Logs:AddParagraph({ Title = L("LogsTitle"), Content = L("NoItem") })

local logHistory = {}
local function addLog(msg)
    local timeStr = os.date("%H:%M:%S")
    table.insert(logHistory, 1, string.format("[%s] %s", timeStr, msg))
    if #logHistory > 15 then table.remove(logHistory, 16) end
    local uptimeSec = os.time() - sessionStats.startTime
    local statsHeader = string.format("⏱️ Time: %02d:%02d:%02d | 📦 Total: %d\n\n", math.floor(uptimeSec / 3600), math.floor((uptimeSec % 3600) / 60), uptimeSec % 60, sessionStats.itemsBought)
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
        addLog("Buy: " .. getCleanDisplayName(itemName))
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
    local promptGui = CoreGui:FindFirstChild("RobrokPromptGui") or CoreGui:FindFirstChild("RobloxPromptGui")
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
