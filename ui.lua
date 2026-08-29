-- ==========================================
-- KENOPSIA HUB - UI MODULE
-- ==========================================

local Debug = require(game:GetService("ReplicatedStorage"):WaitForChild("KenopsiaDebug", 5)) or _G.KenopsiaDebug
if not Debug then
    Debug = {
        Info = function() end,
        Success = function() end,
        Error = function() end,
        Warning = function() end,
        Debug = function() end
    }
end

if Debug.Info then Debug:Info("Loading UI module...") end

local Fluent, err1 = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
if not Fluent then
    if Debug.Error then Debug:Error("Failed to load Fluent library: " .. tostring(err1)) end
    return nil
end

local SaveManager, err2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
if not SaveManager then
    if Debug.Warning then Debug:Warning("Failed to load SaveManager addon") end
end

local InterfaceManager, err3 = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
if not InterfaceManager then
    if Debug.Warning then Debug:Warning("Failed to load InterfaceManager addon") end
end

if Debug.Success then Debug:Success("Fluent libraries loaded successfully") end

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

if Debug.Debug then Debug:Debug("Created UI tabs") end

local HUB = {
    Fluent = Fluent,
    Window = Window,
    Tabs = Tabs,
    SaveManager = SaveManager or {},
    InterfaceManager = InterfaceManager or {},
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

-- Helper function to clean display names
HUB.getCleanDisplayName = function(rawName)
    if not rawName then return "Unknown" end
    local clean = rawName:gsub("(%l)(%u)", "%1 %2"):gsub("%-t%d+", ""):gsub("%-", " ")
    return clean:gsub("(%a)([%w_']*)", function(first, rest) 
        return first:upper() .. rest:lower() 
    end)
end

-- ==================== FLOATING BUTTON ====================
if Debug.Debug then Debug:Debug("Creating floating button...") end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KenopsiaFloatingGui"
screenGui.ResetOnSpawn = false
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

-- Try to load logo
local logoUrl = "https://raw.githubusercontent.com/KenopsiaHUB-101/Kenopsia-Hub/main/logo.png"
local logoPath = "kenopsia_logo.png"

pcall(function()
    if getcustomasset and writefile and isfile then
        if not isfile(logoPath) then
            local logoData = game:HttpGet(logoUrl, true)
            if logoData then
                writefile(logoPath, logoData)
                if Debug.Debug then Debug:Debug("Logo saved to file") end
            end
        end
        if isfile(logoPath) then
            toggleBtn.Image = getcustomasset(logoPath)
            if Debug.Success then Debug:Success("Logo loaded successfully") end
        end
    end
end)

-- Virtual input manager for stable mobile toggle
local VirtualInputManager = game:GetService("VirtualInputManager")

local function safeToggleUI()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
    end)
end

-- Handle button input
toggleBtn.TouchEnded:Connect(function()
    safeToggleUI()
end)

toggleBtn.MouseButton1Click:Connect(function()
    safeToggleUI()
end)

HUB.FloatingButton = screenGui

if Debug.Success then Debug:Success("Floating button created successfully") end

-- ==================== NOTIFICATION ====================
pcall(function()
    Fluent:Notify({ 
        Title = "Kenopsia HUB", 
        Content = "UI loaded successfully! Premium features available.", 
        Duration = 4 
    })
end)

if Debug.Success then Debug:Success("UI module initialization complete") end

return HUB
