local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Kenopsia HUB | Build & Crush",
    SubTitle = "Have a nice day!",
    TabWidth = 120,
    Size = UDim2.fromOffset(530, 450),
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
        audioAlertActive = true,
        streamproofActive = false,
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

-- ==================== FLOATING BUTTON (MOBILE / LOGO GITHUB - FIX JOYSTICK) ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KenopsiaFloatingGui"
screenGui.Parent = game:GetService("CoreGui")

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Parent = screenGui
toggleBtn.Size = UDim2.fromOffset(50, 50)
toggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
toggleBtn.Active = true
toggleBtn.Draggable = true

local corner = Instance.new("UICorner", toggleBtn)
corner.CornerRadius = UDim.new(0, 12)

-- Download & Load Logo dari GitHub Raw
local logoUrl = "https://raw.githubusercontent.com/KenopsiaHUB-101/Kenopsia-Hub/main/logo.png"
local logoPath = "kenopsia_logo.png"

pcall(function()
    if getcustomasset and writefile then
        if not (isfile and isfile(logoPath)) then
            writefile(logoPath, game:HttpGet(logoUrl))
        end
        toggleBtn.Image = getcustomasset(logoPath)
    end
end)

-- Sistem Toggle UI yang Stabil untuk Mobile (Mencegah Joystick Freeze)
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Fungsi simulasi penekanan tombol yang aman dengan delay
local function safeToggleUI()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    -- Sedikit penundaan agar Roblox di mobile dapat memproses KeyDown dengan benar
    task.wait(0.05) 
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end

-- Gunakan TouchEnded untuk input yang lebih stabil di perangkat Mobile
toggleBtn.TouchEnded:Connect(function()
    safeToggleUI()
end)

-- Kasus menempel di layar jika jari meleset (untuk keamanan KeyUp)
toggleBtn.TouchCancelled:Connect(function()
    -- VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)

HUB.FloatingButton = screenGui
-- ================================================================================

Fluent:Notify({ Title = "Kenopsia HUB", Content = "Modular System & Custom Logo Ready!", Duration = 4 })

return HUB
