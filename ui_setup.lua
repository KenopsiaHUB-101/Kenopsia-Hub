local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Kenopsia HUB | Build & Crush",
    SubTitle = "Have a nice day!",
    TabWidth = 120,
    Size = UDim2.fromOffset(500, 420),
    Theme = "Dark"
})

-- Tab Presets & Blacklist sudah di-remove
local Tabs = {
    Store = Window:AddTab({ Title = "Store", Icon = "shopping-cart" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
    DevTools = Window:AddTab({ Title = "DevTools", Icon = "lock" }),
}

return {
    Fluent = Fluent,
    Window = Window,
    Tabs = Tabs,
    SaveManager = SaveManager,
    InterfaceManager = InterfaceManager
}

