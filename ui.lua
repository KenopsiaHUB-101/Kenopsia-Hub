local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Kenopsia HUB | Build & Crush",
    SubTitle = "Have a nice day!",
    TabWidth = 120,
    Size = UDim2.fromOffset(520, 440),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Store = Window:AddTab({ Title = "Store", Icon = "shopping-cart" }),
    Misc = Window:AddTab({ Title = "MISC", Icon = "wrench" }),
    Monitoring = Window:AddTab({ Title = "Monitoring", Icon = "activity" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local HUB = {
    Fluent = Fluent,
    Window = Window,
    Tabs = Tabs,
    SaveManager = SaveManager,
    InterfaceManager = InterfaceManager,
    State = {
        selectedItems = {},
        serverStockCache = {},
        bufferCache = {},
        autoBuyActive = false,
        smartStockActive = true,
        antiAfkActive = true,
        autoReconnectActive = true,
        optimizeFpsActive = false,
        webhookUrl = "",
        minCoinThreshold = 0,
        buyDelay = 0.2,
        currentLang = "English",
        sessionStats = { itemsBought = 0, startTime = os.time() },
        logHistory = {},
        addLog = nil
    }
}

HUB.getCleanDisplayName = function(rawName)
    local clean = rawName:gsub("(%l)(%u)", "%1 %2"):gsub("%-t%d+", ""):gsub("%-", " ")
    return clean:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
end

Fluent:Notify({ Title = "Kenopsia HUB", Content = "Modular System Loaded Successfully!", Duration = 4 })

return HUB
